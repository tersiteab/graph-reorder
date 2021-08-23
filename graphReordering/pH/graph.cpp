#include "graph.h"

using namespace std;

void write_edge_list(char* filename, graph* G, unsigned int * nodeMap){
    unsigned int * VI = G->VI;
    unsigned int * EI = G->EI;
    unordered_map<string, unsigned int> weights = G->weights;
    unordered_map<unsigned int, unsigned int> filtered_to_original = G->filtered_to_original;
    unsigned int* map_to_node = new unsigned int [G->numVertex];
    for (unsigned int i=0; i<G->numVertex; i++)
        map_to_node[nodeMap[i]] = i;

    FILE *fp;
    fp = fopen(filename, "w");
    for (unsigned int i = 0; i < G->numVertex-1; ++i){
        for(unsigned int j = VI[i]; j < VI[i+1]; ++j){
          unsigned int s, d, w;
          s = indegree ? EI[j]: i;
          d = indegree ? i: EI[j];
          w = weights[get_map_key(map_to_node[s], map_to_node[d])];
//          cout << s << " " << d << " "<< w<< endl;
          if (weighted){
            fprintf(fp, "%d %d %d\n", s, d, w);
            // cout <<" weight: " <<  w << endl;
          }else{

            fprintf(fp, "%d %d\n", s, d);
          }
        }
    }
    for(unsigned int j = VI[G->numVertex-1];  j < G->numEdges; ++j){
      unsigned int s, d, w;
      s = indegree ? EI[j]: G->numVertex-1;
      d = indegree ? G->numVertex-1: EI[j];
      w = weights[get_map_key(map_to_node[s], map_to_node[d])];
      // cout <<" weight: " <<  w << endl;
      if (weighted) fprintf(fp, "%d %d %d\n", s, d, w);
      else fprintf(fp, "%d %d\n", s, d);
    }
    fclose(fp);
}

int read_edge_list (char* filename, std::vector<unsigned int>& src, std::vector<unsigned int>& dst,std::vector<unsigned int> &weights)
{
    unsigned int numEdgesRead = 0;

    FILE* fp = fopen (filename, "r");
    if (fp == NULL)
    {
        fputs("file error to output", stderr);
        return -1;
    }

    unsigned int srcVal = 0;
    unsigned int dstVal = 0;
    unsigned int w;
    int numVertex = 0;

    while(!feof(fp))
    {
        if(fscanf(fp, "%d", &srcVal) <= 0)
            break;
        fscanf(fp, "%d", &dstVal);
        if (weighted) fscanf(fp, "%d", &w);
        numVertex = (srcVal > numVertex) ? srcVal : numVertex;
        numVertex = (dstVal > numVertex) ? dstVal : numVertex;

        src.push_back(srcVal);
        dst.push_back(dstVal);
        if (weighted) weights.push_back(w);
        numEdgesRead++;

    }

    fclose(fp);
    cout << numEdgesRead << endl;
    return ++numVertex;
}

unsigned int filter (std::vector<unsigned int>& src, std::vector<unsigned int>& dst, std::vector<unsigned int> & weights, graph * G, unsigned int numVertex, unsigned int numEdgesRead)
{
    bool* exists = new bool [numVertex]();
    for (unsigned int i=0; i<numEdgesRead; i++)
    {
        exists[src[i]]=true;
        exists[dst[i]]=true;
//        if (weighted) cout << src[i] << " " << dst[i] << " " << weights[i] << endl;
    }

    unsigned int* vertexMap = new unsigned int [numVertex]();
    unsigned int actualVertices = 0;
    for (unsigned int i=0; i<numVertex; i++)
    {
        if (exists[i]){
            vertexMap[i] = actualVertices++;
            G->filtered_to_original[actualVertices-1] = i;
        }
    }

    for (unsigned int i=0; i<numEdgesRead; i++)
    {
        src[i] = vertexMap[src[i]];
        dst[i] = vertexMap[dst[i]];
        if (weighted) G->weights[get_map_key(src[i], dst[i])] = weights[i];
    }

    delete[] exists;
    delete[] vertexMap;

    return actualVertices;
}

void csr_convert(std::vector<unsigned int>& src, std::vector<unsigned int>& dst, graph* G)
{
    G->VI = new unsigned int [G->numVertex+1]();
    G->EI = new unsigned int [G->numEdges]();

    unsigned int* deg = new unsigned int [G->numVertex]();
    for (unsigned int i=0; i<G->numEdges; i++){
      if (indegree) deg[dst[i]]++;
      else deg[src[i]]++;
    }


    for (unsigned int i=1; i<G->numVertex+1; i++)
        G->VI[i] = G->VI[i-1] + deg[i-1];

    for (unsigned int i=0; i<G->numVertex; i++)
        deg[i] = 0;

    for (unsigned int i=0; i<G->numEdges; i++)
    {
        if (indegree){
          G->EI[G->VI[dst[i]] + deg[dst[i]]] = src[i];
          deg[dst[i]]++;
        } else {
          G->EI[G->VI[src[i]] + deg[src[i]]] = dst[i];
          deg[src[i]]++;
        }
    }

    delete[] deg;
}

string get_map_key(unsigned int src, unsigned int dst) {
  string key = "";
  key += to_string(src);
  key += ">";
  key += to_string(dst);
  return key;
}

int read_csr (char* filename, graph* G)
{
    std::vector<unsigned int> src;
    std::vector<unsigned int> dst;
    std::vector<unsigned int> weights;

    int numVertex = read_edge_list (filename, src, dst, weights);
    if (numVertex < 0)
        return -1;

    G->numEdges = src.size();

    G->numVertex = filter(src, dst, weights, G, (unsigned int)numVertex, G->numEdges);


    csr_convert(src, dst, G);


    return 1;
}


void printGraph (graph* G)
{
    //for (unsigned int i=0; i<G->numVertex; i++)
    //    printf("%d ", i);
    //printf("\n");
    for (unsigned int i=0; i<G->numVertex; i++)
    {
        printf("%d -> ", i);
        unsigned int endId = (i>=G->numVertex-1) ? G->numEdges : G->VI[i+1];
        for (unsigned int j=G->VI[i]; j<endId; j++)
            printf("%d, ", G->EI[j]);
        printf("\n");
    }
    printf("\n");
    //for (unsigned int i=0; i<G->numEdges; i++)
    //    printf("%d ", i);
    //printf("\n");
//    for (unsigned int i=0; i<G->numEdges; i++)
//        printf("%d ", G->EI[i]);
    printf("\n");
}


void write_csr (char* filename, graph* G)
{
    FILE* fp = fopen(filename, "wb");
    if (fp == NULL)
    {
        fputs("file error", stderr);
        return;
    }
    // fwrite(&G->numVertex, sizeof(unsigned int), 1, fp);
    // fwrite(&G->numEdges, sizeof(unsigned int), 1, fp);
    fwrite(G->VI, sizeof(unsigned int), G->numVertex, fp);
    fwrite(G->EI, sizeof(unsigned int), G->numEdges, fp);
    fclose(fp);
}

void createReverseCSR(graph* G1, graph* G2)
{
    G2->numVertex = G1->numVertex;
    G2->numEdges = G1->numEdges;
    G2->weights = G1->weights;
    G2->filtered_to_original = G1->filtered_to_original;

    G2->VI = new unsigned int[G1->numVertex]();
    G2->EI = new unsigned int[G1->numEdges];

    for (unsigned int i=0; i<G1->numEdges; i++)
    {
        if (G1->EI[i] < G1->numVertex-1)
            G2->VI[G1->EI[i]+1]++;
    }
    for (unsigned int i=1; i<G1->numVertex; i++)
        G2->VI[i] += G2->VI[i-1];
    unsigned int* tempId = new unsigned int [G1->numVertex]();

    for (unsigned int i=0; i<G1->numVertex; i++)
    {
        unsigned int maxId = (i==G1->numVertex-1) ? G1->numEdges : G1->VI[i+1];
        for (unsigned int j=G1->VI[i]; j<maxId; j++)
        {
            G2->EI[G2->VI[G1->EI[j]] + tempId[G1->EI[j]]] = i;
            tempId[G1->EI[j]]++;
        }
    }
    delete[] tempId;
}


void freeMem (graph* G)
{
    delete[] G->VI;
    delete[] G->EI;
}
