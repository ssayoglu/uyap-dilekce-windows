@echo off
chcp 65001 >nul
title UYAP Dilekce ve Sablon Yoneticisi Guncelleme
echo ========================================================
echo ⚖️  UYAP Dilekce ve Sablon Yoneticisi Guncelleme
echo ========================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/ssayoglu/uyap-dilekce-windows/main/update.ps1 | iex"
echo.
pause
