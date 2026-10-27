# ==============================================================================
# DesativarAgendamento.ps1
# Remove o agendamento da Pausa de Água e Exercício (todos os usuários)
# ==============================================================================
$tasks = Get-ScheduledTask -TaskName "PausaAgua_HoraEmHora*" -ErrorAction SilentlyContinue

if ($tasks) {
    foreach ($t in $tasks) {
        Unregister-ScheduledTask -TaskName $t.TaskName -Confirm:$false
        Write-Host "✅ Tarefa '$($t.TaskName)' desativada e removida com sucesso!" -ForegroundColor Green
    }
} else {
    Write-Host "ℹ️ Nenhuma tarefa 'PausaAgua_HoraEmHora*' está cadastrada." -ForegroundColor Yellow
}