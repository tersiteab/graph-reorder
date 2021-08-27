#!/bin/bash
# ph reorder weighted
el=.el
wel=.wel
graphs=(web-NotreDame Slashdot0811 CA-AstroPh Amazon0302)
input=~/materials/sample_edgelists/filtered
output=~/workloads/datasets
variants=(weighted unweighted)
function ph() {
	for i in  "${graphs[@]}"; do
		elloc="${i}.el"
		welloc="${i}.wel"
		python3 ph/ph.py -p=ph/ph $input/$elloc $output/unweighted/ph/$elloc;
		python3 ph/ph.py -m -w -p=ph/ph $input/$welloc $output/weighted/ph/$welloc;
		./converter -f $output/unweighted/ph/$elloc -b $output/unweighted/ph/${i}.sg;
		./converter -f $output/weighted/ph/$welloc -w -b $output/weighted/ph/${i}.wsg;
	done
}
#br reorder
function br (){
	for i in "${graphs[@]}"; do
		elloc="${i}.el";
		welloc="${i}.wel";
		python3 br/br.py -p=br/br $input/$elloc $output/unweighted/br/$elloc;
		python3 br/br.py -m -w -p=br/br $input/$welloc $output/weighted/br/$welloc;
		./converter -f $output/unweighted/br/$elloc -b $output/unweighted/br/${i}.sg;
		./converter -f $output/weighted/br/$welloc -w -b $output/weighted/br/${i}.wsg;
	done
}
function rabbit() {
	for i in "${graphs[@]}"; do
		elloc="${i}.el"
		welloc="${i}.wel"
		python3 rabbit/rabbit.py $input/$elloc $output/unweighted/rabbit/$elloc;
		python3 rabbit/rabbit.py -m -w $input/$welloc $output/weighted/rabbit/$welloc;
		./converter -f $output/unweighted/rabbit/$elloc -b $output/unweighted/rabbit/${i}.sg;
		./converter -f $output/weighted/rabbit/$welloc -w -b $output/weighted/rabbit/${i}.wsg;
	done
}
#Gorder reordering
function gorder (){
	for i in "${graphs[@]}"; do
		elloc="${i}.el";
		gorder/Gorder $input/$elloc;
		mv $input/${i}_Gorder.txt $output/unweighted/gorder/$elloc;
		./converter -f $output/unweighted/gorder/$elloc -b $output/unweighted/gorder/${i}.sg;
	done
}
#cl reorder
function cl () {
	for i in "${graphs[@]}"; do
		welloc="${i}.wel"
		elloc="${i}.el"
		python3 cluster/hub.py -m -w -s $input/$welloc $output/weighted/cl/sort/outdegree/$welloc;
		python3 cluster/hub.py  -m -w -i -s $input/$welloc $output/weighted/cl/sort/indegree/$welloc;
		python3 cluster/hub.py -m -w $input/$welloc $output/weighted/cl/cluster/outdegree/$welloc;
		python3 cluster/hub.py -m -w -i $input/$welloc $output/weighted/cl/cluster/indegree/$welloc;
		python3 cluster/hub.py -s $input/${elloc} $output/unweighted/cl/sort/outdegree/$elloc;
		python3 cluster/hub.py -i -s $input/${elloc} $output/unweighted/cl/sort/indegree/$elloc;
		python3 cluster/hub.py $input/${elloc} $output/unweighted/cl/cluster/outdegree/$elloc;
		python3 cluster/hub.py -i $input/${elloc} $output/unweighted/cl/cluster/indegree/$elloc;
	done
}
#deg reorder
function deg() {
	for i in "${graphs[@]}"; do
		welloc="${i}.wel"
		elloc="${i}.el"
		python3 degree/degree.py -m -w $input/$welloc $output/weighted/deg/outdegree/$welloc;
		python3 degree/degree.py -m -w -i $input/$welloc $output/weighted/deg/indegree/$welloc;
		python3 degree/degree.py  $input/${elloc} $output/unweighted/deg/outdegree/${elloc};
		python3 degree/degree.py -i $input/${elloc} $output/unweighted/deg/indegree/${elloc};
	done
}
#br
#ph
#rabbit
gorder
#deg
#cl
#gorder rerorder weighted
#gorder reorder unweighted
#rbabit reorder weighted
#rabbit reorder unweighted
