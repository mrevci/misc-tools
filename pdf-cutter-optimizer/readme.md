
```markdown
# ExtractAndCompress-PDF.ps1

Extract specific pages from a PDF and compress the result using QPDF and Ghostscript.  
Great for trimming and preparing upload-friendly versions of PDF files, such as documentations (PDF) to use with AI, feeding it upto date fresh docs.

## Examples

```powershell
# Get pages 1-5 and 7, output to C:\output
.\ExtractAndCompress-PDF.ps1 -InputPDF "C:\docs\quickstart.pdf" -Pages "1-5,7"

# Get pages 10-20, save to custom location
.\ExtractAndCompress-PDF.ps1 -InputPDF "C:\docs\manual.pdf" -Pages "10-20" -OutputDir "D:\pdfs"
```

## Parameters

- **`-InputPDF`** (required)  
  Source PDF file path

- **`-Pages`** (required)  
  Page ranges to extract (e.g. "1-3,5,7")

- **`-OutputDir`** (optional)  
  Where to save results (default: C:\output)

## How It Works

1. Auto-installs QPDF if missing
2. Checks PATH for qpdf.exe and gswin64c.exe
3. Makes output dir if needed
4. Pulls specified pages using QPDF
5. Runs Ghostscript with /prepress compression
6. Cleans up temp files
7. Saves final <filename>.compressed.pdf

## Requirements

- Install Ghostscript first: [ghostscript.com/releases](https://www.ghostscript.com/releases/)
- Scanned PDFs won't become searchable - OCR them first if needed
```