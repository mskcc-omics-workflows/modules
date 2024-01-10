// TODO nf-core {COMPLETED}: If in doubt look at other nf-core/modules to see how we are doing things! :)
//               https://github.com/nf-core/modules/tree/master/modules/nf-core/
//               You can also ask for help via your pull request or on the #modules channel on the nf-core Slack workspace:
//               https://nf-co.re/join
// TODO nf-core {IN PROGRESS}: A module file SHOULD only define input and output files as command-line parameters.
//               All other parameters MUST be provided using the "task.ext" directive, see here:
//               https://www.nextflow.io/docs/latest/process.html#ext
//               where "task.ext" is a string.
//               Any parameters that need to be evaluated in the context of a particular sample
//               e.g. single-end/paired-end data MUST also be defined and evaluated appropriately.
// TODO nf-core {COMPLETED}: Software that can be piped together SHOULD be added to separate module files
//               unless there is a run-time, storage advantage in implementing in this way
//               e.g. it's ok to have a single module for bwa to output BAM instead of SAM:
//                 bwa mem | samtools view -B -T ref.fasta
// TODO nf-core {COMPLETED}: Optional inputs are not currently supported by Nextflow. However, using an empty
//               list (`[]`) instead of a file can be used to work around this issue.

process MUTECT1 {
    //tag "$meta.id"
    label 'process_single'

    // TODO nf-core: List required Conda package(s) {COMPLETED - NO CONDA PACKAGES}.
    //               Software MUST be pinned to channel (i.e. "bioconda"), version (i.e. "1.10").
    //               For Conda, the build (i.e. "h9402c20_2") must be EXCLUDED to support installation on different operating systems.
    // TODO nf-core: See section in main README for further information regarding finding and adding container addresses to the section below.
    container 'ghcr.io/msk-access/test:latest'

    input:
    // TODO nf-core: Where applicable all sample-specific information e.g. "id", "single_end", "read_group"
    //               MUST be provided as an input via a Groovy Map called "meta". 
    //               This information may not be required in some instances e.g. indexing reference genome files:
    //               https://github.com/nf-core/modules/blob/master/modules/nf-core/bwa/index/main.nf
    // TODO nf-core: Where applicable please provide/convert compressed files as input/output {COMPLETED}
    //               e.g. "*.fastq.gz" and NOT "*.fastq", "*.bam" and NOT "*.sam" etc.
    tuple val(case_sample_name), path(case_bam), path(case_bais)
    tuple val(control_sample_name), path(control_bam), path(control_bais)
    tuple val(bed_file), val(fasta_file), val(fasta_index_file)

    output:
    // TODO nf-core: Named file extensions MUST be emitted for ALL output channels {COMPLETED}
    tuple val(case_sample_name),val(control_sample_name), path("*.mutect.vcf"), emit: vcf
    tuple val(case_sample_name),val(control_sample_name), path("*.mutect.txt"), emit: standard_mutect_output
    // TODO nf-core: List additional required output channels/values here {COMPLETED}
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    //def prefix = task.ext.prefix ?: "${meta.id}"
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    def reference_fasta = ref_fasta ? "--reference_sequence ${fasta}" : ''
    def bed_file = bed ? "--intervals ${bed}" : ''
    def control_bam_file = control_bam ? "--intervals ${control_bam}" : ''
    def case_bam_file = case_bam ? "--intervals ${case_bam}" : ''

    // TODO nf-core: Where possible, a command MUST be provided to obtain the version number of the software e.g. 1.10
    //               If the software is unable to output a version number on the command-line then it can be manually specified
    //               e.g. https://github.com/nf-core/modules/blob/master/modules/nf-core/homer/annotatepeaks/main.nf
    //               Each software used MUST provide the software name and version number in the YAML version file (versions.yml)
    // TODO nf-core: It MUST be possible to pass additional parameters to the tool as a command-line string via the "task.ext.args" directive {COMPLETED}
    // TODO nf-core: If the tool supports multi-threading then you MUST provide the appropriate parameter
    //               using the Nextflow "task" variable e.g. "--threads $task.cpus" {COMPLETED - NO THREADS REQUIRED}
    // TODO nf-core: Please replace the example samtools command below with your module's command {COMPLETED}
    // TODO nf-core: Please indent the command appropriately (4 spaces!!) to help with readability ;) {COMPLETED}
    """
    java -Xmx28g -Xms256m -XX:-UseGCOverheadLimit -jar /usr/bin/mutect.jar -T MuTect \
    --cosmic ${TBD} \
    --dbsnp ${TBD} \
    --input_file_normal ${control_bam} \
    --input_file_tumor ${case_bam} \
    --intervals ${bed} \
    --normal_sample_name ${control_sample_name} \
    --out "${case_sample_name}.${control_sample_name}.mutect.txt" \
    --reference_sequence ${fasta} \
    --tumor_sample_name ${case_sample_name} \
    --vcf "${case_sample_name}.${control_sample_name}.mutect.vcf"


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        mutect1: \$(java -Xmx28g -Xms256m -XX:-UseGCOverheadLimit -jar /usr/bin/mutect.jar -T MuTect')
    END_VERSIONS
    """

    stub:
    //def prefix = task.ext.prefix ?: "${meta.id}"
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    def reference_fasta = ref_fasta ? "--reference_sequence ${fasta}" : ''
    def bed_file = bed ? "--intervals ${bed}" : ''
    def control_bam_file = control_bam ? "--intervals ${control_bam}" : ''
    def case_bam_file = case_bam ? "--intervals ${case_bam}" : ''
    // TODO nf-core: A stub section should mimic the execution of the original module as best as possible {COMPLETED}
    //               Have a look at the following examples:
    //               Simple example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bcftools/annotate/main.nf#L47-L63
    //               Complex example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bedtools/split/main.nf#L38-L54
    """
    touch ${case_sample_name}.${control_sample_name}.mutect.txt
    touch ${case_sample_name}.${control_sample_name}.mutect.vcf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        mutect1: \$(java -Xmx28g -Xms256m -XX:-UseGCOverheadLimit -jar /usr/bin/mutect.jar -T MuTect')
    END_VERSIONS
    """
}
