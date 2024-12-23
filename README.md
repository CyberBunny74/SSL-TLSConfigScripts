# SSL/TLS Security Configuration Scripts

This repository contains PowerShell scripts designed to enhance SSL/TLS security on Windows systems. These scripts disable outdated protocols and configure secure settings for optimal protection.

## Scripts

### 1. DisableAllButTLS12.ps1

This script disables all SSL and TLS versions except TLS 1.2, configuring the system for enhanced security.

Key features:
- Disables older SSL/TLS protocols
- Enables and configures TLS 1.2
- Adjusts cipher suites and security settings

### 2. Disable-SSLv3Client-Multi.ps1

This script disables SSL 3.0 for client-side communications on multiple systems.

Key features:
- Disables SSL 3.0 for client software across multiple machines
- Supports batch processing of multiple systems

### 3. Disable-SSLv3Client-Single.ps1

This script focuses on disabling SSL 3.0 for client-side communications on a single system.

Key features:
- Disables SSL 3.0 for client software
- Designed for use on individual machines

### 4. Disable-SSLv3Server-Multi.ps1

This script disables SSL 3.0 for server-side communications across multiple systems.

Key features:
- Disables SSL 3.0 for server software, including IIS
- Supports batch processing of multiple servers

### 5. Disable-SSLv3Server-Single.ps1

This script disables SSL 3.0 for server-side communications on a single system..

Key features:
- Disables SSL 3.0 for server software, including IIS
- Supports batch processing of multiple servers

## Usage

1. Ensure you have administrative privileges on the target system(s).
2. Download the desired script to your local machine.
3. Open PowerShell as an administrator.
4. Navigate to the directory containing the script.
5. Execute the script
6. Follow any on-screen prompts or instructions.
7. Restart the affected system(s) to apply all changes.

## Important Notes

- These scripts make significant changes to system security settings. Test thoroughly in a non-production environment before applying to production systems.
- After applying these changes, some older applications or systems may experience connectivity issues if they don't support the configured protocols.
- Regular security audits and updates are recommended to maintain a strong security posture.

## Compatibility

These scripts are designed for Windows systems. They may include checks and configurations for different Windows versions, including various Server editions and Windows 10.

## Disclaimer

Use these scripts at your own risk. Always backup your system and test in a controlled environment before applying changes to production systems.

