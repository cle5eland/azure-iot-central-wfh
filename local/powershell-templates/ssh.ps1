#! /usr/bin/pwsh
$alias=$args[0]
$ip=$args[1]
ssh $alias@$ip
