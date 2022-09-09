

workflow:
	@cookiecutter https://github.com/mskcc-omics-workflows/nextflow-template.git --directory="workflow-cookiecutter"

module:
	@cookiecutter https://github.com/mskcc-omics-workflows/nextflow-template.git --directory="module-cookiecutter" -o modules/

