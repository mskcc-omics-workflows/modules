process NETMHCSTABPAN {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/netmhcstabpan:1.0':
        'docker.io/mskcc/netmhcstabpan:1.0' }"

    input:
    tuple val(meta), path(inputMaf), path(hlaFile)
    

    output:
    tuple val(meta), path("*.MUT.netmhcpan.output"),       path("*.WT.netmhcpan.output"),   emit: netmhcstabpanoutput
    tuple val(meta), path("*_out/*.mutated_sequences.fa"), path("*_out/*.WT_sequences.fa"), emit: fastaSequences
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def netMHCpan_version = '4.1'
    def netMHCstabpan_version = '1.0'
    def in_CDS_file = task.ext.in_CDS_file ?: "/usr/local/bin/Homo_sapiens.GRCh37.75.cds.all.fa.gz"
    def in_CDNA_file = task.ext.in_CDNA_file ?:"/usr/local/bin/Homo_sapiens.GRCh37.75.cdna.all.fa.gz"
    """
    mkdir ${prefix}_out
    python3 /usr/local/bin/generateMutFasta.py --sample_id ${prefix} \
    --output_dir ${prefix}_out \
    --maf_file ${inputMaf} \
    --CDS_file ${in_CDS_file} \
    --CDNA_file ${in_CDNA_file}
    
    
    
    cat ${hlaFile} | tr "\\t" "\\n" | grep -v "HLA" | tr "\\n" "," > massaged.winners.hla.txt


    input_string=`head -n 1 massaged.winners.hla.txt`

    IFS=',' read -ra items <<< "\$input_string"

    for item in "\${items[@]}"; do

        # Append the transformed item to the output string
        truncated_value=\$(echo "\$item" | cut -c 1-11)
        
        # Replace the first '_', the next '_', and remaining '_' with '-', '*', and ':', respectively
        modified_value=\$(echo "\$truncated_value" | tr '[:lower:]' '[:upper:]' | sed 's/_/-/; s/_//; s/_/:/g')
        output_hla+=",\$modified_value"
        
    done

    # Remove leading comma
    output_hla="\${output_hla:1}"

    echo \$output_hla
    /usr/local/bin/netMHCstabpan-1.0/netMHCstabpan -s 1 -BA 1 -f ./${prefix}_out/${prefix}.mutated_sequences.fa -a \$output_hla -l 9,10 -inptype 0 > ${prefix}.MUT.netmhcpan.output

    /usr/local/bin/netMHCstabpan-1.0/netMHCstabpan -s 1 -BA 1 -f ./${prefix}_out/${prefix}.WT_sequences.fa -a \$output_hla -l 9,10 -inptype 0 > ${prefix}.WT.netmhcpan.output


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        netmhcpan: v4.1
        netmhcstabpan: v1.0
    END_VERSIONS

    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def netMHCpan_version = '4.1'
    def netMHCstabpan_version = '1.0'
    """
    touch ${prefix}.MUT.netmhcpan.output
    touch ${prefix}.WT.netmhcpan.output
    mkdir ${prefix}_out
    touch ${prefix}_out/${prefix}.mutated_sequences.fa  
    echo -e ">Mutpeptide \n HEHEHE" > ${prefix}_out/${prefix}.mutated_sequences.fa 

    touch ${prefix}_out/${prefix}.WT_sequences.fa
    echo -e ">WTpeptide \n HEKEHE" > ${prefix}_out/${prefix}.WT_sequences.fa


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        netmhcpan: v4.1
        netmhcstabpan: v1.0
    END_VERSIONS
    """
}
