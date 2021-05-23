# Simulação de enovelamento de proteínas e efeitos de solvente

## Análise das simulações

### Parte 1
* [1. Cálculo da helipticidade](https://github.com/m3g/XEMMSB2021/tree/main/Analyses#1-c%C3%A1lculo-da-helipticidade-do-pept%C3%ADdeo)
* [2. Raio de giração](https://github.com/m3g/XEMMSB2021/tree/main/Analyses#2-raio-de-gira%C3%A7%C3%A3o)

### Parte 2
* [3. Estrutura de solvatação](https://github.com/m3g/XEMMSB2021/blob/main/Analyses/Solvation.md)
* [4. Acúmulo e depleção dos solventes](https://github.com/m3g/XEMMSB2021/blob/main/Analyses/Solvation.md#4-ac%C3%BAmulo-e-deple%C3%A7%C3%A3o-do-tfe)

## <a name="solv"></a>3. Estrutura de solvatação

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

## Executando o exemplo:

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

A função de distribuição de mínima distância (MDDF) deve convergir para `1` em distâncias longas. Nas últimas linhas vemos se isto aconteceu. É importante que o erro seja maior que a diferença entre entre a média e `1.0`, indicando que o erro é aleatório. Se tivéssemos um erro sistemático e a função convergisse para um número maior ou menor que `1.0`, mesmo que pouco, teríamos problemas na análise da integral desta função, que estudaremos a seguir.  







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
