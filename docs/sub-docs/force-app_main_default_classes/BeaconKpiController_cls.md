# force-app/main/default/classes/BeaconKpiController.cls

---
---

[↩️ Back to SOLUTION_EXPLANATION.md](../../SOLUTION_EXPLANATION.md)

---
---

The `BeaconKpiController` class acts as the primary controller facade and orchestration bridge for the Lightning Web Component (LWC) Control Tower user interface. It exposes `@AuraEnabled` endpoints for component state consumption, batch/single finding triage invocation, human-in-the-loop decision routing (`approve`/`reject`), and demo state reset triggers. Additionally, it provides transactional database helper methods that handle record lookups, error boundary conversions, and telemetry sync.

---

## Architecture & Data Structures

### Custom Exceptions

* **`BeaconException`**: Extends standard Apex `Exception`. Serves as the internal domain exception thrown across record lookup failures, state validation mismatches, and invalid decision parameters.



### Aura & LWC Interface Methods

1. **`getKpis()`**: `@AuraEnabled(cacheable=true)` method that delegates state retrieval to `BeaconApiRest.state()` and extracts the high-level KPI telemetry map (`kpis`).


2. **`getQueue()`**: `@AuraEnabled(cacheable=true)` method that delegates to `BeaconApiRest.queue()` to furnish formatted rows for the LWC data table component.


3. **`triageNew()`**: `@AuraEnabled` imperative method that identifies unprocessed findings (`Status__c = 'New'`), constructs bulk invocable requests, and dispatches them to `BeaconTriageAction.triage()`.


4. **`triageOne(String ref)`**: `@AuraEnabled` imperative wrapper around `triageByRef()` that traps domain exceptions and throws an LWC-compatible `AuraHandledException`.


5. **`decide(String ref, String decision)`**: `@AuraEnabled` imperative wrapper around `decideByRef()` that translates governance decisions into `AuraHandledException` payloads upon failure.


6. **`resetDemo()`**: `@AuraEnabled` imperative trigger that executes `BeaconSeed.reset()` to return the org to a pristine baseline state.



---

## Direct Database Querying & Record Lookup Mechanics

The controller enforces strict user-mode record resolution when converting natural language references or user inputs into underlying Salesforce record IDs.

```java
public static Finding__c findFinding(String ref) {
    List<Finding__c> l = [SELECT Id, Name, External_Id__c, Status__c FROM Finding__c WHERE External_Id__c = :ref OR Name = :ref WITH USER_MODE LIMIT 1];
    if (l.isEmpty()) { throw new BeaconException('No finding matches ' + ref); }
    return l[0];
}

```

| Lookup Parameter | Resolution Logic | Exception Handling |
| --- | --- | --- |
| **`ref`** | Scans `Finding__c` using a dual `OR` SOQL condition against `External_Id__c` (e.g., `E-1002`) and `Name` (e.g., `F-00001`) with `WITH USER_MODE`.

 | Throws `BeaconException('No finding matches ' + ref)` if no record is found in the org.

 |

---

## Triage Orchestration Workflow

When `triageNew()` or `triageByRef()` is executed, the controller translates record handles into `BeaconTriageAction.Request` DTOs to execute the deterministic triage engine:

```
                  +-----------------------------------+
                  |   Triage Execution Initiated      |
                  +-----------------+-----------------+
                                    |
          +-------------------------+-------------------------+
          | [triageNew()]                                     | [triageByRef(ref)]
          v                                                   v
   Query 'New' Findings                                findFinding(ref)
   (Up to 200 Records)                                 Construct 1 Request
   Construct Request List                                     |
          |                                                   |
          +-------------------------+-------------------------+
                                    |
                                    v
                     BeaconTriageAction.triage(reqs)
                                    |
                                    v
                      Telemetry & Database Update

```

1. **Bulk Ingest Triage (`triageNew`)**:
* Queries up to 200 unprocessed `Finding__c` records (`Status__c = 'New'`) under `WITH USER_MODE`.


* Wraps each record ID inside a `BeaconTriageAction.Request` container.


* Dispatches the batch list to `BeaconTriageAction.triage(reqs)` and returns the count of triaged items.




2. **Single Finding Triage (`triageByRef`)**:
* Resolves the target finding record via `findFinding(ref)`.


* Constructs a single-element request list and invokes `BeaconTriageAction.triage()`.





---

## Governance Decisions & Analyst Overrides

The `decideByRef(String ref, String decision)` method provides the state validation and record updates necessary to record human analyst intervention when findings are routed to `'Pending Approval'`.

### 1. Pre-Condition Validation

* **Parameter Check**: Verifies that `decision` equals strictly `'approve'` or `'reject'` (lowercased). Throws `BeaconException('Decision must be approve or reject')` if invalid.


* **State Check**: Fetches target record via `findFinding(ref)`. Validates that `f.Status__c == 'Pending Approval'`. If the finding is in any other status, it throws `BeaconException(ref + ' is "' + f.Status__c + '", not Pending Approval.')`.



### 2. Status & Approval Flag Updates

* Sets `f.Status__c` to **`'Approved'`** if `decision == 'approve'` or **`'Rejected'`** if `decision == 'reject'`.


* Clears the human intervention gate by setting `Requires_Approval__c = false`.


* Performs a schema-enforced DML update: `update as user new Finding__c(...)`.



### 3. Agent Telemetry Synchronization & Override Tracking

* Queries related `Agent_Run__c` records linked to the finding.


* Sets `Agent_Run__c.Outcome__c` to `'Approved'` or `'Rejected'`.


* **Financial Metric Penalty for Overrides**: If the decision is `'reject'` (analyst override), `Minutes_Saved__c` is reset to `0`. This directly recalculates down-stream ROI and analyst dollar savings metrics reported by `BeaconApiRest.state()`.


* Updates modified run records via `update as user runs;`.



---

## Exception Handling & LWC Bridge

Because standard Apex exceptions cause generic component errors in Lightning Web Components, `BeaconKpiController` routes all user-facing domain exceptions through a private helper method:

```java
static AuraHandledException aura(String msg) {
    AuraHandledException e = new AuraHandledException(msg);
    e.setMessage(msg);
    return e;
}

```

This ensures that UI components capture clean error strings matching `BeaconException.getMessage()` directly within LWC `error.body.message` callbacks without exposing raw Apex stack traces.