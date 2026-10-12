# UYAP Dilekçe Hazırlayıcı - Windows Kurulum Betiği (Sıfır Bağımlılık, Otomatik Python 3 Kurulumu)
$ProgressPreference = 'SilentlyContinue'

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "⚖️  UYAP Dilekçe & Şablon Yöneticisi (Windows Kurulum)" -ForegroundColor Cyan
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

# Hedef klasörü önceden oluştur
if (!(Test-Path -LiteralPath $TargetDir)) {
    New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
}

# 1. Python 3 Kontrolü ve Gerekirse Otomatik Kurulum
function Ensure-Python {
    Write-Host "🔍 Python 3 kontrol ediliyor..." -ForegroundColor Yellow

    # PATH'te mevcut mu?
    $pyCmd = Get-Command python, py, python3 -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($pyCmd) {
        try {
            $verOutput = & $pyCmd.Source --version 2>&1
            if ($verOutput -match "Python 3") {
                Write-Host "✅ $verOutput tespit edildi." -ForegroundColor Green
                return $pyCmd.Source
            }
        } catch {}
    }

    # Bilinen standart konumlarda var mı? (PATH'e eklenmemiş olabilir)
    $candidatePaths = @(
        "$env:LOCALAPPDATA\Programs\Python\Python312\python.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python311\python.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python310\python.exe",
        "$env:ProgramFiles\Python312\python.exe",
        "$env:ProgramFiles\Python311\python.exe",
        "$env:ProgramFiles\Python310\python.exe"
    )
    foreach ($candidate in $candidatePaths) {
        if (Test-Path -LiteralPath $candidate) {
            Write-Host "✅ Python bulundu: $candidate" -ForegroundColor Green
            $pyDir = Split-Path -Parent $candidate
            $env:Path = "$pyDir;$pyDir\Scripts;$env:Path"
            return $candidate
        }
    }

    Write-Host "⚠️  Python 3 bulunamadı. Otomatik olarak kuruluyor..." -ForegroundColor Yellow

    # A) Winget ile sessiz kurulum dene (Windows 10 / 11)
    $hasWinget = Get-Command winget -ErrorAction SilentlyContinue
    if ($hasWinget) {
        Write-Host "📦 Winget paketi ile Python 3 kuruluyor..." -ForegroundColor Yellow
        try {
            $proc = Start-Process winget -ArgumentList "install --id Python.Python.3.12 --silent --accept-package-agreements --accept-source-agreements" -NoNewWindow -Wait -PassThru
            if ($proc.ExitCode -eq 0) {
                Write-Host "✅ Python 3 Winget ile kuruldu." -ForegroundColor Green
            }
        } catch {
            Write-Host "Winget kurulumu denenemedi, doğrudan indiriciye geçiliyor..." -ForegroundColor DarkYellow
        }
    }

    # B) Winget yoksa veya kurulamadıysa: python.org resmi yükleyicisini indir ve kur
    $pyCheck = Get-Command python, py -ErrorAction SilentlyContinue | Select-Object -First 1
    if (!$pyCheck) {
        Write-Host "📥 Python.org üzerinden resmi yükleyici indiriliyor (Python 3.12 64-bit)..." -ForegroundColor Yellow
        $installerUrl = "https://www.python.org/ftp/python/3.12.7/python-3.12.7-amd64.exe"
        $installerPath = Join-Path $TargetDir "python_installer.exe"
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing
            Write-Host "⚙️  Python arka planda sessizce kuruluyor (PATH otomatik yapılandırılıyor)..." -ForegroundColor Yellow
            $installProc = Start-Process -FilePath $installerPath -ArgumentList "/quiet InstallAllUsers=0 PrependPath=1 Include_test=0 Include_pip=1" -Wait -PassThru
            try { Remove-Item -LiteralPath $installerPath -Force -ErrorAction SilentlyContinue } catch {}
            Write-Host "✅ Python 3 başarıyla kuruldu." -ForegroundColor Green
        } catch {
            Write-Host "❌ Otomatik Python kurulum hatası: $_" -ForegroundColor Red
        }
    }

    # Ortam değişkenlerini yenile
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

Ensure-Python

# Çalışan eski süreçleri ve port 5678'i temizle
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

# 2. Dosyaları İndir ve Çıkart
Write-Host "📥 Uygulama dosyaları indiriliyor..." -ForegroundColor Yellow
$TmpZip = Join-Path $TargetDir "dilekce_win.zip"
$TmpExtract = Join-Path $TargetDir "dilekce_extracted"

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

# 3. Masaüstüne Logolu Kısayol Oluştur (.lnk)
Write-Host "📁 Masaüstü kısayolu oluşturuluyor..." -ForegroundColor Yellow
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

Write-Host "========================================================" -ForegroundColor Green
Write-Host "✅ Kurulum başarıyla tamamlandı!" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
Write-Host "🚀 Masaüstünüzdeki 'Dilekçe Hazırlayıcı' kısayoluna tıklayarak açabilirsiniz." -ForegroundColor Cyan
