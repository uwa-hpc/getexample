#!/bin/bash --login
#SBATCH --job-name=GE-swash
#SBATCH --partition=work
#SBATCH --nodes=1
# -N is equivalent to --nodes
# -n is equivalent to --ntasks
# -c is "number of cores"
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=11G
#SBATCH --time=00:10:00
#SBATCH --export=NONE

# Load Intel compiler and MPI
module load intel/2020.4
module load swash/9.01

# List the loaded environment
module list

# Define input filenames
case_name=a11stwav
input=a11stw01.sws

# Define the SCRATCH and RESULTS directories
# SLURM_JOBID is a unique number for every job.
# MYSCRATCH and MYGROUP are custom Kaya environment variables.
SCRATCH="$MYSCRATCH/run_swash/$SLURM_JOBID"
RESULTS="$MYGROUP/swash_results_${case_name}"

# Define the source directory containing the input files.
# The source directory is two levels above the SWASH example directory.
SOURCE_DIR="${SLURM_SUBMIT_DIR}/../../src/swash"

###############################################
# Create a unique scratch directory
mkdir -p "$SCRATCH"
printf "%s\n" "SCRATCH is $SCRATCH"

###############################################
# Create a unique results directory
mkdir -p "$RESULTS"
printf "%s\n" "The results directory is $RESULTS"

################################################
# Declare the output log filename
OUTPUT=swash_stdout.log

# Use the number of allocated Slurm tasks
OMP_NUM_THREADS="$SLURM_NTASKS"
export OMP_NUM_THREADS

#############################################
# Copy input files to SCRATCH
# Then change directory to SCRATCH

cd "$SLURM_SUBMIT_DIR" || exit 1

printf "%s\n" "Current directory is $(pwd)"

cp "$SOURCE_DIR/${case_name}.bot" "$SCRATCH/" || exit 1
cp "$SOURCE_DIR/${case_name}.wlv" "$SCRATCH/" || exit 1
cp "$SOURCE_DIR/${input}" "$SCRATCH/" || exit 1

cd "$SCRATCH" || exit 1

ls -al

#############################################
# Run SWASH
swashrun -input "$input" -omp "$SLURM_NTASKS"

#############################################
# Move output files to the results directory

mv a11stw01.* "$RESULTS/"

cd "$HOME" || exit 1

###########################
# Clean up SCRATCH

rm -r "$SCRATCH"

printf "%s\n" "SWASH job finished at $(date)"