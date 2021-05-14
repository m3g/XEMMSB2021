#!/bin/bash

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
if [ -z "$repo" ]; then
  # or let us use the github server files directly
  repo="https://raw.githubusercontent.com/m3g/XEMMSB2021/main/Simulation"
  fetch=wget
  target=""
else
  fetch=cp
  target="./"
fi

current_dir=`pwd`

cd $output_dir

for system in "AAQAA_60vv" "AAQAA_0vv"; do

  out=$output_dir/$system/minimization
  mkdir -p $output_dir
  mkdir -p $output_dir/$system
  mkdir -p $out

  $fetch $repo/Inputs/$system/minimization.tpr $target
  mv -f minimization.tpr $out

  cd $out
  gmx_mpi mdrun -s minimization.tpr -v -deffnm minimization

done

cd $current_dir
