# Specify project path on drive
drive_path = 'classifier'

# Specify model to test
model_name = 'incivil_bert-base-uncased_4e_8b_f1'
#model_name = 'davidson_bert'
tokenizer_name = 'bert-base-uncased'

# Load libraries
from transformers import TextClassificationPipeline, AutoTokenizer, AutoModelForSequenceClassification
from datasets import load_dataset

# Load model and build pipeline
model_path = drive_path + '/models/' + model_name

model = AutoModelForSequenceClassification.from_pretrained(model_path)

tokenizer = AutoTokenizer.from_pretrained(tokenizer_name)

classifier = TextClassificationPipeline(task = 'Test classifier',
                                        model = model,
                                        tokenizer = tokenizer,
                                        device = 0)

# Load test data
test_data = load_dataset('csv', data_files = {
    'coe': drive_path + '/test_files/' + 'test_coe.csv',
    'davidson': drive_path + '/test_files/' + 'test_davidson.csv',
    'theocharis': drive_path + '/test_files/' + 'test_theocharis.csv',
    'own': drive_path + '/test_files/' + 'test_own.csv'
    })

# Run tests
def run_tests(classifier, test_data, batch_size = 32):
  # Iterate over test files
  for test_file in test_data.keys():
    print('Running test for ' + test_file)

    # Get texts  
    texts = test_data[test_file]['text']
    results = []

    # Classify in batches
    for i in range(0, len(texts), batch_size):
      results += classifier(texts[i:i+batch_size], 
                            padding = 'max_length', 
                            truncation = True,
                            num_workers = 0)
    
    # Get values
    labels = [x['label'] for x in results]
    scores = [x['score'] for x in results]

    # Add to dataset
    new_data = test_data[test_file].add_column('label', labels).add_column('score', scores)

    # Save
    new_data.to_csv(drive_path + 
                    '/test_results/results_' +
                    model_name + 
                    '_' + 
                    test_file +
                    '.csv')
    print("Saved.")

run_tests(classifier, test_data)