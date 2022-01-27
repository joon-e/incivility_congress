# Patterns of Incivility on U.S. Congress Members’ Social Media Accounts

Replication data and code for [Frontiers in Political Science](https://www.frontiersin.org/journals/political-science) submission "Patterns of Incivility on U.S. Congress Members’ Social Media Accounts: A Comprehensive Analysis of the Influence of Platform, Post, and Person Characteristics".

The full _U.S. Congress Social Media Posts and Comments Sample_ described in the manuscript (section 3.1.1 and Table 1) will be provided upon request, but cannot be shared publicly due to copyright restrictions.

## Classifier

The `classifier` folder contains the final BERT text classification model, `models/incivil_bert-base-uncased_4e_8b_f1`. 

We also provide replication scripts used for training and evaluating the classifier as well as classifying texts for incivility with said classifier (section 3.1.2 in the manuscript). 

- `train_models.py` for model training. Training files should be placed in a `train_files` sub-folder.
- `test_models.py` for model testing on various test data sets. Test files should be placed in the `test_files` sub-folder; test results will be written to the `test_results` sub-folder.
- `compare_classifiers.R` to calculate evaluation measures as reported in Table 2.
- `classify_texts.py` to classify texts for incivility. Texts to classify should be placed in a `texts` sub-folder as CSV files containing an `id` and `text` column. Classification results will be written to a `classifier_results` sub-folder.

Please use the provided `requirements.txt` to install all necessary Python modules.

However, please note that we are not able to share all training and test data due to the classifier being trained on third-party data, namely data from the following three studies:

- Coe, K., Kenski, K., & Rains, S. A. (2014). Online and uncivil? Patterns and determinants of incivility in newspaper website comments. _Journal of Communication, 64_(4), 658–679. https://doi.org/10.1111/jcom.12104

- Davidson, S., Sun, Q., & Wojcieszak, M. (2020). Developing a new classifier for automated identification of incivility in social media. _Proceedings of the Fourth Workshop on Online Abuse and Harms_, 95–101. https://doi.org/10.18653/v1/2020.alw-1.12

- Theocharis, Y., Barberá, P., Fazekas, Z., & Popa, S. A. (2020). The dynamics of political incivility on Twitter. _SAGE Open, 10_(2), 1–15. https://doi.org/10.1177/2158244020919447

We will share training data upon request if data sharing agreements with the authors of said papers can be attested.

## Analysis

The `analysis` folder contains all scripts necessary to replicate the incivility prediction model: 

- `descriptives.R` for sample descriptives.
- `prevalence.R` for incivility prevalence analysis (section 4.1.1 in the manuscript)
- `model.R` to estimate and summarize the prediction model (section 4.1.2 and Table 3 in the manuscript).
- `plot.R` to replicate Figure 1 in the manuscript based on model output.

Please note that we do not include the full model file on GitHub due to size constraints. We will provide the model file upon request.
