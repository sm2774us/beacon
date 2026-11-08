@echo off
setlocal
cd /d "%~dp0"
where sf >nul 2>nul || (echo [ERROR] Salesforce CLI not found. Install: https://developer.salesforce.com/tools/salesforcecli & pause & exit /b 1)
set ORG=beacon
echo.
echo Enter your Salesforce My Domain URL, e.g. https://cunning-hawk-xxxx-dev-ed.trailblaze.my.salesforce.com
echo (press ENTER to reuse the existing CLI session for alias "%ORG%")
set "ORGURL="
set /p ORGURL=My Domain URL: 
if defined ORGURL (
  call sf org login web --instance-url %ORGURL% --alias %ORG% --set-default || goto :err
) else (
  call sf org display --target-org %ORG% >nul 2>nul || (echo [ERROR] No saved session for alias "%ORG%". Enter your URL. & goto :err)
)

echo.
echo [1/5] Deploying metadata ...
call sf project deploy start --source-dir force-app --target-org %ORG% || goto :err

echo.
echo [2/5] Assigning permission set Beacon_FDE_Demo ...
call sf org assign permset --name Beacon_FDE_Demo --target-org %ORG% >"%TEMP%\beacon_ps.txt" 2>&1
if errorlevel 1 (
  findstr /C:"Duplicate PermissionSetAssignment" "%TEMP%\beacon_ps.txt" >nul
  if errorlevel 1 ( type "%TEMP%\beacon_ps.txt" & goto :err )
  echo       Already assigned - OK.
) else (
  echo       Assigned.
)

echo.
echo [3/5] Resetting and seeding demo data (idempotent: safe to re-run) ...
call sf apex run --file scripts\apex\seed.apex --target-org %ORG% >"%TEMP%\beacon_seed.txt" 2>&1
if errorlevel 1 ( type "%TEMP%\beacon_seed.txt" & goto :err )
findstr /C:"Beacon reset complete" "%TEMP%\beacon_seed.txt"

echo.
echo [4/5] Running Apex tests (about 1-2 minutes, please wait) ...
call sf apex run test --class-names BeaconTests --synchronous --result-format human --wait 10 --target-org %ORG%
if errorlevel 1 echo [WARN] Some Apex tests failed - the app still works. Send me the output above.

echo.
echo [5/5] Opening the app ...
call sf org open --path lightning/n/Beacon_Dashboard --target-org %ORG%
echo.
echo DONE. In Salesforce: App Launcher ^> Beacon ^> Control Tower.
echo For the synced local web console run: run-demo-salesforce.bat
pause & exit /b 0
:err
echo.
echo [ERROR] Step failed - see messages above and docs\TROUBLESHOOTING.md
pause & exit /b 1
