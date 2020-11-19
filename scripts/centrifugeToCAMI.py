#from https://gitlab.com/ezlab/lemmi/-/blob/master/containers/centrifuge/prepare_results.py
#LEMMI content is made available under the following license.
#The MIT License (MIT)
#Copyright (c) 2016-2017, Evgeny Zdobnov (ez@ezlab.org)
#Modified by Silvio Weging (2020)
import sys

outp=open(sys.argv[2], 'w')
all_abu={}
ranks={}
ranks_header = '@Ranks:superkingdom|phylum|class|order|family|genus|species\n'
outp.write('# Taxonomic Profiling Output\n')
outp.write('@SampleID: ' + sys.argv[3] +'\n')
outp.write('@Version:0.9.1\n')
outp.write(ranks_header)
outp.write('@@TAXID\tRANK\tTAXPATH\tTAXPATHSN\tPERCENTAGE\n')
total=0
for line in open(sys.argv[1]):
	if line.startswith('name'):
		continue
	id=line.split('\t')[1]
	abu=float(line.split('\t')[4])
	total+=abu
	rank=line.split('\t')[2]
	if rank == "leaf":
		rank = "strain"
	ranks.update({id: rank})
	if id in all_abu:
		all_abu[id] += abu
	else:
		all_abu.update({id: abu})
for i in all_abu:
	outp.write('%s\t%s\t%s\t%s\t%s\n' % (i, ranks[i], i,  i, 100*all_abu[i]/total))
outp.close()
