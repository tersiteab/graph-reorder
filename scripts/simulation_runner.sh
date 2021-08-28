#!/bin/bash
unweighted_apps=(pagerank cc)
weighted_apps=(sssp bfs)

directions=(pull push)
threads=(single multi)
graphs=(web-NotreDame Slashdot0811 CA-AstroPh Amazon0302)

input_path=~/materials/sample_edgelists/original
app_path=~/workloads/applications
dataset_path=~/workloads/datasets
output="statistics.json"
truncate -s 0 $output
temp="temp.txt"
function original() {
	applications=(pagerank cc)
	suffix='.el'
	if [ $1 = 'weighted' ]
	then
		applications=(bfs sssp)
		suffix='.wel'
	fi
	for app in "${applications[@]}"; do
		echo "Original: ${app}"
		echo -e "\n\t${app}: {" >> $output;
		for g in "${graphs[@]}"; do
			echo -e "\n\t\t${g}: {" >> $output;
			g_name="${g}${suffix}"
			for t in "${threads[@]}"; do
				echo -e "\n\t\t\t${t}: {" >> $output;
				for d in "${directions[@]}"; do
					truncate -s 0 $temp
					for i in {1..10}; do
						$app_path/$t/$d/$app $input_path/$g_name;
						runtime=$(<"log.txt");
						echo -e $runtime >> $temp;
					done
					#cat $temp
					python3 average.py;
					avg=$(<$temp);
					echo -e  "\t\t\t\t${d} runtime: $avg ms\n" >> $output;
				done
				echo -e "\t\t\t}" >> $output
			done
			echo -e "\t\t}" >> $output
		done
		echo -e "\t}" >> $output
	done
}
function gorder() {
	for app in "${unweighted_apps[@]}";do
		echo -e "\n\t${app}: {" >> $output;
		for g in "${graphs[@]}"; do
			g_name="${g}.el"
			echo -e "\n${g}: {" >> $output
			for t in "${threads[@]}"; do
				echo -e "\n\t\t\t${t}: {" >> $output;
				for d in "${directions[@]}"; do
					truncate -s 0 $temp
					for i in {1..10}; do
						$app_path/$t/$d/$app $dataset_path/unweighted/gorder/$g_name;
						runtime=$(<"log.txt");
						echo -e $runtime >> $temp;
					done
					#cat $temp
					python3 average.py;
					avg=$(<$temp);
					echo -e  "\t\t\t\t${d} runtime: $avg ms\n" >> $output;
				done
				echo -e "\t\t\t}" >> $output;
			done
			echo -e "\t\t}" >> $output;
		done
		echo -e "\t}" >> $output;
	done
}
#ph reordering
function ph() {
ph_variants=(indegree outdegree)
suffix='.el'
applications=(pagerank cc)
if [ $1 = 'weighted' ]
then 
	applications=(bfs sssp)
	suffix='.wel'
fi
for app in "${applications[@]}"; do
	echo -e "\n\t${app}: {" >> $output;
	for g in "${graphs[@]}"; do
		g_name="${g}${suffix}"
		echo -e "\n\t\t${g}: {" >> $output;
		for t in "${threads[@]}"; do
			echo -e "\n\t\t\t${t}: {" >> $output;
			for d in "${directions[@]}"; do
				truncate -s 0 $temp
				for i in {1..10}; do
					$app_path/$t/$d/$app $dataset_path/$1/ph/$g_name;
					runtime=$(<"log.txt");
					echo -e $runtime >> $temp;
				done
				#cat $temp
				python3 average.py;
				avg=$(<$temp);
				echo -e  "\t\t\t\t${d} runtime: $avg ms\n" >> $output;
			done
			echo -e "\t\t\t}" >> $output;
		done
		echo -e "\t\t}" >> $output;
	done
	echo -e "\t}" >> $output;
done
}
#br reordering
function br() {
suffix='.el'
applications=(pagerank cc)
if [ $1 = 'weighted' ]
then
	applications=(bfs sssp)
	suffix='.wel'
fi
for app in "${applications[@]}"; do
	echo -e "\t${app}: {" >> $output;
	for g in "${graphs[@]}"; do
		g_name="${g}${suffix}"
		echo -e "\n\t\t${g}: {" >> $output;
		for t in "${threads[@]}"; do
			echo -e "\n\t\t\t${t}: {" >> $output;
			for d in "${directions[@]}"; do
				truncate -s 0 $temp
				for i in  {1..10}; do
					$app_path/$t/$d/$app $dataset_path/$1/br/$g_name;
					runtime=$(<"log.txt");
					echo -e $runtime >> $temp;
				done
				#cat $temp
				python3 average.py;
				avg=$(<$temp)
				echo -e "\t\t\t\t${d}: $avg ms\n" >> $output;
			done
			echo -e "\t\t\t}" >> $output;
		done
		echo -e "\t\t}" >> $output;
	done
	echo -e "\t}" >> $output;
done
}
function rabbit() {
suffix='.el'
applications=(pagerank cc)
if [ $1 = 'weighted' ]
then
	applications=(bfs sssp)
	suffix='.wel'
fi
for app in "${applications[@]}"; do
	echo -e "\n\t${app}: {" >> $output;
	for g in "${graphs[@]}"; do
		g_name="${g}${suffix}"
		echo -e "\n\t\t${g}: {" >> $output;
		for t in "${threads[@]}"; do
			echo -e "\n\t\t\t${t}: {" >> $output;
			for d in "${directions[@]}"; do
				truncate -s 0 $temp
				for i in  {1..10}; do
					$app_path/$t/$d/$app $dataset_path/$1/rabbit/$g_name;
					runtime=$(<"log.txt");
					echo -e $runtime >> $temp;
				done
				#cat $temp
				python3 average.py;
				avg=$(<$temp)
				echo -e "\t\t\t\t${d}: $avg ms\n" >> $output;
			done
			echo -e "\t\t\t}" >> $output;
		done
		echo -e "\t\t}" >> $output;
	done
	echo -e "\t}" >> $output;
done
}
echo -e "\nOriginal ordering: {" >> $output
original 'unweighted'
original 'weighted'
echo -e "}" >> $output
echo -e "\npH Reordering: {" >> $output
ph 'unweighted'
ph 'weighted'
echo -e "}" >> $output
echo -e "\nBlock Reordering: {" >> $output
br 'unweighted'
br 'weighted'
echo -e "}" >> $output
echo -e "\nRabbit Reordering: {" >> $output
rabbit 'unweighted'
rabbit 'weighted'
echo -e "}" >> $output
echo -e "\nGorder reordering: {" >> $output;
gorder
echo -e "}" >> $output
