library(tidyverse)

all <- readRDS("analysis/data/analysis_data_full.rds")

# Persons
all %>% 
    distinct(person_id)

# Platforms
all %>% 
    count(platform)

# Posts
all %>% 
    group_by(platform) %>% 
    count(post_id) %>% 
    summarise(n = n())

# Accounts
all %>% 
    group_by(platform) %>%
    distinct(person_id) %>% 
    summarise(n = n())
    