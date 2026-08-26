from pathlib import Path
from datetime import date
import pandas as pd
from jinja2 import Environment, FileSystemLoader


def _cov_cell(a1, a2, exon):
    """Display string for one exon across both alleles, e.g. '262x / 12x(!)'."""
    parts = []
    for a in (a1, a2):
        depth = a.get(f'{exon}_depth') if a else None
        if a is None or pd.isna(depth):
            parts.append('—')
            continue
        mark = '(!)' if (a.get(f'{exon}_incomp') or 0) > 0 else ''
        parts.append(f"{depth:.0f}x{mark}")
    return ' / '.join(parts)


def _cov_detail(label, a):
    """Per-allele breakdown line, or None if no coverage present."""
    if a is None or (pd.isna(a.get('exon2_depth')) and pd.isna(a.get('exon3_depth'))):
        return None
    def fmt(exon):
        depth = a.get(f'{exon}_depth')
        incomp = a.get(f'{exon}_incomp')
        if pd.isna(depth):
            return 'n/a'
        return f"{depth:.1f}x incomp.{int(incomp) if pd.notna(incomp) else '?'}"
    return f"{label}: exon2 {fmt('exon2')} | exon3 {fmt('exon3')}"


def render_report(
    df: pd.DataFrame,
    sample: str,
    pgroup_file: str,
    outdir: Path,
    template_dir: Path,
    hlahd_version: str = 'v1.7.1',
    pileup: dict | None = None,
) -> Path:
    """Render Jinja2 HTML report for one sample. Returns path to written file."""
    env = Environment(loader=FileSystemLoader(str(template_dir)), autoescape=True)
    template = env.get_template('report.html.j2')

    loci_data = []
    for locus in ['A', 'B', 'C']:
        locus_df = df[df['locus'] == locus]
        if locus_df.empty:
            continue

        def _get(pos, _ldf=locus_df):
            rows = _ldf[_ldf['allele_position'] == pos]
            return rows.iloc[0].to_dict() if not rows.empty else None

        a1 = _get('allele1')
        a2 = _get('allele2')
        a1p2 = _get('allele1_pair2')
        a2p2 = _get('allele2_pair2')

        flags = []
        if a1 and a1['multiple_best_pairs']:
            flags.append('MULTIPLE_BEST_PAIRS')
        if a1 and a1['has_ambiguous_pair']:
            flags.append('AMBIGUOUS_PAIR')
        if (a1 and a1['est_mismatch']) or (a2 and a2['est_mismatch']):
            flags.append('EST_MISMATCH')

        if (a1 and a1.get('incomplete_coverage')) or (a2 and a2.get('incomplete_coverage')):
            flags.append('INCOMPLETE_COVERAGE')

        coverage_detail = [
            line for line in (_cov_detail('Allele 1', a1), _cov_detail('Allele 2', a2))
            if line
        ]

        loci_data.append({
            'locus': locus,
            'allele1': a1['allele'] if a1 else None,
            'p_group1': a1['p_group'] if a1 and pd.notna(a1['p_group']) else '—',
            'allele2': a2['allele'] if a2 else None,
            'p_group2': a2['p_group'] if a2 and pd.notna(a2['p_group']) else '—',
            'flags': flags,
            'ambiguous_alleles': a1['ambiguous_alleles'] if a1 else None,
            'est_mismatch_detail': (
                (a1['est_mismatch_detail'] if a1 and a1['est_mismatch'] else None)
                or (a2['est_mismatch_detail'] if a2 and a2['est_mismatch'] else None)
            ),
            'pair2_allele1': a1p2['allele'] if a1p2 else None,
            'pair2_allele2': a2p2['allele'] if a2p2 else None,
            'exon2_cov': _cov_cell(a1, a2, 'exon2'),
            'exon3_cov': _cov_cell(a1, a2, 'exon3'),
            'coverage_detail': coverage_detail,
        })

    html = template.render(
        sample=sample,
        loci=loci_data,
        pgroup_file=pgroup_file,
        run_date=date.today().isoformat(),
        hlahd_version=hlahd_version,
        pileup=pileup or {},
    )

    out_file = Path(outdir) / f"{sample}_report.html"
    out_file.write_text(html, encoding='utf-8')
    return out_file
