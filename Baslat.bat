@echo off
chcp 65001 >nul
title UYAP Dilekce ve Sablon Yoneticisi
echo ========================================================
echo ⚖️  UYAP Dilekce ve Sablon Yoneticisi (Windows)
echo ========================================================
echo.

where python >nul 2>&1
if %errorlevel% neq 0 (
    echo [HATA] Python 3 bulunamadi!
    echo Lutfen https://www.python.org adresinden Python 3 indirip kurunuz.
    echo (Kurulum ekraninda 'Add Python to PATH' kutusunu isaretlemeyi unutmayiniz.)
    pause
    exit /b 1
)

start "" python win_app.py
exit
