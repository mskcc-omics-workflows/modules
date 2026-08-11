#!/bin/bash

### Versioning

VERSION=1.2.0

get_help() { echo "USAGE: generateHLASTRING.sh -f [HLA_FILE]"; exit 0; }
get_version() { echo $VERSION; exit 0; }

while (( "$#" )); do
    case $1 in
        -h|--help)  get_help ;;
        -f)         file=$2; shift ;;
        -v)         get_version ;;
        *)          get_help ;;
    esac
    shift
done

output_hla=""

# POLYSOLVER writes one locus per line: a "HLA-A" label followed by the winning
# alleles, e.g.  HLA-B<TAB>hla_b_08_01_01<TAB>hla_b_18_177
# Split on tabs, drop the label column, and keep the allele fields.
parse_polysolver() {
    while IFS= read -r item; do

        [ -n "$item" ] || continue

        # Split on '_' rather than slicing a fixed number of characters: the second
        # field is not always two digits (hla_b_18_177, hla_c_04_320), and truncating
        # it silently produces a different -- sometimes real -- allele.
        item_upper=$(echo "$item" | tr '[:lower:]' '[:upper:]')
        IFS='_' read -r prefix gene field1 field2 _rest <<< "$item_upper"

        if [ "$prefix" != "HLA" ] || [ -z "$gene" ] || [ -z "$field1" ] || [ -z "$field2" ]; then
            echo "WARN: skipping unparseable HLA entry '$item'" >&2
            continue
        fi

        # hla_c_04_320_01 -> HLA-C04:320   (two-field allele name, as netMHCpan expects)
        output_hla+=",HLA-${gene}${field1}:${field2}"

    done < <(tr '\t' '\n' < "$file" | tr -d '\r' | grep -vi '^hla-')
}

# HLA-HD writes one locus per line too, but labels the locus bare and names the
# alleles with '*' and ':', e.g.  B<TAB>HLA-B*07:02:01<TAB>HLA-B*08:01:01
# Untyped loci carry the literal "Not typed", and a locus may list a second,
# equally scoring pair in later columns.
parse_hlahd() {
    while IFS= read -r line; do

        line=$(echo "$line" | tr -d '\r')
        [ -n "$line" ] || continue

        IFS=$'\t' read -r locus allele1 allele2 _rest <<< "$line"

        # Class I only -- netMHCpan scoring here is class I, so DRB1/DQB1/DPB1
        # and friends are out of scope.
        case "$locus" in
            A|B|C) ;;
            *)     continue ;;
        esac

        # Only the first pair is taken. HLA-HD may report an alternative pair on
        # the same line; emitting it would exceed POLYSOLVER's two-per-locus
        # cardinality and score the sample against alleles it may not carry.
        for allele in "$allele1" "$allele2"; do

            [ -n "$allele" ] || continue
            [ "$allele" != "Not typed" ] || continue

            # HLA-A*02:01:01 -> HLA-A02:01   (two-field allele name)
            if [[ "$allele" =~ ^HLA-([A-Za-z0-9]+)\*([0-9]+):([0-9]+) ]]; then
                output_hla+=",HLA-${BASH_REMATCH[1]}${BASH_REMATCH[2]}:${BASH_REMATCH[3]}"
            else
                echo "WARN: skipping unparseable HLA entry '$allele'" >&2
            fi

        done

    done < "$file"
}

# Detect the format once for the whole file rather than per line: a file comes
# from one caller and is never a mix of the two.
if grep -q 'HLA-[A-Za-z0-9]*\*' "$file"; then
    parse_hlahd
else
    parse_polysolver
fi

if [ -z "$output_hla" ]; then
    echo "ERROR: no HLA alleles parsed from $file" >&2
    exit 1
fi

# Remove leading comma
output_hla="${output_hla:1}"
echo "$output_hla"
