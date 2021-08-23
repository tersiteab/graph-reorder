#!/bin/bash
#pagerank pull
apps=(pagerank bfs cc sssp)
directions=(pull push)
path=~/workloads/applications/
for a in "${apps[@]}"; do
	for d in "${directions[@]}"; do
		python3 graphitc.py -f ~/materials/graphit_schedules/${d}.gt -a graphit_apps/${a}_benchmark_copy.gt -o ${a}_benchmark_${d}.cpp;
		g++ -std=c++14 -I ../../src/runtime_lib/ -O3 ${a}_benchmark_${d}.cpp graphit_apps/logger.cpp -o ${path}single/$d/$a;
		g++ -std=c++14 -I ../../src/runtime_lib/ -O3 -DOPENMP -fopenmp ${a}_benchmark_${d}.cpp graphit_apps/logger.cpp -o ${path}multi/$d/$a;
	done
done
