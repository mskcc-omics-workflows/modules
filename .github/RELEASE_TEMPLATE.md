<!--
# mskcc-omics-workflows/modules release

Please fill in the appropriate checklist below (delete whatever is not relevant).
Please follow the RELEASE.md in addition to this checklist.

Remember that PRs should be made against the main branch.

Learn more about contributing: [gitbook](https://mskcc-omics-workflows.gitbook.io/omics-wf/GMaCKqX0TmAhUOoZmuc6)

-->

## 1. Pre-Release Checklist

- [ ] All CI tests are passing
- [ ] All relevant issues/PRs are merged
- [ ] Code is linted and formatted
- [ ] Compare `.github/workflows/nf-test.yml` against nf-core's [`nf-test.yml`](https://github.com/nf-core/modules/blob/198f39a55453b855cfa3b88a0cf7f68981540ca7/.github/workflows/nf-test.yml):
    - [ ] Check if `NXF_VER` has changed, and update.
    - [ ] Look for added sections and other larger changes. This my require examining nf-core's [`.github` directory](https://github.com/nf-core/modules/tree/198f39a55453b855cfa3b88a0cf7f68981540ca7/.github)
        - Ignore sharding
        - suggested comparison:
          ```console
          wget https://raw.githubusercontent.com/nf-core/modules/198f39a55453b855cfa3b88a0cf7f68981540ca7/.github/workflows/nf-test.yml -O nf-test-nf.yml
          diff nf-test-nf.yml ./.github/workflows/nf-test.yml
    - [ ] Update develop and release branch with changes if necessary
