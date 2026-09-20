@echo off
setlocal
cd /d "%~dp0"

echo ============================================
echo       ZeidlerGPT V3.0.1 Windows Build
echo ============================================
echo.

where node >nul 2>nul
if errorlevel 1 (
  echo [FEHLER] Node.js wurde nicht gefunden.
  echo Installiere Node.js 22 LTS und starte diese Datei erneut.
  pause
  exit /b 1
)

where npm >nul 2>nul
if errorlevel 1 (
  echo [FEHLER] npm wurde nicht gefunden.
  pause
  exit /b 1
)

echo [1/4] Abhaengigkeiten installieren...
call npm install
if errorlevel 1 goto :fail

echo.
echo [2/4] Smoke-Test...
call npm run smoke
if errorlevel 1 goto :fail

echo.
echo [3/4] Produktions-Build...
call npm run build
if errorlevel 1 goto :fail

echo.
echo [4/4] Windows Installer + Portable EXE bauen...
call npm run dist
if errorlevel 1 goto :fail

echo.
echo ============================================
echo BUILD ERFOLGREICH
echo Ausgabe: %CD%\dist-installer
echo ============================================
start "" "%CD%\dist-installer"
pause
exit /b 0

:fail
echo.
echo ============================================
echo BUILD FEHLGESCHLAGEN
 echo Siehe Fehlermeldung oben.
echo ============================================
pause
exit /b 1
