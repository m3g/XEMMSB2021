# XEMMSB 2021

## Simulação de enovelamento de proteínas e efeitos de solvente

O diretório onde tudo será instalado será definido pela variável `XEMMSB_dir`. Por exemplo:

```
XEMMSB_dir=/home/leandro/Drive/Disciplinas/XEMMSB2021
```

Redefina esta variável para instalar no diretório de sua preferência.

## 1. Instalação das dependências: `open-mpi`, `gfortran`, `gcc`, `cmake`

```
sudo apt-get update -y
sudo apt-get install -y gfortran gcc open-mpi cmake
```

Caso no seu sistema esteja instalado um `cmake` antigo (testamos com a versão `3.16.3` que estava instalada no Linux Mint 20.1), é possível que você tenha problemas. Nesse caso, instale a versão mais recente, seguindo as instruções abaixo:

```
wget https://cmake.org/files/v3.20/cmake-3.20.1.tar.gz
tar -zxvf cmake-3.20.1.tar.gz
cd cmake-3.20.1
mkdir build
cd build
sudo   ../configure  --prefix=$XEMMSB_dir/cmake
sudo make
sudo make install
```

## 2. Instalação do Plumed

```
wget https://github.com/plumed/plumed2/archive/refs/tags/v2.5.5.tar.gz
tar -xvzf v2.5.5.tar.gz
cd plumed2-2.5.5
./configure --prefix=$XEMMSB_dir/plumed2
make -j 4
make install
```

### Variáveis de ambiente (podem ser colocadas no `.bashrc`)

```
XEMMSB_dir=/home/leandro/Drive/Disciplinas/XEMMSB2021
export PATH=$PATH:/$XEMMSB_dir/plumed2/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$XEMMSB_dir/plumed2/lib
export PLUMED_KERNEL=$PLUMED_KERNEL:$XEMMSB_dir/plumed2
```

## 3. Instalação do Gromacs

```
wget ftp://ftp.gromacs.org/pub/gromacs/gromacs-2019.4.tar.gz
tar xfz gromacs-2019.4.tar.gz
cd gromacs-2019.4
plumed-patch -p -e gromacs-2019.4
mkdir build
cd build
cmake .. -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=OFF -DGMX_MPI=ON -DGMX_GPU=OFF -DCMAKE_C_COMPILER=gcc -DGMX_FFT_LIBRARY=fftpack -DCMAKE_INSTALL_PREFIX=$XEMMSB_dir/gromacs-2019.4
make -j 4
make check
make install
source $XEMMSB_dir/bin/GMXRC
```

### Para Gromacs


## 5. Teste

Se tudo correu bem, execute o comando:

```
gmx_mpi mdrun -h
```

Deverá aparecer no terminal uma série de comandos da função `mdrun`. Note se a opção `-hrex` aparece:

```
 -[no]hrex                  (no)

           Enable hamiltonian replica exchange
```

Se esta opção não aparece em absoluto, houve algum problema com a instalação acoplada ao `plumed`.










