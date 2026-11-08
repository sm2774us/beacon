# Demo Runbook (Windows 11, offline-safe)

## T-1 day
1. Install Node.js LTS (`node --version` shows v18+). 
2. Unzip to `C:\beacon`. Double-click `run-tests.bat` -> expect `# pass 8`.
3. Run `run-demo.bat` once; confirm the page loads; press **Reset demo**. Close.
4. (Optional) `deploy-to-salesforce.bat` to your Playground and log in once so the session is warm. Playground orgs expire - re-check the day before.
5. Print or save the slides as PDF. Bring HDMI/USB-C adapter. Disable notifications. Zoom browser to 110%.

## Pre-flight (10 min before)
- Open **two** windows: browser (localhost:8080) and cmd (`cd C:\beacon`). Salesforce org tab logged in (optional).
- Fallback if the browser fails: `run-cli-demo.bat` shows everything in the terminal.

## 5-minute live demo script
| Min | Screen | Say |
|---|---|---|
| 0:00 | **Data Pipeline** tab | "18 raw events in, 14 accepted, 4 quarantined with reason codes. Nothing silently dropped." |
| 0:45 | **Mission Control** > Run agent on all | "Each finding goes through tools: asset context, control lookup, classify, score, guardrails." |
| 1:30 | Click E-1002 (public S3 bucket) | "Critical, PII, internet-facing -> the agent cannot act alone. Guardrail G2, human approves." Click **Approve**. |
| 2:15 | Click E-1010 | "Prompt injection hidden in a ticket comment. Blocked by G4 - guardrails are code, not prompt text." |
| 2:45 | Click E-1009 | "Low risk, but PII asset -> never auto-closed (G1)." |
| 3:15 | **Prompt Evals** | "v1 passed 64% on the golden set. Why: vocabulary gap, negation blindness, missing class. v2 = 100%. Gate in CI." |
| 4:00 | **ROI** | Drag sliders. "Value is capacity returned to analysts. Inputs are the sponsor's numbers, not mine." |
| 4:40 | **Salesforce Mapping** | "Same logic is Apex invocable action + LWC in the Playground." |

Optional curl (cmd): `curl -X POST http://localhost:8080/api/v1/findings -H "Content-Type: application/json" -d "{\"id\":\"E-2001\",\"src\":\"Splunk\",\"sev\":\"high\",\"title\":\"Test\",\"detail\":\"x\"}"`

## Reset between runs
Click **Reset demo** (or restart the server).
