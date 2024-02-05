// TODO nf-core: If in doubt look at other nf-core/modules to see how we are doing things! :)
//               https://github.com/nf-core/modules/tree/master/modules/nf-core/
//               You can also ask for help via your pull request or on the #modules channel on the nf-core Slack workspace:
//               https://nf-co.re/join
// TODO nf-core: A module file SHOULD only define input and output files as command-line parameters.
//               All other parameters MUST be provided using the "task.ext" directive, see here:
//               https://www.nextflow.io/docs/latest/process.html#ext
//               where "task.ext" is a string.
//               Any parameters that need to be evaluated in the context of a particular sample
//               e.g. single-end/paired-end data MUST also be defined and evaluated appropriately.
// TODO nf-core: Software that can be piped together SHOULD be added to separate module files
//               unless there is a run-time, storage advantage in implementing in this way
//               e.g. it's ok to have a single module for bwa to output BAM instead of SAM:
//                 bwa mem | samtools view -B -T ref.fasta
// TODO nf-core: Optional inputs are not currently supported by Nextflow. However, using an empty
//               list (`[]`) instead of a file can be used to work around this issue.

process LOHHLA {
    tag "$meta.id"
    label 'process_high'

    // TODO nf-core: List required Conda package(s).
    //               Software MUST be pinned to channel (i.e. "bioconda"), version (i.e. "1.10").
    //               For Conda, the build (i.e. "h9402c20_2") must be EXCLUDED to support installation on different operating systems.
    // TODO nf-core: See section in main README for further information regarding finding and adding container addresses to the section below.
    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'cmopipeline/lohhla:1.1.7':
        'cmopipeline/lohhla:1.1.7' }"

    input:
    tuple val(metaT), path(bamTumor)
    tuple val(metaN), path(bamNormal) 
    tuple val(metahlaN),path(winnersHla) //HLA output from polysolver or other hla caller. 
    path(purityOut)  // purityOut is from FACETS run
    tuple path(hlaFasta), path(hlaDat) 
        

    output:
    tuple val(metaT), val(metaN), path("*.DNA.HLAlossPrediction_CI.txt"), path("*DNA.IntegerCPN_CI.txt"), path("*.pdf"), path("*.RData"), emit: lohhlaOutput
    path  "versions.yml"              , emit: versions


    when:
    task.ext.when == null || task.ext.when

    script:
    def args              = task.ext.args ?: ''
    def build_param       = build ? (["GRCh37","hg19"].contains(build) ? "hg19" : "hg38") : "hg19"
    def prefixTumor       = task.ext.prefix ?: "${metaT.id}"
    def prefixNormal      = task.ext.prefix ?: "${metaN.id}"
    def minCoverageFilter = 10
    def outputPrefix      = task.ext.prefix ?: "${prefixTumor}_${prefixNormal}"
    // TODO nf-core: Where possible, a command MUST be provided to obtain the version number of the software e.g. 1.10
    //               If the software is unable to output a version number on the command-line then it can be manually specified
    //               e.g. https://github.com/nf-core/modules/blob/master/modules/nf-core/homer/annotatepeaks/main.nf
    //               Each software used MUST provide the software name and version number in the YAML version file (versions.yml)
    // TODO nf-core: It MUST be possible to pass additional parameters to the tool as a command-line string via the "task.ext.args" directive
    // TODO nf-core: If the tool supports multi-threading then you MUST provide the appropriate parameter
    //               using the Nextflow "task" variable e.g. "--threads $task.cpus"
    // TODO nf-core: Please replace the example samtools command below with your module's command
    // TODO nf-core: Please indent the command appropriately (4 spaces!!) to help with readability ;)
    """


    cat ${winnersHla} | tr "\t" "\n" | grep -v "HLA" > massaged.winners.hla.txt

    PURITY=\$(grep Purity *_purity.out | grep -oP "[0-9\\.]+|NA+")
    PLOIDY=\$(grep Ploidy *_purity.out | grep -oP "[0-9\\.]+|NA+")
    cat <(echo -e "tumorPurity\ttumorPloidy") <(echo -e "${prefixTumor}\t\$PURITY\t\$PLOIDY") > tumor_purity_ploidy.txt

    Rscript --no-init-file /lohhla/LOHHLAscript.R \\
        --patientId ${outputPrefix} \\
        --normalBAMfile ${bamNormal} \\
        --tumorBAMfile ${bamTumor} \\
        --HLAfastaLoc ${hlaFasta} \\
        --HLAexonLoc ${hlaDat} \\
        --CopyNumLoc tumor_purity_ploidy.txt \\
        --minCoverageFilter ${minCoverageFilter} \\
        --hlaPath massaged.winners.hla.txt \\
        --gatkDir /picard-tools \\
        --novoDir /opt/conda/bin \\
        $args 

    if [[ -f ${outputPrefix}.${minCoverageFilter}.DNA.HLAlossPrediction_CI.txt ]]
    then
        sed -i "s/^${idTumor}/${outputPrefix}/g" ${outputPrefix}.${minCoverageFilter}.DNA.HLAlossPrediction_CI.txt
    else
        rm -rf *.DNA.HLAlossPrediction_CI.txt
    fi

    if [[ -f ${outputPrefix}.${minCoverageFilter}.DNA.IntegerCPN_CI.txt ]]
    then
        sed -i "s/^/${outputPrefix}\t/g" ${outputPrefix}.${minCoverageFilter}.DNA.IntegerCPN_CI.txt
        sed -i "0,/^${outputPrefix}\t/s//sample\t/" ${outputPrefix}.${minCoverageFilter}.DNA.IntegerCPN_CI.txt
    else
        rm -rf *.DNA.IntegerCPN_CI.txt
    fi

    touch ${outputPrefix}.${minCoverageFilter}.DNA.HLAlossPrediction_CI.txt
    touch ${outputPrefix}.${minCoverageFilter}.DNA.IntegerCPN_CI.txt

    mv ${outputPrefix}.${minCoverageFilter}.DNA.HLAlossPrediction_CI.txt ${outputPrefix}.DNA.HLAlossPrediction_CI.txt
    mv ${outputPrefix}.${minCoverageFilter}.DNA.IntegerCPN_CI.txt ${outputPrefix}.DNA.IntegerCPN_CI.txt

    if find Figures -mindepth 1 | read
    then
        mv Figures/* .
        mv ${idTumor}.minCoverage_${minCoverageFilter}.HLA.pdf ${outputPrefix}.HLA.pdf
    fi

    

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        lohhla: v1.17
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def prefixTumor       = task.ext.prefix ?: "${metaT.id}"
    def prefixNormal      = task.ext.prefix ?: "${metaN.id}"
    def minCoverageFilter = 10
    def outputPrefix      = task.ext.prefix ?: "${prefixTumor}_${prefixNormal}"

    // TODO nf-core: A stub section should mimic the execution of the original module as best as possible
    //               Have a look at the following examples:
    //               Simple example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bcftools/annotate/main.nf#L47-L63
    //               Complex example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bedtools/split/main.nf#L38-L54
    """
    


    touch ${outputPrefix}.DNA.HLAlossPrediction_CI.txt
    touch ${outputPrefix}.DNA.IntegerCPN_CI.txt
    touch ${outputPrefix}.HLA.pdf

    my_array=("a" "b" "c")

    for hlagene in "\${my_array[@]}"
    do
        touch ${outputPrefix}.hla_\${hlagene}.tmp.data.plots.RData
    done

    touch ${outputPrefix}.hla_a.tmp.data.plots.RData

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        lohhla: v1.17
    END_VERSIONS
    """
}
