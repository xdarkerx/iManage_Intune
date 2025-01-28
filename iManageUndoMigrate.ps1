#Logs:
$logDir = "C:\Logs\Imanager"
$logFile = "$logDir\undoMigrateImanager.txt"

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

Remove-Item "$env:APPDATA\iManage\Work\HomeServer\home-server.xml" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:APPDATA\iManage\Work\Configs\*.config" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:APPDATA\iManage\Work\Configs\*.xml" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:APPDATA\iManage\Work\WebCache\*" -Force -ErrorAction SilentlyContinue
Write-Log "Arquivos antigos removidos."

Remove-Item "$env:APPDATA\iManage\Work\Configs\user" -Recurse -Force -ErrorAction SilentlyContinue

# Cria o diretório 'user' em Configs, se não existir
$workConfigDir = "$env:USERPROFILE\AppData\Roaming\iManage\Work\Configs\user"
If (-not (Test-Path -Path $workConfigDir)) {
    New-Item -Path $workConfigDir -ItemType Directory -Force
}

Copy-Item -Path "$(Get-Location)\local.config" "$env:APPDATA\iManage\Work\Configs\user\iManWork.config" -Force
Write-Host "Arquivo cloud.config movido e renomeado para iManWork.config."

Set-ItemProperty -Path "HKCU:\Software\iManage" -Name "Version" -Value "Local" -Force

# Reinicia os processos que foram encerrados
Stop-Process -Name "IWAGENT" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "IWWCS" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "iwSingleton" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "iwAgentBackground" -Force -ErrorAction SilentlyContinue
Write-Log "Processos finalizados."

# ********************END WORKSITE**********************************

Write-Log "Configurações desfeitas com sucesso."
