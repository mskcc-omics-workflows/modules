#!/usr/bin/env Rscript
# ------------------------------------------------------------------------------
# flag_ptd_kdd.R
#
# Flags partial tandem duplications (PTDs), kinase-domain duplications
# (KDDs) and internal tandem duplications (ITDs) in an Arriba fusion table:
#     KMT2A-PTD, EGFR-KDD, MET-KDD, FLT3-ITD, BCOR-ITD, KRAS-ITD, NRAS-ITD,
#     HRAS-ITD, RRAS2-ITD, UBTF-ITD, and KDDs in ALK, ARAF, BRAF, ERBB3, FGFR1, FGFR4,
#     FLT1, FLT3, MAP2K1, NTRK1, NTRK2, PDGFRB, RAF1
#
# By default only confident (non-discarded) calls are evaluated:
#   * a native Arriba fusions.tsv is treated as non-discarded;
#   * a table with a `discarded` column (e.g. fusion_dupes.tsv) is filtered to
#     discarded == FALSE.
# --include_discarded also evaluates discarded rows (and, if given, the rows of
# a separate Arriba fusions.discarded.tsv passed via --discarded).
#
# Efficiency: rows are filtered to same-gene target events (gene1 == gene2,
# gene in --genes) up front, vectorized, and only those go through the
# per-row breakpoint evaluation. A --discarded file is pre-filtered with awk
# before R parses it, so only its same-gene target rows reach the output.
#
# PTD/KDD heuristic (all must hold for a call):
#   1. intragenic: gene1 == gene2, and the gene is in --genes
#   2. Arriba type contains "duplication"
#   3. both breakpoints map to the same Ensembl canonical transcript
#   4. back-splice orientation: the junction joins a downstream (donor-side)
#      position back to an upstream (acceptor-side) position in transcript
#      order, spanning >= 2 exons (excludes small ITD-like events)
#   5. the duplicated exon block [first exon .. last exon] falls in the
#      allowed range for that gene (gene_rules.tsv)
#
# KDD ranges for the genes after EGFR and MET in gene_rules.tsv are derived, not curated:
#   the UniProt kinase domain is located in the canonical protein by sequence
#   match and mapped to exons through the GTF CDS. With ks/ke the exons holding
#   the domain's first/last residue:
#     start_allowed = 1 .. ks      (+ ks+1 if <= 10 domain residues are in ks)
#     end_allowed   = ke .. last   (+ ke-1 if <= 10 domain residues are in ke)
#     start_canon   = ks-2 .. ks   (published KDDs often start just upstream)
#     end_canon     = ke .. ke+1
#   Published ranges these cover: BRAF 10-18, FGFR1 10-18 and 8-18, FLT3 6-23.
#   The others have no exon-level report behind them.
# When the domain ends in the last exon (ALK, ARAF, BRAF, FGFR1, FGFR4, MAP2K1,
# NTRK1, NTRK2, RAF1, MET), the donor-side breakpoint falls inside that exon,
# which has no splice donor. Any position in the last exon therefore counts as
# donor_site_ok (see the splice region below), so these calls can be canonical.
# Likewise exon 1 has no splice acceptor, so any acceptor-side position in
# exon 1 counts as acceptor_site_ok, and blocks starting there (e.g. MAP2K1
# e1-e11) can be canonical.
# A donor-side breakpoint past the transcript end is not called.
#
# Breakpoints are converted to the duplicated exon block strand-aware:
#   acceptor side (block start): exon k -> k;  intron k -> k + 1
#   donor side    (block end)  : exon k -> k;  intron k -> k
#
# Each call gets a tier:
#   canonical         exons in the canonical range AND both breakpoints sit in
#                     a splice region, following VEP's splicing consequence
#                     terms (splice_region / splice_donor / splice_donor_region
#                     / splice_acceptor / splice_polypyrimidine_tract):
#                       donor side    = last 1-3 bases of the exon, or the
#                                       first 1-8 bases of the following intron,
#                                       or anywhere in the transcript's last exon
#                       acceptor side = first 1-3 bases of the exon, or the
#                                       last 1-17 bases of the preceding intron,
#                                       or anywhere in the transcript's first exon
#                     (sizes set by --splice_exon_bp, --splice_donor_intron_bp,
#                      --splice_acceptor_intron_bp)
#   atypical_exons    allowed but non-canonical exon range
#   non_splice_site   one or both breakpoints are not on the expected splice
#                     site (e.g. intronic/genomic breakpoint, discordant-only)
#   (atypical_exons;non_splice_site if both apply)
#
# ITD heuristic (FLT3, BCOR, KRAS, NRAS, HRAS, RRAS2, UBTF; all must hold for a call):
#   1. intragenic: gene1 == gene2, and the gene is in --genes
#   2. Arriba type contains "ITD" (e.g. "duplication/ITD")
#   3. both breakpoints map to the gene's canonical transcript
#   4. event size |pos1 - pos2| <= --itd_max_size bp (default 500)
#   5. the duplicated segment lies within a single allowed exon
#      (itd_exons in gene_rules.tsv): FLT3 e14, BCOR e15, KRAS/NRAS/HRAS e2 or e3,
#      RRAS2 e1 or e3, UBTF e9 or e13.
#      So FLT3 needs dup_exons == "e14-e14", and RAS needs "e2-e2" or "e3-e3"
#      ("e2-e3" is not called). Using the same breakpoint-to-exon conversion as
#      PTDs/KDDs, a donor-side breakpoint in intron 14 or an acceptor-side
#      breakpoint in intron 13 still counts as exon 14 (junctions i14>e14,
#      e14>i13), since the duplicated sequence itself is exon 14.
#   6. the duplicated segment [min(pos1, pos2), max(pos1, pos2)] overlaps the
#      canonical transcript's CDS by at least 1 bp, so an ITD lying entirely in
#      a UTR (e.g. the 5' UTR of RRAS2 e1, the 3' UTR of BCOR e15) is not called.
# Breakpoint locations are reported in dup_exons / junction / *_site_ok
# exactly as for PTDs and KDDs. ITD calls get tier "itd".
#
# RAS ITDs occur in the P-loop or switch II domains. The Ensembl GTF has no
# protein-domain annotation, so the exons holding them stand in for them: a
# call in those exons may lie outside the domain itself.
#   KRAS/NRAS/HRAS: P-loop in exon 2, switch II in exon 3.
#   RRAS2: P-loop in exon 1 (codons 21-28), switch II in exon 3 (codons 71-87).
#     RRAS2 has an 11-residue N-terminal extension and a coding exon 1, so its
#     exon 2 (codons 37-66) holds neither domain.
#
# Arriba only types an event as ITD up to its -l MAX_ITD_LENGTH (default 100
# bp), so longer ITDs are missed here unless Arriba ran with a larger -l.
#
# Exon numbers refer to the Ensembl canonical transcripts in GRCh38.111:
#   KMT2A ENST00000534358 (36 exons), EGFR ENST00000275493 (28 exons),
#   MET ENST00000397752 (21 exons; exon 14 = the 141 bp METex14),
#   FLT3 ENST00000241453 (24 exons; minus strand; ITD and KDD rules: type
#   containing "ITD" goes to the ITD rule, other duplications to the KDD rule),
#   BCOR ENST00000378444 (15 exons; minus strand; exon 15 is the last exon),
#   KRAS ENST00000311936 (5 exons), NRAS ENST00000369535 (7 exons),
#   HRAS ENST00000311189 (6 exons); all minus strand, exon 1 non-coding.
#   RRAS2 ENST00000256196 (6 exons; minus strand; exon 1 is coding),
#   UBTF ENST00000436088 (21 exons; minus strand; exon 9 = 134 bp, exon 13 = 156 bp),
#   ALK ENST00000389048 (29), ARAF ENST00000377045 (16), BRAF ENST00000646891
#   (18), ERBB3 ENST00000267101 (28), FGFR1 ENST00000447712 (18), FGFR4
#   ENST00000292408 (18), FLT1 ENST00000282397 (30), MAP2K1 ENST00000307102
#   (11), NTRK1 ENST00000524377 (17), NTRK2 ENST00000277120 (19), PDGFRB
#   ENST00000261799 (23), RAF1 ENST00000251849 (17).
#
# Usage:
#   Rscript flag_ptd_kdd.R \
#       --input  sample.fusions.tsv \
#       --gtf    Homo_sapiens.GRCh38.111.gtf \
#       --output sample.ptd_kdd.tsv \
#       [--rules gene_rules.tsv] [--genes KMT2A,EGFR (default: all in rules)] [--itd_max_size 500] \
#       [--splice_exon_bp 3] [--splice_donor_intron_bp 8] [--splice_acceptor_intron_bp 17] \
#       [--flagged_only] [--include_discarded] [--discarded sample.fusions.discarded.tsv]
#   Rscript flag_ptd_kdd.R --version    # print the version and exit
#
# Output: the input table plus columns
#   ptd_kdd_call      KMT2A-PTD, <gene>-KDD or <gene>-ITD (see top), or NA
#   ptd_kdd_tier      see above (NA if not called)
#   dup_exons         duplicated exon block, e.g. "e2-e10"
#   n_dup_exons       number of exons in the block
#   junction          e.g. "e10>e2" (donor exon > acceptor exon)
#   event_size        |pos1 - pos2| in bp
#   donor_site_ok / acceptor_site_ok   breakpoint in the donor / acceptor
#                     splice region defined above (a donor-side breakpoint
#                     in the last exon is always donor_site_ok, and an
#                     acceptor-side breakpoint in exon 1 is always
#                     acceptor_site_ok)
#   total_support     split_reads1 + split_reads2 + discordant_mates
#   ptd_kdd_note      why an intragenic duplication in a target gene was or
#                     wasn't called (NA for unrelated rows)
#   evaluated         FALSE for rows skipped (discarded, when not included)
# A second file <output>.flagged.tsv holds only the called rows.
#
# Requires: data.table, and gene_rules.tsv beside this script (or --rules).
# Reading the GTF uses awk (and gzip -cd for .gtf.gz).
# Version: VERSION below; --version prints it and exits.
# ------------------------------------------------------------------------------

VERSION <- "0.1.2"
# Checked before anything else so it works without other arguments,
# a rules file or data.table.
if ("--version" %in% commandArgs(trailingOnly = TRUE)) {
  cat(sprintf("flag_ptd_kdd_itd_arriba.R %s\n", VERSION))
  quit(save = "no", status = 0)
}

suppressPackageStartupMessages(library(data.table))

# ---- per-gene rules (gene_rules.tsv) -----------------------------------------
# Shared with whippet_ptd_kdd_scan.py. One row per rule; exon sets look like
# "18", "14-18" or "9,13", and "." means the column doesn't apply to that kind.
# PTD/KDD rules (kind = "exon_block"):
#   start_* = first duplicated exon (acceptor side of the junction)
#   end_*   = last duplicated exon (donor side of the junction)
# ITD rules (kind = "itd"): type must contain "ITD", size <= --itd_max_size,
# duplicated segment within a single exon of itd_exons and overlapping the CDS.
# A gene with both (FLT3) has an exon_block rule plus an `itd` sub-rule.
parse_exon_set <- function(x) {
  if (is.na(x) || !grepl("^[0-9]+(-[0-9]+)?(,[0-9]+(-[0-9]+)?)*$", x)) return(NULL)
  out <- integer(0)
  for (tok in strsplit(x, ",", fixed = TRUE)[[1]]) {
    b <- suppressWarnings(as.integer(strsplit(tok, "-", fixed = TRUE)[[1]]))
    if (anyNA(b)) return(NULL)
    if (length(b) == 2 && b[1] > b[2]) return(NULL)
    out <- c(out, if (length(b) == 2) b[1]:b[2] else b)
  }
  out
}

load_rules <- function(path) {
  bad <- function(...) stop("rules file ", path, ": ", ..., call. = FALSE)
  if (!file.exists(path)) bad("not found (use --rules)")
  d <- tryCatch(fread(path, sep = "\t", header = TRUE, quote = "",
                      colClasses = "character"),
                error   = function(e) bad(conditionMessage(e)),
                warning = function(w) bad(conditionMessage(w)))
  set_cols <- c("start_allowed", "end_allowed", "start_canon", "end_canon", "itd_exons")
  kinds <- list(exon_block = set_cols[1:4], itd = "itd_exons")
  missing <- setdiff(c("gene", "call", "kind", set_cols), names(d))
  if (length(missing) > 0) bad("missing column(s) ", paste(missing, collapse = ", "))
  if (nrow(d) == 0) bad("no rules")

  blocks <- list(); itds <- list()
  for (i in seq_len(nrow(d))) {
    row <- as.list(d[i])
    where <- sprintf("line %d (%s): ", i + 1L, row$gene)
    if (is.na(row$gene) || !nzchar(row$gene) || is.na(row$call) || !nzchar(row$call)) {
      bad(where, "gene and call must not be empty")
    }
    if (!row$kind %in% names(kinds)) bad(where, "unknown kind '", row$kind, "'")
    need <- kinds[[row$kind]]
    for (col in setdiff(set_cols, need)) {
      if (!identical(row[[col]], ".")) bad(where, col, " must be '.' for kind ", row$kind)
    }
    sets <- list()
    for (col in need) {
      sets[[col]] <- parse_exon_set(row[[col]])
      if (is.null(sets[[col]])) bad(where, "bad exon set '", row[[col]], "' in ", col)
    }
    if (row$kind == "exon_block") {
      if (!is.null(blocks[[row$gene]])) bad(where, "second exon_block rule for this gene")
      blocks[[row$gene]] <- c(list(call = row$call, kind = "exon_block"), sets)
    } else {
      if (!is.null(itds[[row$gene]])) bad(where, "second itd rule for this gene")
      itds[[row$gene]] <- c(list(call = row$call), sets)
    }
  }

  rules <- list()
  for (g in unique(d$gene)) {
    r <- blocks[[g]]
    if (is.null(r)) {
      r <- c(list(call = itds[[g]]$call, kind = "itd"), itds[[g]]["itd_exons"])
    } else if (!is.null(itds[[g]])) {
      r$itd <- itds[[g]]
    }
    rules[[g]] <- r
  }
  rules
}

# ---- arguments ---------------------------------------------------------------
script_file <- gsub("~+~", " ", sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)), fixed = TRUE)
script_dir  <- if (length(script_file) > 0) dirname(normalizePath(script_file[1])) else getwd()

defaults <- list(
  input             = NA_character_,
  gtf               = NA_character_,
  output            = NA_character_,
  rules             = file.path(script_dir, "gene_rules.tsv"),
  genes             = NA_character_,        # default: every gene in the rules file
  splice_exon_bp            = 3,
  splice_donor_intron_bp    = 8,
  splice_acceptor_intron_bp = 17,
  itd_max_size      = 500,
  discarded         = NA_character_,
  include_discarded = "FALSE",
  flagged_only      = "FALSE"
)
flags <- c("include_discarded", "flagged_only")

parse_args <- function(args, opts) {
  i <- 1
  while (i <= length(args)) {
    key <- sub("^--", "", args[i])
    if (key %in% flags) {
      opts[[key]] <- "TRUE"; i <- i + 1
    } else if (grepl("=", key)) {
      kv <- strsplit(key, "=", fixed = TRUE)[[1]]
      if (!kv[1] %in% names(opts)) stop("Unknown argument: ", args[i])
      opts[[kv[1]]] <- paste(kv[-1], collapse = "="); i <- i + 1
    } else {
      if (!key %in% names(opts)) stop("Unknown argument: ", args[i])
      opts[[key]] <- args[i + 1]; i <- i + 2
    }
  }
  opts
}
opts <- parse_args(commandArgs(trailingOnly = TRUE), defaults)
RULES <- load_rules(opts$rules)
if (is.na(opts$genes)) opts$genes <- paste(names(RULES), collapse = ",")
for (k in c("splice_exon_bp", "splice_donor_intron_bp", "splice_acceptor_intron_bp")) {
  opts[[k]] <- suppressWarnings(as.integer(opts[[k]]))
  if (is.na(opts[[k]]) || opts[[k]] < 0) stop("--", k, " must be a whole number >= 0")
}
opts$itd_max_size      <- as.integer(opts$itd_max_size)
if (is.na(opts$itd_max_size) || opts$itd_max_size < 1) {
  stop("--itd_max_size must be a positive whole number of bp")
}
opts$include_discarded <- as.logical(opts$include_discarded)
opts$flagged_only      <- as.logical(opts$flagged_only)
opts$genes             <- toupper(trimws(strsplit(opts$genes, ",")[[1]]))
if (is.na(opts$input)) stop("--input is required")
if (is.na(opts$gtf)) stop("--gtf is required")
if (is.na(opts$output)) {
  opts$output <- sub("(\\.tsv|\\.txt)?$", ".ptd_kdd.tsv", opts$input)
}
stopifnot(file.exists(opts$input), file.exists(opts$gtf))
missing_rules <- setdiff(opts$genes, names(RULES))
if (length(missing_rules) > 0) {
  stop("No PTD/KDD rule defined for: ", paste(missing_rules, collapse = ", "),
       " (add one to gene_rules.tsv)")
}

norm_chr <- function(x) {
  x <- sub("^chr", "", as.character(x), ignore.case = TRUE)
  x[x == "M"] <- "MT"
  x
}

# ---- read Arriba table(s) ----------------------------------------------------
# Accepts native Arriba output (#gene1 ... breakpoint1 "chr:pos") or the
# reformatted chr1/pos1/chr2/pos2 tables.
# same_gene_only = TRUE pre-filters the file with awk BEFORE R parses it,
# keeping only the header plus rows where gene1 == gene2 and that gene is in
# --genes. Used for the (large) Arriba discarded file, so R never parses the
# thousands of irrelevant rows or their long read_identifiers fields.
read_arriba <- function(path, discarded_default, same_gene_only = FALSE) {
  if (same_gene_only) {
    # Header via base R (gzfile reads plain and gzipped files), so a .gz file
    # does not need R.utils, which fread() requires to read .gz directly.
    hdr <- sub("^#", "", strsplit(readLines(gzfile(path), n = 1), "\t",
                                  fixed = TRUE)[[1]])
    c1 <- match("gene1", hdr); c2 <- match("gene2", hdr)
    if (is.na(c1) || is.na(c2)) stop(path, " is missing gene1/gene2 columns")
    awk <- sprintf(paste0(
      "awk -F'\\t' -v genes=%s -v c1=%d -v c2=%d ",
      "'BEGIN{n=split(genes,a,\",\"); for(i=1;i<=n;i++) T[a[i]]=1} ",
      "NR==1{print; next} ",
      "{g1=toupper($c1); g2=toupper($c2); sub(/\\(.*$/,\"\",g1); sub(/\\(.*$/,\"\",g2); ",
      "if (g1==g2 && (g1 in T)) print}'"),
      shQuote(paste(opts$genes, collapse = ",")), c1, c2)
    cmd <- if (grepl("\\.gz$", path)) {
      sprintf("gzip -cd %s | %s", shQuote(path), awk)
    } else {
      sprintf("%s %s", awk, shQuote(path))
    }
    d <- fread(cmd = cmd, sep = "\t", header = TRUE, quote = "")
  } else {
    d <- fread(path, sep = "\t", header = TRUE, quote = "")
  }
  setnames(d, sub("^#", "", names(d)))
  if (!all(c("chr1", "pos1") %in% names(d)) && "breakpoint1" %in% names(d)) {
    split_bp <- function(x) {
      x <- as.character(x)
      list(norm_chr(sub(":[^:]*$", "", x)),
           suppressWarnings(as.integer(sub("^.*:", "", x))))
    }
    d[, c("chr1", "pos1") := split_bp(breakpoint1)]
    d[, c("chr2", "pos2") := split_bp(breakpoint2)]
  }
  for (col in c("gene1", "gene2", "chr1", "pos1", "chr2", "pos2", "type")) {
    if (!col %in% names(d)) stop(path, " is missing column: ", col)
  }
  if ("discarded" %in% names(d)) {
    d[, discarded := toupper(as.character(discarded)) %in% c("TRUE", "T", "1")]
  } else {
    d[, discarded := discarded_default]
  }
  d
}

fus <- read_arriba(opts$input, FALSE)
if (!is.na(opts$discarded)) {
  if (!opts$include_discarded) {
    message("--discarded given without --include_discarded; ignoring it.")
  } else {
    stopifnot(file.exists(opts$discarded))
    disc <- read_arriba(opts$discarded, TRUE, same_gene_only = TRUE)
    message(sprintf("Kept %d same-gene target rows from %s", nrow(disc),
                    opts$discarded))
    fus <- rbind(fus, disc, fill = TRUE)
  }
}
fus[, evaluated := opts$include_discarded | !discarded]

# ---- same-gene pre-filter (vectorized) ---------------------------------------
# Only rows where gene1 == gene2 and the gene is a target go through the
# per-row breakpoint evaluation below; every other row gets NA annotations
# without any further work.
strip_vec <- function(g) toupper(trimws(sub("\\(.*$", "", as.character(g))))
fus[, `.g1` := strip_vec(gene1)]
fus[, `.g2` := strip_vec(gene2)]
fus[, `.same_target` := `.g1` == `.g2` & `.g1` %in% opts$genes]
cand <- which(fus$`.same_target` & fus$evaluated)
message(sprintf("%d of %d rows are same-gene %s events to evaluate.",
                length(cand), nrow(fus), paste(opts$genes, collapse = "/")))

# ---- canonical exons for the target genes only -------------------------------
message("Reading canonical exons for ", paste(opts$genes, collapse = ", "),
        " from ", opts$gtf, " ...")
gene_re  <- paste(opts$genes, collapse = "|")
awk_prog <- sprintf("'($3 == \"exon\" || $3 == \"CDS\") && /Ensembl_canonical/ && /gene_name \"(%s)\";/'",
                    gene_re)
reader <- if (grepl("\\.gz$", opts$gtf)) {
  sprintf("gzip -cd %s | awk -F'\\t' %s", shQuote(opts$gtf), awk_prog)
} else {
  sprintf("awk -F'\\t' %s %s", awk_prog, shQuote(opts$gtf))
}
gtf <- fread(cmd = reader, sep = "\t", header = FALSE, quote = "",
             col.names = c("chr", "source", "feature", "start", "end",
                           "score", "strand", "frame", "attr"))
if (nrow(gtf) == 0) stop("No canonical exons found for the target genes.")

get_attr <- function(attr, key) {
  out <- rep(NA_character_, length(attr))
  hit <- grepl(paste0(key, ' "'), attr)
  out[hit] <- sub(paste0('.*', key, ' "([^"]*)".*'), "\\1", attr[hit])
  out
}
cds <- gtf[feature == "CDS", .(start, end,
                               transcript_id = get_attr(attr, "transcript_id"))]
setorder(cds, transcript_id, start)
cds_list <- split(cds[, .(start, end)], cds$transcript_id)
exons <- gtf[feature == "exon", .(chr = norm_chr(chr), start, end, strand,
                 gene_name     = get_attr(attr, "gene_name"),
                 transcript_id = get_attr(attr, "transcript_id"),
                 exon_number   = as.integer(get_attr(attr, "exon_number")))]
rm(gtf)
setorder(exons, transcript_id, exon_number)
tx <- exons[, .(chr = chr[1], strand = strand[1], gene_name = gene_name[1],
                tx_start = min(start), tx_end = max(end), n_exons = .N),
            by = transcript_id]
exon_list <- split(exons[, .(start, end, exon_number)], exons$transcript_id)
message(sprintf("Canonical transcripts: %s",
                paste(sprintf("%s=%s(%d exons)", tx$gene_name, tx$transcript_id,
                              tx$n_exons), collapse = ", ")))

# ---- locate breakpoints in the canonical transcript (vectorized) ------------
# For a vector of positions in ONE transcript, returns region
# (exon/intron/outside), exon/intron number, and whether each position lies in
# the donor or acceptor splice region (VEP-style, see header):
#   exon k   : donor region   = last  splice_exon_bp bases (k < last exon);
#                                the whole exon when k is the last exon
#              acceptor region = first splice_exon_bp bases (k > 1);
#                                the whole exon when k is exon 1
#   intron k : donor region   = first splice_donor_intron_bp bases
#              acceptor region = last  splice_acceptor_intron_bp bases
# Distances are 0 on the boundary base itself, so "1-3 bases" = distance 0-2.
locate_vec <- function(pos, t, ex) {
  n   <- nrow(ex)
  pl  <- t$strand == "+"
  g   <- ex[order(start)]                       # exons in genomic order
  m   <- length(pos)
  region <- rep("outside", m); number <- rep(NA_integer_, m)
  in_donor <- in_acceptor <- rep(FALSE, m)
  inside <- !is.na(pos) & pos >= t$tx_start & pos <= t$tx_end
  idx    <- findInterval(pos, g$start)          # last exon starting <= pos
  idx1   <- pmax(idx, 1L)
  in_ex  <- inside & idx > 0 & pos <= g$end[idx1]
  in_in  <- inside & !in_ex

  if (any(in_ex)) {
    i <- idx1[in_ex]; p <- pos[in_ex]
    k <- g$exon_number[i]; s <- g$start[i]; e <- g$end[i]
    d5 <- if (pl) p - s else e - p             # bases from exon 5' end
    d3 <- if (pl) e - p else p - s             # bases from exon 3' end
    region[in_ex] <- "exon"; number[in_ex] <- as.integer(k)
    in_donor[in_ex]    <- k == n | d3 < opts$splice_exon_bp
    in_acceptor[in_ex] <- k == 1 | d5 < opts$splice_exon_bp
  }
  if (any(in_in)) {                             # intron k: exon k .. exon k+1
    i <- idx1[in_in]; p <- pos[in_in]
    k <- if (pl) g$exon_number[i] else g$exon_number[i + 1L]
    s <- g$end[i] + 1L; e <- g$start[i + 1L] - 1L
    d5 <- if (pl) p - s else e - p             # bases from intron 5' end (donor)
    d3 <- if (pl) e - p else p - s             # bases from intron 3' end (acceptor)
    region[in_in] <- "intron"; number[in_in] <- as.integer(k)
    in_donor[in_in]    <- d5 < opts$splice_donor_intron_bp
    in_acceptor[in_in] <- d3 < opts$splice_acceptor_intron_bp
  }
  list(region = region, number = number,
       in_donor = in_donor, in_acceptor = in_acceptor)
}

# ---- evaluate candidate rows (vectorized) ------------------------------------
# Called only for pre-filtered rows: same gene on both sides, a target gene,
# and evaluated (non-discarded unless --include_discarded).
empty_res <- function(note = NA_character_) {
  list(ptd_kdd_call = NA_character_, ptd_kdd_tier = NA_character_,
       dup_exons = NA_character_, n_dup_exons = NA_integer_,
       event_size = NA_integer_,
       junction = NA_character_, donor_site_ok = NA, acceptor_site_ok = NA,
       ptd_kdd_note = note)
}

evaluate_batch <- function(gene, c1, p1, c2, p2, type) {
  n    <- length(gene)
  out  <- as.data.table(empty_res())[rep(1L, n)]
  open <- rep(TRUE, n)                     # still being evaluated
  close_with <- function(rows, note) {
    if (any(rows)) set(out, i = which(rows), j = "ptd_kdd_note", value = note)
    open[rows] <<- FALSE
  }

  isdup <- grepl("duplication", type, fixed = TRUE)
  close_with(open & !isdup,
             sprintf("intragenic %s but type '%s' is not a duplication",
                     gene, type)[open & !isdup])
  ti <- match(gene, tx$gene_name)
  close_with(open & is.na(ti), "no canonical transcript")
  badchr <- open & (norm_chr(c1) != tx$chr[ti] | norm_chr(c2) != tx$chr[ti])
  close_with(badchr %in% TRUE, "breakpoint on a different chromosome than the gene")

  # transcript-order coordinate: donor side = further downstream
  pl <- tx$strand[ti] == "+"
  o1 <- ifelse(pl, p1, -p1); o2 <- ifelse(pl, p2, -p2)
  close_with(open & (o1 == o2) %in% TRUE, "breakpoints identical")
  dpos <- ifelse(o1 > o2, p1, p2)          # donor side (end of duplicated block)
  apos <- ifelse(o1 > o2, p2, p1)          # acceptor side (start of block)

  dreg <- areg <- rep("outside", n); dnum <- anum <- rep(NA_integer_, n)
  d_don <- a_acc <- rep(FALSE, n)
  for (gn in unique(gene[open])) {
    rows <- which(open & gene == gn)
    t  <- tx[gene_name == gn][1]
    ex <- exon_list[[t$transcript_id]]
    d  <- locate_vec(dpos[rows], t, ex)
    a  <- locate_vec(apos[rows], t, ex)
    dreg[rows] <- d$region; dnum[rows] <- d$number; d_don[rows] <- d$in_donor
    areg[rows] <- a$region; anum[rows] <- a$number; a_acc[rows] <- a$in_acceptor
  }
  close_with(open & (dreg == "outside" | areg == "outside"),
             "a breakpoint lies outside the canonical transcript")

  w <- which(open)
  if (length(w) == 0) return(out)
  end_exon   <- dnum                                     # exon k or intron k -> k
  start_exon <- ifelse(areg == "intron", anum + 1L, anum)
  n_dup      <- as.integer(end_exon - start_exon + 1L)
  dup_exons  <- sprintf("e%d-e%d", start_exon, end_exon)
  junction   <- sprintf("%s%d>%s%d", ifelse(dreg == "exon", "e", "i"), dnum,
                        ifelse(areg == "exon", "e", "i"), anum)
  donor_ok   <- d_don                         # donor side in donor splice region
  accept_ok  <- a_acc                         # acceptor side in acceptor region
  set(out, i = w, j = "dup_exons",        value = dup_exons[w])
  set(out, i = w, j = "n_dup_exons",      value = n_dup[w])
  size <- as.integer(abs(p1 - p2))
  set(out, i = w, j = "event_size",       value = size[w])

  # ITD rows: type contains "ITD" and size <= --itd_max_size; breakpoint
  # locations are reported above but not required. A gene with both rules
  # (FLT3) sends only ITD-typed rows here; its others use the exon-block rule.
  itd_rule <- function(g) {
    r <- RULES[[g]]
    if (identical(r$kind, "itd")) r else r$itd
  }
  itd_only <- vapply(gene, function(g) identical(RULES[[g]]$kind, "itd"),
                     logical(1), USE.NAMES = FALSE)
  has_itd  <- vapply(gene, function(g) !is.null(itd_rule(g)),
                     logical(1), USE.NAMES = FALSE)
  is_itd_gene <- itd_only | (has_itd & grepl("ITD", type, fixed = TRUE))
  itd_open <- open & is_itd_gene
  not_itd  <- itd_open & !grepl("ITD", type, fixed = TRUE)
  close_with(not_itd, sprintf("intragenic %s duplication but type '%s' is not an ITD",
                              gene, type)[not_itd])
  too_big <- open & is_itd_gene & size > opts$itd_max_size
  close_with(too_big, sprintf("ITD size %d bp exceeds --itd_max_size %d",
                              size, opts$itd_max_size)[too_big])
  for (gn in unique(gene[open & is_itd_gene])) {
    ok_ex <- itd_rule(gn)$itd_exons
    if (is.null(ok_ex)) next
    wrong <- open & is_itd_gene & gene == gn &
             !(start_exon == end_exon & start_exon %in% ok_ex)
    close_with(wrong, sprintf("%s outside %s exon(s) %s",
                              dup_exons, itd_rule(gn)$call,
                              paste(ok_ex, collapse = ","))[wrong])
  }
  for (gn in unique(gene[open & is_itd_gene])) {
    rows <- which(open & is_itd_gene & gene == gn)
    cd   <- cds_list[[tx[gene_name == gn]$transcript_id[1]]]
    lo   <- pmin(p1[rows], p2[rows]); hi <- pmax(p1[rows], p2[rows])
    coding <- rep(FALSE, length(rows))
    if (!is.null(cd)) {                     # first CDS block ending at or after lo
      nxt    <- findInterval(lo, cd$end, left.open = TRUE) + 1L
      coding <- nxt <= nrow(cd) & cd$start[pmin(nxt, nrow(cd))] <= hi
    }
    noncoding <- rep(FALSE, n); noncoding[rows[!coding]] <- TRUE
    close_with(noncoding, sprintf("%s %s does not overlap the CDS (UTR only)",
                                  dup_exons, itd_rule(gn)$call)[noncoding])
  }
  hit <- which(open & is_itd_gene)
  if (length(hit) > 0) {
    calls <- vapply(gene[hit], function(g) itd_rule(g)$call, character(1),
                    USE.NAMES = FALSE)
    set(out, i = hit, j = "ptd_kdd_call", value = calls)
    set(out, i = hit, j = "ptd_kdd_tier", value = "itd")
    set(out, i = hit, j = "ptd_kdd_note",
        value = sprintf("%s %d bp (junction %s)", calls, size[hit], junction[hit]))
    open[hit] <- FALSE
  }

  set(out, i = w, j = "junction",         value = junction[w])
  set(out, i = w, j = "donor_site_ok",    value = donor_ok[w])
  set(out, i = w, j = "acceptor_site_ok", value = accept_ok[w])
  close_with(open & n_dup < 2, "duplication spans < 2 exons (ITD-like), not called")

  for (gn in unique(gene[open])) {        # remaining rows: exon-block rules
    r    <- RULES[[gn]]
    rows <- open & gene == gn
    inr  <- start_exon %in% r$start_allowed & end_exon %in% r$end_allowed
    out_rows <- rows & !inr
    close_with(out_rows, sprintf(
      "%s outside %s range (start e%s, end e%s)", dup_exons[out_rows], r$call,
      paste(range(r$start_allowed), collapse = "-"),
      paste(range(r$end_allowed), collapse = "-")))
    hit <- which(rows & inr)
    if (length(hit) == 0) next
    canon  <- start_exon[hit] %in% r$start_canon & end_exon[hit] %in% r$end_canon
    splice <- donor_ok[hit] & accept_ok[hit]
    tier <- ifelse(canon & splice, "canonical",
            ifelse(!canon & !splice, "atypical_exons;non_splice_site",
            ifelse(!canon, "atypical_exons", "non_splice_site")))
    set(out, i = hit, j = "ptd_kdd_call", value = r$call)
    set(out, i = hit, j = "ptd_kdd_tier", value = tier)
    set(out, i = hit, j = "ptd_kdd_note",
        value = sprintf("%s %s (junction %s)", r$call, dup_exons[hit], junction[hit]))
  }
  out
}

# ---- run ---------------------------------------------------------------------
message(sprintf("Evaluating %d candidate rows (%s) ...", length(cand),
                if (opts$include_discarded) "including discarded"
                else "non-discarded only"))
# start with NA annotations for every row, then fill in only the candidates
ann <- as.data.table(empty_res())[rep(1L, nrow(fus))]
ann[fus$`.same_target` & !fus$evaluated, ptd_kdd_note := "discarded; not evaluated"]
if (length(cand) > 0) {
  vals <- evaluate_batch(fus$`.g1`[cand], fus$chr1[cand], fus$pos1[cand],
                         fus$chr2[cand], fus$pos2[cand], fus$type[cand])
  for (col in names(vals)) set(ann, i = cand, j = col, value = vals[[col]])
}
fus[, c(".g1", ".g2", ".same_target") := NULL]
res <- cbind(fus, ann)

num <- function(col) {
  if (!col %in% names(res)) return(rep(0L, nrow(res)))
  v <- suppressWarnings(as.integer(res[[col]])); v[is.na(v)] <- 0L; v
}
res[, total_support := num("split_reads1") + num("split_reads2") +
                       num("discordant_mates")]
setcolorder(res, c(setdiff(names(res), c(names(ann), "total_support", "evaluated")),
                   "ptd_kdd_call", "ptd_kdd_tier", "dup_exons", "n_dup_exons", "event_size",
                   "junction", "donor_site_ok", "acceptor_site_ok",
                   "total_support", "ptd_kdd_note", "evaluated"))

flagged <- res[!is.na(ptd_kdd_call)]
out <- if (opts$flagged_only) flagged else res
fwrite(out, opts$output, sep = "\t", quote = FALSE, na = "NA")
flagged_path <- sub("(\\.tsv|\\.txt)?$", ".flagged.tsv", opts$output)
fwrite(flagged, flagged_path, sep = "\t", quote = FALSE, na = "NA")

if (nrow(flagged) > 0) {
  message("Calls:")
  summ <- flagged[, .N, by = .(ptd_kdd_call, ptd_kdd_tier, dup_exons)]
  setorder(summ, ptd_kdd_call, ptd_kdd_tier, dup_exons)
  for (i in seq_len(nrow(summ))) {
    message(sprintf("  %-10s %-30s %-8s n=%d", summ$ptd_kdd_call[i],
                    summ$ptd_kdd_tier[i], summ$dup_exons[i], summ$N[i]))
  }
} else {
  message("No PTD/KDD calls.")
}
message("Wrote ", opts$output, " and ", flagged_path)
