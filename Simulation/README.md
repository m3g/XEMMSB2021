# Simulação de enovelamento de proteínas e efeitos de solvente

IDEIAS INICIAIS -PRECISA ORGANIZAR E CHECAR ALGUMAS INFORMAÇÕES

## 1. Iniciando as simulações

Existem inputs prontos para simulação do peptídeo `(AAQAA)3` com água e TFE: `0%v/v` e `60%v/v` de TFE. O diretório onde os arquivos de input estão no diretória que será definido pela variável `XEMMSB_dir_MD`. Por exemplo:

```
XEMMSB_dir_MD=/home/leandro/Drive/Disciplinas/XEMMSB2021/Simulation/INPUTS/AAQAA_60vv
```
Redefina esta variável para instalar no diretório de sua preferência.

A simulação pode ser iniciado fazendo apenas:
```
./run-md.sh $XEMMSB_dir_MD
```
O script run-md.sh irá realizar todas as etapas da simulação para o sistema com `60%v/v` de TFE:

* [Minimização do sistema](#min)
* [Equilibração da temperatura e da pressão](#equi)
* [Produção - HREMD](#prod)



## 2. Descrição dos arquivos de input



```
# creating the box and the topology
julia input-tfe-100%.jl
cp topol_new.top topol.top
rm topol_new.top
packmol < box.inp

# Generation of the unprocessed topology
#echo 1 | gmx_mpi pdb2gmx -f system.pdb -o model1.gro -p topol.top -ff amber03w -ignh

# Minimization tpr file and processed topology creation
gmx_mpi grompp -f mim.mdp -c system.pdb -p topol.top -o minimization.tpr -pp processed.top -maxwarn 1
```


O arquivo `input-tfe-60.jl` cria um arquivo de input para o [Packmol](http://leandro.iqm.unicamp.br/m3g/packmol/home.shtml) que irá criar um caixa cúbica com seus lados medindo `56 Angstrons`, além de moléculas de água e TFE para que haja um solução de 60 %v/v de TFE. As quantidades de cada molécula podem ser verificadas no arquivo `box.inp`.

Para criar a caixa usando o packmol basta fazer:
```
packmol < box.inp
```

O output do comando acima será o arquivo `system.pdb`. Este pdb contém o sistema montado e pode ser visualizado por meio de softwares como o `vmd` e o `PyMOL`

-------------- aqui eu tenho que descrever todos os arquivos até a topologia
O arquivo system.pdb será, assim, um dos inputs para que as simulações sejam iniciadas. O próximo passo, portanto, será a construção do arquivo de topologia. No diretório `XEMMSB_dir_MD` há o arquivo `processed.top` que será o arquivo utilizado como topologia para as diferentes réplicas. Alguns pontos merecem atenção aqui.

Primeiramente, o arquivo de topologia deve contar os parâmetros para a água, a proteína e o tfe. 

[plumed](https://www.plumed.org/doc-v2.6/user-doc/html/hrex.html)



----------------------------------------



### <a name="min"></a>Minimização do sistema
Agora que os arquivos iniciais estão organizadas,podemos partir para a etapa de minimização. Precisamos criar um aquivo tpr para o gromacs. O arquivo Tpr é um binário usado para iniciar a simulação. O Tpr contém informações sobre a estrutura inicial da simulação, a topologia molecular e todos os parâmetros da simulação (como raios de corte, temperatura, pressão, número de passos, etc.).

O arquivo tpr da nossa minimização utilizará o arquivo topol.top. Como a atual etapa compreende a minimização, o arquivo mim.mdp (que possui todos os parâmetros para realizar um minimização) também deverá ser utilizado. Assim, para criar o arquivo tpr, usamos o comando:

```
gmx_mpi grompp -f mim.mdp -c system.pdb -p topol.top -o minimization.tpr -pp processed.top -maxwarn 1
```
Agora temos o arquivo minimization.tpr, para realizar a minimização usamos o comando:

```
gmx_mpi mdrun -s minimization.tpr -v -deffnm minimization

```
A minimização terá finalizado quando for printado no prompt:

![Alt Text](https://github.com/m3g/XEMMSB2021/blob/main/Simulation/figs/fim_minimizacao.png)

Agora, temos os seguintes arquivos:

* [minimization.gro]: Coordenadas do sistema minimizado. 
* [minimization.edr]: Arquivo binário da energia do sistema.
* [minimization.log]: Arquivo de texto ASCII do processo de minimização. 
* [minimization.trr]: Arquivo binário da trajetória (alta precisão).

Para a continuação da simulação, vamos utilizar o aquivo `minimization.gro`

### <a name="equi"></a>Equilibração da temperatura e da pressão

Como você deve ter notado, apenas uma minimização foi feita. Agora, faremos alterações no arquivo de topologia para realizar simulações de equilibração nos ensembles NVT e NPT.

Vamos, agora, utilizar arquivo processed.top gerado na criação do arquivo minimization.tpr. As simulações serão realizadas na temperatuda de 300 K e 1 bar. Sendo assim, é necessário abrir os arquivos nvt.mpr, npt.mdp e prod.mdp e alterar a variável REFT por 300. Vamos, agora, copiar todos os arquivos mdp para cada 4 pastas diferentes. Cada pasta representa um replicata que será simulada usando um hamiltoniano diferente (obs: o arquivo prod.mdp será usado na etapa final).

Assim, para copiar os arquivos fazemos:
```
echo {0..3} | xargs -n 1 cp nvt.mdp npt.mdp prod.mdp
```
O próximo passo, agora é escalonar a temperatura de acordo com os hamiltonianos.
Esse "escalonamento" consiste em multiplicar os parâmetros do campo força por um fator entre 0 e 1.

Aqui vamos usar 4 hamiltonianos: 1.0, 0.96, 0.93, 0.89 .



(talvez aqui seja bom sugerir um loop -  ver depois)
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

O método que está sendo utilizado consiste em uma simulação de dinâmica molecular com amostragem conformacional ampliada. Basicamente, os potências de interação intramolecular e proteína solvente são multiplicados por um fator chamado hamiltoniano, comumentemente representado pela letra grega &lambda; .  
  





### <a name="prod"></a>Produção - HREMD




## 3. Verificação dos resultados































































































































































































