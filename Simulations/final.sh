#!/bin/bash

thisscript="final"

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

\cp -f $repo/Simulations/Final/production0.xtc $work/Simulations/AAQAA_0vv/0/production.xtc
\cp -f $repo/Simulations/Final/production0.tpr $work/Simulations/AAQAA_0vv/0/production.tpr
\cp -f $repo/Simulations/Final/system0.pdb $work/Simulations/AAQAA_0vv/system.pdb

\cp -f $repo/Simulations/Final/production60.xtc $work/Simulations/AAQAA_60vv/0/production.xtc
\cp -f $repo/Simulations/Final/production60.tpr $work/Simulations/AAQAA_60vv/0/production.tpr
\cp -f $repo/Simulations/Final/system60.pdb $work/Simulations/AAQAA_60vv/system.pdb

cd $current_dir


