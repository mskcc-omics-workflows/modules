

workflow:
	@cookiecutter https://github.com/mskcc-omics-workflows/nextflow-template.git --directory="workflow-cookiecutter"

module:
	@cookiecutter https://github.com/mskcc-omics-workflows/nextflow-template.git --directory="module-cookiecutter" -o modules/


dockerfile:
	@read -p "Which module needs the Dockerfile? Enter Module Name:" module; \
	module_dir=./modules/$$module; \
	test -d $$module_dir && cookiecutter https://github.com/mskcc-omics-workflows/nextflow-template.git --directory="dockerfile-cookiecutter" -o $$module_dir/docs --skip-if-file-exists --no-input || echo Module does not exist;

