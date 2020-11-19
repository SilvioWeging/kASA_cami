#!/bin/bash

pathToOPALPY=$1
goldStandard=$2
sampleID=$3
resultsPath=$4
output=$5
normalize=$6

mkdir -p $output

toolNames=()
files=()
for file in $resultsPath*"$sampleID".cami
do
	temp=${file#$resultsPath}
	toolName=${temp%_"$sampleID".cami}
	toolNames+=("$toolName")
	files+=("$file")
done

nameString=""
for entry in "${toolNames[@]}"
do
	nameString="$nameString""$entry, "
done
nameString=${nameString%, }

fileString=""
for entry in "${files[@]}"
do
	fileString="$fileString""$entry "
done

fileString=${fileString% }

#echo $nameString
#echo $fileString

$pathToOPALPY -g $goldStandard -o $output $normalize -p -l "$nameString" $fileString