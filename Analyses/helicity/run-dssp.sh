#!/bin/bash

mkdir -p ./DSSP

# Create PDB files for each frame
echo 1 | gmx_mpi trjconv -f production.xtc -s production.tpr -o ./DSSP/dssp$1.pdb -sep

# Compute secondary structure
cd DSSP
for file in `ls dssp*.pdb`; do
  # Compute secondary structure
  mkdssp -i $file -o $file.dssp
done
cd ..

