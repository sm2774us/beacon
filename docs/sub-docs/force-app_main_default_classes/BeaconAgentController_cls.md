# force-app/main/default/classes/BeaconAgentController.cls

---
---

[↩️ Back to SOLUTION_EXPLANATION.md](../../README.md)

---
---

In the `BeaconAgentController` apex class, the regular expression is defined as:

```java
static final Pattern ID_PAT = Pattern.compile('(?i)\\b(F-\\d{5}|E-\\d{4})\\b');

```

This regular expression is designed to scan incoming user messages and extract specific, formatted record identifiers (such as finding or entity IDs like `F-12345` or `E-1002`) regardless of casing.

---

### Component-by-Component Breakdown

| Token / Segment | What It Does |
| --- | --- |
| `(?i)` | **Case-Insensitive Flag:** An inline modifier that tells the regex engine to match letters case-insensitively. This allows the pattern to match both uppercase and lowercase inputs (e.g., `e-1002` or `E-1002`). |
| `\\b` | **Word Boundary (Start):** Asserts that the match must begin at a word boundary. This prevents partial matches inside larger words or strings (e.g., ensuring it doesn't match the middle of `PREFIX-1002`). *Note: The double backslash `\\` is required in Apex/Java string literals to escape the backslash.* |
| `(...)` | **Capturing Group:** Groups the alternative patterns together. Because it is a capturing group, the Apex code can reference and extract the exact matched string via `mt.group(1)`. |
| `F-\\d{5}` | **First Alternative Pattern:** Matches a literal letter `F` (or `f`), followed by a literal hyphen (`-`), followed by **exactly 5 digits** (`\\d{5}`). Example match: `F-12345`. |
| `|` | **Alternation (OR):** Acts as a logical operator meaning "match either the pattern on the left **or** the pattern on the right." |
| `E-\\d{4}` | **Second Alternative Pattern:** Matches a literal letter `E` (or `e`), followed by a literal hyphen (`-`), followed by **exactly 4 digits** (`\\d{4}`). Example match: `E-1002`. |
| `\\b` | **Word Boundary (End):** Asserts that the match must end at a word boundary, preventing it from matching a longer ID (e.g., stopping `E-1002` from matching the first part of `E-10025`). |

---

### How It Works in the Code

When a user sends a message like `"approve e-1002"`, the code executes:

1. **`Matcher mt = ID_PAT.matcher(msg);`**: Scans the message string for any text matching the defined pattern.
2. **`mt.find() ? mt.group(1).toUpperCase() : null;`**: If a match is found, `group(1)` extracts the exact substring inside the capturing group (e.g., `e-1002`), and `.toUpperCase()` normalizes it to uppercase (`E-1002`) so it can be queried cleanly against Salesforce records (`Finding__c` Name or External ID).

---

In the `BeaconAgentController` class, regular expressions and SOQL (Salesforce Object Query Language) work hand in hand to bridge the gap between **unstructured human input** (what a user types in a chat) and **structured Salesforce database records**.

Here is a step-by-step breakdown of how that connection operates:

---

### Step 1: Extracting the Identifier via Regex

When a user chats with the agent, their input is natural language—for example:

> `"Can you please explain E-1002 for me?"`

Because the ID (`E-1002`) can appear anywhere in the sentence, the regular expression (`ID_PAT`) acts as a precise scanner:

```java
static final Pattern ID_PAT = Pattern.compile('(?i)\\b(F-\\d{5}|E-\\d{4})\\b');
Matcher mt = ID_PAT.matcher(msg);
String ref = mt.find() ? mt.group(1).toUpperCase() : null;

```

* **The Scan:** The regex searches the text for the specific pattern (`E-` followed by 4 digits, or `F-` followed by 5 digits).
* **The Extraction:** Once found, `mt.group(1)` isolates that exact string (e.g., `"e-1002"`), and `.toUpperCase()` standardizes it to `"E-1002"`, storing it in the variable `ref`. If no ID is mentioned, `ref` remains `null`.

---

### Step 2: Passing the Extracted Value into SOQL

Once `ref` holds the extracted identifier, it is fed directly into a SOQL query as a **bind variable** (`:ref`):

```java
List<Finding__c> found = [
    SELECT Id, Name, Status__c 
    FROM Finding__c 
    WHERE Name = :ref OR External_Id__c = :ref 
    WITH USER_MODE 
    LIMIT 1
];

```

* **The Bind Variable (`:ref`):** Apex allows variables to be injected into queries using the colon prefix (`:ref`). This securely inserts the exact string captured by the regex into the database filter.
* **Database Lookup:** The query searches the `Finding__c` custom object, checking both the standard `Name` field and the `External_Id__c` field to find the corresponding compliance finding record.

---

### Why This Connection Matters

1. **Natural Language Flexibility:** Users don't have to navigate to a specific record or copy-paste a Salesforce record ID (`18-character alphanumeric Salesforce ID`). They can just type shorthand like `"triage e-1002"`.
2. **Security & Injection Prevention:** By using SOQL bind variables (`:ref`) instead of string concatenation, Salesforce automatically sanitizes the input, entirely preventing SOQL injection vulnerabilities.
3. **Graceful Fallback:** If the regex doesn't find a valid finding ID (`ref == null`), the controller skips the database query entirely and falls back to checking for general commands like `"triage all"` or `"status"`.

---

## Overview of `BeaconTriageAction`

In this Salesforce Apex codebase, **`BeaconTriageAction`** serves as the core automated "action" or tool. In a full Agentforce implementation, this logic would be wrapped as an Invocable Action called directly by an Agentforce Topic. Because this developer edition environment lacks native Agentforce, `BeaconAgentController` acts as a deterministic router that mimics the exact same execution pattern.

When a user asks the agent to triage a finding (e.g., `"triage E-1002"`), the controller delegates the heavy lifting to `BeaconTriageAction`.

---

### Step-by-Step Execution Workflow

1. **Request Invocable Wrapper (`BeaconTriageAction.Request`)**
* The controller instantiates a request object, populates `q.findingId = f.Id`, and passes it in a list to `BeaconTriageAction.triage()`. This matches Salesforce’s standard `@InvocableMethod` signature, which accepts lists of wrapper classes to support bulk processing.

2. **Context Assembly (Asset & Control Mapping)**
* The action queries the `Finding__c` record along with its related parent relationships:
* **Asset Context:** Checks whether the asset contains PII (`Asset__r.Contains_PII__c`), is internet-facing (`Asset__r.Internet_Facing__c`), and its criticality tier (`Asset__r.Tier__c`).
* **Control Mapping:** Links the finding to a compliance control (e.g., SOC2 control code, name, criticality, and owner team).

3. **Risk Scoring & Classification**
* Computes or evaluates the finding's category, risk score, risk band, and confidence score.

---

### How Guardrails Are Evaluated

Guardrails in this architecture act as automated safety and compliance policy checks that determine whether a finding can be auto-processed or if it requires mandatory human intervention.

* **Policy Guardrail Execution:**
During `BeaconTriageAction.triage()`, the business logic evaluates risk rules against the finding and its asset context. For example:
  * Does an internet-facing asset have unpatched vulnerabilities combined with PII?
  * Is the risk score above a specific threshold?
  * Is the compliance control unmapped?


* **Returning Guardrail Results:**
The triage action evaluates these rules and populates a text field (stored on the execution trail in `Agent_Run__c.Guardrails_Triggered__c`). If no safety rules are tripped, it returns `none fired`.
* **Human-in-the-Loop Gating:**
As seen in `BeaconAgentController`, if critical guardrails fire or confidence is low, the finding's status is set to `'Pending Approval'`, forcing a human analyst to explicitly say `"approve E-1002"` or `"reject E-1002"`.

---

### Audit Trail & Explanation (`"Why"` / `"Explain"`)

* **Execution Logging:** Every time `BeaconTriageAction` runs, it logs an `Agent_Run__c` record capturing the outcome, minutes saved, and which guardrails were triggered.
* **Explaining Past Decisions:** When a user asks `"why is E-1010 blocked"` or `"explain E-1002"`, the controller bypasses re-running a fresh triage action. Instead, it queries the most recent `Agent_Run__c` record (`SELECT Guardrails_Triggered__c FROM Agent_Run__c WHERE Finding__c = :f.Id ... ORDER BY CreatedDate DESC LIMIT 1`) to retrieve the exact guardrail history that caused the finding's current state.