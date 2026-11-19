#!/bin/bash --login
#SBATCH --job-name=GE-fortran_helloworld_gnu
#SBATCH --partition=work
#SBATCH --nodes=1
#SBATCH --ntasks=1
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
echo SCRATCH is $SCRATCH

###############################################
# Creates a unique directory in your GROUP directory for the results of this job
if [ ! -d $RESULTS ]; then 
    mkdir -p $RESULTS 
fi
echo the results directory is $RESULTS

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
mv  $OUTPUT ${RESULTS}

cd $HOME

###########################
# Clean up $SCRATCH 

rm -r $SCRATCH

echo fortran_helloworld_gnu job finished at  `date`



