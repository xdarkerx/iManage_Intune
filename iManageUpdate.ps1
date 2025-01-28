# log
$logDir = "C:\IntuneLogs\iManageInstall"
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

$programName = "iManage Work"
 
# Versões
$x86 = Join-Path $PSScriptRoot "iManageWorkDesktopforWindowsx86.exe"
$x64 = Join-Path $PSScriptRoot "iManageWorkDesktopforWindowsx64.exe"



$program = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*$programName*" }

# Verifica se o programa foi encontrado
if ($program) {
    $uninstallCommand = $program.IdentifyingNumber  # IdentifyingNumber é a GUID do programa
    Write-Log "Programa encontrado: $($program.Name)"
    Write-Log "Comando de desinstalação: msiexec /x $uninstallCommand"
    
    # Executa o comando de desinstalação com msiexec
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/x $uninstallCommand /quiet /norestart"
    Write-Log "Desinstalação iniciada com sucesso."
} else {
    Write-Log "Programa '$programName' não encontrado."
}

# Verifica a versão do Office instalada
$officeVersion = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration" -name "Platform").Platform

Write-Log "Finalizando processos do iManage antes da instalação..."
Stop-Process -Name "IWAGENT" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "IWWCS" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "iwSingleton" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "iwAgentBackground" -Force -ErrorAction SilentlyContinue

if ($officeVersion -like "x64") {
    Write-Log "Executando instalação para Office x64..."
    Start-Process -FilePath $x64 -ArgumentList "/s"
    Start-Sleep -Seconds 120
        
} elseif ($officeVersion -like "x86") {
    Write-Log "Executando instalação para Office x86..."
    Start-Process -FilePath $x86 -ArgumentList "/s"
    Start-Sleep -Seconds 120
        
} else {
    Write-Log "Versão do Office não identificada."
    Write-Log "Instalando versão do Office x64..."
    Start-Process -FilePath $x64 -ArgumentList "/s"
    Start-Sleep -Seconds 120 
    exit
}

$filePath = "C:\ProgramData\iManage\Work\iManageWorkDesktopForWindows\iManageWorkDesktopforWindows.exe"

if (Test-Path $filePath) {
    Write-Log "Arquivo encontrado. Executando limpeza..."
    Start-Process -FilePath $filePath -ArgumentList "/cleanup"
        
} else {
    Write-Log "Arquivo não encontrado. Instalação pode não ter sido bem-sucedida."
}

Write-Log "Finalizando a instalação."
