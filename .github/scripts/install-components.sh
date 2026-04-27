#!/usr/bin/env bash
# Install cross-repo nf-core/MSK component dependencies declared in a
# subworkflow's meta.yml.
#
# Usage: install-components.sh META_YML [META_YML …]
#
# Each META_YML may declare a `components:` list. Bare-string entries
# (e.g. `- hlahd`) refer to components in this repo and are skipped.
# Dict entries (e.g. `- {name: samtools/view, git_remote: …, org_path: …}`)
# are sparse-checked-out into `modules/<org_path>/<name>/`.
#
# Notes:
# - Only leaf components are installed; transitive `components:` in the
#   fetched modules are not recursively resolved.
# - An existing `modules/<org>/<name>/` directory is treated as a cache hit
#   and not refreshed even if the declared ref has changed. CI always
#   starts from a fresh checkout, so this is fine in practice; for local
#   re-runs, delete the directory to force a refetch.
# - Default ref is `master`. Set `git_sha:` or `branch:` per component to
#   override.

set -euo pipefail

DEFAULT_REMOTE="https://github.com/nf-core/modules.git"
DEFAULT_REF="master"

# Allowlist for path components built from meta.yml input.
NAME_RE='^[a-z0-9_]+(/[a-z0-9_]+)?$'
ORG_RE='^[a-z0-9_-]+$'

TMPROOT=$(mktemp -d)
trap 'rm -rf "$TMPROOT"' EXIT

declare -A seen

for meta in "$@"; do
  [[ -f "$meta" ]] || { echo "skip: $meta not found"; continue; }
  n=$(yq '.components | length // 0' "$meta")
  for i in $(seq 0 $((n - 1))); do
    kind=$(yq ".components[$i] | tag" "$meta")
    [[ "$kind" == "!!str" ]] && continue  # bare = local, skip

    name=$(yq -r   ".components[$i].name"                            "$meta")
    org=$(yq -r    ".components[$i].org_path         // \"nf-core\"" "$meta")
    remote=$(yq -r ".components[$i].git_remote       // \"$DEFAULT_REMOTE\"" "$meta")
    ref=$(yq -r    ".components[$i].git_sha // .components[$i].branch // \"$DEFAULT_REF\"" "$meta")

    [[ "$name" =~ $NAME_RE ]] || { echo "ERROR: invalid component name: $name (in $meta)" >&2; exit 1; }
    [[ "$org"  =~ $ORG_RE  ]] || { echo "ERROR: invalid org_path: $org (in $meta)" >&2; exit 1; }

    key="$remote|$org|$name|$ref"
    [[ -n "${seen[$key]:-}" ]] && continue
    seen[$key]=1

    dest="modules/$org/$name"
    if [[ -d "$dest" ]]; then
      echo "✓ $dest already present"
      continue
    fi

    echo "→ fetching $org/$name from $remote@$ref"
    tmp="$TMPROOT/$org-${name//\//_}-$ref"
    mkdir -p "$tmp"
    git -C "$tmp" init -q
    git -C "$tmp" remote add origin "$remote"
    git -C "$tmp" config core.sparseCheckout true
    echo "modules/$org/$name/" > "$tmp/.git/info/sparse-checkout"
    git -C "$tmp" fetch --depth 1 origin "$ref" -q
    git -C "$tmp" checkout -q FETCH_HEAD
    mkdir -p "$(dirname "$dest")"
    mv "$tmp/modules/$org/$name" "$dest"
  done
done
