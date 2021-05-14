!/bin/bash

#
# Output dir is the first argument
#
output_dir=$1
if [ -z "$output_dir" ]; then
  echo "Run with: ./install.sh /home/user/installation_dir [optional repo dir]"
  exit
fi

if [[ ! -d "$output_dir" ]]; then
    echo "$output_dir_dir does not exist. Create it first. "
    exit
fi

#
# The second argument may be the directory of a local clone of the XEMMSB2021 repo
#
repo=$2
if [[ ! -d "$repo" ]]; then
  fetch=cp
else
# or let us use the github server files directly
  repo=https://raw.githubusercontent.com/m3g/XEMMSB2021/main/Simulation
  fetch=wget
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
  $fetch $repo/Inputs/plumed.dat
  mv plumed.dat $our

  for simulation in "nvt" "npt" "prod"; do
    $fetch $repo/Inputs/mdp_files/$simulation.mdp
    mv $simulation.mdp $out
  done

  $fetch $repo/Inputs/processed.top
  mv processed.top $out
  plumed partial_tempering $l < $out/processed.top > $out/topology.top
  
  # canonical.tpr is the file needed by gromacs to simulate
  gmx_mpi grompp -f $out/nvt.mdp -c minimization.gro -p $out/topology.top -o $out/canonical.tpr -maxwarn 3

done
