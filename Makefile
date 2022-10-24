

workflow:
	@cookiecutter https://github.com/mskcc-omics-workflows/nextflow-template.git --directory="workflow-cookiecutter"

module:
	@cookiecutter https://github.com/mskcc-omics-workflows/nextflow-template.git --directory="module-cookiecutter" -o modules/msk-tools/


dockerfile:
	@read -p "Which module needs the Dockerfile? Enter Module Name:" module; \
	module_dir=./modules/msk-tools/$$module; \
	test -d $$module_dir && cookiecutter https://github.com/mskcc-omics-workflows/nextflow-template.git --directory="dockerfile-cookiecutter" -o $$module_dir/container --skip-if-file-exists --no-input || echo Module does not exist;

