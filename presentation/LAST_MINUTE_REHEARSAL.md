# Salesforce FDE Final Round: Last-Minute Revision and Rehearsal Bank (Beacon edition)

**Panel:** Kaytie Zimmerman (VP, Forward Deployed Engineering) and Anand Narayan (Deployment Strategy Director; your invite and the repo playbook call him an FDE, so expect deep technical probes from him too)
**Format:** 45 min, 2:1, onsite at a Salesforce office with the panel likely dialling in. 15 min walk-through and demo, then Q&A.
**Candidate:** Shaikat Majumdar
**Project:** **Beacon**, `github.com/sm2774us/beacon`. An agentic GRC/SOC triage build: local Node app plus a Salesforce SFDX project, run live in a Trailhead dev org.
**Use:** read this the night before and the morning of. Deep material is in the playbook and the two decks.

---

## 0. CHANGE LOG (delta from the previous bank)

| # | Change | Why |
|---|---|---|
| 1 | **Project switched** from the "post-trade compliance, Agentforce plus Data 360 plus MuleSoft" story to **Beacon**, the app you actually demo. | The old bank described a system the repo does not contain. A panel that sees the demo and hears the old story catches the gap in seconds. |
| 2 | **Removed every unverifiable metric**: $4.2M ROI, 84% faster, 76% autonomous, 99.4% accuracy, 99.98% uptime, 450,000 events a month, 14,000 tickets, 1,000+ golden payloads, 99.1% fidelity, 15% pilot volume. | None are in Beacon. They contradict each other and each invites "how did you measure that?". |
| 3 | **ROI replaced by the app's exact output**: 13.6 of 18 min saved, 635 h, **$53,947 gross, $47,947 net, 799% ROI, about 3-day payback, 350% at half volume**. | Matches the decks and the screen once all 14 findings are run. |
| 4 | **ROI-tab trap added** (section 4). | Your screenshot shows 14 min, 653 h, $55,533, 826%. That is a one-finding state, not the deck state. |
| 5 | **Guardrail thresholds corrected**: G3 is confidence **< 0.60**, not < 0.85. 0.85 is only the Low-band auto-close bar. | Matches `engine.js` and the Apex engine. |
| 6 | **Honesty block added** (section 3): keyword-stub classifier, simulated latency, v2's 100% is a training set, Node server has no auth. | Say it first so the panel cannot "find" it. |
| 7 | **Added coverage** of the interview-details email: all six prompt points, intro and experience, AI tools used, demo fallback, six competencies, three Round-1 feedback items, 2:1 logistics, questions to ask. | The old bank missed the demo fallback, logistics, competency map and the "surface deviations early" element. |
| 8 | **Agentforce and Salesforce tools** rewritten as a mapping plus honest limits. | Round-1 feedback item 3. |
| 9 | Resume claims (50% faster, 99.2% task reliability, under 5 day MVPs) are **labelled resume claims**, belong to Balyasny and J.P. Morgan, and are never attached to Beacon. | Keeps Beacon defensible. |

**Rule:** a real Balyasny, J.P. Morgan or Millburn result is told as its own sourced story ("at Balyasny we..."), never as a Beacon result. If you cannot source a number, say "I won't quote a number I can't back".

---

## 1. THE 45 MINUTES AT A GLANCE

| Clock | Block | Say / do | Competency |
|---|---|---|---|
| 0:00 | Greeting, escort, setup | Be on the demo before they dial in. Browser tabs: Mission Control, Data Pipeline, Prompt Evals, ROI, Salesforce Control Tower. | Agility |
| 0:00-2:00 | **Intro and experience** (part of the 15 min) | Script in section 2. | Influence Stakeholders |
| 2:00-4:00 | **What I built and why** | Problem, user, cost of doing nothing. | Drive Innovation |
| 4:00-6:30 | **First conversation to approach** | Ambiguity vs uncertainty; architecture alignment; deviations surfaced early. | Influence, Agility |
| 6:30-11:00 | **LIVE DEMO** | Run agent on all, then pipeline, guardrails, evals, Salesforce page. | Build and Deploy, Integration |
| 11:00-13:00 | **Challenges, collaboration, AI tools** | Two real challenges, who you worked with, Cursor and Claude. | AI Ecosystems |
| 13:00-15:00 | **Impact, release vs scale, current state** | ROI after a full run, what ships first, what scales later. | ROI, Build and Deploy |
| 15:00-43:00 | **Q&A** | Sections 5 to 11. | All six |
| 43:00-45:00 | **Your questions** | Section 12. | Influence |

**Hard rules:** finish at 14:00-14:30. Stop talking after the answer. If the demo breaks: section 9.

---

## 2. INTRO AND EXPERIENCE (about 90 seconds)

> "I'm Shaikat, a forward deployed engineer with 17 years of customer-facing delivery. Three chapters. At **Millburn** I built ingestion pipelines and integration APIs and turned repeated field patterns into reusable SDK starter kits. At **J.P. Morgan Asset Management** I hardened prototypes into audit-ready containerised services with architecture decision records, and worked with enterprise architects onsite. Since May 2025 at **Balyasny** I've been building agentic AI for GRC and SOC workflows with a delivery pod, including Agentforce and LangGraph work, and feeding field gaps back to product teams. What ties it together: I go onsite, find the real workflow, ship a thin slice fast, and make it safe enough to trust. Today's project, Beacon, is a reference build of that approach, and I'll be clear about what is built, what is modelled, and what is designed."

**Resume facts you may use (all from the resume):** 17+ years; Balyasny May 2025 to present, about 35% travel, onsite discovery, MVPs to a customer environment in under 5 days; J.P. Morgan Feb 2022 to May 2025, about 40% onsite, ADRs, EKS and AKS; Millburn Apr 2008 to Feb 2022, about 30% travel, SDK starter kits; MS Binghamton 2005; five repos plus Beacon.
**Resume claims to be ready to source or soften:** "50% faster" shipping with AI tools; "99.2%" task completion at J.P. Morgan; "under 5 days" MVPs. If asked how measured: "That is from my work at that firm, here is how we measured it" or "I'd rather not give a number I can't fully back in this room."
**Beacon is not on your resume.** Say "my beacon repo, alongside the five on my resume".

---

## 3. BEACON IN ONE PAGE (memorise)

**One line:** a triage pipeline that takes security and compliance findings, scores them deterministically, lets a classifier propose a category, and applies guardrails so risky decisions go to a human, with telemetry and an ROI view that ties it to business value.

**Pipeline:** ingest (idempotent upsert on `External_Id__c`) -> quarantine bad records with reason codes -> deterministic scoring -> classifier (prompt v1 / v2) -> guardrails G1 to G4 -> human approval -> `Agent_Run__c` telemetry -> ROI.

**Scoring:** `severity x 10 + category bonus + control criticality + asset tier (T1 +15, T2 +8) + PII +10 + internet-facing +8`, capped 0 to 100. **Critical is 75 or more.**

**Guardrails (exact):**

| Id | Rule | Outcome |
|---|---|---|
| G4 | Prompt-injection pattern in the finding text | **BLOCKED** |
| G2 | Band is Critical (score 75+) | **PENDING_APPROVAL** |
| G3 | Confidence **below 0.60** | **PENDING_APPROVAL** |
| G1 | Low band, confidence 0.85+, **PII present** | **ASSIGNED** (never auto-closed) |
| Auto-close | Low band, confidence 0.85+, no PII | **AUTO_CLOSED** |
| Default | Everything else (including 0.60 to 0.85) | **ASSIGNED** to an analyst |

Confidence = 0.5 + 0.15 (control matched) + 0.15 (asset matched) + 0.15 (category not "other") + 0.05.

**Demo numbers (fully run, 14 findings):** 18 findings in, **14 accepted, 4 quarantined**. Outcomes: **4 auto-closed, 6 assigned, 3 pending approval, 1 blocked**. Evals: **v1 64.3% -> v2 100%** on 14 golden cases. Simulated latency about 660 ms per finding.

**Salesforce side:** `with sharing`, `WITH USER_MODE` SOQL, `insert/update/delete as user`, permission set `Beacon_FDE_Demo`, bulk-safe `@InvocableMethod` (`BeaconTriageAction`), `@RestResource /beacon/v1/findings/*`, controllers for the KPI dashboard and the agent console, LWCs `beaconDashboard` and `beaconAgentConsole`, **7 Apex test methods**, CI = `npm test` plus the demo in `--fast` mode.

### 3.1 SAY THESE FIRST (the honesty block)

1. "The classifier is a **keyword stub standing in for an LLM**. The point of the build is the harness around it: versioned prompts, evals, guardrails, telemetry."
2. "**Latency and minutes saved are modelled**, not measured. The 660 ms is a sum of step constants."
3. "v2 reaching **100% is on the same 14 cases its keywords were written against**, so it is effectively a training set. A real eval needs a held-out set."
4. "The Node server has **no authentication**. It is a local reference. In the Salesforce org, access is governed by the platform."
5. "**Agentforce** is documented as the setup path. What runs in the org today is the same Apex action behind an in-org Agent Console, no Agentforce licence needed."
6. "The data is **synthetic**."

Saying these in the first minute turns every later probe into "yes, I told you, here is how I'd close it."

---

## 4. ROI: THE ONE PAGE (Round-1 feedback item 2)

**Formula:** `hours = findings x in-scope % x minutes saved / 60`; `gross = hours x rate`; `net = gross - run cost`; `ROI = net / run cost`; `payback days = run cost / (gross / 30)`.

| Quantity | Fully run (14 findings) |
|---|---|
| Baseline manual triage | 18 min per finding |
| Average saved | **13.6 min** |
| Hours saved | **635 h** |
| Gross value | **$53,947** |
| Run cost | $6,000 |
| Net value | **$47,947** |
| ROI | **799%** |
| Payback | **about 3 days** |
| Half volume (2,000 a month) | **about 350%** (the app shows 350%) |

**Minutes saved by outcome (model constants):** auto-close 17.5, assigned 14, approval 12, blocked 0, of an 18 min baseline.

### TRAP: the ROI tab depends on how many findings have been run
- **Only one finding triaged** (E-1001, 14 min): ROI tab shows **14 min, 653 h, $55,533, $49,533, 826%**. That is your screenshot.
- **All 14 run:** 13.6 min, 635 h, $53,947, $47,947, **799%**.
- **Before the demo, click "Run agent on all".** Then open the ROI tab.
- If a panelist reads 826% from an old screenshot: "That is the single-finding state. With the full run it is 799%. The number moves because the average minutes saved moves with the mix of outcomes."

**How to say it:** "This is a **model, not a measured result**. Volume, in-scope share, minutes saved and rate are assumptions you can change on screen. Even at half volume the model stays at about 350%, so the case doesn't hinge on one assumption. With a customer I'd replace the constants with their baseline handle times and re-run."

**What I would measure in production:** analyst minutes per finding before and after; auto-close precision (how many auto-closed items a human later reopened); override rate on approvals; time in the approval queue; quarantine rate by source.

---

## 5. WHAT YOU BUILT AND WHY (email point 1)

**Q: What did you build and what problem does it solve?**
"Security and compliance teams drown in findings: scanners, SIEM alerts, control-test failures. Analysts spend about 18 minutes each deciding what it is, how bad it is, and who owns it. Beacon ingests findings, scores them deterministically, proposes a category, and applies guardrails so low-risk, well-understood items close themselves, risky ones go to a human, and anything suspicious is blocked. It records every decision, so the team can see value and catch drift."

**Q: Why this problem?**
"It is a workflow every large customer has, the decisions are repeatable enough to automate, and the cost of a wrong auto-decision is high enough to force a real guardrail design. That is the interesting part of agentic work: not the model call, the controls around it."

**Q: Who is the user?** "The SOC or GRC analyst, plus the manager who owns the queue and the number."

**Q: What did you not build?** "A real LLM classifier, authentication on the Node server, an Agentforce agent running in the org, or real customer data connectors."

---

## 6. APPROACH AND ARCHITECTURE (email point 2)

**Q: Walk us through the first conversation with the sponsor.**
"I'd start with the decision, not the technology: which decisions eat the most time, what is a wrong decision's cost, who signs off. I'd ask for a week of real findings and the analysts' actual outcomes. In Beacon, that conversation is why the guardrails are explicit: critical never auto-closes, PII never auto-closes, suspicious text is blocked, low confidence goes to a person."

**Q: Ambiguity vs uncertainty (Round-1 feedback item 1). Define it and give an example.**
- **Ambiguity** = the requirement can be read more than one way. **More information from people resolves it.** Example: "auto-close low-risk findings" - what is low risk? Is a Low-band finding on a PII asset low risk? Resolve with a conversation, written down as a rule (G1: PII never auto-closes).
- **Uncertainty** = the answer is not knowable yet. **Only an experiment or data resolves it.** Example: will the classifier be accurate enough on this customer's findings? Resolve with an eval on their data, a pilot with a human in the loop, a threshold I can tune.
- **How I use it:** ambiguity gets a decision meeting and a written rule; uncertainty gets a time-boxed experiment, a fallback and a measure. Mixing them up wastes time: you can't workshop your way to an eval result, and you can't test your way to a sponsor's intent.
- **Beacon example:** the 0.85 auto-close bar and the 0.60 approval floor are **uncertainty** (tune from data). "Critical never auto-closes" and "PII never auto-closes" are **ambiguity resolved** (a policy decision).

**Q: How did you keep the architecture aligned while surfacing business deviations early?** (the exact email wording)
- **Single source of truth for rules:** the same logic exists in the Node engine and the Apex engine, and tests check them against the same cases, so the demo and the org cannot quietly drift.
- **Deterministic core, model at the edge:** scoring and guardrails are plain code. The classifier is replaceable (v1 to v2) without touching the controls.
- **Deviations surfaced early:** the quarantine path turns bad inputs into reason-coded records instead of silent drops; the Prompt Evals tab shows v1 vs v2 before a change ships; the ROI tab shows when assumptions move. Each is a place where "the business reality differs from the plan" becomes a visible number rather than a surprise in week 6.
- **Mechanism with a customer:** a short weekly "assumptions and deviations" list: what we assumed, what we saw, impact, decision needed, owner. Items move from ambiguity (decide) or uncertainty (test).

**Q: Key technical decisions?**
1. **Idempotent ingest** (upsert on `External_Id__c`): retries and duplicate feeds cannot create duplicates.
2. **Quarantine, don't drop:** bad records keep a reason code (4 of 18 in the demo).
3. **Deterministic scoring before any model:** explainable, testable, auditable.
4. **Guardrails as code with fixed precedence:** injection, then critical, then low confidence, then low-risk auto-close with a PII exception.
5. **Versioned prompts with an eval gate:** a test asserts v2 >= 95% and v1 < v2, so a prompt change that regresses fails CI.
6. **Platform security by default:** `with sharing`, `WITH USER_MODE`, `as user`, permission set.
7. **Bulk-safe Apex:** one SOQL and one DML per object, one `Agent_Run__c` per finding.

**Q: Why not let the LLM decide everything?** "Because the cost of a wrong decision isn't symmetric. A wrong auto-close of a critical finding is far worse than a wasted analyst minute. So the model proposes; deterministic code decides what it is allowed to do."

---

## 7. LIVE DEMO SCRIPT AND FALLBACK (email: "showcase or demo", "whiteboard")

**Setup before they join:** server running, **click "Run agent on all"**, Salesforce Control Tower page open in a second tab, notes on `index.html` ROI tab.

**Demo order (about 4.5 min):**
1. **Mission Control** (30 s): queue, bands, outcomes. "4 auto-closed, 6 assigned, 3 waiting for approval, 1 blocked."
2. **Data Pipeline** (45 s): 18 in, 14 accepted, 4 quarantined with reasons. "Idempotent upsert; bad rows are kept, not lost."
3. **Guardrails** (60 s): open the blocked finding (G4), a critical one (G2), a PII one (G1). Say the precedence.
4. **Prompt Evals** (45 s): v1 64.3% to v2 100%. **Say the training-set caveat here.**
5. **ROI** (45 s): 799%, $47,947 net, 350% at half volume. "A model, with assumptions you can change."
6. **Salesforce** (45 s): Control Tower Lightning page and Agent Console. "Same Apex action; permission set; user mode."

**If the demo fails (whiteboard fallback, 3 min):** draw a left-to-right pipeline with five boxes: **Ingest -> Score -> Classify -> Guardrails -> Human/Telemetry**. Under Guardrails write G4, G2, G3, G1 in precedence order. Under Telemetry write `Agent_Run__c`. Say: "The screens would show these same outcomes; the repo and my deck have the screenshots." Then go to ROI formula on the whiteboard.

**If the ROI reads 826%:** you skipped "Run agent on all". Run it and refresh. Say the trap line from section 4.
**If asked to show code:** `engine.js` (decide function) and `BeaconTriageAction` / `BeaconTriageEngine`. Know where the 0.60 and 0.85 constants are.

---

## 8. CHALLENGES (email point 3)

Use these **real, repo-grounded** ones. Pick two.

| Challenge | What happened | What I did | Lesson |
|---|---|---|---|
| **A. Dirty and duplicate inputs** | 4 of 18 findings were unusable (missing or invalid fields); duplicates on re-ingest. | Idempotent upsert plus reason-coded quarantine. | Never drop silently; make rejection visible and countable. |
| **B. Trusting a model's confidence** | A classifier can be confidently wrong. | Guardrails apply regardless of confidence for Critical, PII and injection; confidence only gates the low-risk path. | Confidence is an input to a policy, not the policy. |
| **C. A prompt change that looked better but wasn't measured** | v1 scored 64.3% on 14 cases. | Versioned prompts and an eval gate in CI. | If you can't measure a prompt change, you can't ship it. |
| **D. The demo number moved** | The ROI tab showed 826% after one finding and 799% after all 14. | Understood it as mix-dependent average minutes; fixed the deck numbers to the full-run state and added the rule "run all first". | A model that updates live needs a stated state when you quote it. |
| **E. Keeping two runtimes consistent** | Logic exists in Node and Apex. | Same cases drive both, tests on both sides (Node tests and 7 Apex tests). | Duplicated logic needs shared test cases or it drifts. |

**Q: Tell us about something that went wrong.** Use D, or B. "I quoted a number from a screen that was in a half-run state. I caught it when the deck and the app disagreed, traced it to the average minutes saved depending on outcome mix, and now the rule is: run the full set before opening ROI. It's a small thing, but it's exactly the trust problem with any live metric."

**Q: Tell us about a time an agent decision failed in production.** This must be a real story. Use a Balyasny, J.P. Morgan or Millburn example you can fully source, labelled as such. If you do not have a clean one: "In production at [firm], [what failed, what the guardrail did, what changed]. In Beacon the equivalent is G2/G3: when the system is unsure or the stakes are high it stops and asks a person."

---

## 9. COLLABORATION (email point 4)

**Q: Who did you work with and how did you navigate technical and stakeholder discussions?**
In Beacon (a solo reference build) be honest: "Beacon is solo, so the collaboration was with the **role** I'd have: the analyst who triages, the manager who owns the queue, a security architect, and the Deployment Strategist. In my professional work at Balyasny and J.P. Morgan I partnered with Deployment Strategists, enterprise architects and executive sponsors." Then use one real pod story.

**Q: How do you partner with a Deployment Strategist?** "They own the business case, adoption and the sponsor relationship; I own whether it works, ships and stays up. We meet on three things: the decision the agent will own, the metric that proves it, and the risks we're both accepting. I give them numbers they can say in a boardroom; they give me the real constraints early."

**Q: Sponsor wants full autonomy on day one; architects are risk-averse.** "Both are right about different things. I turn it into a **graduated autonomy** plan: week 1 everything goes to a human with the agent's recommendation shown; once override rate and precision are measured, the low-risk, high-confidence band auto-closes; critical and PII stay human. Beacon's guardrails are that plan in code."

**Q: A stakeholder doesn't trust AI.** "I show them the control, not the model: here is what it can never do on its own, here is the log of every decision, here is how you turn it off."

**Q: How do you handle scope creep?** "I ask what decision or metric it changes. If it changes neither, it goes on a list. If it does, we trade it against something."

**Q: How do you leave a team more capable (JD)?** "Pair on the first change, then hand them the eval set, the dashboard and the runbook. Success is them changing a prompt and seeing the eval gate catch a regression without me."

**Q: Product feedback loop.** "I write field gaps as: what I tried, what happened, what it cost, a workaround, a suggested change. Examples to prepare: where an agent's confidence couldn't be exposed to guardrails cleanly; where telemetry needed custom objects."

---

## 10. DEPLOYMENT, IMPACT, RELEASE VS SCALE, CURRENT STATE (email points 5 and 6)

### 10.1 Initial release vs scaling (the exact email question)

| | **Initial release** (plan for) | **Scaling** (plan for) |
|---|---|---|
| Scope | One finding source, one workflow, human approves anything non-trivial | More sources, more categories, more teams |
| Autonomy | Auto-close only Low band, 0.85+ confidence, no PII | Raise autonomy per category as precision is proven |
| Data | Idempotent ingest, quarantine, reason codes | Source onboarding checklist, volume and rate limits |
| Quality | 14-case golden set and eval gate | **Held-out and customer-owned** eval set, drift checks |
| Security | Permission set, user mode, sharing rules | Auth on any non-platform endpoint, secrets handling, audit review |
| Ops | `Agent_Run__c` telemetry, KPI dashboard | Alerts on override rate, queue age, quarantine spike |
| People | Pilot analysts | Training, runbook, ownership of prompts and thresholds |

**Honest status:** Beacon is a reference build in a dev org with synthetic data. It has not been through a customer production release.

### 10.2 Impact
Use the section 4 numbers, labelled "modelled". Add: "In production I'd report measured analyst minutes and reopen rate, not modelled ones."

### 10.3 Current state and monitoring
- **Today:** runs locally and in a Trailhead dev org; CI runs `npm test` and the demo in `--fast` mode on every push; 7 Apex tests.
- **Monitor:** one `Agent_Run__c` row per decision with outcome, score, confidence, prompt version, latency; KPI dashboard on top.
- **Maintain and improve:** change prompts only through the eval gate; review overrides weekly; tune 0.60 and 0.85 from data; add a held-out set.
- **Known gaps (offer them):** Node server has no auth; injection detection is a small regex list; static path guard is naive; the classifier is a stub.

---

## 11. AGENTFORCE AND SALESFORCE TOOLS (Round-1 feedback item 3)

**Mapping (what is true today):**

| Beacon piece | Salesforce concept | Status |
|---|---|---|
| `BeaconTriageAction` (`@InvocableMethod`, bulk-safe) | An **Action** an agent topic can call (Apex action) | Built |
| Triage topic and instructions | **Agentforce topic** with instructions and actions | **Mapping and setup path, not run** |
| Guardrails G1 to G4 | Deterministic layer around the agent, plus platform trust controls | Built in Apex |
| `Agent_Run__c` and `beaconDashboard` | Agent telemetry and KPI reporting | Built |
| `beaconAgentConsole` | In-org console calling the same action | Built, no Agentforce licence needed |
| Permission set, `WITH USER_MODE`, `as user` | Platform sharing and FLS enforcement | Built |
| Prompt v1/v2 evals | Prompt versioning and testing | Concept built; the Salesforce-native equivalents are Prompt Builder and Agentforce testing tools |

**Vocabulary to use correctly (verify wording on salesforce.com before the interview):** Agentforce, topics, actions (Apex, Flow, prompt template, API), instructions, the Einstein Trust Layer (masking, zero data retention, grounding, audit), Prompt Builder, Data 360 (formerly Data Cloud), Agentforce Vibes (the AI coding assistant the JD calls "Vibes").

**Q: How are Agentforce and Salesforce tools used in forward-deployed work?**
"The pattern is: model the customer's decision as a **topic**, expose the deterministic business logic as **actions** (Apex, Flow, APIs), ground the agent in the customer's data through **Data 360**, keep the guardrails in code and in platform permissions, and measure with telemetry. As an FDE I'm the one who chooses what belongs in the model's reasoning and what belongs in deterministic actions, makes the data usable, and proves value. Beacon follows that pattern; the Apex action is the piece that plugs into an agent topic."

**Q: Why Agentforce over LangChain or LangGraph?** "When the customer's data, identity and actions already live in Salesforce, Agentforce gives me sharing rules, auditing, the trust layer and native actions without building them. LangGraph is a strong fit when the flow is complex, multi-system or off-platform. I've used both, and a good design can mix them: an off-platform graph calling a Salesforce action, or an agent calling an external API."

**Q: Where does Data 360 fit?** "Where the agent needs unified customer or account context, or data from Snowflake or Databricks without copying it. Beacon doesn't use it; at a customer I'd model the entities, ship the pipeline, validate the output, then ground the agent on it."

**Q: What is Agentforce Vibes?** "Salesforce's AI coding tool for building on the platform; the JD lists it next to Cursor and Claude. I use Cursor and Claude daily; for Vibes say what you have actually done with it and don't claim more."

**Q: How would you productionise Beacon on Agentforce?** "Create the topic and instructions, register `BeaconTriageAction`, test with the golden set in the platform's testing tools, keep G1 to G4 in Apex so they hold even if the model misbehaves, use the same permission set, add the KPI dashboard, pilot with human approval on everything, then relax autonomy per category."

---

## 12. AI TOOLS YOU USED (email: "examples of AI tools")

| Tool | How you used it on Beacon | Guard |
|---|---|---|
| **Claude** | Drafting Apex, tests and the engine port; reviewing guardrail edge cases | You reviewed every change; tests decide |
| **Cursor** | Multi-file edits across `local/` and `force-app/` | Diff review, CI |
| **Vibes** | Only if you used it. Otherwise "I know it's the Salesforce-native assistant" | Don't claim |

**Q: How do you keep AI-written code safe?** "Tests first or alongside, deterministic core, CI, review every diff, and the eval gate on prompts. AI makes the first draft fast; it doesn't own correctness."

**Q: Show a prompt that failed.** Prepare one from v1: what category it misclassified, why (missing keywords), what v2 changed, how the eval confirmed it. Admit the caveat that the fix was written against the same cases.

---

## 13. THE SIX COMPETENCIES: ONE-LINE PROOF EACH

| Competency | Beacon / experience proof | One sentence |
|---|---|---|
| **Influence Stakeholders** | Graduated autonomy plan; ROI as a model they can change | "I move sponsors with a controlled path to autonomy and numbers they can adjust." |
| **Drive Innovation and AI Readiness** | Eval gate, versioned prompts, guardrails | "I make AI safe to adopt: measured, reversible, auditable." |
| **Agility** | MVP pipeline in days; fixed the ROI mismatch fast | "Thin slice first, then harden what the data shows matters." |
| **Build and Deploy Technical Capabilities** | Idempotent ingest, bulk-safe Apex, 7 tests, CI | "I own it from architecture to tested, observable deployment." |
| **Integration Platform and Ecosystem** | REST ingest endpoint, invocable action, LWC, Node plus Apex parity | "I design the seams: APIs, actions and data contracts." |
| **AI Ecosystems and Frameworks** | Agentforce mapping, LangGraph and LangChain experience, Cursor and Claude | "I pick the right tool for where the data and controls live." |

---

## 14. TECHNICAL DEEP-DIVE Q&A

**Q: Explain your Apex action.**
"`BeaconTriageAction` is an `@InvocableMethod` that takes a list of finding Ids, so it is bulk-safe: one SOQL (`WITH USER_MODE`) to load findings with their control and asset, scoring and decision in memory, then one DML per object `as user`, writing the finding outcome and one `Agent_Run__c` per finding. The class is `with sharing`."

**Q: How do you stay inside governor limits?** "No SOQL or DML in loops; collect, query once, compute in memory, write once. For larger volumes, queueable or batch, and platform events for async fan-out."

**Q: How is security enforced?** "`with sharing`, `WITH USER_MODE` on queries, `as user` on DML, a permission set that grants only the needed objects and fields. The Node server has no auth and is explicitly not for production."

**Q: Walk me through the REST endpoint.** "`BeaconIngestRest` is a `@RestResource` at `/beacon/v1/findings/*`. It accepts findings, upserts on `External_Id__c` so retries are safe, and returns accepted and quarantined counts with reasons."

**Q: How do you test an agent?** "Three layers: unit tests on the deterministic engine, a golden set for the classifier with a gate in CI, and guardrail tests with adversarial inputs (injection text, PII on a low-risk finding, a critical with high confidence). In Beacon: Node tests, 7 Apex tests and the eval gate."

**Q: How do you mitigate hallucination and non-determinism?** "Constrain what the model may do (actions, not free text), validate outputs deterministically, use the guardrails regardless of confidence for high-stakes cases, keep a human in the loop where cost is asymmetric, and measure with a golden set. For anything free-text, ground it and cite sources."

**Q: What would you harden first?** "1) Auth and secrets on any non-platform endpoint. 2) A held-out eval set so the percentage means something. 3) A real injection defence beyond a regex list: input isolation, output validation, allow-listed actions. 4) Alerting on override rate and quarantine spikes."

**Q: Data pipelines to Snowflake, Databricks, Data 360?** "Model the entities first, choose zero-copy or ingest by latency and cost, make loads idempotent, validate row counts and keys, quarantine bad rows, and expose lineage. Beacon applies the idempotency and quarantine parts at small scale."

**Q: Integration patterns you would choose?** "Webhook or REST for event push with an idempotency key; Platform Events or queues for decoupling; batch for backfill; an invocable action for in-platform calls. Retries must be safe, failures visible."

**Q: What happens at 100x volume?** "Ingest moves to async with backpressure; scoring stays deterministic and cheap; the classifier call becomes the cost and latency driver, so batch and cache; approvals need queue ownership and SLAs; telemetry needs aggregation rather than row-by-row dashboards."

**Q: LLM prompt failed. Why and what would you change?** (JD) Use the v1 to v2 example: root cause, change, how it was checked, caveat.

---

## 15. HARD AND TRAP QUESTIONS

| Question | Answer |
|---|---|
| "Is this real?" | "It's a reference build with synthetic data. The Salesforce part runs in a dev org. I won't claim customer results from it." |
| "Your classifier is just keywords." | "Yes, a stub. The value is the harness: versions, evals, guardrails, telemetry. Swapping in an LLM changes one function; the controls and the eval gate stay." |
| "100% accuracy?" | "On the same 14 cases it was written against, so it's effectively training data. I'd never quote it as accuracy; I'd build a held-out set." |
| "Where is Agentforce?" | "Mapping and setup path today; the Apex action it would call is built and runs behind an in-org console." |
| "Where are the real ROI results?" | "It's modelled and labelled so. At half volume it is about 350%; with a customer I'd replace assumptions with their baselines." |
| "Why does ROI show 826% in one place?" | "Single-finding state. Full run is 799%." |
| "No auth on the server?" | "Correct, a local reference. On the platform, auth and sharing are the platform's. First hardening item for any exposed endpoint." |
| "You have no Salesforce certifications listed by name." | "My resume lists the Agentforce Specialist path; I'll state exactly what I've completed. [Know your truth before the interview.]" |
| "Beacon is not on your resume." | "Built recently to demonstrate the pattern in the Salesforce stack; it sits alongside the five repos on my resume." |
| "What do you not know about Salesforce?" | "Some depth in Flow orchestration and Prompt Builder specifics; I ramp fast: here's how I'd close it in 30 days." |

---

## 16. YOUR QUESTIONS FOR THE PANEL (ask 2 or 3)

1. "What does a typical first 30 days look like for an FDE paired with a Deployment Strategist on a new account?"
2. "Where do FDEs most often hit gaps in Agentforce, and how does that feedback reach product?"
3. "How do you decide when an agent's autonomy can be raised for a customer?"
4. "What would make someone in this role clearly successful at six months?"
5. "How is the work split between onsite and remote in a typical engagement?" (JD says about 25% travel.)
6. For Kaytie: "What does the delivery team look like in a year?" For Anand: "What does a good handoff between strategy and engineering look like to you?"

---

## 17. LOGISTICS (onsite, remote panel)

- Salesforce employee greets and escorts you to a room; the panel **likely dials in**, so check **camera, audio, screen share and the display cable** before they join.
- Bring: laptop charged plus charger, HDMI/USB-C adapter, a **second way to show slides** (PDF on a USB stick or phone), a printed copy of the core slides (14:10 path) and this bank.
- Browser tabs pre-opened and signed in (Salesforce dev org logins can expire: check them that morning). **Run all, then ROI.**
- Offline fallback: screenshots of each tab in the deck appendix; the whiteboard script in section 7.
- Dress and arrive early; know the office address and parking; save the coordinator's contact.
- Windows offered in the invite: Nov 5 to 6 and Nov 11 to 13.

---

## 18. FINAL CHECKLIST (tick before leaving)

**Numbers (say them exactly):**
- [ ] 18 in, 14 accepted, 4 quarantined
- [ ] 4 auto-closed, 6 assigned, 3 pending approval, 1 blocked
- [ ] G3 is below **0.60**; auto-close needs Low band, **0.85+**, no PII; Critical is **75+**
- [ ] v1 **64.3%** -> v2 **100%** (14 cases, training-set caveat)
- [ ] ROI: **13.6 min, 635 h, $53,947, $47,947, 799%, about 3 days**; half volume **about 350%**
- [ ] **826% = one-finding state. Click Run agent on all first.**
- [ ] 7 Apex tests; CI = `npm test` plus demo `--fast`

**Say first:** stub classifier, modelled ROI and latency, v2 training set, no Node auth, Agentforce is a mapping, synthetic data.

**Cover in 15 min:** intro and experience, what and why, approach (ambiguity vs uncertainty, deviations surfaced early), demo, challenges, collaboration, tools, release vs scale, current state.

**Round-1 feedback:** [ ] ambiguity vs uncertainty example said aloud [ ] ROI tied to outcome with the formula and the sensitivity [ ] Agentforce and Salesforce mapping, with honest limits.

**Do not say:** any removed metric (4.2M, 84%, 76%, 99.4%, 99.98%, 450,000, 14,000, 1,000+ golden, 99.1%); "production" about Beacon; "100% accuracy"; anything about Vibes you have not done.

**Close:** one-sentence summary, thank them, ask two questions.
