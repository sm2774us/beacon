@echo off
setlocal
title Beacon Control Tower
cd /d "%~dp0"
where node >nul 2>nul || (echo [ERROR] Node.js not found. Install LTS from https://nodejs.org then re-run. & pause & exit /b 1)
echo Starting Beacon Control Tower on http://localhost:8080 ...
start "" http://localhost:8080
node local\server.js
