@echo off
title Ativar Pausa da Agua e Reza
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0AtivarAgendamento.ps1"
echo.
pause
