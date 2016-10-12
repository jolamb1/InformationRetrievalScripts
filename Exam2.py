import sys
import re
import os
import math
from decimal import *
import time
getcontext().prec = 10

def tf(docs):
	tfOutd = {}
	for doc in docs:
		tfOutd[doc] = {}
		totalWords = 0;
		for word in docs[doc]:
			totalWords += docs[doc][word]
		
		for word2 in docs[doc]:
			tfOutd[doc][word2] = float(docs[doc][word2])/float(totalWords)
			

	return tfOutd 


def idf(docs):
	
	idfOutD = {}
	docList = docs.keys()
	numDocs = len(docList)

	for doc in docs:
		words = docs[doc].keys()
		for word in words:
			if idfOutD.has_key(word):
				idfOutD[word] += 1
			else :
				idfOutD[word] = 1
	for term in idfOutD:
		idfOutD[term] = float(idfOutD[term]) / float(numDocs)
		idfOutD[term] = math.log(idfOutD[term])
		
		

	return idfOutD

def tfidf(tf, idf):
	getcontext().prec = 10
	tfidfOutD = {}
	
	for doc in tf:
		
		tfidfOutD[doc] = {}
		terms = tf[doc].keys()
		for word in terms:
			
			tfidfOutD[doc][word] = float(tf[doc][word]) * float(idf[word])
	return tfidfOutD

if len(sys.argv) != 2:
	print "Usage: python Exam2.py commandFile"
	sys.exit


commandReader = open(sys.argv[1],'rb')
values = {}

for line in commandReader:
	line = line.rstrip()
	if line[0] == '#':
		continue
	else:
		lineParts = line.split(':')	

		if not values.has_key(lineParts[0]):
			values[lineParts[0]] = lineParts[1]
		else:
			pass

commandReader.close()

valueKeys = values.keys()
fileDir = ''
tfOutput = ''
idfOutput = ''
tfidfOutput=''


for name in valueKeys:
	if name == 'filedir':
		fileDir = values[name]
	elif name == 'tfoutput':
		tfOutput = values[name]
	elif name == 'idfoutput':
		idfOutput = values[name]
	elif name == 'tf-idfoutput':
		tfidfOutput = values[name]

os.chdir(fileDir)

files = os.listdir(fileDir)

corpus = {}

for doc in files:
	corpus[doc] = {}
	with open(doc,'rb') as f:
		docReader = f
		for line in docReader:
			words = re.split('[\s|\.|\!|\?|\-|,|"| ]+',line)
			
			for word in words:
				temp = word.upper()
				if corpus[doc].has_key(temp):
					corpus[doc][temp] += 1
				else:
					corpus[doc][temp] = 1

with open(tfOutput,'w') as tfout:
	tfWriter = tfout
	tfResults = tf(corpus)
	for document in tfResults:
		terms = tfResults[document].keys()		
		for term in terms:
			
			outStr = str(document)+','+str(term)+','+',%.10f' % float(tfResults[document][term])
			
			tfout.write(outStr+'\n')
	print 'tf done'
	
	with open(idfOutput,'w') as idfout:
		idfWriter = idfout
		idfResults = idf(corpus)
		for entry in idfResults:
			outStr = str(entry)+',%.10f'% idfResults[entry]			
			idfout.write(outStr+'\n')
		print 'idf done'
		
		with open(tfidfOutput,'w') as tfidfout:
			tfidfWriter = tfidfout
			tfidfResults = tfidf(tfResults,idfResults)
			for document in tfidfResults:
				words = tfidfResults[document].keys()
				for word in words:
					outStr = str(document)+','+str(word)+',%.10f'% tfidfResults[document][word]
		
					tfidfWriter.write(outStr+'\n')
			print 'tfidf done'
			
