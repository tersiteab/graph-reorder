#!/bin/bash
applications=(pagerank bfs cc sssp)
directions=(pull push)
threads=(single multi)
graphs=(web-NotreDame rMat CA-AstroPh Amazon0302)
declare -A statistics
gem5=build/X86/gem5.opt
config=configs/example/se_modified.py
params="--cpu-type=TimingSimpleCPU --num-cpus=1 --sys-clock=2GHz --caches --cacheline_size=64 --num-dirs=4 --mem-size=4GB --l1i_size=16kB --l1i_assoc=4 --l1d_size=16kB --l1d_assoc=8 --l2cache --num-l2caches=1 --l2_size=2MB --l2_assoc=8 --ruby --topology=Crossbar"
app_path=~/workloads/applications
dataset_path=~/workloads/datasets
output="statistics.json"
#deg reordering tests
deg_variants=(indegree outdegree)

echo -e "Original ordering: {" >> $output
for app in "${applications[@]}"; do
	echo -e "\n\t${app}: {" >> $output;
	for g in "${graphs[@]}"; do
		echo -e "\n\t\t${g}: {" >> $output;
		g_name="${g}.wel"
		for t in "${threads[@]}"; do
			echo -e "\n\t\t\t${t}: {" >> $output;
			for d in "${directions[@]}"; do
				echo -e "\n\t\t\t\t${d}: " >> $output;
				"$gem5 $config $params -c $app_path/$t/$d/$app -o $dataset_path/weighted/original/$g_name";
				runtime=$(<"log.txt");
				cycles=$(<"cycle_log.txt");
				echo -e "runtime: $runtime seconds\tcycles: $cycles" >> $output;
			done
			echo -e "\n\t\t\t}" >> $output
		done
		echo -e "\n\t\t}" >> $output
	done
	echo -e "\n\t}" >> $output
done
echo -e "\n}" >> $output

echo -e "\nDegree ordering: {" >> $output
for app in "${applications[@]}"; do
	echo -e "\n\t${app}: {" >> $output;
	for g in "${graphs[@]}"; do
		echo -e "\n\t\t${g}: {" >> $output;
		g_name="${g}.wel"
		for t in "${threads[@]}"; do
			echo -e "\n\t\t\t${t}: {" >> $output;
			for d in "${directions[@]}"; do
				echo -e "\n\t\t\t\t${d}: {" >> $output;
				for v in "${deg_variants[@]}"; do
					echo -e "\n\t\t\t\t\t${v}: " >> $output;
					$gem5 $config $params -c $app_path/$t/$d/$app -o $dataset_path/weighted/deg/$v/$g_name;
					runtime=$(<"log.txt");
					cycles=$(<"cycle_log.txt");
					echo -e "runtime: $runtime seconds\tcycles: $cycles" >> $output;
				done
				echo -e "\n\t\t\t\t}" >> $output;
			done
			echo -e "\n\t\t\t}" >> $output;
		done
		echo -e "\n\t\t}" >> $output;
	done
	echo -e "\n\t}" >> $output;
done
echo -e "\n}" >> $output;

#cl reordering
cl_variants=(sort cluster)
cl_variants2=(indegree outdegree)

echo -e "\nClustering: {" >> $output
for app in "${applications[@]}"; do
	echo -e "\n\t${app}: {" >> $output
	for g in "${graphs[@]}"; do
		echo -e "\n\t\t${g}: {" >> $output;
		g_name="${g}.wel"
		for t in "${threads[@]}"; do
			echo -e "\n\t\t\t${t}: {" >> $output;
			for d in "${directions[@]}"; do
				echo -e "\n\t\t\t\t${d}: {" >> $output;
				for type in "${variants[@]}"; do
					echo -e "\n\t\t\t\t\t${type}: {" >> $output;
					for type2 in "${variants2[@]}"; do
						echo -e "\n\t\t\t\t\t\t${type2}: " >> $output;
						$gem5 $config $params -c $app_path/$t/$d/$app -o $dataset_path/weighted/cl/$type/$type2/$g_name;
						runtime=$(<"log.txt");
						cycles=$(<"cycle_log.txt");
						echo -e "runtime: $runtime seconds\tcycles: $cycles" >> $output;
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
echo -e "\n}" >> $output;

#ph reordering
ph_variants=(indegree outdegree)
echo -e "\npH reordering: {" >> $output
for app in "${applications[@]}"; do
	echo -e "\n\t${app}: {" >> $output;
	for g in "${graphs[@]}"; do
		g_name="${g}.wel"
		echo -e "\n\t\t${g}: {" >> $output;
		for t in "${threads[@]}"; do
			echo -e "\n\t\t\t${t}: {" >> $output;
			for d in "${directions[@]}"; do
				echo -e "\n\t\t\t\t${d}: {" >> $output;
				for v in "${ph_variants[@]}"; do
					echo -e "\n\t\t\t\t\t${v}: " >> $output;
					$gem5 $config $params -c $app_path/$t/$d/$app - $dataset_path/weighted/ph/$v/$g_name;
					runtime=$(<"log.txt");
					cycles=$(<"cycle_log.txt");
					echo -e "runtime: $runtime seconds\tcycles: $cycles" >> $output;
				done
				echo -e "\n\t\t\t\t}" >> $output;
			done
			echo -e "\n\t\t\t}" >> $output;
		done
		echo -e "\n\t\t}" >> $output;
	done
	echo -e "\n\t}" >> $output;
done
echo -e "\n}" >> $output

#br reordering
br_variants=(indegree outdegree)

echo -e "\nBlock reordering: {" >> $output
for app in "${applications[@]}"; do
	echo -e "\n\t${app}: {" >> $output;
	for g in "${graphs[@]}"; do
		g_name="${g}.wel"
		echo -e "\n\t\t${g}: {" >> $output;
		for t in "${threads[@]}"; do
			echo -e "\n\t\t\t${t}: {" >> $output;
			for d in "${directions[@]}"; do
				echo -e "\n\t\t\t\t${d}: {" >> $output;
				for v in "${br_variants[@]}" do;
					echo -e "\n\t\t\t\t\t${v}: " >> $output;
					$gem5 $config $params -c $app_path/$t/$d/$app -o $dataset_path/weighted/br/$v/$g_name;
					runtime=$(<"log.txt");
					cycles=$(<"cycle_log.txt");
					echo -e "runtime: $runtime seconds\tcycles: $cycles" >> $output;
				done
				echo -e "\n\t\t\t\t}" >> $output;
			done
			echo -e "\n\t\t\t}" >> $output;
		done
		echo -e "\n\t\t}" >> $output;
	done
	echo -e "\n\t}" >> $output;
done
echo -e "\n}" >> $output;
