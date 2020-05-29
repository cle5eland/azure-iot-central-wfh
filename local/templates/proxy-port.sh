#!/bin/bash
alias=$1
ip=$2
ssh -D 9030 -f -C -q -N $alias@$ip -p 22