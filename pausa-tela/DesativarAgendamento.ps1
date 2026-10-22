# ==============================================================================
# DesativarAgendamento.ps1
# Remove o agendamento da Pausa de Água e Exercício
# ==============================================================================
$taskName = "PausaAgua_HoraEmHora"

if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    Write-Host "✅ Tarefa '$taskName' desativada e removida com sucesso!" -ForegroundColor Green
} else {
    Write-Host "ℹ️ A tarefa '$taskName' não está cadastrada." -ForegroundColor Yellow
}