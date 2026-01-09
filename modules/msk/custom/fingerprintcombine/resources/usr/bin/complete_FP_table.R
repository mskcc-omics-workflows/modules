#! /usr/bin/env Rscript

#-------------------------------------------------------------------------------
# Script: complete_FP_table.R
# Author: Erika Gedvilaite
# Date:   2025-09-23
# Version: 0.1.0
#
# Description: This script takes in standard fingerprint tables and combines
# them into a single, wide table for downstream plotting and analysis.
#
# Annotation:
#   - Input table should have three columns: sample_id, genome_build, fp_tsv
#   - Genome build should be either "hg19" or "hg38" or "GRCh37" or "GRCh38"
#     (case insensitive)
#
#-------------------------------------------------------------------------------


rm(list=ls())

library(argparse, quietly = T)
library(plyr, quietly = T)
library(dplyr, quietly = T)
library(data.table, quietly = T)
library(tidyverse, quietly = T)

`%notin%` <- Negate(`%in%`)
`%notlike%` <- Negate(`%like%`)

parser = ArgumentParser(description = 'Generate FP tables for plotting')
parser$add_argument('-i', '--input_table', required = TRUE,
                    help = 'Input table with paths to individual fingerprint TSV files, sample ids, and genome build')
parser$add_argument('-o', '--analysis_folder', required = FALSE, default = ".",
                    help = 'Output folder')
parser$add_argument('-l', '--loci_mapper', required = TRUE,
                    help = 'Loci mapper file')
parser$add_argument('-d', '--depth_filter', required = FALSE, default = 20,
                    help = 'Depth filter to apply to individual fingerprint TSV files (default: 20)')
args = parser$parse_args()



message("Reading in Liftover file")

hg19_hg38_mapper = fread(args$loci_mapper,header = T)
hg19_hg38_mapper$Loci_hg19 = paste(hg19_hg38_mapper$GRCH37_CHROM,hg19_hg38_mapper$GRCH37_POS,sep=":")
hg19_hg38_mapper$Loci_hg38 = paste(hg19_hg38_mapper$GRCH38_CHROM,hg19_hg38_mapper$GRCH38_POS,sep=":")
hg19_hg38_mapper = hg19_hg38_mapper %>% select(Loci_hg19, Loci_hg38) %>% unique()

message("Loading Samples")
input_table = fread(args$input_table, header = T) %>% arrange(group, sample_id)
for (i in 1:nrow(input_table)){
  sample = input_table$sample_id[i]
  genome_build = input_table$genome_build[i]
  print(genome_build)
  if (tolower(genome_build) %notin% c("hg19","grch37","hg38","grch38")){
    stop(paste0("Genome build not recognized: ", genome_build, ". Must be in the following list: hg19, hg38, grch37, grch38 (case will be ignored)."))
  }
  file = input_table$fp_tsv[i]
  if (!file.exists(file)){
    stop(paste0("File does not exist: ", input_table$fp_tsv[i]))
  }
  temp_dataset <- fread(file, header = T, sep="\t")
  colnames(temp_dataset) = c("Locus", "Count", "Genotype","VAF")
  temp_dataset = separate(temp_dataset, Count, into = c(NA,'DP1',NA,'DP2'), remove = F)
  temp_dataset$DP2[is.na(temp_dataset$DP2)==T] <- 0
  temp_dataset$DP = as.numeric(temp_dataset$DP1) + as.numeric(temp_dataset$DP2)
  temp_dataset = temp_dataset[temp_dataset$DP >= args$depth_filter,] ## keeping loci >= 20 dp by default
  temp_dataset$VAF[is.na(temp_dataset$VAF)==T] <- 0
  temp_dataset$Sample = sample #only loci with DP >= depth filter will have Sample info
  temp_dataset = temp_dataset %>% select("Locus","Genotype","Sample","VAF")
  temp_dataset$Locus = str_replace(temp_dataset$Locus,"chr","")

  if (tolower(genome_build) %in% c("hg19","grch37")){
    temp_dataset = merge(hg19_hg38_mapper, temp_dataset, by.x = "Loci_hg19", by.y = "Locus", all.x = T)
    temp_dataset$VAF[is.na(temp_dataset$VAF)==T] <- 0
  } else if (tolower(genome_build) %in% c("hg38","grch38")){
    temp_dataset = merge(hg19_hg38_mapper, temp_dataset, by.x = "Loci_hg38", by.y = "Locus", all.x = T)
    temp_dataset$VAF[is.na(temp_dataset$VAF)==T] <- 0
  }

  if (!exists("all_gbcm")){
    all_gbcm = temp_dataset
  } else {
    all_gbcm = rbind(all_gbcm, temp_dataset)
  }
}
all_gbcm = all_gbcm[is.na(all_gbcm$Sample)==F,] # filters out loci that don't have Sample info (i.e. loci not passing DP filter)
all_gbcm$VAF = round(as.numeric(all_gbcm$VAF), 5)

wide_all_gbcm = all_gbcm %>% pivot_wider(names_from = Sample, values_from = c(Genotype, VAF))

message("Creating final GBCM file")

all_fp_gbcm_final = merge(hg19_hg38_mapper, wide_all_gbcm,all.x = T)

if (!dir.exists(args$analysis_folder)) {
  dir.create(args$analysis_folder, recursive = TRUE)
} else {
  print(paste("Directory already exists:", args$analysis_folder))
}

message(paste("Output file: ", args$analysis_folder,"/",args$depth_filter,"DPfilter_ALL_FP.txt", sep=""))

all_fp_gbcm_final <- apply(all_fp_gbcm_final,2,as.character)
write.table(all_fp_gbcm_final, file = paste(args$analysis_folder,"/",args$depth_filter,"DPfilter_ALL_FP.txt", sep=""), append = F, sep = "\t", row.names = F, quote = F)

message("FP file completed")
