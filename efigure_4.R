############################################################################
# Programmer: Emma McGee
# Date: October 27, 2024
# Purpose of Program: Create figures showing means of time-varying covariates  
#                      (eFigure 4)
############################################################################

# Load required packages

library(haven)
library(plyr)
library(ggsci)
library(ggplot2)
library(gridExtra)
library(ggpubr)
library(tibble)
library(tidyverse)
library(grid)
library(gridExtra)

# Load color palette
library(RColorBrewer)
display.brewer.all()
colors <- brewer.pal(5, "Set2")


forgraphs <- read_sas("filepath")
main.dir = "filepath"
setwd(main.dir)

head(forgraphs)
forgraphs$period <- forgraphs$period*2
forgraphs$xcond <- forgraphs$xcond*100
forgraphs$sxcond <- forgraphs$sxcond*100

forgraphs$aerobic_methr <- forgraphs$aerobic_methr*60
forgraphs$saerobic_methr <- forgraphs$saerobic_methr*60

forgraphs$wtlift_methr <- forgraphs$wtlift_methr*60
forgraphs$swtlift_methr <- forgraphs$swtlift_methr*60

### XCOND ###

# Plot
plot <- ggplot(data=forgraphs, aes(y=period)) +
  geom_point(size=3.8, color='darkblue', aes(x=sxcond)) + 
  geom_path(color='darkblue', linewidth=1.8, alpha=0.4, linetype = 2, aes(x=sxcond)) +
  geom_point(size=3.8, color='darkred', aes(x=xcond)) + 
  geom_path(color='darkred', linewidth=1.8, alpha=0.4, aes(x=xcond)) +
  scale_y_continuous(breaks=c(0, 2, 4, 6, 8, 10), 
                     limits=c(0, 10)) +
  scale_x_continuous(limits=c(0, 10)) +
  labs(title='', x='Mean', y = 'Year of follow-up') +
  coord_flip() +
  theme_classic() +
  theme(axis.text = element_text(size = 30),
        axis.title.x = element_text(size = 30, margin = margin(t = 10, r = 0, b = 0, l = 0)),
        axis.title.y = element_text(size = 30),
        legend.title = element_blank(),
        legend.position = "none",
        legend.text = element_text(size = 30))
plot

ggsave("covmean_xcond.png", width = 30, height = 20, units = "cm")


### BMI ###

# Plot
plot <- ggplot(data=forgraphs, aes(y=period)) +
  geom_point(size=3.8, color='darkblue', aes(x=slbmi)) + 
  geom_path(color='darkblue', linewidth=1.8, alpha=0.4, linetype = 2, aes(x=slbmi)) +
  geom_point(size=3.8, color='darkred', aes(x=lbmi)) + 
  geom_path(color='darkred', linewidth=1.8, alpha=0.4, aes(x=lbmi)) +
  scale_y_continuous(breaks=c(0, 2, 4, 6, 8, 10), 
                     limits=c(0, 10)) +
  scale_x_continuous(limits=c(3.2, 3.4)) +
  labs(title='', x='Mean', y = 'Year of follow-up') +
  coord_flip() +
  theme_classic() +
  theme(axis.text = element_text(size = 30),
        axis.title.x = element_text(size = 30, margin = margin(t = 10, r = 0, b = 0, l = 0)),
        axis.title.y = element_text(size = 30),
        legend.title = element_blank(),
        legend.position = "none",
        legend.text = element_text(size = 30))
plot

ggsave("covmean_lbmi.png", width = 30, height = 20, units = "cm")


### MUSCLE STRENGTHENING ACTIVITIES ###


# Plot
plot <- ggplot(data=forgraphs, aes(y=period)) +
  geom_point(size=3.8, color='darkblue', aes(x=swtlift_methr)) + 
  geom_path(color='darkblue', linewidth=1.8, alpha=0.4, linetype = 2, aes(x=swtlift_methr)) +
  geom_point(size=3.8, color='darkred', aes(x=wtlift_methr)) + 
  geom_path(color='darkred', linewidth=1.8, alpha=0.4, aes(x=wtlift_methr)) +
  scale_y_continuous(breaks=c(0, 2, 4, 6, 8, 10), 
                     limits=c(0, 10)) +
  scale_x_continuous(limits=c(0, 20)) +
  labs(title='', x='Mean', y = 'Year of follow-up') +
  coord_flip() +
  theme_classic() +
  theme(axis.text = element_text(size = 30),
        axis.title.x = element_text(size = 30, margin = margin(t = 10, r = 0, b = 0, l = 0)),
        axis.title.y = element_text(size = 30),
        legend.title = element_blank(),
        legend.position = "none",
        legend.text = element_text(size = 30))
plot

ggsave("covmean_wtlift_methr.png", width = 30, height = 20, units = "cm")



### AEROBIC ACTIVITIES ###


# Plot
plot <- ggplot(data=forgraphs, aes(y=period)) +
  geom_point(size=3.8, color='darkblue', aes(x=saerobic_methr)) + 
  geom_path(color='darkblue', linewidth=1.8, alpha=0.4, linetype = 2, aes(x=saerobic_methr)) +
  geom_point(size=3.8, color='darkred', aes(x=aerobic_methr)) + 
  geom_path(color='darkred', linewidth=1.8, alpha=0.4, aes(x=aerobic_methr)) +
  scale_y_continuous(breaks=c(0, 2, 4, 6, 8, 10), 
                     limits=c(0, 10)) +
  scale_x_continuous(limits=c(2000, 2500)) +
  labs(title='', x='Mean', y = 'Year of follow-up') +
  coord_flip() +
  theme_classic() +
  theme(axis.text = element_text(size = 30),
        axis.title.x = element_text(size = 30, margin = margin(t = 10, r = 0, b = 0, l = 0)),
        axis.title.y = element_text(size = 30),
        legend.title = element_blank(),
        legend.position = "none",
        legend.text = element_text(size = 30))
plot

ggsave("covmean_aerobic_methr.png", width = 30, height = 20, units = "cm")


