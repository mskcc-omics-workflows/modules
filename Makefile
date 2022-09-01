

workflow:
	@cookiecutter http://crux.mskcc.org:8929/mpath-dms-pipelines/nextflow-template.git --directory="workflow-cookiecutter"

module:
	@cookiecutter http://crux.mskcc.org:8929/mpath-dms-pipelines/nextflow-template.git --directory="module-cookiecutter" -o modules/

