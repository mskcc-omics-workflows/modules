from pathlib import Path


def load_pgroup_table(pgroup_file: Path) -> dict[str, str]:
    """
    Parse IMGT wmda hla_nom_p.txt.
    Returns lookup dict: allele at 2/3/4-field resolution -> P-group designation.
    e.g., 'A*02:01' -> 'A*02:01P', 'A*02:01:01' -> 'A*02:01P'
    """
    lookup: dict[str, str] = {}
    with open(pgroup_file) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            parts = line.split(';')
            if len(parts) != 3:
                continue
            locus_prefix = parts[0]        # e.g., 'A*'
            alleles_str = parts[1]         # e.g., '02:01:01:01/02:01:01:02'
            pg_raw = parts[2].strip()
            if not pg_raw:
                continue  # skip alleles not assigned to any P-group
            p_group = locus_prefix + pg_raw  # e.g., 'A*02:01P'

            for allele_fields in alleles_str.split('/'):
                allele_fields = allele_fields.strip()
                if not allele_fields:
                    continue
                # Strip trailing IMGT expression suffixes (N=null, L=low, S=secreted,
                # Q=questionable, C=aberrant cytoplasm, A=aberrant, G=null genomic)
                # from the last colon-field. IMGT uses uppercase only.
                fields = allele_fields.split(':')
                fields[-1] = fields[-1].rstrip('NLSQCAG')
                # MAX_HLA_FIELDS = 4; build keys at 2-, 3-, and 4-field resolution
                for n in range(2, min(5, len(fields) + 1)):
                    key = locus_prefix + ':'.join(fields[:n])
                    if key not in lookup:
                        lookup[key] = p_group
    return lookup


def lookup_pgroup(allele: str | None, lookup: dict[str, str]) -> tuple[str | None, bool]:
    """
    Look up P-group for a reported allele.

    Strips HLA- prefix before lookup. Tries match at reported field depth,
    then falls back to shorter fields (minimum 2 fields).

    Sentinel values treated as "not found" (returns (None, False)):
        - None
        - 'Not typed' (HLA-HD value when locus has insufficient reads)
        - '-' (HLA-HD value when only one allele is identified)

    Returns:
        (p_group, found): tuple of the P-group string and a bool indicating success.
        If not found, p_group is None and found is False.
    """
    if not allele or allele in ('Not typed', '-'):
        return None, False

    a = allele.removeprefix('HLA-')
    fields = a.split(':')

    # Try from full depth down to 2 fields
    for n in range(len(fields), 1, -1):
        key = ':'.join(fields[:n])
        if key in lookup:
            return lookup[key], True

    return None, False
