# Troubleshooting
- **'node' is not recognized**: install Node LTS, reopen cmd.
- **Port 8080 busy**: `set PORT=8090 && node local\server.js`.
- **Deploy: permission set / field errors**: re-run `sf project deploy start --source-dir force-app`; check the playground is Developer-Edition-like and API enabled.
- **LWC shows no data**: assign `Beacon_FDE_Demo` to your user; run `seed.apex`.
- **Seed script fails on delete**: harmless on a fresh org; rerun.
- **Agentforce not visible**: expected on free orgs. Use the Agent Console (docs/NO_AGENTFORCE_PATH.md).
- **Browser blocked**: run `run-cli-demo.bat`.
- **Web console and Lightning show different numbers**: you are in LOCAL mode (amber badge). Close it and run `run-demo-salesforce.bat` (green badge: LIVE). Only live mode shares data with the org.
- **Live mode says "Unexpected response from org"**: redeploy the latest code (`deploy-to-salesforce.bat`); the REST endpoint `/beacon/api/*` and the `BeaconApiRest` class must exist and your user needs the `Beacon_FDE_Demo` permission set.
- **"Cannot read Salesforce CLI session"**: run `sf org login web --instance-url <your My Domain> --alias beacon --set-default`.
- **Lightning looks stale**: it auto-refreshes every 5 s; hard-refresh the browser once after a redeploy.
- **"Duplicate PermissionSetAssignment"**: harmless. It means the permission set was already assigned. The latest deploy script treats it as OK.
- **Deploy script seems stuck after seeding**: it is running the Apex tests (1-2 minutes). Wait for "[5/5] Opening the app".

## Web console shows "Cannot load data - INVALID_AUTH_HEADER"
Cause: the console called the org REST API with an access token scraped from `sf org display`, which can be empty/stale/masked on newer Salesforce CLI versions.
Fix (applied in `local/lib/sf.js`): calls now go through `sf api request rest`, so the CLI supplies and refreshes auth itself; the old token path is only a fallback.
If you still see an auth error: `sf org login web --alias beacon --instance-url <My Domain URL>` then re-run `run-demo-salesforce.bat`. Update the CLI with `npm i -g @salesforce/cli` if `sf api request rest --help` is not found.
