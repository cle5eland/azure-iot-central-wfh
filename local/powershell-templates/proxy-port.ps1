#! /usr/bin/pwsh
$alias=$args[0]
$ip=$args[1]
ssh -D 9030 -f -C -q -N $alias@$ip -p 22