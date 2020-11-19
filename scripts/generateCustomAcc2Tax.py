import sys, getopt, os

def gatherAccessions(argv):
	try:
		opts, args = getopt.getopt(argv, "i:a:o:", [])
	except getopt.GetoptError:
		print('Wrong input!')
	
	for opt, arg in opts:
		if opt in ("-i",):
			genomesPath = arg
		elif opt in ("-a",):
			accToTaxFile = open(arg, 'r')
		elif opt in ("-o",):
			outfile = open(arg, 'w')
			
	dictOfAccs = {}
	listOfFiles = []
	if genomesPath[-1] == '/':
		listOfFiles = os.listdir(genomesPath)
	else:
		listOfFiles.append("")
	dummys = []
	for filename in listOfFiles:
		fastaFile = open(genomesPath+filename)
		for line in fastaFile:
			if '>' in line:
				try:
					acc = ""
					if " " in line:
						numbers = ((((line.rstrip("\n")).split(' '))[0]).lstrip('>')).split('|')
						for e in numbers:
							if "." in e:
								acc = e
								break
					else:
						acc = (line.rstrip("\n")).lstrip(">")
					if acc != "":
						accwoNumber = acc.split(".")[0]
						dictOfAccs[accwoNumber] = acc
					else:
						print("No accession number found in: ", line, "Providing dummy ID later..")
						dummys.append((line.rstrip("\n")).lstrip('>'))
				except:
					print(line)
					print(inPath+filename)
					fastaFile.close()
					break
		fastaFile.close()
	
	
	print(str(len(dictOfAccs))+" accession numbers found")

	numberOfIdentified = 0
	for line in accToTaxFile:
		if numberOfIdentified >= len(dictOfAccs):
			break
		line = line.split('\t')
		if line[0] in dictOfAccs:
			dictOfAccs[line[0]] = (dictOfAccs[line[0]] , line[2])
			numberOfIdentified += 1
	
	if numberOfIdentified != len(dictOfAccs):
		print(str(len(dictOfAccs) - numberOfIdentified)+" accessions didnt get a taxid")
	
	if "CP008984" in dictOfAccs:
		dictOfAccs["CP008984"] = (dictOfAccs["CP008984"], "272556")
	
	for entry in dictOfAccs:
		if ".2" in dictOfAccs[entry][0]:
			outfile.write(entry + "\t" + entry+".1" + "\t" + dictOfAccs[entry][1] + "\t" + "\n")
		outfile.write(entry + "\t" + dictOfAccs[entry][0] + "\t" + dictOfAccs[entry][1] + "\t" + "\n")
	
gatherAccessions(sys.argv[1:])