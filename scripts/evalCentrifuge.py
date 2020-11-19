import sys, math

contentfile = open(sys.argv[1])
contentFile_negative = ""
if sys.argv[2] != "_":
	contentFile_negative = open(sys.argv[2])
CentrifugeInput = open(sys.argv[3])
resultfile = open(sys.argv[4], 'w')

confusionMatrixPerSpecies = {}
accToTax = {}
for line in contentfile:
	line = line.rstrip("\r\n")
	if line != "":
		line = line.split("\t")
		accToTax[line[3]] = line[1]
		confusionMatrixPerSpecies[line[1]] = [0,0,0,0] # TP,TN,FP,FN

negatives = {}
if contentFile_negative != "":
	for line in contentFile_negative:
		line = line.rstrip("\r\n")
		if line != "":
			line = line.split("\t")
			negatives[line[3]] = line[1]

sensitivity = 0.0
specificity = 0.0
numberOfReads = 0
numberOfNegReads = 0
numberOfAssigned = 0
ambigCounter = 0

dummyCounter = 1

next(CentrifugeInput)

for entry in CentrifugeInput: #this is almost the same code as in evalJson.py
	entry = entry.rstrip("\r\n")
	if entry == "":
		break
	entry = entry.split("\t")
	name = ((entry[0]).split(";"))[0]
	origTax = accToTax[name] if name in accToTax else ""
	matched = entry[2]
	numberOfReads += 1
	
	dummyCounter += 1
	
	multipleHits = int(entry[7])
	matchedTaxIDs = set()
	if entry[1] != "unclassified" and entry[1] != "species":
		matchedTaxIDs.add(matched)
	for i in range(multipleHits - 1):
		dummyCounter += 1
		nextLine = ((next(CentrifugeInput)).rstrip("\r\n")).split("\t")
		if nextLine[1] != "species":
			matchedTaxIDs.add((nextLine)[2] )
	if len(matchedTaxIDs) == 1:
		matched = next(iter(matchedTaxIDs))
	
	if origTax != "":
		if len(matchedTaxIDs) >= 2:
			numberOfAssigned += 1
			wasHit = False
			for elem in matchedTaxIDs:
				if elem == origTax:
					ambigCounter += 1
					sensitivity += 1
					confusionMatrixPerSpecies[elem][0] += 1
					wasHit = True
				else:
					#print(entry, matchedTaxIDs, dummyCounter)
					confusionMatrixPerSpecies[elem][2] += 1
			if not wasHit:
				confusionMatrixPerSpecies[origTax][3] += 1
			for spec in confusionMatrixPerSpecies:
				if spec != origTax and spec not in matchedTaxIDs:
					confusionMatrixPerSpecies[spec][1] += 1
		elif len(matchedTaxIDs) == 1:
			numberOfAssigned += 1
			if matched == origTax:
				sensitivity += 1
				confusionMatrixPerSpecies[matched][0] += 1
			else:
				confusionMatrixPerSpecies[matched][2] += 1
				confusionMatrixPerSpecies[origTax][3] += 1
			for spec in confusionMatrixPerSpecies:
				if spec != origTax and spec != matched:
					confusionMatrixPerSpecies[spec][1] += 1
		else:
			#assigned = False
			confusionMatrixPerSpecies[origTax][3] += 1
			for spec in confusionMatrixPerSpecies:
				if spec != origTax:
					confusionMatrixPerSpecies[spec][1] += 1
	else:
		if name in negatives:
			numberOfNegReads += 1
			if entry[1] == "unclassified":
				specificity += 1
				for spec in confusionMatrixPerSpecies:
					confusionMatrixPerSpecies[spec][1] += 1
			else:
				for elem in matchedTaxIDs:
					confusionMatrixPerSpecies[elem][2] += 1
				for spec in confusionMatrixPerSpecies:
					if spec not in matchedTaxIDs:
						confusionMatrixPerSpecies[spec][1] += 1
	
numberOfReads -= numberOfNegReads

precision = 0.0
f1 = 0.0
if numberOfReads > 0 and numberOfAssigned > 0:
	precision = sensitivity / numberOfAssigned
	sensitivity = sensitivity / numberOfReads
	f1 = 2*(sensitivity*precision)/(sensitivity+precision)

if numberOfNegReads > 0:
	specificity = specificity / numberOfNegReads

MetaMCC = 0.0
MCCs = []
for entry in confusionMatrixPerSpecies:
	TP = confusionMatrixPerSpecies[entry][0]
	TN = confusionMatrixPerSpecies[entry][1]
	FP = confusionMatrixPerSpecies[entry][2]
	FN = confusionMatrixPerSpecies[entry][3]
	#print(entry, TP, TN, FP, FN)
	MCC = 0
	if (TN > 0 or TP > 0) and (TP+FP)*(TP+FN)*(TN+FP)*(TN+FN) > 0:
		MCC = (TP*TN - FP*FN)/math.sqrt((TP+FP)*(TP+FN)*(TN+FP)*(TN+FN))
	MetaMCC += MCC
	MCCs.append((entry,MCC))

MetaMCC = MetaMCC / len(confusionMatrixPerSpecies)


resultfile.write("Result:\nSensitivity: " + str(sensitivity) 
+ "\nPrecision: " + str(precision) 
+ "\nSpecificity: " + str(specificity) 
+ "\nF1: " + str(f1)
+ "\nMCC: "+ str(MetaMCC) 
+ "\nAmbiguous Reads: " + str(ambigCounter) 
+ "\nNumber of Reads: " + str(numberOfReads) 
+ "\nNumber of negative Reads: " + str(numberOfNegReads) 
+ "\n\n")

resultfile.write("MCCs:\n")
for entry in MCCs:
	resultfile.write(entry[0] + "\t" + str(entry[1]) + "\n")