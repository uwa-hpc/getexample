#!/bin/bash --login
#SBATCH --job-name=GE-fortranHybrid_gnu
#SBATCH --partition=work
#SBATCH --nodes=1
#SBATCH --ntasks=6
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=4GB
#SBATCH --time=00:05:00
#SBATCH --export=ALL

# To load the GNU toolchain
module load gcc/14.3.0 openmpi/5.0.5

# leave in, it lists the environment loaded by the modules
module list

#  Note: SLURM_JOBID is a unique number for every job.
#  These are generic variables
EXECUTABLE=hello_hybrid_gnu
SCRATCH=$MYSCRATCH/run_fortranHybrid_gnu/$SLURM_JOBID
RESULTS=$MYGROUP/fortranHybrid_gnu_results/$SLURM_JOBID

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
OUTPUT=fortranHybrid_gnu.log

#############################################
#   Copy input files to $SCRATCH
#   then change directory to $SCRATCH

cp $EXECUTABLE $SCRATCH

cd $SCRATCH
ls -al

export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
printf "Number of threads is %s\n" "$OMP_NUM_THREADS"
mpirun -np $SLURM_NTASKS --bind-to none -x OMP_NUM_THREADS ./${EXECUTABLE} >> ${OUTPUT}

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
#    $OUTPUT file to the unique results dir
# note this can be a copy or move  
cp  $OUTPUT ${RESULTS}

cd $HOME

###########################
# Clean up $SCRATCH 

rm -r $SCRATCH

printf 'fortranHybrid_gnu job finished at %s\n' "$(date)"
