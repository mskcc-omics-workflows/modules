# CI: how `nf-test` runs in this repo

This documents the moving parts behind `.github/workflows/nf-test.yml` for
contributors adding or debugging modules/subworkflows. It focuses on one
piece that's easy to miss: **cross-repo component installation** — how a
subworkflow declares a dependency on an nf-core module and gets it fetched
automatically in CI.

## Contents
- [Pipeline overview](#pipeline-overview)
- [Change detection & sharding](#change-detection--sharding)
- [`nf-test-action`: the composite action](#nf-test-action-the-composite-action)
- [Cross-repo component installation](#cross-repo-component-installation)
- [Declaring a component dependency](#declaring-a-component-dependency)
- [`confirm-pass`](#confirm-pass)

## Pipeline overview

`nf-test.yml` has three jobs:

1. **`nf-test-changes`** — diffs the PR against its base and produces a list
   of changed module/subworkflow test paths (tagged via nf-test `tags`).
2. **`nf-test`** — a matrix over `profile: [conda, docker, singularity]` ×
   `shard: [1..5]`. Each cell runs a slice of the changed tests via the
   `nf-test-action` composite action.
3. **`confirm-pass`** — a gate job that fails the overall check if any
   matrix cell failed or was cancelled, and passes only once every cell has
   reported a result. This is the single required status check on PRs.

Only modules/subworkflows whose test files changed (or whose declared
dependencies changed) are run — `nf-test-changes` uses
[`detect-nf-test-changes`](https://github.com/adamrtalbot/detect-nf-test-changes)
for this, so an unrelated PR doesn't re-run the whole repo's test suite.
`.github/skip_nf_test.json` can additionally skip specific paths per-profile
(e.g. a tool that's flaky under conda).

## Change detection & sharding

`nf-test-changes` emits a JSON array of changed test file paths as an
output. Each `nf-test` matrix cell filters that array against
`skip_nf_test.json` for its profile, then calls nf-test with
`--shard <N>/<TOTAL_SHARDS>` so the (filtered) test set is spread across 5
shards per profile. Sharding is by *individual test*, not by file — a
subworkflow test file with 3 tests can have its tests land on 3 different
shards. This is why, when triaging a CI failure, you should check sibling
shards for the *other* tests in the same file rather than assuming the
whole file failed together.

## `nf-test-action`: the composite action

`.github/actions/nf-test-action/action.yml` is the shared setup + run
sequence used by every matrix cell. In order:

1. Set up Java, Nextflow, Python.
2. **Install cross-repo component dependencies** (see below) — runs before
   nf-test is even installed, since it just populates directories nf-test
   will need on disk.
3. Install `nf-test` itself.
4. Set up Apptainer (singularity profile only) / Conda (conda profile only).
5. Configure Nextflow secrets (Sentieon, OncoKB) if present.
6. Log in to the JFrog registry for Docker, and write a scoped
   `docker-config.json` for Apptainer/Singularity (scoped to
   `mskcc.jfrog.io` only — setting JFrog creds globally would leak
   basic-auth to `ghcr.io`/`quay.io` pulls and get rejected with 403).
7. Run `nf-test test --profile=<profile> --shard <N>/<TOTAL> ... <paths>`.
8. On failure, append a results table to the job summary from the TAP
   output.

## Cross-repo component installation

This repo only version-controls `modules/msk/` and `subworkflows/msk/` —
`modules/nf-core/` and `subworkflows/nf-core/` are **gitignored**
(see `.gitignore`). They're not vendored; they're fetched fresh into the
workspace before each CI run (and must be fetched manually for local
testing — see below).

The fetch is driven by `.github/scripts/install-components.sh`, called once
per matrix cell with every subworkflow `meta.yml` file as an argument:

```bash
mapfile -t metas < <(find subworkflows -name meta.yml)
bash .github/scripts/install-components.sh "${metas[@]}"
```

For each `meta.yml`, the script reads its `components:` list (via `yq`) and,
for each entry that is a **dict** (not a bare string — see next section), does
a shallow sparse checkout:

```bash
git init
git remote add origin "$remote"          # default: https://github.com/nf-core/modules.git
git config core.sparseCheckout true
echo "modules/$org/$name/" > .git/info/sparse-checkout
git fetch --depth 1 origin "$ref"        # default ref: master
git checkout FETCH_HEAD
mv <fetched dir> modules/$org/$name      # or subworkflows/$org/$name
```

i.e. it's a shallow, path-scoped clone of just that one module/subworkflow
directory — not a full checkout of `nf-core/modules`. This keeps CI fast:
only the components actually declared as dependencies get pulled, from
whatever ref is specified (defaulting to `nf-core/modules@master`).

Two caching behaviors worth knowing:
- **Dedup within a run**: if two subworkflows declare the same
  `(remote, org_path, name, ref)`, it's only fetched once (`seen[$key]`).
- **Skip if already present**: if `modules/$org/$name` already exists on
  disk, the script leaves it alone rather than re-fetching. CI always
  starts from a clean checkout, so this only matters for local reruns — if
  you change a component's declared `git_sha`/`branch` and rerun locally,
  delete the stale directory first or you'll silently keep testing the old
  ref.

## Declaring a component dependency

In a subworkflow's `meta.yml`, `components:` mixes two entry shapes:

```yaml
components:
  - hlahd                        # bare string: local msk module, already
                                  # under version control here — skipped by
                                  # install-components.sh
  - name: samtools/collate       # dict: external, fetched at CI time
    git_remote: https://github.com/nf-core/modules.git
    org_path: nf-core
    # optional: git_sha: <sha>   # pins to a commit
    # optional: branch: <name>  # pins to a branch (git_sha wins if both set)
```

`org_path` defaults to `nf-core` and determines the destination directory
(`modules/<org_path>/<name>`) as well as being validated against
`^[a-z0-9_-]+$`; `name` is validated against `^[a-z0-9_]+(/[a-z0-9_]+)?$`.
Both are used to build a filesystem path, so the script rejects anything
that doesn't match before shelling out to git.

**When adding a new nf-core module dependency to a subworkflow** (e.g. we
added `samtools/collate` while fixing the `hlahd_from_bam` read-pairing bug
in PR #241):

1. Add the dict entry to the subworkflow's `meta.yml` `components:` list.
2. Fetch it locally the same way CI does (or just run any nf-test command —
   `install-components.sh` isn't wired into a local nf-test invocation
   automatically, so do it once by hand):
   ```bash
   TMP=$(mktemp -d)
   git -C "$TMP" init -q
   git -C "$TMP" remote add origin https://github.com/nf-core/modules.git
   git -C "$TMP" config core.sparseCheckout true
   echo "modules/nf-core/<name>/" > "$TMP/.git/info/sparse-checkout"
   git -C "$TMP" fetch --depth 1 origin master -q
   git -C "$TMP" checkout -q FETCH_HEAD
   mv "$TMP/modules/nf-core/<name>" modules/nf-core/<name>
   ```
3. `include { ... } from '../../../modules/nf-core/<name>/main'` in the
   subworkflow's `main.nf`.
4. Run tests locally with `--profile docker` before pushing — CI will fetch
   the same component fresh from the declared ref, so a local pass here is
   a reliable predictor of CI behavior for this step.

## `confirm-pass`

`confirm-pass` is `needs: [nf-test]` with `if: always()`, so it evaluates
after every matrix cell has finished regardless of outcome. It fails if
`needs.*.result` contains `failure` or `cancelled`, and only passes if it
contains `success` — meaning a single failing shard fails the whole check,
even though the other 29 matrix cells are green. This is intentional: it's
the one branch-protection-required status, so PR authors have a single
check to watch rather than 16 individual ones.
