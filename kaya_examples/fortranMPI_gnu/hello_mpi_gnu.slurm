#!/bin/bash --login
#SBATCH --job-name=GE-fortranMPI_gnu
#SBATCH --partition=work
#SBATCH --nodes=2
#SBATCH --ntasks=20
#SBATCH --ntasks-per-node=10
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4GB
# the default is 1G per cpu(core)
# HINT!
# --mem=0 is a special case and grants the job access to all the memory on each node!
#SBATCH --time=00:05:00
#SBATCH --export=ALL

# To load the GNU toolchain
module load gcc/14.3.0 openmpi/5.0.5

# leave in, it lists the environment loaded by the modules
module list

#  Note: SLURM_JOBID is a unique number for every job.
#  These are generic variables
EXECUTABLE=hello_mpi_gnu
SCRATCH=$MYSCRATCH/run_fortranMPI_gnu/$SLURM_JOBID
RESULTS=$MYGROUP/fortranMPI_gnu_results/$SLURM_JOBID
#  for openMP codes
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
###############################################
# Creates a unique directory in the SCRATCH directory for this job to run in.
if [ ! -d $SCRATCH ]; then 
    mkdir -p $SCRATCH 
fi 
printf "%s\n" "SCRATCH is $SCRATCH"

###############################################
# Creates a unique directory in your GROUP directory for the results of this job
if [ ! -d $RESULTS ]; then 
    mkdir -p $RESULTS 
fi
printf "%s\n" "the results directory is $RESULTS"

################################################
# declare the name of the output file or log file
OUTPUT=fortranMPI_gnu.log

#############################################
#   Copy input files to $SCRATCH
#   then change directory to $SCRATCH
cd ${SLURM_SUBMIT_DIR}

cp $EXECUTABLE $SCRATCH

cd $SCRATCH

mpirun -np $SLURM_NTASKS ./${EXECUTABLE} >> ${OUTPUT}

if [ $? -ne 0 ]; then
    cd
    OUTPUT2=kaya_results.log
    printf "%s\n" "$EXECUTABLE with jobID $SLURM_JOBID Failed" >> ${OUTPUT2}
else
    cd
    OUTPUT2=kaya_results.log
    printf "%s\n" "$EXECUTABLE with jobID $SLURM_JOBID Succeeded" >> ${OUTPUT2}
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

printf "fortranMPI_gnu job finished at %s\n" "$(date)"
