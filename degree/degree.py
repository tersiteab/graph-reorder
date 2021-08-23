import sys
import argparse
from collections import defaultdict

parser = argparse.ArgumentParser(description='Process input arguments')
parser.add_argument('input', help='input graph file path')
parser.add_argument('output', help='output graph file path')
parser.add_argument('-m', '--maintain', help='maintain initial vertex ID 0', action='store_true')
parser.add_argument('-w', '--weighted', help='input graph is weighted', action='store_true')
parser.add_argument('-a', '--ascending', help='order graph in ascending order', action='store_true')
parser.add_argument('-i', '--indegree', help='use indegree for ordering', action='store_true')
args = parser.parse_args()

# read input graph edges
edge_weights = {}
edges_by_node = defaultdict(list)
edge_list = []
with open(args.input, 'r') as fin:
    line = fin.readline()
    while line:
        if args.weighted:
            src, dst, w = line.split()
            src, dst, w = int(src), int(dst), int(w)
            edge_list.append([src, dst, w])
            if args.indegree:
                edges_by_node[dst].append(src)
            else:
                edges_by_node[src].append(dst)
            edge_weights[(src, dst)] = w
        else:
            src, dst = line.split()
            src, dst = int(src), int(dst)
            edge_list.append([src, dst])
            if args.indegree:
                edges_by_node[dst].append(src)
            else:
                edges_by_node[src].append(dst)
        line = fin.readline()

# sort vertices by their degree counts
ordered = sorted(edges_by_node.items(), key=lambda x: len(x[1]), reverse=False if args.ascending else True)

# mapping holds new mapping of a vertex
mapping = {}
count = 1 if args.maintain else 0

# compute the new mapping
for vertex, _ in ordered:
    if args.maintain and vertex == 0:
        mapping[vertex] = vertex
    else:
        mapping[vertex] = count
        count += 1

sorted_output = []

for edge in edge_list:
    src = edge[0]
    dst = edge[1]
    w = edge[2] if args.weighted else None
    if mapping.get(src) is None:
        mapping[src] = count
        count += 1
    if mapping.get(dst) is None:
        mapping[dst] = count
        count += 1
    sorted_output.append(
        [mapping.get(src), mapping.get(dst), edge_weights.get((src, dst))] if args.weighted else [mapping.get(src),
                                                                                                  mapping.get(dst)])
print("Done ordering")

# write ordered graph into output
with open(args.output, 'w') as fout:
    if args.weighted:
        for src, dst, w in sorted_output:
            fout.write('{} {} {}\n'.format(src, dst, w))
    else:
        for src, dst in sorted_output:
            fout.write('{} {}\n'.format(src, dst))
print("Writing done")
