#!/bin/bash -l
#SBATCH --job-name=GE-gaussian
#SBATCH --partition=work
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=4GB
#SBATCH --time=00:15:00

# Load the Gaussian compiler environment
module load gaussian/g16.c02

# leave in, it lists the environment loaded by the modules
module list

#  Note: SLURM_JOBID is a unique number for every job.
#  These are generic variables

INPUT=test0194
SCRATCH=$MYSCRATCH/run_gaussian/$SLURM_JOBID
export GAUSS_SCRDIR="$SCRATCH"
RESULTS=$MYGROUP/gaussian_results/$SLURM_JOBID

###############################################
# Creates a unique directory in the SCRATCH directory for this job to run in.
if [ ! -d $SCRATCH ]; then 
    mkdir -p $SCRATCH 
fi 
echo SCRATCH is $SCRATCH
echo GAUSS_SCRDIR is "${GAUSS_SCRDIR}"
###############################################
# Creates a unique directory in your GROUP directory for the results of this job
if [ ! -d $RESULTS ]; then 
    mkdir -p $RESULTS 
fi
echo the results directory is $RESULTS

################################################
# declare the name of the output file or log file
OUTPUT=gau_${INPUT}.log

#############################################
#   Copy input files to $SCRATCH
#   then change directory to $SCRATCH

cp ${INPUT}.com $SCRATCH

cd $SCRATCH
 
ls -al

g16 < ${INPUT}.com  > ${OUTPUT}

#############################################
#    $OUTPUT file to the unique results dir
# note this can be a copy or move  
mv  ${OUTPUT} ${RESULTS}

cd $HOME

###########################
# Clean up $SCRATCH 

rm -r $SCRATCH

echo gaussian job finished at  `date`