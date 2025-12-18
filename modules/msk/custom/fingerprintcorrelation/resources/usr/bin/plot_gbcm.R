#!/usr/bin/env Rscript
#-------------------------------------------------------------------------------
# Script: plot_gbcm.R
# Author: Hanan Salim
# Date:   2025-11-03
# Version: 0.1.0
#
# Description: This script takes in a wide fingerprinting table pertaining
# to multiple samples and plots in pdf and html formats.
# Additionally, a table with the number of observations for each correlation
# is also written to an output file.
#
#-------------------------------------------------------------------------------


rm(list=ls())

library(argparse, quietly = T)
library(plyr, quietly = T)
library(dplyr, quietly = T)
library(data.table, quietly = T)
library(tidyverse, quietly = T)
library(scales, quietly = T)
library(ggforce, quietly = T)
library(gtools, quietly = T)
library(plotly)
library(htmlwidgets)
library(ggiraph)
library(reshape2)

`%notin%` <- Negate(`%in%`)
`%notlike%` <- Negate(`%like%`)

parser = ArgumentParser(description = 'create correlation plots for a given sample')

parser$add_argument('-t', '--table', required = TRUE,
                    help = 'summary table')

parser$add_argument('-o', '--analysis_folder', required = TRUE,
                    help = 'output folder')

parser$add_argument('-p', '--pool', required = TRUE,
                    help = 'pool ID')

args = parser$parse_args()

all_fp_gbcm_final = fread(args$table, sep = '\t')
outdir = args$analysis_folder
sample = args$pool

all_fp_gbcm_final <- all_fp_gbcm_final %>% select(-contains(c('Loci_hg19', 'Loci_hg38')))
cols <- grep("VAF", names(all_fp_gbcm_final), value = TRUE)
#print(class(all_fp_gbcm_final))
all_fp_gbcm_final <- all_fp_gbcm_final[, ..cols]

for ( col in 1:ncol(all_fp_gbcm_final)){
  colnames(all_fp_gbcm_final)[col] <-  sub("VAF_", "", colnames(all_fp_gbcm_final)[col])
}

title = paste("Patient:", sample,"; ", nrow(all_fp_gbcm_final)," Loci used",sep = "")

all_fp_gbcm_final_matrix <- data.matrix(all_fp_gbcm_final)
all_fp_gbcm_final_matrix = cor(as.matrix(all_fp_gbcm_final_matrix), method = c("pearson"), use = "pairwise.complete.obs")

gbcm_data_long <- reshape2::melt(all_fp_gbcm_final_matrix)
gbcm_observation = crossprod(!is.na(all_fp_gbcm_final))
gbcm_obs_long <- reshape2::melt(gbcm_observation)
gbcm_combo_data <- data.frame(gbcm_data_long, size = gbcm_obs_long$value)

# plot
#pdf(paste(outdir,"/",sample,'_sample-to-sample.pdf', sep = ""), width = 25, height = 25)

n_x <- length(unique(gbcm_combo_data$Var1))
n_y <- length(unique(gbcm_combo_data$Var2))

# Define your plot size (in inches)
plot_width_in <- 20
plot_height_in <- 20

# Convert to mm (1 inch = 25.4 mm)
plot_width_mm <- plot_width_in * 25.4
plot_height_mm <- plot_height_in * 25.4

# Calculate tile size in mm
tile_width_mm <- plot_width_mm / n_x
tile_height_mm <- plot_height_mm / n_y

# Max circle diameter (fits inside smallest tile dimension)
max_diameter_mm <- min(tile_width_mm, tile_height_mm)

# Approximate max point size for geom_point (radius in mm)
max_point_size <- max_diameter_mm

# Calculate log2 size column
gbcm_combo_data$log2_size <- log2(gbcm_combo_data$size)
#print(gbcm_combo_data$log2_size)


gbcm_combo_data$Var1 <- factor(gbcm_combo_data$Var1, levels = mixedsort(unique(gbcm_combo_data$Var1)))
gbcm_combo_data$Var2 <- factor(gbcm_combo_data$Var2, levels = mixedsort(unique(gbcm_combo_data$Var2)))

p <- ggplot(gbcm_combo_data, aes(x = Var1, y = Var2)) +
  geom_tile(color = "black", linewidth = 0.5, fill = NA) +
  geom_point(aes(size = log2_size, fill = value), shape = 21, color = "black") +
  #geom_text(aes(label = size), color = "white", size = 4) +
  scale_x_discrete(limits = sort(levels(gbcm_combo_data$Var1))) +
  scale_y_discrete(limits = sort(levels(gbcm_combo_data$Var2))) +
  scale_fill_viridis_c(
    name = "Correlation",
    option = "viridis",
    direction = -1,
    alpha = 0.75,
    begin = 0,
    end = 1,
    limits = c(-1, 1),
    guide = guide_colorbar(direction = "vertical",
                           title.position = "top"
    )) +
  scale_size_continuous(limits = c(0, 14.2),    # known max of log2(size)
    range = c(0, max_point_size),
    name = "Sites (log2)",
    guide = guide_legend(direction = "vertical",
                         title.position = "top")
  ) +
  #scale_size_identity(name = "Sites (log2)",
  #                    guide = guide_legend(direction = "vertical",
  #                                         title.position = "top"),
  #                    breaks = rescale(c(2, 5, 10, 14.2), to = c(1, 10), from = c(0, max_log2)),
  #                    labels = c("2", "5", "10", "14.2")) +

  #scale_size_continuous(name = "Sites (log2)",
                        #range = c(4, 32),
                        #guide = guide_legend(direction = "vertical",
                                             #title.position = "top")) +
  labs(title = title) +
  theme_minimal() +
  theme(
    panel.grid = element_blank(),
    axis.text.x = element_text(angle = 90, hjust = 1, size = 10, color = "black"),
    axis.text.y = element_text(size = 10, color = "black"),
    axis.title = element_blank(),
    plot.title = element_text(hjust = 0.5, size = 20, margin = margin(b = 15)),
    legend.position = "right",
    legend.box = "horizontal",
    legend.box.just = "left",
    legend.title.align = 0.5,
    legend.spacing.x = unit(1, "cm"),
    aspect.ratio = 1
  )

p2 <- ggplot(gbcm_combo_data, aes(x = Var1, y = Var2)) +
  geom_tile(color = "black", linewidth = 0.5, fill = NA) +
  geom_point_interactive(
    aes(size = log2_size,
        fill = value,
        tooltip = paste0(
          "x: ", Var1, "\n",
          "y: ", Var2, "\n",
          "Size: ", size, "\n",
          "Correlation: ", round(value, 2)
      )),
    shape = 21,
    color = "black"
  ) +
  scale_x_discrete(limits = sort(levels(gbcm_combo_data$Var1))) +
  scale_y_discrete(limits = sort(levels(gbcm_combo_data$Var2))) +
  scale_fill_viridis_c(
    name = "Correlation",
    option = "viridis",
    direction = -1,
    alpha = 0.75,
    begin = 0,
    end = 1,
    limits = c(-1, 1),
    guide = guide_colorbar(direction = "vertical",
                           title.position = "top"
    )) +
  scale_size_continuous(limits = c(0, 14.2),    # known max of log2(size)
                        range = c(0, max_point_size),
                        name = "Sites (log2)",
                        guide = guide_legend(direction = "vertical",
                                             title.position = "top")
  ) +
  labs(title = title) +
  theme_minimal() +
  theme(
    text = element_text(family = "Courier"),
    panel.grid = element_blank(),
    axis.text.x = element_text(angle = 90, hjust = 1, size = 10, color = "black"),
    axis.text.y = element_text(size = 10, color = "black"),
    axis.title = element_blank(),
    plot.title = element_text(hjust = 0.5, size = 24, margin = margin(b = 15)),
    legend.position = "right",
    legend.box = "horizontal",
    legend.box.just = "left",
    legend.title.align = 0.5,
    legend.spacing.x = unit(1, "cm"),
    aspect.ratio = 1,
  )


pg = girafe(ggobj = p2, width_svg = 25, height_svg = 25,
            options = list(opts_tooltip(css = "padding:5pt; font-size:16pt; color:white; background-color:black;")))

saveWidget(pg, paste(outdir,"/",sample,'_interactive4.html', sep = ""), selfcontained = TRUE)


ggsave(paste(outdir,"/",sample,'_gbcm_sample-to-sample4.pdf', sep = ""), plot = p, width = 25, height = 25, units = "in", device = cairo_pdf)
write.table(gbcm_observation, paste(outdir,"/",sample,'_observations.tab', sep = ''), sep = '\t')
