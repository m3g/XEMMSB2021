# Simulação de enovelamento de proteínas e efeitos de solvente

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

O arquivo `input-tfe-60.jl` cria um arquivo de input para o [Packmol](http://leandro.iqm.unicamp.br/m3g/packmol/home.shtml) que irá criar um caixa cúbica com seus lados medindo `56 Angstrons`, além de moléculas de água e TFE para que haja um solução de 60 %v/v de TFE. As quantidades de cada molécula podem ser verificadas no arquivo `box.inp`.

Para criar a caixa usando o packmol basta fazer:
```
packmol < box.inp
```




[plumed](https://www.plumed.org/doc-v2.6/user-doc/html/hrex.html)







### <a name="min"></a>Minimização do sistema


### <a name="equi"></a>Equilibração da temperatura e da pressão


### <a name="prod"></a>Produção - HREMD




## 3. Verificação dos resultados































































































































































































