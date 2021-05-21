# Simulação de enovelamento de proteínas e efeitos de solvente


## Analise das simulações

* [1. Cálculo da helipticidade](#helix)
* [2. Raio de giração](#config)
* [3. Estrutura de solvatação](#min)
* [4. Acúmulo e depleção do TFE](#equi)

## <a name="helix"></a>1. Cálculo da helipticidade do peptídeo

O trifluoretanol (TFE) é um cossolvente conhecido por induzir a formação de hélices em peptídeos e proteínas. Portanto, vamos iniciar nossas análises avaliando o conteúdo de alfa hélices nas simulações contendo água pura, e também em soluções contendo o TFE. A atribuição de estrutura secundária para os resíduos do peptídeo pode ser feita com o Dicionário de Estrutura Secundária de Proteínas (do inglês, Dictionary of Secondary Structure of Proteins, DSSP). Existe uma plataforma online para o DSSP (http://bioinformatica.isa.cnr.it/SUSAN/DSSP-web/), mas o software também pode ser facilmente instalado com o ```sudo apt install dssp```. O DDSP atribui elementos de estrutura secundária para os resíduos da proteína por meio de alguns caracteres, por exemplo:

G = hélice 310
H = α-hélice
I = hélice π
T = turn
E = folhas-β paralelas e antiparalelas
B = resíduo isolado em uma ponte-β
S = bend
C = coil

Como nosso interesse é avaliar a indução de hélices pelo TFE, vamos quantificar apenas o elemento de estrutura secundária "H" de acordo com as instruções a seguir. 

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

<img width=800px src=https://user-images.githubusercontent.com/31046348/119068971-95e88a80-b9bb-11eb-89bf-515e16001a2b.png>

## <a name="config"></a>2. Raio de giração


## <a name="min"></a>3. Estrutura de solvatação


## <a name="equi"></a>4. Acúmulo e depleção do TFE



