from pickle import GLOBAL
import tensorflow as tf
import string
import re
from tensorflow.keras.layers.experimental.preprocessing import TextVectorization

def custom_standardization(input_data):
  lowercase = tf.strings.lower(input_data)
  stripped_html = tf.strings.regex_replace(lowercase, '<br />', ' ')
  return tf.strings.regex_replace(stripped_html,
                                  '[%s]' % re.escape(string.punctuation), '')
  
vocab = ["baseball", "basketball"] #entire vocab list for interest

#Vocabulary size and number of words in a sequence.
vocab_size = 10000
embedding_dim = 5
sequence_length = 100

vectorize_layer = TextVectorization(
    standardize=custom_standardization,
    max_tokens=vocab_size,
    output_mode='int',
    output_sequence_length=sequence_length
)

vectorize_layer.adapt(vocab)

embeddingLayer = tf.keras.layers.Embedding(vocab_size, embedding_dim)

#input: age, sex and interest 
#arch:
# --> text(intrests)
# --> embedding(text) 
# concatonate (age and sex)
# dense layer 
# category neurone
#output: an index for classification 
model = tf.keras.Sequential([
  vectorize_layer,
  embeddingLayer,
  tf.keras.layers.GlobalAveragePooling1D(),
  tf.keras.layers.Dense(16, activation='relu'),
  tf.keras.layers.Dense(1)
  ])

print(model.summary())



