#!/bin/bash --login
#SBATCH --job-name=GE-hello_mpi_c_intel
#SBATCH --partition=work
#SBATCH --nodes=1
#SBATCH --ntasks=36
#SBATCH --ntasks-per-node=36
#SBATCH --mem-per-cpu=2G
#SBATCH --time=00:05:00
#SBATCH --export=ALL

# load the Intel compiler and MPI libs
module use /uwahpc/rocky9/modulefiles/intel/2023.0
module load compiler mpi

# leave in, it lists the environment loaded by the modules
module list

#  Note: SLURM_JOBID is a unique number for every job.
#  These are generic variables
EXECUTABLE=hello_mpi_intel
SCRATCH=$MYSCRATCH/run_hello_mpi_c_intel/$SLURM_JOBID
RESULTS=$MYGROUP/hello_mpi_c_intel_results/$SLURM_JOBID

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
OUTPUT=hello_mpi_c_intel.log

#############################################
#   Copy input files to $SCRATCH
#   then change directory to $SCRATCH

cp $EXECUTABLE $SCRATCH

cd $SCRATCH
ls -al

mpirun -np $SLURM_NTASKS ./${EXECUTABLE} >> ${OUTPUT}

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
cp  $OUTPUT ${RESULTS}

cd $HOME

###########################
# Clean up $SCRATCH 

rm -r $SCRATCH

printf 'hello_mpi_c_intel job finished at %s\n' "$(date)"
