####################### Clark ############################
rule clark_buildAndIdentify:
	input:
		db = config["path"] + "done/download.done",
		taxonomy = config["path"]+"done/downloadTaxData.done"
	output:
		touch(config["path"] + "done/clark.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/clark_buildAndIdentify.txt"
	shell:
		"""
		mkdir -p {config[path]}index/clark
		mkdir -p {config[path]}index/clark/Custom
		cp {config[path]}index/taxonomy/acc2Tax {config[path]}index/taxonomy/nucl_accss
		touch {config[path]}index/clark/.taxondata
		ln -sf {config[path]}index/taxonomy/ {config[path]}index/clark/taxonomy
		
		for file in {config[path]}genomes/genomes/*
		do
			cp ${{file}} {config[path]}index/clark/Custom/
		done
		{config[ClarkPath]}set_targets.sh {config[path]}index/clark custom --species
		
		
		path={config[path]}
		for file in ${{path}}fastqs/*
		do
			temp=${{file#${{path}}fastqs/}}
			filename=${{temp%.fq}}
			{config[ClarkPath]}classify_metagenome.sh -O ${{file}} -n {threads} -R ${{path}}results/Clark_${{filename}}
			{config[ClarkPath]}exe/getAbundance -F ${{path}}results/Clark_${{filename}}.csv -D {config[path]}index/clark > ${{path}}results/Clark_${{filename}}.abundance
		done
		"""

rule evalclark:
	input:
		config["path"] + "done/clark.done"
	output:
		touch(config["path"] + "done/clark_eval.done")
	shell:
		"""
		path={config[path]}
		for file in ${{path}}results/Clark_*.abundance
		do
			temp=${{file#${{path}}results/Clark_sample_}}
			filename=${{temp%.abundance}}
			python ${{path}}scripts/clarkToCAMI.py -i ${{file}} -o ${{path}}results/Clark_${{filename}}.cami -s ${{filename}} -n {config[path]}index/taxonomy/nodes.dmp -m {config[path]}index/taxonomy/names.dmp
			python ${{path}}scripts/clarkToCAMI.py -i ${{file}} -o ${{path}}results/Clark-0.01_${{filename}}.cami -s ${{filename}} -n {config[path]}index/taxonomy/nodes.dmp -m {config[path]}index/taxonomy/names.dmp -t 0.01
		done
		cat ${{path}}results/Clark_*.cami > ${{path}}results/Clark_all.cami
		cat ${{path}}results/Clark-0.01_*.cami > ${{path}}results/Clark-0.01_all.cami
		"""