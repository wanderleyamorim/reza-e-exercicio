@echo off
title Desativar Pausa da Agua e Reza
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0DesativarAgendamento.ps1"
echo.
pause
