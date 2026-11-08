# Beacon - Agentic GRC Control Tower

> A forward-deployed reference build: an **AI triage agent for security/GRC findings** with human-in-the-loop guardrails, a data pipeline, prompt evals, business-KPI telemetry and an ROI model.
> Same *shape* as Salesforce's [Pronto](https://github.com/trailheadapps/pronto) sample (data model + Apex actions + LWC + Agentforce agent + headless/REST layer), pointed at the enterprise FDE problem: **ship an agent into a customer's real workflow and prove business value.**

Built by **Shaikat Majumdar** as a Forward Deployed Engineer portfolio piece. Fictional data only. MIT licensed.

## Two ways to run it (no commercial tools, no API keys)

| Mode | Needs | Time | Use it for |
|---|---|---|---|
| **A. Local demo** (primary) | Windows 11 + [Node.js LTS](https://nodejs.org) | 30 sec | The 15-minute interview demo. Works offline. |
| **B. Salesforce Playground** | Free [Trailhead Playground](https://trailhead.salesforce.com) + [Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli) | ~10 min | Proving the same logic runs on the platform: Apex action, REST ingest, LWC dashboard, Agentforce agent. |

## A. Local demo from Windows 11 (cmd / DOS prompt)

```bat
cd beacon
run-demo.bat          :: web UI at http://localhost:8080 (opens automatically)
run-cli-demo.bat      :: terminal-only demo with live agent trace (add --fast to skip delays)
run-tests.bat         :: 8 unit tests
```
Or by hand: `node local\server.js` / `npm start` / `npm test`. Zero npm dependencies; Node 18+.

## B. Salesforce Trailhead Playground

1. In Trailhead: Hands-on Orgs > **Launch** a playground; note its *My Domain* URL (Setup > My Domain).
2. `deploy-to-salesforce.bat` - logs in, deploys `force-app`, assigns the `Beacon_FDE_Demo` permission set, seeds data, runs Apex tests, opens the app.
3. App Launcher > **Beacon** > **Control Tower** > *Run agent on new findings*.
4. **No Agentforce? No problem.** Free Developer Edition and basic Trailhead Playgrounds work: use the built-in **Beacon Agent Console** (chat box on the Control Tower page). See [docs/NO_AGENTFORCE_PATH.md](docs/NO_AGENTFORCE_PATH.md) (also Flow + Anonymous Apex options).
5. Optional, only on Agentforce-enabled orgs: [docs/AGENTFORCE_SETUP.md](docs/AGENTFORCE_SETUP.md).

## What is in the box

| Capability (JD / Pronto parallel) | Local demo | Salesforce package |
|---|---|---|
| Custom data model (Pronto: storefronts/orders) | JSON files | `Control__c`, `Asset__c`, `Finding__c`, `Agent_Run__c` |
| Agent actions / tool calls | `lib/engine.js` | `BeaconTriageAction` (`@InvocableMethod`) |
| Guardrails + human approval | G1-G4, approve/reject UI | same rules in `BeaconTriageEngine` + `Requires_Approval__c` |
| Headless / API layer (Pronto: MCP/HXL) | `POST /api/v1/findings` | `BeaconIngestRest` (`/services/apexrest/beacon/v1/findings`) |
| Data pipeline (Data 360/Snowflake pattern) | `lib/pipeline.js` + quarantine | idempotent upsert on `External_Id__c` |
| Dashboard / KPI reporting | Mission Control UI | LWC `beaconDashboard` + `BeaconKpiController` |
| Prompt eval rigor | v1 vs v2 golden set (64% -> 100%) | prompt templates + Testing Center (docs) |
| Business value | ROI calculator tab | `Agent_Run__c.Minutes_Saved__c` telemetry |

## Repo layout
```
local/        zero-dep Node app (server, UI, CLI demo, engine, pipeline, tests, sample data)
force-app/    Salesforce DX source (objects, Apex, LWC, app, permission set)
scripts/apex/ seed.apex
docs/         DEMO_RUNBOOK, PRESENTATION_PLAYBOOK, ARCHITECTURE, AGENTFORCE_SETUP, TROUBLESHOOTING
```

## Design decisions (ADR summary)
1. **Deterministic scoring + LLM only for classification** - auditable risk math; the non-deterministic step is isolated, versioned and evaluated.
2. **Guardrails as code, not prompt text** - critical, low-confidence, PII and injection paths cannot be talked around.
3. **Staged autonomy** (suggest > approve > auto-close) with override-rate as the trust metric.
4. **Telemetry from day one** - every run writes latency, tokens, minutes saved, guardrails fired.
5. **Quarantine, never drop** - bad records are kept with a reason code.

Simulated numbers (latency, minutes saved) are illustrative model assumptions, not customer results.
