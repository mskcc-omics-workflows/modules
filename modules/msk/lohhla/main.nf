process LOHHLA {
    tag "$metaT.id"
    label 'process_high'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker.io/orgeraj/lohhla:1.1.8':
        'docker.io/orgeraj/lohhla:1.1.8' }"

    input:
    tuple val(metaT), path(bamTumor)
    tuple val(metaN), path(bamNormal) 
    tuple val(metahlaN),path(winnersHla) //HLA output from polysolver or other hla caller. 
    tuple val(metaFacets) , path(purityOut)  // purityOut is from FACETS run
    
        

    output:
    tuple val(metaT), val(metaN), path("*.DNA.HLAlossPrediction_CI.txt"), path("*DNA.IntegerCPN_CI.txt"), path("*.pdf"), path("*.RData"), emit: lohhlaOutput
    path  "versions.yml"              , emit: versions


    when:
    task.ext.when == null || task.ext.when

    script:
    def args              = task.ext.args ?: ''
    def prefixTumor       = task.ext.prefix ?: "${metaT.id}"
    def prefixNormal      = task.ext.prefix ?: "${metaN.id}"
    def minCoverageFilter = 10
    def outputPrefix      = task.ext.prefix ?: "${prefixTumor}_${prefixNormal}"
    def hlaFasta          =  "/lohhla/data/abc_complete.fasta"
    def hlaDat            = "/lohhla/data/hla.dat"

    """

    samtools index -b ${bamTumor}
    samtools index -b ${bamNormal}

    cat ${winnersHla} | tr "\t" "\n" | grep -v "HLA" > massaged.winners.hla.txt

    PURITY=\$(grep Purity *_purity.out | grep -oP "[0-9\\.]+|NA+")
    [[ \$PURITY == "NA" ]] && PURITY=0.5
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
        sed -i "s/^${prefixTumor}/${outputPrefix}/g" ${outputPrefix}.${minCoverageFilter}.DNA.HLAlossPrediction_CI.txt
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
        mv ${prefixTumor}.minCoverage_${minCoverageFilter}.HLA.pdf ${outputPrefix}.HLA.pdf
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
    def minCoverageFilter = 10
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

    touch ${outputPrefix}.hla_a.tmp.data.plots.RData

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        lohhla: v1.17
    END_VERSIONS
    """
}
