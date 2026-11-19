#!/bin/bash --login
#SBATCH --job-name=GE-hello_hybrid_c_gnu
#SBATCH --partition=work
#SBATCH --nodes=2
#SBATCH --ntasks=8
#SBATCH --cpus-per-task=6
#SBATCH --time=00:05:00


# Load the GNU compilers environment
module load gcc/14.3.0 openmpi/5.0.5

# leave in, it lists the environment loaded by the modules
module list

#  Note: SLURM_JOBID is a unique number for every job.
#  These are generic variables
EXECUTABLE=hello_hybrid_gnu
SCRATCH=$MYSCRATCH/run_hello_hybrid_c_gnu/$SLURM_JOBID
RESULTS=$MYGROUP/hello_hybrid_c_gnu_results/$SLURM_JOBID

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
OUTPUT=hello_hybrid_c_gnu.log

#############################################
#   Copy input files to $SCRATCH
#   then change directory to $SCRATCH

cp $EXECUTABLE $SCRATCH

cd $SCRATCH
ls -al

export OMP_NUM_THREADS=6
echo "Number of threads is $OMP_NUM_THREADS"
srun -N 2 -n 8 -c 6 ./$EXECUTABLE >> ${OUTPUT}

#############################################
#    $OUTPUT file to the unique results dir
# note this can be a copy or move  
mv  $OUTPUT ${RESULTS}

cd $HOME

###########################
# Clean up $SCRATCH 

rm -r $SCRATCH

echo hello_hybrid_c_gnu job finished at  `date`



