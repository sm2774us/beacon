# Troubleshooting
- **'node' is not recognized**: install Node LTS, reopen cmd.
- **Port 8080 busy**: `set PORT=8090 && node local\server.js`.
- **Deploy: permission set / field errors**: re-run `sf project deploy start --source-dir force-app`; check the playground is Developer-Edition-like and API enabled.
- **LWC shows no data**: assign `Beacon_FDE_Demo` to your user; run `seed.apex`.
- **Seed script fails on delete**: harmless on a fresh org; rerun.
- **Agentforce not visible**: expected on free orgs. Use the Agent Console (docs/NO_AGENTFORCE_PATH.md).
- **Browser blocked**: run `run-cli-demo.bat`.
