#from https://gitlab.com/ezlab/lemmi/-/blob/master/containers/kraken2/python/prepare_results.py
#LEMMI content is made available under the following license.
#The MIT License (MIT)
#Copyright (c) 2016-2017, Evgeny Zdobnov (ez@ezlab.org)
#Modified by Silvio Weging (2020)
import sys

outp=open(sys.argv[2],'w')
outp.write('# Taxonomic Profiling Output\n')
outp.write('@SampleID: ' + sys.argv[3] + '\n')
outp.write('@Version:0.9.1\n')
outp.write('@Ranks:superkingdom|phylum|class|order|family|genus|species|strain\n')
outp.write('@@TAXID\tRANK\tTAXPATH\tTAXPATHSN\tPERCENTAGE\n') # !!! TAXPATHSN\t

for line in open(sys.argv[1]):
	if line.startswith('#') or line == "\n" or line.startswith("unclassified"):
		continue
	taxid=line.split('\t')[4]
	if taxid == None:
		continue
	percentage=line.split('\t')[8].replace('%', '').strip("\n")
	rank=line.split('\t')[0]
	outp.write('%s\t%s\t%s\t%s\t%s\n' % (taxid, rank, taxid, taxid, percentage))
