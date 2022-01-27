library(tidyverse)
library(kableExtra)

# Read files
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

all_tests <- map_dfr(test_files, read_test)

all_tests %>% 
    group_by(classifier, dataset) %>% 
    summarise(n = n())

# Run tests

recall <- all_tests %>% 
    group_by(classifier, dataset, incivil) %>% 
    summarise(match = sum(incivil == label),
              nonmatch = sum(incivil != label),
              n = n()) %>% 
    mutate(recall = match / n) %>% 
    select(category = incivil, recall) %>% 
    ungroup()

precision <- all_tests %>% 
    group_by(classifier, dataset, label) %>% 
    summarise(match = sum(incivil == label),
              nonmatch = sum(incivil != label),
              n = n()) %>% 
    mutate(precision = match / n) %>% 
    select(category = label, precision) %>% 
    ungroup()

scores <- inner_join(recall, precision) %>% 
    mutate(f1 = (2 * recall * precision) / (recall + precision))

scores %>% 
    pivot_longer(c(recall, precision, f1), names_to = "measure") %>% 
    arrange(dataset, classifier, category, measure) %>% 
    pivot_wider(names_from = c(dataset, classifier),
                values_from = value) %>% 
    select(-category) %>% 
    kable(digits = 3) %>% 
    kable_styling(bootstrap_options = c("striped", "hover")) %>%
    pack_rows("civil", 1, 3) %>% 
    pack_rows("incivil", 4, 6)

scores %>% 
    filter(classifier != "unitary-toxic-bert") %>% 
    pivot_longer(c(recall, precision, f1), names_to = "measure") %>% 
    arrange(dataset, classifier, category, measure) %>% 
    pivot_wider(names_from = c(dataset, classifier),
                values_from = value) %>% 
    select(-category) %>% 
    write_excel_csv("classifier/test_results.csv")