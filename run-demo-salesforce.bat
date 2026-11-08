@echo off
setlocal
title Beacon Control Tower (LIVE: Salesforce org)
cd /d "%~dp0"
where node >nul 2>nul || (echo [ERROR] Node.js not found. Install LTS from https://nodejs.org & pause & exit /b 1)
where sf >nul 2>nul || (echo [ERROR] Salesforce CLI not found. https://developer.salesforce.com/tools/salesforcecli & pause & exit /b 1)
set SF_ORG=beacon
call sf org display --target-org %SF_ORG% >nul 2>nul || (echo [ERROR] No CLI session for alias "%SF_ORG%". Run deploy-to-salesforce.bat first. & pause & exit /b 1)
echo LIVE mode: this web console reads and writes your Salesforce org (alias %SF_ORG%).
echo Lightning Control Tower and this console now always show the same data.
start "" http://localhost:8080
node local\server.js
