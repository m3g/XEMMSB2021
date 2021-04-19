#
# Modifique este diretorio:
#
XEMMSB_dir=/home/leandro/Drive/Disciplinas/XEMMSB2021

cd $SEMMSB_dir

## 1. Instalação das dependências: `open-mpi`, `gfortran`, `gcc`, `cmake`

sudo apt-get update -y
sudo apt-get install -y gfortran gcc openmpi-bin cmake

## 2. Instalação do Plumed

wget https://github.com/plumed/plumed2/archive/refs/tags/v2.5.5.tar.gz
tar -xvzf v2.5.5.tar.gz
cd plumed2-2.5.5
./configure --prefix=$XEMMSB_dir/plumed2
make -j 4
make install

### Variáveis de ambiente (podem ser colocadas no `.bashrc`)

## 3. Instalação do Gromacs

wget ftp://ftp.gromacs.org/pub/gromacs/gromacs-2019.4.tar.gz
tar xfz gromacs-2019.4.tar.gz
cd gromacs-2019.4
plumed-patch -p -e gromacs-2019.4
mkdir build
cd build
cmake .. -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=OFF -DGMX_MPI=ON -DGMX_GPU=OFF -DCMAKE_C_COMPILER=gcc -DGMX_FFT_LIBRARY=fftpack -DCMAKE_INSTALL_PREFIX=$XEMMSB_dir/gromacs-2019.4
make -j 4
make install

envfile=$XEMMSB_dir/env.sh
echo "
# Configuration for PLUMED:
XEMMSB_dir=$XEMMSB_dir
export PATH=$PATH:/$XEMMSB_dir/plumed2/bin
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$XEMMSB_dir/plumed2/lib
export PLUMED_KERNEL=$PLUMED_KERNEL:$XEMMSB_dir/plumed2
For Gromacs:
source $XEMMSB_dir/gromacs-2019.4/bin/GMXRC
" > $envfile


