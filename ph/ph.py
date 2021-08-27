import sys
import subprocess
import argparse
parser = argparse.ArgumentParser(description="Process input arguments")
parser.add_argument('input', help='input graph file path')
parser.add_argument('output', help='output graph file path')
parser.add_argument('-p', '--program', help='reordering program', default='ph/ph')
parser.add_argument('-m', '--maintain', help='maintain initial al vertex', action='store_true')
parser.add_argument('-w', '--weighted', help='input is weighted graph', action='store_true')
args = parser.parse_args()
program = args.program
el = []
output_wel = []
vertices = set()
with open(args.input, "r") as fin:
	line = fin.readline()
	while line:
		splited = line.split()
		src, dst = int(splited[0]), int(splited[1])
		w = (splited[2]) if args.weighted else None
		el.append([src, dst, w] if args.weighted else [src, dst])
		vertices.add(src)
		vertices.add(dst)
		line = fin.readline()
mapping = {}
if args.weighted:
	with open("input.el", "w") as fout:
		for s, d, _ in el:
			fout.write("{} {}\n".format(s, d))
	subprocess.run([program, "./input.el", "./output.el"])
	with open("new_order.el", "r") as fin, open(args.output, "w") as fout:
		in_line = fin.readline()
		node = 0
		zeros_map=None
		mapped_to_zero=None
		while in_line:
			nodeMap = int(in_line)
			if not zeros_map:
				zeros_map=nodeMap
			if nodeMap==0:
				mapped_to_zero=node
			mapping[node] = nodeMap
			node += 1
			in_line = fin.readline()
		if args.maintain:
			mapping[mapped_to_zero]=zeros_map
			mapping[0]=0
		for s, d, w in el:
			fout.write("{} {} {}\n".format(mapping.get(s, s), mapping.get(d, d), w))

else:
	subprocess.run([args.program, args.input, "output.el" if args.maintain else args.output])
	if args.maintain:
		with open("new_order.el", "r") as fin, open(args.output, "w") as fout:
			in_line = fin.readline()
			node = 0
			zeros_map=None
			mapped_to_zero=None
			while in_line:
				nodeMap = int(in_line)
				if not zeros_map:
					zeros_map = nodeMap
				if nodeMap == 0:
					mapped_to_zero = node
				mapping[node]=nodeMap
				node += 1
				in_line = fin.readline()
			mapping[0] = 0
			mapping[mapped_to_zero]=zeros_map
			for s,d in el:
				fout.write("{} {}\n".format(mapping.get(s, s), mapping.get(d, d)))
