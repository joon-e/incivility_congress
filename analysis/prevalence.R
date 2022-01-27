library(tidyverse)
library(tidycomm)

# Load
all <- readRDS("analysis/data/analysis_data.rds")

# Prevalence in original posts
prev_org <- all %>% 
    distinct(post_id, .keep_all = TRUE) %>% 
    tab_frequencies(incivil)
prev_org

mat_org <- matrix(pull(prev_org, percent))

# Prevalence in all posts
prev_posts <- all %>% 
    tab_frequencies(label)
prev_posts

mat_posts <- matrix(pull(prev_posts, percent))


# Misclassification correction

## Preferred standard
test_files <- list.files("classifier/test_results",
                         full.names = TRUE)

read_test <- function(file_path) {
    df <- read_csv(file_path)
    
    source <- str_match(file_path, "(results)_([\\w-]*)_([\\w]*)")
    df %>% 
        select(combined_id, incivil, label, score) %>% 
        mutate(classifier = source[[3]], 
               dataset = source[[4]])
    
    
}

all_tests <- map_dfr(test_files, read_test) %>% 
    filter(classifier == "incivil_bert-base-uncased_4e_8b_f1", 
           dataset == "own")

mcm_ps <- prop.table(table(all_tests$label, all_tests$incivil), margin = 2)

solve(mcm_ps) %*% mat_posts


## Maximum accuracy
acc <- all_tests %>% 
    summarise(acc = sum(incivil == label) / n()) %>% 
    pull(acc)

max_acc <- (1 + acc) / 2

mcm_ma <- matrix(c(max_acc, 1 - max_acc, 1 - max_acc, max_acc), nrow = 2)

solve(mcm_ma) %*% mat_posts


# By post
all %>% 
    group_by(post_id) %>% 
    summarise(share = mean(label)) %>% 
    describe(share)

# By author
all %>% 
    group_by(person_id) %>% 
    summarise(share = mean(label)) %>% 
    describe(share)

# By date
all %>% 
    group_by(num_date) %>% 
    summarise(share = mean(label)) %>% 
    describe(share)
