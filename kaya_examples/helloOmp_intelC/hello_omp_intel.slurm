#!/bin/bash --login
#SBATCH --job-name=GE-helloOmp_intelC
#SBATCH --partition=work
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --time=00:05:00
#SBATCH --export=ALL

# Load the Intel oneAPI compiler environment
module use /uwahpc/rocky9/modulefiles/intel/2023.0
module load compiler

# leave in, it lists the environment loaded by the modules
module list

#  Note: SLURM_JOBID is a unique number for every job.
#  These are generic variables
EXECUTABLE=hello_omp_intel
SCRATCH=$MYSCRATCH/run_helloOmp_intelC/$SLURM_JOBID
RESULTS=$MYGROUP/helloOmp_intelC_results/$SLURM_JOBID

###############################################
# Creates a unique directory in the SCRATCH directory for this job to run in.
if [ ! -d $SCRATCH ]; then 
    mkdir -p $SCRATCH 
fi 
printf 'SCRATCH is %s\n' "$SCRATCH"

###############################################
# Creates a unique directory in your GROUP directory for the results of this job
if [ ! -d $RESULTS ]; then 
    mkdir -p $RESULTS 
fi
printf 'the results directory is %s\n' "$RESULTS"

################################################
# declare the name of the output file or log file
OUTPUT=helloOmp_intelC.log

#############################################
#   Copy input files to $SCRATCH
#   then change directory to $SCRATCH
cd ${SLURM_SUBMIT_DIR}
cp $EXECUTABLE $SCRATCH

cd $SCRATCH

export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
export KMP_AFFINITY=disabled

./$EXECUTABLE >> ${OUTPUT}

if [ $? -ne 0 ]; then
    cd
    OUTPUT2=kaya_results.log
    printf '%s\n' "$EXECUTABLE with jobID $SLURM_JOBID Failed" >> ${OUTPUT2}
else
    cd
    OUTPUT2=kaya_results.log
    printf '%s\n' "$EXECUTABLE with jobID $SLURM_JOBID Succeeded" >> ${OUTPUT2}
fi

cd $SCRATCH

#############################################
#    $OUTPUT file to the unique results dir
# note this can be a copy or move  
mv $OUTPUT ${RESULTS}

cd $HOME

###########################
# Clean up $SCRATCH 

rm -r $SCRATCH

printf 'helloOmp_intelC job finished at %s\n' "$(date)"
