# Specify project path on drive
drive_path = 'classifier'

# Specify model to test
model_name = 'incivil_bert-base-uncased_4e_8b_f1'
tokenizer_name = 'bert-base-uncased'

# Load libraries
from transformers import TextClassificationPipeline, AutoTokenizer, AutoModelForSequenceClassification
from datasets import load_dataset
import time
import os
import random

# Load model and build classification pipeline
model_path = drive_path + '/models/' + model_name

model = AutoModelForSequenceClassification.from_pretrained(model_path)

tokenizer = AutoTokenizer.from_pretrained(tokenizer_name)

classifier = TextClassificationPipeline(task = 'Test classifier',
                                        model = model,
                                        tokenizer = tokenizer,
                                        device = 0)

# Classify function
def run_classifier(classifier, text_data, batch_size = 4096):
  # Iterate over test files
  for text_file in text_data.keys():

    if (text_file[0] == 'f'):
      text_col = 'message'
    else:
      text_col = 'text'

    # Get texts  
    texts = text_data[text_file][text_col]
    results = []
    print('Classifying ' + str(len(texts)) + ' texts in ' + text_file)

    time_now = time.ctime(time.time())
    print('Starting at ' + time_now)

    # Classify in batches
    for i in range(0, len(texts), batch_size):
      print('Classifying at index ' + str(i) + ' of ' + str(len(texts)) + ' at ' + time.ctime(time.time()))
      results += classifier(texts[i:i+batch_size], 
                            padding = 'max_length', 
                            truncation = True,
                            num_workers = 0)

    time_now = time.ctime(time.time())
    print('Ending at ' + time_now)
    
    # Get values
    labels = [x['label'] for x in results]
    scores = [x['score'] for x in results]

    # Add to dataset
    new_data = text_data[text_file].add_column('label', labels).add_column('score', scores)

    # Save
    new_data.to_csv(drive_path + 
                    '/classifier_results/' +
                    text_file +
                    '.csv')
    print("Saved.")

# Load texts
all_texts = os.listdir('classifier/texts')
classified_texts = os.listdir('classifier/classifier_results')
remaining = set(all_texts).symmetric_difference(set(classified_texts))

# Run classification
while (len(remaining) > 0):
  
  text_file = random.choice(list(remaining)).split('.', 1)[0]
  
  # Load texts
  classifier_data = load_dataset('csv', data_files = {
    text_file: drive_path + '/texts/' + text_file  + '.csv'
    })

  run_classifier(classifier, classifier_data)

  classified_texts = os.listdir('classifier/classifier_results')
  remaining = set(all_texts).symmetric_difference(set(classified_texts))

  

