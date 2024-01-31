#!/bin/bash

prefix=$1
read1=$2
read2=$3


if [[ "${read1}" == *gz ]] ; then
    cat_="zcat"
else
    cat_="cat"
fi

function a() {
    awk \
        -v prefix=$3 \
        -v readnumber=$1 \
        '
        BEGIN {FS = ":"}
        {
            lane=$(NF-3)
            flowcell=$(NF-4)
            outfastq=prefix"@"flowcell"_L00"lane"_R"readnumber".split.fastq.gz"
            print | "gzip > "outfastq
            for (i = 1; i <= 3; i++) {
                getline
                print | "gzip > "outfastq
            }
        }
        ' <( eval "$cat_ $2")
}

echo "processing read1"
a 1 ${read1} ${prefix}
if [ ! -z ${read2} ] ; then
    echo "processing read2"
    a 2 ${read2} ${prefix}
fi