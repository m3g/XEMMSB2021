#!/bin/bash

thisscript="build_system"

#
# Repository dir is the first argument, output dir the second argument
#
repo_dir=$1
output_dir=$(readlink -f $2)
current_dir=`pwd`

if [ -z "$output_dir" ]; then
  echo "Run with: ./$thisscript.sh /home/user/path/repo_dir /home/user/installation_dir"
  exit
fi
if [ -z "$repo_dir" ]; then
  echo "Run with: ./$thisscript.sh /home/user/path/repo_dir /home/user/installation_dir"
  exit
fi

if [[ ! -d "$output_dir" ]]; then
    echo "$output_dir does not exist. Create it first. "
    exit
fi


for system in "AAQAA_60vv" "AAQAA_0vv"; do

  cd $output_dir

  mkdir -p $system
  mkdir -p $system/$thisscript
  cd $system/$thisscript
pwd

  julia $repo_dir/Simulation/JuliaScripts/$system.jl


done

cd $current_dir


