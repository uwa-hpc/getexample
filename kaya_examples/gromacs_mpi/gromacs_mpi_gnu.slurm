#!/bin/bash -l
#SBATCH --job-name=gromacs_mpi
#SBATCH --partition=admin
#SBATCH --nodes=1
#SBATCH --ntasks=36
#SBATCH --mem-per-cpu=10G
#SBATCH --time=00:40:00
#SBATCH --export=ALL

set -e

# Load the gcc compiler and gromacs/2020.4
module load gcc/9.4.0
module load gromacs/2020.4

# Leave in, it lists the environment loaded by the modules
module list

echo "Submission directory: $SLURM_SUBMIT_DIR"

# Note: SLURM_JOBID is a unique number for every job.
EXECUTABLE=gmx
SCRATCH="$MYSCRATCH/run_gromacs/$SLURM_JOBID"
RESULTS="$MYGROUP/gromacs_results"
SOURCE="$GE_DIR/src/gromacs"

OUTFILE=1AKI_processed.gro
PDB_FILE=1AKI.pdb
OUTPUT=gromacs_mpi.log

###############################################
# Create scratch and results directories

mkdir -p "$SCRATCH"
mkdir -p "$RESULTS"

echo "SCRATCH is $SCRATCH"
echo "Results directory is $RESULTS"

###############################################
# Copy input files to scratch

cp "$SOURCE/$PDB_FILE" "$SCRATCH/"

cd "$SCRATCH"

echo "GROMACS input files copied successfully."

###############################################
# Download required GROMACS parameter files

BASE_URL="http://www.mdtutorials.com/gmx/lysozyme/Files"

for file in ions.mdp minim.mdp nvt.mdp npt.mdp md.mdp; do
    wget -O "$file" "$BASE_URL/$file"
done

###############################################
# Generate processed protein structure and topology

gmx pdb2gmx -f "$PDB_FILE" -o "$OUTFILE" -water spce << EOF
15
0
EOF

###############################################
# Define simulation box

gmx editconf -f 1AKI_processed.gro -o 1AKI_newbox.gro \
    -c -d 1.0 -bt cubic > "$OUTPUT"

###############################################
# Solvate protein

gmx solvate -cp 1AKI_newbox.gro -cs spc216.gro \
    -o 1AKI_solv.gro -p topol.top >> "$OUTPUT"

###############################################
# Add ions

gmx grompp -f ions.mdp -c 1AKI_solv.gro \
    -p topol.top -o ions.tpr >> "$OUTPUT"

gmx genion -s ions.tpr -o 1AKI_solv_ions.gro \
    -p topol.top -pname NA -nname CL -nn 8 << EOF
13
EOF

###############################################
# Energy Minimization

gmx grompp -f minim.mdp -c 1AKI_solv_ions.gro \
    -p topol.top -o em.tpr >> "$OUTPUT"

gmx mdrun -v -deffnm em -g energy.log >> "$OUTPUT"

gmx energy -f em.edr -o potential.xvg << EOF
10
0
EOF

###############################################
# Equilibration: NVT

gmx grompp -f nvt.mdp -c em.gro -r em.gro \
    -p topol.top -o nvt.tpr

gmx mdrun -deffnm nvt

gmx energy -f nvt.edr -o temperature.xvg << EOF
16
0
EOF

###############################################
# Equilibration: NPT

gmx grompp -f npt.mdp -c nvt.gro -r nvt.gro \
    -t nvt.cpt -p topol.top -o npt.tpr

gmx mdrun -deffnm npt

gmx energy -f npt.edr -o pressure.xvg << EOF
18
0
EOF

gmx energy -f npt.edr -o density.xvg << EOF
24
0
EOF

###############################################
# Production MD

gmx grompp -f md.mdp -c npt.gro -t npt.cpt \
    -p topol.top -o md_0_1.tpr

gmx mdrun -deffnm md_0_1

###############################################
# Analysis

gmx trjconv -s md_0_1.tpr -f md_0_1.xtc \
    -o md_0_1_noPBC.xtc -pbc mol -center << EOF
1
0
EOF

# RMSD calculations

gmx rms -s md_0_1.tpr -f md_0_1_noPBC.xtc \
    -o rmsd.xvg -tu ns << EOF
4
EOF

# RMSD relative to the crystal structure

gmx rms -s em.tpr -f md_0_1_noPBC.xtc \
    -o rmsd_xtal.xvg -tu ns << EOF
4
EOF

# Radius of gyration

gmx gyrate -s md_0_1.tpr -f md_0_1_noPBC.xtc \
    -o gyrate.xvg << EOF
1
EOF

###############################################
# Save output to the results directory

cp "$OUTPUT" "$RESULTS/"

echo "GROMACS job finished at $(date)"

###############################################
# Clean up scratch

cd "$HOME"
# rm -r "$SCRATCH"
