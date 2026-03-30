############################################################################
# Programmer: Emma McGee 
# Date: October 27, 2024
# Purpose of Program: Create adjusted risk curves (Figure 2)
############################################################################

############################################################################
# One figure per outcome; 4 interventions + No intervention; no CI ribbons
############################################################################

library(haven)
library(plyr)       
library(ggsci)      
library(ggplot2)
library(gridExtra) 
library(ggpubr)
library(tibble)
library(tidyverse)  
library(grid)
library(RColorBrewer)

#Palette & Shapes
colors <- brewer.pal(5, "Set2")

intervention_levels <- c(
  "No intervention",
  "Increase total weekly aerobic activity by 15 minutes vigorous or 30 minutes moderate",
  "Increase total weekly aerobic activity by 30 minutes vigorous or 60 minutes moderate",
  "Increase total weekly aerobic activity by 45 minutes vigorous or 90 minutes moderate",
  "Increase total weekly aerobic activity by 60 minutes vigorous or 120 minutes moderate"
)

# Color and shape maps
col_map <- setNames(colors[1:5], intervention_levels)
shape_map <- c(
  "No intervention" = 16, 
  "Increase total weekly aerobic activity by 15 minutes vigorous or 30 minutes moderate" = 17,
  "Increase total weekly aerobic activity by 30 minutes vigorous or 60 minutes moderate" = 15,
  "Increase total weekly aerobic activity by 45 minutes vigorous or 90 minutes moderate" = 3,
  "Increase total weekly aerobic activity by 60 minutes vigorous or 120 minutes moderate" = 7
)

# export vector files with panel clipping disabled
save_plot_vector <- function(p, basename, width_in = 9, height_in = 5){
  gt <- ggplot_gtable(ggplot_build(p))
  gt$layout$clip[gt$layout$name == "panel"] <- "off"
  
  # PDF
  grDevices::cairo_pdf(
    paste0(basename, ".pdf"),
    width = width_in,
    height = height_in,
    onefile = FALSE,
    family = "sans"
  )
  grid::grid.draw(gt)
  grDevices::dev.off()
  
  # EPS
  grDevices::cairo_ps(
    paste0(basename, ".eps"),
    width = width_in,
    height = height_in,
    onefile = FALSE,
    family = "sans",
    fallback_resolution = 600
  )
  grid::grid.draw(gt)
  grDevices::dev.off()
  
  # SVG
  if (requireNamespace("svglite", quietly = TRUE)) {
    svglite::svglite(
      paste0(basename, ".svg"),
      width = width_in,
      height = height_in
    )
    grid::grid.draw(gt)
    grDevices::dev.off()
  }
}

# Paths
data_dir <- "filepath/results"
file_all <- file.path(data_dir, "forgraphs_all_mort.sas7bdat")
file_bc  <- file.path(data_dir, "forgraphs_bc_mort.sas7bdat")
if (!file.exists(file_all)) stop("File not found: ", file_all)
if (!file.exists(file_bc))  stop("File not found: ", file_bc)

############################################################################
#################             OVERALL MORTALITY          ###################
############################################################################

forgraphs_all <- read_sas(file_all)

# Time points
time_all <- seq(0, by = 2, length.out = nrow(forgraphs_all))

# Columns
frame_all <- forgraphs_all[c(2,5,8,11,14)]
names(frame_all) <- intervention_levels
frame_all$time <- time_all

# Long format and compute risk = 1 - survival
long_all <- as_tibble(frame_all) %>%
  gather(Intervention, survprob, -time, factor_key = TRUE) %>%
  mutate(
    Intervention = factor(Intervention, levels = intervention_levels),
    risk = 1 - survprob
  )

plot_all <- ggplot(
  long_all,
  aes(x = factor(time), y = risk,
      group = Intervention, colour = Intervention, shape = Intervention)
) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2.5) +
  scale_color_manual(values = col_map) +
  scale_shape_manual(values = shape_map) +
  scale_y_continuous(
    breaks = c(0, 0.05, 0.10, 0.15, 0.20, 0.25),
    limits = c(0, 0.25),
    labels = c("0%","5%","10%","15%","20%","25%")
  ) +
  ylab("All-cause mortality (%)") +
  xlab("Year of follow-up") +
  theme_minimal() +
  theme(
    axis.text = element_text(size = 18, colour = "black"),
    axis.line.y = element_line(colour = "black"),
    axis.line.x = element_line(colour = "black"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.y = element_blank(),
    panel.grid.major.y = element_blank(),
    legend.position = "none",     # remove key/legend
    legend.title = element_blank(),
    legend.text = element_text(size = 12, colour = "black"),
    axis.ticks.x = element_line(linewidth = 0.8),
    axis.ticks.y = element_line(linewidth = 0.8),
    axis.ticks.length = unit(5, "pt")
  ) +
  font("xlab", size = 18) +
  font("ylab", size = 18) +
  font("legend.text", size = 8)

save_plot_vector(plot_all, file.path(data_dir, "figure_2_all_combined"))

############################################################################
#################         BREAST CANCER MORTALITY        ###################
############################################################################

forgraphs_bc <- read_sas(file_bc)

# Time points
time_bc <- seq(0, by = 2, length.out = nrow(forgraphs_bc))

# Columns
frame_bc <- forgraphs_bc[c(2,5,8,11,14)]
names(frame_bc) <- intervention_levels
frame_bc$time <- time_bc

# Long format (risk already on risk scale)
long_bc <- as_tibble(frame_bc) %>%
  gather(Intervention, risk, -time, factor_key = TRUE) %>%
  mutate(Intervention = factor(Intervention, levels = intervention_levels))

plot_bc <- ggplot(
  long_bc,
  aes(x = factor(time), y = risk,
      group = Intervention, colour = Intervention, shape = Intervention)
) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2.5) +
  scale_color_manual(values = col_map) +
  scale_shape_manual(values = shape_map) +
  scale_y_continuous(
    breaks = c(0, 0.05, 0.10, 0.15, 0.20, 0.25),
    limits = c(0, 0.25),
    labels = c("0%","5%","10%","15%","20%","25%")
  ) +
  ylab("Breast cancer mortality (%)") +
  xlab("Year of follow-up") +
  theme_minimal() +
  theme(
    axis.text = element_text(size = 18, colour = "black"),
    axis.line.y = element_line(colour = "black"),
    axis.line.x = element_line(colour = "black"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.y = element_blank(),
    panel.grid.major.y = element_blank(),
    legend.position = "none",     # remove key/legend
    legend.title = element_blank(),
    legend.text = element_text(size = 12, colour = "black"),
    axis.ticks.x = element_line(linewidth = 0.8),
    axis.ticks.y = element_line(linewidth = 0.8),
    axis.ticks.length = unit(5, "pt")
  ) +
  font("xlab", size = 18) +
  font("ylab", size = 18) +
  font("legend.text", size = 8)

save_plot_vector(plot_bc, file.path(data_dir, "figure_2_bc_combined"))

############################################################################
#################     COMBINED FIGURE (A/B STACKED)      ###################
############################################################################

#  Risk row
risk_row_mat <- matrix(
  c("No. at risk and\nunder follow-up", "2,107", "2,052", "1,142", "1,093", "712", "672"),
  nrow = 1, byrow = TRUE
)

risk_theme <- gridExtra::ttheme_minimal(
  core = list(
    fg_params = list(fontsize = 12, col = "black"),
    bg_params = list(fill = NA, col = NA)
  )
)

make_risk_grob <- function(){
  rg <- gridExtra::tableGrob(
    risk_row_mat,
    rows = NULL,
    cols = NULL,
    theme = gridExtra::ttheme_minimal(
      core = list(
        fg_params = list(fontsize = 12, col = "black"),
        bg_params = list(fill = NA, col = NA),
        padding   = grid::unit(c(0.5, 0.5), "mm")
      )
    )
  )
  
  rg$layout$clip <- "off"
  rg$widths <- grid::unit.c(
    grid::unit(2.65, "cm"),          # label column (controls left shift)
    rep(grid::unit(3.05, "cm"), 6)  # numeric columns (smaller = closer together)
  )
  
  rg
}

risk_grob_A <- make_risk_grob()
risk_grob_B <- make_risk_grob()

# Legend extraction (shows BOTH color and shapes in the key)
plot_for_legend <- ggplot(
  long_all,
  aes(x = factor(time), y = risk,
      group = Intervention, colour = Intervention, shape = Intervention)
) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2.5) +
  scale_color_manual(values = col_map) +
  scale_shape_manual(values = shape_map) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    legend.title = element_blank(),
    legend.text = element_text(size = 12, colour = "black")
  ) +
  guides(
    # Use ONE legend (color) and force it to also display the shapes
    colour = guide_legend(
      ncol = 1, byrow = TRUE,
      override.aes = list(
        shape = unname(shape_map[intervention_levels]),  # shapes in the same order
        linewidth = 0.8,
        size = 2.5
      )
    ),
    # Suppress separate shape legend to avoid duplication
    shape = "none"
  )

legend_grob <- ggpubr::get_legend(plot_for_legend)
if (inherits(legend_grob, "gtable")) legend_grob$layout$clip <- "off"

#  Remove legends from BOTH panels
plot_all_noleg <- plot_all + theme(legend.position = "none")
plot_bc_noleg  <- plot_bc  + theme(legend.position = "none")

# Convert plots to grobs; disable panel clipping 
gA <- ggplot_gtable(ggplot_build(plot_all_noleg))
gA$layout$clip[gA$layout$name == "panel"] <- "off"

gB <- ggplot_gtable(ggplot_build(plot_bc_noleg))
gB$layout$clip[gB$layout$name == "panel"] <- "off"

# Panel labels 
gA_labeled <- gridExtra::arrangeGrob(
  gA,
  top = grid::textGrob("A)  All-cause mortality", x = 0, just = "left",
                       gp = grid::gpar(fontsize = 18, fontface = "bold"))
)

gB_labeled <- gridExtra::arrangeGrob(
  gB,
  top = grid::textGrob("B)  breast cancer-specific mortality", x = 0, just = "left",
                       gp = grid::gpar(fontsize = 18, fontface = "bold"))
)

# Stack: A + its risk row, then B + its risk row, then legend 
combined_core <- gridExtra::arrangeGrob(
  gA_labeled,
  risk_grob_A,
  gB_labeled,
  risk_grob_B,
  legend_grob,
  ncol = 1,
  heights = c(1, 0.14, 1, 0.14, 0.46)
)

# Add left/right padding so nothing is cut off 
combined <- gridExtra::arrangeGrob(
  grid::nullGrob(), combined_core, grid::nullGrob(),
  ncol = 3,
  widths = grid::unit.c(grid::unit(0.25, "in"), grid::unit(1, "null"), grid::unit(0.25, "in"))
)

# Save combined as differnet file types 
base_combined <- file.path(data_dir, "figure_1_combined_AB")

grDevices::cairo_pdf(paste0(base_combined, ".pdf"),
                     width = 9, height = 12.6, onefile = FALSE, family = "sans")
grid::grid.newpage()
grid::grid.draw(combined)
grDevices::dev.off()

grDevices::cairo_ps(paste0(base_combined, ".eps"),
                    width = 9, height = 12.6, onefile = FALSE, family = "sans",
                    fallback_resolution = 600)
grid::grid.newpage()
grid::grid.draw(combined)
grDevices::dev.off()

if (requireNamespace("svglite", quietly = TRUE)) {
  svglite::svglite(paste0(base_combined, ".svg"), width = 9, height = 12.6)
  grid::grid.newpage()
  grid::grid.draw(combined)
  grDevices::dev.off()
}

png(paste0(base_combined, ".png"),
    width = 9, height = 12.6, units = "in", res = 600)
grid::grid.newpage()
grid::grid.draw(combined)
dev.off()
