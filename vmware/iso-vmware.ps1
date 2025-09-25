#
# Create ISO with your text file (self-contained, no downloads needed)
#

# All Credits to awakecoding https://gist.github.com/awakecoding/c197d176e32be7b5964129e981d104d6

function New-IsoFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string] $Path,
        [Parameter(Mandatory=$true,Position=1)]
        [string] $Destination,
        [Parameter(Mandatory=$true)]
        [string] $VolumeName,
        [switch] $IncludeRoot,
        [switch] $Force
    )

    $fsi = New-Object -ComObject IMAPI2FS.MsftFileSystemImage
    $fsi.FileSystemsToCreate = 4 # UDF
    $fsi.FreeMediaBlocks = 0
    $fsi.VolumeName = $VolumeName
    $fsi.Root.AddTree($Path, $IncludeRoot)
    $istream = $fsi.CreateResultImage().ImageStream

    $Options = if ($PSEdition -eq 'Core') {
        @{ CompilerOptions = "/unsafe" }
    } else {
        $cp = New-Object CodeDom.Compiler.CompilerParameters
        $cp.CompilerOptions = "/unsafe"
        $cp.WarningLevel = 4
        $cp.TreatWarningsAsErrors = $true
        @{ CompilerParameters = $cp }
    }

    Add-Type @Options -TypeDefinition @"
using System;
using System.IO;
using System.Runtime.InteropServices.ComTypes;
namespace IsoHelper {
    public static class FileUtil {
        public static void WriteIStreamToFile(object i, string fileName) {
            IStream inputStream = i as IStream;
            FileStream outputFileStream = File.OpenWrite(fileName);
            int bytesRead = 0;
            int offset = 0;
            byte[] data;
            do {
                data = Read(inputStream, 2048, out bytesRead);
                outputFileStream.Write(data, 0, bytesRead);
                offset += bytesRead;
            } while (bytesRead == 2048);
            outputFileStream.Flush();
            outputFileStream.Close();
        }
        unsafe static private byte[] Read(IStream stream, int toRead, out int read) {
            byte[] buffer = new byte[toRead];
            int bytesRead = 0;
            int* ptr = &bytesRead;
            stream.Read(buffer, toRead, (IntPtr)ptr);
            read = bytesRead;
            return buffer;
        }
    }
}
"@

    [IsoHelper.FileUtil]::WriteIStreamToFile($istream, $Destination)
}


# The file you want to convert
$FileToConvert = "C:\Users\Smiley\Downloads\New Tekstdokument.txt"

# Timestamped ISO filename
$Timestamp = (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss")

# Ensure folders exist
New-Item -ItemType Directory -Path C:\iso -Force | Out-Null
New-Item -ItemType Directory -Path C:\temp -Force | Out-Null

# Put your text into the staging folder
Copy-Item $FileToConvert C:\iso\ -Force

# Build the ISO
New-IsoFile -Path $FileToConvert -Destination "C:\iso\$Timestamp.iso" -VolumeName "NOTES"
#New-IsoFile -Path "C:\iso" -Destination "C:\iso\$Timestamp.iso" -VolumeName "NOTES"
Write-Host "ISO created: C:\temp\$Timestamp.iso"
