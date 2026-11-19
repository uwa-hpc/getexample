
#!/bin/bash -l
#SBATCH --job-name=GE-grasp
#SBATCH --partition=work
#SBATCH --nodes=1
#SBATCH --ntasks=34
#SBATCH --time=02:00:00
#SBATCH --export=ALL

# Load GNU compiler, OpenMPI and LAPACK
module load gcc/14.3.0 openmpi/5.0.5 lapack/3.12.1
module list

# GRASP executable and input directory
EXECUTABLE=sh_case1
INFILE=script

# GRASP software installation
export GRASP=/group/ea001/cbording/grasp/grasp-2018-12-03
export PATH="${GRASP}/bin:$PATH"
export LD_LIBRARY_PATH="${GRASP}/lib:${LD_LIBRARY_PATH}"

# Scratch and results directories
SCRATCH="$MYSCRATCH/run_grasp/$SLURM_JOBID"
RESULTS="$MYGROUP/grasp_results/$SLURM_JOBID"

mkdir -p "$SCRATCH" || exit 1
mkdir -p "$RESULTS" || exit 1

echo "Scratch directory: $SCRATCH"
echo "Results directory: $RESULTS"
echo "GRASP installation: $GRASP"

# Check that the required GRASP executable exists
if [ ! -x "$GRASP/bin/rangular_mpi" ]; then
    echo "ERROR: GRASP MPI executables not found in $GRASP/bin"
    exit 1
fi

# Copy GRASP input files to scratch
cd "$SLURM_SUBMIT_DIR" || exit 1
cp -R "grasp/$INFILE" "$SCRATCH/" || exit 1

cd "$SCRATCH/$INFILE" || exit 1

# Run the GRASP calculation workflow.
# sh_scf and sh_tr launch the MPI programs using SLURM_NTASKS.
OUTPUT=case1_mpi.log
"./$EXECUTABLE" > "$OUTPUT" 2>&1
EXIT_STATUS=$?

# Record job outcome
if [ "$EXIT_STATUS" -ne 0 ]; then
    echo "GRASP job $SLURM_JOBID failed" >> "$HOME/kaya_results.log"
else
    echo "GRASP job $SLURM_JOBID succeeded" >> "$HOME/kaya_results.log"
fi

# Save output
mv "$OUTPUT" "$RESULTS/"

# Clean up scratch
cd "$HOME" || exit 1
rm -rf "$SCRATCH"

echo "GRASP MPI job finished at $(date)"
exit "$EXIT_STATUS"
