#!/bin/bash

this_script="build_system"

#
# Repository dir is the first argument, output dir the second argument
#
repo_dir=$1
output_dir=$2
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
    echo "$output_dir_dir does not exist. Create it first. "
    exit
fi


cd $output_dir

for system in "AAQAA_60vv" "AAQAA_0vv"; do

  mkdir -p $system
  mkdir -p $out/$thisscript

  julia $repo_dir/Simulation/JuliaScripts/$system.jl

done

cd $current_dir



