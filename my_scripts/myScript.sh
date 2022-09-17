#!/bin/bash

#ENV CALC_CCF="YES" #1
#ENV IMPUTE="NO" #2
#ENV PATIENT_ID="Patient" #3
#ENV N_ITER=1000 #4
#ENV MIN_COVERAGE=30 #5
#ENV BUILDTREE_CCF_THRESHOLD=0.1 #6
#ENV BLOCKLIST_CLUSTER="None" #7

#CMD /phylogicndt/myScript.sh ${CALC_CCF} ${IMPUTE} ${PATIENT_ID} ${N_ITER} ${MIN_COVERAGE} ${BUILDTREE_CCF_THRESHOLD} ${BLOCKLIST_CLUSTER}

linesinsif=$(wc -l MySimulation_input.sif | awk '{print $1}')
Ndrivergenes=$(wc -l Driver_genes_v1.0.txt | awk '{print $1}')

Nsamples=$(expr $linesinsif - 1)

echo "PhylogicNDT run parameters are:"
echo "CALC_CCF $1"
echo "IMPUTE $2"
echo "PATIENT_ID $3"
echo "N_ITER $4"
echo "MIN_COVERAGE $5"
echo "BUILDTREE_CCF_THRESHOLD $6"
echo "BLOCKLIST_CLUSTER $7"
echo "........................................"
echo "Number of Time points in MySimulation_input.sif = $Nsamples"
echo "Number of driver genes in Driver_genes_v1.0.txt = $Ndrivergenes"
echo "........................................"


echo "start clustering ..."

## if impuse and calc_ccf true do

if [ "$1" == "YES" ] && [ "$2" == "YES" ]; then
    echo "calc CALC_CCF and impute before clustering..."
    python ../phylogicndt/PhylogicNDT.py Cluster -i $3 \
    -sif MySimulation_input.sif \
    -drv Driver_genes_v1.0.txt \
    --n_iter $4 \
    --min_coverage $5 \
    --maf_input_type calc_ccf \
    --impute \
    --maf
elif [ "$1" == "YES" ] && [ "$2" == "NO" ]; then
    echo "calc_ccf before clustering..."
    python ../phylogicndt/PhylogicNDT.py Cluster -i $3 \
    -sif MySimulation_input.sif \
    -drv Driver_genes_v1.0.txt \
    --n_iter $4 \
    --min_coverage $5 \
    --maf_input_type calc_ccf \
    --maf
elif [ "$1" == "NO" ] && [ "$2" == "YES" ]; then
    echo "impute before clustering..."
    python ../phylogicndt/PhylogicNDT.py Cluster -i $3 \
    -sif MySimulation_input.sif \
    -drv Driver_genes_v1.0.txt \
    --n_iter $4 \
    --min_coverage $5 \
    --impute \
    --maf
elif [ "$1" == "NO" ] && [ "$2" == "NO" ]; then
    echo "No calc_ccf or impute applied before clustering..."
    python ../phylogicndt/PhylogicNDT.py Cluster -i $3 \
    -sif MySimulation_input.sif \
    -drv Driver_genes_v1.0.txt \
    --n_iter $4 \
    --min_coverage $5 \
    --maf
else
    echo "Could NOT phrase the passing input argment for clustering!"
fi


## build tree
echo "start building tree ..."

if [ "$7" == "None" ] || [ "$7" == "" ]; then
    python ../phylogicndt/PhylogicNDT.py BuildTree -i $3 \
    --seed 123 \
    -sif MySimulation_input.sif \
    -drv Driver_genes_v1.0.txt \
    -m $3.mut_ccfs.txt \
    -c $3.cluster_ccfs.txt \
    --n_iter $4 \
    --blacklist_threshold $6
else
	python ../phylogicndt/PhylogicNDT.py BuildTree -i $3 \
    --seed 123 \
    -sif MySimulation_input.sif \
    -drv Driver_genes_v1.0.txt \
    -m $3.mut_ccfs.txt \
    -c $3.cluster_ccfs.txt \
    --n_iter $4 \
    --blacklist_threshold $6 \
    --blacklist_cluster $7
fi

echo "Finished!"

