#!/bin/bash --login
#SBATCH --job-name=GE-hello_NUMA_intel
#SBATCH --partition=work
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --time=00:05:00
#SBATCH --export=ALL

# Load the Intel oneAPI compiler environment
module use /uwahpc/rocky9/modulefiles/intel/2023.0
module load compiler

# Display loaded modules
module list

# Define executable and directories
EXECUTABLE=hello_numa_intel
SCRATCH=$MYSCRATCH/run_hello_NUMA_intel/$SLURM_JOBID
RESULTS=$MYGROUP/hello_NUMA_intel_results/$SLURM_JOBID

# Create scratch directory
mkdir -p "$SCRATCH"
printf '%s\n' "SCRATCH is $SCRATCH"

# Create results directory
mkdir -p "$RESULTS"
printf '%s\n' "Results directory is $RESULTS"

# Output log file
OUTPUT=hello_NUMA_intel.log

# Copy executable into scratch directory
cd "$SLURM_SUBMIT_DIR" || exit 1
cp "$EXECUTABLE" "$SCRATCH" || exit 1
cd "$SCRATCH" || exit 1

# Configure OpenMP
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
export KMP_AFFINITY="granularity=fine,compact"

printf '%s\n' "Number of threads is $OMP_NUM_THREADS"
printf '%s\n' "Intel affinity: $KMP_AFFINITY"

# Run with Slurm-managed CPU binding
srun --cpu-bind=verbose,cores ./$EXECUTABLE >> "$OUTPUT"
EXIT_STATUS=$?

# Record job success or failure
cd "$HOME" || exit 1

if [ "$EXIT_STATUS" -ne 0 ]; then
    printf '%s\n' "$EXECUTABLE with jobID $SLURM_JOBID Failed" >> kaya_results.log
else
    printf '%s\n' "$EXECUTABLE with jobID $SLURM_JOBID Succeeded" >> kaya_results.log
fi

# Move output to results directory
mv "$SCRATCH/$OUTPUT" "$RESULTS/"

# Clean up scratch directory
rm -r "$SCRATCH"

printf '%s\n' "hello_NUMA_intel job finished at $(date)"
