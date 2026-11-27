#!/bin/bash 
#SBATCH --job-name=GE-orca
#SBATCH --partition=work
## note -c to use just cores (no mpi)
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --ntasks-per-node=16
#
#SBATCH --time=00:10:00   
#SBATCH --mem-per-cpu=3G
#SBATCH --export=NONE

# Load the GNU compiler and ORCA 6.0.0 (which also loads openmpi/5.0.5)
module load gcc/14.3.0 orca/6.0.0

# leave in, it lists the environment loaded by the modules
module list

#  Note: SLURM_JOBID is a unique number for every job.
#  These are generic variables

INPUT=water
#INPUT=fcfc-118-freq
#INPUT=BLYP-D3-def2-SVP
#INPUT=pagt-spe-ccsdt-rif12-qz
#INPUT=tight
EXEC=orca
SCRATCH=$MYSCRATCH/run_orca/$SLURM_JOBID

RESULTS=$MYGROUP/orca_results

###############################################
# Creates a unique directory in the SCRATCH directory for this job to run in.
if [ ! -d $SCRATCH ]; then 
    mkdir -p $SCRATCH 
fi 
printf '%s\n' "SCRATCH is $SCRATCH"

###############################################
# Creates a unique directory in your GROUP directory for the results of this job
if [ ! -d $RESULTS ]; then 
    mkdir -p $RESULTS 
fi 
printf '%s\n' "the results directory is $RESULTS"

################################################
# declare the name of the output file or log file
OUTPUT=orca_${INPUT}.out

#############################################
#   Copy input files to $SCRATCH
#   then change directory to $SCRATCH
cd ${SLURM_SUBMIT_DIR}
cp ${INPUT}.inp $SCRATCH

cd $SCRATCH
ls -al 
printf '%s %s\n' 'number of cpus or tasks is:' "${SLURM_NTASKS}"

# Note: ORCA manages its own MPI workers based on %pal nprocs in water.inp,
# so invoke the orca executable directly (do not prefix with mpirun).
${MAALI_ORCA_HOME}/orca ${INPUT}.inp > ${OUTPUT}

if [ $? -ne 0 ]; then
    cd
    OUTPUT2=kaya_results.log
    printf '%s\n' "orca (${INPUT}) with jobID $SLURM_JOBID Failed" >> ${OUTPUT2}
else
    cd
    OUTPUT2=kaya_results.log
    printf '%s\n' "orca (${INPUT}) with jobID $SLURM_JOBID Succeeded" >> ${OUTPUT2}
fi

cd $SCRATCH

#############################################
# $OUTPUT file to the unique results dir
# note this can be a copy or move  
mv  ${SCRATCH} ${RESULTS}

cd $HOME

###########################
# Clean up $SCRATCH 
if [ -d $SCRATCH ]; then
    rm -r $SCRATCH
fi 

printf 'orca job on kaya finished at %s\n' "$(date)"
