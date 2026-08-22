# UYAP Dilekçe Hazırlayıcı - Windows Kurulum Betiği
$ErrorActionPreference = "Stop"

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "⚖️  UYAP Dilekçe & Şablon Yöneticisi (Windows Kurulum)" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

$TargetDir = "$env:USERPROFILE\.dilekce-hazirlayici"
$ZipUrl = "https://github.com/ssayoglu/uyap-dilekce-windows/archive/refs/heads/main.zip"
$DesktopPath = [System.Environment]::GetFolderPath("Desktop")

# 1. Klasörü hazırla
if (!(Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
}

# 2. Dosyaları İndir
Write-Host "📥 Dosyalar indiriliyor..." -ForegroundColor Yellow
$TmpZip = "$env:TEMP\dilekce_win.zip"
$TmpExtract = "$env:TEMP\dilekce_win_extracted"

if (Test-Path $TmpZip) { Remove-Item -Force $TmpZip }
if (Test-Path $TmpExtract) { Remove-Item -Recurse -Force $TmpExtract }

Invoke-WebRequest -Uri $ZipUrl -OutFile $TmpZip
Expand-Archive -Path $TmpZip -DestinationPath $TmpExtract -Force
Copy-Item -Path "$TmpExtract\uyap-dilekce-windows-main\*" -Destination $TargetDir -Recurse -Force

Remove-Item -Force $TmpZip -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force $TmpExtract -ErrorAction SilentlyContinue

# 3. Masaüstüne Kısayol Oluştur (.lnk)
Write-Host "📁 Masaüstü kısayolu oluşturuluyor..." -ForegroundColor Yellow
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$DesktopPath\Dilekçe Hazırlayıcı.lnk")
$Shortcut.TargetPath = "pythonw.exe"
$Shortcut.Arguments = """$TargetDir\win_app.py"""
$Shortcut.WorkingDirectory = "$TargetDir"
$Shortcut.Description = "UYAP Dilekçe & Şablon Yöneticisi"
$Shortcut.Save()

Write-Host "========================================================" -ForegroundColor Green
Write-Host "✅ Kurulum başarıyla tamamlandı!" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
Write-Host "🚀 Masaüstünüzdeki 'Dilekçe Hazırlayıcı' kısayoluna tıklayarak açabilirsiniz." -ForegroundColor Cyan
