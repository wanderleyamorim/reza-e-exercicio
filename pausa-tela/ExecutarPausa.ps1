# ==============================================================================
# ExecutarPausa.ps1
# Pausa Obrigatória de Hidratação, Movimento & Reflexão
# Integrado ao Projeto Reza-e-Exercício (mesmo conteúdo enviado ao Telegram)
# ==============================================================================
param(
    [int]$DuracaoMinutos = 5,
    [int]$DuracaoSegundos = 0,
    [int]$AvisoSegundos = 60,
    [int]$Hora = -1,
    [switch]$SemAviso = $false
)

# Força codificação UTF-8 no ambiente PowerShell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

# -------------------------------------------------------------
# OBTÉM O CONTEÚDO DO HORÁRIO VIA NODE.JS (COM BASE64 UTF-8)
# -------------------------------------------------------------
$scriptDir = $PSScriptRoot
$projectRoot = Split-Path $scriptDir -Parent
$nodeScript = Join-Path $projectRoot "scripts\obter-lembrete.mjs"

$lembrete = $null
if (Test-Path $nodeScript) {
    try {
        # Chamada direta sem splatting para evitar qualquer decomposição de strings
        if ($Hora -ge 0) {
            $b64 = & node "$nodeScript" "$Hora" "--base64" 2>$null
        } else {
            $b64 = & node "$nodeScript" "--base64" 2>$null
        }

        if ($b64) {
            $bytes = [System.Convert]::FromBase64String($b64.Trim())
            $jsonUtf8 = [System.Text.Encoding]::UTF8.GetString($bytes)
            $lembrete = $jsonUtf8 | ConvertFrom-Json
        }
    } catch {}
}

# -------------------------------------------------------------
# FASE 1: AVISO PRÉVIO FLUTUANTE (1 minuto antes da pausa)
# -------------------------------------------------------------
if (-not $SemAviso -and $AvisoSegundos -gt 0) {
    try {
        [System.Media.SystemSounds]::Asterisk.Play()
    } catch {}

    $primaryScreen = [System.Windows.Forms.Screen]::PrimaryScreen
    $toast = New-Object System.Windows.Forms.Form
    $toast.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
    $toast.StartPosition = [System.Windows.Forms.FormStartPosition]::Manual
    $toast.Size = New-Object System.Drawing.Size(460, 120)
    $toast.Location = New-Object System.Drawing.Point(
        ($primaryScreen.WorkingArea.Right - 480),
        ($primaryScreen.WorkingArea.Bottom - 140)
    )
    $toast.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#0F172A")
    $toast.TopMost = $true
    $toast.ShowInTaskbar = $false

    $accentBar = New-Object System.Windows.Forms.Panel
    $accentBar.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#0284C7")
    $accentBar.Size = New-Object System.Drawing.Size(8, 120)
    $accentBar.Location = New-Object System.Drawing.Point(0, 0)
    $toast.Controls.Add($accentBar)

    # Ícone do Toast
    $toastIco = New-Object System.Windows.Forms.Label
    $toastIco.Text = "💧"
    $toastIco.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 14)
    $toastIco.Location = New-Object System.Drawing.Point(18, 12)
    $toastIco.Size = New-Object System.Drawing.Size(30, 26)
    $toast.Controls.Add($toastIco)

    $lblToastTitle = New-Object System.Windows.Forms.Label
    $lblToastTitle.Text = "Pausa da Água & Reza em Breve"
    $lblToastTitle.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#38BDF8")
    $lblToastTitle.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $lblToastTitle.Location = New-Object System.Drawing.Point(52, 12)
    $lblToastTitle.Size = New-Object System.Drawing.Size(390, 26)
    $toast.Controls.Add($lblToastTitle)

    $temaMsg = if ($lembrete -and $lembrete.dentroDaJanela -and $lembrete.tema) { "Tema: $($lembrete.tema). " } else { "" }
    $lblToastMsg = New-Object System.Windows.Forms.Label
    $lblToastMsg.Text = "Em 1 minuto a tela será pausada por 5 minutos para água, exercício e oração. ${temaMsg}Salve seu trabalho!"
    $lblToastMsg.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#E2E8F0")
    $lblToastMsg.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Regular)
    $lblToastMsg.Location = New-Object System.Drawing.Point(22, 44)
    $lblToastMsg.Size = New-Object System.Drawing.Size(425, 65)
    $toast.Controls.Add($lblToastMsg)

    $toast.Show()
    $toast.Refresh()

    $tempoToast = [Math]::Min($AvisoSegundos, 12)
    Start-Sleep -Seconds $tempoToast
    $toast.Close()
    $toast.Dispose()

    $tempoRestanteAviso = $AvisoSegundos - $tempoToast
    if ($tempoRestanteAviso -gt 0) {
        Start-Sleep -Seconds $tempoRestanteAviso
    }
}

# -------------------------------------------------------------
# FASE 2: BLOQUEIO TOTAL DA TELA (MODO DISCIPLINA SEM BURLAR)
# -------------------------------------------------------------
$script:CanClose = $false
if ($DuracaoSegundos -gt 0) {
    $script:SegundosRestantes = $DuracaoSegundos
} else {
    $script:SegundosRestantes = $DuracaoMinutos * 60
}
$script:TotalSegundos = [Math]::Max(1, $script:SegundosRestantes)

$allForms = @()

foreach ($screen in [System.Windows.Forms.Screen]::AllScreens) {
    $f = New-Object System.Windows.Forms.Form
    $f.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
    $f.StartPosition = [System.Windows.Forms.FormStartPosition]::Manual
    $f.Location = $screen.Bounds.Location
    $f.Size = $screen.Bounds.Size
    $f.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#070B14")
    $f.TopMost = $true
    $f.ShowInTaskbar = $false
    $f.KeyPreview = $true

    $f.Add_FormClosing({
        if (-not $script:CanClose) {
            $_.Cancel = $true
        }
    })

    $f.Add_KeyDown({
        $_.SuppressKeyPress = $true
        $_.Handled = $true
    })

    $f.Add_Deactivate({
        $this.TopMost = $true
        $this.BringToFront()
        $this.Activate()
    })

    if ($screen.Primary) {
        $mainForm = $f

        # Container Principal
        $cWidth = [Math]::Min(2360, [int]($screen.Bounds.Width * 0.96))
        $cHeight = [Math]::Min(980, [int]($screen.Bounds.Height * 0.95))
        $container = New-Object System.Windows.Forms.Panel
        $container.Size = New-Object System.Drawing.Size($cWidth, $cHeight)
        $container.Location = New-Object System.Drawing.Point(
            ([int](($screen.Bounds.Width - $cWidth) / 2)),
            ([int](($screen.Bounds.Height - $cHeight) / 2))
        )
        $container.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#070B14")
        $f.Controls.Add($container)

        # PAINEL ESQUERDO: Cronômetro, Água & Status (Largura: 500px)
        $leftPanelWidth = 500
        $leftPanel = New-Object System.Windows.Forms.Panel
        $leftPanel.Size = New-Object System.Drawing.Size($leftPanelWidth, $cHeight)
        $leftPanel.Location = New-Object System.Drawing.Point(0, 0)
        $leftPanel.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#0D1527")
        $container.Controls.Add($leftPanel)

        # Ícone de Gota
        $lblIcon = New-Object System.Windows.Forms.Label
        $lblIcon.Text = "💧"
        $lblIcon.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 42)
        $lblIcon.Size = New-Object System.Drawing.Size($leftPanelWidth, 60)
        $lblIcon.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $lblIcon.Location = New-Object System.Drawing.Point(0, 20)
        $leftPanel.Controls.Add($lblIcon)

        # Título
        $lblTitle = New-Object System.Windows.Forms.Label
        $lblTitle.Text = "PAUSA, ÁGUA & REZA"
        $lblTitle.Font = New-Object System.Drawing.Font("Segoe UI", 17, [System.Drawing.FontStyle]::Bold)
        $lblTitle.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#F8FAFC")
        $lblTitle.Size = New-Object System.Drawing.Size($leftPanelWidth, 32)
        $lblTitle.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $lblTitle.Location = New-Object System.Drawing.Point(0, 85)
        $leftPanel.Controls.Add($lblTitle)

        # Subtítulo
        $lblSubtitle = New-Object System.Windows.Forms.Label
        $lblSubtitle.Text = "Conteúdo oficial do seu Telegram!`nBeba 250ml de água e faça a prática ao lado."
        $lblSubtitle.Font = New-Object System.Drawing.Font("Segoe UI", 10.5, [System.Drawing.FontStyle]::Regular)
        $lblSubtitle.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#94A3B8")
        $lblSubtitle.Size = New-Object System.Drawing.Size($leftPanelWidth, 45)
        $lblSubtitle.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $lblSubtitle.Location = New-Object System.Drawing.Point(0, 122)
        $leftPanel.Controls.Add($lblSubtitle)

        # Cronômetro Gigante
        $script:lblTimer = New-Object System.Windows.Forms.Label
        $min = [int]([Math]::Floor($script:SegundosRestantes / 60))
        $sec = $script:SegundosRestantes % 60
        $script:lblTimer.Text = ("{0:D2}:{1:D2}" -f $min, $sec)
        $script:lblTimer.Font = New-Object System.Drawing.Font("Consolas", 58, [System.Drawing.FontStyle]::Bold)
        $script:lblTimer.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#38BDF8")
        $script:lblTimer.Size = New-Object System.Drawing.Size($leftPanelWidth, 85)
        $script:lblTimer.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $script:lblTimer.Location = New-Object System.Drawing.Point(0, 175)
        $leftPanel.Controls.Add($script:lblTimer)

        # Barra de Progresso
        $script:progressBar = New-Object System.Windows.Forms.ProgressBar
        $script:progressBar.Size = New-Object System.Drawing.Size(400, 12)
        $script:progressBar.Location = New-Object System.Drawing.Point(50, 275)
        $script:progressBar.Maximum = $script:TotalSegundos
        $script:progressBar.Value = $script:TotalSegundos
        $script:progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
        $leftPanel.Controls.Add($script:progressBar)

        # Card de Dicas de Saúde
        $pnlSaude = New-Object System.Windows.Forms.Panel
        $pnlSaude.Size = New-Object System.Drawing.Size(440, 280)
        $pnlSaude.Location = New-Object System.Drawing.Point(30, 315)
        $pnlSaude.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#131E38")
        $leftPanel.Controls.Add($pnlSaude)

        $lblSaudeIco = New-Object System.Windows.Forms.Label
        $lblSaudeIco.Text = "💡"
        $lblSaudeIco.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 12)
        $lblSaudeIco.Location = New-Object System.Drawing.Point(18, 14)
        $lblSaudeIco.Size = New-Object System.Drawing.Size(26, 25)
        $pnlSaude.Controls.Add($lblSaudeIco)

        $lblSaudeTitle = New-Object System.Windows.Forms.Label
        $lblSaudeTitle.Text = "DICAS DESTE INTERVALO"
        $lblSaudeTitle.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
        $lblSaudeTitle.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#38BDF8")
        $lblSaudeTitle.Location = New-Object System.Drawing.Point(46, 15)
        $lblSaudeTitle.Size = New-Object System.Drawing.Size(370, 25)
        $pnlSaude.Controls.Add($lblSaudeTitle)

        $lblSaudeMsg = New-Object System.Windows.Forms.Label
        $lblSaudeMsg.Text = "• Beba 200 a 300ml de água fresca agora.`n`n• Afaste o olhar do monitor e mire um ponto distante pela janela.`n`n• Faça o movimento do horário ao lado no seu ritmo, respirando continuamente.`n`n• O Windows será liberado sozinho ao zerar os 5 minutos!"
        $lblSaudeMsg.Font = New-Object System.Drawing.Font("Segoe UI", 10.5, [System.Drawing.FontStyle]::Regular)
        $lblSaudeMsg.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#CBD5E1")
        $lblSaudeMsg.Location = New-Object System.Drawing.Point(20, 48)
        $lblSaudeMsg.Size = New-Object System.Drawing.Size(400, 215)
        $pnlSaude.Controls.Add($lblSaudeMsg)

        # Rodapé do painel esquerdo
        $lblFooter = New-Object System.Windows.Forms.Label
        $lblFooter.Text = "Bloqueio Obrigatório • Sem senha • Retorno automático"
        $lblFooter.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
        $lblFooter.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#64748B")
        $lblFooter.Size = New-Object System.Drawing.Size($leftPanelWidth, 30)
        $lblFooter.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $lblFooter.Location = New-Object System.Drawing.Point(0, ($cHeight - 40))
        $leftPanel.Controls.Add($lblFooter)

        # PAINEL DIREITO: Os 6 Blocos Exatos do Telegram em Sequência
        $rightPanelX = $leftPanelWidth + 24
        $rightPanelWidth = $cWidth - $rightPanelX
        $rightPanel = New-Object System.Windows.Forms.Panel
        $rightPanel.Size = New-Object System.Drawing.Size($rightPanelWidth, $cHeight)
        $rightPanel.Location = New-Object System.Drawing.Point($rightPanelX, 0)
        $rightPanel.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#0D1527")
        $container.Controls.Add($rightPanel)

        if ($lembrete -and $lembrete.dentroDaJanela) {
            # CARD 1: ⏰ MOVIMENTO (Topo)
            $cardMov = New-Object System.Windows.Forms.Panel
            $cardMov.Size = New-Object System.Drawing.Size(($rightPanelWidth - 60), 125)
            $cardMov.Location = New-Object System.Drawing.Point(30, 20)
            $cardMov.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#111D36")
            $rightPanel.Controls.Add($cardMov)

            $barMov = New-Object System.Windows.Forms.Panel
            $barMov.Size = New-Object System.Drawing.Size(6, 125)
            $barMov.Location = New-Object System.Drawing.Point(0, 0)
            $barMov.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#10B981")
            $cardMov.Controls.Add($barMov)

            # Ícone Relógio (Segoe UI Emoji)
            $icoMov = New-Object System.Windows.Forms.Label
            $icoMov.Text = "⏰"
            $icoMov.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 13)
            $icoMov.Location = New-Object System.Drawing.Point(22, 10)
            $icoMov.Size = New-Object System.Drawing.Size(28, 24)
            $cardMov.Controls.Add($icoMov)

            $lblExTag = New-Object System.Windows.Forms.Label
            $lblExTag.Text = "MOVIMENTO (FAÇA AGORA)"
            $lblExTag.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
            $lblExTag.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#34D399")
            $lblExTag.Location = New-Object System.Drawing.Point(52, 12)
            $lblExTag.Size = New-Object System.Drawing.Size(($cardMov.Width - 65), 24)
            $cardMov.Controls.Add($lblExTag)

            $lblExText = New-Object System.Windows.Forms.Label
            $lblExText.Text = [string]$lembrete.exercicio
            $lblExText.Font = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
            $lblExText.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#FFFFFF")
            $lblExText.Location = New-Object System.Drawing.Point(25, 38)
            $lblExText.Size = New-Object System.Drawing.Size(($cardMov.Width - 50), 75)
            $cardMov.Controls.Add($lblExText)

            # CARD 2: 🧭 TEMA, PALAVRAS SIMPLES, EXEMPLO & FAÇA AGORA (Meio)
            $cardMeio = New-Object System.Windows.Forms.Panel
            $cardMeio.Size = New-Object System.Drawing.Size(($rightPanelWidth - 60), 285)
            $cardMeio.Location = New-Object System.Drawing.Point(30, 160)
            $cardMeio.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#111D36")
            $rightPanel.Controls.Add($cardMeio)

            $barMeio = New-Object System.Windows.Forms.Panel
            $barMeio.Size = New-Object System.Drawing.Size(6, 285)
            $barMeio.Location = New-Object System.Drawing.Point(0, 0)
            $barMeio.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#F59E0B")
            $cardMeio.Controls.Add($barMeio)

            # 🧭 Tema
            $icoTema = New-Object System.Windows.Forms.Label
            $icoTema.Text = "🧭"
            $icoTema.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 14)
            $icoTema.Location = New-Object System.Drawing.Point(22, 10)
            $icoTema.Size = New-Object System.Drawing.Size(30, 28)
            $cardMeio.Controls.Add($icoTema)

            $lblTemaTag = New-Object System.Windows.Forms.Label
            $lblTemaTag.Text = "TEMA: " + [string]$lembrete.tema
            $lblTemaTag.Font = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
            $lblTemaTag.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#FBBF24")
            $lblTemaTag.Location = New-Object System.Drawing.Point(54, 12)
            $lblTemaTag.Size = New-Object System.Drawing.Size(($cardMeio.Width - 70), 28)
            $cardMeio.Controls.Add($lblTemaTag)

            # 💬 Em palavras simples
            $icoSimples = New-Object System.Windows.Forms.Label
            $icoSimples.Text = "💬"
            $icoSimples.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 10.5)
            $icoSimples.Location = New-Object System.Drawing.Point(22, 44)
            $icoSimples.Size = New-Object System.Drawing.Size(26, 20)
            $cardMeio.Controls.Add($icoSimples)

            $lblSimplesTag = New-Object System.Windows.Forms.Label
            $lblSimplesTag.Text = "EM PALAVRAS SIMPLES"
            $lblSimplesTag.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
            $lblSimplesTag.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#94A3B8")
            $lblSimplesTag.Location = New-Object System.Drawing.Point(50, 45)
            $lblSimplesTag.Size = New-Object System.Drawing.Size(($cardMeio.Width - 70), 18)
            $cardMeio.Controls.Add($lblSimplesTag)

            $lblSimples = New-Object System.Windows.Forms.Label
            $lblSimples.Text = [string]$lembrete.simples
            $lblSimples.Font = New-Object System.Drawing.Font("Segoe UI", 11.5, [System.Drawing.FontStyle]::Regular)
            $lblSimples.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#E2E8F0")
            $lblSimples.Location = New-Object System.Drawing.Point(25, 65)
            $lblSimples.Size = New-Object System.Drawing.Size(($cardMeio.Width - 50), 42)
            $cardMeio.Controls.Add($lblSimples)

            # 🏠 Exemplo do dia a dia
            $icoExemplo = New-Object System.Windows.Forms.Label
            $icoExemplo.Text = "🏠"
            $icoExemplo.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 10.5)
            $icoExemplo.Location = New-Object System.Drawing.Point(22, 114)
            $icoExemplo.Size = New-Object System.Drawing.Size(26, 20)
            $cardMeio.Controls.Add($icoExemplo)

            $lblExemploTag = New-Object System.Windows.Forms.Label
            $lblExemploTag.Text = "EXEMPLO DO DIA A DIA"
            $lblExemploTag.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
            $lblExemploTag.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#94A3B8")
            $lblExemploTag.Location = New-Object System.Drawing.Point(50, 115)
            $lblExemploTag.Size = New-Object System.Drawing.Size(($cardMeio.Width - 70), 18)
            $cardMeio.Controls.Add($lblExemploTag)

            $lblExemplo = New-Object System.Windows.Forms.Label
            $lblExemplo.Text = [string]$lembrete.exemplo
            $lblExemplo.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Regular)
            $lblExemplo.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#CBD5E1")
            $lblExemplo.Location = New-Object System.Drawing.Point(25, 135)
            $lblExemplo.Size = New-Object System.Drawing.Size(($cardMeio.Width - 50), 42)
            $cardMeio.Controls.Add($lblExemplo)

            # ✅ Faça agora
            $icoAcao = New-Object System.Windows.Forms.Label
            $icoAcao.Text = "✅"
            $icoAcao.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 11)
            $icoAcao.Location = New-Object System.Drawing.Point(22, 187)
            $icoAcao.Size = New-Object System.Drawing.Size(26, 20)
            $cardMeio.Controls.Add($icoAcao)

            $lblAcaoTag = New-Object System.Windows.Forms.Label
            $lblAcaoTag.Text = "FAÇA AGORA"
            $lblAcaoTag.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
            $lblAcaoTag.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#6EE7B7")
            $lblAcaoTag.Location = New-Object System.Drawing.Point(50, 188)
            $lblAcaoTag.Size = New-Object System.Drawing.Size(($cardMeio.Width - 70), 18)
            $cardMeio.Controls.Add($lblAcaoTag)

            $lblAcaoText = New-Object System.Windows.Forms.Label
            $lblAcaoText.Text = [string]$lembrete.acao
            $lblAcaoText.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
            $lblAcaoText.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#A7F3D0")
            $lblAcaoText.Location = New-Object System.Drawing.Point(25, 210)
            $lblAcaoText.Size = New-Object System.Drawing.Size(($cardMeio.Width - 50), 65)
            $cardMeio.Controls.Add($lblAcaoText)

            # CARD 3: 🙏 REZA & REFLEXÃO (Destaque Principal)
            $cardRezaY = 460
            $cardRezaHeight = $cHeight - $cardRezaY - 20
            $cardReza = New-Object System.Windows.Forms.Panel
            $cardReza.Size = New-Object System.Drawing.Size(($rightPanelWidth - 60), $cardRezaHeight)
            $cardReza.Location = New-Object System.Drawing.Point(30, $cardRezaY)
            $cardReza.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#14223E")
            $rightPanel.Controls.Add($cardReza)

            $barReza = New-Object System.Windows.Forms.Panel
            $barReza.Size = New-Object System.Drawing.Size(6, $cardRezaHeight)
            $barReza.Location = New-Object System.Drawing.Point(0, 0)
            $barReza.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#38BDF8")
            $cardReza.Controls.Add($barReza)

            # Ícone Oração (Segoe UI Emoji)
            $icoReza = New-Object System.Windows.Forms.Label
            $icoReza.Text = "🙏"
            $icoReza.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 14)
            $icoReza.Location = New-Object System.Drawing.Point(22, 11)
            $icoReza.Size = New-Object System.Drawing.Size(30, 28)
            $cardReza.Controls.Add($icoReza)

            $lblRezaTag = New-Object System.Windows.Forms.Label
            $tipoRezaStr = if ($lembrete.tipoReza -eq "longa") { " (REZA COMPLETA / LONGA)" } else { " (REZA DO HORÁRIO)" }
            $lblRezaTag.Text = "REZA & REFLEXÃO" + $tipoRezaStr
            $lblRezaTag.Font = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
            $lblRezaTag.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#60A5FA")
            $lblRezaTag.Location = New-Object System.Drawing.Point(54, 14)
            $lblRezaTag.Size = New-Object System.Drawing.Size(($cardReza.Width - 70), 28)
            $cardReza.Controls.Add($lblRezaTag)

            $lblRezaText = New-Object System.Windows.Forms.Label
            $lblRezaText.Text = '"' + [string]$lembrete.reflexao + '"'
            $lblRezaText.Font = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Italic)
            $lblRezaText.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#F8FAFC")
            $lblRezaText.Location = New-Object System.Drawing.Point(25, 48)
            $lblRezaText.Size = New-Object System.Drawing.Size(($cardReza.Width - 50), ($cardRezaHeight - 60))
            $cardReza.Controls.Add($lblRezaText)

        } else {
            $lblForaTag = New-Object System.Windows.Forms.Label
            $lblForaTag.Text = "HORÁRIO DE DESCANSO"
            $lblForaTag.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
            $lblForaTag.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#38BDF8")
            $lblForaTag.Location = New-Object System.Drawing.Point(40, 40)
            $lblForaTag.Size = New-Object System.Drawing.Size(($rightPanelWidth - 80), 40)
            $rightPanel.Controls.Add($lblForaTag)

            $lblForaMsg = New-Object System.Windows.Forms.Label
            $lblForaMsg.Text = "Os lembretes do projeto Reza-e-Exercício ocorrem entre 5h e 20h.`n`nAproveite esta pausa para relaxar os olhos, beber água e respirar fundo."
            $lblForaMsg.Font = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Regular)
            $lblForaMsg.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#CBD5E1")
            $lblForaMsg.Location = New-Object System.Drawing.Point(40, 95)
            $lblForaMsg.Size = New-Object System.Drawing.Size(($rightPanelWidth - 80), 100)
            $rightPanel.Controls.Add($lblForaMsg)
        }
    } else {
        # Tela Secundária (DISPLAY2) - Exibe TODOS os 6 blocos completos na ordem exata do Telegram
        $centerSec = New-Object System.Windows.Forms.Panel
        $sWidth = [Math]::Min(1140, [int]($screen.Bounds.Width * 0.92))
        $sHeight = [Math]::Min(920, [int]($screen.Bounds.Height * 0.92))
        $centerSec.Size = New-Object System.Drawing.Size($sWidth, $sHeight)
        $centerSec.Location = New-Object System.Drawing.Point(
            ([int](($screen.Bounds.Width - $sWidth) / 2)),
            ([int](($screen.Bounds.Height - $sHeight) / 2))
        )
        $centerSec.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#0D1527")
        $f.Controls.Add($centerSec)

        $lblSecIcon = New-Object System.Windows.Forms.Label
        $lblSecIcon.Text = "💧"
        $lblSecIcon.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 32)
        $lblSecIcon.Size = New-Object System.Drawing.Size($sWidth, 50)
        $lblSecIcon.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $lblSecIcon.Location = New-Object System.Drawing.Point(0, 15)
        $centerSec.Controls.Add($lblSecIcon)

        $lblSecTitle = New-Object System.Windows.Forms.Label
        $lblSecTitle.Text = if ($lembrete -and $lembrete.dentroDaJanela) { "TEMA: " + [string]$lembrete.tema } else { "Momento de Pausa & Hidratação" }
        $lblSecTitle.Font = New-Object System.Drawing.Font("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
        $lblSecTitle.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#F8FAFC")
        $lblSecTitle.Size = New-Object System.Drawing.Size(($sWidth - 40), 32)
        $lblSecTitle.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $lblSecTitle.Location = New-Object System.Drawing.Point(20, 70)
        $centerSec.Controls.Add($lblSecTitle)

        $txtSec = if ($lembrete -and $lembrete.dentroDaJanela) {
            "MOVIMENTO:`n" + [string]$lembrete.exercicio + "`n`n" +
            "EM PALAVRAS SIMPLES:`n" + [string]$lembrete.simples + "`n`n" +
            "EXEMPLO DO DIA A DIA:`n" + [string]$lembrete.exemplo + "`n`n" +
            "FAÇA AGORA:`n" + [string]$lembrete.acao + "`n`n" +
            "REZA & REFLEXÃO:`n`"" + [string]$lembrete.reflexao + '"'
        } else {
            "Aproveite para levantar, beber um copo de água e relaxar os olhos da tela.`n`nO computador retornará sozinho ao término do tempo!"
        }

        $lblSecMsg = New-Object System.Windows.Forms.Label
        $lblSecMsg.Text = $txtSec
        $lblSecMsg.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Regular)
        $lblSecMsg.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#CBD5E1")
        $lblSecMsg.Size = New-Object System.Drawing.Size(($sWidth - 60), ($sHeight - 120))
        $lblSecMsg.Location = New-Object System.Drawing.Point(30, 110)
        $centerSec.Controls.Add($lblSecMsg)
    }

    $allForms += $f
}

# Timer de 1 segundo
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000

$timer.Add_Tick({
    $script:SegundosRestantes--

    if ($script:SegundosRestantes -le 0) {
        $timer.Stop()
        $script:CanClose = $true

        try {
            [System.Media.SystemSounds]::Asterisk.Play()
        } catch {}

        foreach ($frm in $allForms) {
            $frm.Close()
            $frm.Dispose()
        }
        [System.Windows.Forms.Application]::Exit()
        return
    }

    $m = [int]([Math]::Floor($script:SegundosRestantes / 60))
    $s = $script:SegundosRestantes % 60
    if ($script:lblTimer) {
        $script:lblTimer.Text = ("{0:D2}:{1:D2}" -f $m, $s)
    }

    if ($script:progressBar -and $script:SegundosRestantes -ge 0) {
        $script:progressBar.Value = [Math]::Max(0, [Math]::Min($script:SegundosRestantes, $script:TotalSegundos))
    }

    foreach ($frm in $allForms) {
        if (-not $frm.TopMost) { $frm.TopMost = $true }
    }
})

try {
    [System.Media.SystemSounds]::Beep.Play()
} catch {}

foreach ($frm in $allForms) {
    $frm.Show()
    $frm.BringToFront()
    $frm.Activate()
}

$timer.Start()
[System.Windows.Forms.Application]::Run($mainForm)