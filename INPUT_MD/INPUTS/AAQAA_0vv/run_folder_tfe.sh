#!/bin/bash

#echo "Name of the dir "
#
#read paste
#mkdir $paste
#cd $paste
#
#pdbs=/home/ander/doutorado/aaqaa/PDBS
#scripts=/home/ander/doutorado/aaqaa/scripts
#mdps=/home/ander/doutorado/aaqaa/mdp_files
#
#\cp -f $pdbs/*.pdb   .  
#\cp -f $scripts/* .
#\cp -f $mdps/plumed.dat .
#\cp -f $mdps/mim.mdp .
#\cp -r ../amber03w.ff  . 
#
## creating the box and the topology
#julia input_tfe.jl
#packmol < box.inp

## Generation of the unprocessed topology
#echo 6 | gmx_mpi pdb2gmx -f system.pdb -o model1.gro -p topol.top -ff amber03w
#
## Minimization tpr file and processed topology creation
gmx_mpi grompp -f mim.mdp -c system.pdb -p topol.top -o minimization.tpr -pp processed.top -maxwarn 1
#
for i in 0 1 2 3 4 5 6 7 8 9;do
  mkdir -p "$i"
done
#
echo "You must edit the processed.top file"
