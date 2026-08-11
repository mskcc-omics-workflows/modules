#!/bin/bash

### Versioning

VERSION=1.1.0

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
    modified_value="HLA-${gene}${field1}:${field2}"
    output_hla+=",$modified_value"

done < <(tr '\t' '\n' < "$file" | tr -d '\r' | grep -vi '^hla-')

if [ -z "$output_hla" ]; then
    echo "ERROR: no HLA alleles parsed from $file" >&2
    exit 1
fi

# Remove leading comma
output_hla="${output_hla:1}"
echo "$output_hla"
