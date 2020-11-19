#!/bin/bash

#$ -S /bin/bash
#$ -N CAMI2
#$ -l h_rt=08:00:00
#$ -l h_vmem=14G
#$ -pe smp 8
# -l scratch=10G

ulimit -c 0

#$ -V 
#$ -cwd
#$ -l highmem

# output files
#$ -o /gpfs1/work/weging/CAMI2/snakemakePipeline/qsubOut.out
#$ -e /gpfs1/work/weging/CAMI2/snakemakePipeline/qsubErr.err

rm /gpfs1/work/weging/CAMI2/snakemakePipeline/.snakemake/locks/*

export PATH=/gpfs1/data/idiv_gogoldoe/weging/krakenuniq/build/jellyfish-install/bin:$PATH

cd /gpfs1/work/weging/CAMI2/snakemakePipeline || exit

conda activate
snakemake -s benchmark.smk