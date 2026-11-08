@echo off
cd /d "%~dp0"
node --test local\test\engine.test.js
pause
