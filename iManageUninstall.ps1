# log
$logDir = "C:\IntuneLogs\iManageUninstall"
$logFile = "$logDir\iManager.txt"

if (-not (Test-Path -Path $logDir)) {
    Write-Host "Criando diret�rio de logs: $logDir"
    New-Item -Path $logDir -ItemType Directory -Force
}

function Write-Log {
    param (
        [string]$message
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logMessage = "$timestamp - $message"
    Write-Host $logMessage
    Add-Content -Path $logFile -Value "$logMessage`r`n"
}

# Caminho do comando de desinstala��o
$ProgramPath = "C:\ProgramData\iManage\Work\iManageWorkDesktopForWindows\iManageWorkDesktopForWindows.exe"

if (Test-Path $ProgramPath) {
    Write-Log "Comando de desinstala��o encontrado: $ProgramPath  /uninstall /quiet"
    
    try {
        Write-Log "Iniciando desinstala��o..."
        Start-Process -FilePath $ProgramPath -ArgumentList "/uninstall /quiet" -Wait
        Write-Log "Desinstala��o iniciada com sucesso."
    } catch {
        Write-Log "Erro ao tentar executar o comando de desinstala��o: $_"
    }
} else {
    Write-Log "Programa iManage Work n�o encontrado no caminho especificado."
}
