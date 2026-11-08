@echo off
setlocal
cd /d "%~dp0"
where sf >nul 2>nul || (echo [ERROR] Salesforce CLI not found. Install: https://developer.salesforce.com/tools/salesforcecli & pause & exit /b 1)
echo.
echo Enter your Trailhead Playground My Domain URL, e.g. https://orgfarm-1234abcd.my.salesforce.com
set /p ORGURL=My Domain URL: 
call sf org login web --instance-url %ORGURL% --alias beacon --set-default || goto :err
call sf project deploy start --source-dir force-app --target-org beacon || goto :err
call sf org assign permset --name Beacon_FDE_Demo --target-org beacon
call sf apex run --file scripts\apex\seed.apex --target-org beacon || goto :err
call sf apex run test --class-names BeaconTests --result-format human --wait 10 --target-org beacon
call sf org open --path lightning/n/Beacon_Dashboard --target-org beacon
echo Done. App Launcher ^> Beacon ^> Control Tower, then use the Agent Console chat box.
pause & exit /b 0
:err
echo [ERROR] Step failed - see messages above and docs\TROUBLESHOOTING.md
pause & exit /b 1
