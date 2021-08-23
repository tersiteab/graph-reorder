#!/bin/bash
# ph reorder weighted
el=.el
wel=.wel
graphs=(web-NotreDame rMat CA-AstroPh Amazon0302)

function ph() {
	for i in  "${graphs[@]}"; do 
		welloc="${i}.wel"
		elloc="${i}.el"
		./graphReordering/pH/ph 100000 -w -m ~/materials/sample_edgelists/$welloc ~/workloads/datasets/weighted/ph/outdegree/$welloc; 
		./graphReordering/pH/ph 100000 -w -m -i ~/materials/sample_edgelists/$welloc ~/workloads/datasets/weighted/ph/indegree/$welloc;
		./graphReordering/pH/ph 100000 -m ~/materials/sample_edgelists/${elloc} ~/workloads/datasets/unweighted/ph/outdegree/${elloc};
		./graphReordering/pH/ph 100000 -m -i ~/materials/sample_edgelists/${elloc} ~/workloads/datasets/unweighted/ph/indegree/${elloc}
	done
}
#br reorder
function br (){
	for i in "${graphs[@]}"; do
		welloc="${i}.wel"
		elloc="${i}.el"
		./graphReordering/block_reordering/br 20 100000 -m -w ~/materials/sample_edgelists/$welloc ~/workloads/datasets/weighted/br/outdegree/$welloc;
		./graphReordering/block_reordering/br 20 100000 -m -w -i ~/materials/sample_edgelists/$welloc ~/workloads/datasets/weighted/br/indegree/$welloc;
		./graphReordering/block_reordering/br 20 100000 -m ~/materials/sample_edgelists/${elloc} ~/workloads/datasets/unweighted/br/outdegree/${elloc};
		./graphReordering/block_reordering/br 20 100000 -m -i ~/materials/sample_edgelists/${elloc} ~/workloads/datasets/unweighted/br/indegree/${elloc};
	done
}
#cl reorder
function cl () {
	for i in "${graphs[@]}"; do
		welloc="${i}.wel"
		elloc="${i}.el"
		python3 cluster/hub.py -m -w -s ~/materials/sample_edgelists/$welloc ~/workloads/datasets/weighted/cl/sort/outdegree$welloc;
		python3 cluster/hub.py  -m -w -i -s ~/materials/sample_edgelists/$welloc ~/workloads/datasets/weighted/cl/sort/indegree$welloc;
		python3 cluster/hub.py -m -w ~/materials/sample_edgelists/$welloc ~/workloads/datasets/weighted/cl/cluster/outdegree/$welloc;
		python3 cluster/hub.py -m -w -i ~/materials/sample_edgelists/$welloc ~/workloads/datasets/weighted/cl/cluster/indegree/$welloc;
		python3 cluster/hub.py -m -s ~/materials/sample_edgelists/${elloc} ~/workloads/datasets/unweighted/cl/sort/outdegree${elloc};
		python3 cluster/hub.py  -m -i -s ~/materials/sample_edgelists/${elloc} ~/workloads/datasets/unweighted/cl/sort/indegree${elloc};
		python3 cluster/hub.py -m ~/materials/sample_edgelists/${elloc} ~/workloads/datasets/unweighted/cl/cluster/outdegree/${elloc};
		python3 cluster/hub.py -m -i ~/materials/sample_edgelists/${elloc} ~/workloads/datasets/unweighted/cl/cluster/indegree/${elloc};
	done
}
#deg reorder
function deg() {
	for i in "${graphs[@]}"; do
		welloc="${i}.wel"
		elloc="${i}.el"
		python3 degree/degree.py -m -w ~/materials/sample_edgelists/$welloc ~/workloads/datasets/weighted/deg/outdegree/$welloc;
		python3 degree/degree.py -m -w -i ~/materials/sample_edgelists/$welloc ~/workloads/datasets/weighted/deg/indegree/$welloc;
		python3 degree/degree.py -m ~/materials/sample_edgelists/${elloc} ~/workloads/datasets/unweighted/deg/outdegree/${elloc};
		python3 degree/degree.py -m -i ~/materials/sample_edgelists/${elloc} ~/workloads/datasets/unweighted/deg/indegree/${elloc};
	done
}
br
ph
deg
cl
#gorder rerorder weighted
#gorder reorder unweighted
#rbabit reorder weighted
#rabbit reorder unweighted


