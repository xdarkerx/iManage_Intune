#Logs
$logDir = "C:\Logs\Imanager"
$logFile = "$logDir\migrateImanager.txt"

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

Remove-Item "$env:APPDATA\iManage\Work\HomeServer\home-server.xml" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:APPDATA\iManage\Work\Configs\*.config" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:APPDATA\iManage\Work\Configs\*.xml" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:APPDATA\iManage\Work\WebCache\*" -Force -ErrorAction SilentlyContinue
Write-Log "Arquivos antigos removidos."

Remove-Item "$env:APPDATA\iManage\Work\Configs\user" -Recurse -Force -ErrorAction SilentlyContinue

New-Item -Path "$env:APPDATA\iManage" -ItemType Directory -Force
New-Item -Path "$env:APPDATA\iManage\Work" -ItemType Directory -Force
New-Item -Path "$env:APPDATA\iManage\Work\Configs" -ItemType Directory -Force
New-Item -Path "$env:APPDATA\iManage\Work\Configs\user" -ItemType Directory -Force
Write-Log "Novos items Criados."

# copiar arquivo de configura��o
Copy-Item -Path "$(Get-Location)\cloud.config" "$env:APPDATA\iManage\Work\Configs\user\iManWork.config" -Force
Write-Host "Arquivo cloud.config movido e renomeado para iManWork.config."

Set-ItemProperty -Path "HKCU:\Software\iManage" -Name "Version" -Value "Cloud" -Force

# matar os processos
Stop-Process -Name "IWAGENT" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "IWWCS" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "iwSingleton" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "iwAgentBackground" -Force -ErrorAction SilentlyContinue
Write-Log "Processos finalizados."

# ********************FIM**********************************

Write-Log "Configurado com sucesso."