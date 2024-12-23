# This script will disable SSL 3.0 for all server 
# software installed on multiple systems, including IIS.
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

# Path to a text file containing server names, one per line
$ServerListPath = "C:\scripts\Data\servers.txt"

#---------------------------------------------------------- 
#CHECK IF KEY EXISTS
#----------------------------------------------------------
function KeyCheck {
    param($ServerName)
    $RegTest = Invoke-Command -ComputerName $ServerName -ScriptBlock {
        Test-Path "$using:RegPath\$using:RegName"
    }
    if ($RegTest -eq $true) {
        Write-Host "[$ServerName] Registry key already exists." -ForegroundColor Yellow
    } else { 
        try {
            Invoke-Command -ComputerName $ServerName -ScriptBlock {
                New-Item -Path $using:RegPath -ItemType Directory -Name $using:RegName -Force -ErrorAction Stop | Out-Null
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
        Invoke-Command -ComputerName $ServerName -ScriptBlock {
            Set-ItemProperty -Path "$using:RegPath\$using:RegName" -Name $using:RegItem -Value $using:RegValue -Type $using:RegType -ErrorAction Stop
        }
        Write-Host "[$ServerName] Registry value set successfully." -ForegroundColor Green
    } catch {
        Write-Host "[$ServerName] Failed to set registry value: $_" -ForegroundColor Red
        # Optionally, log the error to a file
        # "$ServerName : $_" | Out-File -Append -FilePath "C:\Logs\SSLv3DisableServer.log"
    }
}

#---------------------------------------------------------- 
#MAIN FUNCTION
#----------------------------------------------------------
function Disable-SSLv3Server {
    param($ServerName)
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
Write-Host "Running Disable-SSLv3Server.ps1 - v1.1" -ForegroundColor Green
Write-Host "This script will disable SSL 3.0 for all server software installed on specified systems, including IIS." -ForegroundColor DarkGreen
Write-Host "Author: Branko Vucinec - 2015-07-15 (Updated 2024-12-22)" -ForegroundColor DarkGreen

# Check if server list file exists
if (-not (Test-Path $ServerListPath)) {
    Write-Host "Server list file not found at $ServerListPath" -ForegroundColor Red
    exit
}

# Read server names from file
$Servers = Get-Content $ServerListPath

# Process each server
foreach ($Server in $Servers) {
    Disable-SSLv3Server -ServerName $Server
}

Write-Host "Script execution completed for all servers." -ForegroundColor Green
