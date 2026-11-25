#!/bin/bash -l
#SBATCH --job-name=GE-gaussian
#SBATCH --partition=work
#SBATCH --nodes=1
#SBATCH --ntasks=16
# -N is equivalent to --nodes
# -n is equivalent to --ntasks
# note ntasks has to match %nprocshared in your gaussian input file (or pass -p)
#SBATCH --mem-per-cpu=4GB
# the default is 1G per cpu(core)
# HINT!
# --mem=0 is a special case and grants the job access to all the memory on each node!
#SBATCH --time=01:00:00   
#SBATCH --export=NONE

# To configure the environment 
module load nvhpc/21.3 gaussian/g16.c02

# leave in, it lists the environment loaded by the modules
module list

#  Note: SLURM_JOBID is a unique number for every job.
#  These are generic variables

INPUT=test0135
SCRATCH=$MYSCRATCH/run_gaussian/$SLURM_JOBID
# need to define the scratch directory location for Gaussian
export GAUSS_SCRDIR="$SCRATCH"
RESULTS=$MYGROUP/gaussian_results

# set OpenMP parallelism to prevent it from conflicting with 
# Gaussian's internal parallelism 
export OMP_NUM_THREADS=1

###############################################
# Creates a unique directory in the SCRATCH directory for this job to run in.
if [ ! -d $SCRATCH ]; then 
    mkdir -p $SCRATCH 
fi 
printf "SCRATCH is %s\n" "$SCRATCH"
printf "GAUSS_SCRDIR is %s\n" "$SCRATCH"
###############################################
# Creates a unique directory in your GROUP directory for the results of this job
if [ ! -d $RESULTS ]; then 
    mkdir -p $RESULTS 
fi
printf "the results directory is %s\n" "$RESULTS"

#############################################
#   Copy input files to $SCRATCH
#   then change directory to $SCRATCH
cd ${SLURM_SUBMIT_DIR}
printf "### current directory is %s\n" "$(pwd)"
cp ${INPUT}.com ${SCRATCH}

cd ${SCRATCH}

ls -al

g16 ${INPUT}.com

if [ $? -ne 0 ]; then
    cd
    OUTPUT2=kaya_results.log
    printf "gaussian (%s) with jobID %s Failed\n" "$INPUT" "$SLURM_JOBID" >> ${OUTPUT2}
else
    cd
    OUTPUT2=kaya_results.log
    printf "gaussian (%s) with jobID %s Succeeded\n" "$INPUT" "$SLURM_JOBID" >> ${OUTPUT2}
fi

cd ${SCRATCH}

#############################################
# Gaussian writes ${INPUT}.log directly; move $SCRATCH to $RESULTS/$SLURM_JOBID
mv ${SCRATCH} ${RESULTS}

cd $HOME

###########################
# Clean up $SCRATCH if still present
if [ -d $SCRATCH ]; then
    rm -r $SCRATCH
fi

printf "gaussian job finished at %s\n" "$(date)"
