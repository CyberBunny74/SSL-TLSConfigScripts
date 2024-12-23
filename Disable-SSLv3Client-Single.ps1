# This script will disable SSL 3.0 for all client
# software installed on a system.
########################################################### 
#Requires -RunAsAdministrator

#---------------------------------------------------------- 
#VARIABLES
#---------------------------------------------------------- 
$RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\"
$RegName = "Client"
$RegItem = "Enable"
$RegValue = "0"
$RegType = "DWord"

#---------------------------------------------------------- 
#CHECK IF KEY EXISTS
#----------------------------------------------------------
function KeyCheck {
    $RegTest = Test-Path "$RegPath\$RegName"
    if ($RegTest -eq $true) {
        Write-Host "Registry key already exists." -ForegroundColor Yellow
    } else { 
        try {
            New-Item -Path $RegPath -ItemType Directory -Name $RegName -Force -ErrorAction Stop | Out-Null
            Write-Host "Registry key created successfully." -ForegroundColor Green
        } catch {
            Write-Host "Failed to create registry key: $_" -ForegroundColor Red
        }
    }
}

#---------------------------------------------------------- 
#SET THE DWORD VALUE
#----------------------------------------------------------
function SetRegValue {
    try {
        Set-ItemProperty -Path "$RegPath\$RegName" -Name $RegItem -Value $RegValue -Type $RegType -ErrorAction Stop
        Write-Host "Registry value set successfully." -ForegroundColor Green
    } catch {
        Write-Host "Failed to set registry value: $_" -ForegroundColor Red
        # Optionally, log the error to a file
        # $_ | Out-File -Append -FilePath "C:\Logs\SSLv3Disable.log"
    }
}

#---------------------------------------------------------- 
#START
#----------------------------------------------------------
Clear-Host
Write-Host "Running Disable-SSLv3Client.ps1 - v1.1" -ForegroundColor Green
Write-Host "This script will disable SSL 3.0 for all client software installed on a system." -ForegroundColor DarkGreen
Write-Host "Author: Branko Vucinec - 2015-07-15 (Updated 2024-12-22)" -ForegroundColor DarkGreen
Write-Host "Checking registry key..."
KeyCheck
Write-Host "Setting registry value..."
SetRegValue
Write-Host "Script execution completed." -ForegroundColor Green
