# force-app/main/default/classes/BeaconTests.cls

---
---

[↩️ Back to SOLUTION_EXPLANATION.md](../../SOLUTION_EXPLANATION.md)

---
---

The `BeaconTests` class is the comprehensive unit and integration test suite designed to validate the entire compliance automation package. It exercises core domain logic across deterministic risk triage, headless REST event ingestion, conversational agent intent routing, KPI controllers, API REST endpoints, and state reset routines.

---

## Test Setup & Fixture Generation

The test suite uses standard Apex test setup methods and helper functions to establish a consistent testing baseline.

### `@TestSetup` Method

* **Control Creation**: Inserts a base compliance control (`Name = 'Logical Access'`, `Control_Code__c = 'CC6.1'`, `Criticality__c = 10`, `Framework__c = 'SOC2'`).

* **Asset Creation**: Inserts two baseline assets representing distinct operational tiers:
  * `core-ledger`: Tier 1 asset containing PII (`Contains_PII__c = true`), non-internet-facing.
  * `dev-sandbox`: Tier 3 asset without PII (`Contains_PII__c = false`), non-internet-facing.

### Helper Utility (`mk`)

* **`mk(String ext, String sev, String asset, String title, String detail)`**: Streamlines the instantiation of `Finding__c` records linked dynamically to pre-inserted test assets and controls by name lookup.

---

## Test Coverage Breakdown

The test suite covers seven distinct functional verification blocks:

### 1. Engine Classification & Negation (`classifiesNegationAsBenign`)

* Verifies that `BeaconTriageEngine.classify()` correctly identifies negation phrases (e.g., `"No evidence of malware; scan came back clean"`) and overrides categories to `'benign'`.
* Validates standard keyword classification rules for security exposure vectors (e.g., `"allows 0.0.0.0/0 on port 22"` mapping to `'exposure'`).

### 2. Guardrails & Routing Rules (`guardrailsRouteCorrectly`)

* Instantiates three diverse test findings (`T1` Critical Ransomware C2, `T2` Low Config Drift, and `T3` Medium Finding containing prompt injection text).
* Invokes `BeaconTriageAction.triage()` inside transaction boundary test blocks (`Test.startTest()` / `Test.stopTest()`).
* Asserts that guardrail policies route outcomes correctly:
* `T1` evaluates to **`Pending Approval`**.
* `T2` evaluates to **`Auto-Closed`**.
* `T3` evaluates to **`Blocked`** due to prompt injection payloads.
* Asserts creation of exactly three `Agent_Run__c` telemetry tracking records.

### 3. REST Ingestion, Idempotency & Quarantine (`restIngestIsIdempotentAndQuarantines`)

* Simulates an inbound REST payload containing valid, duplicate, and malformed/invalid-severity security events (`R1` valid, duplicate `R1`, and `R2` with severity `"banana"`).
* Configures `RestContext.request` with serialized JSON test payloads.
* Asserts that `BeaconIngestRest.ingest()` successfully upserts 1 record while quarantining 2 invalid items.
* Verifies idempotency by re-running ingestion and verifying total unique record count remains `1`.

### 4. KPI Controller & Queue Verification (`kpiController`)

* Inserts a test finding (`K1`) and verifies that `BeaconKpiController.triageNew()` processes exactly 1 record.
* Asserts that KPI summary maps report `processed` count as `1` and queue lists return valid row sizing.

### 5. Conversational Agent Intent Handling (`agentConsoleHandlesIntents`)

* Inserts a critical finding (`E-1002`) linked to `core-ledger`.
* Asserts conversational response states across multiple user inputs:
* `"triage E-1002"` returns status `'PENDING_APPROVAL'`.
* `"why is E-1002 pending"` generates an execution step trace of length `5`.
* `"approve E-1002"` successfully updates status to `'Approved'`.
* `"status"` queries KPI strings containing `"triaged"`.
* General queries (e.g., `"hello"`) return help text containing `"Try"`.

### 6. Seed Reset & State Parity (`resetGivesCleanSlateAndStateMatchesLocalDemo`)

* Invokes `BeaconSeed.reset()` to initialize baseline demo records.
* Validates API state maps against expected local demo parameters:
* Total findings: `14`, processed: `0`, pipeline received: `18`, accepted: `14`, quarantined: `4`.
* Executes `BeaconKpiController.triageNew()` and validates updated KPI distributions (processed: `14`, autoClosed: `4`, assigned: `6`, pending: `3`, blocked: `1`, average latency: `660ms`).
* Executes a secondary reset to confirm all telemetry runs are cleared (`0` records in `Agent_Run__c`).

### 7. REST API Endpoint Operations (`restPostOperations`)

* Configures mock `RestResponse` and `RestRequest` contexts to test direct Apex REST mappings.
* Exercises `/beacon/api/reset`, `/beacon/api/triage/E-1002`, and `/beacon/api/decision/E-1002/approve` endpoints.
* Verifies finding status transitions to `'APPROVED'`.
* Tests duplicate action handling to ensure appropriate error handling returns HTTP status code `409`.