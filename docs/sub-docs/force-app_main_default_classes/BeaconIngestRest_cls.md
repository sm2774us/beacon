# force-app/main/default/classes/BeaconIngestRest.cls

---
---

[↩️ Back to SOLUTION_EXPLANATION.md](../../SOLUTION_EXPLANATION.md)

---
---

The `BeaconIngestRest` class is the headless REST API endpoint (`@RestResource(urlMapping='/beacon/v1/findings/*')`) that powers automated security event ingestion into the Salesforce organization. It mirrors the validation, normalization, deduplication, and quarantine semantics of the local JavaScript simulation pipeline (`local/lib/pipeline.js`), executing idempotent upserts on `External_Id__c` while preserving the status of already-triaged findings.

---

## Architecture & Data Structures

### REST Annotations & Entry Points

* **`@RestResource(urlMapping='/beacon/v1/findings/*')`**: Exposes a headless HTTP POST endpoint for ingestion payloads.


* **`ingest()`**: Handles incoming HTTP POST requests, extracts the request body as a JSON string, handles single-object or array payloads, and forwards normalized line items to `processLines()`.


* **`processLines(List<String> lines)`**: Core ingestion engine that executes parsing, data normalization, validation, quarantine tracking, and idempotent database upserts.



### Inner Classes & Data Transfer Objects

1. **`Evt`**: Represents a raw inbound security event payload.
* Fields: `id`, `src`, `sev`, `asset`, `control`, `title`, `detail`.




2. **`Outcome`**: Represents the batch execution summary returned by the ingestion operation.
* `received` (Integer): Total incoming lines processed.


* `upserted` (Integer): Total valid records successfully upserted.


* `quarantined` (`List<String>`): Detailed list of quarantine identifiers and reason codes.





### Static Lookup Maps & Constants

* **`SEVMAP`**: Normalizes diverse external severity strings into standardized Salesforce picklist values:
* `'low'`, `'sev1'` $\rightarrow$ `'Low'`


* `'medium'`, `'sev2'` $\rightarrow$ `'Medium'`


* `'high'`, `'sev3'` $\rightarrow$ `'High'`


* `'crit'`, `'critical'`, `'sev4'` $\rightarrow$ `'Critical'`





---

## Ingestion Pipeline & Validation Workflow

When `processLines()` executes, it processes inbound JSON lines through a strict validation and quarantine pipeline:

```
                  +--------------------------------+
                  |    Inbound JSON Lines (List)   |
                  +---------------+----------------+
                                  |
                   Query Asset & Control Lookups
                                  |
                  +---------------+----------------+
                  |   For Each Line: Validate      |
                  +---------------+----------------+
                                  |
       +--------------------------+--------------------------+
       | [Error Found]                                       | [Valid Item]
       v                                                     v
  Quarantine Item & Record Reason                       Add to Accepted Map
  - malformed_json                                      - Deduplicate by ID
  - missing_required_field                              - Map Normalized Severity
  - invalid_severity
  - duplicate
       |                                                     |
       +--------------------------+--------------------------+
                                  |
                                  v
                    Check Existing Finding Status
                 Upsert Records (User Mode Security)
                   Record Ingest Batch Telemetry
                                  |
                                  v
                         Return Outcome Object

```

### 1. Context & Reference Resolution

Before validating event lines, the engine queries all active `Asset__c` and `Control__c` records under `WITH USER_MODE` security enforcement, building in-memory lookup maps (`Asset Name $\rightarrow$ Id` and `Control Code $\rightarrow$ Id`).

### 2. Validation & Quarantine Rules

Iterating through each event line, the engine assigns a `reason` code if validation fails:

* **`malformed_json`**: Triggered if JSON deserialization throws an exception.


* **`missing_required_field`**: Triggered if the event object is null or lacks an identifier (`id`) or `title`.


* **`invalid_severity`**: Triggered if the severity string cannot be mapped via `SEVMAP`.


* **`duplicate`**: Triggered if an event ID is repeated within the same payload batch (`accepted.containsKey(e.id)`).



Quarantined items are logged with reason codes in `o.quarantined`, aggregated in `reasons`, and stored with truncated payload snippets (`max length 80`) in quarantine diagnostic lists.

---

## Idempotent Upsert & State Protection

Valid accepted events undergo deduplication checks against existing records in the database:

1. **Existence Check**: Queries existing `Finding__c` records where `External_Id__c` matches accepted keys using `WITH USER_MODE`.


2. **Status Preservation**: For newly inserted records (items not found in the existing database set), the status is explicitly initialized to `'New'` (`f.Status__c = 'New'`). Re-ingesting existing findings updates core metadata (`Title__c`, `Description__c`, `Severity__c`, etc.) without resetting the lifecycle status of already-triaged findings.


3. **Database Upsert**: Executes `upsert as user recs Finding__c.External_Id__c;` to guarantee secure, idempotent record synchronization.



---

## Telemetry & Batch Audit Logging

Upon completing the upsert phase, the engine records an audit trail by inserting an `Ingest_Batch__c` telemetry record under user mode:

* Stores aggregate counts (`Received__c`, `Accepted__c`, `Quarantined__c`).


* Serializes reason maps and quarantine diagnostic details into JSON format (`Reasons__c`, `Quarantine_Detail__c`) to provide full visibility for the Control Tower UI.