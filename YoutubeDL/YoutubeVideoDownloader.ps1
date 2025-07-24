param (
    [Parameter(Mandatory = $true)]
    [string]$VideoUrl,

    [string]$OutputDir = "C:\output",

    [string[]]$ExtraArgs,  

    [string]$CustomName,   

    [ValidateSet("mkv", "mp4")]
    [string]$Format = "mkv" 
)

# Ensure yt-dlp is available, install if missing
if (-not (Get-Command yt-dlp -ErrorAction SilentlyContinue)) {
    Write-Host "yt-dlp not found. Attempting to install via winget..." -ForegroundColor Yellow
    try {
        winget install --id yt-dlp.yt-dlp -e --silent
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine) + ";" +
                    [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)
        if (-not (Get-Command yt-dlp -ErrorAction SilentlyContinue)) {
            Write-Error "yt-dlp installation via winget failed or PATH not updated. Please install manually."
            exit 1
        }
    } catch {
        Write-Error "yt-dlp installation via winget failed: $_"
        exit 1
    }
}

# Ensure output directory exists
if (-not (Test-Path $OutputDir)) {
    New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null
}

Push-Location $OutputDir

# Define output template
if ($CustomName) {
    $OutputTemplate = "$CustomName/$CustomName.%(ext)s"
} else {
    $OutputTemplate = "%(upload_date)s - %(title).200B [%(id)s]/%(upload_date)s - %(title).200B [%(id)s].%(ext)s"
}

# Run yt-dlp
yt-dlp `
    -f bestvideo+bestaudio `
    --merge-output-format $Format `
    --write-info-json `
    --write-description `
    --write-annotations `
    --write-thumbnail --embed-thumbnail `
    --write-subs --write-auto-subs --embed-subs --convert-subs srt `
    --embed-chapters `
    --add-metadata `
    --output $OutputTemplate `
    @ExtraArgs `
    $VideoUrl

Pop-Location
