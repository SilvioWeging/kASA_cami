configfile: "snake_config.json"

#TODO: download cami stuff and gunzip it; run OPAL on everything

def tools():
	listOfTools = []
	if config["Kraken2Path"] != "":
		listOfTools.append(config["path"] + "done/kraken2_eval.done")
	if config["kASA"] != "":
		listOfTools.append(config["path"] + "done/kASA_eval.done")
	if config["kASA"] != "" and config["128"] == 1:
		listOfTools.append(config["path"] + "done/kASA_eval128.done")
	if config["ClarkPath"] != "":
		listOfTools.append(config["path"] + "done/clark_eval.done")
	if config["KrakenPath"] != "":
		listOfTools.append(config["path"] + "done/kraken_eval.done")
	if config["CentrifugePath"] != "":
		listOfTools.append(config["path"] + "done/Centrifuge_eval.done")
	if config["metacachePath"] != "":
		listOfTools.append(config["path"] + "done/metacache_eval.done")
	if config["ganonPath"] != "":
		listOfTools.append(config["path"] + "done/ganon_eval.done")
	
	return listOfTools

rule all:
	input:	*tools()

rule createAllFolders:
	output:
		touch(config["path"]+"done/folders.done")
	shell:
		"""
		mkdir -p {config[path]}results
		mkdir -p {config[path]}temporary
		mkdir -p {config[path]}genomes
		mkdir -p {config[path]}index
		mkdir -p {config[path]}index/taxonomy
		mkdir -p {config[path]}done
		mkdir -p {config[path]}fastqs
		"""

rule downloadTaxData:
	input:
		folder = config["path"]+"done/folders.done"
	output:
		touch(config["path"]+"done/downloadTaxData.done")
	shell:
		"""
		cd {config[path]}index/taxonomy
		wget -nc https://openstack.cebitec.uni-bielefeld.de:8080/swift/v1/CAMI_DATABASES/taxdump_cami2_toy.tar.gz
		if [ -s taxdump_cami2_toy.tar.gz ]; then
			tar -zxf taxdump_cami2_toy.tar.gz
		else
			echo "Download of taxonomy data failed"
			exit 1
		fi
		
		wget -nc https://openstack.cebitec.uni-bielefeld.de:8080/swift/v1/CAMI_2_DATABASES/ncbi_taxonomy_accession2taxid.tar
		if [ -s ncbi_taxonomy_accession2taxid.tar ]; then
			tar xf ncbi_taxonomy_accession2taxid.tar
		else
			echo "Download of acc2tax file failed"
			exit 1
		fi
		
		cd ncbi_taxonomy_accession2taxid/
		gunzip nucl_gb.accession2taxid.gz
		mv nucl_gb.accession2taxid ../
		cd ..
		
		python {config[path]}scripts/generateCustomAcc2Tax.py -i {config[path]}genomes/ -a nucl_gb.accession2taxid -o acc2Tax
		"""

rule downloadGenome:
	input:
		infolder= config["path"]+"done/folders.done"
	output:
		touch(config["path"]+"done/download.done")
	shell:
		"""
		cd {config[path]}
		wget -nc https://data.cami-challenge.org/camiClient.jar
		cd genomes/
		java -jar camiClient.jar -d https://openstack.cebitec.uni-bielefeld.de:8080/swift/v1/CAMI_Gastrointestinal_tract . -p . -t 4
		arr=( 0 1 2 3 4 5 9 10 11 12 )
		for i in "${{arr[@]}}"
		do
			cp pacbio/2018.01.23_11.53.11_sample_${{i}}/reads/anonymous_reads.fq.gz {config[path]}fastqs/sample_${{i}}.fq.gz
			gunzip {config[path]}fastqs/sample_${{i}}.fq.gz
		done
		"""
		

rule catEverythingTogether:
	input:
		divisionDone = config["path"]+"done/download.done"
	output:
		largeFasta = config["path"]+"genomes/merged_pacbio.fasta"
	shell:
		"""
		for file in {config[path]}genomes/pacbio/genomes/*
		do
			cat $file >> {config[path]}genomes/merged_pacbio.fasta
		done
		ln -fs {config[path]}genomes/pacbio/genomes {config[path]}genomes/genomes
		cat {config[path]}genomes/pacbio/taxonomic_profile_* > {config[path]}genomes/pacbio/taxonomic_profile_all.txt
		"""

if config["kASA"] != "":
	include: config["path"] + "rules/kASA.smk"

if config["kASA"] != "" and config["128"] == 1:
	include: config["path"] + "rules/kASA_128.smk"

if config["Kraken2Path"] != "":
	include: config["path"] + "rules/kraken2.smk"

if config["KrakenPath"] != "":
	include: config["path"] + "rules/kraken.smk"

if config["ClarkPath"] != "":
	include: config["path"] + "rules/clark.smk"

if config["CentrifugePath"] != "":
	include: config["path"] + "rules/Centrifuge.smk"

if config["metacachePath"] != "":
	include: config["path"] + "rules/metacache.smk"

if config["ganonPath"] != "":
	include: config["path"] + "rules/ganon.smk"