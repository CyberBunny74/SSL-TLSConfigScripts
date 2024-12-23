# This script will disable SSL 3.0 for all client
# software installed on multiple systems.
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

# Path to a text file containing computer names, one per line
$ComputerListPath = "C:\scripts\Data\computers.txt"

#---------------------------------------------------------- 
#CHECK IF KEY EXISTS
#----------------------------------------------------------
function KeyCheck {
    param($ComputerName)
    $RegTest = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
        Test-Path "$using:RegPath\$using:RegName"
    }
    if ($RegTest -eq $true) {
        Write-Host "[$ComputerName] Registry key already exists." -ForegroundColor Yellow
    } else { 
        try {
            Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                New-Item -Path $using:RegPath -ItemType Directory -Name $using:RegName -Force -ErrorAction Stop | Out-Null
            }
            Write-Host "[$ComputerName] Registry key created successfully." -ForegroundColor Green
        } catch {
            Write-Host "[$ComputerName] Failed to create registry key: $_" -ForegroundColor Red
        }
    }
}

#---------------------------------------------------------- 
#SET THE DWORD VALUE
#----------------------------------------------------------
function SetRegValue {
    param($ComputerName)
    try {
        Invoke-Command -ComputerName $ComputerName -ScriptBlock {
            Set-ItemProperty -Path "$using:RegPath\$using:RegName" -Name $using:RegItem -Value $using:RegValue -Type $using:RegType -ErrorAction Stop
        }
        Write-Host "[$ComputerName] Registry value set successfully." -ForegroundColor Green
    } catch {
        Write-Host "[$ComputerName] Failed to set registry value: $_" -ForegroundColor Red
        # Optionally, log the error to a file
        # "$ComputerName : $_" | Out-File -Append -FilePath "C:\Logs\SSLv3Disable.log"
    }
}

#---------------------------------------------------------- 
#MAIN FUNCTION
#----------------------------------------------------------
function Disable-SSLv3Client {
    param($ComputerName)
    Write-Host "Processing $ComputerName..." -ForegroundColor Cyan
    Write-Host "[$ComputerName] Checking registry key..."
    KeyCheck -ComputerName $ComputerName
    Write-Host "[$ComputerName] Setting registry value..."
    SetRegValue -ComputerName $ComputerName
    Write-Host "[$ComputerName] Processing completed." -ForegroundColor Green
}

#---------------------------------------------------------- 
#START
#----------------------------------------------------------
Clear-Host
Write-Host "Running Disable-SSLv3Client.ps1 - v1.2" -ForegroundColor Green
Write-Host "This script will disable SSL 3.0 for all client software installed on specified systems." -ForegroundColor DarkGreen
Write-Host "Author: Branko Vucinec - 2015-07-15 (Updated 2024-12-22)" -ForegroundColor DarkGreen

# Check if computer list file exists
if (-not (Test-Path $ComputerListPath)) {
    Write-Host "Computer list file not found at $ComputerListPath" -ForegroundColor Red
    exit
}

# Read computer names from file
$Computers = Get-Content $ComputerListPath

# Process each computer
foreach ($Computer in $Computers) {
    Disable-SSLv3Client -ComputerName $Computer
}

Write-Host "Script execution completed for all computers." -ForegroundColor Green
