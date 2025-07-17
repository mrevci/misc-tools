param (
    [Parameter(Mandatory = $true)]
    [string]$VideoUrl,

    [string]$OutputDir = "C:\yt-dlp",

    [string[]]$ExtraArgs  # Optional: for passing extra yt-dlp flags    
)

# Ensure yt-dlp is available, install if missing
if (-not (Get-Command yt-dlp -ErrorAction SilentlyContinue)) {
    Write-Host "yt-dlp not found. Attempting to install via winget..." -ForegroundColor Yellow
    try {
        winget install --id yt-dlp.yt-dlp -e --silent
        # Refresh environment path in current session
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


# Ensure base output directory exists
if (-not (Test-Path $OutputDir)) {
    New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null
}

# Change to base output directory
Push-Location $OutputDir

# Define output template: put everything into a subfolder named after the video
$OutputTemplate = "%(upload_date)s - %(title).200B [%(id)s]/%(upload_date)s - %(title).200B [%(id)s].%(ext)s"

# Run yt-dlp
yt-dlp `
    -f bestvideo+bestaudio `
    --merge-output-format mkv `
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

# Restore original location
Pop-Location
