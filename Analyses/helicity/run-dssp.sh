#!/bin/bash

# Gerar os arquivos .pdb de cada frame da simulação
echo 1 | gmx trjconv -f production-center.xtc -s production.tpr -o $1.pdb -sep

# Calcular os elementos de estrutura secundária com o software DSSP
       for i in {0..1000}; do
       
         mkdssp -i $i.pdb -o $i.dssp

       done

# Recortar o arquivos .dssp
       for i in {0..1000}; do
       
         sed -n 29,42p $i.dssp > $i.txt

       done

       for i in {0..1000};do

         cat $i.txt | awk '{print $4}' > $i.dat

       done

# Construir uma matriz com M linhas (14 linhas, que reflete o número de resíduos do peptídeo) e N colunas (1001, que é igual ao número de frames da simulação)
       for i in {0..1000};do

         paste {0..1000}.dat > matrix-all.xvg

       done

# Backup do arquivo matrix-correct.xvg
       cp matrix-all.xvg matrix.xvg

# Contruir uma matriz de 0 (para qualquer atribuição diferente de H) e 1 (quando o resíduo for atribuído como H) 
       sed -i 's/H/1/g' matrix.xvg
       sed -i 's/G/0/g' matrix.xvg
       sed -i 's/I/0/g' matrix.xvg
       sed -i 's/T/0/g' matrix.xvg
       sed -i 's/E/0/g' matrix.xvg
       sed -i 's/B/0/g' matrix.xvg
       sed -i 's/S/0/g' matrix.xvg
       sed -i 's/C/0/g' matrix.xvg
       sed -i 's/>/0/g' matrix.xvg
       sed -i 's/</0/g' matrix.xvg
       sed -i 's/+/0/g' matrix.xvg
       sed -i 's/-/0/g' matrix.xvg
       sed -i 's/X/0/g' matrix.xvg


