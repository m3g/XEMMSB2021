# Simulação de enovelamento de proteínas e efeitos de solvente

## 1. Diretório de instalação

O diretório onde tudo será instalado será definido pela variável `XEMMSB_dir`. Por exemplo:

```
XEMMSB_dir=/home/leandro/Drive/Disciplinas/XEMMSB2021
```
Redefina esta variável para instalar no diretório de sua preferência.

Crie o diretório:
```
mkdir -p $XEMMSB_dir
```

### 1.1 Estou com sorte

Se você usa `bash`, uma distribuição Linux derivada do Debian (Ubuntu, Mint, etc.), e acha que está com sorte, execute apenas (após definir o diretório acima):

```
wget https://raw.githubusercontent.com/m3g/XEMMSB2021/main/Install/install.sh 
chmod +x ./install.sh
./install.sh $XEMMSB_dir

```

Vai ser requisitada a sua senha, mas é só para instalar, se necessário, alguns pacotes da distribuição, usando `apt`. Após a instalação de tudo, este script acrescentará uma linha ao seu `.bashrc` que define as variáveis de ambiente necessárias. 

Vá direto aos [Testes](#testes) se a instalação funcionou. Alternativamente, siga o passo-a-passo abaixo.

## 2. Instalação das dependências: `openmpi`, `gfortran`, `gcc`, `cmake`

```
sudo apt-get update -y
sudo apt-get install -y gfortran gcc libopenmpi-dev openmpi-bin cmake
```

Caso no seu sistema esteja instalado um `cmake` antigo (testamos com a versão `3.10.2` que estava instalada no Ubuntu 18), é possível que você tenha problemas. Nesse caso, instale a versão mais recente, seguindo as instruções abaixo:

```
cd $XEMMSB_dir
wget https://cmake.org/files/v3.20/cmake-3.20.1.tar.gz
tar -xzf cmake-3.20.1.tar.gz
cd cmake-3.20.1
./configure  --prefix=$XEMMSB_dir/cmake
mkdir build
cd build
make
make install
```

Atenção nos passos seguintes, que será necessário, neste caso, ajustar o caminho para o executável do `cmake` definido acima.

## 3. Instalação do Plumed

[Plumed](https://www.plumed.org/) é um pacote que implementa uma série de algoritmos de simulação e análise, interagindo com outros pacotes de simulação. Usaremos sua implementação do Hamiltonian-Exchange Molecular Dynamics (método de amostragem ampliada):

```
cd $XEMMSB_dir
wget https://github.com/plumed/plumed2/archive/refs/tags/v2.5.5.tar.gz
tar -xzf v2.5.5.tar.gz
cd plumed2-2.5.5
./configure --prefix=$XEMMSB_dir/plumed2
make -j 4
make install
```

### Variáveis de ambiente (podem ser colocadas no `.bashrc`)

Execute estes comandos antes de iniciar a instalação do Gromacs:

```
export PATH=$PATH:/$XEMMSB_dir/plumed2/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$XEMMSB_dir/plumed2/lib
export PLUMED_KERNEL=$PLUMED_KERNEL:$XEMMSB_dir/plumed2
```

## 4. Instalação do Gromacs

[Gromacs](https://www.gromacs.org/) é o programa que usaremos para fazer as simulações.

```
cd $XEMMSB_dir
wget ftp://ftp.gromacs.org/pub/gromacs/gromacs-2019.4.tar.gz
tar -xzf gromacs-2019.4.tar.gz
cd gromacs-2019.4
plumed-patch -p -e gromacs-2019.4
mkdir build
cd build
cmake .. -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=OFF -DGMX_MPI=ON -DGMX_GPU=OFF -DCMAKE_C_COMPILER=gcc -DGMX_FFT_LIBRARY=fftpack -DCMAKE_INSTALL_PREFIX=$XEMMSB_dir/gromacs-2019.4
make -j 4
make install
source $XEMMSB_dir/gromacs-2019.4/bin/GMXRC
```

## 5. Instalação do Packmol

[Packmol](http://m3g.iqm.unicamp.br/packmol) será usado para construção das caixas de simulação, em particular com misturas de solventes.

```
cd $XEMMSB_dir
wget http://leandro.iqm.unicamp.br/m3g/packmol/packmol.tar.gz
tar -xzf packmol.tar.gz
\rm -f packmol.tar.gz
cd packmol
make
```

## 5. Instalação de Julia

[Julia](https://julialang.org) é uma linguagem de programação dinâmica e de alto desempenho na qual foram escritos alguns scripts e o principal programa de análise que usaremos. Pode ser instalada com:

```
cd $XEMMSB_dir
wget https://julialang-s3.julialang.org/bin/linux/x64/1.6/julia-1.6.0-linux-x86_64.tar.gz
tar -xzf julia-1.6.0-linux-x86_64.tar.gz
```

## 6. Variáveis de ambiente:

É necessário definir as variáveis de ambiente para usar os programas. Há duas alternativas: colocar tudo no `.bashrc`, ou no arquivo de configuração da `shell` que você estiver usando. Ou manter um arquivo de ambiente local. Por padrão, aqui vamos criar o arquivo `setenv.sh`, que executado definirá as variáveis de ambiente na `shell` em uso: 

```
cd $XEMMSB_dir
wget  https://raw.githubusercontent.com/m3g/XEMMSB2021/main/Install/setenv.sh
chmod +x setenv.sh
./setenv.sh $XEMMSB_dir
```

Agora, quando abrir uma nova `shell`, vá ao diretório `$XEMMSB_dir` e execute:

```
source setenv.sh
```

Alterntativamente, acrecente a linha acima ao seu `~/.bashrc`:
```
echo "source $XEMMSB_dir/setenv.sh" >> ~/.bashrc
```

Além das variáveis de ambiente, este script colocará no `PATH` os diretórios onde foram instalados o `Packmol` e o `Julia`. 

<a name="testes">

## 7. Teste

### 7.1 Gromacs e plumed

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


### 7.2 Packmol

Execute o comando:

```
packmol  
```

Você deve ver esta saída (aperte Control-C) para sair:

```
################################################################################

 PACKMOL - Packing optimization for the automated generation of
 starting configurations for molecular dynamics simulations.
 
                                                              Version 20.2.1 

################################################################################

  Packmol must be run with: packmol < inputfile.inp 

  Userguide at: http://m3g.iqm.unicamp.br/packmol 

  Reading input file... (Control-C aborts)

```

### 7.3 Julia

Execute o comando:
```
julia
```

que deverá abrir um terminal (REPL) de Julia. Para sair, use `Conrol-d` (ou digite `exit()`).








