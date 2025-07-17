param(
    [Parameter(Mandatory=$true)][string]$InputPDF,
    [Parameter(Mandatory=$true)][string]$Pages,          # e.g. "1-3,7"
    [string]$OutputDir = "C:\output"
)

# --- ensure QPDF ------------------------------------------------------------
if (-not (Get-Command qpdf -ErrorAction SilentlyContinue)) {
    winget install -e --id QPDF.QPDF -h --accept-source-agreements --accept-package-agreements
}
if (-not (Get-Command qpdf -ErrorAction SilentlyContinue)) {
    $q = Get-ChildItem "C:\Program Files\qpdf*" -Recurse -Filter qpdf.exe -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($q) { $env:Path += ";$($q.Directory.FullName)" }
}

# --- ensure Ghostscript -----------------------------------------------------
if (-not (Get-Command gswin64c.exe -ErrorAction SilentlyContinue)) {
    $g = Get-ChildItem "C:\Program Files\gs" -Recurse -Filter gswin64c.exe -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($g) { $env:Path += ";$($g.Directory.FullName)" }
    else    { throw "Ghostscript not found. Install from https://www.ghostscript.com/releases/ (64-bit) and re-run." }
}

# --- paths ------------------------------------------------------------------
if (!(Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir | Out-Null }
$base      = [IO.Path]::GetFileNameWithoutExtension($InputPDF)
$tempPdf   = Join-Path $OutputDir "$base.tmp.pdf"
$finalPdf  = Join-Path $OutputDir "$base.compressed.pdf"

# --- processing -------------------------------------------------------------
qpdf "$InputPDF" --pages . $Pages -- "$tempPdf"
gswin64c.exe -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -o "$finalPdf" "$tempPdf"
Remove-Item "$tempPdf"

"Done → $finalPdf"
