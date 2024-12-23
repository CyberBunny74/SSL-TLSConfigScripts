# This script disables all versions of SSL and TLS except TLS 1.2
# Requires administrator privileges

# Function to disable a protocol
function Disable-Protocol {
    param (
        [string]$Protocol
    )
    $paths = @(
        "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$Protocol\Server",
        "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$Protocol\Client"
    )
    foreach ($path in $paths) {
        New-Item -Path $path -Force | Out-Null
        New-ItemProperty -Path $path -Name "Enabled" -Value 0 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $path -Name "DisabledByDefault" -Value 1 -PropertyType DWORD -Force | Out-Null
    }
    Write-Host "$Protocol has been disabled."
}

# Function to enable TLS 1.2
function Enable-TLS12 {
    $paths = @(
        "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server",
        "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client"
    )
    foreach ($path in $paths) {
        New-Item -Path $path -Force | Out-Null
        New-ItemProperty -Path $path -Name "Enabled" -Value 0xffffffff -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $path -Name "DisabledByDefault" -Value 0 -PropertyType DWORD -Force | Out-Null
    }
    Write-Host "TLS 1.2 has been enabled."
}

# Function to configure ciphers
function Configure-Ciphers {
    New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers' -Force | Out-Null
    $insecureCiphers = @(
        'DES 56/56', 'NULL', 'RC2 128/128', 'RC2 40/128', 'RC2 56/128',
        'RC4 40/128', 'RC4 56/128', 'RC4 64/128', 'RC4 128/128', 'Triple DES 168'
    )
    foreach ($cipher in $insecureCiphers) {
        New-Item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\$cipher" -Force | Out-Null
        New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\$cipher" -Name "Enabled" -Value 0 -PropertyType DWORD -Force | Out-Null
        Write-Host "Weak cipher $cipher has been disabled."
    }
    $secureCiphers = @('AES 128/128', 'AES 256/256')
    foreach ($cipher in $secureCiphers) {
        New-Item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\$cipher" -Force | Out-Null
        New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\$cipher" -Name "Enabled" -Value 0xffffffff -PropertyType DWORD -Force | Out-Null
        Write-Host "Strong cipher $cipher has been enabled."
    }
}

# Function to configure hashes
function Configure-Hashes {
    New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes' -Force | Out-Null
    New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes\MD5' -Name "Enabled" -Value 0 -PropertyType DWORD -Force | Out-Null
    $secureHashes = @('SHA', 'SHA256', 'SHA384', 'SHA512')
    foreach ($hash in $secureHashes) {
        New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes\$hash" -Name "Enabled" -Value 0xffffffff -PropertyType DWORD -Force | Out-Null
        Write-Host "Hash $hash has been enabled."
    }
}

# Function to configure key exchange algorithms
function Configure-KeyExchangeAlgorithms {
    New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms' -Force | Out-Null
    $algorithms = @('Diffie-Hellman', 'ECDH', 'PKCS')
    foreach ($alg in $algorithms) {
        New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\$alg" -Name "Enabled" -Value 0xffffffff -PropertyType DWORD -Force | Out-Null
        Write-Host "KeyExchangeAlgorithm $alg has been enabled."
    }
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\Diffie-Hellman" -Name "ServerMinKeyBitLength" -Value 2048 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\Diffie-Hellman" -Name "ClientMinKeyBitLength" -Value 2048 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\PKCS" -Name "ClientMinKeyBitLength" -Value 2048 -PropertyType DWORD -Force | Out-Null
}

# Function to configure .NET Framework
function Configure-DotNetFramework {
    $versions = @('v2.0.50727', 'v4.0.30319')
    foreach ($version in $versions) {
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\$version" -Name "SystemDefaultTlsVersions" -Value 1 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\$version" -Name "SchUseStrongCrypto" -Value 1 -PropertyType DWORD -Force | Out-Null
        if (Test-Path 'HKLM:\SOFTWARE\Wow6432Node') {
            New-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\$version" -Name "SystemDefaultTlsVersions" -Value 1 -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\$version" -Name "SchUseStrongCrypto" -Value 1 -PropertyType DWORD -Force | Out-Null
        }
    }
    Write-Host ".NET Framework has been configured to use TLS 1.2."
}

# Main execution
Write-Host "Configuring SSL/TLS settings..."

$protocolsToDisable = @("Multi-Protocol Unified Hello", "PCT 1.0", "SSL 2.0", "SSL 3.0", "TLS 1.0", "TLS 1.1")
foreach ($protocol in $protocolsToDisable) {
    Disable-Protocol -Protocol $protocol
}

Enable-TLS12
Configure-Ciphers
Configure-Hashes
Configure-KeyExchangeAlgorithms
Configure-DotNetFramework

Write-Host "SSL/TLS configuration completed. Only TLS 1.2 is now enabled."
Write-Host "Please restart the computer for changes to take effect."
