#outputs installed apps to a csv file on your desktop

$allApps = Get-ItemProperty @(
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
) | Where-Object { $_.DisplayName }

$allApps | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Sort-Object DisplayName | Export-Csv -Path "$env:USERPROFILE\Desktop\InstalledApps.csv" -NoTypeInformation -Encoding UTF8
