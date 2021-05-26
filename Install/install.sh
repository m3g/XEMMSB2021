#!/bin/bash

repo=$1
work=$2

if [ -z "$work" ]; then
  echo "Run with: ./install.sh \$repo \$work"
  exit
fi

if [[ ! -d "$work" ]]; then
    echo "$work does not exist. Create it first. "
    exit
fi


## 1. Instalação das dependências: `open-mpi`, `gfortran`, `gcc`, `cmake`, `dssp`

cd $work
mkdir -p Downloads
sudo apt-get update -y
sudo apt-get install -y gfortran gcc libopenmpi-dev openmpi-bin cmake dssp gawk

## 2. Instalação do Plumed

cd $work
wget https://github.com/plumed/plumed2/archive/refs/tags/v2.5.5.tar.gz
mv -f v2.5.5.tar.gz ./Downloads
tar -xzf ./Downloads/v2.5.5.tar.gz
cd plumed2-2.5.5
./configure --prefix=$work/plumed2
make -j 4
make install

export PATH=$PATH:/$work/plumed2/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$work/plumed2/lib
export PLUMED_KERNEL=$PLUMED_KERNEL:$work/plumed2

## 3. Instalação do Gromacs

cd $work
wget ftp://ftp.gromacs.org/pub/gromacs/gromacs-2019.4.tar.gz
mv -f gromacs-2019.4.tar.gz ./Downloads
tar -xzf ./Downloads/gromacs-2019.4.tar.gz
cd gromacs-2019.4
plumed-patch -p -e gromacs-2019.4
mkdir build
cd build
cmake .. -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=OFF -DGMX_MPI=ON -DGMX_GPU=OFF -DCMAKE_C_COMPILER=gcc -DGMX_FFT_LIBRARY=fftpack -DCMAKE_INSTALL_PREFIX=$work/gromacs-2019.4
make -j 4
make install
source $work/gromacs-2019.4/bin/GMXRC

# 4. Instalação do Packmol

cd $work
wget http://leandro.iqm.unicamp.br/m3g/packmol/packmol.tar.gz
mv -f packmol.tar.gz ./Downloads
tar -xzf ./Downloads/packmol.tar.gz
cd packmol
make
make clean

# 5. Instalação de Julia

cd $work
wget https://julialang-s3.julialang.org/bin/linux/x64/1.6/julia-1.6.0-linux-x86_64.tar.gz
mv -f julia-1.6.0-linux-x86_64.tar.gz ./Downloads 
tar -xzf ./Downloads/julia-1.6.0-linux-x86_64.tar.gz 

# Adicionando as variáveis de ambiente ao .bashrc

cd $work
cp -f $repo/Install/setenv.sh ./
chmod +x setenv.sh
./setenv.sh $work
echo "" >> ~/.bashrc
echo "# FOR XEMMSB2021" >> ~/.bashrc
echo "source $work/setenv.sh" >> ~/.bashrc

