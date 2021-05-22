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
julia $repo/Analyses/helicity/dssp.jl $work
```

Este script lê os arquivos de saída do DSSP, e gera a figura `helicity.pdf`, que será parecida com:  

<img width=700px src=https://user-images.githubusercontent.com/31046348/119176986-18b42880-ba42-11eb-852a-51a782784c02.png>

## <a name="config"></a>2. Raio de giração

Seguindo as análises do conteúdo de alfa-hélices do peptídeo por água e solução de TFE, vamos também calcular o seu raio de giração nos dois sistemas. O raio de giração é um parâmetro estrutural que permite avaliar o grau de compactação do peptídeo durante a simulação. Para isso, usaremos a ferramenta ```gyrate``` disponível no software GROMACS:
```
gmx_mpi gyrate -f production-center.xtc -s production.tpr -o radius-of-gyration.xvg
```
Em seguida, precisamos selecionar como output o grupo 1, que corresponde ao peptídeo: 

<img width=400px src=https://user-images.githubusercontent.com/70027760/119173029-0b486f80-ba3d-11eb-9743-38f6a2fb25e2.png>

O arquivo de saída será o ```radius-of-gyration.xvg```. Você poderá abrir esse arquivo no seu terminal, e irá perceber que o ```gyrate``` calcula o raio de giração para o peptídeo, e também o raio de giração sobre os eixos X, Y e Z, em função do tempo. Aqui, iremos adotar a segunda coluna do arquivo ```radius-of-gyration.xvg``` (que corresponde ao raio de giração do peptídeo) para calcular a distribuição do raio de giração do peptídeo com o pacote StatsPlots, do Julia. Para instalar o pacote StatsPlots, basta digitar o comando ```]add StatsPlots``` no terminal do Julia.

A fim de comparar o grau de compactação do peptídeo nos dois sistemas, o cálculo do raio de giração, de acordo com as instruções acima, deverá ser realizado para a trajetória do peptídeo em água e em solução de TFE. Após obter o arquivo ```radius-of-gyration.xvg``` para os dois sistemas, a distribuição do raio de giração poderá ser obtida com o script ```rg.jl```, disponível no diretório ```Analyses```. A figura obtida será parecida com:

<img width=400px src=https://user-images.githubusercontent.com/70027760/119211705-1fff2480-ba8a-11eb-800a-b6c61c68ae67.png>

## <a name="min"></a>3. Estrutura de solvatação

Embora seja conhecido o potencial do TFE na indução de hélices em peptídeos e proteínas, o seu mecanismo de ação ainda é bastante discutido na literatura. Diferentes mecanismos têm sido propostos para explicar a indução de hélices pelo TFE, dentre eles os mecanismos direto e indireto. De forma resumida, o mecanismo direto consiste na interação direta entre os átomos de hidrogênio ácido do TFE e o oxigênio carbonílico da *backbone* da proteína por meio de ligações de hidrogênio intermolecular. Nesse caso, a ligação de hidrogênio intermolecular também contribui para fortalecer as ligações de hidrogênio intramoleculares entre os átomos de oxigênio carbonílico e o hidrogênio ligado ao nitrogênio da amida. Por outro lado, no mecanismo indireto, a adição de TFE ao sistema é responsável por 1) perturbar as moléculas de água em torno do soluto,  e então desestabilizá-lo; e, posteriormente, 2) induzir a formação de hélices por meio de interações específicas e inespecíficas com a superfície da proteína. 

Para entendermos como o TFE contribuiu para a formação de hélices, precisamos, primeiramente, avaliar como as moléculas do solvente se distribuem na solução. A forma com que as moléculas do solvente se distribuem na solução pode ser descrita pelas funções de distribuição de mínima distância (MDDFs). As MDDFs adotam a distância mínima entre átomos do solvente e os átomos do soluto, resultando em funções de distribuição facilmente interpretáveis do ponto de vista das interações físico-químicas específicas. Por meio das MDDFs podemos avaliar tanto a distribuição total das moléculas do solvente em torno do soluto, quanto a contribuição de cada átomo (ou grupos de átomos) do solvente. Com isso, é possível formular hipóteses a respeito das interações que possivelmente justificam a forma do soluto na solução.

O cálculo das MDDFs pode ser feito com o software ```ComplexMixtures```. Você poderá instalar o ```ComplexMixtures``` no terminal do Julia com o comando ```] add ComplexMixtures```. Também será necessário instalar o software PDBTools (```] add PDBTools```), que manipula os arquivos no formato .pdb. Finalmente, as MDDFs para o TFE e para a água, podem ser calculadas a partir dos scripts ```gmd-tfe.jl``` e ```gmd-water.jl```, respectivamente, disponíveis no diretório ```Analyses/mddf-kb/```.  Por meio desse script você poderá observar várias opções de cálculo, dentre elas, o parâmetro ```dbulk=20```. Esse parâmetro define a distância do soluto, em que assumimos que o soluto não influencia significativamente na estrutura do solvente.

Vale lembrar que o cálculo das MDDFs poderá ser realizado em paralelo, utilizando vários processadores do computador. Por exemplo, os scripts ```gmd-tfe.jl``` e ```gmd-water.jl``` poderão ser executados em paralelo com o comando ```julia -t 4 gmd-tfe.jl```. 

A partir do cálculo das MDDFs, os resultados obtidos estarão salvos nos arquivos com o formato ```.json``` (```results-water-20.json```e ```results-tfe-20.json```). Portanto, os arquivos ```.json``` podem ser utilizados para plotar o perfil total das MDDFs, e também a constribuição de cada átomo (ou grupos de átomos). Os gráficos poderão ser plotados com o script ```mddf-kb-water.jl``` e ```mddf-kb-tfe.jl``` (disponíveis em ```Analyses/mddf-kb/```), e as suas figuras devem ser parecidas com:

<img width=400px src=https://user-images.githubusercontent.com/70027760/119211426-618ed000-ba88-11eb-8eae-8d66e8f9c037.png>
<img width=400px src=https://user-images.githubusercontent.com/70027760/119211427-62276680-ba88-11eb-8db6-408a8d9af0f6.png>


## <a name="equi"></a>4. Acúmulo e depleção do TFE

A partir das MDDFs é possível calcular propriedades termodinâmicas macroscópicas das soluções, usando a Teoria de Soluções de Kirkwood-Buff. Nos arquivos ```.json```, além das MDDFs, também há informação das integrais de Kirkwood-Buff (KB). As integrais de KB refletem a afinidade entre o soluto e as moléculas de solvente, e determinam se há excesso ou exclusão de cada componente do solvente nas vizinhanças do soluto. Dessa forma, avaliando o perfil das integrais de KB da água e do TFE, é possível dizer se cada componente é acumulado ou é excluído da superfície da proteína. Quando o solvente se encontra preferencialmente próximo à superfície da proteína, o valor de integral de KB deve ser positivo, e negativo caso seja preferencialmente excluído para o *bulk* da solução. Nas figuras a seguir, podemos analisar o perfil das integrais de KB para o TFE (azul) é a água (verde), na simulação contendo ~60% de TFE.

<img width=400px src=https://user-images.githubusercontent.com/70027760/119211424-605da300-ba88-11eb-94c7-5379f20d6bcd.png>
<img width=400px src=https://user-images.githubusercontent.com/70027760/119211425-618ed000-ba88-11eb-8ece-fa06e2a4ca35.png>

O efeito da adição do TFE (e qualquer outro cossolvente) à solução será quantificado pela diferença pelo Parâmetro de Solvatação Preferencial (Γ). O Γ está diretamente relacionado com a variação do potencial químico do soluto pela adição de um cossolvente à solução. De modo geral, se o parâmetro de solvatação preferencial do cossolvete (Γ<sub>pc</sub>) apresenta um valor positivo, o soluto é preferencialmente solvatado pelo cossolvente. Por outro lado, se o Γ<sub>pc</sub> for negativo, a proteína é preferencialmente hidratada. 
