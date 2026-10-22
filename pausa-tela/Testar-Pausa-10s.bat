@echo off
title Teste de Pausa (10 segundos)
echo Executando demonstracao de 10 segundos com a reza e exercicio...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ExecutarPausa.ps1" -DuracaoSegundos 10 -SemAviso
