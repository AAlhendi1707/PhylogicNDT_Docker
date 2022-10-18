FROM bitnami/minideb:buster-amd64
RUN install_packages python-pip build-essential python-dev r-base r-base-dev git graphviz python-tk
RUN pip install setuptools wheel
RUN pip install numpy scipy matplotlib pandas
COPY req /tmp/req
RUN apt-get -y upgrade
RUN apt-get -y update
RUN apt-get install -y libgraphviz-dev
RUN pip install -r /tmp/req
RUN pip install -e git+https://github.com/rmcgibbo/logsumexp.git#egg=sselogsumexp
RUN R -e "install.packages('dplyr',dependencies=TRUE)"
RUN R -e "install.packages('data.table',dependencies=TRUE)"
RUN mkdir /phylogicndt/
COPY PhylogicSim /phylogicndt/PhylogicSim
COPY GrowthKinetics /phylogicndt/GrowthKinetics
COPY BuildTree /phylogicndt/BuildTree
COPY Cluster /phylogicndt/Cluster
COPY SinglePatientTiming /phylogicndt/SinglePatientTiming
COPY LeagueModel /phylogicndt/LeagueModel
COPY data /phylogicndt/data
COPY ExampleData /phylogicndt/ExampleData
COPY ExampleRuns /phylogicndt/ExampleRuns
COPY output /phylogicndt/output
COPY utils /phylogicndt/utils
COPY PhylogicNDT.py /phylogicndt/PhylogicNDT.py
COPY LICENSE /phylogicndt/LICENSE
COPY req /phylogicndt/req
COPY README.md /phylogicndt/README.md
COPY my_scripts/merge.add.protein.anno.R /phylogicndt/merge.add.protein.anno.R
COPY my_scripts/myScript.sh /phylogicndt/myScript.sh
RUN chmod +x /phylogicndt/myScript.sh
# create directories
RUN mkdir -p /INPUTDIR
WORKDIR /INPUTDIR
# we need to specify default values
ENV MODULE="Cluster"
ENV CALC_CCF="YES"
ENV IMPUTE="NO"
ENV PATIENT_ID="PatientX"
ENV N_ITER=1000
ENV MIN_COVERAGE=30
ENV BUILDTREE_CCF_THRESHOLD=0.1
ENV BLOCKLIST_CLUSTER="None"
## run the script
CMD /phylogicndt/myScript.sh ${MODULE} ${CALC_CCF} ${IMPUTE} ${PATIENT_ID} ${N_ITER} ${MIN_COVERAGE} ${BUILDTREE_CCF_THRESHOLD} ${BLOCKLIST_CLUSTER}