@echo off
cd /d "%~dp0"
where node >nul 2>nul || (echo [ERROR] Node.js not found. Install LTS from https://nodejs.org & pause & exit /b 1)
chcp 65001 >nul
node local\cli\demo.js %*
echo.
pause
