# Simulação de enovelamento de proteínas e efeitos de solvente

## Etapas:

* [1. Diretório de trabalho](#workdir)
* [2. Configuração inicial do sistema](#config)
* [3. Minimização](#min)
* [4. Equilibração da temperatura e da pressão](#equi)
* [5. Produção - HREMD](#prod)

## <a name="workdir"></a>1. Diretório de trabalho

Lembre-se que estamos considerando que as variáves `repo` e `work` estão definidas, de acordo com a instalação. No exemplo, estamos
usando:

```
work=/home/leandro/Documents/curso
repo=/home/leandro/Documents/curso/XEMMSB2021
```

Define novamente estas variáveis em cada seção, para facilitar (ou coloque estas definições no seu `$work/setenv.sh`).

Vamos criar um diretório onde as simulações vão ser realizadas, e vamos definir a variável `simulations` para fazer referência a este diretório de agora em adiante.

```
cd $work
mkdir -p Simulations
```

## <a name="config"></a>2. Configuração inicial do sistema

O primeiro passo para a realização da simulação é definir qual o sistema que será simulado. Para o nosso caso, iremos simular dois sistemas. Um composto pelo peptídeo `(AAQAA)3` e água. Outro pelo mesmo peptídeo solvatado por uma solução aquosa de 60%v/v do 2,2,2-Trifluoretanol (TFE). Criaremos uma caixa cúbica com 56Å de lado em ambos casos.

### 2.1. Criando a posição inicial das partículas do sistema

A criação dos arquivos de configuração das duas simulações pode ser feita executando o script `build_system.sh`:

```
$repo/Simulations/build_system.sh $repo $work
```

Isto criará o diretório `Simulations` e, dentro dele, duas pastas `AAQAA_0vv` e `AAQAA_60vv`. Dentro de cada pasta será encontrado o arquivoi `box.inp`. Este arquivo contém o de input para o `packmol`.

A criação da caixa de simulação envolve criar coordenadas iniciais para todos os átomos envolvidos (peptideo, água, cossolvente), nas concentrações desejadas.   

Nosso peptídeo, de sequência `(AAQAA)₃` tem aproximadamete 26Å de comprimento. Vamos criar uma caixa que contenha esse peptídeo e mais 15Å de solvente no mínimo em cada direção. Portanto, vamos criar uma caixa com `26+30=56Å`. É razoável, como primeira aproximação, assumir que o volume ocupado por cada tipo de molécula na caixa é proporcional à sua massa molar. 

Com essa aproximação, podemos estimar o volume ocupado pelo peptídeo se a densidade do sistema é a densidade da água (1.00 g/mL) ou a densidade da solução de água com TFE (1.33 g/mL). Em seguida, podemos calcular qual a fração do volume que a solução ocupa, a o número de moléculas de cossolvente e, por fim, o número de moléculas de água que cabem no volume restante da solução. 

Um [pequeno programa](https://github.com/m3g/PackmolInputCreator.jl) que faz essas contas está disponível, caso queria ver os detalhes (é simples, mas muito fácil de errar nas contas). Este programa está sendo usado nos scripts [AAQAA_0vv.jl](https://github.com/m3g/XEMMSB2021/blob/main/Simulations/julia/AAQAA_0vv.jl) e [AAQAA_60v.jl](https://github.com/m3g/XEMMSB2021/blob/main/Simulations/julia/AAQAA_60vv.jl) que são executados quando você executou o comando `build_system.sh`. 

Para criar as caixas, entre cada um dos diretórios e execute:
```
packmol < box.inp
```

Isto vai gerar um arquivo `system.pdb`, contendo todas as moléculas que serão simuladas. Você pode abrir este arquivo em qualquer programa de visualizacão, como VMD ou PyMOL. 

### 2.2. Criando a topologia do sistema: proteina e água

As simulações dependem de um arquivo de topologia, que define a conectividade do sistema e todos os parâmetros necessários para calcular as forças entre átomos do sistema. A criação destes arquivos é diferente para o sistema com água pura (mais simples) e com TFE. 

### Peptídeo em água

Entre no diretório correspondente (`$repo/Simulations/AAAQAA_0vv`), copie o diretório do campo de força para esse diretório:

```
cd $work/Simulations/AAQAA_0vv
cp -r $repo/Simulations/InputData/amber03w.ff ./
```

Em seguida, execute o comando do Gromacs que gera os arquivos necessários para a simulação:
```
gmx_mpi pdb2gmx -f system.pdb -o sytem.gro -p topology.top -ff amber03w -ignh
```
Você vai selecionar o modelo de água `TIP4P2005` para estas simulações. 

Isto deve gerar os seguintes arquivos: 
```
system.gro
posre.itp
topology.top
```

### Peptídeo em solução de água e TFE

Para o sistema com TFE (e qualquer outro cossolvente, como a ureia ou TMAO), é necessário realizar algumas modificações no arquivo de topologia. O arquivo de topologia que o GROMACS gera contém os parâmetros apenas das moléculas (mais comuns) que estão contidas nos campos de força pré-instalados. Sendo assim, é necessário obter os arquivos de topologia separados para o cossolvente de interesse. Vamos entender como essa edição na topologia é feita tomando como exemplo o sistema trabalhado no curso.


Inicialmente, é necessário gerar um arquivo de topologia para a proteína ou peptídeo de interesse. O peptídeo que iremos trabalhar no curso é o (AAQAA)3, cujo arquivo de coordenadas disponível no diretório `$repo/Simulations/InputData/PDB/` é o `AAQAA.pdd`. Portanto, você precisa executar os seguintes comandos: 

```
cd $work/Simulations/AAQAA_60vv
cp -r $repo/Simulations/InputData/amber03w.ff ./
cp $repo/Simulations/InputData/PDB/AAQAA.pdb .
echo 6 | gmx_mpi pdb2gmx -f AAQAA.pdb -o AAQAA.gro -p topology.top -ff amber03w
```
 
O arquivo de topologia “topology.top” terá a seguinte forma:

```
; Informações relacionadas ao computador, versão do GROMACS e diretório em que a topologia foi gerada. 

; Include forcefield parameters
#include "./amber03.ff/forcefield.itp"

[ moleculetype ]
; Name            nrexcl
Protein             3

[ atoms ]
;   nr       type  resnr residue  atom   cgnr     charge       mass  typeB    chargeB      massB
; residue   1 ALA rtp NALA q +1.0
     1         N3      1    ALA      N      1  -0.589266      14.01
     2          H      1    ALA     H1      2   0.446422      1.008
     3          H      1    ALA     H2      3   0.446422      1.008
     4          H      1    ALA     H3      4   0.446422      1.008
     5         CT      1    ALA     CA      5   0.113871      12.01
     6         HP      1    ALA     HA      6    0.06715      1.008
     7         CT      1    ALA     CB      7  -0.204113      12.01
     8         HC      1    ALA    HB1      8   0.063056      1.008
     9         HC      1    ALA    HB2      9   0.063056      1.008
    10         HC      1    ALA    HB3     10   0.063056      1.008
    11          C      1    ALA      C     11   0.676687      12.01
    12          O      1    ALA      O     12  -0.592764         16   ; qtot 1
.
.
.

; Include water topology
#include "./amber03.ff/tip4p2005.itp"

; Include topology for ions
#include "./amber03.ff/ions.itp"

[ system ]
; Name
GROningen MAchine for Chemical Simulation

[ molecules ]
; Compound        #mols
Protein             1
```

As flags `#include` servem para incluir arquivos com os parâmetros do campo de força utilizado para cada componente do sistema. Por exemplo,  para a água a flag é `#include "./amber03w.ff/tip4p2005.itp"` e para os íons é  `#include "./amber03w.ff/ions.itp"`. Portanto, o mesmo deve ser feito para o TFE. 

Para incluir os arquivos de parâmetros do TFE no arquivo `topology.top` você deverá adicionar as expressões `#include "./amber03w.ff/tfe_atomtypes.itp"` e `#include "./amber03w.ff/tfe.itp"`, de acordo com o exemplo abaixo. É importante mencionar que os arquivos `tfe_atomtypes.itp` e `tfe.itp` fornecidos foram retirados de um [trabalho publicado previamente](https://pubs.acs.org/doi/10.1021/jp505861b). Entretanto, caso seja de seu interesse estudar outros cossolventes, você poderá construir o seu próprio arquivo de parâmetros, assim como mencionado no arquivo AdditionalInfo.md, no tópico dos Cossolvente, em $repo/Simulations/AdditionalInfo.md.

```
; Informações relacionadas ao computador, versão do gromacs e diretório em que a topologia foi gerada. 

; Include forcefield parameters
#include "./amber03w.ff/forcefield.itp"

; Include cosolvents topology
#include "./amber03w.ff/tfe_atomtypes.itp"
#include "./amber03w.ff/tfe.itp"

[ moleculetype ]
; Name            nrexcl
Protein             3

[ atoms ]
;   nr       type  resnr residue  atom   cgnr     charge       mass  typeB    chargeB      massB
; residue   1 ALA rtp NALA q +1.0
     1         N3      1    ALA      N      1  -0.589266      14.01
     2          H      1    ALA     H1      2   0.446422      1.008
     3          H      1    ALA     H2      3   0.446422      1.008
     4          H      1    ALA     H3      4   0.446422      1.008
     5         CT      1    ALA     CA      5   0.113871      12.01
     6         HP      1    ALA     HA      6    0.06715      1.008
     7         CT      1    ALA     CB      7  -0.204113      12.01
     8         HC      1    ALA    HB1      8   0.063056      1.008
     9         HC      1    ALA    HB2      9   0.063056      1.008
    10         HC      1    ALA    HB3     10   0.063056      1.008
    11          C      1    ALA      C     11   0.676687      12.01
    12          O      1    ALA      O     12  -0.592764         16   ; qtot 1

```
A última alteração que você precisa fazer em `topology.top` é adicionar o número de moléculas para cada componente do sistema. Como a simulação com TFE possui a concentração igual a `60 %v/v`, teremos 1 peptídeo, 2415 moléculas de água e 868 moléculas de TFE. Sendo assim, altere o final do arquivo `topology.top` adicionando `SOL          2415` e `TFE         868` abaixo da linha `Protein       1`. Seu arquivo deve ter a mesma forma de:

```
; Informações relacionadas ao computador, versão do GROMACS e diretório em que a topologia foi gerada. 

; Include forcefield parameters
#include "./amber03w.ff/forcefield.itp"

; Include cosolvents topology
#include "./amber03w.ff/tfe_atomtypes.itp"
#include "./amber03w.ff/tfe.itp"

[ moleculetype ]
; Name            nrexcl
Protein             3

[ atoms ]
;   nr       type  resnr residue  atom   cgnr     charge       mass  typeB    chargeB      massB
; residue   1 ALA rtp NALA q +1.0
     1         N3      1    ALA      N      1  -0.589266       14.01
     2          H      1    ALA     H1      2   0.446422       1.008
     3          H      1    ALA     H2      3   0.446422       1.008
     4          H      1    ALA     H3      4   0.446422       1.008
     5         CT      1    ALA     CA      5   0.113871     12.01
     6         HP      1    ALA     HA      6    0.06715      1.008
     7         CT      1    ALA     CB      7  -0.204113     12.01
     8         HC      1    ALA    HB1      8   0.063056    1.008
     9         HC      1    ALA    HB2      9   0.063056    1.008
    10         HC      1    ALA    HB3     10   0.063056  1.008
    11          C      1    ALA      C     11   0.676687      12.01
    12          O      1    ALA      O     12  -0.592764       16   ; qtot 1
.
.
.

; Include water topology
#include "./amber03w.ff/tip4p2005.itp"

; Include topology for ions
#include "./amber03w.ff/ions.itp"

[ system ]
; Name
GROningen MAchine for Chemical Simulation

[ molecules ]
; Compound        #mols
Protein             1
SOL               2415
TFE                868
```
Os nomes `SOL` e `TFE` representam algo semelhante ao que seria o nome de um resíduo para as proteínas. Portanto, todas as moléculas de água e cossolvente no arquivo `system.pdb` do sistema devem ser nomeadas com `SOL` e `TFE`, respectivamente. Basicamente, essas alterações representam o que precisa ser feito para ter um arquivo de topologia para as simulações de um sistema contendo a proteína, água e cossolvente (neste caso, o `TFE`). 
Como temos os pdbs individuais para o peptídeo (`AAQAA.pdb`), a água (`tip4p2005.pdb`) e o TFE (`tfe.pdb`), podemos usar o `packmol` para criar uma caixa com o número desejado de cada componente. 

O `system.pdb` resultante deve ser utilizado juntamente da topologia editada como input do gromacs para gerar o arquivos necessários para rodar a simulação. Vale lembrar que a ordem em que os componentes do sistema são descritos no arquivo de topologia devem estar na mesma ordem do arquivo `system.pdb`. 

### <a name="min"></a> 3. Minimização da energia

### 3.1. Gerando arquivos de entrada para as simulações

Entre no diretório de uma das simulações, por exemplo na do peptídeo em água:
```
cd $work/Simulations/AAQAA_0vv
```
(você terá que repetir estas etapas para a outra simulação).

Os arquivos de configuração das simulações do Gromacs têm extensão `.mdp`. A minimização será feita com este arquivo de configuração:

```
;mim.mdp- used as input into grompp to generate em.tpr
;Parameters describing what to do, when to stop and what to save
integrator  = steep         ; Algorithm (steep = steepest descent minimization)
emtol       = 10.0          ; Stop minimization when the maximum force < 100.0 kJ/mol/nm
emstep      = 0.01          ; Minimization step size
nsteps      = 1000          ; Maximum number of (minimization) steps to perform

; Parameters describing how to find the neighbors of each atom and how to calculate the interactions
nstlist         = 1         ; Frequency to update the neighbor list and long range forces
cutoff-scheme   = Verlet    ; Buffered neighbor searching
ns_type         = grid      ; Method to determine neighbor list (simple, grid)
coulombtype     = PME       ; Treatment of long range electrostatic interactions
rcoulomb        = 1.2       ; Short-range electrostatic cut-off
rvdw            = 1.2       ; Short-range Van der Waals cut-off
pbc             = xyz       ; Periodic Boundary Conditions in all 3 dimensions
```

A primeira parte do arquivo descreve o método de minimização da energia e seus parâmetros. A segunda parte do arquivo descreve alguns parâmetros do cálculo de interações.

Copie este arquivo (e outros arquivos de configuração que usaremos) para o diretório de cada simulação usando:

```
cp $repo/Simulations/InputData/mdp_files/* $work/Simulations/AAQAA_0vv
cp $repo/Simulations/InputData/mdp_files/* $work/Simulations/AAQAA_60vv
```

Detalhes para um simulação básica usando o gromacs podem ser encontrados no tutorial [gromacs_simulations](http://www.mdtutorials.com/gmx/lysozyme/01_pdb2gmx.html).

### 3.2. Executando a minimização

Agora que os arquivos iniciais estão organizados, podemos partir para a etapa de minimização. Precisamos criar um arquivo `.tpr` para o gromacs. O arquivo tpr é um binário usado para iniciar a simulação que contém informações sobre a estrutura inicial da simulação, a topologia molecular e todos os parâmetros da simulação (como raios de corte, temperatura, pressão, número de passos, etc.).

Para a etapa de minimização, usaremos os arquivos `topology.top` e `minimization.mdp`. Assim, para criar o arquivo tpr, usamos o comando: 
```
gmx_mpi grompp -f minimization.mdp -c system.pdb -p topology.top -o minimization.tpr -pp processed.top -maxwarn 1
```

Este comando vai gerar os arquivos
```
minimization.tpr
processed.top
```
que são os arquivos nos formatos finais que são usados pelo Gromacs.
O arquivo `processed.top` é importante para a utilização do software Plumed, sua utilização detalhada posteriormente. Agora temos o arquivo `minimization.tpr` e para realizar a minimização usamos o comando:

```
gmx_mpi mdrun -s minimization.tpr -v -deffnm minimization
```
A minimização terá finalizado quando for escrito na tela algo similar a:
```
Step=  997, Dmax= 1.4e-02 nm, Epot= -2.84568e+05 Fmax= 1.19056e+04, atom= 172
Step=  999, Dmax= 8.7e-03 nm, Epot= -2.84649e+05 Fmax= 1.37924e+03, atom= 172
Step= 1000, Dmax= 1.0e-02 nm, Epot= -2.84659e+05 Fmax= 1.45829e+04, atom= 172

Energy minimization reached the maximum number of steps before the forces
reached the requested precision Fmax < 10.

writing lowest energy coordinates.

Steepest Descents did not converge to Fmax < 10 in 1001 steps.
Potential Energy  = -2.8465941e+05
Maximum force     =  1.4582858e+04 on atom 172
Norm of force     =  1.2090649e+02

GROMACS reminds you: "There's Nothing We Can't Fix, 'coz We Can Do It in the Mix" (Indeep)

```
Agora, temos os seguintes arquivos:

* `minimization.gro`: Coordenadas do sistema minimizado. 
* `minimization.edr`: Arquivo binário da energia do sistema.
* `minimization.log`: Arquivo de texto ASCII do processo de minimização. 
* `minimization.trr`: Arquivo binário da trajetória (alta precisão).

Para a continuação da simulação, vamos utilizar o arquivo `minimization.gro` e a topologia `processed.top`.

### <a name="equi"></a>4. Equilibração da temperatura e da pressão

### 4.1. Preparando os arquivos de configuração para o plumed

Vamos copiar todos os arquivos de configuração para 4 pastas diferentes. Cada pasta conterá as simulações de uma réplica que usando um hamiltoniano diferente.

Assim, faremos:
```
mkdir -p 0 1 2 3
echo {0..3} | xargs -n 1 cp nvt.mdp npt.mdp production.mdp plumed.dat
```
O comando acima copia os arquivos `nvt.mdp`, `npt.mdp`, `production.mdp` e `plumed.dat` (discutido posteriormente) para as pastas `0/`, `1/`, `2/` e `3/`.

O programa que vai fazer as modificações no campo de força para simular as réplicas com diferentes Hamiltonianos é o `plumed`. Para indicar a quais átomos aplicaremos o método de aceleração de amostragem, temos que modificar o arquivo `processsed.top`, que contém todos os parâmetros da simulação. Vamos copiar este arquivo em um novo arquivo chamado `processed_.top`, porque precisamos acrescentar `_` em frente ao nome de todos os átomos que serão incluídos na aceleração de amostragem.
```
cd $work/Simulations/AAQAA_0vv
```

Se você digitar `vim processed.top` e procurar por `atoms`, encontrará os átomos da proteína, em uma seção assim:
```
[ atoms ]
;   nr       type  resnr residue  atom   cgnr     charge       mass  typeB    chargeB      massB
; residue   1 ALA rtp NALA q +1.0
     1         N3     1    ALA      N      1     0.1414      14.01
     2          H     1    ALA     H1      2     0.1997      1.008
     3          H     1    ALA     H2      3     0.1997      1.008
     4          H     1    ALA     H3      4     0.1997      1.008
                                  ...
   172          C     15    ALA      C    172     0.7731      12.01
   173         O2     15    ALA    OC1    173    -0.8055         16
   174         O2     15    ALA    OC2    174    -0.8055         16   ; qtot 0
```

É necessário adicionar `_` na frente do nome de cada átomo da proteína (no `vim`, use Control-V, selecione todas as colunas referentes a átomos da proteína na posição seguinte ao nome do átomo, e use `shift-i _`). 

O arquivo resultante deve ficar assim:

```
[ atoms ]
;   nr       type  resnr residue  atom   cgnr     charge       mass  typeB    chargeB      massB
; residue   1 ALA_ rtp NALA q +1.0
     1         N3_     1    ALA      N      1     0.1414      14.01
     2          H_     1    ALA     H1      2     0.1997      1.008
     3          H_     1    ALA     H2      3     0.1997      1.008
     4          H_     1    ALA     H3      4     0.1997      1.008
                                  ...
   172          C_    15    ALA      C    172     0.7731      12.01
   173         O2_    15    ALA    OC1    173    -0.8055         16
   174         O2_    15    ALA    OC2    174    -0.8055         16   ; qtot 0
```

### 4.2. Usando plumed para definir o parâmetro de escalonamento 

Cada réplica terá seu próprio parâmetro de escalonamento do potencial. Geralmente, varia-se este escalonamento entre 0.7 e 1.0, da réplica onde o potencial é mais permissivo (0.7) até o potencial original (1.0). Uma sequência de parâmetros de escalonamento razoável, mais densa nos parâmetros de maior perturbação, pode ser obtida usando a fórmula: 

<img width=300px src=https://user-images.githubusercontent.com/31046348/118821585-c500de00-b88d-11eb-8b80-e907d92a30e1.png>

onde `T₀` e `Tₘ` são as "temperaturas" de referência e temperatura máxima usadas. Usaremos `T₀=300` e `Tₘ=425`. Neste caso, como estamos fazendo réplicas por modificação do potencial, não se trata de variar exatamente a temperatura, mas o conceito é similar. Podemos aplicar esta fórmula e obter o conjunto de parâmetros que vamos usar, com:  
```julia
%julia -e "println.([exp((-i/3)*log(425/300)) for i in 0:3])"
1.0
0.8903841934016186
0.7927840118594509
0.7058823529411764
```

Neste caso ilustrativo são só 4 réplicas. Mas se tivéssemos mais e uma faixa mais ampla de "temperaturas" e mais réplicas, [obteríamos](https://github.com/m3g/XEMMSB2021/blob/main/Simulations/julia/lambda.jl) o seguinte perfil de parâmetros de escalonamento: 

<img src=https://github.com/m3g/XEMMSB2021/raw/main/Simulations/julia/lambda.png>

Nele vemos que os parâmetros variam mais nas temperaturas menores e menos nas temperaturas maiores, onde as flutuações estruturais são maiores. Esta formula procura garantir uma taxa de troca de réplicas uniforme ao longo de toda a faixa de parâmetros estudada.

Feito isso, devemos escalonar as topologias que serão usadas para as diferentes réplicas.

```
plumed partial_tempering 1.00 < processed.top > ./0/topology.top
plumed partial_tempering 0.89 < processed.top > ./1/topology.top
plumed partial_tempering 0.79 < processed.top > ./2/topology.top
plumed partial_tempering 0.71 < processed.top > ./3/topology.top
```

Mais informações podem ser obtidas em [plumed](https://www.plumed.org/doc-v2.6/user-doc/html/hrex.html).

O método que está sendo utilizado consiste em uma simulação de dinâmica molecular com amostragem conformacional ampliada. Basicamente, os potenciais de interação intramolecular da proteína e as interações inter-moleculares proteína-solvente são multiplicados por um fator, comumente representado pela letra grega λ. Desta forma, a multiplicação dos potenciais pelo λ fará com que o sistema seja mais móvel, aproximadamente como se estivesse sendo simulado a uma temperatura mais alta (se a temperatura for o parâmetro efetivamente alterado, o método é o clássico método de trocas de réplicas).

Feito o escalonamento das topologias e com todos os arquivos em seus respectivos diretórios, vamos criar o arquivo tpr que irá iniciar uma equilibração de 1 ns no ensemble NVT para cada réplica.

### 4.3. Executando as simulações de equilibração  

Vamos gerar os arquivos de configuração do Gromacs em cada diretório com o comando abaixo:

```
for dir in 0 1 2 3; do
  cd $dir
  gmx_mpi grompp -f nvt.mdp -c ../minimization.gro  -p topology.top -o canonical.tpr -maxwarn 1
  cd ..
done
```

A flag `maxwarn` serve para ignorar os avisos mensagens de aviso excessivas. Muitos desses avisos são coisas que não tem impacto nenhum na simulação. Entretanto, é recomendado rodar, na primeira vez, sem essa flag para observar o que o gromacs está reportando. Alguns dos avisos podem ser potencialmente danosos para sua simulação, como, por exemplo, aquele de que o sistema que não está eletricamente neutro. Mais informações podem ser obtidas em [Errors](https://www.gromacs.org/Documentation_of_outdated_versions/Errors).

Um arquivo `cannonical.tpr` será gerado em cada diretório, e será usado pelo Gromacs para efetivamente iniciar a simulação.

Podemos iniciar a simulação da equilibração NVT fazendo:

```
mpirun -np 4 gmx_mpi mdrun -s canonical.tpr -v -deffnm canonical -multidir 0 1 2 3
```

A flag -np indica o número de processos que serão iniciados. Neste caso, cada processo será uma réplica. O mpirun fará a distribuição de processadores disponíveis em seu computador para cada processo de forma automática.

A simulação que estamos realizando será curta (5000 passos), apenas para ilustrar o procedimento, e deve demorar alguns minutos em um computador normal. 

A etapa de equilibração NPT usa, essencialmente, os mesmos comandos, apenas alterando os inputs. As simulações NPT usarão a saída das simulações anteriores como input, definidas nos arquivos `canonical.gro`:

```
for dir in 0 1 2 3; do
  cd $dir
  gmx_mpi grompp -f npt.mdp -c canonical.gro  -p topology.top -o isobaric.tpr -maxwarn 1
  cd ..
done
```
Após os arquivos `isobaric.tpr` serem criados (em cada pasta da réplica deve haver um arquivo `isobaric.tpr`), vamos usar o comando abaixo para realizar a equilibração da temperatura:

```
mpirun -np 4 gmx_mpi mdrun -s isobaric.tpr -v -deffnm isobaric -multidir 0 1 2 3
```

Terminadas as etapas de equilibração, faremos a simulação de produção, que efetivamente seria analisada.

### <a name="prod"></a> 5. Produção - HREMD

### 5.1. Executando a simulação de produção

A simulação de produção do exemplo terá o dobro do tempo (20 ps) das anteriores. Você pode aumentar o tempo de simulação modificando o parâmetro `nsteps` dos arquivos `production.mdp`. De todos modos, as análises que faremos serão sobre uma simulação preparada anteriormente e executada em um cluster de computadores do [CCES/Unicamp](http://cces.unicamp.br).


Estamos fazendo várias simulações simultâneas que diferenciam-se pelos potenciais de interação intramolecular da proteína e intermolecular da proteína com o solvente. Esta diferença decorre do método de escalonamento que fizemos na etapa de equilibração com os valores de &lambda;. As simulações com potenciais modificaods por &lambda; menor poderão amostrar conformações diferentes que não seriam visitadas na simulação convencional (réplica 0). Por meio de uma troca de coordenadas que acontece periodicamente (no nosso caso as  tentativas dão-se a cada 400 passos da simulação, (0.8 ps), as conformações amostradas nas réplicas de maior ordem podem ser trocadas com as réplicas vizinhas até chegar na réplica 0, aumentando a capacidade de amostragem na simulação sem modificações no potencial.

Com a minimização e as equilibrações finalizadas, podemos então criar os arquivos `tpr` para as simulações de produção.

```
for dir in 0 1 2 3; do
  cd $dir
  gmx_mpi grompp -f production.mdp -p topology.top -c isobaric.gro  -o production.tpr -maxwarn 1
  cd ..
done
```

As simulações são executadas com:
```
mpirun -np 4 gmx_mpi mdrun -plumed plumed.dat -s production.tpr -v -deffnm production -multidir 0 1 2 3  -replex 400 -hrex -dlb no
```

### 5.2. Verificação dos resultados

As trajetórias geradas para cada uma das réplicas estarão contidas nos arquivos `production.tpr` em cada diretório. Para que a visualização seja mais bonita (com o peptídeo centrado na caixa), vamos criar um novo arquivo, com os seguintes comandos:  

```
cd 0
echo 1 0 |gmx_mpi trjconv -s production.tpr -f production.gro -o processed.gro -ur compact -pbc mol -center
echo 1 0 |gmx_mpi trjconv -s production.tpr -f production.xtc -o processed.xtc -ur compact -pbc mol -center
```
Com os arquivos `processed.gro` e `processed.xtc` podemos usar o vmd para visualizar a trajetória:

```
vmd processed.gro processed.xtc
```

Lembre-se de repetir o procedimento para a simulação da mistura de água e TFE (`AAQAA_60vv`).

## Referências do método HREMD

- Y. Sugita, Y. Okamoto, *Replica-exchange multicanonical algorithm and multicanonical replica-exchange method for simulating systems with rough energy landscape.* Chem. Phys. Lett. 329, 3-4, 2000. [[Text]](https://arxiv.org/pdf/cond-mat/0009119.pdf)

- G. Bussi, *Hamiltonian replica exchange in GROMACS: a flexibile implementation.* 
Molecular Physics, 112, 379-384, 2014. [[Text]](https://www.tandfonline.com/doi/pdf/10.1080/00268976.2013.824126)




