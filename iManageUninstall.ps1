# log
$logDir = "C:\IntuneLogs\iManageUninstall"
$logFile = "$logDir\iManager.txt"

if (-not (Test-Path -Path $logDir)) {
    Write-Host "Criando diretório de logs: $logDir"
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

# Caminho do comando de desinstalação
$ProgramPath = "C:\ProgramData\iManage\Work\iManageWorkDesktopForWindows\iManageWorkDesktopForWindows.exe"

if (Test-Path $ProgramPath) {
    Write-Log "Comando de desinstalação encontrado: $ProgramPath  /uninstall /quiet"
    
    try {
        Write-Log "Iniciando desinstalação..."
        Start-Process -FilePath $ProgramPath -ArgumentList "/uninstall /quiet" -Wait
        Write-Log "Desinstalação iniciada com sucesso."
    } catch {
        Write-Log "Erro ao tentar executar o comando de desinstalação: $_"
    }
} else {
    Write-Log "Programa iManage Work não encontrado no caminho especificado."
}
