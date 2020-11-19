####################### kASA ############################

rule createIndex:
	input:
		genomesAreReady = config["path"]+"done/download.done"
	output:
		index = config["path"]+"index/kASA/index",
		kASAFinished = touch(config["path"]+"done/kASA_index.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/kASA_build.txt"
	params:
		ram = config["ram"]
	shell:
		"""
		mkdir -p {config[path]}index/kASA
		{config[kASA]} build -d {config[path]}index/kASA/index -i {config[path]}genomes/merged_pacbio.fasta -t {config[path]}temporary/ -f {config[path]}index/taxonomy/acc2Tax -y {config[path]}index/taxonomy/ -u species -n {threads} -m {params.ram} -x 1 {config[kASAParameters]}
		"""

rule shrink:
	input:
		genomesAreReady = config["path"]+"done/download.done",
		indexDone = config["path"]+"done/kASA_index.done"
	output:
		index = config["path"]+"index/kASA/index_s",
		shrinkFinished = touch(config["path"]+"done/kASA_shrink.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/kASA_shrink.txt"
	params:
		ram = config["ram"]
	shell:
		"""
		{config[kASA]} shrink -d {config[path]}index/kASA/index -o {output.index} -s 2 -t {config[path]}temporary/ -x 1
		"""

rule identify:
	input:
		index = config["path"]+"index/kASA/index_s",
		indexDone = config["path"]+"done/kASA_index.done",
		shrinkDone = config["path"]+"done/kASA_shrink.done"
	output:
		touch(config["path"]+"done/kASA_identification.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/kASA_identify.txt"
	params:
		ram = config["ram"]
	shell:
		"""
		{config[kASA]} identify_multiple -d {input.index} -i {config[path]}fastqs/ -p {config[path]}results/kASA_ -t {config[path]}temporary/ -n {threads} -x 1 -m {params.ram} -r {config[kASAParameters]}
		"""


rule evalkASA:
	input:
		result = config["path"]+"done/kASA_identification.done"
	output:
		touch(config["path"]+"done/kASA_eval.done")
	shell:
		"""
		path={config[path]}
		for file in ${{path}}results/kASA_*.csv
		do
			temp=${{file#${{path}}results/kASA_sample_}}
			filename=${{temp%.csv}}
			python ${{path}}scripts/csvToCAMI.py -i ${{file}} -n ${{path}}index/taxonomy/nodes.dmp -m ${{path}}index/taxonomy/names.dmp -o ${{path}}results/kASA-12-nu-0.0_${{filename}}.cami -k 12 -u n -t 0.0 -s ${{filename}} &
			python ${{path}}scripts/csvToCAMI.py -i ${{file}} -n ${{path}}index/taxonomy/nodes.dmp -m ${{path}}index/taxonomy/names.dmp -o ${{path}}results/kASA-12-u-0.0_${{filename}}.cami -k 12 -u u -t 0.0 -s ${{filename}} &
			python ${{path}}scripts/csvToCAMI.py -i ${{file}} -n ${{path}}index/taxonomy/nodes.dmp -m ${{path}}index/taxonomy/names.dmp -o ${{path}}results/kASA-12-o-0.0_${{filename}}.cami -k 12 -u o -t 0.0 -s ${{filename}} &
			python ${{path}}scripts/csvToCAMI.py -i ${{file}} -n ${{path}}index/taxonomy/nodes.dmp -m ${{path}}index/taxonomy/names.dmp -o ${{path}}results/kASA-12-ou-0.0_${{filename}}.cami -k 12 -u ou -t 0.0 -s ${{filename}} &
			python ${{path}}scripts/csvToCAMI.py -i ${{file}} -n ${{path}}index/taxonomy/nodes.dmp -m ${{path}}index/taxonomy/names.dmp -o ${{path}}results/kASA-12-nu-0.01_${{filename}}.cami -k 12 -u n -t 0.01 -s ${{filename}} &
			python ${{path}}scripts/csvToCAMI.py -i ${{file}} -n ${{path}}index/taxonomy/nodes.dmp -m ${{path}}index/taxonomy/names.dmp -o ${{path}}results/kASA-12-u-0.01_${{filename}}.cami -k 12 -u u -t 0.01 -s ${{filename}} &
			python ${{path}}scripts/csvToCAMI.py -i ${{file}} -n ${{path}}index/taxonomy/nodes.dmp -m ${{path}}index/taxonomy/names.dmp -o ${{path}}results/kASA-12-o-0.01_${{filename}}.cami -k 12 -u o -t 0.01 -s ${{filename}} &
			python ${{path}}scripts/csvToCAMI.py -i ${{file}} -n ${{path}}index/taxonomy/nodes.dmp -m ${{path}}index/taxonomy/names.dmp -o ${{path}}results/kASA-12-ou-0.01_${{filename}}.cami -k 12 -u ou -t 0.01 -s ${{filename}} &
		done
		wait
		cat ${{path}}results/kASA-12-nu-0.0_*.cami > ${{path}}results/kASA-12-nu-0.0_all.cami
		cat ${{path}}results/kASA-12-nu-0.01_*.cami > ${{path}}results/kASA-12-nu-0.01_all.cami
		cat ${{path}}results/kASA-12-u-0.0_*.cami > ${{path}}results/kASA-12-u-0.0_all.cami
		cat ${{path}}results/kASA-12-u-0.01_*.cami > ${{path}}results/kASA-12-u-0.01_all.cami
		cat ${{path}}results/kASA-12-o-0.0_*.cami > ${{path}}results/kASA-12-o-0.0_all.cami
		cat ${{path}}results/kASA-12-o-0.01_*.cami > ${{path}}results/kASA-12-o-0.01_all.cami
		cat ${{path}}results/kASA-12-ou-0.0_*.cami > ${{path}}results/kASA-12-ou-0.0_all.cami
		cat ${{path}}results/kASA-12-ou-0.01_*.cami > ${{path}}results/kASA-12-ou-0.01_all.cami
		"""


