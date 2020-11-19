for file in $1*.csv.cami
do
	toolName=${file%.csv.cami}
	mv $file ${toolName}.cami
done
