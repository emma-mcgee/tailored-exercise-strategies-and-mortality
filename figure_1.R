############################################################################
# Programmer: Emma McGee 
# Date: October 27, 2024
# Purpose of Program: Create adjusted risk curves (Figure 1 - Challenge)
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

############################################################################
#################             OVERALL MORTALITY          ###################
############################################################################

forgraphs <- read_sas("filepath/results/forgraphs_all_mort_challenge.sas7bdat")
main.dir  <- "filepath/results"
setwd(main.dir)

forgraphs_final <- forgraphs
forgraphs_final$risk0 <- 1 - forgraphs_final$surv0

###### FORMAT DATA ######

### Point estimates (No intervention + 2 interventions)
frame1 <- forgraphs_final[c(2,5,8)]

frame2 <- frame1
names(frame2) <- c("No intervention",
                   "Health education intervention",
                   "Recreational aerobic exercise intervention")

frame3min3 <- as_tibble(frame2)
long_pe <- gather(frame3min3, Intervention, survprob,
                  `No intervention`:`Recreational aerobic exercise intervention`,
                  factor_key = TRUE)
long_pe$risk <- 1 - long_pe$survprob

# Combine with time (0,2,4,6,8)
time <- c(0,2,4,6,8)
long <- cbind(time, long_pe)

# Rows 1:5 = No intervention, 6:10 = Health education, 11:15 = Recreational
long_plot <- long[c(6:15), ]

# Ensure consistent ordering
intervention_levels <- c("Health education intervention",
                         "Recreational aerobic exercise intervention")
long_plot$Intervention <- factor(long_plot$Intervention, levels = intervention_levels)

############################################################################
#################     STYLE: COLORS & SHAPES (NOT Fig 2) ###################
############################################################################

# colors & shapes 
col_map <- c(
  "Health education intervention" = "#CC79A7",              # purple
  "Recreational aerobic exercise intervention" = "#4D4D4D"  # gray
)

shape_map <- c(
  "Health education intervention" = 18,  # diamond
  "Recreational aerobic exercise intervention" = 8   # star
)

############################################################################
#################                 MAIN PLOT               ###################
############################################################################

plot1 <- ggplot(long_plot,
                aes(x = factor(time), y = risk,
                    group = Intervention, colour = Intervention, shape = Intervention)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2.5) +
  scale_color_manual(values = col_map) +
  scale_shape_manual(values = shape_map) +
  scale_y_continuous(breaks = c(0, 0.05, 0.1, 0.15, 0.2, 0.25),
                     limits = c(0, 0.27),
                     labels = c("0%","5%","10%","15%","20%","25%")) +
  ylab("All-cause mortality (%)") +
  xlab("Year of follow-up") +
  theme_minimal() +
  theme(axis.text = element_text(size = 18, colour = "black"),
        axis.line.y = element_line(colour = "black"),
        axis.line.x = element_line(colour = "black"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.y = element_blank(),
        panel.grid.major.y = element_blank(),
        legend.position = "none",
        axis.ticks.x = element_line(linewidth = 0.8),
        axis.ticks.y = element_line(linewidth = 0.8),
        axis.ticks.length = unit(5, "pt")) +
  font("xlab", size = 18) +
  font("ylab", size = 18)

############################################################################
#################     RISK ROW + LEGEND (IN-FIGURE)      ###################
############################################################################

# Risk row 
risk_counts <- c("959", "917", "466", "435", "269")

risk_row_mat <- matrix(
  c("No. at risk and\nunder follow-up", risk_counts),
  nrow = 1, byrow = TRUE
)

risk_theme <- gridExtra::ttheme_minimal(
  core = list(
    fg_params = list(fontsize = 12, col = "black"),
    bg_params = list(fill = NA, col = NA),
    padding   = grid::unit(c(0.8, 0.8), "mm")
  )
)

make_risk_grob <- function(){
  rg <- gridExtra::tableGrob(risk_row_mat, rows = NULL, cols = NULL, theme = risk_theme)
  rg$layout$clip <- "off"
  
  # Column widths
  rg$widths <- grid::unit.c(
    grid::unit(2.5, "cm"),
    rep(grid::unit(3.65, "cm"), 5)
  )
  rg
}

risk_grob <- make_risk_grob()

# Legend grob that shows BOTH colors + shapes
plot_for_legend <- ggplot(long_plot,
                          aes(x = factor(time), y = risk,
                              group = Intervention, colour = Intervention, shape = Intervention)) +
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
    colour = guide_legend(
      ncol = 1, byrow = TRUE,
      override.aes = list(
        shape = unname(shape_map[intervention_levels]),
        linewidth = 0.8,
        size = 2.5
      )
    ),
    shape = "none"
  )

legend_grob <- ggpubr::get_legend(plot_for_legend)
if (inherits(legend_grob, "gtable")) legend_grob$layout$clip <- "off"

############################################################################
#################       ASSEMBLE FINAL FIGURE GROB       ###################
############################################################################

# Turn plot into gtable; disable panel clipping
gt_plot <- ggplot_gtable(ggplot_build(plot1))
gt_plot$layout$clip[gt_plot$layout$name == "panel"] <- "off"

# Stack: plot + risk row + legend
fig1_core <- gridExtra::arrangeGrob(
  gt_plot,
  risk_grob,
  legend_grob,
  ncol = 1,
  heights = c(1, 0.14, 0.25)
)

# Add left/right padding so nothing is cut off
fig1_final <- gridExtra::arrangeGrob(
  grid::nullGrob(), fig1_core, grid::nullGrob(),
  ncol = 3,
  widths = grid::unit.c(grid::unit(0.25, "in"), grid::unit(1, "null"), grid::unit(0.25, "in"))
)

############################################################################
#################               SAVE OUTPUTS              ###################
############################################################################

base_out <- file.path(main.dir, "figure_1_challenge_SER_updated")

# PDF 
grDevices::cairo_pdf(paste0(base_out, ".pdf"),
                     width = 9, height = 6.8, onefile = FALSE, family = "sans")
grid::grid.newpage()
grid::grid.draw(fig1_final)
grDevices::dev.off()

# EPS
grDevices::cairo_ps(paste0(base_out, ".eps"),
                    width = 9, height = 6.8, onefile = FALSE, family = "sans",
                    fallback_resolution = 600)
grid::grid.newpage()
grid::grid.draw(fig1_final)
grDevices::dev.off()

# SVG
if (requireNamespace("svglite", quietly = TRUE)) {
  svglite::svglite(paste0(base_out, ".svg"), width = 9, height = 6.8)
  grid::grid.newpage()
  grid::grid.draw(fig1_final)
  grDevices::dev.off()
}

# PNG
png(paste0(base_out, ".png"),
    width = 9, height = 6.8, units = "in", res = 600)
grid::grid.newpage()
grid::grid.draw(fig1_final)
dev.off()
