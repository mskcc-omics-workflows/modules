#!/bin/bash

### Versioning

VERSION=1.0.0

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

cat $file | tr "\t" "\n" | grep -v "HLA" | tr "\n" "," > massaged.winners.hla.txt

input_string=`head -n 1 massaged.winners.hla.txt`

IFS=',' read -ra items <<< "$input_string"

for item in "${items[@]}"; do

    # Append the transformed item to the output string
    truncated_value=$(echo "$item" | cut -c 1-11)

    # Replace the first '_', the next '_', and remaining '_' with '-', '*', and ':', respectively
    modified_value=$(echo "$truncated_value" | tr '[:lower:]' '[:upper:]' | sed 's/_/-/; s/_//; s/_/:/g')
    output_hla+=",$modified_value"

done

# Remove leading comma
output_hla="${output_hla:1}"
echo $output_hla
