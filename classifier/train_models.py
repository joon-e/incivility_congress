# Specify project path on Drive
drive_path = '/content/drive/MyDrive/incivility'

# Specify model to train
model_name = 'bert-base-uncased'
tokenizer_name = 'bert-base-uncased'

# Load libraries
from transformers import (TextClassificationPipeline, AutoTokenizer, 
                          AutoModelForSequenceClassification, TrainingArguments, 
                          Trainer)
from datasets import load_dataset, load_metric
import numpy as np
import torch

data = load_dataset('csv', data_files = drive_path + '/train_files/train_full.csv')

data = data['train'].train_test_split(test_size = 0.1,
                                      shuffle = True,
                                      seed = 80085)

train_texts = data['train']['text']
eval_texts = data['test']['text']

train_labels = [0 if x == 'civil' else 1 for x in data['train']['incivil']]
eval_labels = [0 if x == 'civil' else 1 for x in data['test']['incivil']]

tokenizer = AutoTokenizer.from_pretrained(tokenizer_name)

train_encodings = tokenizer(train_texts, 
                            truncation = True, 
                            padding = 'max_length',
                            max_length = 256)
eval_encodings = tokenizer(eval_texts, 
                           truncation = True, 
                           padding = 'max_length',
                           max_length = 256)

class IncivilityData(torch.utils.data.Dataset):
  def __init__(self, encodings, labels):
    self.encodings = encodings
    self.labels = labels
  
  def __getitem__(self, idx):
    item = {key: torch.tensor(val[idx]) for key, val in self.encodings.items()}
    item['labels'] = torch.tensor(self.labels[idx])
    return item

  def __len__(self):
    return len(self.labels)

train_dataset = IncivilityData(train_encodings, train_labels)
eval_dataset = IncivilityData(eval_encodings, eval_labels)

# Build model
# Define arguments
n_epochs = 4
train_batch_size = 16
eval_batch_size = 16
eval_metric = 'precision'

label2id = {
    "incivil": 1,
    "civil": 0
  }

id2label = {
    1: "incivil",
    0: "civil"
  }

model = AutoModelForSequenceClassification.from_pretrained(model_name, num_labels=2, label2id = label2id, id2label = id2label)

training_args = TrainingArguments(
    output_dir=drive_path + '/models/checkpoints',          
    num_train_epochs=n_epochs,              
    per_device_train_batch_size=train_batch_size,  
    per_device_eval_batch_size=eval_batch_size,   
    warmup_steps=500,                
    weight_decay=0.01,               
    logging_dir='./logs',            
    logging_steps=1000,
    evaluation_strategy='epoch',
    save_strategy='epoch'
)

metric = load_metric(eval_metric)

def compute_metrics(eval_pred):
    logits, labels = eval_pred
    predictions = np.argmax(logits, axis=-1)
    return metric.compute(predictions=predictions, references=labels)

trainer = Trainer(
    model=model,                         
    args=training_args,                  
    train_dataset=train_dataset,         
    eval_dataset=eval_dataset,
    compute_metrics=compute_metrics
)

trainer.train(resume_from_checkpoint = True)

final_model_name = "incivil_full_{}-{}e-{}b-{}".format(model_name, 
                                                  n_epochs,
                                                  train_batch_size,
                                                  eval_metric)

trainer.save_model(drive_path + '/models/' + final_model_name)