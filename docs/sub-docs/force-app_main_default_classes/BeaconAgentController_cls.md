# force-app/main/default/classes/BeaconAgentController.cls

---
---

[↩️ Back to SOLUTION_EXPLANATION.md](../../SOLUTION_EXPLANATION.md)

---
---

The `BeaconAgentController` class serves as the entry-point controller for the lightweight, in-org conversational assistant within Salesforce orgs that lack native Agentforce licenses (such as Developer Edition or Trailhead Playground orgs). It mimics the execution loop of an Agentforce agent topic by evaluating user intent, extracting entity references, delegating execution to underlying domain controllers (`BeaconKpiController`, `BeaconApiRest`, `BeaconSeed`), and formatting tool traces for front-end Lightning components.

---

## Architecture & Data Structures

### Inner Classes

1. **`Reply`**: The strongly-typed data transfer object returned by the `@AuraEnabled` entry method to the UI framework.



* `text` (String): The primary conversational response string or help instructions.


* `steps` (List): Formatted trace strings detailing execution tool invocation steps, input arguments, latency metrics, and output payloads.


* `status` (String): High-level operational outcome status (e.g., `'Done'`, `'Approved'`, `'Rejected'`, or the specific finding triage status).



### Static Lookup Patterns & Constants

* **`ID_PAT`**: A regular expression pattern (`(?i)\b(F-\d{5}|E-\d{4})\b`) designed to perform case-insensitive matching for primary entity identifiers. Matches both finding reference numbers starting with `F-` (5 digits) and external system IDs starting with `E-` (4 digits).


* **`HELP`**: Default guidance message detailing supported intent commands (`"triage E-1002"`, `"why is E-1010 blocked"`, `"approve E-1002"`, `"reject E-1008"`, `"triage all new"`, `"status"`, `"reset"`) when user input cannot be parsed or lacks an entity reference.



---

## Detailed Regex Breakdown

The controller relies on a single compiled regular expression to extract targets from natural language user input:

```java
static final Pattern ID_PAT = Pattern.compile('(?i)\\b(F-\\d{5}|E-\\d{4})\\b');

```

| Pattern Name | Regular Expression | What It Does & How It's Used |
| --- | --- | --- |
| **`ID_PAT`** | `(?i)\b(F-\d{5}\mid E-\d{4})\b`

 | Evaluates natural language messages for finding IDs (e.g., `F-00001`) or external reference codes (e.g., `E-1002`) using word boundaries (`\b`). When matched, `mt.group(1).toUpperCase()` extracts the standard uppercase reference ID to route deterministic target actions.

 |

---

## Intent Routing & Execution Workflow

When `BeaconAgentController.ask(String message)` is executed via Lightning Web Components (LWC) or Aura, it routes execution across two primary branches depending on whether an entity identifier (`ref`) is present.

```
						+-------------------------------+
                 |   User Message Received       |
                 +---------------+---------------+
                                 |
                        Evaluate ID_PAT Regex
                                 |
                 +---------------+---------------+
                 |                               |
          [ ref == null ]                 [ ref != null ]
                 |                               |
      Check Command Intents            Check Entity Actions
    +------------+------------+       +----------+----------+
    |            |            |       |                     |
 "reset"    "triage all"   "status"  "approve"/"reject"  "triage"/"explain"
    |            |            |       |                     |
Seed Reset  Bulk Triage   KPI Summary Human Decision   Run/Explain Triage

```

### 1. Global Commands (No Reference ID Match)

If `ref == null`, the controller matches exact keyword patterns within the lowercased message string:

* **Demo Reset (`"reset"`)**: Invokes `BeaconSeed.reset()` to clear operational telemetry and re-seed clean baseline records.
* **Batch Triage (`"triage all" / "run all" / "all new"`)**: Executes `BeaconKpiController.triageNew()` to run triage evaluation across all untouched findings.
* **KPI Summary (`"status" / "kpi" / "summary"`)**: Queries `BeaconKpiController.getKpis()` to aggregate processed/total counts, auto-closure rates, pending approvals, blocked items, and saved financial/hour metrics.
* **Fallback (`HELP`)**: Returns pre-formatted command guidance if input does not match known non-reference intents.

### 2. Targeted Entity Operations (Reference ID Present)

If a valid reference code is captured (e.g., `E-1002`), the engine enters target execution inside a `try-catch` block handling domain exceptions (`BeaconKpiController.BeaconException`):

* **Human Override (`"approve" / "reject"`)**: Calls `BeaconKpiController.decideByRef(ref, decision)` to approve or record an override rejection for findings pending human sign-off.
* **Entity Validation**: Queries existing record representation via `BeaconApiRest.findingView(ref)`. If `null`, returns a prompt directing the user to reset demo data.
* **Explanation vs. Execution (`"why" / "explain"`)**: If a finding is already triaged (status is not `'New'`) and the request asks to `"why"` or `"explain"`, the controller bypasses re-triage. Otherwise, it invokes `BeaconKpiController.triageByRef(ref)` to execute a fresh triage cycle.

---

## Tool Step Formatting & Serialization

For single-entity operations, `BeaconAgentController` retrieves detailed execution metadata generated during triage and formats it into human-readable steps:

1. **Step Extraction**: Extracts the `run` map from the finding payload returned by `BeaconApiRest.findingView(ref)`.

2. **Trace Formatting**: Iterates over `steps` elements and appends serialized logs into `Reply.steps` using the template format:

$$\text{\{tool\}}(\text{\{input\}}) \;\text{\{ms\}} \text{ms} \rightarrow \text{\{output\}}$$

3. **Response Assembly**: Builds the primary `text` payload detailing the updated status, recommendation message, mapped owner team, and explicitly prompts for human approval when the resulting status is `'PENDING_APPROVAL'`.