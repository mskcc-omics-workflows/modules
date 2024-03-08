<!--
# mskcc-omics-workflows/modules pull request

Many thanks for contributing to mskcc-omics-workflows/modules!

Please fill in the appropriate checklist below (delete whatever is not relevant).
These are the most common things requested on pull requests (PRs).

Remember that PRs should be made against the master branch.

Learn more about contributing: [gitbook](https://mskcc-omics-workflows.gitbook.io/omics-wf/GMaCKqX0TmAhUOoZmuc6)
-->

## PR checklist

Closes #XXX <!-- If this PR fixes an issue, please link it here! -->

- [ ] This comment contains a description of changes (with reason).
- [ ] Check to see if a [nf-core module, or subworkflow](https://github.com/nf-core/modules) is available and usable for your pipeline.
- [ ] Feature branch is named `feature/<module_name>` for modules, or `feature/<subworkflow_name>` for subworkflows. For modules, if there is a subcommand use: `feature/<module_name>/<module_subcommand>`.
- [ ] If you've fixed a bug or added code that should be tested, add tests!
- [ ] If you've added a new tool - have you followed the module conventions in the [contribution docs](https://mskcc-omics-workflows.gitbook.io/omics-wf/GMaCKqX0TmAhUOoZmuc6).
- [ ] Use [nf-core data](https://github.com/nf-core/test-datasets) if possible for nf-tests. If not, add test data to [mskcc-omics-workflows/test-datasets](https://github.com/mskcc-omics-workflows/test-datasets), following the repository guidelines, for nf-tests. Finally, if neither option is feasible, add only a stub nf-test.
- [ ] Remove all TODO statements.
- [ ] Emit the `versions.yml` file.
- [ ] Follow the naming conventions.
- [ ] Follow the parameters requirements.
- [ ] Follow the input/output options guidelines.
- [ ] Add a resource `label`
- [ ] Use Jfrog if possible to fulfil software requirements.
- Ensure that the test works with either Docker / Singularity. Conda CI tests can be quite flaky:
  - For modules:
    - [ ] `nf-core modules --git-remote https://github.com/mskcc-omics-workflows/modules.git -b <module_branch> test <MODULE> --profile docker`
    - [ ] `nf-core modules --git-remote https://github.com/mskcc-omics-workflows/modules.git -b <module_branch> test <MODULE> --profile singularity`
    - [ ] `nf-core modules --git-remote https://github.com/mskcc-omics-workflows/modules.git -b <module_branch> test <MODULE> --profile conda`
  - For subworkflows:
    - [ ] `nf-core subworkflows --git-remote https://github.com/mskcc-omics-workflows/modules.git -b <subworkflow_branch> test <SUBWORKFLOW> --profile docker`
    - [ ] `nf-core subworkflows --git-remote https://github.com/mskcc-omics-workflows/modules.git -b <subworkflow_branch> test <SUBWORKFLOW> --profile singularity`
    - [ ] `nf-core subworkflows --git-remote https://github.com/mskcc-omics-workflows/modules.git -b <subworkflow_branch> test <SUBWORKFLOW> --profile conda`
