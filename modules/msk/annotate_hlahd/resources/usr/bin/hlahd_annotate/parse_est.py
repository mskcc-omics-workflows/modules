from pathlib import Path

_NULL_ALLELE = {'-', ''}

_EXONS = ('exon2', 'exon3')


def _parse_coverage(field: str) -> dict:
    """
    Parse a coverage field like 'exon2:262.426:comp.0,exon3:303.069:incomp.7'
    into {exon2_depth, exon2_incomp, exon3_depth, exon3_incomp}.
    comp.N -> incomp 0; incomp.N -> incomp N. Missing/null -> None values.
    """
    cov = {}
    for e in _EXONS:
        cov[f'{e}_depth'] = None
        cov[f'{e}_incomp'] = None

    if not field or field.strip() in _NULL_ALLELE:
        return cov

    for part in field.split(','):
        bits = part.split(':')
        if len(bits) != 3:
            continue
        exon, depth, status = bits[0].strip(), bits[1].strip(), bits[2].strip()
        if exon not in _EXONS:
            continue
        try:
            cov[f'{exon}_depth'] = float(depth)
        except ValueError:
            cov[f'{exon}_depth'] = None
        if status.startswith('incomp.'):
            try:
                cov[f'{exon}_incomp'] = int(status.split('.', 1)[1])
            except ValueError:
                cov[f'{exon}_incomp'] = None
        elif status.startswith('comp'):
            cov[f'{exon}_incomp'] = 0

    return cov


def _first_allele(field: str) -> str | None:
    """First allele in a comma-separated est column, HLA- stripped; None if null."""
    field = field.strip()
    if field in _NULL_ALLELE:
        return None
    first = field.split(',')[0].strip().removeprefix('HLA-')
    return first or None


def parse_est(est_file: Path) -> dict:
    """
    Parse *_{A,B,C}.est.txt. Used for flag extraction and cross-validation only.
    Never used as the authoritative source for allele calls.

    Returns dict with:
        multiple_best_pairs (bool): True if #Best allele pair count > 1
        has_ambiguous_pair (bool): True if #Other ambiguous pair section present
        ambiguous_alleles (str | None): 'allele1 / allele2' from ambiguous section
        best_pair_alleles (list[str]): all alleles from best-pair data rows, HLA- stripped
        best_pairs (list[dict]): per best pair, with representative names
            allele1/allele2 (str | None) and allele1_coverage/allele2_coverage dicts
    """
    result = {
        'multiple_best_pairs': False,
        'has_ambiguous_pair': False,
        'ambiguous_alleles': None,
        'best_pair_alleles': [],
        'best_pairs': [],
    }

    if not est_file.exists():
        return result

    with open(est_file) as f:
        lines = [line.rstrip('\n') for line in f]

    in_ambiguous_section = False
    best_pair_alleles = []
    best_pairs = []

    for line in lines:
        if not line:
            continue

        if line.startswith('#Best allele pair'):
            # Format: "#Best allele pair\t<count>"
            parts = line.split('\t')
            count = int(parts[1]) if len(parts) > 1 else 1
            result['multiple_best_pairs'] = count > 1
            in_ambiguous_section = False

        elif line.startswith('#Other ambiguous pair'):
            result['has_ambiguous_pair'] = True
            in_ambiguous_section = True

        elif line.startswith('#'):
            in_ambiguous_section = False

        else:
            cols = line.split('\t')
            if in_ambiguous_section:
                # Ambiguous data lines: single allele per column (not lists)
                if len(cols) >= 2:
                    a1 = cols[0].strip().removeprefix('HLA-')
                    a2 = cols[1].strip().removeprefix('HLA-')
                    result['ambiguous_alleles'] = f"{a1} / {a2}"
            else:
                # Best pair data lines: col0=allele1_comma_list, col1=allele2_comma_list
                for col in cols[:2]:
                    col = col.strip()
                    if col in _NULL_ALLELE:
                        continue
                    for a in col.split(','):
                        a = a.strip().removeprefix('HLA-')
                        if a:
                            best_pair_alleles.append(a)
                allele1_cov = _parse_coverage(cols[2]) if len(cols) > 2 else _parse_coverage('')
                allele2_cov = _parse_coverage(cols[3]) if len(cols) > 3 else _parse_coverage('')
                best_pairs.append({
                    'allele1': _first_allele(cols[0]) if len(cols) > 0 else None,
                    'allele2': _first_allele(cols[1]) if len(cols) > 1 else None,
                    'allele1_coverage': allele1_cov,
                    'allele2_coverage': allele2_cov,
                })

    result['best_pair_alleles'] = best_pair_alleles
    result['best_pairs'] = best_pairs
    return result


def cross_check_allele(
    allele: str | None,
    best_pair_alleles: list[str],
) -> tuple[bool, str | None]:
    """
    Check that an allele from final.result.txt appears in the est.txt best pair allele lists.
    Matching is performed at the field depth of the reported allele (2 or 3 fields).

    Returns (match_found, detail_string).
    If match_found is True, detail_string is None.
    Hard warning to stderr is the caller's responsibility.
    """
    if not allele or not best_pair_alleles:
        return True, None

    a = allele.removeprefix('HLA-')
    fields = a.split(':')
    n_fields = len(fields)

    truncated = set()
    for bp in best_pair_alleles:
        bp_fields = bp.split(':')
        truncated.add(':'.join(bp_fields[:n_fields]))

    if a in truncated:
        return True, None

    shown = sorted(truncated)[:10]
    detail = f"final={allele}; est_best_alleles={','.join(shown)}"
    return False, detail
