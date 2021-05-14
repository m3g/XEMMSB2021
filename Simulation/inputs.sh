#!/bin/bash

output_dir=$1
if [ -z "$output_dir" ]; then
  echo "Run with: ./install.sh /home/user/installation_dir"
  exit
fi

if [[ ! -d "$output_dir" ]]; then
    echo "$output_dir_dir does not exist. Create it first. "
    exit
fi

n=4
T0=300.0
Tm=425.0
lambda=`julia -e "println.([exp((-i/($n-1))*log($Tm/$T0)) for i in 0:($n-1)])"`

i=-1
for l in $lambda; do
  i=`expr $i + 1`

  out="$output_dir/$i"

  mkdir -p $out
  cp plumed.dat $out

  for simulation in "nvt" "npt" "prod"; do
    cp ../mdp_files/$simulation.mdp $out
  done

  plumed partial_tempering $l < processed.top > $out/topology.top
  
  # canonical.tpr is the file needed by gromacs to simulate
  gmx_mpi grompp -f $out/nvt.mdp -c minimization.gro -p $out/topology.top -o $out/canonical.tpr -maxwarn 3

done
