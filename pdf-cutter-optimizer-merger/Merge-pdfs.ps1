param (
    [string]$QpdfPath = "C:\Program Files\qpdf 12.2.0\bin\qpdf.exe",
    [string]$SourceFolder = "C:\PDFs",
    [string]$OutputFileName = "merged.pdf"
)

# Check if qpdf exists at specified path
if (-not (Test-Path -Path $QpdfPath)) {
    Write-Error "qpdf executable not found at path: $QpdfPath"
    exit 1
}

# Check if source folder exists
if (-not (Test-Path -Path $SourceFolder)) {
    Write-Error "Source folder not found: $SourceFolder"
    exit 1
}

# Get all PDF files in the source folder
$pdfFiles = Get-ChildItem -Path $SourceFolder -Filter *.pdf | Sort-Object Name

if ($pdfFiles.Count -eq 0) {
    Write-Error "No PDF files found in: $SourceFolder"
    exit 1
}

# Build input arguments for qpdf
$inputArgs = $pdfFiles | ForEach-Object { $_.FullName }
$outputFilePath = Join-Path -Path $SourceFolder -ChildPath $OutputFileName
$qpdfArgs = @("--empty", "--pages") + $inputArgs + @("--", $outputFilePath)

# Execute qpdf
& $QpdfPath $qpdfArgs

Write-Host "PDF successfully merged and saved to: $outputFilePath"