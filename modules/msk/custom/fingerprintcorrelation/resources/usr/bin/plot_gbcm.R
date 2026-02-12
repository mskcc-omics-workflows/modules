#!/usr/bin/env Rscript

#-------------------------------------------------------------------------------
# Script: plot_gbcm.R
# Author: Hanan Salim
# Date:   2026-02-09
# Version: 0.2.0
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
library(htmlwidgets)
library(ggiraph)


`%notin%` <- Negate(`%in%`)
`%notlike%` <- Negate(`%like%`)


#function to size the dots
calculate_point_size <- function(x,y) {
    n_x <- length(unique(x))
    n_y <- length(unique(y))
    
    #define your plot size (in inches)
    plot_width_in <- 20
    plot_height_in <- 20
    
    #convert to mm (1 inch = 25.4 mm)
    plot_width_mm <- plot_width_in * 25.4
    plot_height_mm <- plot_height_in * 25.4
    
    #calculate tile size in mm
    tile_width_mm <- plot_width_mm / n_x
    tile_height_mm <- plot_height_mm / n_y
    
    #max circle diameter (fits inside smallest tile dimension)
    max_diameter_mm <- min(tile_width_mm, tile_height_mm)
    
    #approximate max point size for geom_point (radius in mm)
    max_point_size <- max_diameter_mm 
    
    return(max_point_size)
}


#function to create static plots
static_plot <- function(data, max_point_size) {
    n = length(unique(data$Var1))
    legend_size = max_point_size * n * .4

    axis_text_size = if (n < 25) 14 else 10
    
    p <- ggplot(data, aes(x = Var1, y = Var2)) +
        geom_tile(color = "gray50", linewidth = 0.25, fill = NA) +
        geom_point_interactive(
            aes(size = log2_size,
                fill = value,
                tooltip = paste0(
                    "x: ", Var1, "\n",
                    "y: ", Var2, "\n",
                    "Loci Overlap: ", size, "\n",
                    "Correlation: ", round(value, 2)
                )),
            shape = 21,
            color="NA"
        ) +
        scale_x_discrete(limits = sort(levels(data$Var1))) +
        scale_y_discrete(limits = rev(sort(levels(data$Var2)))) +
        scale_fill_viridis_c(
            name = "Correlation",
            option = "viridis",
            direction = -1,
            alpha = 0.75,
            begin = 0,
            end = 1,
            limits = c(-1, 1),
            breaks = seq(-1, 1, by = .25),
            guide = guide_colorbar(direction = "vertical", 
                                   title.position = "top",
                                   barheight = unit(legend_size, "mm"),
                                   barwidth = unit(legend_size*.05, "mm")
            )) +
        scale_size_continuous(
            limits = c(0, 14.2),    #known max of log2(size)
            range = c(0, max_point_size),
            breaks = seq(2, 14, by = 4),
            name = "Loci Overlap (log2)",
            guide = guide_legend(direction = "vertical",
                                 title.position = "top",
                                 keyheight = unit(legend_size/4, "mm"),
                                                  override.aes = list(
                                                       color = "black",
                                                       stroke = 0.5
                                                   ))
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
            aspect.ratio = 1
        )

    return(p)
}


parser = ArgumentParser(description = 'create correlation plots for a given sample')

parser$add_argument('-t', '--table', required = TRUE,
                    help = 'summary table')

parser$add_argument('-o', '--analysis_folder', required = TRUE,
                    help = 'output folder')

parser$add_argument('-p', '--pool', required = FALSE,
                    default = "fp_plots",
                    help = 'pool ID')

parser$add_argument('-f', '--filter', 
                    action = "store_true",
                    default = FALSE,
                    help = "create pool levelel plots instead of extended plots"
)

args = parser$parse_args()

fingerprints = fread(args$table, sep = '\t')
outdir = args$analysis_folder
sample = args$pool


#format data
fingerprints <- fingerprints %>% select(-contains(c('Loci_hg19', 'Loci_hg38')))
cols <- grep("VAF", names(fingerprints), value = TRUE)
fingerprints <- fingerprints[, ..cols]

for ( col in 1:ncol(fingerprints)){
    colnames(fingerprints)[col] <-  sub("VAF_", "", colnames(fingerprints)[col])
}

title = paste("Pool:", sample,"; ", nrow(fingerprints)," Loci used",sep = "")

fp_matrix <- data.matrix(fingerprints)
fp_matrix = cor(as.matrix(fp_matrix), method = c("pearson"), use = "pairwise.complete.obs")

fp_long <- reshape2::melt(fp_matrix)
observations = crossprod(!is.na(fingerprints))
obs_long <- reshape2::melt(observations)
final <- data.frame(fp_long, size = obs_long$value)

#calculate log2 size column
final$log2_size <- log2(final$size)

if (args$filter) {

    if (identical(args$pool, "fp_plots")) {
        message("A pool ID is required to create pool level plots")
        quit(status = 1)
    }
    
    message("Creating pool level plots")
    type="pool"
    
    final = final %>% filter(grepl(args$pool, Var1) & grepl(args$pool, Var2))
    final = droplevels(final)
    
} else {
    message("Creating extended plots")
    type="extended"
}

#get max point size
max_point_size = calculate_point_size(final$Var1, final$Var2)

#create static plot
s <- static_plot(final, max_point_size)
ggsave(paste(outdir,"/",sample,"_", type, '.pdf', sep = ""), plot = s, width = 25, height = 25, units = "in", device = cairo_pdf)

#create interactive plot
i = girafe(ggobj = s, width_svg = 25, height_svg = 25, 
           options = list(opts_tooltip(css = "padding:5pt; font-size:16pt; color:white; background-color:black;")))
saveWidget(i, paste(outdir,"/",sample,"_", type,'.html', sep = ""), selfcontained = TRUE)

#save tables
write.table(observations, paste(outdir,"/",sample, '_observations.tab', sep = ''), sep = '\t')
write.table(fp_matrix, paste(outdir,"/",sample, '_correlations.tab', sep = ''), sep = '\t')
