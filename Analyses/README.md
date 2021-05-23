# Simulação de enovelamento de proteínas e efeitos de solvente


## Analise das simulações

* [1. Cálculo da helipticidade](#helix)
* [2. Raio de giração](#config)
* [3. Estrutura de solvatação](#min)
* [4. Acúmulo e depleção do TFE](#equi)

## <a name="helix"></a>1. Cálculo da helipticidade do peptídeo

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

## <a name="config"></a>2. Raio de giração

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

## <a name="min"></a>3. Estrutura de solvatação

Embora seja conhecido o potencial do TFE na indução de hélices em peptídeos e proteínas, o seu mecanismo de ação ainda é bastante discutido na literatura. Diferentes mecanismos têm sido propostos para explicar a indução de hélices pelo TFE, conhecidos como  mecanismos direto e indireto. 

1. O mecanismo direto consiste na interação direta entre os átomos de hidrogênio ácido do TFE e o oxigênio carbonílico da cadeia principal da proteína por meio de ligações de hidrogênio. Esta interação pode acontecer sem a ruptura da ligação ``N-H⋯O` que estabiliza a hélice. Ao mesmo tempo, o grupo trifluoro-metil impede a aproximação de moléculas de água ao ao nitrogênio amídico da cadeia principal. Com isto, o TFE impede que a água interaja com a cadeia principal competindo pelas ligações de hidrogênio que estabilizam sua estrutura. Assim, o TFE contribui para fortalecer as ligações de hidrogênio intramoleculares entre os átomos de oxigênio carbonílico e o hidrogênio ligado ao nitrogênio da amida. 

2. No mecanismo indireto, o TFE deve se acumular de forma inespecífica em torno da proteína e perturbar a estrutrua da água, diminiuindo suas interações com a proteína e, portanto, sua capacidade de competir pelas ligações de hidrogênio intra-moleculares que estabilizam as hélices. 

Os dois mecanismos podem coexistir. O mecanismo (1) levanta as seguintes hipóteses:

- Devem ocorrer ligações de hidrogênio entre o TFE e o oxigênio da cadeia principal da proteína. 
- Não devem ocorrer ligações de hidrogênio entre o TFE e o nitrogênio da cadeia principal. 
- O número de ligações de hidrogênio da água com a cadeia principal da proteína deve diminuir na presença de TFE.

O mecanismo indireto (2), sugere que: 

- O TFE deve, de forma geral, ser encontrado nos arredores da proteína, mas não necessariamente interagindo diretamente e de forma específica com sua estrutura. 
- A água deve ser excluída das proximidades da proteína.
- As ligações de hidrogênio água-cadeia principal da proteína devem ser desestabilizadas.   

Estas hipóteses podem ser estudadas usando simulações, e funções de distribuição. Uma visão molecular da forma com que as moléculas do solvente se distribuem na solução pode ser descrita pelas [funções de distribuição de mínima distância (MDDFs)](http://pubs.acs.org/doi/abs/10.1021/acs.jctc.7b00599). Por meio das MDDFs podemos avaliar tanto a distribuição total das moléculas do solvente em torno do soluto, quanto a contribuição de cada átomo (ou grupos de átomos) do solvente. Com isso, é possível testar as hipóteses a respeito das interações que possivelmente justificam a forma do soluto na solução.

O cálculo das MDDFs pode ser feito com o software [ComplexMixtures.jl](http://m3g.iqm.unicamp.br/ComplexMixtures). 

### Usando ComplexMixtures.jl 

[ComplexMixtures.jl](http://m3g.iqm.unicamp.br/ComplexMixtures) é um software que calcula funções de distribuição e parâmetros de solvatação preferencial a partir de simulações de dinâmica molecular. É usado para a compreensão das interações entre solutos e solventes complexos, sendo as proteínas um exemplo importante e comum de estrutura complexa altamente dependente de sua estrutura de solvatação. 

Os scripts que usam o pacote para calcular as estruturas de solvatação que estudaremos aqui estão disponíveis no diretório `Analyses/julia`. Vamos descrever um dos exemplos, em que calculamos a distribuição da água em torno da proteína, na simulação do peptídeo em água pura. O script é [`$repo/Analyses/julia/cm_water0.jl`](https://github.com/m3g/XEMMSB2021/blob/main/Analyses/julia/cm_water0.jl) 
 


```
julia -t5 -i $repo/Analyses/julia/cm_water0.jl $repo $work
```


```julia
using PDBTools, ComplexMixtures
```

# Load PDB file of the system
atoms = readPDB("system.pdb")

# Select the protein and the solvents
protein = select(atoms,"protein")
tfe = select(atoms,"resname TFE")
water = select(atoms,"water")

# Setup solute (1 protein)
solute = Selection(protein,nmols=1)

#
# Compute MDDF for TFE
#

# Setup solvent (number of atoms of TFE molecule = 9)
solvent = Selection(tfe,natomspermol=9)

# Setup the Trajectory structure
trajectory = Trajectory("production.xtc",solute,solvent)

# Options (dbulk: distance above which the solute does not
# affect the structure of the solvent)
options = Options(dbulk=10)

# Run the calculation and get results
results = mddf(trajectory,options)

# Save the reults to recover them later if required
save(results,"./cm-tfe.json")









Finalmente, as MDDFs para o TFE e para a água, podem ser calculadas a partir dos scripts ```gmd-tfe.jl``` e ```gmd-water.jl```, disponíveis no diretório ```$repo/Analyses/julia```.  Por meio desse script você poderá observar várias opções de cálculo, dentre elas, o parâmetro ```dbulk=20```. Esse parâmetro define a distância do soluto, em que assumimos que o soluto não influencia significativamente na estrutura do solvente.

Vale lembrar que o cálculo das MDDFs poderá ser realizado em paralelo, utilizando vários processadores do computador. Por exemplo, os scripts ```gmd-tfe.jl``` e ```gmd-water.jl``` poderão ser executados em paralelo com o comando ```julia -t 4 gmd-tfe.jl```. 

A partir do cálculo das MDDFs, os resultados obtidos estarão salvos nos arquivos com o formato ```.json``` (```results-water-20.json```e ```results-tfe-20.json```). Portanto, os arquivos ```.json``` podem ser utilizados para plotar o perfil total das MDDFs, e também a constribuição de cada átomo (ou grupos de átomos). Os gráficos poderão ser plotados com o script ```mddf-kb-water.jl``` e ```mddf-kb-tfe.jl``` (disponíveis em ```$repo/Analyses/julia```), e as suas figuras devem ser parecidas com:

<img width=400px src=https://user-images.githubusercontent.com/70027760/119211426-618ed000-ba88-11eb-8eae-8d66e8f9c037.png>
<img width=400px src=https://user-images.githubusercontent.com/70027760/119211427-62276680-ba88-11eb-8db6-408a8d9af0f6.png>


## <a name="equi"></a>4. Acúmulo e depleção do TFE

A partir das MDDFs é possível calcular propriedades termodinâmicas macroscópicas das soluções, usando a Teoria de Soluções de Kirkwood-Buff. Nos arquivos ```.json```, além das MDDFs, também há informação das integrais de Kirkwood-Buff (KB). As integrais de KB refletem a afinidade entre o soluto e as moléculas de solvente, e determinam se há excesso ou exclusão de cada componente do solvente nas vizinhanças do soluto. Dessa forma, avaliando o perfil das integrais de KB da água e do TFE, é possível dizer se cada componente é acumulado ou é excluído da superfície da proteína. Quando o solvente se encontra preferencialmente próximo à superfície da proteína, o valor de integral de KB deve ser positivo, e negativo caso seja preferencialmente excluído para o *bulk* da solução. Nas figuras a seguir, podemos analisar o perfil das integrais de KB para o TFE (azul) é a água (verde), na simulação contendo ~60% de TFE. Vale lembrar que estas figuras devem ter sido geradas na etapa anterior, juntamente com a das MDDFs. 

<img width=400px src=https://user-images.githubusercontent.com/70027760/119211424-605da300-ba88-11eb-94c7-5379f20d6bcd.png>
<img width=400px src=https://user-images.githubusercontent.com/70027760/119211425-618ed000-ba88-11eb-8ece-fa06e2a4ca35.png>

O efeito da adição do TFE (e qualquer outro cossolvente) à solução será quantificado pela diferença pelo Parâmetro de Solvatação Preferencial (```Γ```). O ```Γ``` está diretamente relacionado com a variação do potencial químico do soluto pela adição de um cossolvente à solução. De modo geral, se o parâmetro de solvatação preferencial do cossolvete (Γ<sub>pc</sub>) apresenta um valor positivo, o soluto é preferencialmente solvatado pelo cossolvente. Por outro lado, se o Γ<sub>pc</sub> for negativo, a proteína é preferencialmente hidratada.

Matematicamente, o Γ<sub>pc</sub> é dado por: 

Γ<sub>pc</sub> = ρ<sub>c</sub>(G<sub>pc</sub> − G<sub>wc</sub>)

Em que ρ<sub>c</sub> é a densidade do TFE, e G<sub>pc</sub> e G<sub>wc</sub> as integrais de KB do TFE e da água no *bulk* da solução, respectivamente. O valor de ρ<sub>c</sub> pode ser obtido carregando o arquivo ```results-tfe-20.json``` da seguinte forma:

```results = ComplexMixtures.load("./results-tfe-20.json")```

Em seguida, você irá identificar Concentration in bulk: 7,351558289632044 mol L <sup>-1</sup>, que corresponde a  ρ<sub>c</sub> . Para encontrar o valor de G<sub>pc</sub> você deverá digitar no terminal do Julia ```results.kb/1000```, e adotar o último valor da integral de KB, que será igual a -0,8052674557436698 L mol<sup>-1</sup>. Finalmente, para encontrar o valor de G<sub>wc</sub>, você deverá carregar o arquivo ```results-water-20.json```:

```results = ComplexMixtures.load("./results-tfe-20.json")```

```results.kb/1000```

Com isso, você irá perceber que o último valor da integral de KB corresponde a -0,9256393982359525 L mol<sup>-1</sup>. Portanto, o valor de Γ<sub>pc</sub> é igual a 0,8849.

