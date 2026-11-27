#!/bin/bash -l
#SBATCH --job-name=GE-slurm
#SBATCH --partition=test
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem-per-cpu=2G
#SBATCH --time=00:05:00
#SBATCH --export=ALL

# To configure intel Environment for swan
module load intel/2020.4 metis/5.1.0 swan/41.41

# leave in, it lists the environment loaded by the modules
module list

#  Note: SLURM_JOBID is a unique number for every job.
#  These are generic variables

INFILE=f32har01.swn
SCRATCH=/tmp/$USER/run_swan/$SLURM_JOBID
RESULTS=$MYGROUP/swan_results

###############################################
# Creates a unique directory in the SCRATCH directory for this job to run in.
if [ ! -d $SCRATCH ]; then 
    mkdir -p $SCRATCH 
fi 
printf 'Working SCRATCH directory is %s\n' "$SCRATCH"

###############################################
# Creates a unique directory in your GROUP directory for the results of this job
if [ ! -d $RESULTS ]; then 
     mkdir -p $RESULTS
fi 
printf 'Results will be store in %s/%s\n' "$RESULTS" "$SLURM_JOBID"

#############################################
#   Copy input files to $SCRATCH
#   then change directory to $SCRATCH

cd ${SCRATCH}
wget https://swanmodel.sourceforge.io/download/zip/f32harin.tar.gz 
tar -xvf f32harin.tar.gz 
cd f32harin
ls -al

swanrun -input $INFILE -omp $SLURM_CPUS_PER_TASK 

#############################################
#    $OUTPUT file to the unique results dir
# note this can be a copy or move  
cd $HOME
mv ${SCRATCH} ${RESULTS}

###########################
# Clean up $SCRATCH 

rm -r $SCRATCH

printf 'SWAN OpenMP/thread job finished at %s\n' "$(date)"


