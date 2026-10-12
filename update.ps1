# UYAP Dilekçe Hazırlayıcı - Windows Güncelleme Betiği
$ProgressPreference = 'SilentlyContinue'

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "⚖️  UYAP Dilekçe & Şablon Yöneticisi (Windows Güncelleme)" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

$TargetDir = Join-Path $env:USERPROFILE ".dilekce-hazirlayici"
$ZipUrl = "https://github.com/ssayoglu/uyap-dilekce-windows/archive/refs/heads/main.zip"

$DesktopPath = [System.Environment]::GetFolderPath("Desktop")
if (!$DesktopPath -or !(Test-Path -LiteralPath $DesktopPath)) {
    $DesktopPath = Join-Path $env:USERPROFILE "Desktop"
}
if (!(Test-Path -LiteralPath $DesktopPath)) {
    $DesktopPath = Join-Path $env:USERPROFILE "Masaüstü"
}

if (!(Test-Path -LiteralPath $TargetDir)) {
    Write-Host "⚠️  Uygulama henüz kurulu değil. Kurulum başlatılıyor..." -ForegroundColor Yellow
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-Expression (Invoke-RestMethod "https://raw.githubusercontent.com/ssayoglu/uyap-dilekce-windows/main/install.ps1")
    exit
}

# Port 5678'i tutan veya win_app.py / server.py çalıştıran eski süreçleri sonlandır
try {
    Get-NetTCPConnection -LocalPort 5678 -ErrorAction SilentlyContinue | ForEach-Object {
        Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue
    }
} catch {}

try {
    Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object {
        $_.Name -match "^python" -and ($_.CommandLine -like "*win_app.py*" -or $_.CommandLine -like "*server.py*")
    } | ForEach-Object {
        Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
    }
} catch {}

if (Test-Path -LiteralPath (Join-Path $TargetDir ".git")) {
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
    $TmpZip = Join-Path $TargetDir "dilekce_update.zip"
    $TmpExtract = Join-Path $TargetDir "dilekce_update_extracted"

    if (Test-Path -LiteralPath $TmpZip) {
        try { Remove-Item -LiteralPath $TmpZip -Force -ErrorAction SilentlyContinue } catch {}
    }
    if (Test-Path -LiteralPath $TmpExtract) {
        try { Remove-Item -LiteralPath $TmpExtract -Recurse -Force -ErrorAction SilentlyContinue } catch {}
    }

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $ZipUrl -OutFile $TmpZip -UseBasicParsing
    Expand-Archive -LiteralPath $TmpZip -DestinationPath $TmpExtract -Force

    $sourceDir = Join-Path $TmpExtract "uyap-dilekce-windows-main"
    if (Test-Path -LiteralPath $sourceDir) {
        Get-ChildItem -LiteralPath $sourceDir | ForEach-Object {
            Copy-Item -LiteralPath $_.FullName -Destination $TargetDir -Recurse -Force
        }
    }

    try { Remove-Item -LiteralPath $TmpZip -Force -ErrorAction SilentlyContinue } catch {}
    try { Remove-Item -LiteralPath $TmpExtract -Recurse -Force -ErrorAction SilentlyContinue } catch {}
}

# Masaüstü kısayolunu yenile
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut((Join-Path $DesktopPath "Dilekçe Hazırlayıcı.lnk"))

$pythonwCmd = Get-Command pythonw -ErrorAction SilentlyContinue | Select-Object -First 1
if ($pythonwCmd) {
    $Shortcut.TargetPath = $pythonwCmd.Source
} else {
    $pyNormal = Get-Command python -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($pyNormal) {
        $pywCandidate = Join-Path (Split-Path -Parent $pyNormal.Source) "pythonw.exe"
        if (Test-Path -LiteralPath $pywCandidate) {
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
$iconFile = Join-Path $TargetDir "AppIcon.ico"
if (Test-Path -LiteralPath $iconFile) {
    $Shortcut.IconLocation = "$iconFile,0"
}
$Shortcut.Save()

$verFile = Join-Path $TargetDir "version.json"
$newVer = "1.5.0"
if (Test-Path -LiteralPath $verFile) {
    try {
        $json = Get-Content -LiteralPath $verFile -Raw | ConvertFrom-Json
        $newVer = $json.version
    } catch {}
}

Write-Host "========================================================" -ForegroundColor Green
Write-Host "✅ Güncelleme başarıyla tamamlandı! (Sürüm: v$newVer)" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
Write-Host "🚀 Masaüstünüzdeki 'Dilekçe Hazırlayıcı' kısayolundan uygulamayı başlatabilirsiniz." -ForegroundColor Cyan
