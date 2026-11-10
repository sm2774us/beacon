# Salesforce FDE (Mid/Senior) — Final Round Playbook

## 1. Synopsis

**Format:** 45 min, 2:1 panel (1 leader + 1 FDE). 15 min = intro + walkthrough of one project (demo or whiteboard), remaining 30 min = Q&A.
**Competencies scored:** Influence Stakeholders · Drive Innovation & AI Readiness · Agility · Build & Deploy Technical Capabilities · Integration Platform & Ecosystem · AI Ecosystems & Frameworks.
**Round-1 feedback to fix:** (1) frame **ambiguity vs. uncertainty**; (2) tie every technical outcome to **business value / ROI**; (3) show **Agentforce + Salesforce-specific tooling** in forward-deployed work.

**The thesis you repeat in every answer:** *Salesforce is the system of engagement and governed action layer; the firm's existing stack (warehouse, GRC/ticketing, identity, streaming) remains the system of record. My job is the seam between them: data in (Data 360 / zero-copy), actions out (Apex/Flow/REST/MCP), trust throughout (Trust Layer, permission model, audit).*

| # | Use case | Role / firm | Years | Salesforce-ecosystem bridge | Answers best |
|---|----------|-------------|-------|-----------------------------|--------------|
| UC1 | Real-time B2B compliance decision engine + event-driven integration | Forward Deployed Systems & Integration Eng., Millburn Ridgefield | 2008–2022 | Platform Events / CDC / REST ↔ firm Kafka & warehouse; Data 360 ingestion | Q3 (disagree w/ sponsor), integration patterns, 100x volume |
| UC2 | Risk & operations exception-triage agent on GRC (ServiceNow/Archer) | Sr. FDE & AI Platform Architect, J.P. Morgan AM / Highbridge | 2022–2025 | Agentforce-pattern agent: Apex invocable actions, Named Credentials, zero-copy to Snowflake/BigQuery | Q1 (most challenging), prompt failure, hardening, governor limits |
| UC3 | GRC/SOC autonomous agent on Agentforce + Data 360 + Snowflake/Databricks, LWC console | Sr. FDE & Agentic AI Lead, Balyasny | 2025–present | Full Agentforce: Topics/Actions, Atlas (Claude), Prompt Builder, Testing Center, LWC, Data 360 | Q2 (most proud), Agentforce, testing, hallucination, security |

> ### ⚠️ Integrity check — do this before you memorize
> Interviewers (esp. the FDE) will probe two levels deep. Every claim below is written to be *plausible against your resume*, but **you must overwrite any detail that does not match what you personally did.** Tags used:
> - **[V]** = verify/replace with your real number, tool, or name.
> - **[PATTERN]** = you applied the *pattern* with a non-Salesforce tool; say so explicitly, then map to the Salesforce equivalent ("I built X with Kafka; in Salesforce that's Platform Events — here's the trade-off").
> - Timeline sanity: Agentforce/Vibes/Cursor/LLM-agents did not exist in 2008–2022. UC1 is therefore a **pattern story** (integration, eventing, decision engines), not an Agentforce story. Do not claim otherwise; the "Salesforce mapping" paragraphs are what you *would* do and what you know.
> - Resume says "Salesforce Vibes" — product is now branded **Agentforce Vibes**; use the current name.
> - "Claude 3.5" on resume is dated → say "Claude (current Sonnet/Opus-class models)".
> - An honest "I haven't done X, here's how I'd approach it and the first thing I'd check" scores higher than a bluff caught on follow-up.

---

## 2. Table of Contents

1. [Synopsis](#1-synopsis)
2. [Table of Contents](#2-table-of-contents)
3. [Three Use Cases (chronological)](#3-three-use-cases-chronological)
   - [UC1 — Millburn: Real-time compliance decision engine](#uc1--millburn-ridgefield-2008-2022-real-time-b2b-compliance-decision-engine)
   - [UC2 — J.P. Morgan AM / Highbridge: Exception-triage agent on GRC](#uc2--jp-morgan-am--highbridge-2022-2025-risk--ops-exception-triage-agent)
   - [UC3 — Balyasny: GRC/SOC agent on Agentforce + Data 360](#uc3--balyasny-2025present-grcsoc-agentic-platform-on-agentforce--data-360)
4. [Detailed Answers](#4-detailed-answers)
   - [Behavioral](#41-behavioral-q1q3) — [Q1](#q1-most-challenging-project-why-and-how-did-you-contribute) · [Q2](#q2-project-most-proud-of-and-your-role) · [Q3](#q3-how-do-you-disagree-with-a-sponsor-and-still-fulfil-requirements)
   - [Technical](#42-technical)
     - [Salesforce portfolio](#q-salesforce-product-portfolio-where-used-pros--cons) · [Apex actions](#q-explain-apex-actions-and-how-you-used-them) · [Agentforce](#q-explain-agentforce-and-how-you-used-it) · [LWC](#q-explain-lwc-and-how-you-used-it) · [Claudeforce](#q-claudeforce-what-is-it-and-where-would-you-use-it)
     - [Governor limits](#q-how-do-you-stay-inside-governor-limits) · [Security](#q-how-is-security-enforced) · [REST endpoint](#q-walk-me-through-a-rest-endpoint) · [Testing / golden set](#q-how-do-you-test-an-agent-golden-set) · [Hallucination](#q-how-do-you-mitigate-hallucination-and-non-determinism)
     - [Harden first](#q-what-would-you-harden-first) · [Data pipelines](#q-data-pipelines-to-snowflake-databricks-data-360) · [Integration patterns](#q-integration-patterns-you-would-choose-and-why) · [100x volume](#q-what-happens-at-100x-volume-and-how-to-mitigate) · [Prompt failed](#q-llm-prompt-failed-why-and-what-would-you-change)
5. [Bonus: 15-Minute Run-of-Show, Ambiguity vs. Uncertainty, ROI Formula](#5-bonus-15-minute-run-of-show-ambiguity-vs-uncertainty-roi-formula)

---

## 3. Three Use Cases (chronological)

### UC1 — Millburn Ridgefield (2008–2022): Real-time B2B compliance decision engine

**Tag:** [PATTERN] — pre-agentic; this is your *integration and decision-engine* credibility story.

**Situation.** Institutional partner accounts needed compliance/operational decisions (eligibility, limits, exceptions) from our data in near real time. Partners' systems were heterogeneous (batch files, REST, vendor portals). Decisions were being made by humans reading spreadsheets: slow, inconsistent, unauditable.

**Sponsor & stakeholders.** Business sponsor: head of partner operations/compliance [V]. Partner-side: their architects and compliance officers. Internal: platform team, sales engineering.

**What I built (architecture).**

```text
Partner systems ──REST/webhook/SFTP──► API gateway ─► Ingest svc (validate, idempotency key)
                                                        │
                                                   Kafka topics (raw → validated → decisions)
                                                        │
                                  ┌─────────────────────┼──────────────────────┐
                           Rules/ML decision svc   Warehouse (BigQuery/Snowflake)   Alerts/webhooks
                           (Python/Java; NLP+ML)     (model: partner, account,      back to partners
                                  │                   event, decision, audit)
                                  ▼
                       Decision + rationale + audit record ─► KPI dashboards (exec-level)
```

- Data model: `Partner → Account → Event → Decision → AuditRecord`; every decision stores inputs, rule/model version, rationale (explainability = compliance requirement).
- Interfaces: REST (sync lookups), webhooks (async partner callbacks, HMAC-signed, retry w/ exponential backoff + dead-letter), Kafka (internal fan-out), gRPC (internal low-latency calls).
- Reusable **Python/TypeScript SDK starter kits** distilled from recurring field patterns → shortened onboarding of new partner accounts [V: quantify].

**Salesforce-ecosystem mapping (say this explicitly).**

| What I built | Salesforce equivalent I'd use today | Why |
|---|---|---|
| Kafka decision topics | **Platform Events / Change Data Capture** (+ Pub/Sub API gRPC) | Native, replayable (72-hr replay), decouples Apex from external consumers |
| Partner REST/webhook ingress | **Apex REST** or External Services + **Named Credentials** for outbound | Governed auth, no secrets in code |
| Warehouse model | **Data 360** data model objects (DMOs) + **zero-copy** to Snowflake/BigQuery | One identity-resolved view without copying data |
| Decision/explainability record | **Custom object `Decision__c`** + Event Monitoring/Shield audit | Reportable, permissioned, auditable |
| Exec KPI dashboards | **CRM Analytics / Tableau** on Data 360 | Same KPIs inside the Salesforce workspace |

**Challenges & resolution.**
1. *Duplicate/out-of-order events from partners* → idempotency keys + event-time watermarking + upsert on natural key.
2. *Partner schema drift* → schema registry + contract tests; unknown fields quarantined, never dropped.
3. *Sponsor wanted a single "approve/deny" number* → disagreed (see Q3); delivered score **plus** reason codes **plus** human-review band.

**Outcome (replace with real numbers) [V].** Decision latency from hours → seconds; manual review volume −X%; onboarding of a new partner from weeks → days via SDK kit; zero audit findings on decision traceability.

**FDE signal to emphasize.** Onsite mapping of the partner's *actual* workflow (not the documented one), co-building integration components with their engineers, and feeding recurring patterns back into the internal platform roadmap — that is the forward-deployed loop.

---

### UC2 — J.P. Morgan AM / Highbridge (2022–2025): Risk & ops exception-triage agent

**Tag:** [PATTERN] for orchestration framework (LangChain/LlamaIndex, not Agentforce) → map to Agentforce explicitly; Apex/Salesforce portions are **[V]** against what you actually shipped.

**Situation.** Operations and risk teams drowned in exceptions (failed reconciliations, limit breaches, control-test failures) landing in GRC tools (ServiceNow, Archer). Analysts spent most of each exception gathering context across 5+ systems before deciding anything. Sponsor: Head of Risk Technology / COO of operations [V].

**Goal.** Cut time-to-triage and improve consistency without letting an LLM take unreviewed actions on regulated processes.

**What I built.**

```text
GRC exception (ServiceNow/Archer) ─webhook─► Orchestrator (LangChain/LlamaIndex, custom router)
        │                                         │
        │                         ┌───────────────┼─────────────────┐
        │                  Retrieval (hybrid RAG:   Tools (typed, allow-listed):       Policy engine
        │                  BM25 + vector over       get_position(), get_control(),     (hard rules before
        │                  policies/runbooks)       query_warehouse(), create_ticket() and after the LLM)
        │                                         │
        │                           Snowflake / BigQuery (read-only service role)
        ▼
  Draft triage (classification, evidence links, proposed action, confidence)
        │
  Human-in-the-loop gate (approve/edit/reject) ─► write-back to ticket ─► audit log + KPI dashboard
```

- **Prompt/Context engineering:** system prompt split into role, policy, tool contract, output JSON schema; retrieval chunk budget; tool routing by intent classifier first (cheap model) → reasoning model second.
- **Reliability: task-completion 99.2%** (resume figure) measured on a labeled golden set [V: define "completion" precisely — valid schema + correct tool + correct class].
- **Productionization:** containerized microservices on AWS EKS / Azure AKS, Helm, Terraform, GitHub Actions; **Architecture Decision Records** for every trade-off (e.g., ADR-007: *human gate on all write actions in v1*).

**Salesforce-ecosystem mapping.**

| Built | Agentforce/Salesforce equivalent |
|---|---|
| Orchestrator + router | **Agentforce Topics** (scope/instructions) + **Atlas Reasoning Engine** |
| Typed tool registry | **Agent Actions**: Apex invocable, Flow, Prompt Template, API (MuleSoft/External Services) |
| Policy engine around LLM | **Einstein Trust Layer** + Apex validation inside actions + permission-set-scoped agent user |
| Hybrid RAG on runbooks | **Data 360 Data Library / Search Index (hybrid)** grounding |
| Warehouse read | **Zero-copy federation** to Snowflake/BigQuery |
| HITL gate | **Flow approval step / Slack or Service Console escalation** |
| Golden-set eval | **Agentforce Testing Center** (batch tests) + custom judge harness |

**The most challenging part (feeds Q1).** The first pilot hit ~85% on the golden set but analysts distrusted it: the 15% failures were *confidently wrong on edge-case controls*, and one hallucinated a policy clause. Diagnosis: (a) retrieval returned superseded policy versions; (b) the prompt asked for a conclusion before evidence; (c) tool-argument errors (wrong entity IDs) on ambiguous exceptions. Fixes:
1. Policy corpus versioning + effective-date filter at retrieval → superseded-policy errors → ~0.
2. Re-ordered output schema: `evidence[] → reasoning → classification → action → confidence`, each evidence item must cite a retrieved doc ID; post-validator rejects uncited claims.
3. Tool arguments validated against enums/regex + entity existence check; failed validation → ask-clarifying-question branch instead of guessing.
4. Abstain path: confidence < threshold or policy-conflict → route to human with the evidence packet. Completion → **99.2%** on golden set, with the remaining cases *routed*, not guessed.

**Outcome [V].** Triage time per exception −X%; analyst throughput +Y%; zero unreviewed write actions; audit-ready with ADR trail.

**FDE signal.** Held the room with client enterprise architects over data-access boundaries; surfaced agent-framework gaps to product teams; documented trade-offs in ADRs so the client could own the system after hand-off.

---

### UC3 — Balyasny (2025–Present): GRC/SOC agentic platform on Agentforce + Data 360

**Tag:** Your **flagship / most proud / demo** story. Make this the 15-minute walkthrough. Reconcile every Salesforce-specific component with what you actually configured **[V]**; if a piece was a prototype/reference build (e.g., your GitHub repos), say "reference implementation" — that is allowed by the recruiter's brief ("GitHub repository you're proud of").

**Situation.** Governance, risk & compliance and SOC analysts triaged alerts and control exceptions across SIEM (Splunk), ticketing (Jira/ServiceNow), the data warehouse (Snowflake/Databricks), and Salesforce-hosted case/workflow records. Duplicated effort, inconsistent evidence, slow closure; leadership had no KPI view of agent/automation health. Sponsor: Head of Compliance Technology / CISO delegate [V]. Strategic partner: the Deployment Strategist, who owned adoption and exec alignment while I owned technical components.

**Business objective (ROI framing).** Reduce mean time to triage (MTTT) and analyst hours per case, with auditability. ROI = (hours saved × loaded rate + avoided incident cost) − (platform + build + run cost).

**Architecture (end-to-end).**

```text
 Splunk / SIEM ─┐                                    ┌─► Agentforce Agent (SOC/GRC Triage)
 ServiceNow/Jira ┤─► Kafka/Pub-Sub ─► Data 360 ──────┤     Topics: Alert Triage · Control Exception · Evidence Pack
 Snowflake ──────┤   (Ingestion API,   (DMOs, identity│     Atlas Reasoning (Claude) + Trust Layer
 Databricks ─────┘   streaming)        resolution,    │     Actions:
                                       zero-copy ◄────┘       • Apex invocable: CreateCase / UpdateCase / EnrichAlert (bulkified, USER_MODE)
                                       Snowflake/DBX)         • Flow: approval + escalation
                                                              • Prompt Template: evidence summary (grounded on Data 360)
                                                              • External Service/REST: Jira, ServiceNow write-back via Named Credential
                                                       ▼
                    Service Console + **LWC "Agent Evidence Panel"** (human review, accept/edit/reject, citations)
                                                       ▼
        Event log → Data 360 → CRM Analytics/Tableau dashboard (MTTT, deflection, accuracy, cost/case, escalation rate)
```

**Key technical decisions (and why).**
1. **Zero-copy vs. ingest:** zero-copy for large, slowly-changing warehouse tables (no duplicate governance); streaming ingest into Data 360 only for hot signals needed for real-time grounding. Trade-off: query latency/cost on the source vs. copy governance.
2. **Narrow Topics, deterministic actions:** each Topic has tight scope; every action is a deterministic Apex/Flow unit with its own tests — LLM *chooses*, code *does*.
3. **Agent runs as a dedicated integration user with a minimal permission set** (least privilege), `WITH USER_MODE` SOQL inside actions.
4. **Phased autonomy:** v1 read + draft only; v2 low-risk writes (tagging, enrichment); v3 gated writes (ticket creation) behind approval Flow. Surfaced as the "autonomy ladder" to the sponsor.
5. **Observability from day one:** every reasoning step, tool call, latency, token cost, and outcome logged to Data 360 → dashboard.
6. **Model:** Claude via Atlas Reasoning Engine / Agent Builder model selection; prompt templates versioned; evals run on every prompt/model change.

**Challenges.**
- *Ambiguous alerts → wrong topic routing* → added disambiguating topic descriptions + a "clarify" instruction; routing accuracy measured in golden set.
- *Governor limits in a bulk action* when agent fan-out triggered 200-record batches → bulkified, moved enrichment to Queueable, platform-event decoupling.
- *Non-determinism in summaries* → low temperature, structured outputs, grounded citations, post-validator.
- *Stakeholder tension* (compliance wanted full autonomy off; ops wanted full autonomy on) → autonomy ladder with measurable promotion criteria (precision ≥ X, zero critical misses over N cases) [V].

**Delivery speed.** PoC sketch → customer environment in **<5 days** (resume claim [V]); MVP behind approval gate; co-building workshops so client engineers own prompts/actions after hand-off.

**Outcome [V].** MTTT −X%; analyst hours/case −Y; escalation precision Z%; dashboard adopted by leadership; shipped ~**50% faster** using Cursor/Claude/Agentforce Vibes [V].

**Current state & ops.** Weekly eval run on golden set + shadow traffic; drift alerts on routing accuracy & hallucination rate; monthly prompt/action review; platform gaps (e.g., test tooling, trace granularity) logged to product team.

**Initial release vs. scale (explicitly asked in brief).**
| Initial release | Scaling |
|---|---|
| Narrow topics, read/draft only, HITL on all writes | Autonomy ladder, per-action risk tiers |
| Single-region, synchronous actions | Async (Queueable/Platform Events), caching, rate limits |
| Manual golden set | CI-gated evals, adversarial/regression sets, cost budgets |
| Basic dashboard | Tenant-level SLOs, cost/case, on-call runbooks |

---

## 4. Detailed Answers

> **Delivery rule:** *Context (1 line) → Decision → Trade-off → Outcome with a number → Business value.* Always end with the business metric.

### 4.1 Behavioral (Q1–Q3)

#### Q1) Most challenging project, why, and how did you contribute?

**Pick: UC2 (J.P. Morgan AM / Highbridge exception-triage agent).**

> "The hardest was an exception-triage agent for risk and operations at Highbridge. Hard for three reasons: the domain was regulated, the first pilot was *confidently wrong* in a way that destroyed analyst trust, and the sponsor wanted autonomy that compliance couldn't accept.
> **My contribution:** I owned the agent architecture and eval strategy. I diagnosed the 15% failure set into three root causes — stale policy retrieval, conclusion-before-evidence prompting, and tool-argument errors — and fixed each structurally: versioned retrieval, evidence-first schema with citation validation, typed tool arguments with an abstain-and-route path. Completion on the golden set went to 99.2%, and the remaining cases were routed to humans rather than guessed.
> **Business value:** analysts trusted it because it showed evidence and abstained when unsure; triage time dropped [X%], and we stayed audit-ready via ADRs. The lesson: reliability is a *product* property — evals, abstention, and observability, not a better prompt."

**Follow-ups to be ready for:** *Why not just a bigger model?* (didn't fix retrieval/versioning; cost; latency) · *How did you know the root causes?* (error taxonomy over 200+ labeled failures [V]) · *What would you do differently?* (start the golden set before the first prototype).

#### Q2) Project most proud of and your role

**Pick: UC3 (Balyasny GRC/SOC agentic platform).**

> "Most proud: the GRC/SOC triage platform on Agentforce and Data 360. I was the Senior FDE and technical lead, paired with a Deployment Strategist. She owned executive alignment and adoption; I owned architecture and the deployed components — Data 360 grounding with zero-copy to Snowflake/Databricks, the Apex and Flow actions, the Topics and prompt templates, the LWC evidence panel, and the KPI dashboard.
> What I'm proud of isn't just that it works; it's *how it shipped*: PoC in under five days, an autonomy ladder that let compliance and operations both say yes, and a co-building model so the client team could own it afterward. The outcome was [X%] faster triage with a full audit trail, and platform feedback we sent back to the product team."

**Role statement (memorize):** "I own the technical components end-to-end — architecture choice to deployed, validated, observable — while the Strategist shapes adoption."

#### Q3) How do you disagree with a sponsor and still fulfil requirements?

**Use story: UC1 (single approve/deny number) with UC3 echo (autonomy).**

**Framework — "Align, Evidence, Options, Commit":**
1. **Align on the outcome**, not the solution: "The goal is faster, defensible decisions, correct?"
2. **Bring evidence** (data, a 1-day spike, a failure example) instead of opinion.
3. **Offer 2–3 options** that each satisfy the underlying requirement, with cost/risk/time; recommend one.
4. **Disagree-and-commit** if they choose otherwise — but *instrument the risk* (metrics + trigger to revisit) and document in an ADR.
5. **Surface deviations early** (brief language): flag as soon as a requirement conflicts with architecture/limits; never at demo day.

> "At Millburn, the sponsor wanted one approve/deny output per partner request. Literally building that would have hidden borderline cases and failed audit. I didn't say no — I said, 'To make this defensible, can I show you what happens on the 8% borderline cases?' I replayed historical data, showed the exposure, then offered three options: single number; number plus reason codes; number plus reason codes plus a human-review band. We shipped option three, still delivering the single-number API they asked for, with extra fields optional. Outcome: audit passed without findings and review volume dropped [X%]."

**With Salesforce flavor:** "If a sponsor says 'agent writes directly to production Cases day one,' I'd agree to the goal (deflection), show the failure modes from the golden set, and propose the autonomy ladder: draft → low-risk writes → gated writes, with promotion criteria. Same requirement, staged risk."

---

### 4.2 Technical

#### Q: Salesforce product portfolio — where used, pros & cons

| Product | Where (UC) | Advantage | Disadvantage / watch-out |
|---|---|---|---|
| **Agentforce** (Agent Builder, Topics, Actions, Atlas Reasoning, Testing Center, Vibes) | UC3 (UC2 pattern) | Governed agents on CRM data/actions; low time-to-first-agent; Trust Layer | Opinionated; topic/action design discipline needed; non-determinism still yours to evaluate; test tooling evolving |
| **Data 360 (Data Cloud)** | UC3 (UC1 pattern) | Identity resolution, zero-copy to Snowflake/Databricks/BigQuery, grounding for agents | Consumption-based cost; modeling (DMO mapping) effort; latency tiers differ by source |
| **Apex** | UC3 (UC2 equivalent) | Deterministic actions, transactional, testable | Governor limits; 75% coverage; not for heavy compute |
| **Flow** | UC3 | Fast admin-owned automation, approvals | Hard to version/test at scale; bulk pitfalls; avoid logic sprawl |
| **LWC** | UC3 | Fast native UI; Lightning Data Service; Jest | Learning curve; Lightning Web Security constraints |
| **Platform Events / CDC / Pub/Sub API** | UC1 mapping, UC3 | Decoupled, replayable eventing | Delivery/allocation limits; at-least-once semantics → idempotency needed |
| **MuleSoft / External Services / Named Credentials** | UC2/UC3 | Governed outbound integration, secret mgmt | MuleSoft is another platform/cost; External Services need clean OpenAPI |
| **Service Cloud / Case mgmt** | UC3 | Workflow + audit for human review | Customization debt |
| **Slack** | UC3 (escalation) | Human-in-the-loop where analysts live | Channel sprawl; permissions mapping |
| **CRM Analytics / Tableau** | UC3 dashboards | KPIs next to work | Licensing; dataset refresh design |
| **Shield / Event Monitoring** | UC3 audit | Field audit, encryption, event logs | Added cost; retention planning |
| **Claudeforce / Claude in Agentforce** | UC3 model choice | Strong reasoning/tool use, default for Vibes/Coworker | Newer partnership surface; validate on your own evals |

**One-liner:** "Salesforce wins where the work already lives in CRM and needs governed action; I pair it with the firm's warehouse and streaming rather than replacing them."

#### Q: Explain Apex actions and how you used them

**Definition.** An Apex **agent/invocable action** is an Apex method annotated `@InvocableMethod` (with `@InvocableVariable` input/output wrapper classes) that Flow, Agentforce Agent Builder, and Prompt Builder can call. Agent actions come in types: **Apex, Flow, Prompt Template, API/MuleSoft/External Service**, and standard actions. The agent's reasoning layer selects an action from its **descriptions**, so label/description quality is functional, not cosmetic.

```apex
public with sharing class EnrichAlertAction {
  public class Req {
    @InvocableVariable(label='Case Id' description='Salesforce Case Id of the alert' required=true)
    public Id caseId;
    @InvocableVariable(label='Source System' description='SIEM or GRC system name')
    public String sourceSystem;
  }
  public class Res {
    @InvocableVariable(description='Enrichment summary with source citations')
    public String summary;
    @InvocableVariable(description='SUCCESS, PARTIAL, or FAILED')
    public String status;
  }

  @InvocableMethod(label='Enrich Alert' description='Adds asset/owner/context to a security or GRC case')
  public static List<Res> run(List<Req> reqs) {                  // bulk-safe signature
    Set<Id> ids = new Set<Id>();
    for (Req r : reqs) ids.add(r.caseId);
    Map<Id, Case> cases = new Map<Id, Case>(
      [SELECT Id, Subject, AccountId FROM Case WHERE Id IN :ids WITH USER_MODE]); // one SOQL, FLS/CRUD enforced
    List<Res> out = new List<Res>();
    for (Req r : reqs) {
      Res res = new Res();
      Case c = cases.get(r.caseId);
      if (c == null) { res.status = 'FAILED'; res.summary = 'Case not found/accessible'; }
      else { res.status = 'SUCCESS'; res.summary = EnrichmentService.build(c); }  // callouts via Queueable if >limits
      out.add(res);
    }
    return out;
  }
}
```

**How I used them (concrete).**
- **UC3:** `EnrichAlert`, `CreateCase`, `UpdateCaseStatus`, `WriteBackToJira` (Named Credential callout). Each has Apex tests (positive, negative, bulk 200, permission-denied via `System.runAs`).
- **UC2 [PATTERN]:** same idea as typed Python tools in the orchestrator (`get_position()`, `create_ticket()`); mapped one-to-one to Apex actions in the Salesforce design.
- **Design rules:** one action = one verb; narrow inputs; deterministic outputs; idempotent write actions (external-ID upsert); descriptive input/output names so the model routes correctly.

**Advantages:** deterministic, transactional, governed by sharing & permissions, unit-testable. **Disadvantages:** limits, callouts not allowed after uncommitted DML in the same transaction (use Queueable), deployment coupling.

#### Q: Explain Agentforce and how you used it

**Definition.** Agentforce is Salesforce's platform for building and deploying autonomous AI agents grounded in CRM/Data 360 data and executing governed actions. Core concepts:
- **Agent** = role + **Topics** (scope/classification of jobs-to-be-done, with instructions) + **Actions** (what it can do) + **Guardrails**.
- **Atlas Reasoning Engine**: plans, selects topic/action, calls tools, evaluates results, iterates; model-selectable (Claude available as a reasoning model).
- **Einstein Trust Layer**: PII masking, zero-data-retention with model providers, toxicity detection, audit trail, secure grounding.
- **Grounding**: Data 360 (incl. zero-copy), Knowledge, Data Library/search index; **Prompt Builder** templates merge fields + retrieval.
- **Channels/surfaces**: Service Console, Slack, Experience Cloud, messaging, API (headless).
- **Lifecycle**: Agent Builder → **Testing Center** (batch tests) → sandbox → deploy → monitor (Agentforce analytics/observability).
- **Agentforce Vibes / Coworker**: AI-assisted development/work surfaces.

**How I used it (UC3).**
1. Defined 3 Topics: *Alert Triage*, *Control Exception*, *Evidence Pack* — each with scope, "do not" instructions, and clarify-before-act rule.
2. Mapped Actions: Apex (enrich/create/update), Flow (approval/escalation), Prompt Template (evidence summary grounded on Data 360), External Service (Jira/ServiceNow).
3. Grounded via Data 360 with zero-copy to Snowflake/Databricks, hybrid search index for runbooks.
4. Tested via Testing Center on golden set; promoted via autonomy ladder.
5. Shipped LWC evidence panel + KPI dashboard; logged traces to Data 360.

**What I'd say about gaps (product feedback loop):** trace granularity for step-level debugging; richer assertion types for tests; clearer cost-per-conversation attribution.

#### Q: Explain LWC and how you used it

**Definition.** Lightning Web Components: standards-based (Web Components, ES modules) UI framework on Salesforce. Reactive via decorators `@api` (public), `@wire` (declarative data via Lightning Data Service/Apex), tracked fields reactive by default; communicates with parents via **events**, siblings via **Lightning Message Service**; tested with **Jest**.

```javascript
// agentEvidencePanel.js
import { LightningElement, api, wire } from 'lwc';
import getEvidence from '@salesforce/apex/EvidenceController.getEvidence';
import submitDecision from '@salesforce/apex/EvidenceController.submitDecision';

export default class AgentEvidencePanel extends LightningElement {
  @api recordId;
  decision;
  @wire(getEvidence, { caseId: '$recordId' }) evidence;      // cacheable=true Apex, auto-refresh on change

  async handleDecision(e) {
    try {
      await submitDecision({ caseId: this.recordId, action: e.target.dataset.action });
      this.dispatchEvent(new CustomEvent('decided', { detail: e.target.dataset.action }));
    } catch (err) { /* surface via toast, never swallow */ }
  }
}
```

**Use (UC3).** "Agent Evidence Panel": shows the agent's proposed classification, **citations to evidence**, confidence, and Accept / Edit / Reject buttons that write the human decision back (feeds the golden set — human corrections become labeled data). **Why LWC:** native context, FLS/CRUD via Apex `with sharing` controllers, no external front-end hosting. **Trade-off:** more constrained than a free-standing React app (Lightning Web Security, limited libs), but zero extra auth surface. For a rich external app I used React/TypeScript and the same APIs [PATTERN, UC1/UC2 dashboards].

#### Q: "Claudeforce" — what is it and where would you use it?

**What it is (announced 26 Aug 2026).** The expanded Salesforce–Anthropic strategic partnership with two halves:
1. **Claude inside Salesforce:** Claude is a reasoning model for the **Atlas Reasoning Engine**, the default for **Agentforce Vibes** and **Agentforce Coworker**, selectable in **Agent Builder**; also default for Slack AI/Slackbot and Claude Code across Salesforce engineering.
2. **Salesforce inside Claude:** a **"Salesforce in Claude"** plugin (launched with 37 prebuilt sales skills) that lets users work with Salesforce data/actions from Claude, governed by existing permissions and business rules; pilot customers first, open beta slated for September 2026 per coverage.
- Context: Claude has been a foundation model in Agentforce since late 2025; Claudeforce is the commercial/product packaging.
- **Distinction to state:** *Agentforce* = platform to **build and deploy** custom agents on your data/actions/processes; *Salesforce in Claude* = out-of-the-box way to **work with Salesforce from inside Claude**. They can overlap technically (Agentforce can use Claude as its reasoning model) but are not the same thing. (Verify latest GA status before the interview — it is evolving.)

**Where I'd use it.**
- **Reasoning model choice in Agent Builder** for tool-heavy, multi-step topics (UC3 triage) — A/B against other models on the same golden set; choose on accuracy, latency, cost.
- **Agentforce Vibes** for FDE speed: Apex/LWC scaffolding, test generation, refactors (my "50% faster" lever).
- **Salesforce in Claude** for analyst/sales-facing ad-hoc work: account research, pipeline Q&A — keeping heavy governed workflows in Agentforce.
- **MCP**: expose firm systems (warehouse, GRC) to Claude/agents through governed MCP servers.
- **Caveat I'd raise with a customer:** model-agnostic is a feature; I'd keep model choice behind configuration and evals, not hard-wired.

#### Q: How do you stay inside governor limits?

**Key synchronous limits (memorize):** 100 SOQL queries · 50,000 rows retrieved · 150 DML statements · 10,000 DML rows · 10 s CPU · 6 MB heap · 100 callouts (120 s max each, 120 s cumulative per transaction... callout timeout max 120 s) · 50 `@future` calls · 100 Queueable adds. **Async:** 200 SOQL · 60 s CPU · 12 MB heap. *(Verify exact values against current docs; the principles matter more.)*

**Principles (say them in this order).**
1. **Bulkify:** no SOQL/DML in loops; collect IDs → single query → `Map<Id, SObject>` → single DML.
2. **Selective queries:** indexed filters, `LIMIT`, field lists; custom indexes/skinny tables for large objects.
3. **Offload to async:** Queueable (chaining, callouts), Batch Apex (up to millions of rows, scope 200), Platform Events for decoupling.
4. **Avoid recursion:** static guard flags; one trigger per object + handler framework.
5. **Callouts:** after-DML callout restriction → Queueable; use Named Credentials; set timeouts; cache.
6. **Test for limits:** bulk tests of 200 (and 10,000 for batches); `Limits.getQueries()` assertions; `Test.startTest/stopTest` for async.
7. **Declarative-first:** Flow for simple automation, Apex for heavy logic.
8. **Agent-specific:** an agent can invoke actions repeatedly → rate-limit and idempotency inside actions; coarse-grained actions (batch enrich) over chatty ones.

> **Story (UC3):** agent fan-out invoked `EnrichAlert` for 200 cases; original version did a SOQL per case → limit exceptions. Rewrote to single `IN :ids` query with `Map`, moved external enrichment to Queueable with Platform Event completion signal; added a 200-record bulk test and a `Limits` assertion in CI.

#### Q: How is security enforced?

**Layers (outside-in).**
- **Identity & access:** SSO (SAML/OIDC); OAuth 2.0 for APIs — **JWT Bearer** for server-to-server, **Authorization Code + PKCE** for users; **External Client Apps / Connected Apps** with scoped OAuth, IP restrictions, rotating certs.
- **Authorization model:** profiles → **permission sets/groups** (least privilege), org-wide defaults + **sharing rules/role hierarchy**; **Restriction/Scoping rules** where needed.
- **Code-level:** `with sharing`, `WITH USER_MODE` / `WITH SECURITY_ENFORCED`, `Security.stripInaccessible`, **CRUD/FLS** checks; bind variables (no SOQL injection); Lightning Web Security for LWC.
- **Secrets & callouts:** **Named Credentials** (no secrets in code), External Credentials per-principal.
- **Data protection:** **Shield Platform Encryption**, field audit trail, Event Monitoring, masking in sandboxes.
- **AI-specific:** **Einstein Trust Layer** (masking PII before LLM, zero retention, toxicity filters, audit); agent runs as a **dedicated agent/integration user with minimal permission set**; action-level allow-list; prompt-injection defenses (treat retrieved text as data, strip/flag instructions, validate tool args server-side).
- **Network:** Private Connect/IP allow-lists to Snowflake/Databricks; mTLS for partner links.
- **Governance:** ADRs, change management, audit logs reviewed.

> **Principle:** "The LLM is never the security boundary. Enforcement lives in permissions and action code."

#### Q: Walk me through a REST endpoint

**Apex REST (inbound) — example: partner alert ingestion (UC1 pattern, UC3 production).**

```apex
@RestResource(urlMapping='/v1/alerts/*')
global with sharing class AlertApi {
  global class AlertReq { public String externalId; public String source; public String severity; public String payload; }

  @HttpPost
  global static void create() {
    RestResponse res = RestContext.response;
    try {
      AlertReq req = (AlertReq) JSON.deserialize(RestContext.request.requestBody.toString(), AlertReq.class);
      if (String.isBlank(req.externalId)) { res.statusCode = 400; res.responseBody = Blob.valueOf('{"error":"externalId required"}'); return; }
      Case c = new Case(Subject = req.source + ' alert', External_Id__c = req.externalId, Priority = req.severity);
      Database.UpsertResult ur = Database.upsert(c, Case.External_Id__c, true);   // idempotent
      res.statusCode = ur.isCreated() ? 201 : 200;
      res.responseBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{ 'id' => c.Id }));
    } catch (Exception e) { res.statusCode = 500; res.responseBody = Blob.valueOf('{"error":"internal"}'); /* log, no stack leak */ }
  }
}
```

**Walkthrough order.** (1) **Auth:** caller gets OAuth token (JWT bearer) for an integration user with a narrow permission set → `Authorization: Bearer`. (2) **Route:** `/services/apexrest/v1/alerts`. (3) **Validate** schema → 400. (4) **Idempotent upsert** on external ID → 200/201 (retries safe). (5) **Limits:** bulk variant accepts arrays; for heavy work publish a Platform Event and process async. (6) **Errors:** consistent codes + correlation ID; never leak internals. (7) **Versioning:** `/v1`. (8) **Observability:** log request ID, latency, outcome. (9) **Rate limiting:** API limits per 24 h — back-pressure with queue at the caller.

**Alternatives to name:** Standard REST/Composite API for CRUD/bulk, **Bulk API 2.0** for large loads, **Pub/Sub API (gRPC)** for streaming, **Data 360 Ingestion API** for streaming/bulk into Data 360. **Outbound:** Apex callout via Named Credential or External Service.

#### Q: How do you test an agent (golden set)?

**Golden set = versioned, labeled test suite of realistic inputs with expected outcomes.**

1. **Build it:** 150–300 cases [V] from real, de-identified tickets, stratified: happy paths (50%), edge/ambiguous (25%), adversarial/prompt-injection (10%), out-of-scope/should-abstain (15%). Domain experts label.
2. **Label what matters:** expected **topic**, expected **action(s) & arguments**, expected **final classification**, must-cite evidence IDs, and **must-not** actions.
3. **Metrics:** topic-routing accuracy · action-selection precision/recall · argument correctness · groundedness (claims supported by retrieved docs) · hallucination rate · abstention correctness · latency · tokens/cost. Gate: no critical misses; thresholds per metric.
4. **Methods:** deterministic assertions first (schema, tool call, IDs); **LLM-as-judge** only for semantic quality, calibrated against human labels (agreement ≥ target); multiple runs per case (e.g., n=5) to measure variance.
5. **Tooling:** **Agentforce Testing Center** for batch/regression on topics & actions; custom Python harness for judge metrics and CI.
6. **Process:** run on every prompt/model/action change in CI; **shadow mode** on live traffic; production failures become new golden cases (closed loop; LWC human edits feed this).

```python
def evaluate(cases: list[dict], run_agent, n_runs: int = 5) -> dict:
    """Runs a golden set against an agent and returns aggregate metrics.

    Args:
        cases: Labeled cases with keys `input`, `expected_topic`, `expected_actions`.
        run_agent: Callable that returns a dict with `topic` and `actions`.
        n_runs: Repeats per case to estimate non-determinism.

    Returns:
        Dict with routing accuracy and a stability score (share of cases whose
        outcome is identical across all runs).
    """
    correct, stable = 0, 0
    for c in cases:
        outs = [run_agent(c["input"]) for _ in range(n_runs)]
        correct += sum(o["topic"] == c["expected_topic"] for o in outs) / n_runs
        stable += len({(o["topic"], tuple(o["actions"])) for o in outs}) == 1
    return {"routing_accuracy": correct / len(cases), "stability": stable / len(cases)}
```

*Plain-English readout:* routing accuracy = on average, how often the agent picks the right topic; stability = share of cases where the agent does the exact same thing every time. **UC2 tie-in:** 99.2% completion was measured exactly this way; **UC3:** Testing Center + harness.

#### Q: How do you mitigate hallucination and non-determinism?

**Hallucination (make the model unable to be wrong without being caught).**
1. **Ground** with retrieval (Data 360 hybrid search / versioned policy corpus), prefer *effective-dated* sources.
2. **Evidence-first structured output** (JSON schema): `evidence[] → reasoning → answer`; every claim must cite a doc ID.
3. **Post-validation:** server-side check that citations exist and support the claim; reject/route otherwise.
4. **Abstain path:** explicit "insufficient evidence" outcome + escalation to human.
5. **Constrain actions:** typed args, enums, existence checks; LLM *selects*, code *executes*.
6. **Trust Layer** + toxicity/PII filters; **instruction hierarchy** vs. prompt injection.

**Non-determinism.**
1. Low temperature/top-p for decisioning steps; keep creativity for summaries only.
2. Decompose into **small, single-purpose prompts**; deterministic code between steps.
3. **Idempotent actions** so retries/repeats are safe.
4. **Evals with repeated runs** to quantify variance; treat variance as a metric with a threshold.
5. **Version-pin** model and prompt; canary on model changes.
6. **Consensus/self-check** for high-risk steps (second pass or judge) — budgeted by risk tier.
7. **Human gate** on irreversible actions.

> **Message:** "I don't try to eliminate non-determinism; I bound it — by structure, validation, and blast-radius control."

#### Q: What would you harden first?

**Order (risk × likelihood):**
1. **Write-action safety:** least-privilege agent user, approval gates on irreversible actions, idempotency keys, kill switch/feature flag. *(Biggest blast radius.)*
2. **Prompt-injection & data-leak paths:** treat retrieved/ticket text as untrusted; server-side arg validation; output filtering; no secrets in context.
3. **Observability:** end-to-end traces (topic → action → latency → cost → outcome), alerting on routing accuracy, hallucination rate, error rate, cost per case.
4. **Eval regression in CI** — block deploys that drop golden-set metrics.
5. **Limits & resilience:** bulkification, async decoupling, retries with backoff, dead-letter queue, circuit breakers on external systems.
6. **Data governance:** PII masking, retention, audit trail, field-level encryption.
7. **Runbooks & ownership:** on-call, rollback of prompts/actions, ADRs.

> **Why this order:** "Anything that can act wrongly at scale comes before anything that can answer wrongly — and I need observability before I can trust any other fix."

#### Q: Data pipelines to Snowflake, Databricks, Data 360

**Principles:** decide *copy vs. federate* per dataset by freshness, size, governance, and cost.

| Need | Pattern | Mechanics |
|---|---|---|
| Large, slowly-changing warehouse tables used for grounding/segmentation | **Zero-copy (federation/data sharing)** Data 360 ↔ Snowflake / Databricks (Delta sharing / Unity Catalog) / BigQuery | No ETL, single governance, query-time latency; watch source compute cost |
| Hot operational signals (alerts, events) | **Streaming ingest** → Data 360 **Ingestion API (streaming)** or Kafka/Connector | Micro-batch (~minutes) latency; schema & dedupe up front |
| Bulk/historical loads | **Bulk ingestion** (Ingestion API bulk, S3/cloud storage connector, Bulk API 2.0 for CRM) | Idempotent, partitioned loads |
| Write-back of agent outcomes/KPIs to warehouse | **Data 360 data actions / data share out** or Platform Events → warehouse | Closes the loop for BI |
| CRM-originated changes to downstream | **CDC → Pub/Sub API → Kafka/Snowpipe/Auto Loader** | Replay by ReplayId; at-least-once → dedupe |

**Pipeline discipline ("model the data, ship the pipeline, validate the output").**
1. **Model first:** map sources → **DMOs** with explicit keys; identity resolution rules; ontology-first naming (reference repos).
2. **Contracts & schema drift:** schema registry/contract tests; quarantine unknowns.
3. **Idempotency & dedupe:** natural/external keys; event-time + watermark.
4. **Validation:** row-count reconciliation, null/range checks, freshness SLAs, sample audit; alert on breach.
5. **Lineage & access:** least-privilege service roles (read-only for grounding), masking.
6. **Cost:** federate big, copy small; partition pruning; cache.

**Where I did it:** UC1 (Kafka → BigQuery/Snowflake decision model) [PATTERN]; UC2 (Snowflake/BigQuery read-only tools for the agent); UC3 (Snowflake/Databricks zero-copy + streaming alerts into Data 360).

#### Q: Integration patterns you would choose and why

| Scenario | Pattern | Why | Salesforce mechanism |
|---|---|---|---|
| User needs an answer now (lookup) | **Request/Reply (sync API)** | Simple, immediate | Apex REST / callout via Named Credential |
| Fire-and-forget updates, spiky load | **Fire-and-Forget / Event-driven** | Decouples, absorbs bursts | **Platform Events**, Pub/Sub API, Kafka |
| Keep systems in sync with changes | **Change Data Capture** | No polling; replay | **CDC** + consumer upsert |
| Large nightly/bulk | **Batch** | Throughput, cost | **Bulk API 2.0**, Batch Apex |
| Need data but not ownership | **Data virtualization / zero-copy** | No duplication/governance drift | **Data 360 zero-copy**, External Objects |
| Multi-step with compensations | **Saga / orchestration** | Failure handling | Flow orchestration + Platform Events + compensating actions |
| Many systems, shared policies | **API-led (MuleSoft)** | Reuse, central policy | MuleSoft / API gateway |
| Agent needs tools | **Tool/Action contract (MCP/OpenAPI)** | Typed, governed | Agent Actions, External Services, MCP |
| Partner callbacks | **Webhooks** | Push, near-real-time | Apex REST receiver + signature check |

**Selection heuristics (say this):** "Sync only when a human or agent is waiting; async everywhere else. Own data where it's mastered; federate the rest. Always design for at-least-once delivery → idempotent consumers, dead-letter, replay."

#### Q: What happens at 100x volume and how to mitigate?

*Example baseline:* 10k events/day → 1M/day (≈ 12 events/s average, **peaks 10–50× average**) [V baseline].

**Capacity readout.** Required throughput ≈ $\text{rate} = \frac{N_{\text{events}}}{86{,}400}\times \text{peak factor}$.
*Plain English:* take daily volume, convert to events per second, then multiply by how spiky your traffic is — size for the spike, not the average.

**What breaks, in order, and mitigation.**
| Layer | Failure at 100x | Mitigation |
|---|---|---|
| Salesforce API/limits | Daily API request cap, row-lock contention, per-transaction limits | Switch row-by-row calls → **Bulk API 2.0 / composite**; batch & coalesce; **Platform Events** for decoupling; async Queueable/Batch; sharding by parent to avoid lock contention |
| Ingress/APIs | Timeouts, thundering herd | Queue-first (Kafka), back-pressure, rate limits, autoscaling, idempotent retries with jitter |
| Data 360 | Ingestion/processing cost & latency | Filter at source, aggregate before ingest, tier hot vs cold, zero-copy for cold |
| Warehouse | Query cost/concurrency | Partitioning/clustering, materialized aggregates, caching, workload isolation |
| LLM layer | Token cost, rate limits (TPM/RPM), latency | **Triage with deterministic rules first**; small model for routing, big model for hard cases; response/semantic caching; batching; prompt compression; per-tenant budgets; fallback model |
| Agent actions | Chatty tool calls | Coarse-grained actions, memoization, circuit breakers |
| Humans | Review queue explodes | Risk-tiering + abstention thresholds + auto-close of low-risk; SLA dashboards |
| Ops | Blind spots | SLOs, saturation dashboards, load tests, cost-per-case alarms, runbooks |

**Approach:** load-test to 10× → 100× in staging with production-shaped data; find the first bottleneck; fix; repeat. **Message:** "The first thing that breaks at 100× is almost never the model — it's limits, locks, and the human queue; the first thing that gets expensive *is* the model."

#### Q: LLM prompt failed — why and what would you change?

**Diagnostic protocol (say it as a sequence).**
1. **Reproduce** with logged inputs, context, tool traces, model/version, temperature.
2. **Classify the failure:** (a) *retrieval* (wrong/stale/missing context), (b) *instruction* (ambiguous, conflicting, buried), (c) *format* (schema not enforced), (d) *tool* (wrong tool/args), (e) *reasoning* (needs decomposition), (f) *model/variance* (works n/5), (g) *injection/adversarial*.
3. **Isolate:** ablate one variable at a time (context off, prompt simplified, model swapped) — change one thing per experiment.
4. **Fix at the right layer:** retrieval fix before prompt fix; code validation before "add more instructions."
5. **Regress:** add the failure to the golden set; run full suite before shipping.

**Concrete case (UC2).** *Failure:* agent classified a control exception as "low risk" and cited a policy clause that didn't exist. *Why:* retrieval returned a superseded policy; prompt asked for a verdict first, so the model rationalized; no citation check. *Changes:* (1) effective-date filtered retrieval; (2) evidence-first schema `evidence → reasoning → classification`; (3) citation validator; (4) explicit rule "if evidence insufficient, return `needs_human`"; (5) 3 few-shot examples including a near-miss; (6) lowered temperature. *Result:* failure class eliminated on golden set; completion → 99.2%.

**Concrete case (UC3, Salesforce flavor).** *Failure:* agent picked *Alert Triage* instead of *Control Exception*. *Why:* overlapping Topic descriptions. *Change:* sharpened Topic scope with explicit inclusions/exclusions, added a clarifying-question instruction, renamed actions to verb-object with precise descriptions; measured routing accuracy before/after in Testing Center.

---

## 5. Bonus: 15-Minute Run-of-Show, Ambiguity vs. Uncertainty, ROI Formula

### 5.1 15-minute walkthrough (UC3) — timing

| Min | Segment | Must-say |
|---|---|---|
| 0:00–1:30 | **Intro** | "17+ years building production systems at the buy-side; last 3 as forward-deployed engineer. I sit between Salesforce's platform and the firm's wider tech stack." |
| 1:30–3:00 | **Problem & sponsor** | Pain, KPI (MTTT, hours/case), sponsor + Strategist roles, success criteria agreed in week 1 |
| 3:00–6:30 | **Architecture (whiteboard/diagram)** | Data in (Data 360, zero-copy) → Agent (Topics/Actions/Atlas/Trust Layer) → Actions out (Apex/Flow/REST) → Human (LWC) → KPIs |
| 6:30–8:30 | **Key decisions** | Zero-copy vs ingest; deterministic actions; least-privilege; autonomy ladder; **surfacing deviations early** (ADR + weekly risk log) |
| 8:30–10:30 | **Demo** (or steps) | One alert → triage → evidence → human accepts → write-back → dashboard tick |
| 10:30–12:30 | **Challenges & collaboration** | Governor-limit bulk fix; routing ambiguity; compliance-vs-ops tension |
| 12:30–14:30 | **Deployment, impact, current state** | <5-day PoC, phased release vs. scale table, MTTT −X%, monitoring/evals |
| 14:30–15:00 | **Close** | Tools used (Cursor, Claude, Agentforce Vibes), lessons, product feedback sent |

**Fallback if the demo isn't live:** narrate the creation steps on the whiteboard in the same order; show screenshots/repo (GitHub: `agentic-platform`, `enterprise-ai-agent-architecture`) as a reference implementation and say so.

### 5.2 Ambiguity vs. uncertainty (Round-1 feedback)

| | **Ambiguity** | **Uncertainty** |
|---|---|---|
| Meaning | The requirement can be read **multiple ways** (unclear *what*) | The requirement is clear but the **outcome/feasibility is unknown** (unclear *whether/how much*) |
| Example | "Agent should handle compliance alerts" — which alerts? which actions? | "Agent should auto-close low-risk alerts" — will accuracy reach 98%? Will latency fit? |
| Resolve by | **Asking / clarifying / defining** — workshops, examples, acceptance criteria, glossary | **Experimenting / measuring / de-risking** — spike, PoC, golden-set, shadow mode, phased rollout |
| Owner | Sponsor + Strategist (decide meaning) | FDE (reduce through evidence) |
| Say it as | "First I separate what's *unclear* from what's *unknown*. Unclear I clarify with the sponsor; unknown I de-risk with an experiment and a decision date." | |

**Surfacing deviations early:** maintain a one-page *assumptions & deviations log* (assumption → evidence → impact → decision owner → date), reviewed weekly with the Strategist; any divergence between sponsor intent and architecture constraints (limits, data latency, model accuracy) is raised within 48 hours with options.

### 5.3 ROI — always close with this

$$\text{ROI} = \frac{(H_{\text{saved}} \times C_{\text{hour}}) + V_{\text{risk avoided}} - C_{\text{total}}}{C_{\text{total}}}$$

*Plain English:* value of analyst hours you saved, plus the cost of bad outcomes you prevented, minus everything you spent building and running it — divided by what you spent. Report **payback period** (months to break even) alongside it.

**Technical → business translation lines:**
- "Zero-copy meant no duplicate pipeline to govern — **lower run cost and faster time-to-value**."
- "Golden-set gating meant **fewer production incidents → sponsor confidence → faster autonomy promotion**."
- "Autonomy ladder meant **compliance said yes sooner**, so value started in week 1, not month 6."
- "Co-building meant the client team **owned it post-engagement — lower dependency on us, stronger retention**."

### 5.4 Closing question bank (ask them)
1. "How does the Deployment Strategist / FDE pod split ownership when a customer's data estate is mostly Snowflake/Databricks?"
2. "What's the typical path from PoC to production in your Agentforce engagements, and where do deployments stall?"
3. "How is product feedback from the field triaged into the roadmap?"
4. "Which Claude/Atlas model-selection patterns are you seeing customers adopt?"
