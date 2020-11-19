####################### kASA ############################

rule createIndex128:
	input:
		genomesAreReady = config["path"]+"done/download.done"
	output:
		index = config["path"]+"index/kASA/index128",
		kASAFinished = touch(config["path"]+"done/kASA_index128.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/kASA_build128.txt"
	params:
		ram = config["ram"]
	shell:
		"""
		mkdir -p {config[path]}index/kASA
		{config[kASA]} build -d {config[path]}index/kASA/index128 -i {config[path]}genomes/merged_pacbio.fasta -t {config[path]}temporary/ -f {config[path]}index/taxonomy/acc2Tax -y {config[path]}index/taxonomy/ -u species -n {threads} --kH 25 -m {params.ram} -x 2 {config[kASAParameters]}
		"""

rule identify128:
	input:
		index = config["path"]+"index/kASA/index128",
		indexDone = config["path"]+"done/kASA_index128.done"
	output:
		touch(config["path"]+"done/kASA_identification128.done")
	threads: config["threads"]
	benchmark:
		config["path"] + "benchmarks/kASA_identify128.txt"
	params:
		ram = config["ram"]
	shell:
		"""
		{config[kASA]} identify_multiple -d {input.index} -i {config[path]}fastqs/ -p {config[path]}results/kASA-128_ -t {config[path]}temporary/ -n {threads} -m {params.ram} -x 2 -k 25 10 -r {config[kASAParameters]}
		"""

rule evalkASA128:
	input:
		result = config["path"]+"done/kASA_identification128.done"
	output:
		touch(config["path"]+"done/kASA_eval128.done")
	shell:
		"""
		path={config[path]}
		for file in ${{path}}results/kASA-128*.csv
		do
			temp=${{file#${{path}}results/kASA-128_sample_}}
			filename=${{temp%.csv}}
			python ${{path}}scripts/csvToCAMI.py -i ${{file}} -n ${{path}}index/taxonomy/nodes.dmp -m ${{path}}index/taxonomy/names.dmp -o ${{path}}results/kASA-25-nu-0.0_${{filename}}.cami -k 25 -u n -t 0.0 -s ${{filename}} &
			python ${{path}}scripts/csvToCAMI.py -i ${{file}} -n ${{path}}index/taxonomy/nodes.dmp -m ${{path}}index/taxonomy/names.dmp -o ${{path}}results/kASA-25-u-0.0_${{filename}}.cami -k 25 -u u -t 0.0 -s ${{filename}} &
			python ${{path}}scripts/csvToCAMI.py -i ${{file}} -n ${{path}}index/taxonomy/nodes.dmp -m ${{path}}index/taxonomy/names.dmp -o ${{path}}results/kASA-25-o-0.0_${{filename}}.cami -k 25 -u o -t 0.0 -s ${{filename}} &
			python ${{path}}scripts/csvToCAMI.py -i ${{file}} -n ${{path}}index/taxonomy/nodes.dmp -m ${{path}}index/taxonomy/names.dmp -o ${{path}}results/kASA-25-ou-0.0_${{filename}}.cami -k 25 -u ou -t 0.0 -s ${{filename}} &
			python ${{path}}scripts/csvToCAMI.py -i ${{file}} -n ${{path}}index/taxonomy/nodes.dmp -m ${{path}}index/taxonomy/names.dmp -o ${{path}}results/kASA-25-nu-0.01_${{filename}}.cami -k 25 -u n -t 0.01 -s ${{filename}} &
			python ${{path}}scripts/csvToCAMI.py -i ${{file}} -n ${{path}}index/taxonomy/nodes.dmp -m ${{path}}index/taxonomy/names.dmp -o ${{path}}results/kASA-25-u-0.01_${{filename}}.cami -k 25 -u u -t 0.01 -s ${{filename}} &
			python ${{path}}scripts/csvToCAMI.py -i ${{file}} -n ${{path}}index/taxonomy/nodes.dmp -m ${{path}}index/taxonomy/names.dmp -o ${{path}}results/kASA-25-o-0.01_${{filename}}.cami -k 25 -u o -t 0.01 -s ${{filename}} &
			python ${{path}}scripts/csvToCAMI.py -i ${{file}} -n ${{path}}index/taxonomy/nodes.dmp -m ${{path}}index/taxonomy/names.dmp -o ${{path}}results/kASA-25-ou-0.01_${{filename}}.cami -k 25 -u ou -t 0.01 -s ${{filename}} &
		done
		wait
		cat ${{path}}results/kASA-25-nu-0.0_*.cami > ${{path}}results/kASA-25-nu-0.0_all.cami
		cat ${{path}}results/kASA-25-nu-0.01_*.cami > ${{path}}results/kASA-25-nu-0.01_all.cami
		cat ${{path}}results/kASA-25-u-0.0_*.cami > ${{path}}results/kASA-25-u-0.0_all.cami
		cat ${{path}}results/kASA-25-u-0.01_*.cami > ${{path}}results/kASA-25-u-0.01_all.cami
		cat ${{path}}results/kASA-25-o-0.0_*.cami > ${{path}}results/kASA-25-o-0.0_all.cami
		cat ${{path}}results/kASA-25-o-0.01_*.cami > ${{path}}results/kASA-25-o-0.01_all.cami
		cat ${{path}}results/kASA-25-ou-0.0_*.cami > ${{path}}results/kASA-25-ou-0.0_all.cami
		cat ${{path}}results/kASA-25-ou-0.01_*.cami > ${{path}}results/kASA-25-ou-0.01_all.cami
		"""