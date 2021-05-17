echo "
#
# Configuration of environment for XEMMSB2021 course
#
XEMMSB_dir=$1
# For plumed
export PATH=\$PATH:\$XEMMSB_dir/plumed2/bin
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\$XEMMSB_dir/plumed2/lib
export PLUMED_KERNEL=\$PLUMED_KERNEL:\$XEMMSB_dir/plumed2
# For gromacs
source \$XEMMSB_dir/gromacs-2019.4/bin/GMXRC
# For packmol
export PATH=\$PATH:\$XEMMSB_dir/packmol
# For Julia
export PATH=\$PATH:\$XEMMSB_dir/julia-1.6.0/bin
" > setenv_tmp.sh
mv -f setenv_tmp.sh setenv.sh
