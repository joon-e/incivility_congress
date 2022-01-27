library(tidyverse)
library(patchwork)
library(lubridate)

theme_set(theme_bw() +
              theme(panel.grid.major.x = element_blank(),
                    panel.grid.minor = element_blank(),
                    text = element_text(size = 9),
                    axis.text = element_text(size = 9)))

# Read
resp_date <- read_csv("analysis/output/resp_date_full.csv")
resp_female <- read_csv("analysis/output/resp_female_full.csv")
resp_incivil <- read_csv("analysis/output/resp_incivil_full.csv")
resp_lgbt <- read_csv("analysis/output/resp_lgbt_full.csv")
resp_non_white <- read_csv("analysis/output/resp_non_white_full.csv")
resp_party <- read_csv("analysis/output/resp_party_full.csv")
resp_platform <- read_csv("analysis/output/resp_platform_full.csv")
resp_reach <- read_csv("analysis/output/resp_reach_full.csv")

# Individual plots

ylims <- c(0.1, .25)
ybreaks <- seq(ylims[1], ylims[2], .025)

# Date
p_date <- resp_date %>% 
    ggplot(aes(x = as_date(num_date, origin = "2020-07-01"),
               y = Probability,
               ymin = CI_low,
               ymax = CI_high)) +
    geom_line() +
    geom_ribbon(alpha = .3) +
    scale_y_continuous(name = NULL, limits = ylims, breaks = ybreaks,
                       labels = scales::label_percent(accuracy = 0.1),
                       expand = c(0,0)) +
    scale_x_date(name = "Date", expand = c(0,0), 
                 date_labels = "%b %y",
                 breaks = seq(from = as_date("2020-08-01"),
                              to = as_date("2021-07-01"),
                              by = "3 months"))

# Reach
p_reach <- resp_reach %>% 
    ggplot(aes(x = 10^reach,
               y = Probability,
               ymin = CI_low,
               ymax = CI_high)) +
    geom_line() +
    geom_ribbon(alpha = .3) +
    scale_y_continuous(name = NULL, limits = ylims, breaks = ybreaks,
                       labels = scales::label_percent(accuracy = 0.1), 
                       expand = c(0,0)) +
    scale_x_log10(name = "Reach", breaks = c(0, 1, 10, 100, 1000, 10000, 100000),
                  labels = scales::label_comma(accuracy = 1),
                  expand = c(0,0))

# Platform
p_platform <- resp_platform %>% 
    ggplot(aes(x = platform,
               y = Probability,
               ymin = CI_low,
               ymax = CI_high)) +
    geom_pointrange(shape = 19) +
    scale_y_continuous(name = NULL, limits = ylims, breaks = ybreaks,
                       labels = scales::label_percent(accuracy = 0.1),
                       expand = c(0,0)) +
    scale_x_discrete(name = "Platform")

# Incivil
p_incivil <- resp_incivil %>% 
    ggplot(aes(x = incivil,
               y = Probability,
               ymin = CI_low,
               ymax = CI_high)) +
    geom_pointrange(shape = 19) +
    scale_y_continuous(name = NULL, limits = ylims, breaks = ybreaks,
                       labels = scales::label_percent(accuracy = 0.1),
                       expand = c(0,0)) +
    scale_x_discrete(name = "Civility (Original Post/Tweet)")

# Party
p_party <- resp_party %>% 
    ggplot(aes(x = party,
               y = Probability,
               ymin = CI_low,
               ymax = CI_high)) +
    geom_pointrange(shape = 19) +
    scale_y_continuous(name = NULL, limits = ylims, breaks = ybreaks,
                       labels = scales::label_percent(accuracy = 0.1),
                       expand = c(0,0)) +
    scale_x_discrete(name = "Party")

# Gender
p_female <- resp_female %>% 
    ggplot(aes(x = female,
               y = Probability,
               ymin = CI_low,
               ymax = CI_high)) +
    geom_pointrange(shape = 19) +
    scale_y_continuous(name = NULL, limits = ylims, breaks = ybreaks,
                       labels = scales::label_percent(accuracy = 0.1),
                       expand = c(0,0)) +
    scale_x_discrete(name = "Gender")

# Sexuality
p_lgbt <- resp_lgbt %>% 
    ggplot(aes(x = lgbt,
               y = Probability,
               ymin = CI_low,
               ymax = CI_high)) +
    geom_pointrange(shape = 19) +
    scale_y_continuous(name = NULL, limits = ylims, breaks = ybreaks,
                       labels = scales::label_percent(accuracy = 0.1),
                       expand = c(0,0)) +
    scale_x_discrete(name = "Sexual Orientation")


# Ethnicity
p_non_white <- resp_non_white %>% 
    ggplot(aes(x = non_white,
               y = Probability,
               ymin = CI_low,
               ymax = CI_high)) +
    geom_pointrange(shape = 19) +
    scale_y_continuous(name = NULL, limits = ylims, breaks = ybreaks,
                       labels = scales::label_percent(accuracy = 0.1),
                       expand = c(0, 0)) +
    scale_x_discrete(name = "Ethnicity")


# Combine

(p_platform + p_incivil) / 
    (p_date + p_reach) / 
    (p_party + p_non_white) / 
    (p_female + p_lgbt)

ggsave("analysis/figures/fig_probabilities_full.jpg",
       device = "jpg",
       dpi = 300,
       width = 17.25,
       height = 20.05,
       units = "cm")

ggsave("analysis/figures/fig_probabilities_full.pdf",
       device = "pdf",
       dpi = 300,
       width = 17.25,
       height = 20.05,
       units = "cm")

