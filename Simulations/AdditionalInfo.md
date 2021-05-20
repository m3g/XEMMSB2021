
# Notas sobre construção de sistemas complexos

Neste curso, estudamos um peptídeo solvatado por água e 2,2-trifluoroetanol (TFE). O soluto será o peptídeo `(AAQAA)3`. 

## Criação da configuração inicial com Packmol

A primeira etapa para a realização de uma simulação de dinâmica molecular consiste na criação do das posições iniciais para todos os átomos do sistema. Para sistemas mais simples (uma proteína em água e algum contra-íon comum) existem ferramentas automáticas na maior parte dos pacotes de simulação. No entanto, quando queremos estudar sistemas mais complexos, como este que possui um cossolvente não tão comum, é necessário construir a caixa usando o Packmol.

Para criar uma configuração inicial do sistema de interesse com o Packmol e realizar uma simulação de dinâmica molecular, são necessários arquivos de coordenadas da proteína, de uma molécula do cossolvente, de uma molécula de água, e dos contra-íons. Eventualmente de quaisquer outras espécies que forem compor o sistema.

Normalmente, o arquivo de coordenadas está são usados no formato PDB. Desta forma, é preciso o arquivos PDB para o soluto, para a água e para o cossolvente. Podemos conseguir estas estas estruturas, por exemplo, da seguinte forma:

### Proteína

O maior banco de dados de estruturas proteicas é o Protein Data Bank (https://www.rcsb.org/). Portanto, a estrutura da proteína pode ser obtida por meio desse banco de dados. Não é o caso neste curso, em que estamos estudando um peptídeo simples que pode ser construído com uma das ferramentas mencionadas abaixo.  

### Cossolvente
 
Existem algumas alternativas para obter a estrutura de uma molécula do cossolvente utilizado nas simulações

i) construir e otimizar o cossolvente em um algum editor molecular, como o [Avogadro](https://avogadro.cc/) ou [Molden](https://www3.cmbi.umcn.nl/molden/).

ii) obter a estrutura do cossolvente no repositório Automated Topology Builder (ATB). O ATB é um repositório que fornece tanto a topologia para simulações por Dinâmica Molecular clássica, quanto as coordenadas das moléculas. Para obter mais detalhes sobre o repositório, o nível de teoria em que as moléculas são otimizadas, arquivos de parâmetros, entre outras informações, acesse o link [https://atb.uq.edu.au/](https://atb.uq.edu.au/). 

### Água
 
As coordenadas de uma molécula de água pode ser obtida diretamente de repositórios contendo os arquivos de topologia compatíveis com o GROMACS ([http://www.gromacs.org/Downloads/User_contributions/Force_fields](http://www.gromacs.org/Downloads/User_contributions/Force_fields)).  

### Íons monoatômicos (Na+ e Cl-)
 
Pode-se construir um arquivo no formato PDB com as coordenadas X, Y e Z de cada contra-íon como (0,0,0), e com nome do íon correspondente ao íon no campo de força utilizado.

## Configuração, topologia e campos de força

São necessários arquivos de topologia (`.top`), utilizados para descrever os potenciais ligados e não ligados de cada componente do sistema na simulação e os arquivos contendo os parâmetros da dinâmica molecular (`.mdp`). Para cada etapa de simulação (minimização, equilibração, produção), é necessário um arquivo de configuração diferente especificando os detalhes da execução, como o tempo de simulação, temperatura, pressão, etc. 

Dispondo dos arquivos mencionados é possível gerar o arquivo final de topologia (`.tpr`), que contém todas as informações necessárias para iniciar uma simulação com o software GROMACS. 
 
### Parâmetros para a proteína, proteína, água, cossolvente e contra-íons:
 
Diferentes campos de força para a proteína, moléculas de água e contra-íons, que são compatíveis com o pacote de simulação GROMACS, podem ser obtidos em [Force_Fields](http://www.gromacs.org/Downloads ). 

Quando o cossolvente não é muito comum, a escolha geralmente depende do campo de força utilizado para descrever a proteína nas simulações. Por exemplo, os parâmetros para diferentes moléculas que são derivados pelo ATB têm a função potencial do campo de força GROMOS. Então, para utilizar os parâmetros do ATB para o cossolvente, é recomendado utilizar também um campo de força GROMOS para descrever a proteína na simulação.
 
No nosso caso, estamos utilizando um campo de força AMBER para descrever a proteína ([amber03w](https://pubs.acs.org/doi/abs/10.1021/jp108618d)) e o [cossolvente](https://pubs.acs.org/doi/10.1021/jp505861b). Além dos campos de força AMBER, em formatos compatíveis com o GROMACS, outros parâmetros AMBER para o cossolvente podem ser obtidos de forma automática com o servidor [ACPYPE](https://github.com/llazzaro/acpype). Entretanto, parâmetros CHARMM e OPLS para o cossolvente, e que são compatíveis com o GROMACS, também podem ser obtidos de forma automática em outros servidores.
 
### Arquivos de parâmetros da dinâmica molecular
 
Para a realização da dinâmica molecular são necessários arquivos que contenham os parâmetros para a simulação (temperatura, tipo de termostato, pressão, etc.). Os arquivos variam dependendo do caso. Contudo, para qualquer simulação que utilize o gromacs, vale à pena analisar os arquivos modelos do ótimo tutorial montado pelo professor Justin Lemkul.
 
Minimização (http://www.mdtutorials.com/gmx/lysozyme/Files/minim.mdp)
Equilibração NVT ([](http://www.mdtutorials.com/gmx/lysozyme/Files/nvt.mdp))
Equilibração NPT ([](http://www.mdtutorials.com/gmx/lysozyme/Files/npt.mdp))
Produção ([](http://www.mdtutorials.com/gmx/lysozyme/Files/md.mdp))




 
 

