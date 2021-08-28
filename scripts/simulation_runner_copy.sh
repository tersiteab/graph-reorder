#!/bin/bash
directions=(pull push)
threads=(single multi)
applications=(pagerank cc)
suffix='.el'
graphs=(web-NotreDame Slashdot0811 CA-AstroPh Amazon0302)
app_path=~/workloads/applications
dataset_path=~/workloads/datasets
gem5=~/gem5/build/X86/gem5.opt
config=~/gem5/configs/example/se.py
params="--cpu-type=TimingSimpleCPU --num-cpus=1 --sys-clock=2GHz --caches --cacheline_size=64 --num-dirs=4 --mem-size=4GB --l1i_size=16kB --l1i_assoc=4 --l1d_size=16kB --l1d_assoc=8 --l2cache --num-l2caches=1 --l2_size=2MB --l2_assoc=8 --ruby --topology=Crossbar"
output="statistics_gem5.json"
temp="temp.txt"
truncate -s 0 $output
function original() {
if [ $1 = "weighted" ]
then 
	applications=(bfs sssp);
	suffix='.wel'
fi
for app in "${applications[@]}"; do
	echo -e "\n\t${app}: {" >> $output;
	for g in "${graphs[@]}"; do
		echo -e "\n\t\t${g}: {" >> $output;
		g_name="${g}${suffix}"
		for t in "${threads[@]}"; do
			echo -e "\n\t\t\t${t}: {" >> $output;
			for d in "${directions[@]}"; do
				truncate -s 0 $temp
				for i in {1..10}; do
					$gem5 $config $params -c $app_path/$t/$d/$app -o $dataset_path/weighted/original/$g_name;
					runtime=$(<"log.txt");
					echo -e $runtime >> $temp;
				done
				python3 average.py;
				avg=$(<$temp)
				echo -e "\t\t\t\t${d} runtime: $avg ms\n" >> $output;
			done
			echo -e "\n\t\t\t}" >> $output
		done
		echo -e "\n\t\t}" >> $output
	done
	echo -e "\n\t}" >> $output
done
}
function deg() {
deg_variants=(indegree outdegree)
if [ $1 = "weighted" ]
then 
	applications=(bfs sssp);
	suffix='.wel'
fi
for app in "${applications[@]}"; do
	echo -e "\n\t${app}: {" >> $output;
	for g in "${graphs[@]}"; do
		echo -e "\n\t\t${g}: {" >> $output;
		g_name="${g}${suffix}"
		for t in "${threads[@]}"; do
			echo -e "\n\t\t\t${t}: {" >> $output;
			for v in "${deg_variants[@]}"; do
				echo -e "\n\t\t\t\t${v}: {" >> $output;
				for d in "${directions[@]}"; do
					for i in {1..10}; do
						$gem5 $config $params -c $app_path/$t/$d/$app -o $dataset_path/$1/deg/$v/$g_name;
						runtime=$(<"log.txt");
						echo -e $runtime >> $temp;
					done
					python3 average.py;
					avg=$(<$temp);
					echo -e "\n\t\t\t\t\t${d} runtime: $avg ms\n " >> $output;
				done
				echo -e "\n\t\t\t\t}" >> $output;
			done
			echo -e "\n\t\t\t}" >> $output;
		done
		echo -e "\n\t\t}" >> $output;
	done
	echo -e "\n\t}" >> $output;
done
}

#cl reordering
function cl() {
cl_variants=(sort cluster)
cl_variants2=(indegree outdegree)
if [ $1 = "weighted" ]
then 
	applications=(bfs sssp);
	suffix='.wel'
fi
echo -e "\nClustering: {" >> $output
for app in "${applications[@]}"; do
	echo -e "\n\t${app}: {" >> $output
	for g in "${graphs[@]}"; do
		echo -e "\n\t\t${g}: {" >> $output;
		g_name="${g}${suffix}"
		for t in "${threads[@]}"; do
			echo -e "\n\t\t\t${t}: {" >> $output;
			for type in "${cl_variants[@]}"; do
				echo -e "\n\t\t\t\t${tyep}: {" >> $output;
				for type2 in "${cl_variants2[@]}"; do
					echo -e "\n\t\t\t\t\t${type2}: {" >> $output;
					for d in "${directions[@]}"; do
						for i in {1..10};do
							$gem5 $config $params -c $app_path/$t/$d/$app -o $dataset_path/$1/cl/$type/$type2/$g_name;
							runtime=$(<"log.txt");
							echo -e $runtime >> $temp;
						done
						python3 average.py;
						avg=$(<$temp);
						echo -e "\n\t\t\t\t\t\t${d} runtime: $avg ms\n " >> $output;
					done
					echo -e "\n\t\t\t\t\t}" >> $output;
				done
				echo -e "\n\t\t\t\t}" >> $output;
			done
			echo -e "\n\t\t\t}" >> $output;
		done
		echo -e "\n\t\t}" >> $output;
	done
	echo -e "\n\t}" >> $output;
done
}

#ph reordering
function ph(){
if [ $1 = "weighted" ]
then 
	applications=(bfs sssp);
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
				echo -e "" > $temp
				for i in {1..10}; do
					$gem5 $config $params -c $app_path/$t/$d -o $dataset_path/$1/ph/$g_name;
					runtime=$(<"log.txt");
					echo -e runtime >> $temp;
				done
				python3 average.py;
				avg=$(<$temp);
				echo -e  "\t\t\t\t${d}runtime: $avg" >> $output;
			done
			echo -e "\n\t\t\t}" >> $output;
		done
		echo -e "\n\t\t}" >> $output;
	done
	echo -e "\n\t}" >> $output;
done
}
#br reordering
function br() {
applications=(pagerank cc)
suffix='.el'
if [ $1 = "weighted" ]
then 
	applications=(bfs sssp);
	suffix='.wel'
fi
for app in "${applications[@]}"; do
	echo -e "\n\t${app}: {" >> $output;
	for g in "${graphs[@]}"; do
		g_name="${g}.el"
		echo -e "\n\t\t${g}: {" >> $output;
		for t in "${threads[@]}"; do
			echo -e "\n\t\t\t${t}: {" >> $output;
			for d in "${directions[@]}"; do
				echo  "" > $temp
				for i in  {1..10}; do
					$gem5 $config $params -c $app_path/$t/$d -o dataset_path/$1/br/$g_name;
					runtime=$(<"log.txt");
					echo -e runtime >> $temp;
				done
				python3 average.py;
				avg=$(<$temp)
				echo -e "\t\t\t\t${d}: $avg seconds" >> $output;
			done
			echo -e "\n\t\t\t}" >> $output;
		done
		echo -e "\n\t\t}" >> $output;
	done
	echo -e "\n\t}" >> $output;
done
}

#rabbit reordering
function rabbit() {
if [ $1 = "weighted" ]
then 
	applications=(bfs sssp);
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
					$gem5 $config $params -c $app_path/$t/$d/$app -o $dataset_path/$1/rabbit/$g_name;
					runtime=$(<"log.txt");
					echo -e runtime >> $temp;
				done
				python3 average.py;
				avg=$(<$temp)
				echo -e "\t\t\t\t${d}: $avg seconds" >> $output;
			done
			echo -e "\n\t\t\t}" >> $output;
		done
		echo -e "\n\t\t}" >> $output;
	done
	echo -e "\n\t}" >> $output;
done
}

#br reordering
function gorder() {
for app in "${applications[@]}"; do
	echo -e "\n\t${app}: {" >> $output;
	for g in "${graphs[@]}"; do
		g_name="${g}.el"
		echo -e "\n\t\t${g}: {" >> $output;
		for t in "${threads[@]}"; do
			echo -e "\n\t\t\t${t}: {" >> $output;
			for d in "${directions[@]}"; do
				echo  "" > $temp
				for i in  {1..10}; do
					$gem5 $config $params -c $app_path/$t/$d -o $dataset_path/unweighted/gorder/$g_name;
					runtime=$(<"log.txt");
					echo -e runtime >> $temp;
				done
				python3 average.py;
				avg=$(<$temp)
				echo -e "\t\t\t\t${d}: $avg seconds" >> $output;
			done
			echo -e "\n\t\t\t}" >> $output;
		done
		echo -e "\n\t\t}" >> $output;
	done
	echo -e "\n\t}" >> $output;
done
}
echo -e "\nOriginal Ordering: {" >> $output
original 'unweighted'
original 'weighted'
echo -e "\n}" >> $output
#echo - e"\npH reeordering: {" >> $output
#ph 'unweighted'
#ph 'weighted'
#echo -e "\n}" >> $output
#echo -e "\nBlock reordering: {" >> $output
#br 'unweighted'
#br 'weighted'
#echo -e "\n}" >> $output
#echo -e \Rabbit reordering: {" >> $output
#rabbit 'unweighted'
#rabbit 'weighted'
#echo -e "\n}" >> $output
#echo -e "\nDegree ordering: {" >> $output
#deg 'unweighted'
#deg 'weighted'
#echo -e "\n}" >> $output
#echo -e "\nCluster reordering: {" >> $output
#cl 'unweighted'
#cl 'weighted'
#echo -e "\n}" >> $output
#echo -e "\nGOrder reordering: {" >> $output
#gorder
#echo -e "\n}" >> $output
