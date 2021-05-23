# Simulação de enovelamento de proteínas e efeitos de solvente

## 1. Definindo o local de trabalho

### 1.1. Diretório de instalação

O diretório trabalharemos será definido pela variável `work`. Por exemplo:

```
work=/home/leandro/Documents/curso
```
Redefina esta variável para instalar no diretório de sua preferência.

Crie o diretório, caso não tenha feito isso antes.
```
mkdir -p $work
```

### 1.2. Faça o dowload dos arquivos do curso

Você pode fazer o download clicando na forma de um arquivo compactado no formato `zip`, clicando em `Code` e `Download Zip`, a partir da [página principal](https://github.com/m3g/XEMMSB2021) do repositório. 

Alternativamente, pode fazer um clone do repositório usando

```
cd $work
git clone https://github.com/m3g/XEMMSB2021
```

Atenção ao nome do diretório onde os arquivos foram copiados. Vamos definir uma variável `$repo` que neste tutorial vai sempre se referir a esse diretório. Por exemplo:

```
% pwd
/home/leandro/Documents/curso

% git clone https://github.com/m3g/XEMMSB2021

% repo=/home/leandro/Documents/curso/XEMMSB2021

```

Assumimos aqui que você tem instalado algum programa de visualização de trajetórias de simulação, como o [VMD](https://www.ks.uiuc.edu/Research/vmd/).  

### 1.3 Estou com sorte

Se você usa `bash`, uma distribuição Linux de 64bits derivada do Debian (Ubuntu, Mint, etc.), e acha que está com sorte, execute apenas (após definir o diretório acima):

```
$repo/Install/install.sh $repo $work
source $work/Install/setenv.sh
```

Vai ser requisitada a sua senha, mas é só para instalar, se necessário, alguns pacotes da distribuição, usando `apt`. Após a instalação de tudo, este script acrescentará uma linha ao seu `.bashrc` que define as variáveis de ambiente necessárias cada vez que você reiniciar um terminal.

Vá direto aos [Testes](#testes) se a instalação funcionou. Alternativamente, siga o passo-a-passo abaixo.

## 2. Instalação das dependências: `openmpi`, `gfortran`, `gcc`, `cmake`, `dssp`

```
sudo apt-get update -y
sudo apt-get install -y gfortran gcc libopenmpi-dev openmpi-bin cmake dssp
```

Os cinco primeiros pacotes são para compilação e desenvolvimento de dependências, e [`dssp`](https://swift.cmbi.umcn.nl/gv/dssp/) é um pacote
que calcula a estrutura secundária de proteínas e será usado nas análises. 

Caso no seu sistema esteja instalado um `cmake` antigo (testamos com a versão `3.10.2` que estava instalada no Ubuntu 18), é possível que você tenha problemas. Nesse caso, instale a versão mais recente, seguindo as instruções abaixo:

```
cd $work
wget https://cmake.org/files/v3.20/cmake-3.20.1.tar.gz
tar -xzf cmake-3.20.1.tar.gz
cd cmake-3.20.1
./configure  --prefix=$work/cmake
mkdir build
cd build
make
make install
```

Atenção nos passos seguintes, que será necessário, neste caso, ajustar o caminho para o executável do `cmake` definido acima.

## 3. Instalação do Plumed

[Plumed](https://www.plumed.org/) é um pacote que implementa uma série de algoritmos de simulação e análise, interagindo com outros pacotes de simulação. Usaremos sua implementação do Hamiltonian-Exchange Molecular Dynamics (método de amostragem ampliada):

```
cd $work
wget https://github.com/plumed/plumed2/archive/refs/tags/v2.5.5.tar.gz
tar -xzf v2.5.5.tar.gz
cd plumed2-2.5.5
./configure --prefix=$work/plumed2
make -j 4
make install
```

### Variáveis de ambiente (podem ser colocadas no `.bashrc`)

Execute estes comandos antes de iniciar a instalação do Gromacs:

```
export PATH=$PATH:/$work/plumed2/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$work/plumed2/lib
export PLUMED_KERNEL=$PLUMED_KERNEL:$work/plumed2
```

## 4. Instalação do Gromacs

[Gromacs](https://www.gromacs.org/) é o programa que usaremos para fazer as simulações.

```
cd $work
wget ftp://ftp.gromacs.org/pub/gromacs/gromacs-2019.4.tar.gz
tar -xzf gromacs-2019.4.tar.gz
cd gromacs-2019.4
plumed-patch -p -e gromacs-2019.4
mkdir build
cd build
cmake .. -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=OFF -DGMX_MPI=ON -DGMX_GPU=OFF -DCMAKE_C_COMPILER=gcc -DGMX_FFT_LIBRARY=fftpack -DCMAKE_INSTALL_PREFIX=$work/gromacs-2019.4
make -j 4
make install
source $work/gromacs-2019.4/bin/GMXRC
```

## 5. Instalação do Packmol

[Packmol](http://m3g.iqm.unicamp.br/packmol) será usado para construção das caixas de simulação, em particular com misturas de solventes.

```
cd $work
wget http://leandro.iqm.unicamp.br/m3g/packmol/packmol.tar.gz
tar -xzf packmol.tar.gz
cd packmol
make
```

## 5. Instalação de Julia

[Julia](https://julialang.org) é uma linguagem de programação dinâmica e de alto desempenho na qual foram escritos alguns scripts e o principal programa de análise que usaremos. Pode ser instalada com:

```
cd $work
wget https://julialang-s3.julialang.org/bin/linux/x64/1.6/julia-1.6.0-linux-x86_64.tar.gz
tar -xzf julia-1.6.0-linux-x86_64.tar.gz
```

## 6. Variáveis de ambiente:

É necessário definir as variáveis de ambiente para usar os programas. Há duas alternativas: colocar tudo no `.bashrc`, ou no arquivo de configuração da `shell` que você estiver usando. Ou manter um arquivo de ambiente local. Por padrão, aqui vamos criar o arquivo `setenv.sh`, que executado definirá as variáveis de ambiente na `shell` em uso: 

```
cd $work
wget https://raw.githubusercontent.com/m3g/work/main/Install/setenv.sh
chmod +x setenv.sh
./setenv.sh $work
```

Agora, quando abrir uma nova `shell`, vá ao diretório `$work` e execute:

```
source setenv.sh
```

Alterntativamente, acrecente a linha acima ao seu `~/.bashrc`:
```
echo "source $work/setenv.sh" >> ~/.bashrc
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

Vamos instalar alguns pacotes que vamos usar em nossas análises, em Julia. Dentro do REPL (da shell) do Julia, digite `]`, e vai aparecer o prompt do gerenciador de pacotes:

```julia
(@v1.6) pkg>
``` 

Para instalar os pacotes, use:
```julia
(@v1.6) pkg> add PDBTools, ComplexMixtures, Plots, LaTeXStrings, StatsPlots, EasyFit
``` 

e
```julia
(@v1.6) pkg> add https://github.com/m3g/PackmolInputCreator.jl
``` 

alugns destes são pacotes desenvolvidos no nosso grupo para manipulação e análise de arquivos PDB, estudo da solvatação em soluções complexas, e um pacote acessorio para gerar os inputs do programa Packmol. Os dois primeiros estão registrados, por isso podem ser instalados diretmente, o último está apenas hospedado no nosso repositório, e deve ser instalado com o domínio completo. `Plots`, `LaTeXStrings`, `StatsPlots` e `EasyFit` são pacotes que nos ajudarão a fazer gráficos.

Para sair da seção de Julia, use `Conrol-d` (ou digite `exit()`).










