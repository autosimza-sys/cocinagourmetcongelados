@echo off
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-Content -Raw '%~dp0index.html' | Set-Clipboard"
echo.
echo Codigo completo de index.html copiado al portapapeles.
echo Ahora anda donde editas tu web y pega con Ctrl + V.
echo.
pause
