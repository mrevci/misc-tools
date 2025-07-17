<#
quick-fd.ps1 – thin wrapper around fd

Usage
  .\quick-fd.ps1 <pattern> [-Opts "<fd opts>"] [-Drives C:\,D:\] [-OutCsv] [-Metadata] [-IncludeSystem]

Examples
  .\quick-fd.ps1 bf1.exe
  .\quick-fd.ps1 "*.ps1" -OutCsv
  .\quick-fd.ps1 log -Metadata -OutCsv
  .\quick-fd.ps1 bf1.exe -IncludeSystem
  .\quick-fd.ps1 "*.dll" -Drives 'D:\','E:\'
#>

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Pattern,

    [string]$Opts = "-i -H -I -L",
    [string[]]$Drives,
    [switch]$OutCsv,
    [switch]$Metadata,
    [switch]$IncludeSystem
)

function To-HumanSize ($bytes) {
    if ($bytes -ge 1GB) { "{0:N2} GB" -f ($bytes / 1GB) }
    elseif ($bytes -ge 1MB) { "{0:N2} MB" -f ($bytes / 1MB) }
    elseif ($bytes -ge 1KB) { "{0:N0} KB" -f ($bytes / 1KB) }
    else { "$bytes B" }
}

function Is-SystemLike($path) {
    $systemRoots = @(
        "$env:SystemRoot",
        "${env:ProgramFiles}",
        "${env:ProgramFiles(x86)}",
        "${env:ProgramData}",
        "$env:SystemDrive\Recovery",
        "$env:SystemDrive\System Volume Information",
        "$env:SystemDrive\$Recycle.Bin"
    ) | ForEach-Object { ($_ -replace '\\+$', '').ToLower() }
    $p = ($path -replace '\\+$', '').ToLower()
    foreach ($root in $systemRoots) {
        if ($p -like "$root*") { return $true }
    }
    try {
        $attr = (Get-Item $path -Force).Attributes
        if ($attr -band [IO.FileAttributes]::System) { return $true }
    } catch {}
    return $false
}

if (-not (Get-Command fd -ErrorAction SilentlyContinue)) {
    winget install --id sharkdp.fd -e -h --accept-package-agreements --accept-source-agreements
    $env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                [Environment]::GetEnvironmentVariable("Path","User")
}

if (-not $Drives) {
    $Drives = (Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match '^[A-Z]:\\$' }).Root
}

$optsArray = $Opts -split '\s+'
$results = @()

foreach ($d in $Drives) {
    $fdOut = & fd @optsArray $Pattern $d 2>$null
    foreach ($p in $fdOut) {
        try {
            if (-not $IncludeSystem -and (Is-SystemLike $p)) { continue }
            $item = Get-Item $p -Force
            $results += $item
            $item.FullName
        } catch {}
    }
}

if ($OutCsv -and $results.Count) {
    $safePattern = ($Pattern -replace '[^a-zA-Z0-9_\-]', '_') -replace '^_+|_+$'
    $timestamp   = Get-Date -Format 'yyyyMMdd_HHmmss'
    $outDir      = 'C:\scriptoutput'
    if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }
    $csvPath = Join-Path $outDir "$safePattern`_$timestamp.csv"

    if ($Metadata) {
        $results | Sort-Object FullName | ForEach-Object {
            [pscustomobject]@{
                Path         = $_.FullName
                Size         = To-HumanSize $_.Length
                LastWriteUtc = $_.LastWriteTimeUtc
                Attributes   = $_.Attributes
            }
        } | Export-Csv $csvPath -NoTypeInformation -Encoding UTF8
    } else {
        $results | Sort-Object FullName | ForEach-Object {
            [pscustomobject]@{ Path = $_.FullName }
        } | Export-Csv $csvPath -NoTypeInformation -Encoding UTF8
    }
}
