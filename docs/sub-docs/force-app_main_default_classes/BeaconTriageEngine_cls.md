# force-app/main/default/classes/BeaconTriageEngine.cls

---
---

[↩️ Back to SOLUTION_EXPLANATION.md](../../SOLUTION_EXPLANATION.md)

---
---

The `BeaconTriageEngine` class is the deterministic rules engine that powers compliance triage across the Salesforce organization. It mirrors a local JavaScript simulation engine (`prompt v2`) to ensure that both the Lightning app and local console output identical scores, weights, thresholds, latencies, and guardrail decisions.

---

## Architecture & Data Structures

### Inner Classes

1. **`Step`**: Represents an individual execution trace step.
* `tool` (String): The name of the simulated tool (e.g., `get_asset_context`, `classify_llm`, `score_risk`).
* `input` (String): The input parameters or references passed to the tool.
* `output` (String): The descriptive result produced by the tool.
* `ms` (Integer): Simulated execution latency in milliseconds.

2. **`Result`**: The comprehensive output object returned by the triage process.
* Contains categorization, calculated risk score (`score`), risk tier (`band`), confidence level (`confidence`), final triage status (`status`), guardrails triggered (`guardrails`), remediation recommendation, minutes saved, latency breakdown, token consumption, owner team, and the full step trace list (`steps`).

### Static Lookup Maps & Constants

* **`SEV`**: Maps finding severity levels to numeric weights (`Low` = 1, `Medium` = 2, `High` = 3, `Critical` = 4).

* **`BONUS`**: Maps security finding categories to score modifiers (e.g., `malware` = +10, `exposure` = +8, `identity` = +8, `privilege` = +8, `phishing` = +5, `drift` = +3, `benign` = -25, `other` = 0).

* **`CATS` & `KW**`: Defines target threat categories (`malware`, `phishing`, `identity`, `exposure`, `privilege`, `drift`) and their corresponding keyword lists for keyword-based classification.

* **`REC`**: Standardized remediation playbooks corresponding to each threat category.

---

## Detailed Regex Breakdown

The engine utilizes two primary regular expressions for content analysis and security validation:

```java
static final Pattern NEGATION = Pattern.compile('(no evidence of|false positive|came back clean|not malicious)');
static final Pattern INJECTION = Pattern.compile('(ignore (all )?(previous|prior) instructions|system prompt|disregard (the )?policy)');

```

| Pattern Name | Regular Expression | What It Does & How It's Used |
| --- | --- | --- |
| **`NEGATION`** | `(no evidence of|false positive\|came back clean\|not malicious)` | Scans text for phrases indicating a false alarm. If matched in `classifyDetail()`, the engine immediately short-circuits classification, overrides category to **`benign`**, and tags it as a false positive. |
| **`INJECTION`** | `(ignore (all )?(previous\|prior) instructions\|system prompt\|disregard (the )?policy)` | Scans finding titles and descriptions for prompt injection payloads designed to hijack automated agent workflows. If matched, `injected` becomes `true`, forcing the status to **`'Blocked'`** and firing `G4_PROMPT_INJECTION`. |

---

## Step-by-Step Triage Execution Workflow

When `BeaconTriageEngine.triage(Finding__c f, Asset__c asset, Control__c control)` is invoked, it executes the following pipeline:

1. **Context & Injection Analysis**
  * Extracts external IDs, builds the combined text payload (`Title + Description`), and evaluates the `INJECTION` regex pattern.

2. **Step Trace Recording (`get_asset_context` & `lookup_control`)**
  * Logs execution steps with deterministic latency calculations derived from a custom string hashing function (`hash()`).

3. **Classification (`classifyDetail`)**
  * Checks for negation patterns first. If none, iterates through categories and keywords (`KW`) to categorize the finding (defaulting to `'other'` if no keywords match). Adds the `classify_llm` step trace.

---

## How Risk Scores and Bands Are Calculated

Risk calculation is a multi-layered deterministic process inside `triage()` that combines base severity, category impact, compliance control criticality, and asset-specific context.

1. **Base Score Calculation:**
  * Takes the numeric weight from the `SEV` map based on the finding's severity (`Low` = 1, `Medium` = 2, `High` = 3, `Critical` = 4) and multiplies it by 10.
  * Adds the category score modifier from the `BONUS` map (e.g., `malware` adds +10, while `benign` subtracts 25).

2. **Contextual Adjustments:**
  * **Control Criticality:** If a compliance control is linked and has a criticality score, that value is added directly.
  * **Asset Tier:** If an asset is mapped, Tier 1 adds +15 points, Tier 2 adds +8 points, and Tier 3 adds 0.
  * **Data Sensitivity & Exposure:** If the asset contains PII (`Contains_PII__c`), +10 points are added. If it is internet-facing (`Internet_Facing__c`), +8 points are added.

3. **Clamping & Banding:**
  * The raw score is clamped between `0` and `100` using `Math.max(0, Math.min(100, score))`.
  * The score is then mapped into a discrete risk **band**:
  * **Critical**: Score $\ge 75$
  * **High**: Score $\ge 50$
  * **Medium**: Score $\ge 30$
  * **Low**: Score $< 30$

---

## How Guardrails and Security Gates Work

Once confidence and risk bands are calculated, the engine runs policy guardrails to enforce safety gates, determining whether a finding can be auto-processed or must be routed to human analysts.

1. **Confidence Score Calculation:**
  * Baseline confidence starts at `0.5`, with positive increments added if a control is present (+0.15), an asset is present (+0.15), the category is successfully classified away from 'other' (+0.15), plus a base bonus (+0.05), capped at a maximum of `1.0`.

2. **Guardrail Evaluation Rules:**
  * **`G4_PROMPT_INJECTION`**: If the `INJECTION` regex pattern matches the text, status is set to **`'Blocked'`** and this guardrail fires.
  * **`G2_CRITICAL_REQUIRES_HUMAN`**: If the risk band is evaluated as **Critical**, status is set to **`'Pending Approval'`**.
  * **`G3_LOW_CONFIDENCE_REQUIRES_HUMAN`**: If confidence is below `0.6`, status is set to **`'Pending Approval'`**.
  * **`G1_PII_NO_AUTOCLOSE`**: If a finding has low risk and high confidence ($\ge 0.85$), but the underlying asset contains PII, auto-closure is blocked, setting the status to **`'Assigned'`**.
  * **Auto-Closed / Assigned Default**: If low risk, high confidence ($\ge 0.85$), and no PII, the status becomes **`Auto-Closed`**; otherwise, it defaults to **`Assigned`**.

---

## Finalizing Metrics

* Calculates estimated analyst minutes saved (e.g., 17.5 minutes for Auto-Closed, 14 for Assigned, 12 for Pending Approval).
* Computes token usage based on text length and calculates total execution latency in milliseconds (`latencyMs`).
* Assigns ownership routing to the control's owner team or defaults to `GRC Office (unmapped)`.
