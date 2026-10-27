# ==============================================================================
# AtivarAgendamento.ps1
# Configura o Agendamento no Windows para rodar todo minuto :04 da hora
# Integrado ao Projeto Reza-e-Exercício (Ativo para todos os usuários locais)
# ==============================================================================
$baseTaskName = "PausaAgua_HoraEmHora"
$scriptPath = Join-Path $PSScriptRoot "ExecutarPausa.ps1"

# 1. Ação: Chama o PowerShell em modo oculto
$action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File ""$scriptPath"""

# 2. Gatilho: Repete a cada 1 hora, disparando sempre no minuto :04
# Começando da data de hoje às 00:04
$baseTime = (Get-Date).Date.AddMinutes(4)
$trigger = New-ScheduledTaskTrigger `
    -Once `
    -At $baseTime `
    -RepetitionInterval (New-TimeSpan -Hours 1) `
    -RepetitionDuration (New-TimeSpan -Days 3650)

# 3. Configurações de execução
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 20) `
    -MultipleInstances IgnoreNew

# 4. Identifica os usuários locais interativos (ex.: INSS e Wanderley Amorim)
$targetUsers = @(
    Get-LocalUser -ErrorAction SilentlyContinue | Where-Object {
        $_.Enabled -and $_.Name -notmatch '^(CodexSandbox|DefaultAccount|WDAGUtilityAccount|Convidado|Guest|Administrador|Administrator)'
    } | Select-Object -ExpandProperty Name
)

if (-not $targetUsers -or $targetUsers.Count -eq 0) {
    $targetUsers = @($env:USERNAME)
}

foreach ($userName in $targetUsers) {
    $safeSuffix = ($userName -replace '[^a-zA-Z0-9]', '_')
    $taskName = if ($userName -eq "INSS") { $baseTaskName } else { "${baseTaskName}_${safeSuffix}" }

    try {
        $principal = New-ScheduledTaskPrincipal `
            -UserId "$env:COMPUTERNAME\$userName" `
            -LogonType Interactive

        Register-ScheduledTask `
            -TaskName $taskName `
            -Action $action `
            -Trigger $trigger `
            -Settings $settings `
            -Principal $principal `
            -Force -ErrorAction Stop | Out-Null

        Write-Host "✅ Tarefa '$taskName' ativada para o usuário '$userName'!" -ForegroundColor Green
    } catch {
        Write-Host "⚠️ Não foi possível registrar para '$userName' (execute como Administrador para outros usuários): $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Write-Host "Caminho do script: $scriptPath" -ForegroundColor Gray
Write-Host "Horário de disparo: A cada 1 hora (no minuto :04 para aviso e :05 para pausa de 5 minutos)." -ForegroundColor Cyan