from pathlib import Path
import warnings
import pandas as pd

CLASS_I_LOCI = {'A', 'B', 'C'}
_NULL_VALUES = {'Not typed', '-', ''}
# Positions for alleles: primary pair then optional second pair
_PAIR_POSITIONS = ['allele1', 'allele2', 'allele1_pair2', 'allele2_pair2']


def parse_final_result(result_file: Path) -> pd.DataFrame:
    """
    Parse *_final.result.txt. Returns only class I loci (A, B, C).

    Returns DataFrame with columns:
        locus, allele, allele_position, resolution, multiple_best_pairs
    where:
        - allele: str with HLA- prefix, or None/NaN if Not typed / -
        - allele_position: 'allele1', 'allele2', 'allele1_pair2', 'allele2_pair2'
        - resolution: number of colon-separated fields (0 if null)
        - multiple_best_pairs: True if row has >2 allele columns
    """
    rows = []
    with open(result_file) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            parts = line.split('\t')
            locus = parts[0]
            if locus not in CLASS_I_LOCI:
                continue

            alleles = parts[1:]
            multiple_best_pairs = len(alleles) > 2

            if len(alleles) > len(_PAIR_POSITIONS):
                warnings.warn(
                    f"Row for locus {locus!r} has {len(alleles)} allele columns "
                    f"(max supported: {len(_PAIR_POSITIONS)}); extra alleles ignored.",
                    UserWarning,
                    stacklevel=2,
                )

            for pos, allele in zip(_PAIR_POSITIONS, alleles):
                allele_val = None if allele in _NULL_VALUES else allele
                if allele_val is not None:
                    fields = allele_val.removeprefix('HLA-').split(':')
                    resolution = len(fields)
                else:
                    resolution = 0

                rows.append({
                    'locus': locus,
                    'allele': allele_val,
                    'allele_position': pos,
                    'resolution': resolution,
                    'multiple_best_pairs': multiple_best_pairs,
                })

    return pd.DataFrame(rows, columns=['locus', 'allele', 'allele_position',
                                       'resolution', 'multiple_best_pairs'])
