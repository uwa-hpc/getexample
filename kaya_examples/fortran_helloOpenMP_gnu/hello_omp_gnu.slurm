#!/bin/bash --login
#SBATCH --job-name=GE-fortran_helloOpenMP_gnu
#SBATCH --partition=work
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --time=00:05:00
#SBATCH --export=ALL

# Load the GNU compiler module
module load gcc/14.3.0

# leave in, it lists the environment loaded by the modules
module list

#  Note: SLURM_JOBID is a unique number for every job.
#  These are generic variables
EXECUTABLE=hello_omp_gnu
SCRATCH=$MYSCRATCH/run_fortran_helloOpenMP_gnu/$SLURM_JOBID
RESULTS=$MYGROUP/fortran_helloOpenMP_gnu_results/$SLURM_JOBID

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
OUTPUT=fortran_helloOpenMP_gnu.log

#############################################
#   Copy input files to $SCRATCH
#   then change directory to $SCRATCH
cd ${SLURM_SUBMIT_DIR}
cp $EXECUTABLE $SCRATCH

cd $SCRATCH

export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
./$EXECUTABLE >> ${OUTPUT}

if [ $? -ne 0 ]; then
    cd
    OUTPUT2=kaya_results.log
    printf '%s with jobID %s Failed\n' "$EXECUTABLE" "$SLURM_JOBID" >> "${OUTPUT2}"
else
    cd
    OUTPUT2=kaya_results.log
    printf '%s with jobID %s Succeeded\n' "$EXECUTABLE" "$SLURM_JOBID" >> "${OUTPUT2}"
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

printf 'fortran_helloOpenMP_gnu job finished at %s\n' "$(date)"
