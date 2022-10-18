#!/bin/bash

#MODULE="Cluster" #1
#CALC_CCF="YES" #2
#IMPUTE="NO" #3
#PATIENT_ID="Patient" #4
#N_ITER=1000 #5
#MIN_COVERAGE=30 #6
#BUILDTREE_CCF_THRESHOLD=0.1 #7
#BLOCKLIST_CLUSTER="None" #8
#CMD /phylogicndt/myScript.sh ${MODULE} ${CALC_CCF} ${IMPUTE} ${PATIENT_ID} ${N_ITER} ${MIN_COVERAGE} ${BUILDTREE_CCF_THRESHOLD} ${BLOCKLIST_CLUSTER}

linesinsif=$(wc -l MySimulation_input.sif | awk '{print $1}')
Ndrivergenes=$(wc -l Driver_genes_v1.0.txt | awk '{print $1}')

Nsamples=$(expr $linesinsif - 1)

echo "PhylogicNDT run parameters are:"
echo "MODULE $1"
echo "CALC_CCF $2"
echo "IMPUTE $3"
echo "PATIENT_ID $4"
echo "N_ITER $5"
echo "MIN_COVERAGE $6"
echo "BUILDTREE_CCF_THRESHOLD $7"
echo "BLOCKLIST_CLUSTER $8"
echo "........................................"
echo "Number of Time points in MySimulation_input.sif = $Nsamples"
echo "Number of driver genes in Driver_genes_v1.0.txt = $Ndrivergenes"
echo "........................................"

if [ "$1" == "Cluster" ]; then

    echo "start clustering ..."
    ## if impuse and calc_ccf true do

    if [ "$2" == "YES" ] && [ "$3" == "YES" ]; then
        echo "calc CALC_CCF and impute before clustering..."
        python ../phylogicndt/PhylogicNDT.py Cluster -i $4 \
        -sif MySimulation_input.sif \
        -drv Driver_genes_v1.0.txt \
        --n_iter $5 \
        --min_coverage $6 \
        --maf_input_type calc_ccf \
        --impute \
        --maf
    elif [ "$2" == "YES" ] && [ "$3" == "NO" ]; then
        echo "calc_ccf before clustering..."
        python ../phylogicndt/PhylogicNDT.py Cluster -i $4 \
        -sif MySimulation_input.sif \
        -drv Driver_genes_v1.0.txt \
        --n_iter $5 \
        --min_coverage $6 \
        --maf_input_type calc_ccf \
        --maf
    elif [ "$2" == "NO" ] && [ "$3" == "YES" ]; then
        echo "impute before clustering..."
        python ../phylogicndt/PhylogicNDT.py Cluster -i $4 \
        -sif MySimulation_input.sif \
        -drv Driver_genes_v1.0.txt \
        --n_iter $5 \
        --min_coverage $6 \
        --impute \
        --maf
    elif [ "$2" == "NO" ] && [ "$3" == "NO" ]; then
        echo "No calc_ccf or impute applied before clustering..."
        python ../phylogicndt/PhylogicNDT.py Cluster -i $4 \
        -sif MySimulation_input.sif \
        -drv Driver_genes_v1.0.txt \
        --n_iter $5 \
        --min_coverage $6 \
        --maf
    else
    echo "Could NOT phrase the passing input argment for clustering!"
    fi
    
    echo "Clustering done ..."
    echo "Adding aa change to mutation name ..."

    ## adding protein change anno to mut.ccfs file
    Rscript ../phylogicndt/merge.add.protein.anno.R ./ $4.mut_ccfs.txt

    ## build tree
    echo "start building tree ..."

    if [ "$8" == "None" ] || [ "$8" == "" ]; then
        python ../phylogicndt/PhylogicNDT.py BuildTree -i $4 \
        --seed 123 \
        -sif MySimulation_input.sif \
        -drv Driver_genes_v1.0.txt \
        -m $4.mut_ccfs.txt \
        -c $4.cluster_ccfs.txt \
        --n_iter $5 \
        --blacklist_threshold $7
    else
	    python ../phylogicndt/PhylogicNDT.py BuildTree -i $4 \
        --seed 123 \
        -sif MySimulation_input.sif \
        -drv Driver_genes_v1.0.txt \
        -m $4.mut_ccfs.txt \
        -c $4.cluster_ccfs.txt \
        --n_iter $5 \
        --blacklist_threshold $7 \
        --blacklist_cluster $8
    fi

    echo "Finished!"

elif [ "$1" == "BuildTree" ]; then

    echo "Adding aa change to mutation name ..."
    ## adding protein change anno to mut.ccfs file
    Rscript ../phylogicndt/merge.add.protein.anno.R ./ $4.mut_ccfs.txt
    ## build tree
    echo "start building tree ..."

    if [ "$8" == "None" ] || [ "$8" == "" ]; then
        python ../phylogicndt/PhylogicNDT.py BuildTree -i $4 \
        --seed 123 \
        -sif MySimulation_input.sif \
        -drv Driver_genes_v1.0.txt \
        -m $4.mut_ccfs.txt \
        -c $4.cluster_ccfs.txt \
        --n_iter $5 \
        --blacklist_threshold $7
    else
	    python ../phylogicndt/PhylogicNDT.py BuildTree -i $4 \
        --seed 123 \
        -sif MySimulation_input.sif \
        -drv Driver_genes_v1.0.txt \
        -m $4.mut_ccfs.txt \
        -c $4.cluster_ccfs.txt \
        --n_iter $5 \
        --blacklist_threshold $7 \
        --blacklist_cluster $8
    fi

    echo "Finished!"

else
    echo "Inputted module is not recognised! The current supported module to run with this docker are: Cluster[default option] or BuildTree"
fi