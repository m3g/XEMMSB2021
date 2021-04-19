echo "
# Configuration of environment for XEMMSB2021 course
XEMMSB_dir=$1
export PATH=\$PATH:\$XEMMSB_dir/plumed2/bin
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\$XEMMSB_dir/plumed2/lib
export PLUMED_KERNEL=\$PLUMED_KERNEL:\$XEMMSB_dir/plumed2
source \$XEMMSB_dir/gromacs-2019.4/bin/GMXRC
" > setenv_tmp.sh
mv -f setenv_tmp.sh setenv.sh
