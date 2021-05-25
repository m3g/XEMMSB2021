# Simulação de enovelamento de proteínas e efeitos de solvente

## Análise das simulações

### >> Parte 1
* [1. Substituição das trajetórias](#subs)

* [2. Cálculo da helipticidade](https://github.com/m3g/XEMMSB2021/tree/main/Analyses#1-c%C3%A1lculo-da-helipticidade-do-pept%C3%ADdeo)
* [3. Raio de giração](https://github.com/m3g/XEMMSB2021/tree/main/Analyses#2-raio-de-gira%C3%A7%C3%A3o)

### Parte 2
* [4. Estrutura de solvatação](https://github.com/m3g/XEMMSB2021/blob/main/Analyses/Solvation.md)
* [5. Acúmulo e depleção dos solventes](https://github.com/m3g/XEMMSB2021/blob/main/Analyses/Solvation.md#4-ac%C3%BAmulo-e-deple%C3%A7%C3%A3o-do-tfe)

## <a name="subs"></a>1. Substituição das trajetórias

As análises serão feitas em trajetórias mais longas que foram feitas anteriormente em um cluster de computadores. Para copiar os arquivos desta trajetória para seu diretório de trabalho, faça:

```
$repo/Simulations/final.sh $repo $work
```
### Taxas de trocas

 
Após o término da simulação, é interessante verificar as taxas de aceitação de trocas a cada tentativa (400 passos). Esse resultado pode ser facilmente obtido do arquivo ```production.log```. Para observar esses resultados diretamente no seu terminal, basta executar o comando a seguir:

```
cd $work/Simulations/AAQAA_0vv/0
grep -A9 "exchange statistics" production.log
```

O resultado que irá aparecer na sua tela deve ser algo parecido com:

```
Replica exchange statistics
Repl  624999 attempts, 312500 odd, 312499 even
Repl  average probabilities:
Repl     0    1    2    3    4    5    6    7    8    9
Repl      .59  .68  .58  .67  .56  .66  .65  .64  .75
Repl  number of exchanges:
Repl     0    1    2    3    4    5    6    7    8    9
Repl     185680 213492 181304 209275 176160 204696 202077 199750 234254
Repl  average number of exchanges:
Repl     0    1    2    3    4    5    6    7    8    9
Repl      .59  .68  .58  .67  .56  .66  .65  .64  .75
```
De acordo com o resultado acima é possível perceber que a maior taxa de troca ocorreu entre as réplicas 8 e 9. Se o espaçamento entre as temperaturas fosse constante, seria esperado que a taxa de trocas das temperaturas maiores fosse maior, já que a temperatura entra no expoente da probabilidade de trocas (`exp[-(E2-E1)/RT]`). A escolha das temperaturas com o parâmetro nestas simulações (&lambda;) é pensada para que a taxa seja constante em uma simulação de REMD entre diferentes temperaturas. Prefere-se que a taxa de trocas final esteja sempre próximas de 30% [ref](https://link.springer.com/protocol/10.1007/978-1-4939-7811-3_5) , o que significa que as réplicas não estão muito próximas nem muito distantes. Nesta simulação, as réplicas estão um pouco próximas, e as taxas de troca são maiores (em torno de 60%). Para melhorar a amostragem poderíamos aumentar a faixa de temperaturas estudada, atingindo maiores temperaturas. Além disso, um outro estudo realizado no mesmo intervalo de temperatura que nós adotamos no presente trabalho [(300 K - 425 K)](https://www.nature.com/articles/s42003-021-01759-1.pdf), mostrou que uma taxa de troca de 0,4 foi suficiente para obter uma boa amostragem do sistema.

## <a name="helix"></a>2. Cálculo da helipticidade do peptídeo

O trifluoretanol (TFE) é um cossolvente conhecido por induzir a formação de hélices em peptídeos e proteínas. Portanto, vamos iniciar nossas análises avaliando o conteúdo de alfa-hélices nos sistemas na presença e ausência de TFE. A atribuição de estrutura secundária para os resíduos do peptídeo pode ser feita com o Dicionário de Estrutura Secundária de Proteínas (do inglês, *Dictionary of Secondary Structure of Proteins, DSSP*). Existe uma plataforma online para o DSSP (http://bioinformatica.isa.cnr.it/SUSAN/DSSP-web/), mas o software também pode ser facilmente instalado com o ```sudo apt install dssp```. O DDSP atribui elementos de estrutura secundária para os resíduos da proteína por meio de alguns caracteres, por exemplo:

G = hélice 3<sub>10</sub>;
H = α-hélice;
I = hélice π;
T = *turn*;
E = folhas-β paralelas e antiparalelas;
B = resíduo isolado em uma ponte-β;
S = *bend*;
C = *coil*;

Como nosso interesse é avaliar a indução de hélices pelo TFE, vamos quantificar apenas o elemento de estrutura secundária "H" de acordo com as instruções a seguir:

Entre no diretório `AAQAA_0vv/0`, que contém a simulação sem aproximação no potencial
para o peptídeo em água pura, e crie um diretório que conterá uma série de arquivos
temporários necessários para o cálculo da estrutura secundária:

```
cd $work/Simulations/AAQAA_0vv/0
mkdir -p ./DSSP
```

Em seguida, use este comando do Gromacs para gerar um arquivo PDB da proteína para cada
frame da sua trajetória: 
```
echo 1 | gmx_mpi trjconv -f production.xtc -s production.tpr -o ./DSSP/dssp$1.pdb -sep
```

E, por fim, usaremos o programa `DSSP` para calcular a estrutura secundária de cada resíduo
em cada frame:
```
cd DSSP
for file in `ls dssp*.pdb`; do
  # Compute secondary structure
  mkdssp -i $file -o $file.dssp
done
cd ..
```

- Repita os passos acima para a simulação `AAQAA_60vv/0` 

Os arquivos `dsspX.pdb.dssp` gerados contém, para cada passo da simulação, a atribuição da estrutura secundária para cada resíduo. Podemos fazer gráficos de como evolui no tempo a estrutura secundária dos
 resíduos, e do conteúdo médio de &alpha;-hélices que cada resíduo possui.

Isto pode ser feito usando o script `dssp.jl`:  
```
cd $work/Simulations
julia $repo/Analyses/julia/dssp.jl $work
```

Este script lê os arquivos de saída do DSSP, e gera a figura `helicity.pdf`, que será parecida com:  

<img width=700px src=https://user-images.githubusercontent.com/31046348/119176986-18b42880-ba42-11eb-852a-51a782784c02.png>

Note que, como esperado, o conteúdo de &alpha;-hélices do peptídeo na simulação com TFE é maior, ilustrando o papel estabilizador deste cossolvente sobre esta estrutura secundária.

## <a name="config"></a>3. Raio de giração

Seguindo as análises do conteúdo de alfa-hélices do peptídeo por água e solução de TFE, vamos também calcular o seu raio de giração nos dois sistemas. O raio de giração é um parâmetro estrutural que permite avaliar o grau de compactação do peptídeo durante a simulação. Para isso, usaremos a ferramenta ```gyrate``` disponível no software GROMACS:

```cd $work/Simulations/AAQAA_0vv/0```
```
gmx_mpi gyrate -f production.xtc -s production.tpr -o rg.xvg
```
Em seguida, selecione como output o grupo 1, que corresponde ao peptídeo: 

```
Reading file production.tpr, VERSION 2019.4 (single precision)
Group     0 (         System) has 23394 elements
Group     1 (        Protein) has   174 elements
Group     2 (      Protein-H) has    88 elements
Group     3 (        C-alpha) has    15 elements
Group     4 (       Backbone) has    45 elements
Group     5 (      MainChain) has    61 elements
Group     6 (   MainChain+Cb) has    76 elements
Group     7 (    MainChain+H) has    78 elements
Group     8 (      SideChain) has    96 elements
Group     9 (    SideChain-H) has    27 elements
Group    10 (    Prot-Masses) has   174 elements
Group    11 (    non-Protein) has 23220 elements
Group    12 (          Water) has 23220 elements
Group    13 (            SOL) has 23220 elements
Group    14 (      non-Water) has   174 elements
Select a group: 1
```

O arquivo de saída será o ```rg.xvg```. Você poderá abrir esse arquivo no seu terminal, e irá perceber que o ```gyrate``` calcula o raio de giração para o peptídeo, e também o raio de giração sobre os eixos X, Y e Z, em função do tempo. Aqui, iremos adotar a segunda coluna do arquivo ```rg.xvg``` (que corresponde ao raio de giração do peptídeo) para calcular a distribuição do raio de giração do peptídeo usaremos o pacote StatsPlots do Julia.

A fim de comparar o grau de compactação do peptídeo nos dois sistemas, o cálculo do raio de giração, de acordo com as instruções acima, deverá ser realizado para a trajetória do peptídeo em água e em solução de TFE. Repita o procedimento acima para o diretório `AAQAA_60vv`.

Para produzir os gráficos, execute o script `rg.jl`:

```
cd $work/Simulations
julia $repo/Analyses/julia/rg.jl $work
```

O resultado obtido deve ser similar a:

<img width=500px src=https://user-images.githubusercontent.com/31046348/119245655-4b991200-bb51-11eb-9251-4bd427683119.png>

Neste caso, note que o raio de giração em água é maior, e talvez bimodal. Isto é resultado da maior variabilidade conformacional do peptídeo em água pura que na solução com TFE. Note que o primeiro pico da distribuição em água coincide aproximadamente com o pico da distriubição em solução de TFE, indicando que estas conformações devem ser as que assumem a estrutura de hélice que é estabilizada na solução com o cossolvente.

