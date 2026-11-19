#!/bin/bash -l
#SBATCH --job-name=GE-orca
#SBATCH --partition=work
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --ntasks-per-node=16
#SBATCH --time=00:10:00   
#SBATCH --mem-per-cpu=3G

# Load the GNU compiler and ORCA compiler
module load gcc/14.3.0 orca/6.0.0

# leave in, it lists the environment loaded by the modules
module list

#  Note: SLURM_JOBID is a unique number for every job.
#  These are generic variables

INPUT=water
EXEC=orca
SCRATCH=$MYSCRATCH/run_orca/$SLURM_JOBID
RESULTS=$MYGROUP/orca_results/$SLURM_JOBID

###############################################
# Creates a unique directory in the SCRATCH directory for this job to run in.
if [ ! -d $SCRATCH ]; then 
    mkdir -p $SCRATCH 
fi 
echo SCRATCH is $SCRATCH

###############################################
# Creates a unique directory in your GROUP directory for the results of this job
if [ ! -d $RESULTS ]; then 
    mkdir -p $RESULTS 
fi 
echo the results directory is $RESULTS

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
echo 'number of cpus or tasks is:'  ${SLURM_NTASKS}

$(which orca) ${INPUT}.inp > ${OUTPUT}

#############################################
# $OUTPUT file to the unique results dir
mv ${OUTPUT} ${RESULTS}/

cd $HOME

###########################
# Clean up $SCRATCH 
if [ -d $SCRATCH ]; then
    rm -r $SCRATCH
fi 

echo orca job on kaya finished at  `date`
