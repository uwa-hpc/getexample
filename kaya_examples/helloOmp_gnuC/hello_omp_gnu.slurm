#!/bin/bash --login
#SBATCH --job-name=GE-helloOmp_gnuC
#SBATCH --partition=work
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
# -N is equivalent to --nodes
# -n is equivalent to --ntasks
# -c is equivalent to --cpus-per-task
#SBATCH --mem-per-cpu=4GB
# the default is 1G per cpu(core)
# HINT!
# --mem=0 is a special case and grants the job access to all the memory on each node!
#SBATCH --time=00:05:00
#SBATCH --export=NONE

# Load the GNU compilers environment
module load gcc/14.3.0

# leave in, it lists the environment loaded by the modules
module list

#  Note: SLURM_JOBID is a unique number for every job.
#  These are generic variables
EXECUTABLE=hello_omp_gnu
SCRATCH=$MYSCRATCH/run_helloOmp_gnuC/$SLURM_JOBID
RESULTS=$MYGROUP/helloOmp_gnuC_results/$SLURM_JOBID

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
OUTPUT=helloOmp_gnuC.log

#############################################
#   Copy input files to $SCRATCH
#   then change directory to $SCRATCH

cp $EXECUTABLE $SCRATCH

cd $SCRATCH
ls -al

export OMP_NUM_THREADS=24
srun -n 1 -c $SLURM_CPUS_PER_TASK ./$EXECUTABLE >> ${OUTPUT}

if [ $? -ne 0 ]; then
    cd
    OUTPUT2=kaya_results.log
    printf '%s with jobID %s Failed\n' "$EXECUTABLE" "$SLURM_JOBID" >> "$OUTPUT2"
else
    cd
    OUTPUT2=kaya_results.log
    printf '%s with jobID %s Succeeded\n' "$EXECUTABLE" "$SLURM_JOBID" >> "$OUTPUT2"
fi

cd $SCRATCH

#############################################
# $OUTPUT file to the unique results dir
# note this can be a cp (copied) or mv (moved)  
cp  $OUTPUT ${RESULTS}

cd $HOME

###########################
# Clean up $SCRATCH 

rm -r $SCRATCH

printf 'helloOmp_gnuC job finished at %s\n' "$(date)"
