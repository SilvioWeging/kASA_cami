# Snakemake pipeline for kASA with CAMI data

This pipeline enables you to benchmark [kASA](https://github.com/SilvioWeging/kASA) together with other tools e.g.: [Kraken](https://github.com/DerrickWood/kraken), [Kraken2](https://github.com/DerrickWood/kraken2), [Clark](http://clark.cs.ucr.edu/Overview/), [ganon](https://github.com/pirovc/ganon), [Centrifuge](https://github.com/DaehwanKimLab/centrifuge), [MetaCache](https://github.com/muellan/metacache).


## Before you start

These pipelines assume that you are working in a Linux environment since most of the other tools do too.

 * Download and install the tools you wish to benchmark. If some tool is not of interest to you, write "" instead of the path inside the config file.

 * Install [Snakemake](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html) (we recommend that you install [conda](https://docs.conda.io/projects/conda/en/latest/user-guide/install/download.html#anaconda-or-miniconda) first and then use `pip3 install snakemake --user` inside this conda environment. Please note, that you have to activate the conda environment every time you want to use snakemake.).

 * Check the config file(s) which contain parameters that need to be changed for your platform (like paths, RAM, number of threads, etc.)

 * Call one of the snakefiles with `snakemake -s <snakefile>`.

You might want to use `.clean.sh` to remove all benchmark related files.

## Benchmark

This will evaluate time and memory consumption as well as create profiles in cami format for all results of every tool.

It downloads genomes given in the CAMI2 Gastrointestinal tract toy data set, creates indices for every tool from them and checks against all fastq files of this toy set. 
Finally, [OPAL](https://github.com/CAMI-challenge/OPAL/) can be called to compare profiling capability of all tested tools and settings. For every tool and setting (e.g. with threshold or without), a `*_all.cami` file will be created. Therefore please call the script as follows (OPAL needs to be in the PATH variable): `scripts/callOPAL.sh opal.py genomes/pacbio/taxonomic_profile_all.txt all results/ results/OPAL_all`.

The results are given inside the folder `results` (which is created during the benchmark). Scripts for the evaluation can be found inside the `scripts` folder. Measurements of time and memory consumption are saved inside the `benchmarks` folder for the index creation and identification step of every tool.

If the evaluation of the Centrifuge script should fail then the building step of the tool had a hiccup and "forgot" to assign certain tax IDs. Just run the building step again and it should work...

For kASA, setting the flag `128` to 1 in the config runs an additional extended version with a maximum k of 25.

NOTE: taxid 272556 for CP008984.1 had to be inserted manually