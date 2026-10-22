@echo off
title Teste de Pausa - Reza Completa das 12h
echo Executando demonstracao com a reza longa das 12h...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ExecutarPausa.ps1" -Hora 12 -DuracaoSegundos 10 -SemAviso
