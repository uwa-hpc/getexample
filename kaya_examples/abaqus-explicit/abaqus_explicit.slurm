#!/bin/bash --login
#SBATCH --job-name=GE-abaqus-explicit
#SBATCH --partition=work
#SBATCH --nodes=1
# -N is equivalent to --nodes
# -n is equivalent to --ntasks
#SBATCH --ntasks=36
#SBATCH --ntasks-per-node=36
#SBATCH --mem-per-cpu=10g
#SBATCH --time=00:30:00
#SBATCH --export=NONE

# Load the ABAQUS environment
module load abaqus/2025

# Leave in, it lists the environment loaded by the modules
module list

# Note: SLURM_JOBID is a unique number for every job.
# These are generic variables
cd ${SLURM_SUBMIT_DIR}
INPUT=e4

SCRATCH=$MYSCRATCH/run_abaqus/$SLURM_JOBID
RESULTS=$MYGROUP/abaqus_results

### Need to unset this for ABAQUS MPI/threading compatibility
unset SLURM_GTIDS

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

#############################################
# Copy input files to $SCRATCH
# then change directory to $SCRATCH
printf 'current directory is  %s\n' "$(pwd)"
cp ${INPUT}.inp $SCRATCH/.
cd $SCRATCH

### Create ABAQUS environment file in $SCRATCH for current job
env_file=abaqus_v6.env

cat << EOT > ${env_file}
verbose = 1
EOT

node_list=$(scontrol show hostname ${SLURM_NODELIST} | sort -u)

mp_host_list="["
for host in ${node_list}; do
    mp_host_list="${mp_host_list}['$host', ${SLURM_CPUS_ON_NODE}],"
done

mp_host_list=$(printf '%s\n' "$mp_host_list" | sed -e "s/,$/]/")

printf 'mp_host_list=%s\n' "$mp_host_list" >> "$env_file"

export OMP_NUM_THREADS=1

abaqus interactive job=${INPUT} cpus=${SLURM_NTASKS} \
        scratch=. mp_mode=threads

if [ $? -ne 0 ]; then
    cd
    OUTPUT2=kaya_results.log
    printf 'abaqus-explicit (%s) with jobID %s Failed\n' "$INPUT" "$SLURM_JOBID" >> "$OUTPUT2"
else
    cd
    OUTPUT2=kaya_results.log
    printf 'abaqus-explicit (%s) with jobID %s Succeeded\n' "$INPUT" "$SLURM_JOBID" >> "$OUTPUT2"
fi

cd $SCRATCH

#############################################
# Copy results directory to $MYGROUP/abaqus_results/$SLURM_JOBID
cp -r ${SCRATCH} ${RESULTS}

cd $HOME

###########################
# Clean up $SCRATCH
rm -r $SCRATCH

printf 'abaqus job finished at %s\n' "$(date)"
