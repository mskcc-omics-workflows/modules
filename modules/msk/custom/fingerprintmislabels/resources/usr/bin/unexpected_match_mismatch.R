#!/usr/bin/env Rscript

#-------------------------------------------------------------------------------
# Script:  unexpected_match_mismatch.R
# Author:  Erika Gedvilaite
# Date:    2026-03-10
# Version: 0.1.0
#
# Description: This script takes in fingerprint corrations and observation
# counts and identifies patient mismatches and matches based on patient labels.
#
#-------------------------------------------------------------------------------

rm(list=ls())
library(plyr, quietly = T)
library(dplyr, quietly = T)
library(data.table, quietly = T)
library(tidyverse, quietly = T)
library(argparse, quietly = T)

`%notin%` <- Negate(`%in%`)
`%notlike%` <- Negate(`%like%`)

parser = ArgumentParser(description = 'Generate Unexpected Match and Mismatch results for FPv3 (TRACE)')
parser$add_argument('-r', '--run_id', required = TRUE,
                    help = 'Sequencing Run')
parser$add_argument('-o', '--output_folder', required = TRUE,
                    help = 'Output folder')
parser$add_argument('-i', '--sample_sheet', required = TRUE,
                    help = 'Sample Sheet')
parser$add_argument('-c', '--correlations', required = TRUE,
                    help = 'Path to fingerprint correlations file')
parser$add_argument('-n', '--observations', required = TRUE,
                    help = 'Path to fingerprint observations file')
args = parser$parse_args()
theme_set(theme_classic())

# Helper: build seq() breakpoints for cut(); expands range when all values
# fall within the same integer interval (avoids "invalid number of intervals").
make_corr_breaks <- function(x) {
  lo <- floor(min(x, na.rm = TRUE))
  hi <- ceiling(max(x, na.rm = TRUE))
  if (lo == hi) { lo <- lo - 1L; hi <- hi + 1L }
  seq(lo, hi, by = 0.1)
}

# Setting up input collection

poolID = args$run_id
samplesheetpath = args$sample_sheet
outputpath = args$output_folder

print(paste("Correlations file: ", args$correlations, sep = ""))
print(paste("Observations file: ", args$observations, sep = ""))
print(paste("Output directory: ",outputpath, sep = ""))
print(paste("Sample Sheet: ",samplesheetpath, sep = ""))
print(paste("Run ID: ",poolID, sep = ""))


sample_sheet = read.csv(samplesheetpath,header = T, sep = ",", check.names = F)
sample_sheet = sample_sheet %>% select(sample, patient, is_donor) %>% unique()
sample_sheet$patient = str_pad(sample_sheet$patient, 8, pad = "0")
colnames(sample_sheet) = c("Sample","Patient","IsDonor")

sample_sheet <- sample_sheet %>%
  mutate(
    Transplant = case_when(IsDonor == "true" ~ "Donor Found",
                           TRUE ~ "No Donor Found")
  )

sample_sheet_transplant = sample_sheet %>% select(Patient, Transplant) %>% unique()
sample_sheet_transplant = sample_sheet_transplant[sample_sheet_transplant$Transplant == "Donor Found",]

sample_sheet = sample_sheet %>% select(Patient, Sample) %>% unique()
sample_sheet = merge(sample_sheet, sample_sheet_transplant, by = "Patient", all.x = T)
sample_sheet$Transplant[is.na(sample_sheet$Transplant)==T] <- "No Donor Found"

correlation_f = read.csv(args$correlations, header = T, sep = "\t", check.names = F)

observations_f = read.csv(args$observations, header = T, sep = "\t", check.names = F)

correlation_f = as.data.frame(correlation_f)
observations_f = as.data.frame(observations_f)

correlation_f[is.na(correlation_f)] <- 0
observations_f[is.na(observations_f)] <- 0

correlation_wide_df <- as.data.frame(correlation_f)

correlation_wide_df$Assay1 <- rownames(correlation_wide_df)
rownames(correlation_wide_df) <- NULL
correlation_wide_df <- correlation_wide_df[, c("Assay1", colnames(correlation_wide_df))]

correlation_wide_df <- correlation_wide_df[, !(names(correlation_wide_df) %in% c("Assay1.1"))]

correlation_long_df <- melt(setDT(correlation_wide_df), id.vars = c("Assay1"), variable.name = "Sample")

colnames(correlation_long_df) = c("Sample1", "Sample2", "Correlation")

correlation_long_df = correlation_long_df %>% select(Sample1, Sample2, Correlation) %>% unique()

observations_wide_df <- as.data.frame(observations_f)

observations_wide_df$Assay1 <- rownames(observations_wide_df)
rownames(observations_wide_df) <- NULL
observations_wide_df <- observations_wide_df[, c("Assay1", colnames(observations_wide_df))]

observations_wide_df <- observations_wide_df[, !(names(observations_wide_df) %in% c("Assay1.1"))]

observations_long_df <- melt(setDT(observations_wide_df), id.vars = c("Assay1"), variable.name = "Sample")

colnames(observations_long_df) = c("Sample1", "Sample2", "Observation")

observations_long_df = observations_long_df %>% select(Sample1, Sample2, Observation) %>% unique()

correlation_long_df = merge(correlation_long_df, observations_long_df) %>% unique() %>% drop_na()

correlation_long_df$Correlation = round(correlation_long_df$Correlation,2)

correlation_long_df = merge(correlation_long_df,  sample_sheet, by.x = "Sample1", by.y = "Sample", all.x = T)
correlation_long_df = merge(correlation_long_df,  sample_sheet, by.x = "Sample2", by.y = "Sample", all.x = T)

colnames(correlation_long_df) = c("Sample2", "Sample1", "Correlation", "Observation", "Patient1", "Donor_Status1", "Patient2", "Donor_Status2")

## Data clean-out
### 1. Remove same sample-to-sample comparison (assume 1 for these)
### 2. Only keeping one pair per match (removing pair duplicates)

key <- t(apply(correlation_long_df[, c("Sample1", "Sample2")], 1, sort))
correlation_long_df_clean <- correlation_long_df[!duplicated(key), ]

## Analysis organization
### 1. Unexpected match: Sample 1 and Sample 2 are coming from DIFFERENT Patient ID
### 2. Unexpected mismatch: Sample 1 and Sample 2 are coming from the SAME Patient ID

unexpected_match = correlation_long_df_clean[correlation_long_df_clean$Patient1!=correlation_long_df_clean$Patient2,]
unexpected_mismatch = correlation_long_df_clean[correlation_long_df_clean$Patient1==correlation_long_df_clean$Patient2,]

## Unexpected match calculation - sample

unexpected_match_sample = copy(unexpected_match)
unexpected_match_sample$Loci_Status = ifelse(unexpected_match_sample$Observation >= 10, "Loci Pass","Loci Low")
unexpected_match_sample$Donor_Status = ifelse((unexpected_match_sample$Donor_Status1 == "Donor Found" | unexpected_match_sample$Donor_Status2 == "Donor Found"), "Donor Present","No Donor")

unexpected_match_sample$Pool_mean = round(mean(unexpected_match_sample$Correlation),2)
unexpected_match_sample$Pool_SD = round(sd(unexpected_match_sample$Correlation),2)

unexpected_match_sample$Cohort_mean = 0.02
unexpected_match_sample$Cohort_SD = 0.07

unexpected_match_sample$Pool_meanplussd = unexpected_match_sample$Pool_mean + unexpected_match_sample$Pool_SD
unexpected_match_sample$Pool_meanplussd = round(unexpected_match_sample$Pool_meanplussd,2)

unexpected_match_sample$Mean_plusSD = unexpected_match_sample$Cohort_mean+unexpected_match_sample$Cohort_SD
unexpected_match_sample$Mean_plus2SD = unexpected_match_sample$Cohort_mean+2*unexpected_match_sample$Cohort_SD
unexpected_match_sample$Mean_plus25SD = unexpected_match_sample$Cohort_mean+2.5*unexpected_match_sample$Cohort_SD
unexpected_match_sample$Mean_minusSD = unexpected_match_sample$Cohort_mean-unexpected_match_sample$Cohort_SD
unexpected_match_sample$Mean_minus2SD = unexpected_match_sample$Cohort_mean-2*unexpected_match_sample$Cohort_SD
unexpected_match_sample$Mean_minus25SD = unexpected_match_sample$Cohort_mean-2.5*unexpected_match_sample$Cohort_SD


unexpected_match_sample$Match_Status = ifelse(unexpected_match_sample$Correlation >= unexpected_match_sample$Mean_plus25SD, "Matching","Pass")

unexpected_match_sample$key = paste(unexpected_match_sample$Sample1, unexpected_match_sample$Sample2, sep=":")

unexpected_match_sample_intervals_corr = unexpected_match_sample %>%
  mutate(interval = cut(Correlation, breaks = make_corr_breaks(Correlation), include.lowest = TRUE)) %>%
  count(interval)

intervals_set <- c("[-1,-0.9]", "(-0.9,-0.8]", "(-0.8,-0.7]", "(-0.7,-0.6]", "(-0.6,-0.5]","(-0.5,-0.4]", "(-0.4,-0.3]", "(-0.3,-0.2]", "(-0.2,-0.1]", "(-0.1,0]", "(0,0.1]", "(0.1,0.2]", "(0.2,0.3]", "(0.3,0.4]", "(0.4,0.5]", "(0.5,0.6]", "(0.6,0.7]", "(0.7,0.8]", "(0.8,0.9]","(0.9,1]")
intervals_df <- data.frame(
  interval = intervals_set
)

intervals_df = merge(intervals_df, unexpected_match_sample_intervals_corr, all.x = T)
intervals_df$n[is.na(intervals_df$n)] <- 0
intervals_df$percent = round(intervals_df$n/nrow(unexpected_match_sample),digits = 2)

intervals_df$interval <- factor(intervals_df$interval, levels = c("[-1,-0.9]", "(-0.9,-0.8]", "(-0.8,-0.7]", "(-0.7,-0.6]", "(-0.6,-0.5]","(-0.5,-0.4]", "(-0.4,-0.3]", "(-0.3,-0.2]", "(-0.2,-0.1]", "(-0.1,0]", "(0,0.1]", "(0.1,0.2]", "(0.2,0.3]", "(0.3,0.4]", "(0.4,0.5]", "(0.5,0.6]", "(0.6,0.7]", "(0.7,0.8]", "(0.8,0.9]","(0.9,1]"))

pdf(file = paste(outputpath,"/",poolID,"_unexpected_match.pdf",sep = ""), width = 10, height = 6)


group_colors <- c(Pass = "#D3D3D3", Matching = "#CC6600")

ggplot(unexpected_match_sample, aes(x = key, y = Correlation)) +
  geom_point(aes(colour = Match_Status, shape = Donor_Status), size = 1.0) +
  geom_hline(aes(yintercept = Mean_plus25SD, linetype = "Mean+2.5SD"), size = 0.5) +
  geom_hline(aes(yintercept = Mean_minus25SD, linetype = "Mean-2.5SD"), size = 0.5) +
  geom_hline(aes(yintercept = Mean_plusSD, linetype = "Mean+SD"), size = 0.5) +
  geom_hline(aes(yintercept = Mean_minusSD, linetype = "Mean-SD"), size = 0.5) +
  theme(axis.title.x=element_blank(),axis.text.x=element_blank(),axis.ticks.x=element_blank()) +
  labs(colour = "Match Status") +
  labs(shape = "Donor Status") +
  ylim(-1,1) +
  scale_color_manual(values = group_colors) +
  labs(linetype = "Limits") +
  ggtitle(paste("Pool:",poolID,sep=""),subtitle = "Unexpected Match Overall")

ggplot(unexpected_match_sample, aes(x = key, y = Correlation)) +
  geom_point(aes(colour = Match_Status, shape = Donor_Status), size = 1.0) +
  geom_hline(aes(yintercept = Mean_plus25SD, linetype = "Mean+2.5SD"), size = 0.5) +
  geom_hline(aes(yintercept = Mean_minus25SD, linetype = "Mean-2.5SD"), size = 0.5) +
  geom_hline(aes(yintercept = Mean_plusSD, linetype = "Mean+SD"), size = 0.5) +
  geom_hline(aes(yintercept = Mean_minusSD, linetype = "Mean-SD"), size = 0.5) +
  theme(axis.title.x=element_blank(),axis.text.x=element_blank(),axis.ticks.x=element_blank()) +
  labs(colour = "Match Status") +
  labs(shape = "Donor Status") +
  ylim(-1,1) +
  scale_color_manual(values = group_colors) +
  labs(linetype = "Limits") +
  facet_wrap(~Patient2, scales = "free_x") +
  ggtitle(paste("Pool:",poolID, sep=""),subtitle = "Unexpected Match Overall")

ggplot(intervals_df, aes(x=interval, y = log10(n))) +
  geom_bar(stat = "identity", position = "dodge") +
  geom_text(aes(label = paste(n,"\n",percent,sep="")), vjust = -0.5, color = "black")+
  annotate("text", x=1, y=5, label= paste("Threshold Mean + SD: ",unexpected_match_sample$Mean_plusSD,sep=""), hjust = 0) +
  annotate("text", x=1, y=4.5, label= paste("Threshold Mean + 2.5*SD: ",unexpected_match_sample$Mean_plus25SD,sep=""), hjust = 0) +
  annotate("text", x=1, y=4, label= paste("Threshold Mean - SD: ",unexpected_match_sample$Mean_minusSD,sep=""), hjust = 0) +
  annotate("text", x=1, y=3.5, label= paste("Threshold Mean - 2.5SD: ",unexpected_match_sample$Mean_minus25SD,sep=""), hjust = 0) +
  annotate("text", x=1, y=3., label= paste("Pool Mean + SD: ",unexpected_match_sample$Pool_meanplussd,sep=""), hjust = 0) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)) +
  xlab("Intervals") +
  ylab("log10(Compared Pairs)") +
  ggtitle(paste("Pool:",poolID, sep=""),subtitle = "Unexpected Match Intervals")

dev.off()

unexpected_match_sample_table = unexpected_match_sample[unexpected_match_sample$Match_Status == "Matching",]

unexpected_match_sample_table = unexpected_match_sample_table %>% select(Sample1, Sample2, Correlation, Observation, Mean_minusSD, Mean_minus2SD, Mean_minus25SD, Mean_plusSD, Mean_plus2SD, Mean_plus25SD, Match_Status, Loci_Status, Donor_Status) %>% unique()
write.table(unexpected_match_sample_table,file = paste(outputpath,"/",poolID,"_unexpected_match.txt",sep = ""), append = F, quote = F, sep = "\t", row.names = F)

## Unexpected mismatch calculation - sample

unexpected_mismatch_sample = copy(unexpected_mismatch)
unexpected_mismatch_sample$Loci_Status = ifelse(unexpected_mismatch_sample$Observation >= 10, "Loci Pass","Loci Low")
unexpected_mismatch_sample$Donor_Status = ifelse((unexpected_mismatch_sample$Donor_Status1 == "Donor Found" | unexpected_mismatch_sample$Donor_Status2 == "Donor Found"), "Donor Present","No Donor")
unexpected_mismatch_sample$Correlation = as.numeric(unexpected_mismatch_sample$Correlation)

unexpected_mismatch_sample$Pool_mean = round(mean(unexpected_mismatch_sample$Correlation),2)
unexpected_mismatch_sample$Pool_sd = round(sd(unexpected_mismatch_sample$Correlation),2)

unexpected_mismatch_sample$Pool_meanminussd = unexpected_mismatch_sample$Pool_mean - unexpected_mismatch_sample$Pool_sd

unexpected_mismatch_sample$Cohort_mean = 0.96
unexpected_mismatch_sample$Cohort_SD = 0.07

unexpected_mismatch_sample$Mean_minus25SD = unexpected_mismatch_sample$Cohort_mean-2.5*unexpected_mismatch_sample$Cohort_SD
unexpected_mismatch_sample$Mean_minusSD = unexpected_mismatch_sample$Cohort_mean-unexpected_mismatch_sample$Cohort_SD
unexpected_mismatch_sample$Mean_minus2SD = unexpected_mismatch_sample$Cohort_mean-2*unexpected_mismatch_sample$Cohort_SD

unexpected_mismatch_sample$Match_Status = ifelse(unexpected_mismatch_sample$Correlation <= unexpected_mismatch_sample$Mean_minus25SD, "Mismatching","Pass")

unexpected_mismatch_sample$key = paste(unexpected_mismatch_sample$Sample1, unexpected_mismatch_sample$Sample2, sep=":")

unexpected_mismatch_sample_intervals_corr = unexpected_mismatch_sample %>%
  mutate(interval = cut(Correlation, breaks = make_corr_breaks(Correlation), include.lowest = TRUE)) %>%
  count(interval)

intervals_set <- c("[-1,-0.9]", "(-0.9,-0.8]", "(-0.8,-0.7]", "(-0.7,-0.6]", "(-0.6,-0.5]","(-0.5,-0.4]", "(-0.4,-0.3]", "(-0.3,-0.2]", "(-0.2,-0.1]", "(-0.1,0]", "(0,0.1]", "(0.1,0.2]", "(0.2,0.3]", "(0.3,0.4]", "(0.4,0.5]", "(0.5,0.6]", "(0.6,0.7]", "(0.7,0.8]", "(0.8,0.9]","(0.9,1]")
intervals_df <- data.frame(
  interval = intervals_set
)

intervals_df = merge(intervals_df, unexpected_mismatch_sample_intervals_corr, all.x = T)
intervals_df$n[is.na(intervals_df$n)] <- 0
intervals_df$percent = round(intervals_df$n/nrow(unexpected_mismatch_sample),digits = 2)

intervals_df$interval <- factor(intervals_df$interval, levels = c("[-1,-0.9]", "(-0.9,-0.8]", "(-0.8,-0.7]", "(-0.7,-0.6]", "(-0.6,-0.5]","(-0.5,-0.4]", "(-0.4,-0.3]", "(-0.3,-0.2]", "(-0.2,-0.1]", "(-0.1,0]", "(0,0.1]", "(0.1,0.2]", "(0.2,0.3]", "(0.3,0.4]", "(0.4,0.5]", "(0.5,0.6]", "(0.6,0.7]", "(0.7,0.8]", "(0.8,0.9]","(0.9,1]"))


pdf(file = paste(outputpath,"/",poolID,"_unexpected_mismatch.pdf",sep = ""), width = 10, height = 6)

group_colors <- c(Pass = "#D3D3D3", Mismatching = "#CC6600")


ggplot(unexpected_mismatch_sample, aes(x = key, y = Correlation)) +
  geom_point(aes(colour = Match_Status, shape = Donor_Status), size = 1.0) +
  geom_hline(aes(yintercept = Mean_minus25SD, linetype = "Mean-2.5SD"), size = 0.5) +
  geom_hline(aes(yintercept = Mean_minusSD, linetype = "Mean-SD"), size = 0.5) +
  theme(axis.title.x=element_blank(),axis.text.x=element_blank(),axis.ticks.x=element_blank()) +
  labs(colour = "Match Status") +
  labs(shape = "Donor Status") +
  ylim(0,1) +
  scale_color_manual(values = group_colors) +
  labs(linetype = "Limits") +
  ggtitle(paste("Pool:",poolID,sep=""),subtitle = "Unexpected Mismatch Overall")

ggplot(unexpected_mismatch_sample, aes(x = key, y = Correlation)) +
  geom_point(aes(colour = Match_Status, shape = Donor_Status), size = 1.0) +
  geom_hline(aes(yintercept = Mean_minus25SD, linetype = "Mean-2.5SD"), size = 0.5) +
  geom_hline(aes(yintercept = Mean_minusSD, linetype = "Mean-SD"), size = 0.5) +
  theme(axis.title.x=element_blank(),axis.text.x=element_blank(),axis.ticks.x=element_blank()) +
  labs(colour = "Match Status") +
  labs(shape = "Donor Status") +
  ylim(0,1) +
  scale_color_manual(values = group_colors) +
  labs(linetype = "Limits") +
  facet_wrap(~Patient2, scales = "free_x") +
  ggtitle(paste("Pool:",poolID,sep=""),subtitle = "Unexpected Mismatch Overall")

ggplot(intervals_df, aes(x=interval, y = log10(n))) +
  geom_bar(stat = "identity", position = "dodge") +
  geom_text(aes(label = paste(n,"\n",percent,sep="")), vjust = -0.5, color = "black")+
  annotate("text", x=1, y=4.5, label= paste("Threshold Mean - SD: ",unexpected_mismatch_sample$Mean_minusSD,sep=""), hjust = 0) +
  annotate("text", x=1, y=4, label= paste("Threshold Mean - 2.5SD: ",unexpected_mismatch_sample$Mean_minus25SD,sep=""), hjust = 0) +
  annotate("text", x=1, y=3.5, label= paste("Pool Mean + SD: ",unexpected_mismatch_sample$Pool_meanminussd,sep=""), hjust = 0) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)) +
  ggtitle(paste("Pool:",poolID,sep=""),subtitle = "Unexpected Mismatch Intervals") +
  xlab("Intervals") +
  ylab("log10(Compared Pairs)")

dev.off()

unexpected_mismatch_sample_table = unexpected_mismatch_sample[unexpected_mismatch_sample$Match_Status == "Mismatching",]

unexpected_mismatch_sample_table = unexpected_mismatch_sample_table %>% select(Sample1, Sample2, Correlation, Observation, Mean_minusSD, Mean_minus2SD, Mean_minus25SD, Loci_Status, Donor_Status) %>% unique()
write.table(unexpected_mismatch_sample_table,file = paste(outputpath,"/",poolID,"_unexpected_mismatch.txt",sep = ""), append = F, quote = F, sep = "\t", row.names = F)
