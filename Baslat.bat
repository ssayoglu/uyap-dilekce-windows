@echo off
chcp 65001 >nul
title UYAP Dilekce ve Sablon Yoneticisi
echo ========================================================
echo ⚖️  UYAP Dilekce ve Sablon Yoneticisi (Windows)
echo ========================================================
echo.

where python >nul 2>&1
if %errorlevel% neq 0 (
    echo [BILGI] Python 3 sistemde tespit edilemedi.
    echo Otomatik kurulum ve sistem hazirligi baslatiliyor...
    echo.
    powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/ssayoglu/uyap-dilekce-windows/main/install.ps1 | iex"
    exit /b 0
)

start "" python win_app.py
exit
