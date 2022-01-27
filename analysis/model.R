library(tidyverse)
library(lme4)
library(splines)
library(easystats)

# Optimizer settings
settings = glmerControl(optimizer = "nloptwrap",
                        optCtrl = list(algorithm = "NLOPT_LN_BOBYQA"),
                        calc.derivs = FALSE)

# Load analysis data
df <- readRDS("analysis/data/analysis_data_full.rds")

# Main model
tictoc::tic()
m1 <- glmer(label ~ platform + incivil + bs(reach) + bs(num_date) +
                party + female + lgbt + non_white + 
                age + new_member + type + post_freq +
                (1 | person_id/post_id),
            data = df,
            family = "binomial",
            control = settings,
            nAGQ = 0)

tictoc::toc()

saveRDS(m1, "analysis/output/model_full.rds")

m1 <- readRDS("analysis/output/model_full.rds")


# Response means
## Hypothesized effects
resp_date <- estimate_means(m1, at = "num_date", length = 365, rg.limit = 100000,
                            transform = "response", ci = 0.99,
                            factors = "all", numerics = "median")
write_csv(resp_date, "analysis/output/resp_date_full.csv")
rm(resp_date)
gc()

resp_reach <- estimate_means(m1, at = "reach", length = 100, rg.limit = 30000,
                             transform = "response", ci = 0.99, 
                             factors = "all", numerics = "median")
write_csv(resp_reach, "analysis/output/resp_reach_full.csv")
rm(resp_reach)
gc()

resp_party <- estimate_means(m1, at = "party", transform = "response", ci = 0.99,
                             factors = "all", numerics = "median")
write_csv(resp_party, "analysis/output/resp_party_full.csv")
rm(resp_party)
gc()

resp_platform <- estimate_means(m1, at = "platform", transform = "response", ci = 0.99,
                                factors = "all", numerics = "median")
write_csv(resp_platform, "analysis/output/resp_platform_full.csv")
rm(resp_platform)
gc()

resp_incivil <- estimate_means(m1, at = "incivil", transform = "response", ci = 0.99,
                               factors = "all", numerics = "median")
write_csv(resp_incivil, "analysis/output/resp_incivil_full.csv")
rm(resp_incivil)
gc()

resp_female <- estimate_means(m1, at = "female", transform = "response", ci = 0.99,
                              factors = "all", numerics = "median")
write_csv(resp_female, "analysis/output/resp_female_full.csv")
rm(resp_female)
gc()

resp_lgbt <- estimate_means(m1, at = "lgbt", transform = "response", ci = 0.99,
                            factors = "all", numerics = "median")
write_csv(resp_lgbt, "analysis/output/resp_lgbt_full.csv")
rm(resp_lgbt)
gc()

resp_non_white <- estimate_means(m1, at = "non_white", transform = "response", ci = 0.99,
                                 factors = "all", numerics = "median")
write_csv(resp_non_white, "analysis/output/resp_non_white_full.csv")
rm(resp_non_white)
gc()

## Controls
resp_age <- estimate_means(m1, at = "age", length = max(df$age) - min(df$age), rg.limit = 25000,
                           transform = "response", ci = 0.99,
                           factors = "all", numerics = "median")
write_csv(resp_age, "analysis/output/resp_age_full.csv")
rm(resp_age)
gc()

resp_post_freq <- estimate_means(m1, at = "post_freq", length = 100, rg.limit = 30000,
                                 transform = "response", ci = 0.99,
                                 factors = "all", numerics = "median")
write_csv(resp_post_freq, "analysis/output/resp_post_freq_full.csv")
rm(resp_post_freq)
gc()

resp_new_member <- estimate_means(m1, at = "new_member", transform = "response", ci = 0.99,
                                  factors = "all", numerics = "median")
write_csv(resp_new_member, "analysis/output/resp_new_member_full.csv")
rm(resp_new_member)
gc()

resp_type <- estimate_means(m1, at = "type", transform = "response", ci = 0.99,
                            factors = "all", numerics = "median")
write_csv(resp_type, "analysis/output/resp_type_full.csv")
rm(resp_type)
gc()

# Model parameters
r2 <- r2_nakagawa(m1)
saveRDS(r2, "analysis/output/r2_full.rds")

coefs <- exp(fixef(m1))
saveRDS(coefs, "analysis/output/coefs.rds")

confs <- exp(confint.merMod(m1, level = .99, method = "Wald"))
saveRDS(confs, "analysis/output/confs_wald_full.rds")
