.\YoutubeVideoDownloader.ps1
run this script in powershell, provide mandatory parameter -VideoUrl. The download video and files is outputted by default to C:\yt-dlp. Can be changed using -OutputDir or changing the default in the script itself.
Creds: https://github.com/yt-dlp

example usage:

 .\YoutubeVideoDownloader.ps1 -VideoUrl https://www.youtube.com/watch?v=MkVCbhcrU60 -ExtraArgs @("--cookies", "C:\Users\Smiley\Downloads\cookies.txt", "--age-limit", "18")
