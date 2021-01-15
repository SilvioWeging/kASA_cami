####################### metacache ############################
rule metacache_build:
	input:
		db = config["path"] + "done/download.done",
		tax = config["path"]+"done/downloadTaxData.done"
	output:
		touch(config["path"] + "done/metacache_build.done")
	benchmark:
		config["path"] + "benchmarks/metacache_build.txt"
	shell:
		"""
		mkdir -p {config[path]}index/metacache
		
		{config[metacachePath]}metacache build {config[path]}index/metacache/index {config[path]}genomes/merged_pacbio.fasta -taxonomy {config[path]}index/taxonomy/
		"""

rule metacache_identify:
	input:
		indexDone = config["path"] + "done/metacache_build.done"
	output:
		touch(config["path"] + "done/metacache_identify.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/metacache_identify.txt"
	shell:
		"""
		path={config[path]}
		{config[metacachePath]}metacache query ${{path}}index/metacache/index ${{path}}fastqs/ -taxids -threads {threads} -split-out ${{path}}results/metacache -lowest species -separate-cols -abundances ${{path}}results/metacache_profiles
		"""

rule evalmetacache:
	input:
		config["path"] + "done/metacache_identify.done"
	output:
		touch(config["path"] + "done/metacache_eval.done")
	shell:
		"""
		path={config[path]}
		for file in ${{path}}results/metacache_profiles_*.txt
		do
			temp=${{file#${{path}}results/metacache_profiles_sample_}}
			filename=${{temp%.fq.txt}}
			python ${{path}}scripts/MetaCacheCountToCAMI.py -i ${{file}} -o ${{path}}results/metacache_${{filename}}.cami -s ${{filename}} -t 0.0 -n {config[path]}index/taxonomy/nodes.dmp -m {config[path]}index/taxonomy/names.dmp
			python ${{path}}scripts/MetaCacheCountToCAMI.py -i ${{file}} -o ${{path}}results/metacache-0.01_${{filename}}.cami -s ${{filename}} -t 0.0 -n {config[path]}index/taxonomy/nodes.dmp -m {config[path]}index/taxonomy/names.dmp -t 0.01
		done
		cat ${{path}}results/metacache_*.cami > ${{path}}results/metacache_all.cami
		cat ${{path}}results/metacache-0.01_*.cami > ${{path}}results/metacache-0.01_all.cami
		"""