# This script will disable SSL 3.0 for all server 
# software installed on a system, including IIS.
########################################################### 
#Requires -RunAsAdministrator

#---------------------------------------------------------- 
#VARIABLES
#---------------------------------------------------------- 
$RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\"
$RegName = "Server"
$RegItem = "Enable"
$RegValue = "0"
$RegType = "DWord"

#---------------------------------------------------------- 
#CHECK IF KEY EXISTS
#----------------------------------------------------------
function KeyCheck {
    param($ServerName)
    $RegTest = if ($ServerName -eq $env:COMPUTERNAME) {
        Test-Path "$RegPath\$RegName"
    } else {
        Invoke-Command -ComputerName $ServerName -ScriptBlock {
            Test-Path "$using:RegPath\$using:RegName"
        }
    }
    if ($RegTest -eq $true) {
        Write-Host "[$ServerName] Registry key already exists." -ForegroundColor Yellow
    } else { 
        try {
            if ($ServerName -eq $env:COMPUTERNAME) {
                New-Item -Path $RegPath -ItemType Directory -Name $RegName -Force -ErrorAction Stop | Out-Null
            } else {
                Invoke-Command -ComputerName $ServerName -ScriptBlock {
                    New-Item -Path $using:RegPath -ItemType Directory -Name $using:RegName -Force -ErrorAction Stop | Out-Null
                }
            }
            Write-Host "[$ServerName] Registry key created successfully." -ForegroundColor Green
        } catch {
            Write-Host "[$ServerName] Failed to create registry key: $_" -ForegroundColor Red
        }
    }
}

#---------------------------------------------------------- 
#SET THE DWORD VALUE
#----------------------------------------------------------
function SetRegValue {
    param($ServerName)
    try {
        if ($ServerName -eq $env:COMPUTERNAME) {
            Set-ItemProperty -Path "$RegPath\$RegName" -Name $RegItem -Value $RegValue -Type $RegType -ErrorAction Stop
        } else {
            Invoke-Command -ComputerName $ServerName -ScriptBlock {
                Set-ItemProperty -Path "$using:RegPath\$using:RegName" -Name $using:RegItem -Value $using:RegValue -Type $using:RegType -ErrorAction Stop
            }
        }
        Write-Host "[$ServerName] Registry value set successfully." -ForegroundColor Green
    } catch {
        Write-Host "[$ServerName] Failed to set registry value: $_" -ForegroundColor Red
    }
}

#---------------------------------------------------------- 
#MAIN FUNCTION
#----------------------------------------------------------
function Disable-SSLv3Server {
    param(
        [Parameter(Mandatory=$false)]
        [string]$ServerName = $env:COMPUTERNAME
    )
    Write-Host "Processing $ServerName..." -ForegroundColor Cyan
    Write-Host "[$ServerName] Checking registry key..."
    KeyCheck -ServerName $ServerName
    Write-Host "[$ServerName] Setting registry value..."
    SetRegValue -ServerName $ServerName
    Write-Host "[$ServerName] Processing completed." -ForegroundColor Green
}

#---------------------------------------------------------- 
#START
#----------------------------------------------------------
Clear-Host
Write-Host "Running Disable-SSLv3Server.ps1 - v1.2" -ForegroundColor Green
Write-Host "This script will disable SSL 3.0 for all server software installed on a system, including IIS." -ForegroundColor DarkGreen
Write-Host "Author: Branko Vucinec - 2015-07-15 (Updated 2024-12-22)" -ForegroundColor DarkGreen

# Prompt for server name or use local machine
$TargetServer = Read-Host "Enter server name (leave blank for local machine)"
if ([string]::IsNullOrWhiteSpace($TargetServer)) {
    $TargetServer = $env:COMPUTERNAME
}

Disable-SSLv3Server -ServerName $TargetServer

Write-Host "Script execution completed." -ForegroundColor Green
