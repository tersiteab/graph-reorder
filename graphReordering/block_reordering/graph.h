#include <iostream>
#include <vector>
#include <stdio.h>
#include <stdlib.h>
#include <cstdio>
#include <string>
#include <unordered_map>
#define GRAPH_HEADER_INCL
using namespace std;

extern bool weighted, maintain, indegree;

typedef struct graph
{
    unsigned int numVertex;
    unsigned int numEdges;
    unsigned int* VI;
    unsigned int* EI;
    unordered_map<unsigned int, unsigned int> filtered_to_original;
    unordered_map<string, unsigned int> weights;
} graph;

string get_map_key(unsigned int, unsigned int);

int read_csr (char*, graph*);

void printGraph (graph*);

void write_edge_list(char*, graph*, unsigned int *);

void write_csr (char*, graph*);

void initGraph (graph*);

void createReverseCSR (graph*, graph*, unsigned int);

void freeMem(graph*);
