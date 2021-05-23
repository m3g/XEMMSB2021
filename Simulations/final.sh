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

\cp -f $repo/Simulations/Final/production0.xtc $work/AAQAA_0vv/0/
\cp -f $repo/Simulations/Final/production0.tpr $work/AAQAA_0vv/0/
\cp -f $repo/Simulations/Final/system0.pdb $work/AAQAA_0vv/

\cp -f $repo/Simulations/Final/production60.xtc $work/AAQAA_60vv/0/
\cp -f $repo/Simulations/Final/production60.tpr $work/AAQAA_60vv/0/
\cp -f $repo/Simulations/Final/system60.pdb $work/AAQAA_60vv/

cd $current_dir


