#!/bin/bash

XEMMSB_dir=$1

if [ -z "$XEMMSB_dir" ]; then
  echo "Run with: ./install.sh /home/user/installation_dir"
  exit
fi

if [[ ! -d "$XEMMSB_dir" ]]; then
    echo "$XEMMSB_dir does not exist. Create it first. "
    exit
fi


## Baixando inputs e dados de simulações prontas 

cd $XEMMSB_dir
wget https://raw.githubusercontent.com/m3g/XEMMSB2021/main/INPUTS  # inputs
wget https://raw.githubusercontent.com/m3g/XEMMSB2021/main/DADOS   # dados
wget https://raw.githubusercontent.com/m3g/XEMMSB2021/main/run-md.sh



