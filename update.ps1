# UYAP Dilekçe Hazırlayıcı - Windows Güncelleme Betiği
$ErrorActionPreference = "Stop"

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "⚖️  UYAP Dilekçe & Şablon Yöneticisi (Windows Güncelleme)" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

$TargetDir = "$env:USERPROFILE\.dilekce-hazirlayici"
$DesktopPath = [System.Environment]::GetFolderPath("Desktop")
$ZipUrl = "https://github.com/ssayoglu/uyap-dilekce-windows/archive/refs/heads/main.zip"

if (!(Test-Path $TargetDir)) {
    Write-Host "⚠️  Uygulama henüz kurulu değil. Kurulum başlatılıyor..." -ForegroundColor Yellow
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-Expression (Invoke-RestMethod "https://raw.githubusercontent.com/ssayoglu/uyap-dilekce-windows/main/install.ps1")
    exit
}

# Çalışan eski Python sunucu süreçlerini sonlandır (dosya kilitlerini kaldırmak için)
Get-Process python, pythonw -ErrorAction SilentlyContinue | Where-Object {
    try {
        $_.CommandLine -like "*win_app.py*" -or $_.CommandLine -like "*server.py*"
    } catch { $false }
} | Stop-Process -Force -ErrorAction SilentlyContinue

if (Test-Path "$TargetDir\.git") {
    Write-Host "🔄 Git deposundan güncellemeler alınıyor..." -ForegroundColor Yellow
    Push-Location $TargetDir
    try {
        git pull --quiet
    } catch {
        Write-Host "Git güncellemesi tamamlanamadı, ZIP üzerinden güncelleniyor..." -ForegroundColor DarkYellow
    }
    Pop-Location
} else {
    Write-Host "📥 Son sürüm dosyaları indiriliyor..." -ForegroundColor Yellow
    $TmpZip = "$env:TEMP\dilekce_win_update.zip"
    $TmpExtract = "$env:TEMP\dilekce_win_update_extracted"

    if (Test-Path $TmpZip) { Remove-Item -Force $TmpZip }
    if (Test-Path $TmpExtract) { Remove-Item -Recurse -Force $TmpExtract }

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $ZipUrl -OutFile $TmpZip -UseBasicParsing
    Expand-Archive -Path $TmpZip -DestinationPath $TmpExtract -Force
    Copy-Item -Path "$TmpExtract\uyap-dilekce-windows-main\*" -Destination $TargetDir -Recurse -Force

    Remove-Item -Force $TmpZip -ErrorAction SilentlyContinue
    Remove-Item -Recurse -Force $TmpExtract -ErrorAction SilentlyContinue
}

# Masaüstü kısayolunu yenile
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$DesktopPath\Dilekçe Hazırlayıcı.lnk")

$pythonwCmd = Get-Command pythonw -ErrorAction SilentlyContinue | Select-Object -First 1
if ($pythonwCmd) {
    $Shortcut.TargetPath = $pythonwCmd.Source
} else {
    $pyNormal = Get-Command python -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($pyNormal) {
        $pywCandidate = (Split-Path -Parent $pyNormal.Source) + "\pythonw.exe"
        if (Test-Path $pywCandidate) {
            $Shortcut.TargetPath = $pywCandidate
        } else {
            $Shortcut.TargetPath = $pyNormal.Source
        }
    } else {
        $Shortcut.TargetPath = "pythonw.exe"
    }
}

$Shortcut.Arguments = """$TargetDir\win_app.py"""
$Shortcut.WorkingDirectory = "$TargetDir"
$Shortcut.Description = "UYAP Dilekçe & Şablon Yöneticisi"
if (Test-Path "$TargetDir\AppIcon.ico") {
    $Shortcut.IconLocation = "$TargetDir\AppIcon.ico,0"
}
$Shortcut.Save()

$verFile = "$TargetDir\version.json"
$newVer = "1.5.0"
if (Test-Path $verFile) {
    try {
        $json = Get-Content $verFile -Raw | ConvertFrom-Json
        $newVer = $json.version
    } catch {}
}

Write-Host "========================================================" -ForegroundColor Green
Write-Host "✅ Güncelleme başarıyla tamamlandı! (Sürüm: v$newVer)" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
Write-Host "🚀 Masaüstünüzdeki 'Dilekçe Hazırlayıcı' kısayolundan uygulamayı başlatabilirsiniz." -ForegroundColor Cyan
