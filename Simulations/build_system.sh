#!/bin/bash

thisscript="build_system"

#
# Repository dir is the first argument, output dir the second argument
#
repo=$1
work=$2
current_dir=`pwd`

if [ -z "$work" ]; then
  echo "Run with: ./$thisscript.sh \$repo \$work"
  exit
fi
if [ -z "$repo" ]; then
  echo "Run with: ./$thisscript.sh \$repo \$work"
  exit
fi

if [[ ! -d "$work" ]]; then
    echo "$work does not exist. Create it first. "
    exit
fi

work=$(readlink -f $work) # expand path if necessary
mkdir -p $work/Simulations

for system in "AAQAA_0vv" "AAQAA_60vv"; do

  cd $work/Simulations

  mkdir -p $system
  mkdir -p $system/$thisscript
  cd $system/$thisscript

  julia $repo/Simulations/JuliaScripts/$system.jl

done

cd $current_dir


