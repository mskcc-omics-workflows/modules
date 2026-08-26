#!/usr/bin/env python3
"""
annotate_hlahd.py — Post-process HLA-HD class I output.

Produces per-sample annotated TSV and self-contained HTML report.

Usage:
    annotate_hlahd.py \
        --result_dir results/SAMPLE1/ \
        --sample SAMPLE1 \
        --pgroup_file /path/to/hla_nom_p.txt \
        --outdir output/

Vendored from mskcc/HLA_HD_workflow's scripts/annotate_hlahd.py + scripts/hlahd_annotate/
for the ANNOTATE_HLAHD module (see modules/msk/annotate_hlahd/resources/usr/bin/).
"""
import argparse
import sys
from pathlib import Path

# hlahd_annotate/ is a sibling of this file (both live in resources/usr/bin/,
# which Nextflow adds to PATH for any process including this module).
sys.path.insert(0, str(Path(__file__).parent))

from hlahd_annotate.annotate import annotate_sample
from hlahd_annotate.report import render_report

TEMPLATE_DIR = Path(__file__).parent / "templates"


def parse_args():
    p = argparse.ArgumentParser(
        description='Annotate HLA-HD class I output with P-groups and quality flags.'
    )
    p.add_argument('--result_dir', required=True, type=Path,
                   help='Directory containing <sample>_final.result.txt and <sample>_{A,B,C}.est.txt')
    p.add_argument('--sample', required=True,
                   help='Sample ID (used as filename prefix for output files)')
    p.add_argument('--pgroup_file', required=True, type=Path,
                   help='IMGT wmda/hla_nom_p.txt P-group reference table')
    p.add_argument('--outdir', required=True, type=Path,
                   help='Output directory for TSV and HTML report (created if absent)')
    p.add_argument('--hlahd_version', default='v1.7.1',
                   help='HLA-HD version string for the report footer (default: v1.7.1)')
    p.add_argument('--skip_html', action='store_true',
                   help='Skip generating the HTML report; write only the annotated TSV')
    return p.parse_args()


def main():
    args = parse_args()
    args.outdir.mkdir(parents=True, exist_ok=True)

    df = annotate_sample(args.result_dir, args.sample, args.pgroup_file)

    tsv_path = args.outdir / f"{args.sample}_annotated.tsv"
    df.to_csv(tsv_path, sep='\t', index=False)
    print(f"TSV written: {tsv_path}")

    if not args.skip_html:
        html_path = render_report(df, args.sample, str(args.pgroup_file), args.outdir, TEMPLATE_DIR,
                                  hlahd_version=args.hlahd_version)
        print(f"HTML written: {html_path}")


if __name__ == '__main__':
    main()
