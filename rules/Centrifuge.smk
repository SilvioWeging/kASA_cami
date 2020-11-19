####################### Centrifuge ############################
rule Centrifuge_build:
	input:
		db = config["path"] + "done/download.done",
		tax = config["path"]+"done/downloadTaxData.done",
		largeFile = config["path"]+"genomes/merged_pacbio.fasta"
	output:
		touch(config["path"] + "done/Centrifuge_build.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/Centrifuge_build.txt"
	shell:
		"""
		mkdir -p {config[path]}index/Centrifuge
		cut -f 2,3 {config[path]}index/taxonomy/acc2Tax > {config[path]}index/taxonomy/centrifuge.acc2tax
		{config[CentrifugePath]}centrifuge-build -p {threads} --conversion-table {config[path]}index/taxonomy/centrifuge.acc2tax --taxonomy-tree {config[path]}index/taxonomy/nodes.dmp --name-table {config[path]}index/taxonomy/names.dmp {config[path]}genomes/merged_pacbio.fasta {config[path]}index/Centrifuge/Centrifuge
		"""

rule Centrifuge_identify:
	input:
		indexDone = config["path"] + "done/Centrifuge_build.done"
	output:
		touch(config["path"] + "done/Centrifuge_identify.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/Centrifuge_identify.txt"
	shell:
		"""
		path={config[path]}
		for file in ${{path}}fastqs/*
		do
			temp=${{file#${{path}}fastqs/}}
			filename=${{temp%.fq}}
			{config[CentrifugePath]}centrifuge -x ${{path}}index/Centrifuge/Centrifuge -p {threads} -t -q -S ${{path}}results/Centrifuge_${{filename}}.tsv --report-file ${{path}}results/Centrifuge_${{filename}}_profile.csv -U ${{file}}
		done
		"""

rule evalCentrifuge:
	input:
		config["path"] + "done/Centrifuge_identify.done"
	output:
		touch(config["path"] + "done/Centrifuge_eval.done")
	shell:
		"""
		path={config[path]}
		for file in ${{path}}results/Centrifuge_*.csv
		do
			temp=${{file#${{path}}results/Centrifuge_sample_}}
			filename=${{temp%_profile.csv}}
			python ${{path}}scripts/centrifugeCountToCAMI.py -i ${{file}} -o ${{path}}results/Centrifuge_${{filename}}.cami -s ${{filename}} -t 0.0 -n {config[path]}index/taxonomy/nodes.dmp -m {config[path]}index/taxonomy/names.dmp
			python ${{path}}scripts/centrifugeCountToCAMI.py -i ${{file}} -o ${{path}}results/Centrifuge-0.01_${{filename}}.cami -s ${{filename}} -t 0.01 -n {config[path]}index/taxonomy/nodes.dmp -m {config[path]}index/taxonomy/names.dmp
			python ${{path}}scripts/centrifugeCountToCAMI.py -i ${{file}} -o ${{path}}results/Centrifuge-nu_${{filename}}.cami -s ${{filename}} -u n -n {config[path]}index/taxonomy/nodes.dmp -m {config[path]}index/taxonomy/names.dmp
		done
		cat ${{path}}results/Centrifuge_*.cami > ${{path}}results/Centrifuge_all.cami
		cat ${{path}}results/Centrifuge-0.01_*.cami > ${{path}}results/Centrifuge-0.01_all.cami
		cat ${{path}}results/Centrifuge-nu_*.cami > ${{path}}results/Centrifuge-nu_all.cami
		"""