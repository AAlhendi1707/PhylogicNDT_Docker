# Docker container for PhylogicNDT

## Description
PhylogicNDT container contains complete build for Dockerfile of PhylogicNDT from [Broad Institute](https://github.com/broadinstitute/PhylogicNDT) that can be easily used to analyse tumour evolution. It has been built to automatically  run `Cluster` and `BuildTree` modules, which required to determine the phylogenetic relationship between tumour subclones.

![PhylogicNDT Container](https://github.com/AAlhendi1707/WES/blob/main/PhylogicNDT/PhylogicNDT.drawio.png)

## Docker image avaiablity
PhylogicNDT image can be found on [aalhendi1707/phylogicndt](https://hub.docker.com/repository/docker/aalhendi1707/phylogicndt) on dockerhub, and it is only for non-commersial use.

## How to use this image
```
docker run -it --rm \
-e MODULE="Cluster" \
-e PATIENT_ID="PatientXX" \
-e N_ITER=1000 \
-e MIN_COVERAGE=30 \
-e CALC_CCF="YES" \
-e IMPUTE="NO" \
-e BUILDTREE_CCF_THRESHOLD=0.1 \
-e BLOCKLIST_CLUSTER="None" \
-v /path/to/data:/INPUTDIR \
aalhendi1707/phylogicndt:latest
```

## Enviroment variables are:
`-e MODULE` to select running module. This version of docker container only support `Cluster` and `BuildTree`. Default used by algorithm BuildTree.

`-e PATIENT_ID` to set Patient/Case ID.

`-e N_ITER" ` Number iterations that will be used in Cluster and BuildTree modules. Default used by algorithm is 1000.

`-e MIN_COVERAGE` Mutations with coverage lower than this will not be used to cluster and instead re-assigned after dp clustering.

`-e CALC_CCF` Flag must be set to calc_ccf and sample purity must be provided. Also local copy number must be attached to each mutation in the maf with columns named `local_cn_a1` and `local_cn_a2` represent minor and major allele fractions respectively.

`-e IMPUTE` Assume 0 ccf for missing mutations. *Not recommanded*, instead do use **SNV.impute.R** script.

`-e BUILDTREE_CCF_THRESHOLD` ccf threshold for blacklisting clusters for a BuildTree and Cell Population. Default used by algorithm is 0.1.

`-e BLOCKLIST_CLUSTER` List cluster ids to blacklist from BuildTree and CellPopulation. Default used by algorithm None.

`-v /path/to/data` The path to your Input/output directory. This directory must contains (1) Somatic variants in maf file format for each sample [required], (2) `MySimulation_input.sif` [required] as described in below, (3) `Driver_genes_v1.0.txt` list for dirver genes that would be used to annotate for driver mutations [optional], as PhylogicNDT already comes with list of driver genes. The outputs will be written to this directory as well.


## Cluster
When running the Cluster module, prefer to use the sif file option. The command line code is much cleaner, and the format provides a much more organized way to keep track of your input files and values.

Sif file has 4 required columns, and 1 optional column:

- **sample_id**: the ID of each sample from the patient.
- **maf_fn**: a truncated version of the MAF file with/without additional CCF information.
- **seg_fn (optional)**: a truncated version of allelic seg calls.
- **purity**: the purity of each tumor sample from the patient.
- **timepoint**: if temporal ordered by biopsy time, if spatial then arbitrary

Below is the accepted format for MAF file

| Hugo_Symbol | Chromosome | Start_position | Reference_Allele | Tumor_Seq_Allele2 | t_ref_count | t_alt_count | Protein_change | Variant_Classification | Variant_Type | local_cn_a1 | local_cn_a2 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| CASZ1 | 1 | 10705011 | G | C | 200 | 13 | p.F1277L | Missense_Mutation | SNP | 0 | 1.4827313901312 | 
| CAMK2N1 | 1 | 20811852 | G | C | 66 | 31 | p.Y7X | Nonsense_Mutation | SNP | 0 | 1.4827313901312 | 
| RPL11 | 1 | 24020360 | T | C | 250 | 136 | p.V74A | Missense_Mutation | SNP | 0 | 1.4827313901312 | 
| MACO1 | 1 | 25785293 | A | C | 181 | 101 | p.K355T | Missense_Mutation | SNP | 0 | 1.4827313901312 | 
| SZT2 | 1 | 43890459 | C | T | 47 | 301 | p.R826X | Nonsense_Mutation | SNP | 0 | 1.4827313901312 | 
| BEST4 | 1 | 45250052 | C | T | 183 | 10 | p.V418I | Missense_Mutation | SNP | 0 | 1.4827313901312 | 
| CDKN2C | 1 | 51436117 | A | T | 53 | 230 | p.Q26L | Missense_Mutation | SNP | 0 | 1.4827313901312 | 
| ECHDC2 | 1 | 53387259 | C | G | 164 | 14 | p.E29D | Missense_Mutation | SNP | 0 | 1.4827313901312 | 
| AKNAD1 | 1 | 109395196 | C | - | 45 | 189 | p.D31Ifs*14 | Frame_Shift_Del | SNP | 0 | 1.4827313901312 | 
| HAO2 | 1 | 119923748 | C | G | 246 | 110 | p.R14G | Missense_Mutation | SNP | 0.421210864983179 | 2.16034289004054 | 
| ACP6 | 1 | 147141987 | G | A | 114 | 88 | p.R62W | Missense_Mutation | SNP | 2.30880923350471 | 2.30880923350471 | 
| SNX27 | 1 | 151611456 | TACCT | - | 497 | 0 | p.V135Afs*3 | Frame_Shift_Del | DEL | 2.30880923350471 | 2.30880923350471 | 
| POU2F1 | 1 | 167343450 | A | T | 371 | 0 | p.S159C | Missense_Mutation | SNP | 2.95035229843327 | 4.3441852902848 |


## BuildTree
The BuildTree inputs are just a subset of the outputs from the Cluster module:
Again, we need to proide the patient ID and the sif file. A description of the mutation CCF file and cluster CFF file output by the cluster module are described below.

- **mutation_ccf_file**: This file contains the cluster assignment of each mutation in the MAF in the maf_fn file.
- **cluster_ccf_file**: This file contains CCF information on each cluster, such as the average CCF of mutations in the cluster and the probability distribution of the cluster CCF.

