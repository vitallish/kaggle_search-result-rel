__author__ = 'Lolhaven'
# Based off of tutorial for word2vec
# https://github.com/Eric-Xu/nycdssg_talks/blob/master/06_08_2015_word2vec/kaggle_movies_word2vec_demo.ipynb

import re
import time
import numpy as np
import pandas as pd
import logging
import nltk.data
import matplotlib.pyplot as plt

from bs4 import BeautifulSoup
from nltk.corpus import stopwords
from gensim.models import Doc2Vec
from gensim.models.doc2vec import LabeledSentence
from gensim.models.doc2vec import LabeledBrownCorpus
from sklearn.metrics import roc_curve, auc
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import SGDClassifier
from sklearn.cross_validation import train_test_split

# Read in training data
train = pd.read_csv("raw-data\\train.csv")
train_msk = np.random.rand(len(train)) <.7

df = train[train_msk]

# Clean up product title/ product description
rx_to_space = re.compile('[\\n/\|\+]')
rx_to_blank = re.compile('[#%:\(\)\"\[\]]')
rx_to_period = re.compile('[!;]')
rx2 = re.compile('[^a-zA-Z0-9_.,! #%:\\/\'\?;\|\-\\n\(\)\+\"]')


def check_string(my_str, my_regx, lengthRet = False):
    if type(my_str) is str:
        if lengthRet:
            return len(my_regx.findall(my_str))
        else:
            return my_regx.findall(my_str)
    else:
        return 0

def sub_string(my_str, my_regx, my_replace):
    if type(my_str) is not float:
        return my_regx.sub(my_replace, my_str)
    else:
        return ""

def clean_column(col):
    col = col.apply(sub_string, my_regx = rx_to_space, my_replace = " ")
    col = col.apply(sub_string, my_regx = rx_to_blank, my_replace = "")
    col = col.apply(sub_string, my_regx = rx_to_period, my_replace = ".")
    return col

sentences = clean_column(df.product_description)
test_sent = []

for index, value in sentences.iteritems():
    test_sent.append(LabeledSentence(words = value.split(), labels=['SENT_%s' % index]))

model = Doc2Vec(test_sent)