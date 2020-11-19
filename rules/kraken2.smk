####################### Kraken2 ############################
rule kraken2_build:
	input:
		db = config["path"] + "done/download.done",
		taxonomyFiles = config["path"]+"done/downloadTaxData.done"
	output:
		touch(config["path"] + "done/kraken2_build.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/kraken2_build.txt"
	shell:
		"""
		mkdir -p {config[path]}index/Kraken2
		ln -fs {config[path]}index/taxonomy {config[path]}index/Kraken2/taxonomy
		cat {config[path]}index/taxonomy/firstLine.txt {config[path]}index/taxonomy/acc2Tax > {config[path]}index/taxonomy/nucl_gb.accession2taxid
		
		for file in {config[path]}genomes/genomes/*
		do
			{config[Kraken2Path]}kraken2-build --add-to-library ${{file}} --db {config[path]}index/Kraken2 --no-masking
		done
		
		{config[Kraken2Path]}kraken2-build --build --db {config[path]}index/Kraken2 --threads 1 --no-masking
		"""

rule kraken2_identify:
	input:
		indexDone = config["path"] + "done/kraken2_build.done"
	output:
		touch(config["path"] + "done/kraken2_identify.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/kraken2_identify.txt"
	shell:
		"""
		path={config[path]}
		for file in ${{path}}fastqs/*
		do
			temp=${{file#${{path}}fastqs/}}
			filename=${{temp%.fq}}
			{config[Kraken2Path]}kraken2 --db ${{path}}index/Kraken2 --threads {threads} --output ${{path}}results/Kraken2_${{filename}}.tsv ${{file}} --report ${{path}}results/Kraken2_${{filename}}.csv
		done
		"""

rule evalKraken2:
	input:
		config["path"] + "done/kraken2_identify.done"
	output:
		touch(config["path"] + "done/kraken2_eval.done")
	shell:
		"""
		path={config[path]}
		for file in ${{path}}results/Kraken2_*.csv
		do
			temp=${{file#${{path}}results/Kraken2_sample_}}
			filename=${{temp%.csv}}
			python ${{path}}scripts/kraken2ToCAMI.py ${{file}} ${{path}}results/Kraken2_${{filename}}.cami ${{filename}}
		done
		cat ${{path}}results/Kraken2_*.cami > ${{path}}results/Kraken2_all.cami
		"""