#!/bin/bash --login
#SBATCH --job-name=GE-thread_placement_intel
#SBATCH --partition=work
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --ntasks-per-node=24
#SBATCH --cpus-per-task=2
#SBATCH --time=00:05:00
#SBATCH --export=ALL

# Load the Intel oneAPI compiler and MPI environment
module use /uwahpc/rocky9/modulefiles/intel/2023.0
module load compiler mpi

# leave in, it lists the environment loaded by the modules
module list

#  Note: SLURM_JOBID is a unique number for every job.
#  These are generic variables
EXECUTABLE=thread_placement_intel
SCRATCH=$MYSCRATCH/run_thread_placement_intel/$SLURM_JOBID
RESULTS=$MYGROUP/thread_placement_intel_results/$SLURM_JOBID

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
OUTPUT=thread_placement_intel.log

#############################################
#   Copy input files to $SCRATCH
#   then change directory to $SCRATCH
cd ${SLURM_SUBMIT_DIR}
cp $EXECUTABLE $SCRATCH

cd $SCRATCH

export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
export KMP_AFFINITY="granularity=fine,compact,1,0"
export I_MPI_PIN=1
export I_MPI_PIN_DOMAIN=omp

mpirun -np $SLURM_NTASKS ./$EXECUTABLE >> ${OUTPUT}

if [ $? -ne 0 ]; then
    cd
    OUTPUT2=kaya_results.log
    echo "$EXECUTABLE with jobID $SLURM_JOBID Failed" >> ${OUTPUT2}
else
    cd
    OUTPUT2=kaya_results.log
    echo "$EXECUTABLE with jobID $SLURM_JOBID Succeeded" >> ${OUTPUT2}
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

echo thread_placement_intel job finished at `date`
