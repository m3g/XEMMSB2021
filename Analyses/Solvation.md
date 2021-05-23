# Simulação de enovelamento de proteínas e efeitos de solvente

## Análise das simulações

### Parte 1
* [1. Cálculo da helipticidade](https://github.com/m3g/XEMMSB2021/tree/main/Analyses#1-c%C3%A1lculo-da-helipticidade-do-pept%C3%ADdeo)
* [2. Raio de giração](https://github.com/m3g/XEMMSB2021/tree/main/Analyses#2-raio-de-gira%C3%A7%C3%A3o)

### >> Parte 2
* [3. Estrutura de solvatação: Conceitos](https://github.com/m3g/XEMMSB2021/blob/main/Analyses/Solvation.md)
* [4. Funções de distribuição da água e do TFE](https://github.com/m3g/XEMMSB2021/blob/main/Analyses/Solvation.md)
* [5. Acúmulo e depleção dos solventes](https://github.com/m3g/XEMMSB2021/blob/main/Analyses/Solvation.md#4-ac%C3%BAmulo-e-deple%C3%A7%C3%A3o-do-tfe)

## <a name="solv"></a>3. Estrutura de solvatação: Conceitos

Embora seja conhecido o potencial do TFE na indução de hélices em peptídeos e proteínas, o seu mecanismo de ação ainda é bastante discutido na literatura. Diferentes mecanismos têm sido propostos para explicar a indução de hélices pelo TFE, conhecidos como  mecanismos direto e indireto. 

1. O mecanismo direto consiste na interação direta entre os átomos de hidrogênio ácido do TFE e o oxigênio carbonílico da cadeia principal da proteína por meio de ligações de hidrogênio. Esta interação pode acontecer sem a ruptura da ligação ``N-H⋯O` que estabiliza a hélice. Ao mesmo tempo, o grupo trifluoro-metil impede a aproximação de moléculas de água ao nitrogênio amídico da cadeia principal. Com isto, o TFE impede que a água interaja com a cadeia principal competindo pelas ligações de hidrogênio que estabilizam sua estrutura. Assim, o TFE contribui para fortalecer as ligações de hidrogênio intramoleculares entre os átomos de oxigênio carbonílico e o hidrogênio ligado ao nitrogênio da amida. 

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

### 3.1. Usando ComplexMixtures.jl 

[ComplexMixtures.jl](http://m3g.iqm.unicamp.br/ComplexMixtures) é um software que calcula funções de distribuição e parâmetros de solvatação preferencial a partir de simulações de dinâmica molecular. É usado para a compreensão das interações entre solutos e solventes complexos, sendo as proteínas um exemplo importante e comum de estrutura complexa altamente dependente de sua estrutura de solvatação. 

Os scripts que usam o pacote para calcular as estruturas de solvatação que estudaremos aqui estão disponíveis no diretório `Analyses/julia`. Vamos descrever um dos exemplos, em que calculamos a distribuição da água em torno da proteína, na simulação do peptídeo em água pura.
O script, passo a passo, contém os seguintes comandos, que podem ser executados contanto que o caminho para o arquivo de estrutura `system.pdb` e trajetória `production.xtc` estejam adequadamente definidos. Essencialmente, possuem os comandos para ler a estrutura e a trajetória, definir alguns parâmetros básicos do cálculo da função de distribuição, calcular e salvar o resultados:

1. Carregamento dos pacotes usados:
```julia
using PDBTools, ComplexMixtures
```

2. Ler o arquivo PDB to sistema:
```julia
atoms = readPDB("system.pdb")
```

3. Selecionar a proteína e a água (a água, no modelo TIP4P2005 possui um átomo
fictício, que será ignorado por não ter correlato físico):
```julia
protein = select(atoms,"protein")
water = select(atoms,"resname SOL and not name MW")
```

4. Definir o soluto e o solvente para o cálculo das funções de distribuição:
```julia
solute = Selection(protein,nmols=1)
solvent = Selection(water,natomspermol=9)
```

5. Abrir a trajetória
```julia
trajectory = Trajectory("production.xtc",solute,solvent)
```

6. Definição da distância de *bulk*:
```julia
options = Options(dbulk=10)
```

7. Calcular a função de distribuição e salvar na variável `results`:
```julia
results = mddf(trajectory,options)
```

8. Salvar os resultados em arquivo no formato `json`:
```julia
save(results,"./cm-tfe.json")
```

### 3.2. Executando o exemplo:

O script completo é [`$repo/Analyses/julia/cm_water0.jl`](https://github.com/m3g/XEMMSB2021/blob/main/Analyses/julia/cm_water0.jl), e será executado assim:
```
julia -t5 -i $repo/Analyses/julia/cm_water0.jl $repo $work
```
onde `-t5` indica que usaremos 5 *threads*, paralelizando o cálculo (só como ilustração, não é realmente necessário porque a trajetória não é muito longa aqui), e `-i` indica que vamos manter a seção de `julia` aberta no fim do cálculo, para estudar o resultado e entender as próximas etapas: 

Terminado o cálculo, execute o comando `results`, que vai simplesmente imprimir um resumo dos resultados na tela:

```julia-repl
julia> results

-------------------------------------------------------------------------------

 MDDF Overview: 

 Solvent properties: 
 ------------------- 

 Simulation concentration: 54.86804877410611 mol L⁻¹
 Molar volume: 18.225543323347235 cm³ mol⁻¹

 Concentration in bulk: 55.317568428449 mol L⁻¹
 Molar volume in bulk: 18.077439562323836 cm³ mol⁻¹ 

 Solute properties: 
 ------------------ 

 Simulation Concentration: 0.009451860253937308 mol L⁻¹
 Estimated solute partial molar volume: 860.9416831970985 cm³ mol⁻¹

 Using with dbulk = 10.0Å: 
 Molar volume of the solute domain: 15897.977955953416 cm³ mol⁻¹

 Auto-correlation: false

 Trajectory files and weights: 
   /home/leandro/Documents/curso/XEMMSB2021/Simulations/Final/production0.xtc - w = 1.0

 Long range MDDF mean (expected 1.0): 1.0067406427203667 +/- 0.019351948543982617
 Long range RDF mean (expected 1.0): 1.0089598723940005 +/- 0.017961284832647764

-------------------------------------------------------------------------------
```

O que nos pode imediatamente chamar a atenção são a concentração da água na simulação `~54,86` e a concentração da água no *bulk*, de `~55.31` mol/L. A concentração da água na caixa inteira é menor, porque a proteína ocupa uma parte da caixa, mas a concentração no bulk (a uma distância maior que 10A da proteína), deve ser similar à concentração da água na água pura. Se a água sofresse uma acumulação muito substancial em torno da proteína (como vai acontecer com muitos cossolventes), a concentração na caixa pode ser *maior* que a concentração no *bulk* da solução. Neste caso, podemos ver que o volume molar da água no *bulk*, de `~18` cc/mol, é adequado.

A função de distribuição de mínima distância (MDDF) deve convergir para `1.0` em distâncias longas. Nas últimas linhas vemos se isto aconteceu. É importante que o erro seja maior que a diferença entre entre a média e `1.0`, indicando que o erro é aleatório. Se tivéssemos um erro sistemático e a função convergisse para um número maior ou menor que `1.0`, mesmo que pouco, teríamos problemas na análise da integral desta função, que estudaremos a seguir.  

### 3.3. Explorando os resultados: a função de distribuição

Vamos fazer alguns gráficos para explorar os resultados obtidos no cálculo acima. Carregamos o pacote `Plots` com 
```julia
using Plots
```
e, em seguida, podemos fazer o gráfico da função de distribuição de mínima distância obtida, com:
```julia
plot(results.d,results.mddf,xlabel="d/Angs",ylabel="mddf",label="MDDF")
```
você deve notar um pico em aproximadamente `1.8AA` e outro pico em `2.6AA`, que são característicos da primeira e segunda camadas de solvatação da água. O pico em `2.6AA` é mais largo e contém também interações inespecíficas entre a água e o peptídeo. 

![image](https://user-images.githubusercontent.com/31046348/119264899-3fe23580-bbbb-11eb-9a9c-7bf740903afa.png)

Podemos extrair a informação das interações da água com a cadeia principal da proteína, usando:
```julia
julia> backbone = select(atoms,"backbone")
   Array{Atoms,1} with 59 atoms with fields:
   index name resname chain   resnum  residue        x        y        z  beta occup model segname index_pdb
       1    N     ALA              1        1   -5.112   10.286    0.360  0.00  1.00     1       1         1
       5   CA     ALA              1        1   -5.682    9.046   -0.130  0.00  1.00     1       1         5
      11    C     ALA              1        1   -4.682    8.256   -0.950  0.00  1.00     1       1        11
                                                       ⋮ 
     164    N     ALA             15       15    3.768   -9.894    2.110  0.00  1.00     1       1       164
     166   CA     ALA             15       15    3.128  -11.114    2.600  0.00  1.00     1       1       166
     172    C     ALA             15       15    3.258  -12.244    1.590  0.00  1.00     1       1       172
```

E, então, extrair dos resultados apenas a contribução dos átomos desta seleção: 

```julia
julia> bb_contrib = contrib(solute,results.solute_atom,backbone)
500-element Vector{Float64}:
 0.0
 0.0
 ⋮
```

e acrescentamos, finalmente, esta contribuição ao gráfico anterior:
```julia
julia> plot!(results.d,bb_contrib,label="backbone")
```

![image](https://user-images.githubusercontent.com/31046348/119264941-61dbb800-bbbb-11eb-8ea4-e76671d32120.png)

Note que, claramente, a água forma muitas ligações de hidrogênio com a cadeia principal da proteína. Estas ligações competem com as interações que estabilizam a &alpha;-hélice.  

É possível decompor a MDDF em contribuições de qualquer tipo de átomo do solvente ou do soluto obtendo, assim, uma visão microscópica das interações que compõem o sistema.

### 3.4. Explorando os resultados: a integral de Kirkwood-Buff

As integrais de Kirkwood-Buff são o parâmetro termodinâmico que permite conectar as funções de distribuição com as propriedades macroscópicas das soluções. Para entender o que elas representam, podemos pensar assim: some, em toda a solução, o número de moléculas de um determinado componente, subtraia desse número o número de moléculas que haveria na solução se o componente estivesse puro na concentração da solução. Depois, transforme isso em unidades de volume dividindo pela densidade molar. Em outras palavras, as integrais de KB medem se há mais ou menos moléculas de uma espécie na solução do que haveria se a molécula estivesse homogeneamente distribuída em toda a solução, na concentração de estudo.  

Não é trivial, e é mais fácil entender com um exemplo. Com o seguinte código, fazemos um gráfico da integral de Kirkwood-Buff da água integrada em função da distância da superfície da proteína, no nosso exemplo.  
```julia
julia> plot(results.d,results.kb,xlabel="d/Angs",ylabel="KB / cm³/mol",label="KB")
```

Que produz a seguinte figura:

![image](https://user-images.githubusercontent.com/31046348/119265281-808e7e80-bbbc-11eb-8746-7a5c3c498f09.png)

A concentração de água no bulk, na solução é de `~55.3 mol/L`, como vimos no resumo dos resultados acima. Vemos que:

1. Em distâncias curtas a integral torna-se muito negativa, o que significa que há menos água nessa distância do que haveria em uma solução homogênea de água com concentração `55.3 mol/L`. Isto reflete diretamente o fato da proteína ocupar um volume na solução, e está relacionado com a função de distribuição vista anteriormente em toda a região onde MDDF(r) < 1. 

2. A partir de aproximadamente 1.9AA, a sobre uma série de aumentos. Isto quer dizer que, nessas distâncias, a concentração de água é maior que `~55.3 mol/L`. Isto se deve às interações favoráveis, específicas (ligações de hidrogênio) e inespecíficas da água com a proteína. No MDDF vemos estes efeitos nas regiões em MDDF > 1.   

3. Em distâncias longas, a integral fica  constante, o que significa que as concentrações de água nessas distâncias são iguais à concentração de água no *bulk* (e, nesses casos, a MDDF converge para 1 ao mesmo tempo).

O resultado final da integral de KB, que neste caso é `~-860 cc/L`, corresponde a quanto volume a água ocupa a mais, ou a menos, na solução, em relação ao que ela ocuparia se a solução fosse homogênea com concentração `~55.3 mol/L`. Neste caso o volume é negativo, indicando que há menos água no mesmo volume da solução do que haveria se a proteína não estivesse lá. Dado o grande volume ocupado por uma molécula como uma proteína, isto talvez soa esperado, mas não é sempre assim, devido às interações favoráveis entre solutos e solventes que provocam aumentos de densidade local.

No caso de um soluto em um solvente único, como neste caso, a integral obtida nada mais é que o volume molar aparente da proteína (que é um parâmetro macroscópico mensurável). Ou seja, qual o volume que a proteína ocupa na solução, por mol. 

Os resultados são muito mais interessantes quando comparamos as funções de distribuição e integrais de Kirkwood-Buff para soluções com mais de um solvente.

## 4. Funções de distribuição da água e do TFE

As funções de distribuição do TFE e da água em torno da proteína podem ser calculadas com os scripts que estão disponíveis na pasta `julia` desta seção. Os seguintes comandos vão executar os script que fazem os cálculos para cada um dos sistemas e tipos de solvente:
```julia
julia -t5 $repo/Analyses/julia/cm_tfe60.jl $repo $work
julia -t5 $repo/Analyses/julia/cm_water60.jl $repo $work
julia -t5 $repo/Analyses/julia/cm_water0.jl $repo $work
```

Estes scripts gerarão resultados que são salvos em três arquivos `.json` correspondentes. 

Em seguida, podemos fazer os gráficos dos resultados obtidos com os outros scripts disponíveis.
O seguinte comando vai gerar o gráfico MDDF do TFE decomposto em cada tipo de átomo:  
```julia
julia $repo/Analyses/julia/mddf_tfe.jl $repo $work
```

<img width=600px src=https://user-images.githubusercontent.com/31046348/119271660-da9d3d00-bbd8-11eb-8a13-f6920cc0dce5.png>

Nesta figura notamos os seguintes pontos:
1. O TFE forma ligações de hidrogênio com a proteína.
2. Praticamente todas as ligações de hidrogênio são através do seu hidrogênio da hidroxila. Isto é, praticamente não há ligações de hidrogênio nas quais o TFE atua como doador de par de elétrons. Evidentemente, isto se deve à baixa densidade eletrônica sobre o oxigênio que resulta dos átomos de flúor presentes na cadeia alifática.

As funções de distribuição da água para os dois sistemas vão ser graficadas simultaneamente, com o script que será executado por:
```julia
julia $repo/Analyses/julia/mddf_water.jl $repo $work
```

<img width=600px src=https://user-images.githubusercontent.com/31046348/119272657-6c0eae00-bbdd-11eb-839b-43ea14dfa482.png>

Em uma primeira impressão, pode-se pensar que a água está formando mais ligações de hidrogênio com o peptídeo na presença de TFE que na água pura. No entanto, note que a concentração de água é muito diferente nas duas simulações. Como vimos, em água pura a concentração ficou em `~55.3 mol/L`, enquanto que na simulação com TFE temos uma concentração de aproximadamente a metade (`27.1 mol/L`). Portanto, para que tivéssemos o mesmo *número* de ligações de hidrogênio com a água na solução com TFE, o pico em `~1.8AA` deveria ter aproximadamente o dobro da altura (ou o dobro da integral, mas precisamente). Este efeito de concentração pode ser explorado calculando diretamente o número de ligações de hidrogênio peptídeo-água em estudo complementar. 

## <a name="equi"></a>4. Acúmulo e depleção dos solventes

A partir das MDDFs é possível calcular propriedades termodinâmicas macroscópicas das soluções, usando a Teoria de Soluções de Kirkwood-Buff. Nos arquivos ```.json```, além das MDDFs, também há informação das integrais de Kirkwood-Buff (KB). As integrais de KB refletem a afinidade entre o soluto e as moléculas de solvente, e determinam se há excesso ou exclusão de cada componente do solvente nas vizinhanças do soluto. Dessa forma, avaliando o perfil das integrais de KB da água e do TFE, é possível dizer se cada componente é acumulado ou é excluído da região onde a proteína se encontra. Quando o solvente se encontra preferencialmente próximo à superfície da proteína, o valor de integral de KB deve ser positivo, e negativo caso seja preferencialmente excluído. Nas figuras a seguir, podemos analisar o perfil das integrais de KB para a água em relação à proteína em água pura e na solução com TFE, e do TFE na solução. 

<img width=800px src=https://user-images.githubusercontent.com/31046348/119273376-10deba80-bbe1-11eb-8107-78f61266cc49.png>

Vemos que as três curvas tem limites negativos em grandes distânicias, indicando que todos os solventes estão de forma global excluídos da região da proteína. Isto se deve a que às interações proteína-solventes não, em nenhum dos casos, suficientemente favoráveis para compensar a exclusão pelo volume da proteína, que se observa em distâncias curtas. Solventes desnaturantes, que interagem fortemente com a superfície da proteína, podem apresentar esse comportamento ([ref](https://pubs.rsc.org/en/content/articlelanding/2019/CP/C9CP05196A#!divAbstract),[ref](http://pubs.acs.org/doi/abs/10.1021/acs.jctc.7b00599)). 



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

