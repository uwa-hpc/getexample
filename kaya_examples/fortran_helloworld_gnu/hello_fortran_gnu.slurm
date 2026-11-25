#!/bin/bash --login
#SBATCH --job-name=GE-fortran_helloworld_gnu
#SBATCH --partition=work
#SBATCH --nodes=1
#SBATCH --ntasks=1
# -N is equivalent to --nodes
# -n is equivalent to --ntasks
# max ntasks = 1
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
EXECUTABLE=hello_fortran_gnu
SCRATCH=$MYSCRATCH/run_fortran_helloworld_gnu/$SLURM_JOBID
RESULTS=$MYGROUP/hellofortran_gnu_results/$SLURM_JOBID

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
OUTPUT=fortran_helloworld_gnu.log

#############################################
#   Copy input files to $SCRATCH
#   then change directory to $SCRATCH

cp $EXECUTABLE $SCRATCH

cd $SCRATCH
ls -al

srun -n 1 ./$EXECUTABLE >> ${OUTPUT}

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
# $OUTPUT file to the unique results dir
# note this can be a cp (copied) or mv (moved)  
cp  $OUTPUT ${RESULTS}

cd $HOME

###########################
# Clean up $SCRATCH 

rm -r $SCRATCH

printf 'fortran_helloworld_gnu job finished at %s\n' "$(date)"

