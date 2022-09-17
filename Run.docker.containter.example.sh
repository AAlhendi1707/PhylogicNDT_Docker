sudo docker run -it --rm \
-e PATIENT_ID="P106" \
-e N_ITER=100 \
-e MIN_COVERAGE=30 \
-e CALC_CCF="YES" \
-e IMPUTE="NO" \
-e BUILDTREE_CCF_THRESHOLD=0.1 \
-e BLOCKLIST_CLUSTER="None" \
-v /home/twix/PhylogicNDT/Impute_test:/INPUTDIR b856a6bf7143
