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
simulations=Simulations
mkdir -p $simulations
```

## <a name="config"></a>2. Configuração inicial do sistema

O primeiro passo para a realização da simulação é definir qual o sistema que será simulado. Para o nosso caso, iremos simular dois sistemas. Um composto pelo peptídeo `(AAQAA)3` e água. Outro pelo mesmo peptídeo solvatado por uma solução aquosa de 60%v/v do 2,2,2-Trifluoretanol (TFE). Criaremos uma caixa cúbica com 56 &angstrom; de lado em ambos casos.

### 2.1. Atalho

A criação dos arquivos de configuração das duas simulações pode ser feita executando o script `build_system.sh`:

```
$repo/Simulations/build_system.sh $repo $work
```

Isto criará o diretório `Simulations` e, dentro dele, duas pastas `AAQAA_0vv` e `AAQAA_60vv`. Dentro de cada pasta serão encontrados diretórios de nome `build_system` com dois arquivos: `box.inp` e `topology.top`. O primeiro contém o arquivo de input para o `packmol`. O segundo contém a topologia do sistema, usada na simulação.

### 2.2. Passo a passo

A criação da caixa de simulação envolve criar coordenadas iniciais para todos os átomos envolvidos (peptideo, água, cossolvente), nas concentrações desejadas.   

Nosso peptídeo, de sequência `(AAQAA)₃` tem aproximadamete 26Å de comprimento. Vamos criar uma caixa que contenha esse peptídeo e mais 15Å de solvente no mínimo em cada direção. Portanto, vamos criar uma caixa com `26+30=56Å`. É razoável, como primeira aproximação, assumir que o volume ocupado por cada tipo de molécula na caixa é proporcional à sua massa molar. 

Com essa aproximação, podemos estimar o volume ocupado pelo peptídeo se a densidade do sistema é a densidade da água (1.00 g/mL) ou a densidade da solução de água com TFE (1.33 g/mL). Em seguida, podemos calcular qual a fração do volume que a solução ocupa, a o número de moléculas de cossolvente e, por fim, o número de moléculas de água que cabem no volume restante da solução. 

Um [pequeno programa](https://github.com/m3g/XEMMSB2021/blob/main/Simulations/JuliaScripts/CreateInputs.jl) que faz essas contas está disponível aqui, caso queria ver os detalhes. 





(ADICIONAR OBSERVAÇÃO PARA OSISTEMA APENAR COM ÁGUA)

Para executar este script para fazer:
```
julia input-tfe-60.jl
```

Como resultado, dois novos arquivos serão gerados `box.inp` e `topol.top`. O arquivo `box.inp` será usado como input do [Packmol](http://m3g.iqm.unicamp.br/packmol), enquando `topol.top` conterá todos os parâmetros de topologia do nosso sistema, mais adiante voltaremos neste arquivos.

Assim, para finalmente criarmos nosso sistema inicial, usamos o seguinte comando:

```
packmol < box.inp > box.log
```
O output do comando acima será o arquivo `system.pdb`. Este pdb contém todos os átomos que compõem o sistema e pode ser visualizado por meio de softwares como o `vmd` e o `PyMOL` fazendo:

```
vmd system.pdb

ou

pymol system.pdb
```

Agora que possuímos um arquivo pdb para o nosso sistema inicial, devemos nos atentar para a topologia.  O arquivo topol.top possui toda a informação referente aos parâmetros do campo de força do sistema. 
Aqui existem alguns pontos importantes
* O arquivo topol.top, na forma com que é apresentado, não é montado automaticamente pelo gromacs. Isto deve-se ao fato que estamos usando parâmetros que não estão contidos no gromacs para o TFE.
* O campo de força utilizado para o peptídeo é o amber03w e o modelo para para a água é o tip4p2005. Os parâmetros para o TFE também são do tipo amber e estão no arquivo `tfe.itp`.
* O arquivo `topol_back.top` é usado pelo script  `input-tfe-60.jl` para criar a topologia (`topol.top`) como o número correto de moléculas do sistema. 


### Minimização

Faça o download do script `minimization.sh`, crie o diretório de saída desejado, e execute:

```
chmod +x ./minimization.sh
./minimization.sh /home/user/path/output_dir
```

### Gerando arquivos de entrada para as simulações







Apesar do passo acima possibilitar a execução de todas as etapas da simulação que estamos nos propondo a fazer, é interessante analisar o que acontece em cada etapa para uma melhor compreensão do método.

Resumidamente, a simulação é composta pelas seguintes etapas:

* [Configuração inicial do sistema](#config)
* [Minimização](#min)
* [Equilibração da temperatura e da pressão](#equi)
* [Produção - HREMD](#prod)


Detalhes para um simulação básica usando o gromacs podem ser encontrados no tutorial [gromacs_simulations](http://www.mdtutorials.com/gmx/lysozyme/01_pdb2gmx.html)



## 3. Descrição das etapas de simulação e dos arquivos de input.

### <a name="min"></a>Minimização do sistema
Agora que os arquivos iniciais estão organizados, podemos partir para a etapa de minimização. Precisamos criar um arquivo `.tpr` para o gromacs. O arquivo tpr é um binário usado para iniciar a simulação que contém informações sobre a estrutura inicial da simulação, a topologia molecular e todos os parâmetros da simulação (como raios de corte, temperatura, pressão, número de passos, etc.).

Para a etapa de minimização, usaremos os arquivos `topol.top` e `mim.mdp` (que possui todos os parâmetros para realizar uma minimização). Assim, para criar o arquivo tpr, usamos o comando:

```
gmx_mpi grompp -f mim.mdp -c system.pdb -p topol.top -o minimization.tpr -pp processed.top -maxwarn 1
```
O arquivo `processed.top` é importante para a utilização do software Plumed, sua utilização detalhada posteriormente. Agora temos o arquivo `minimization.tpr` e para realizar a minimização usamos o comando:

```
gmx_mpi mdrun -s minimization.tpr -v -deffnm minimization

```
A minimização terá finalizado quando for printado no prompt algo semelhante à:

![Alt Text](https://github.com/m3g/XEMMSB2021/blob/main/Simulation/figs/fim_minimizacao.png)

Agora, temos os seguintes arquivos:

* [minimization.gro]: Coordenadas do sistema minimizado. 
* [minimization.edr]: Arquivo binário da energia do sistema.
* [minimization.log]: Arquivo de texto ASCII do processo de minimização. 
* [minimization.trr]: Arquivo binário da trajetória (alta precisão).

Para a continuação da simulação, vamos utilizar o arquivo `minimization.gro` e a topologia `processed.top`.

### <a name="equi"></a>Equilibração da temperatura e da pressão

Agora, faremos alterações no arquivo de topologia para realizar simulações de equilibração nos ensembles NVT e NPT.

Vamos, agora, utilizar o arquivo `processed.top` gerado na criação do arquivo minimization.tpr. As simulações serão realizadas na temperatura de 300K e pressão de 1 bar. Sendo assim, o primeiro passo é alterar nos arquivos (nvt.mdp, npt.mdp e prod.mdp) a variável REFT para 300 (isso é feito pelo script run-md.sh. Como estamos fazendo por etapas, devemos realizar essa troca manualmente). Em seguida, copiamos todos os arquivos mdp para cada 4 pastas diferentes. Cada pasta representa uma réplica que será simulada usando um hamiltoniano diferente (obs: o arquivo prod.mdp será usado na etapa final).

Assim, para copiar os arquivos fazemos:
```
echo {0..3} | xargs -n 1 cp nvt.mdp npt.mdp prod.mdp plumed.dat
```
O comando acima copia os arquivos nvt.mdp, npt.mdp, prod.mdp e plumed.dat (discutido posteriormente) para as pastas 0/, 1/, 2/ e 3/.

O próximo passo, agora, é escalonar a temperatura de acordo com os hamiltonianos.
Esse "escalonamento" consiste em multiplicar os parâmetros do campo força por um fator entre 0 e 1. Aqui vamos usar 4 hamiltonianos: 1.0, 0.96, 0.93, 0.89 .

Nesta etapa, é importante selecionar os átomos que irão ser escalonados. Para isso, adicionamos um underline na frente dos átomos que queremos "aquecer" (*). Na simulação tratadas neste curso, os átomos que serão escalonados são aqueles que compõem o polipeptídeo.

----------------------
(*)
O termo aquecer é usado pois a multiplicação dos parâmetros do campo de força pelo hamiltoniano diminui a interação entre as partículas, “afrouxando” o potencial. Esta ação é como se aumentássemos a temperatura. Porém, como a temperatura é um prop…. (decidir se vale a pena colocar isso)

----------------------

Se você digitar `vi processed.top` e procurar pela proteína, encontrará o seguinte:
```
[ moleculetype ]
; Name            nrexcl
Protein_chain_X     3

[ atoms ]
;   nr       type  resnr residue  atom   cgnr     charge       mass  typeB    chargeB      massB
; residue   1 ALA rtp NALA q +1.0
     1         N3     1    ALA      N      1     0.1414      14.01
     2          H     1    ALA     H1      2     0.1997      1.008
     3          H     1    ALA     H2      3     0.1997      1.008
     4          H     1    ALA     H3      4     0.1997      1.008

```

O que precisa ser feito é adicionar _ na frente do nome de cada átomo da proteína, assim:


```

[ moleculetype ]
; Name            nrexcl
Protein_chain_X     3

[ atoms ]
;   nr       type  resnr residue  atom   cgnr     charge       mass  typeB    chargeB      massB
; residue   1 ALA rtp NALA q +1.0
     1         N3_     1    ALA      N      1     0.1414      14.01
     2          H_     1    ALA     H1      2     0.1997      1.008
     3          H_     1    ALA     H2      3     0.1997      1.008
     4          H_     1    ALA     H3      4     0.1997      1.008
                                    .
                                    .
                                    .

```
Feito isso, devemos escalonar as topologias que serão usadas para as diferentes réplicas.

```
cd $XEMMSB_dir_MD/0
plumed partial_tempering 1.0 < processed.top > topol0.top
cd $XEMMSB_dir_MD/1
plumed partial_tempering 0.96 < processed.top > topol1.top
cd $XEMMSB_dir_MD/2
plumed partial_tempering 0.93 < processed.top > topol2.top
cd $XEMMSB_dir_MD/3
plumed partial_tempering 0.89 < processed.top > topol3.top
   
```
Mais informações podem ser obtidas em [plumed](https://www.plumed.org/doc-v2.6/user-doc/html/hrex.html).

O método que está sendo utilizado consiste em uma simulação de dinâmica molecular com amostragem conformacional ampliada. Basicamente, os potenciais de interação intramolecular e proteína-solvente são multiplicados por um fator chamado hamiltoniano, comumente representado pela letra grega &lambda; . Desta forma, a multiplicação dos potenciais pelo &lambda fará com que o sistema possua uma temperatura efetiva Ti. 
O fator de escalonamento &lambada; e as temperaturas efetivas Ti da i-ésima réplica são dados por: 

<img src="https://render.githubusercontent.com/render/math?math=\lambda_{i} =\frac{ T_{0}}{T_{i}}=exp(\frac{-i}{n-1} \ln(\frac{T_{max}}{T_{0}}))">

###(Não consegui colocar latex aqui, se o senhor souber peço que mude como achar melhor)
onde &lambda;i é o fator de escalonamento da i-ésima replicata, n é o número de replicatas, Ti é a temperatura efetiva, T0 é a temperatura inicial e Tmax é a temperatura máxima efetiva.

Temos, então, 4 simulações diferentes (uma simulação para cada réplica). Contudo, para as análises, apenas a réplica de menor grau será utilizada (`&lambda; = 1`). 

Feito o escalonamento das topologias e com todos os arquivos em seus respectivos diretórios, vamos criar o arquivo tpr que irá iniciar uma equilibração de 1 ns no ensemble NVT para cada réplica.

```
for i in 0 1 2 3; do
  gmx_mpi grompp -f $i/nvt$i.mdp -c minimization.gro  -p $i/topol$i.top -o $i/canonical.tpr -maxwarn 1
done

```
A flag maxwarn serve para ignorar os avisos que o gromacs dá. Muitos desses avisos são coisas que não tem impacto nenhum na simulação. Entretanto, é recomendado rodar, na primeira vez, sem essa flag para observar o que o gromacs está reportando. Alguns dos avisos podem ser potencialmente danosos para sua simulação, como, por exemplo, um sistema que não está eletricamente neutro. Mais informações podem ser obtidas em [Errors](https://www.gromacs.org/Documentation_of_outdated_versions/Errors).

Agora que todos os arquivos tpr foram gerados, podemos iniciar a simulação da equilibração NVT fazendo:

```
mpirun -np 4 gmx_mpi mdrun -s canonical.tpr -v -deffnm canonical -multidir 0 1 2 3

```
A flag -np indica o número de processos que serão iniciados. Neste caso, cada processo será uma réplica. O mpirun fará a distribuição de processadores disponíveis em seu computador para cada processo de forma automática.

#Colocar alguma coisa para as pessoas saberem se a simulação terminou

A etapa de equilibração NPT usa, essencialmente, os mesmos comandos, apenas alterando os inputs:

```
for i in 0 1 2 3; do
  gmx_mpi grompp -f $i/npt$i.mdp -c canonical.gro  -p $i/topol$i.top -o $i/isobaric.tpr -maxwarn 1
done


```
Após os arquivos `isobaric.tpr` serem criados (em cada pasta da réplica deve haver um arquivo `isobaric.tpr`), vamos usar o comando abaixo para realizar a equilibração da temperatura:


```
mpirun -np 4 gmx_mpi mdrun -s canonical.tpr -v -deffnm canonical -multidir 0 1 2 3
```


### <a name="prod"></a>Produção - HREMD

(melhorar)

Resumidamente, estamos fazendo várias simulações simultâneas que diferenciam-se pelos potenciais de interação intramolecular da proteína e da proteína com o solvente. Esta diferença decorre do método de escalonamento que fizemos na etapa de equilibração com os valores de &lambda; . Assim, o método baseia-se no princípio que simulações que foram escalonadas com um &lambda; menor poderão amostrar conformações diferentes que não seriam visitadas na simulação normal (réplica 0). Por meio de uma troca de coordenadas que acontece periodicamente (no nosso caso as  tentativas dão-se a cada 400 passos da simulação, o que dão tentativas ocorrendo a cada 0.8 ps), as conformações amostradas nas réplicas de maior ordem podem ir sendo trocadas com as réplicas vizinhas até chegar na réplica 0, aumentando a capacidade de amostragem na simulação.


Agora, com a minimização e as equilibrações finalizadas, podemos então criar os arquivos tpr para as simulações de produção.

```
for i in 0 1 2 3; do
  gmx_mpi grompp -f $i/prod$i.mdp -p $i/topol$i.top -c $i/isobaric.gro  -o $i/production.tpr -maxwarn 1
done
```

Assim, 2 ns de simulação de produção poderão feitos por meio do comando:


```
 mpirun -np $rep gmx_mpi mdrun -plumed plumed.dat -s production.tpr -v -deffnm production -multidir 0 1 2 3  -replex 400 -hrex -dlb no
```




## 3. Verificação dos resultados

### probabilidades de troca
Com sorte, nenhum problema ocorreu e agora a simulação foi finalizada... 


### visualização da trajetória
Para visualizar sua trajetória no vmd é necessário processar os dados para uma visualização correta. Os arquivos importantes para a visualização são o frame com a configuração final, `production.gro`, e a trajetória, `production.xtc`. Assim, precisamos usar o comando:
```
    for a in "gro" "xtc"; do
      echo 1 0 |gmx trjconv -s  production.tpr -f production."$a" -o processed."$a" -ur compact -pbc mol -center
     done
```
Com os arquivos `processed.gro` e `processed.xtc` podemos usar o vmd para visualizar a trajetória:

```
vmd processed.gro processed.xtc

```































































































































































































