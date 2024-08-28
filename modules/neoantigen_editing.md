# Subworkflow: neoantigen_editing

Compute fitness and quality of the neoantigens

**Keywords:**

| Keywords |
|----------|
| neoantigenediting |
| neoantigens |
| fitness |

## Components

| Components |
| ---------- |
| neoantigenediting/computefitness |
| neoantigenediting/aligntoiedb |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| neoantigenInput_ch | file | The input channel containing the json formatted for NeoantigenEditing by the neoantigeninput module Structure: [ val(meta), path(json) ]  | *.{json} |
| iedbfasta | file | The input channel containing the IEDB fasta file Structure: [ val(meta), path(fasta) ]  | *.{fasta} |

## Outputs

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| annotated_output | file | Channel containing annpotated json output with neoantigen quality Structure: [ val(meta), [ annotated_json ] ]  | *.json |
| versions | file | File containing software versions Structure: [ path(versions.yml) ]  | versions.yml |

## Authors

@johnoooh

