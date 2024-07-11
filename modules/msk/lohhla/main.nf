process LOHHLA {
    tag "$meta.id"
    label 'process_high'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'mskcc.jfrog.io/omicswf-docker-dev-local/mskcc-omics-workflows/lohhla:0.0.1' :
        'mskcc.jfrog.io/omicswf-docker-dev-local/mskcc-omics-workflows/lohhla:0.0.1' }"

    input:
    tuple val(meta),
        path(bamTumor),
        path(bamNormal),
        path(winnersHla), // HLA output from polysolver or other hla caller.
        path(purityOut) // purityOut is from FACETS run

    output:
    tuple val(meta), path("*.DNA.HLAlossPrediction_CI.txt"), emit: prediction
    tuple val(meta), path("*DNA.IntegerCPN_CI.txt")        , emit: integercpn
    tuple val(meta), path("*.pdf")                         , emit: pdf
    tuple val(meta), path("*.RData")                       , emit: rdata
    path  "versions.yml"                                   , emit: versions


    when:
    task.ext.when == null || task.ext.when

    script:
    def args              = task.ext.args ?: ''
    def prefix            = task.ext.prefix ?: "${meta.id}"
    def prefixTumor       = task.ext.prefix ?: "${meta.tumor_id}"
    def prefixNormal      = task.ext.prefix ?: "${meta.normal_id}"
    def outputPrefix      = task.ext.prefix ?: "${prefixTumor}__${prefixNormal}"
    def hlaFasta          =  "/lohhla/data/abc_complete.fasta"
    def hlaDat            = "/lohhla/data/hla.dat"

    """

    samtools index -b ${bamTumor}
    samtools index -b ${bamNormal}

    cat ${winnersHla} | tr "\t" "\n" | grep -v "HLA" > massaged.winners.hla.txt

    PURITY=\$(grep Purity *_purity.out | grep -oP "[0-9\\.]+|NA+")
    [[ \$PURITY == "NA" ]] && PURITY=0.5
    PLOIDY=\$(grep Ploidy *_purity.out | grep -oP "[0-9\\.]+|NA+")
    #cat <(echo -e "tumorPurity\ttumorPloidy") <(echo -e "${prefixTumor}\t\$PURITY\t\$PLOIDY") > tumor_purity_ploidy.txt
    cat <(echo -e "tumorPurity\ttumorPloidy") <(echo -e "${prefixTumor}\t\$PURITY\t\$PLOIDY") > tumor_purity_ploidy.txt

    Rscript --no-init-file /lohhla/LOHHLAscript.R \\
        --patientId ${outputPrefix} \\
        --normalBAMfile ${bamNormal} \\
        --tumorBAMfile ${bamTumor} \\
        --HLAfastaLoc ${hlaFasta} \\
        --HLAexonLoc ${hlaDat} \\
        --CopyNumLoc tumor_purity_ploidy.txt \\
        --hlaPath massaged.winners.hla.txt \\
        --gatkDir /picard-tools \\
        --novoDir /opt/conda/bin \\
        $args 

    if [[ -f ${outputPrefix}.*.DNA.HLAlossPrediction_CI.txt ]]
    then
        sed -i "s/^${prefixTumor}/${outputPrefix}/g" ${outputPrefix}.*.DNA.HLAlossPrediction_CI.txt
        mv ${outputPrefix}.*.DNA.HLAlossPrediction_CI.txt ${outputPrefix}.DNA.HLAlossPrediction_CI.txt
    else
        rm -rf *.DNA.HLAlossPrediction_CI.txt
        touch ${outputPrefix}.DNA.HLAlossPrediction_CI.txt
    fi

    if [[ -f ${outputPrefix}.*.DNA.IntegerCPN_CI.txt ]]
    then
        sed -i "s/^/${outputPrefix}\t/g" ${outputPrefix}.*.DNA.IntegerCPN_CI.txt
        sed -i "0,/^${outputPrefix}\t/s//sample\t/" ${outputPrefix}.*.DNA.IntegerCPN_CI.txt
        mv ${outputPrefix}.*.DNA.IntegerCPN_CI.txt ${outputPrefix}.DNA.IntegerCPN_CI.txt
    else
        rm -rf *.DNA.IntegerCPN_CI.txt
        touch ${outputPrefix}.DNA.IntegerCPN_CI.txt
    fi

    if find Figures -mindepth 1 | read
    then
        mv Figures/* .
        mv ${prefixTumor}.minCoverage_*.HLA.pdf ${outputPrefix}.HLA.pdf
    fi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        lohhla: v1.17
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefixTumor       = task.ext.prefix ?: "${metaT.id}"
    def prefixNormal      = task.ext.prefix ?: "${metaN.id}"
    def outputPrefix      = task.ext.prefix ?: "${prefixTumor}_${prefixNormal}"
    """
    touch ${outputPrefix}.DNA.HLAlossPrediction_CI.txt
    touch ${outputPrefix}.DNA.IntegerCPN_CI.txt
    touch ${outputPrefix}.HLA.pdf

    my_array=("a" "b" "c")

    for hlagene in "\${my_array[@]}"
    do
        touch ${outputPrefix}.hla_\${hlagene}.tmp.data.plots.RData
    done

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        lohhla: v1.17
    END_VERSIONS
    """
}
