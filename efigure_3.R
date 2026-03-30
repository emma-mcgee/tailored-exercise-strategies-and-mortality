############################################################################
# Programmer: Emma McGee
# Date: October 27, 2024
# Purpose of Program: Create dose response curve of risk differences (eFigure3)
############################################################################

# Load required packages

library("readxl")
library(ggplot2)
library("grid")
library(RColorBrewer)

# Check color names
f <- function(pal) brewer.pal(brewer.pal.info[pal, "maxcolors"], pal)
(cols <- f("RdYlBu"))

# Set working directory
main.dir = "filepath"
setwd(main.dir)

#load data
df_b <- read_excel("filepath")


#create forest plot - RD
plot_p_rd <- ggplot(data=df_b, aes(y=act, x=rd, xmin=ll_ci, xmax=ul_ci)) +
  geom_point(size=3.8, color='deepskyblue3') + 
  geom_line(color='deepskyblue3', linewidth=1.8, alpha=0.4) +
  geom_errorbarh(height=.24, linewidth=1.8, color='deepskyblue3') +
  annotate("text", x = -0.2, y = 100, label = "-1.0", size = 7, color='deepskyblue3') +
  annotate("text", x = -0.7, y = 200, label = "-1.9", size = 7, color='deepskyblue3') +
  annotate("text", x = -1.2, y = 300, label = "-2.5", size = 7, color='deepskyblue3') +
  annotate("text", x = -1.6, y = 400, label = "-3.1", size = 7, color='deepskyblue3') +
  scale_x_continuous(breaks=c(-4.5, -4, -3.5, -3, -2.5, -2, -1.5, -1, -0.5, 0), 
                     limits=c(-4.6, 0)) +
  scale_y_continuous(breaks=c(0, 100, 200, 300, 400)) +
  labs(title='', x='Risk difference (percentage points)', y = 'Increase in total aerobic activity (MET-minutes/week)') +
  coord_flip() +
  geom_hline(yintercept=150, color='black', linetype='dashed', alpha=0.4) +
  theme_classic() +
  theme(axis.text = element_text(size = 30),
        axis.title.x = element_text(size = 30, margin = margin(t = 10, r = 0, b = 0, l = 0)),
        axis.title.y = element_text(size = 30),
        legend.title = element_blank(),
        legend.position = "none",
        legend.text = element_text(size = 30))
plot_p_rd

ggsave("dose_response_figure_all_mort.png", width = 30, height = 20, units = "cm")



# BREAST CANCER SPECIFIC


#load data
df_b <- read_excel("filepath")


#create forest plot - RD
plot_p_rd <- ggplot(data=df_b, aes(y=act, x=rd, xmin=ll_ci, xmax=ul_ci)) +
  geom_point(size=3.8, color='orange') + 
  geom_line(color='orange', linewidth=1.8, alpha=0.4) +
  geom_errorbarh(height=.24, linewidth=1.8, color='orange') +
  annotate("text", x = 0, y = 100, label = "-0.9", size = 6, color='orange') +
  annotate("text", x = -0.3, y = 200, label = "-1.5", size = 6, color='orange') +
  annotate("text", x = -0.6, y = 300, label = "-2.0", size = 6, color='orange') +
  annotate("text", x = -0.8, y = 400, label = "-2.4", size = 6, color='orange') +
  scale_x_continuous(breaks=c(-4.5, -4, -3.5, -3, -2.5, -2, -1.5, -1, -0.5, 0), 
                     limits=c(-4.6, 0)) +
  scale_y_continuous(breaks=c(0, 100, 200, 300, 400)) +
  labs(title='', x='Risk difference (percentage points)', y = 'Increase in total aerobic activity (MET-minutes/week)') +
  coord_flip() +
  geom_hline(yintercept=150, color='black', linetype='dashed', alpha=0.4) +
  theme_classic() +
  theme(axis.text = element_text(size = 30),
        axis.title.x = element_text(size = 30, margin = margin(t = 10, r = 0, b = 0, l = 0)),
        axis.title.y = element_text(size = 30),
        legend.title = element_blank(),
        legend.position = "none",
        legend.text = element_text(size = 30))
plot_p_rd

ggsave("dose_response_figure_bc_mort.png", width = 30, height = 20, units = "cm")

