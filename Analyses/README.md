# Simulação de enovelamento de proteínas e efeitos de solvente

## Analise das simulações

* [1. Cálculo da helipticidade](#helix)
* [2. Raio de giração](#config)
* [3. Estrutura de solvatação](#min)
* [4. Acúmulo e depleção do TFE](#equi)

## <a name="helix"></a>1. Cálculo da helipticidade do peptídeo

Entre no diretório `AAQAA_0vv/0`, que contém a simulação sem aproximação no potencial
para o peptídeo em água pura, e crie um diretório que conterá uma série de arquivos
temporários necessários para o cálculo da estrutura secundária:

```
cd $work/AAQAA_0vv/Simulations/0
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

Os arquivos `dsspX.pdb.dssp` gerados contém, para cada passo da simulação, a atribuição da estrutura secundária para cada resíduo. Podemos fazer gráficos de como evolui no tempo a estrutura secundária dos resíduos, e do conteúdo médio de &alpha;-hélices que cada resíduo possui.

Isto pode ser feito usando o script `dssp.jl`:  
```
cd $work
$repo/Analyses/helicity/dssp.jl $work
```

Este script lê os arquivos de saída do DSSP, e gera a figura `helicity.pdf`, que será parecida com:  

![image](https://user-images.githubusercontent.com/31046348/119068899-6fc2ea80-b9bb-11eb-9cc5-f1d01bf810d5.png)










