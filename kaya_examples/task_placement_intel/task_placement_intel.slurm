#!/bin/bash -l
#SBATCH --job-name=GE-task_placement_intel
#SBATCH --partition=work
#SBATCH --nodes=1
#SBATCH --ntasks=48
#SBATCH --ntasks-per-node=48
#SBATCH --time=00:05:00
#SBATCH --export=ALL

# Load the Intel oneAPI compiler and MPI environment
module use /uwahpc/rocky9/modulefiles/intel/2023.0
module load compiler mpi

# leave in, it lists the environment loaded by the modules
module list

#  Note: SLURM_JOBID is a unique number for every job.
#  These are generic variables
EXECUTABLE=task_placement_intel
SCRATCH=$MYSCRATCH/run_task_placement_intel/$SLURM_JOBID
RESULTS=$MYGROUP/task_placement_intel_results/$SLURM_JOBID

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
OUTPUT=task_placement_intel.log

#############################################
#   Copy input files to $SCRATCH
#   then change directory to $SCRATCH
cd ${SLURM_SUBMIT_DIR}
cp $EXECUTABLE $SCRATCH

cd $SCRATCH

export I_MPI_PIN=1
export I_MPI_PIN_PROCESSOR_LIST=allcores

mpirun -np $SLURM_NTASKS ./$EXECUTABLE >> ${OUTPUT}

if [ $? -ne 0 ]; then
    cd
    OUTPUT2=kaya_results.log
    printf '%s\n' "$EXECUTABLE with jobID $SLURM_JOBID Failed" >> "$OUTPUT2"
else
    cd
    OUTPUT2=kaya_results.log
    printf '%s\n' "$EXECUTABLE with jobID $SLURM_JOBID Succeeded" >> "$OUTPUT2"
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

printf 'task_placement_intel job finished at %s\n' "$(date)"
