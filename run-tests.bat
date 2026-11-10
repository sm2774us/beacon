@echo off
cd /d "%~dp0"
node --test local\test\engine.test.js local\test\guardrails.test.js
pause
