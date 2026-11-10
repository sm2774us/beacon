# Presentation Slide Rehearsal

**Candidate:** Shaikat Majumdar, Senior Forward Deployed Engineer candidate
**Interview:** Salesforce final round, 45 minutes, 2:1, Google Meet (candidate at the Salesforce NYC office, both interviewers remote)
**Interviewers:** Kaytie Zimmerman (VP, Forward Deployed Engineering) and Anand Narayan (Deployment Strategist Director)

**Slide references used below:** `P1-S#` = slide # of `SALESFORCE_FINAL_ROUND_PRESENTATION`; `P2-S#` = slide # of `SALESFORCE_FINAL_ROUND_OPEN_SOURCE_DEMO`.

**Which version this script follows:** the **enhanced** copies, `SALESFORCE_FINAL_ROUND_PRESENTATION_ENHANCED.pptx` and `SALESFORCE_FINAL_ROUND_OPEN_SOURCE_DEMO_ENHANCED.pptx`. Slide count, order, numbering and titles are identical to the originals; the originals were not modified. The enhancements (all small, all listed in the table below) change no claim except to make one wording more honest.

| # | File | Change | Why it was worth making |
|---|------|--------|-------------------------|
| 1 | P1-S4 | Title "four things" → "six things" | The table has six rows; a skeptical reader sees the mismatch in seconds. |
| 2 | P1-S15 | "measured in the Beacon demo run" → "modelled in the Beacon demo run" | The 13.6 min/finding is computed from an 18-min *assumed* baseline and assumed per-outcome analyst minutes. "Measured" invites an attack on the whole ROI slide. |
| 3 | P1-S5, P1-S10, P1-S13 charts | Redrawn with category labels (were "1, 2, 3…") | Unlabelled bars cannot be narrated over a screen share. Values unchanged. |
| 4 | P2-S4 chart + caption | Bars labelled (Manual baseline / Auto-closed / Assigned / Pending approval / Blocked); caption now says "modelled in the demo run" | Same reasons as 2 and 3. |
| 5 | P2-S10 chart | Bars labelled Prompt v1 / v2 | Same as 3. |
| 6 | P2-S15 chart | Bars labelled G1 PII / G2 Critical / G3 Low conf. / G4 Injection | Same as 3. |
| 7 | P2-S20 chart | Quarantine bars labelled Duplicate / Invalid severity / Missing required field / Malformed JSON | Same as 3. |
| 8 | P2-S18 | "Anand (Director, Deployment Strategy)" → "Anand (Deployment Strategist Director)" | Matches his title and P1-S18. |
| 9 | Speaker notes on P1-S15 and P2-S4 | Added the arithmetic behind 13.6 min and the ROI definition | Gives you the derivation when asked. |

Slides that were already strong and left alone: P1-S3, S8, S9, S11, S12, S13 (layout), S16, S17; P2-S5, S6, S7, S9, S11, S12, S13, S16, S17, S22. The deck design (dark theme, consistent header strip, one message per slide) is coherent and should not be redesigned.

> **Two items to verify before the interview (I could not check them from the files):**
> 1. The per-outcome analyst minutes behind 13.6 min (I reconstructed them from the P2-S4 chart: 0.5 / 4 / 6 / 18, which reproduces 13.57 ≈ 13.6 exactly). Confirm in the Beacon repo.
> 2. Current Salesforce product names (Agentforce, Agentforce Vibes, Data 360, Testing Center, Prompt Builder, Trust Layer). Names change; P2-S16's own notes say the same.

---

## Interview Context and Overall Strategy

### The room

Two remote interviewers, one candidate in a Salesforce office. Everything you say has to survive a webcam and a screen share. That means:

- **Camera:** sit so the camera is at eye level and your face fills the top third. Talk to the lens for opening, closing and every key claim. Glance at the screen for diagrams, then return to the lens.
- **Audio:** use the headset you tested in that room, not laptop speakers. Mute notifications. Speak 10% slower than feels natural; remote audio compresses fast speech.
- **Screen share:** share one window, not the entire screen. Keep three windows ready and in this order: (1) Beacon in the browser, (2) `SALESFORCE_FINAL_ROUND_OPEN_SOURCE_DEMO_ENHANCED.pptx`, (3) `SALESFORCE_FINAL_ROUND_PRESENTATION_ENHANCED.pptx`. Also have `run-cli-demo.bat` open in a terminal as the demo fallback, and pre-click "Run agent on all" state knowledge (see the ROI trap in P2-S9).
- **Signposting:** because they cannot see where you point, always name the thing: "top-left box, the Ingest API", "the second row of the table". Never say "this one here".
- **Notes:** keep this document on a second device or printed, not on the shared screen.

### Objectives

1. Prove you are a builder who can sit in a customer environment (Kaytie's lens: rigor, architecture, judgment).
2. Prove you can turn ambiguity into a plan a customer adopts, and tie it to value (Anand's lens: deployment, adoption, time to value).
3. Be unmistakably honest about what Beacon is: a **reference build** with synthetic data, a keyword-stub classifier, simulated latency and modelled ROI. Honesty here is your biggest credibility asset because the evidence-boundary slide (P2-S22) lets you volunteer it before they find it.
4. Own the Agentforce gap in one sentence and show a concrete plan to close it (P1-S7, P1-S17).

### Delivery order (this differs from file order)

You present **P2 (the Beacon deck) first**, because it is the assigned-prompt answer. **P1 is the Q&A bank** that you open when a question lands on a competency or on the job description.

### 45-minute plan

| Clock | Minutes | Segment | What is on screen |
|-------|---------|---------|-------------------|
| 0:00–2:00 | 2:00 | Greetings, restate the plan, confirm they can see and hear | P1-S1 for ≤20 s, then switch to P2 |
| 2:00–16:00 | ~14:10 | **Beacon walkthrough** (P2-S1 to S18, live demo inside it) | P2, with Beacon in the browser for S8–S9 |
| 16:00–37:00 | 21:00 | **Discussion and Q&A**, led by the interviewers | P2 backup (S19–S22) or P1 slides on demand |
| 37:00–42:00 | 5:00 | **Your questions** to Kaytie and Anand | P2-S18 (or P1-S18) |
| 42:00–45:00 | 3:00 | Close, thanks, next steps; also the buffer | camera only |

Rules: if you reach 6:30 and have not started the demo, cut P2-S5 to 40 seconds and skip P2-S9. If the demo fails at any point, switch to the CLI demo, and failing that, to P2-S20/S21 (they are built for this). Never spend more than 60 seconds troubleshooting live.

### Narrative spine (say it the same way in every answer)

> *I deliver in customer environments. I make AI safe to ship. I prove value.*

Every answer should land on one of those three, with one concrete example from Beacon or from the resume items on the slides.

### What you may and may not claim

- **May claim** (it is on your slides and resume): 17+ years; Millburn Ridgefield 2008-22, J.P. Morgan/Highbridge 2022-25, Balyasny 2025-now; 25-40% onsite; under-5-day MVPs; ADR-governed, containerized services on EKS/AKS; 99.2% task-completion reliability after prompt/context/tool-routing fixes; ServiceNow and Archer headless integrations; LangChain, LlamaIndex, LangGraph; Beacon as a reference build.
- **May not claim:** that Beacon ran at a customer; that the 13.6 minutes or the $48K are measured outcomes; that the classifier is an LLM; that Agentforce is a deep strength (say "ramping"); anything about a customer's metrics that is not on a slide.
- **When asked about something not on a slide**, use this pattern: *"What I've done is X. What I would do here is Y, and here is how I'd validate it."* This separates fact from proposal without sounding weak.

---

## Presentation 1 — `SALESFORCE_FINAL_ROUND_PRESENTATION__1_.pptx` (use the enhanced copy)

### 1. Presentation Overview

An 18-slide **competency-led deck and Q&A bank**. Slides 1-5 introduce you and map your background to the job description. Slides 6-13 walk the six competencies Salesforce assesses (influence stakeholders, drive innovation and AI readiness, agility, build and deploy, integration platform, AI ecosystems), each cross-referenced to the Beacon deck. Slides 14-18 close on business value, a summary, a proposed first 90 days, and your questions. Its central message: **"I have real evidence for five of six competencies and a concrete plan for the sixth (Agentforce depth)."** Its most important feature is P1-S7, an honest evidence table that separates "resume: delivered", "Beacon", and "ramping".

### 2. Recommended Presentation Strategy

- **Do not present it front to back.** The notes on P1-S1 say it explicitly: the Beacon deck is the main event and this deck is the Q&A bank. Open P1-S1 for 20 seconds, then go to P2.
- **Use it reactively.** Map likely questions to slides: "tell me about yourself" → S2/S5; "why should we hire you vs. a Salesforce specialist" → S4/S7/S12; "how do you handle ambiguity" → S9; "how do you ship AI safely" → S13; "what is your ROI story" → S15; "what will you do in your first quarter" → S17.
- **Deliver quickly:** S2, S3, S5, S10 (these repeat or support the Beacon deck). **Deliver deliberately:** S7 (honesty and Agentforce ramp), S9 (the ambiguity/uncertainty frame, which was explicit Round 1 coaching), S12 (framework vs platform judgment), S13 (staged autonomy), S15 (ROI, careful wording), S17 (first 90 days).
- **Pause points:** after S7 (invite them to probe Agentforce), after S13 (invite safety questions), after S15 (invite the ROI challenge).

### 3. Slide-by-Slide Rehearsal

#### Slide 1 — Forward Deployed Engineer | Final Round: *Shipping Agentic AI Into Real Enterprises*

**Purpose.** Set a warm, confident tone, state the plan, and hand off to the Beacon deck. This slide earns trust, not information.

**Recommended delivery time.** 0:20 (inside the 2-minute opening).

**Verbatim-ready speaking script**

> "Kaytie, Anand, thank you for making the time. I'm looking forward to this. Here's how I'd like to use our 45 minutes. I'll take about fifteen minutes to walk you through one project, Beacon, including a live demo, because it answers the prompt you gave me. Then I'd love to spend most of the remaining time in conversation, with your questions first and mine at the end. I have a second deck behind this one organized around the competencies you assess, and I'll pull it up if a question lands there. Does that work for you?"

**Delivery and emphasis cues**
- Look at the camera for "thank you." Smile; do not rush.
- Pause after "Does that work for you?" and wait for a nod or a yes. This also confirms audio and video.
- Switch windows *before* you start talking about Beacon so there is no dead air.

**Likely interviewer questions**
1. "Before the project, can you give us the 30-second version of who you are?"
2. "Why this role, rather than staying in finance?"

**Suggested answers**
1. "I'm a senior engineer with seventeen years of customer-facing delivery, most of it in New York finance and governance, risk and compliance. Each role moved me closer to putting AI agents into production inside customer environments, and that's what I want to do on Agentforce."
2. "The part of my work I value most is sitting with a customer, finding the real problem, and shipping something their team can run. Finance gave me hard constraints: audit, security, uptime. Salesforce gives me that same discipline at much greater scale and breadth, across many industries and a platform built for it."

**Transition.** "So let's start with the project."

---

#### Slide 2 — Opening | Introduction: *17 years of putting software where customers live*

**Purpose.** Establish the through-line (customer-facing delivery, closer to agents each time) in under 75 seconds. Duplicates P2-S2, so use it only if you are running the competency path.

**Recommended delivery time.** 1:00–1:15 (skip if P2-S2 was already presented).

**Verbatim-ready speaking script**

> "The short version: seventeen-plus years, and the through-line is customer-facing delivery. Fourteen of those years were at Millburn Ridgefield, where I built data and integration systems for institutional partner accounts and wrote reusable SDK starter kits. Then three years at J.P. Morgan and Highbridge, where I moved into agent orchestration inside client environments, hardening tools into containerized, audit-ready services. And now Balyasny, where I'm embedding with pods and putting agents into production, with working prototypes in the customer's environment in under five days.
>
> Across those three roles I've been onsite with customers about twenty-five to forty percent of the time, which fits the roughly twenty-five percent this role asks for. And what I actually do day to day is three things. I design the intelligence of the agent: prompts, reasoning, tool calls and the guardrails around them. I own components end to end, from architecture through to something deployed, validated and observable in production. And I co-build with the customer, because the measure of a good engagement is that their team is more capable when I leave."

**Delivery and emphasis cues**
- Emphasize "customer-facing delivery" once; it is the through-line.
- Say "under five days" slowly; it is a differentiator.
- Look at the camera for the last sentence.

**Likely interviewer questions**
1. "You say 25-40% onsite. What does onsite mean for a finance engineer?"
2. "Which of the three roles taught you the most about customer deployment?"
3. "The donut chart shows 14 years at one firm. What did you do to avoid stagnating?"

**Suggested answers**
1. "Working inside the client's or business's own environment: their network, their change control, their stakeholders, not shipping from a distance. In practice that meant sitting with traders, risk teams, architects and sponsors to understand the workflow, then deploying into their environment."
2. "J.P. Morgan and Highbridge, because the environments were the most constrained. Security review, audit and change control force you to make decisions explicit, which is where I started writing ADRs for every trade-off. I carry that habit into every engagement."
3. "The scope kept changing. Early on it was data pipelines and integrations in Python and Java; later BigQuery and Snowflake, Kafka, and SDK starter kits for other teams. The tenure gave me depth on how systems age in production, which matters when you hand a deployment to a customer and need it to last."

**Transition.** "That's who I am. Let me show you what I'm going to cover."

---

#### Slide 3 — Opening | Agenda and Assigned Prompt: *Agenda: answer the prompt, show it live, tie it to value*

**Purpose.** Show you understood the assigned prompt and have a disciplined plan. Restating the prompt in your own words is the signal.

**Recommended delivery time.** 0:20–0:30.

**Verbatim-ready speaking script**

> "You asked me to walk through a project: what I built and why, how I approached it from the first sponsor conversation to architecture, what broke and how I fixed it, who I worked with, how I took it from a first release to scale, and how it's monitored and improved today. I've organized fifteen minutes around exactly that: one and a half minutes on me, three and a half on the problem and approach, five on the live demo and evals, one on challenges and collaboration, and three on impact. I've left a minute of buffer. I've also planned two pauses for you, one after the architecture and one after the demo."

**Delivery and emphasis cues**
- Do not read the agenda strip. Look at the camera when you restate the prompt.
- Slow down at "two pauses for you" and mean it.

**Likely interviewer questions**
1. "Is Beacon a real customer project?"
2. "Why did you pick this project for the prompt?"

**Suggested answers**
1. "No, and I want to be clear up front. Beacon is a reference build I made from patterns I've used in customer work. It uses synthetic data, and the savings are modelled assumptions I'd replace with the sponsor's numbers. I chose that framing so I can show you everything, including the code, without exposing a client's data."
2. "Because it exercises exactly what the role does: ambiguous discovery, an agent with guardrails, a data pipeline, evals, telemetry, and a business case. And it maps directly to Agentforce, which let me do the homework on your platform."

**Transition.** "Let me first show you how I read the role."

---

#### Slide 4 — Opening | Context: *The role asks for six things. I bring evidence for each.*

**Purpose.** Show you read the job description and are not reciting a resume. The "Fit" column is deliberately honest (one "Growing").

**Recommended delivery time.** 0:45 (can be cut to 0:20).

**Verbatim-ready speaking script**

> "I went through the job description and boiled it down to six requirements, and I'd rather show you evidence than adjectives. Customer-facing technical delivery is the required one, and that's seventeen years across three firms. Production agentic AI, with prompts and evals: at Balyasny I took task-completion reliability to ninety-nine point two percent by refining prompts, context and tool routing. Data pipelines, with Data 360, Snowflake and Databricks in mind: I've built ingestion pipelines and executive dashboards at J.P. Morgan and Balyasny. APIs and integration: REST, gRPC, webhooks, Kafka, plus headless integrations to ServiceNow and Archer.
>
> The one I've marked 'Growing' is the Salesforce platform and Agentforce. I've worked with Agentforce and Apex and I built Beacon on the platform, but I won't claim the depth of someone who's lived in it for years. I'll tell you exactly how I'm closing that gap when we get to the first ninety days."

**Delivery and emphasis cues**
- Slow down and look at the camera on "Growing." Naming it first removes its sting.
- Do not read every row; pick three.

**Likely interviewers' questions**
1. "How was the 99.2% measured?"
2. "What exactly have you done with Agentforce?"
3. "You marked Travel as 'Ready'. Is 25% really workable?"

**Suggested answers**
1. "It's task-completion reliability for the agent workflow: the share of tasks that completed correctly end to end. The improvement came from three things: tighter prompts, better context assembly and fixing tool-routing errors. I'd want to be careful to describe the denominator precisely: the specific task set and period. [**Prep note:** know this denominator cold before the interview. If you cannot state it, say 'on the task set we tracked at Balyasny' and do not elaborate.]"
2. "[**Prep note:** this slide says 'Agentforce deployments' while P1-S7 says 'Agentforce: ramping'. Reconcile them before the interview.] The safest, strongest answer: say exactly what you did (for example, which agent, which topics and actions, in which kind of environment), then say 'my depth is in orchestration and guardrails, and I'm ramping on the platform-native pieces: Prompt Builder, the Trust Layer and Testing Center.' Do not describe features you have not touched."
3. "Yes. I've been onsite thirty to forty percent of the time in every forward-deployed role I've held, so twenty-five percent is a comfortable number."

**Transition.** "Let me show how those roles built on each other."

---

#### Slide 5 — Opening | Context: *Each role moved closer to agents in production*

**Purpose.** Give the career a narrative arc: data and integration → agent orchestration → agents in production.

**Recommended delivery time.** 0:45 (or skip).

**Verbatim-ready speaking script**

> "I think about my career as three steps, each one closer to agents running in production. At Millburn, from 2008 to 2022, it was data and integration: Python and Java pipelines, BigQuery, Snowflake, Kafka, and SDK starter kits that other teams could adopt. That's the plumbing every agent depends on. At J.P. Morgan, from 2022 to 2025, it was agent orchestration: LangChain, LlamaIndex, custom engines, headless APIs into ServiceNow and Archer, and ADR-governed hardening. And at Balyasny, from 2025, it's agents in production: Agentforce, LangGraph, GRC and SOC actions, dashboards, and MVPs in under five days.
>
> The bars show my approximate onsite share per role, about thirty, forty and thirty-five percent. They're approximations from my resume, so please take them as a range, not a measurement."

**Delivery and emphasis cues**
- Trace the arrow left to right verbally: "first, second, third."
- Say "approximations" clearly; it prevents a trap.

**Likely interviewer questions**
1. "Why did agents come so late in your career?"
2. "What did the earlier data work teach you that helps with agents?"

**Suggested answers**
1. "The tooling matured late. LLM agents that could call tools reliably only became practical recently, and I moved when they did. The earlier years weren't wasted: nearly every agent failure I see in production is a data, integration or permissions failure, not a model failure."
2. "Idempotency, schema discipline, and observability. If an ingest isn't idempotent, an agent retry duplicates work. If the data contract is loose, the agent hallucinates around gaps. Those habits are why Beacon starts with a quarantine and an upsert before it ever calls a model."

**Transition.** "Now, the part that matters most: how I deliver. I've organized it around the six competencies you assess."

---

#### Slide 6 — Middle (divider): *How I deliver. Mapped to the six competencies you assess*

**Purpose.** Reset attention and signal a shift from background to substance.

**Recommended delivery time.** 0:05.

**Verbatim-ready speaking script**

> "Let me move from who I am to how I deliver, organized around the six competencies you assess."

**Delivery and emphasis cues.** One breath. Do not elaborate.

**Likely interviewer questions**
1. "Where do you think you're strongest of the six?"

**Suggested answers**
1. "Build and deploy, and integration. Those are where I have the longest track record, with delivered work I can show. Where I'm still ramping is the Agentforce-specific layer, and I'll be explicit about that on the next slide."

**Transition.** "Here's the evidence map."

---

#### Slide 7 — Middle | Competency Snapshot: *Where the evidence lives, and where I am still ramping*

**Purpose.** This is the credibility slide. It shows you can assess yourself honestly, and it pre-empts the Agentforce gap.

**Recommended delivery time.** 1:30. Do not rush.

**Verbatim-ready speaking script**

> "This is the slide I'd most like you to hold me to. For each of the six competencies, I've listed the proof and the level of evidence: whether it's delivered work from my resume, shown in Beacon, or still in progress.
>
> On influencing stakeholders, I held the room with architects and sponsors, about forty percent onsite at J.P. Morgan and Highbridge. On innovation and AI readiness, the evidence is staged autonomy, where a golden-set eval gates every prompt change. On agility, it's getting from sketch to a customer environment in under five days, and how I separate ambiguity from uncertainty, which I'll show on a later slide. On build and deploy, it's containerized, audit-ready services on EKS and AKS with architecture decision records. On integration, REST, gRPC, webhooks, Kafka, SSO and SAML, with idempotent ingest.
>
> The last row is the honest one. I've delivered with LangGraph, LangChain and LlamaIndex. On Agentforce I'm ramping. And I want to be specific about how: I'm working in a developer org, I've mapped Beacon onto Agentforce topics, actions, the Trust Layer, Prompt Builder and the testing tools, and I'd close the rest by building, not reading. I haven't given myself numeric scores, because evidence is better than self-ratings."

**Delivery and emphasis cues**
- Slow down for the last row. Look at the camera for "I'm ramping."
- Pause 2 seconds after "evidence is better than self-ratings." Let them react.

**Likely interviewer questions**
1. "How will you close the Agentforce gap, concretely?"
2. "Why should we hire someone who's ramping on our core platform?"
3. "Give me one example of 'Influence stakeholders' where you changed someone's mind."
4. "Which of these claims is weakest?"

**Suggested answers**
1. "Three steps in my first thirty days: map Beacon's pieces onto Agentforce (the triage topic and instructions, Apex invocable actions, Prompt Builder for the classification prompt, Flow for approvals), build the eval gate using the platform's testing tooling, and shadow a Deployment Strategist's discovery sessions. The mapping already exists on P2-S16; the first 30 days make it real in a customer-shaped org."
2. "Because the hard part of forward-deployed work isn't the product surface; it's discovery, integration, guardrails, evals and getting a customer to adopt. Product features I can learn in weeks. Those other skills take years, and I have them. I'd also bring a cross-framework view: when LangGraph or custom orchestration is the right tool and when it isn't, which is on P1-S12."
3. "I'd rather use a pattern than invent a story: when sponsors and SOC analysts disagree about trust in auto-close, I don't argue; I propose a staged-autonomy rollout where the override rate decides. That moves the argument from opinion to data. [**Prep note:** have one real, specific stakeholder story from J.P. Morgan or Balyasny ready, with no confidential names or numbers.]"
4. "The Agentforce row, which is why I've labelled it. The second weakest is Beacon's evidence, which is a reference build rather than a customer result, and that's labelled too."

**Transition.** "Let me take the competencies in turn, starting with influence."

---

#### Slide 8 — Middle | Influence Stakeholders: *I work the whole room, not just the keyboard*

**Purpose.** Show you navigate multiple stakeholders and give both interviewers something specific: outcomes and repeatability for Kaytie, adoption and strategy for Anand.

**Recommended delivery time.** 1:00.

**Verbatim-ready speaking script**

> "In a deployment there are at least seven audiences, and each one needs something different from me. The executive sponsor cares about value and risk. The customer's architects care about integration and security. The Deployment Strategist cares about adoption and scope. Sales or the solutions engineer cares about expectations, and I want to keep what we've promised and what we can build in sync. Customer engineers care about enablement, because they'll own it after me. And the product team cares about getting field feedback they can act on.
>
> My job is to be the builder and the translator in the middle. Three mechanisms keep everyone aligned: a weekly requirements ledger, an architecture decision record for every meaningful trade-off, and customer-facing demos early and often, so disagreement shows up in week two, not week ten."

**Delivery and emphasis cues**
- Name the two roles in the room by title ("a Deployment Strategist like Anand's team") only if it feels natural; do not flatter.
- Emphasize "week two, not week ten."

**Likely interviewer questions**
1. "What do you do when the sponsor and the customer architect disagree?"
2. "How do you split the work with a Deployment Strategist?"
3. "How do you handle a sales promise that engineering can't deliver?"

**Suggested answers**
1. "Make the trade-off visible. I write it up as an ADR: the options, the cost, the reversibility and my recommendation, and put it in front of both. Sponsors usually care about risk and timeline; architects about security and operability. An ADR lets both see their concern was priced, and it makes the decision reversible if we're wrong."
2. "The Deployment Strategist owns adoption, scope and the commercial relationship; I own the components, the integrations and the technical truth. Discovery is shared: they lead the business conversation, I lead the technical probing, and we compare notes against the weekly requirements ledger."
3. "Early, and in the customer's presence if appropriate, not behind their back. I'd show what the prototype does, name the gap, and offer a path: de-scope, phase, or an alternative. I'd then take the gap to the Deployment Strategist and product so it doesn't repeat."

**Transition.** "Underneath all that is how I handle the unknown, which is agility."

---

#### Slide 9 — Middle | Agility: *Ambiguity is a question. Uncertainty is an experiment.*

**Purpose.** Deliver the single most important mental model in the deck (explicit Round 1 coaching). Make it memorable and concrete.

**Recommended delivery time.** 1:30. Do not rush.

**Verbatim-ready speaking script**

> "The most useful distinction I've learned in discovery is between ambiguity and uncertainty, because they need opposite responses.
>
> Ambiguity means the information exists. Somebody knows; nobody wrote it down. The right response is to ask, decide, and document it in an ADR. In Beacon, the question 'what counts as Critical?' was ambiguity. The CISO knew, I asked, and it became a score of seventy-five or more, logged in an ADR.
>
> Uncertainty means it can't be known yet. No meeting will answer it; you need evidence. The right response is a cheap experiment, a reversible decision, and a trigger to revisit. In Beacon, 'will classification hold on new log sources?' was uncertainty. So we shipped with golden-set evals, shadow mode and a drift alert, rather than debating it.
>
> And that's the loop at the bottom: name it, classify it, ask or experiment, log it in the ADR, review weekly. Deviations surface early, because every open item has a type, an owner, and a revisit date."

**Delivery and emphasis cues**
- Hold up two beats: "ambiguity... uncertainty." Pause between them.
- Slow down at "a cheap experiment, a reversible decision, and a trigger to revisit."
- Look at the camera at the final sentence.

**Likely interviewer questions**
1. "Give me an example where you misclassified one as the other."
2. "How do you stop endless discovery?"
3. "What if the customer won't commit to a decision?"

**Suggested answers**
1. "A classic one: treating 'what is the SLA for this feed?' as uncertainty and building monitoring for a threshold that actually existed in a contract nobody had read. Asking first would have been cheaper. I now ask the 'does anyone know?' question before I design an experiment. [**Prep note:** only use this if it matches something you did; otherwise say 'the reverse mistake is more common, and it looks like this' and give the hypothetical clearly.]"
2. "Time-box it. Every open item gets an owner and a revisit date; if a question has been ambiguous for two weeks, it's escalated to the sponsor as a decision, not a discovery task."
3. "I make the default explicit and reversible. 'Unless you tell me otherwise by Friday, we'll use seventy-five as the Critical threshold, and we can change it with one config change.' Silence then becomes a decision, with a paper trail."

**Transition.** "Agility means getting to something real quickly, so let me talk about build and deploy."

---

#### Slide 10 — Middle | Build and Deploy: *Ship in days, harden in weeks, hand over cleanly*

**Purpose.** Show a repeatable delivery rhythm and the habit of documenting trade-offs.

**Recommended delivery time.** 1:00.

**Verbatim-ready speaking script**

> "My rhythm is discover, sketch an MVP, harden, observe, enable. The first goal is speed to something real: at Balyasny I've gone from a sketch to a working MVP in the customer's environment in under five days. That speed matters because a running prototype surfaces the real requirements faster than any document. Using Cursor and Claude in the workflow has made production delivery roughly fifty percent faster for me.
>
> But speed is only half. At J.P. Morgan I took field tools and hardened them into containerized, audit-ready microservices on EKS and AKS, with an ADR for every trade-off, so that a risk reviewer could see why each decision was made. And at Millburn I built reusable SDK starter kits, which is how you scale one engagement into many.
>
> One caution on the chart: those phase durations are illustrative of my typical pace, not measured figures, so please don't read them as data."

**Delivery and emphasis cues**
- Say "illustrative, not measured" clearly and without apology.
- Emphasize "enable"; it is the handover.

**Likely interviewer questions**
1. "Fifty percent faster than what, and how did you measure it?"
2. "What do you cut to ship in five days?"
3. "How do you stop an MVP becoming production by accident?"

**Suggested answers**
1. "It's my estimate of time-to-production on comparable work before and after adopting AI-assisted development. It's an estimate, not a controlled study, and I'd describe it that way. [**Prep note:** be ready to name the comparison; if you cannot, say 'my own before-and-after estimate'.]"
2. "Breadth, not safety. I cut features, polish and secondary integrations, never authentication, audit logging or guardrails. The MVP is narrow but it is already safe to put in front of a user."
3. "An explicit hardening phase with exit criteria, agreed with the customer before the MVP ships: evals in CI, observability, runbook, rollback. If those aren't done, it's still a prototype, and we label it as such."

**Transition.** "Fast delivery only helps if the agent can reach the customer's systems, which is integration."

---

#### Slide 11 — Middle | Integration Platform and Ecosystem: *Agents are only as useful as the systems they can reach*

**Purpose.** Show you design integrations (not just consume them) and know the reliability patterns.

**Recommended delivery time.** 1:15.

**Verbatim-ready speaking script**

> "Left to right: on the left are the systems of record the customer already has: Splunk, ServiceNow, Archer, Jira. They connect through a standard integration layer, REST, gRPC, webhooks or Kafka, with OAuth 2.0 and SAML single sign-on. In the middle is the agent layer, Agentforce or LangGraph. On the right are the destinations: Data 360, Snowflake, Databricks or BigQuery for history and analytics, and Salesforce apps such as Lightning Web Component dashboards and Flow approvals.
>
> The three patterns in the table are the ones that bite in production. First, idempotent upsert on an external ID: webhooks retry, and a retry must never create a duplicate. Second, dead-letter quarantine: bad data is kept, with a reason, never silently dropped. Third, a headless API layer, so the same action can be called by an agent, a Flow or a human UI. On Salesforce those map to Apex REST, Platform Events, Data 360 connectors and MuleSoft where the customer already has it."

**Delivery and emphasis cues**
- Narrate the diagram left to right; name each cluster.
- Slow down on "retry must never create a duplicate."

**Likely interviewer questions**
1. "What happens when a downstream system is down?"
2. "Why a headless API layer rather than calling tools directly from the agent?"
3. "How do you handle auth between the agent and a non-Salesforce system?"

**Suggested answers**
1. "Retries with backoff for transient errors, a queue so we apply back-pressure instead of dropping, a dead-letter path for poison messages, and a visible status so users know the action is pending. For anything irreversible, I fail closed: no action, escalate to a human."
2. "One governed action surface means one place to enforce permissions, validation and audit, and any caller (agent, Flow, UI, a different agent framework) gets identical behavior. It also lets us swap the agent layer without rewriting integrations."
3. "OAuth 2.0 with scoped credentials and least privilege, secrets in a vault, short-lived tokens, and the agent never holding long-lived credentials directly. On Salesforce I'd use Named Credentials, which keep secrets out of code."

**Transition.** "So which tool do I reach for: platform or framework? That's the next slide."

---

#### Slide 12 — Middle | AI Ecosystems and Frameworks: *Right tool for the job: framework or platform*

**Purpose.** Demonstrate judgment, not tribal loyalty. Probably the best slide for Kaytie.

**Recommended delivery time.** 1:15. Do not rush.

**Verbatim-ready speaking script**

> "People ask me 'LangChain or Agentforce?' as if it's a loyalty test. It isn't. It's a question about where the data lives, who operates it and how fast you need to learn.
>
> When the work lives in Salesforce data and needs governed access, masking, audit, and admin-owned change, Agentforce is the natural choice: those are built in, and a LangGraph build would make me re-create them. When I need custom multi-agent graphs, non-Salesforce systems, or fast research iteration, LangGraph or LlamaIndex is faster to experiment with.
>
> So my rule is four steps. Start where the data and permissions already live. Prototype in the faster tool. Ship in the one the customer can operate. And join the two with a versioned API. That last part is what makes the choice reversible."

**Delivery and emphasis cues**
- Say the four-step rule slowly, counting on the camera if natural.
- Pause after "Ship in the one the customer can operate."

**Likely interviewer questions**
1. "When would you choose LangGraph in a Salesforce shop?"
2. "Why does 'admin-owned' matter so much?"
3. "Is the Trust Layer something you can replicate?"

**Suggested answers**
1. "When the workflow spans several non-Salesforce systems with complex branching and loops, or when we need to test retrieval strategies quickly. Then I'd front it with a versioned API and, if the customer wants it inside Salesforce long term, port the proven pattern to Agentforce topics and actions."
2. "Because a deployment's success is decided after I leave. If only an engineer can change a prompt or a threshold, the customer is dependent on me. Admin-owned means the customer's team can adjust and operate it."
3. "You can replicate pieces: masking, logging and policy checks. But doing it per project is expensive, and getting it audit-grade is harder than it looks. Where the platform provides it, I'd use it and spend my time on what's unique to the customer. [**Prep note:** check the current Trust Layer feature list before the interview.]"

**Transition.** "Whichever tool you choose, the next question is how much autonomy the agent gets."

---

#### Slide 13 — Middle | Drive Innovation and AI Readiness: *Autonomy is earned with evidence, not granted by a slide*

**Purpose.** Show a concrete, defensible framework for safe AI rollout.

**Recommended delivery time.** 1:30. Do not rush.

**Verbatim-ready speaking script**

> "I don't ask a customer to trust an agent; I let the agent earn it. Autonomy moves in four levels. Level zero, the agent suggests. Level one, a human approves. Level two, it acts on its own for low-risk cases. Level three is broader autonomy.
>
> You move up only by passing gates. First, an eval gate: at least ninety-five percent on the golden set, run in CI. Second, a trust metric: the human override rate has to be below a threshold the sponsor agreed to in advance. Third, safety: guardrails are code, not prompt text, because prompts can be talked around. Fourth, rollback: one switch takes you back to the previous level.
>
> The chart shows the first step in Beacon: prompt version one passed sixty-four percent of a fourteen-case golden set, and version two passed all of them. The point isn't the numbers; it's that we can measure a change before it ships."

**Delivery and emphasis cues**
- Count the four levels on your fingers only if your camera frames your hands; otherwise count verbally.
- Emphasize "guardrails are code, not prompt text."

**Likely interviewer questions**
1. "Why 95%? Where does that number come from?"
2. "A 14-case golden set is tiny. Why should I trust it?"
3. "Who decides the override-rate threshold?"

**Suggested answers**
1. "It's a starting default, not a law. The right gate depends on the cost of an error. A threshold for auto-closing low-risk items can be looser than one for anything touching customer data. I'd set it with the sponsor in the first workshop. Note too that on fourteen cases a ninety-five percent gate means all fourteen must pass, since thirteen of fourteen is 92.9%."
2. "You shouldn't, as a measure of real-world accuracy. If all fourteen pass, the statistics only support a true pass rate of roughly 77% or better at 95% confidence (the exact lower bound is $0.025^{1/14} \approx 0.77$). It's a regression gate, a tripwire, not an accuracy claim. In a deployment I'd grow it from production overrides and hold out cases the prompt was never written against."
3. "The sponsor and the SOC lead, with data. I'd show the override rate trend at each review and let them set the line. It's their risk appetite, not mine."

**Transition.** "That's the how. Now what it's worth, which is the business value."

---

#### Slide 14 — Closing (divider): *Business value: Outcomes the sponsor can take to a CFO*

**Purpose.** Signal a shift from engineering to economics. Frame: numbers a CFO could challenge.

**Recommended delivery time.** 0:10.

**Verbatim-ready speaking script**

> "Engineering only matters if it produces something the sponsor can defend to a CFO, so let me put numbers on Beacon, with the assumptions on the table."

**Delivery and emphasis cues.** Say "assumptions on the table" with emphasis; it sets up the honesty on the next slide.

**Likely interviewer questions**
1. "Do you think in business terms by default?"

**Suggested answers**
1. "I try to. In discovery the second question after 'what's the problem?' is 'what is it costing, and how would we know it's fixed?' Without that, there's nothing to measure and no way to show value."

**Transition.** "Here's the model."

---

#### Slide 15 — Closing | ROI: *Capacity returned to analysts, with the cost on the table*

**Purpose.** Present the ROI with total honesty about inputs and sensitivity. This slide is where the careless candidate loses credibility.

**Recommended delivery time.** 1:15.

**Verbatim-ready speaking script**

> "Here's the model. Four thousand findings a month, seventy percent in scope, so twenty-eight hundred. Each in-scope finding saves about thirteen point six minutes of an eighteen-minute baseline. At eighty-five dollars an hour loaded, that's about six hundred thirty-five hours and fifty-four thousand dollars of capacity a month. Subtract a six-thousand-dollar monthly run cost, and the net is about forty-eight thousand dollars, a modelled ROI of about eight hundred percent, which I define as net value divided by run cost.
>
> Now the part I most want you to hear: these are assumptions, not facts. The eighteen minutes is a baseline I'd confirm in discovery, and the thirteen point six is modelled in Beacon from assumed analyst minutes per outcome, not stopwatch-measured. I'd replace every input with the sponsor's numbers in the first workshop. At half the volume, the case is still about three hundred fifty percent. And I frame it as capacity redeployed to higher-risk work, not headcount cut."

**Delivery and emphasis cues**
- Slow down for each number. Round aloud (say "about").
- Make eye contact on "assumptions, not facts."
- If screen-sharing the app, **click "Run agent on all" first** or the ROI tab shows 14 min / 653 h / 826% (see trap below).

**Likely interviewer questions**
1. "Why is half the volume 350% and not 400%?"
2. "How would you validate the 18-minute baseline?"
3. "Isn't 'capacity redeployed' just a euphemism for layoffs?"
4. "What would make this ROI wrong?"

**Suggested answers**
1. "The run cost doesn't halve. Gross at half volume is $26,973; subtract the same $6,000 and net is $20,973; divided by $6,000 that's 349.6%. Fixed costs make ROI non-linear in volume, which is why I show the sensitivity."
2. "Time-and-motion on a sample: sit with analysts, record real triage time per finding by type, and compare to the ticketing system's timestamps. I'd also separate time to first touch from time to resolution."
3. "It's a fair challenge. The honest answer is that it depends on the sponsor's choices. In the security case, analyst capacity is chronically short, so the realistic benefit is less backlog and more time on high-risk findings. I'd write the redeployment plan into the success criteria with the sponsor so we measure it."
4. "Volume lower than assumed, in-scope rate lower, the baseline overstated, override rate high enough that humans redo the agent's work, or run cost higher once evals, monitoring and review time are included. Each is a named input I'd stress-test."

**Technical math, if asked to derive**

$$
\text{Gross}=N\,p\,\frac{s}{60}\,w,\qquad \text{Net}=\text{Gross}-C,\qquad \text{ROI}=\frac{\text{Net}}{C}
$$

with $N=4000$, $p=0.7$, $s=13.6$ min, $w=\$85$, $C=\$6000$: gross $=2800\times\frac{13.6}{60}\times 85\approx\$53{,}947$, net $\approx\$47{,}947$, ROI $\approx 7.99=799\%$. Payback on run cost is about $6000/53947\times 30\approx 3.3$ days of a month.

**Transition.** "Let me pull it together."

---

#### Slide 16 — Closing | Summary and Bottom Line: *Three points to remember*

**Purpose.** Land three memorable claims and tie to the job description.

**Recommended delivery time.** 0:45.

**Verbatim-ready speaking script**

> "Three things I'd like you to remember. One: I deliver in customer environments. Seventeen years, twenty-five to forty percent onsite, MVPs in under five days. Two: I make AI safe to ship: guardrails as code, evals in CI, staged autonomy. Three: I prove value: telemetry from day one and an ROI the sponsor can defend.
>
> Your job description asks for real code, real environments and measurable business impact. That is how I've worked for seventeen years, and Agentforce is the platform where I want to do it next."

**Delivery and emphasis cues.** Camera, steady pace, pause after each numbered point. Don't read the box text.

**Likely interviewer questions**
1. "What's the one thing you'd want us to remember?"
2. "What worries you about this role?"

**Suggested answers**
1. "That I'll be useful in the first week and leave the customer more capable than I found them."
2. "Breadth. The product surface moves quickly and every customer environment is different. My answer is to build early in a developer org and let the real customer constraints teach me."

**Transition.** "Let me show how I'd spend my first ninety days."

---

#### Slide 17 — Closing | First 90 Days (Proposed): *How I would earn trust in the first 90 days*

**Purpose.** Show a concrete, humble plan, labelled as a proposal. Answers Kaytie's "great first 90 days" question.

**Recommended delivery time.** 0:30 (up to 1:00 if asked).

**Verbatim-ready speaking script**

> "This is a proposal for us to tailor together. In the first thirty days I learn the pod and the platform: shadow Deployment Strategist discovery sessions and map Agentforce topics, actions, the Trust Layer and Prompt Builder onto Beacon in a developer org. By day sixty I own a component: ship one scoped piece in a live deployment, stand up its eval gate and telemetry, and send the first field insight to product, with a reproduction. By day ninety I lead and multiply: co-lead a customer workshop with the Deployment Strategist, turn a repeated pattern into a reusable starter kit, and leave the customer team able to run it without me. Success is customer outcomes, reusable assets, and a team that can operate the solution. And I'll name Agentforce depth as my ramp area and close it by building, not reading."

**Delivery and emphasis cues.** Emphasize "proposed" and "tailor together." Keep it to three beats.

**Likely interviewer questions**
1. "What if you're dropped into a customer in week two?"
2. "How would you measure success at 90 days?"

**Suggested answers**
1. "Then I learn on the job, paired with someone experienced, and I'd take the component with the most familiar shape, like integration or evals, so I'm contributing while ramping on the platform."
2. "One component in production with an eval gate and telemetry, one field insight accepted by product, a reusable asset others used, and a customer who says they can run it. I'd agree these with Kaytie in week one."

**Transition.** "I'd love to hear from you, so let me turn it around."

---

#### Slide 18 — Closing | Questions and Why Salesforce: *Why I want this role, and what I would like to learn from you*

**Purpose.** Show curiosity; ask sharp questions; then stop talking.

**Recommended delivery time.** 2:00–5:00 (this is your question block at ~37:00).

**Verbatim-ready speaking script**

> "Kaytie, one thing I'd love to understand: what does a great first ninety days look like for an FDE in this pod, and how do you measure FDE impact: outcomes, reusable assets, or both?
>
> Anand, from the deployment side: where do deployments tend to stall most, data access, security review or adoption? And what separates the pods that scale from the ones that stay one-offs?
>
> And if there's time: how does field feedback reach the Agentforce product teams, and is there an example that changed the roadmap?"

**Delivery and emphasis cues.** Ask one question, then stop and listen. Take notes visibly. Do not fill silences. Thank them by name.

**Likely interviewer questions**
1. "Why Salesforce rather than another AI company?"
2. "Why now?"

**Suggested answers**
1. "Because of the combination: real customers with real data and permissions, a platform that already carries the governance (identity, audit, trust) that most AI projects have to build, and an FDE role that is explicitly about code in customer environments."
2. "Agents are crossing from demos to production, and the hard part has shifted to deployment, guardrails and adoption, which is the work I've spent seventeen years on."

**Transition.** "Thank you. I'd love to build this with you."

---

### 4. Consolidated Interview Q&A (Presentation 1)

**Q1. How do you handle ambiguous requirements from a customer?** *(Why: core FDE competence; Round 1 coaching.)*
Answer: "I separate ambiguity from uncertainty. Ambiguity means someone knows: I ask, decide and write it in an ADR. Uncertainty means it can't be known yet: I run the cheapest experiment, keep the decision reversible and set a trigger to revisit. Every open item has a type, an owner and a revisit date, so deviations surface early." *If probed:* give the "What counts as Critical?" (ambiguity → score ≥75, ADR) versus "will classification hold on new log sources?" (uncertainty → golden set, shadow mode, drift alert) pair from P2-S5.

**Q2. How do you decide between Agentforce and LangGraph?** *(Why: judgment, platform fit.)*
Answer: P1-S12 rule: start where data and permissions live, prototype in the faster tool, ship in the one the customer can operate, join them with a versioned API. *If probed:* governance (Trust Layer, masking, audit) and admin ownership favor Agentforce; non-Salesforce systems, custom multi-agent graphs and research velocity favor LangGraph.

**Q3. What's your actual Agentforce experience?** *(Why: the visible gap.)*
Answer: say precisely what you built and where; then: "My depth is orchestration, guardrails and evals; I'm ramping on Prompt Builder, the Trust Layer and Testing Center, and I've mapped Beacon onto each." *If probed:* walk P2-S16 row by row. Never claim a feature you haven't touched. **Reconcile P1-S4 "Agentforce deployments" with P1-S7 "ramping" in advance.**

**Q4. How do you keep an agent from doing something harmful?** *(Why: safety and governance.)*
Answer: "Defense in depth. Deterministic scoring the LLM can't change; guardrails as code (G1 PII never auto-closed, G2 Critical needs a human, G3 low confidence needs a human, G4 injection blocked); staged autonomy; rollback switch; full telemetry." *If probed:* explain why prompt-only defenses fail (the model can be talked around) and that no defense against injection is perfect, hence least privilege and human approval for irreversible actions.

**Q5. Walk me through how you'd show ROI to a CFO.** *(Why: Anand's lens.)*
Answer: P1-S15 model, stressing inputs as assumptions, sensitivity, and "capacity redeployed." *If probed:* derive the half-volume 349.6% and explain fixed run cost.

**Q6. How do you collaborate with a Deployment Strategist?** *(Why: pod fit.)*
Answer: "They own adoption, scope and the commercial relationship; I own components, integration and technical truth. We run discovery together and reconcile against a weekly requirements ledger." *If probed:* give how you would escalate a scope conflict (ADR, reversible default, sponsor decision).

**Q7. Tell me about a time something failed in production.** *(Why: ownership.)*
Answer: use the 99.2% story (prompt/context/tool-routing fixes) or P2-S11's prompt v1 failure, stating clearly which is real work and which is Beacon. *If probed:* root cause, detection, fix, regression test, and what changed in process.

**Q8. What would you do differently on Beacon?** *(Why: reflection.)*
Answer: "Replace the keyword stub with a real LLM behind the same interface, build the golden set from real analyst decisions with a held-out split, and measure analyst minutes by stopwatch rather than assume them." *If probed:* explain why the current v2 is effectively a training set (P2-S10 caveat).

### 5. Presentation Timing and Rehearsal Strategy (Presentation 1)

| Slide | Role in live interview | Time if used |
|---|---|---|
| S1 | Opening hand-off | 0:20 |
| S2, S3 | Skip if P2 already presented | 1:00 / 0:20 |
| S4 | JD fit, on demand | 0:45 |
| S5 | On demand | 0:45 |
| S6 | Divider, 5 s | 0:05 |
| S7 | Deliberate, honest | 1:30 |
| S8 | Stakeholders | 1:00 |
| S9 | Ambiguity vs uncertainty | 1:30 |
| S10 | Build/deploy | 1:00 |
| S11 | Integration | 1:15 |
| S12 | Framework vs platform | 1:15 |
| S13 | Staged autonomy | 1:30 |
| S14 | Divider | 0:10 |
| S15 | ROI | 1:15 |
| S16 | Summary | 0:45 |
| S17 | First 90 days | 0:30–1:00 |
| S18 | Questions | 2:00–5:00 |

Full front-to-back would total about 17–19 minutes, which does **not** fit; it is a bank. If forced into a 10-minute competency-led path: S1, S7, S9, S12, S13, S15, S17 (≈9:30). **Shorten first:** S2, S3, S5, S10. **Never rush:** S7, S9, S13, S15.

Rehearsal plan: (1) read S7, S9, S12, S13, S15 aloud twice; (2) record yourself on camera for each and check eye line and pace; (3) have a partner challenge you with the Q&A above, with no notes; (4) time the 10-minute path.

### 6. Final Presentation Readiness Assessment (Presentation 1)

**Strengths:** the evidence-level column on S7 is rare and credible; S9 and S13 are crisp, reusable mental models; S12 shows judgment over loyalty; ROI on S15 is now honestly labelled "modelled."
**Risks to prepare:** (1) Agentforce claim consistency between S4 and S7; (2) the 99.2% and "50% faster" figures need defined denominators/comparisons; (3) onsite percentages are approximations; (4) one real stakeholder story is needed for S7/S8; (5) S10's phase chart is illustrative.
**Readiness:** high on structure and content; moderate until the two items above are rehearsed with specifics.

---

## Presentation 2 — `SALESFORCE_FINAL_ROUND_OPEN_SOURCE_DEMO__1_.pptx` (use the enhanced copy)

*Enhanced-copy change specific to this deck beyond the table above: on P2-S3 the "AI tools used" line was removed from the "Honest framing" box and from that slide's notes, as requested. Slide count and numbering are unchanged.*

### 1. Presentation Overview

A 22-slide deck: an 18-slide **core path (about 14 minutes, with a 5-minute live demo)** and a 4-slide **appendix** (S19 divider, S20 data pipeline, S21 agent outcomes, S22 evidence boundary) for questions or demo failure. It walks **Beacon**, an agentic governance-risk-compliance "control tower": findings from sources such as Splunk, CloudTrail, ServiceNow and Archer are ingested idempotently, scored deterministically, triaged by an agent with four code-level guardrails, logged as telemetry, and evaluated with a golden set and a modelled ROI. Central message: **"Real code, real guardrails, measurable value, and I'm honest about what's built versus designed."**

Facts to hold in your head: 18 events in, 14 accepted, 4 quarantined (duplicate, invalid severity, missing required field, malformed JSON). Of 14 findings: 4 auto-closed, 6 assigned, 3 held for approval, 1 blocked. Guardrails fired 5 times (G1 ×1, G2 ×2, G3 ×1, G4 ×1). Prompt v1 64.3% (9/14) → v2 100% on the 14-case golden set. 660 ms average latency (simulated). 3.17 hours saved. ROI inputs: 4,000 findings/month, 70% in scope, 13.6 min saved, $85/h, $6,000 run cost.

### 2. Recommended Presentation Strategy

- **Say the framing in the first minute:** reference build, synthetic data, modelled value (P2-S1/S3). Then they can't "catch" you later.
- **Spend your time where the signal is:** S5 (first conversation), S6 (architecture), S7 (decisions), the demo, S10 (why prompt v1 failed). Deliver S1, S3, S9, S12, S15, S17 fast.
- **Pauses:** Pause 1 after S6 ("any questions on the architecture before I show it running?"); Pause 2 after S10 (the demo and evals). Wait at least 4 seconds at each.
- **Dashed boxes** on S6 are the target Salesforce mapping, not run live. Say this before they ask.
- **ROI tab trap:** click **Run agent on all** before opening the ROI tab (fully run: 13.6 min, 635 h, $53,947, $47,947, 799%; if only one finding triaged: 14 min, 653 h, $55,533, $49,533, 826%).
- **Demo failure plan:** run `run-cli-demo.bat`; if that fails, go to S20/S21 and narrate.
- **Be ready for the stub question:** the classifier is a keyword stub standing in for an LLM; latency is simulated. Say it in one sentence, then redirect to what Beacon proves: the surrounding system (pipeline, guardrails, evals, telemetry) is what is hard, and it is model-agnostic.

### 3. Slide-by-Slide Rehearsal

#### Slide 1 — 15-Minute Walkthrough | Open Source Repo: *Beacon: An Agentic GRC Control Tower*

**Purpose.** Frame Beacon honestly in one breath and establish what you'll show.

**Recommended delivery time.** 0:10–0:15.

**Verbatim-ready speaking script**

> "Beacon is a reference build I made from patterns I've used in customer work. It's open source on my GitHub, it uses synthetic data, and the savings I'll show are modelled assumptions. It's an agent that triages security and compliance findings, with guardrails, a data pipeline, evals and an ROI model, and it runs locally on a laptop and maps onto a Salesforce org. Let me start with who I am."

**Delivery and emphasis cues.** Camera. Say "reference build," "synthetic," "modelled" with a small emphasis each, without apologizing.

**Likely interviewer questions**
1. "Is this running on Salesforce right now?"
2. "Why GRC?"

**Suggested answers**
1. "The demo you'll see runs locally with a Node server and a web UI. The repo also contains the Salesforce mapping: Apex REST ingest, an invocable action, an LWC. The Salesforce pieces are the target mapping and, as the dashed boxes show, aren't run live in this demo. [**Prep note:** be precise about which Apex/LWC artifacts exist in the repo; P2-S22 lists 'Agentforce topic as the runtime in a customer org' as designed, not shown.]"
2. "Because it's a domain I know from client work: high alert volume, inconsistent triage, audit pressure, and a high cost of a wrong automatic decision. That makes guardrails and evidence non-negotiable, which is exactly where forward-deployed judgment matters."

**Transition.** "First, a minute on me."

---

#### Slide 2 — Opening | Introduction: *17 years of putting software where customers live*

**Purpose.** Introduction with the three-role arc, then bridge to Beacon.

**Recommended delivery time.** 1:00.

**Verbatim-ready speaking script**

> "Thank you, Kaytie and Anand. I'm Shaikat. Seventeen-plus years, three forward-deployed roles in New York finance and governance, risk and compliance. At Millburn Ridgefield, 2008 to 2022, I built data and integration systems: Python and Java pipelines, BigQuery, Snowflake, Kafka and reusable SDK starter kits. At J.P. Morgan and Highbridge, 2022 to 2025, I moved to agent orchestration, with LangChain, LlamaIndex, and headless APIs into ServiceNow and Archer, hardening everything into audit-ready services on EKS and AKS. At Balyasny, since 2025, it's agents in production: Agentforce, LangGraph, GRC and SOC actions, dashboards, and MVPs in under five days. I've been onsite with customers twenty-five to forty percent of the time.
>
> What I do is design the agent's intelligence, own components end to end, and co-build with the customer so their team is more capable when I leave. Beacon is a reference build of those patterns."

**Delivery and emphasis cues.** Don't recite dates; hit the three verbs: data, orchestration, production. Camera for the last sentence.

**Likely interviewer questions**
1. "What's one thing from those roles that shaped how you built Beacon?"
2. "What's the most difficult customer you've worked with?"

**Suggested answers**
1. "Audit. In J.P. Morgan and Highbridge settings, every decision had to be explainable later. That's why Beacon's scoring is deterministic, guardrails are code, and every run writes a telemetry record."
2. "[**Prep note:** choose a real example without confidential details.] Pattern: a sponsor whose expectations were ahead of the data. I'd bring a working prototype within days, show the data gaps honestly, and re-scope with them rather than argue."

**Transition.** "Let me restate what you asked me to cover and how I'll use the time."

---

#### Slide 3 — Opening | Agenda, Assigned Prompt: *Fourteen minutes of content, one minute of buffer*

**Purpose.** Prove you understood the prompt; commit to a time plan.

**Recommended delivery time.** 0:20.

**Verbatim-ready speaking script**

> "You asked what I built and why, my approach and key decisions, the challenges, the collaboration, the deployment and impact, and the current state. I'll take about a minute and a half on me, three and a half on the problem and approach, five on a live demo with evals, a minute on challenges and collaboration, and three on impact, with a minute of buffer. I've also been plain about the framing: this is a reference build with synthetic data, and the value is modelled, with assumptions I'd replace with the sponsor's numbers."

**Delivery and emphasis cues.** Don't read the chevrons. Camera on the framing sentence.

**Likely interviewer questions**
1. "Did you use AI tools to build this?"
2. "How much of Beacon did you write yourself?"

**Suggested answers**
1. "Yes. I use AI-assisted tools in my normal workflow, and I think a modern FDE should. I'm accountable for the design, the guardrail logic, the evals and every line I ship. I can walk through any of it. [**Prep note:** the 'AI tools used' line was removed from this slide. Decide your exact, truthful wording in advance and stick to it; do not claim more or less than is true.]"
2. "I can explain and defend every component: the scoring function, the four guardrails, the pipeline and the eval harness. If you pick any file in the repo, I'll walk you through it."

**Transition.** "So, the problem."

---

#### Slide 4 — Opening | What I Built and Why: *Analysts spend 18 minutes on every finding. Most are noise.*

**Purpose.** Establish the problem, the agreed success criteria, and the headline numbers, carefully labelled as assumed or modelled.

**Recommended delivery time.** 0:50.

**Verbatim-ready speaking script**

> "The sponsor in this scenario is a CISO or GRC lead. The pain is familiar: alert volume, inconsistent triage, and audit pressure. In the baseline I've assumed, an analyst spends about eighteen minutes on every finding, and most of them are noise. I'd confirm that eighteen in discovery.
>
> Before writing any code I'd agree what success means with the sponsor: hours returned to analysts, no critical finding acted on without a human, and every decision auditable. Those three are on the left. In the demo run, the model has the agent saving about thirteen point six minutes per finding, and zero critical findings were acted on without a human. And every decision is logged as an Agent_Run record.
>
> The bar chart shows why that number is what it is: analyst minutes by outcome. An auto-closed finding costs about half a minute, an assigned one about four, one waiting for approval about six, and a blocked one gets the full eighteen. Those are modelled minutes, so the thirteen point six is a modelled saving, not a stopwatch measurement."

**Delivery and emphasis cues.** Pause after "Most are noise." Slow on "modelled." Point out the chart bars by name.

**Likely interviewer questions**
1. "Where does 13.6 come from?"
2. "Why is a blocked finding 18 minutes, the same as baseline?"
3. "How would you validate the baseline with the customer?"

**Suggested answers**
1. "It's the weighted average. Across 14 findings: four auto-closed at 0.5, six assigned at 4, three pending approval at 6, one blocked at 18, which is 62 minutes, about 4.4 per finding. Eighteen minus 4.4 is about 13.6. [**Prep note:** I reconstructed the per-outcome minutes from the chart; confirm them in the repo.]" 
   $$\bar m=\frac{4(0.5)+6(4)+3(6)+1(18)}{14}=\frac{62}{14}\approx 4.43,\quad 18-4.43\approx 13.57$$
2. "A blocked finding was an injection attempt, so I assume a human handles it fully, with no time saved. It's a conservative assumption."
3. "A time-and-motion sample with real analysts, comparing ticket timestamps by finding type, before I'd put any number in front of a CFO."

**Transition.** "Now, how I approached it. I started with decisions, not technology."

---

#### Slide 5 — Middle | Approach: The First Conversation: *I started with decisions, not technology*

**Purpose.** Show discovery skill: separating ambiguity from uncertainty and turning each into a decision or an experiment.

**Recommended delivery time.** 1:10. Do not rush.

**Verbatim-ready speaking script**

> "The first conversation with the CISO and the SOC lead wasn't about models. It was: what decision do analysts make hundreds of times a week, and what does a wrong automatic decision cost? That question drove the whole design.
>
> Then I sorted every open question into two types. Three were ambiguity, meaning somebody knows the answer. What counts as Critical? I asked the CISO: a score of seventy-five or more, written into an ADR. Which findings may auto-close? A SOC workshop answered it: low band, confidence at least zero point eight five, no personal data. Which systems hold personal data? Pulled from the data catalog into the Asset object.
>
> Three were uncertainty, where no meeting can answer. Will classification hold on log sources it hasn't seen? We use golden-set evals, shadow mode and a drift alert. Will analysts trust auto-close? Staged autonomy, tracking the override rate. How does it behave in a real incident surge? A queue with back-pressure, and only reversible decisions. And every deviation surfaces in a weekly requirements ledger I review with the Deployment Strategist."

**Delivery and emphasis cues.** Group in threes: "three ambiguities, three uncertainties." Slow down for the Critical threshold. Eye contact on "what does a wrong automatic decision cost?"

**Likely interviewer questions**
1. "Why 75 for Critical and 0.85 for auto-close? Where did those come from?"
2. "What if the CISO and SOC lead disagree?"
3. "How does shadow mode work?"

**Suggested answers**
1. "In Beacon they're configurable defaults standing in for what the sponsor would decide. In a real engagement I'd calibrate them against historical findings with the SOC lead and revisit them with override data. The ADR records who decided and why, so it's auditable."
2. "I take it as a trade-off: write the options with cost and reversibility, and show the data. Often it's resolved by staging: the stricter rule first, loosen once the override rate says it's safe."
3. "The agent runs on live traffic and records what it would have done, but takes no action. We compare against analyst decisions to estimate agreement and error cost before granting any autonomy."

**Transition.** "Here's how those decisions turned into an architecture."

---

#### Slide 6 — Middle | Architecture: *Architecture, mapped to the Salesforce platform* (PAUSE 1)

**Purpose.** Demonstrate architectural ownership: data flow, boundaries, idempotency, guardrails and telemetry. Say the dashed-box caveat.

**Recommended delivery time.** 1:00 plus the pause (up to 2:00 if they ask questions).

**Verbatim-ready speaking script**

> "I'll walk it left to right, and one caveat first: the dashed boxes are the target mapping on Salesforce, not what runs live in the demo.
>
> On the far left are the sources: Splunk or CloudTrail for security events, ServiceNow or Archer for tickets and controls. They post into an ingest API, which on Salesforce is Apex REST, and it upserts on an external ID, so a retried webhook can never create a duplicate. Next a validation step dedupes and quarantines bad records, keeping them with a reason. Good records land as Finding objects, enriched with Control and Asset context.
>
> The triage agent, an Agentforce topic with actions on the platform, calls tools to fetch that context and compute the score. Between its recommendation and any action sit guardrails G1 to G4 and, where needed, a human approval through Flow. Every run writes an Agent_Run record: telemetry. The Control Tower UI, a Lightning Web Component, reads Findings and Agent_Runs to show KPIs and ROI. Underneath, an eval harness runs the golden set in CI, and at scale Data 360 or Snowflake holds history.
>
> Regulators and frameworks—such as the NIST AI Risk Management Framework and the **EU AI Act** — mandate that enterprise software must implement "Risk Tiering" or a "Chain of Responsibility".

> Engineers adapt these regulatory buckets into systematic "G-Series" code exceptions to handle them programmatically:
>   * **G1 (Compliance Gate):** Checks basic legal/privacy baselines (e.g., GDPR/HIPAA compliance via **PII masking**).
>   * **G2 (Operational Safety Gate):** Checks brand safety or massive system damage (**Critical** failures, prohibited actions, or structural violations).
>   * **G3 (Statistical Threshold Gate):** Evaluates if the math/probability broke down (**Low Confidence** outputs that fail deterministic scoring rules).
>   * **G4 (Security/Adversarial Gate):** Identifies active malicious manipulation (**Prompt Injections** or system hijacking attempts).
>
> In short, the terms are a synthesis of **Stage-Gate engineering architecture** combined with **regulatory risk tiering**, customized to give developers an explicit blueprint for intercepting bad AI behavior before it reaches a customer.
>
> The table shows the same thing locally versus on Salesforce: the Node server maps to an LWC, the engine tools map to an invocable Apex action usable by Agentforce, Flow and REST, and the local POST endpoint maps to an Apex REST resource.
>
> Before I show it running, are there any questions on the architecture?"

**Delivery and emphasis cues.** Slow down; narrate by position ("top-left", "the guardrails box in the middle"). Emphasize "idempotent," "guardrails are code," "everything writes telemetry." Then **pause 4+ seconds** and wait.

**Likely interviewer questions**
1. "Why Apex REST and not Platform Events or MuleSoft for ingest?"
2. "What happens at ten times the volume? Governor limits?"
3. "Why keep the guardrails in Apex rather than in the topic instructions?"
4. "Where's the security boundary and what can the agent touch?"

**Suggested answers**
1. "Apex REST is the simplest synchronous, idempotent entry point for a first release. For bursty or high-volume feeds I'd put Platform Events or a queue in front for decoupling and back-pressure, and use MuleSoft where the customer already runs it. It's an ADR decision driven by volume and the customer's existing integration estate."
2. "At scale you hit Apex governor limits per transaction and API limits per org, so I'd batch (bulk upserts of up to 200 records), move heavy work to asynchronous Apex or a queue, and keep high-volume history in Data 360 or Snowflake rather than core objects. In Release 1 I'd measure first; the design for scale is on S13, and I'd label it as designed, not proven. [**Prep note:** confirm current limits in Salesforce docs.]"
3. "Topic instructions are natural language, so a clever input can argue around them. Code is deterministic, testable and auditable, and it runs whatever the model says. I use instructions to guide the agent and code to bound it."
4. "The agent only calls a small set of invocable actions, each running with the permissions the org grants it. It can read Finding, Control and Asset context and propose a status. It cannot close Critical or personal-data findings; that's enforced in code at the action boundary. Least privilege, with the data model controlling what it can see."

**Transition (after the pause).** "Let me tell you three decisions in that diagram that I'd defend hardest."

---

#### Slide 7 — Middle | Key Technical Decisions: *Three decisions that keep it safe and auditable*

**Purpose.** Show judgment: where to use a probabilistic model and where not to.

**Recommended delivery time.** 0:30–0:45.

**Verbatim-ready speaking script**

> "Three decisions. One: deterministic scoring. The score is severity plus category plus control criticality plus asset context, an auditable formula. The model only classifies the finding's category; it never sets the score. So a CISO can audit the math.
>
> Two: guardrails as code. G1: personal data is never auto-closed. G2: Critical needs a human. G3: low confidence needs a human. G4: prompt injection is blocked. They're code because prompts can be talked around.
>
> Three: telemetry first. Every run records latency, tokens, minutes saved and which guardrails fired. That feeds the KPIs and the ROI, and it's the same record I'd show an auditor. You can't prove ROI you didn't measure.
>
> The table at the bottom is the data model: Finding is the normalized event, Control and Asset carry context, and Agent_Run is telemetry."

**Delivery and emphasis cues.** Three clear beats; hold up three fingers on camera only if framing allows. Emphasize "never sets the score."

**Likely interviewer questions**
1. "If the LLM only classifies, what's the risk of a misclassification?"
2. "Why not let the LLM score? Isn't a fixed formula brittle?"
3. "How do you defend against prompt injection beyond G4?"

**Suggested answers**
1. "A wrong category shifts the category component of the score, so the blast radius is bounded: a misclassified Low can't auto-close unless confidence, band and personal-data conditions are all met, and Critical always goes to a human. Misclassification is caught by evals and by overrides."
2. "A formula is rigid, but rigid is the point for auditability and tuning: weights are explicit and changeable via ADR. I'd happily let a model propose weights offline, but a person approves the formula, not the model at runtime."
3. "Layers: treat all ticket text as data, never as instructions; least-privilege actions; no tool the model can call that can do irreversible harm without a human; output validation; and monitoring for anomalous tool use. On Salesforce, the Trust Layer adds prompt defense and masking. No single layer is perfect; the guardrails bound the damage."

**Transition.** "Now let me show it running."

---

#### Slide 8 — Live Demo | 5 Minutes: *Beacon in action*

**Purpose.** Switch cleanly to the live app.

**Recommended delivery time.** 0:05 (the demo itself is about 4:30).

**Verbatim-ready speaking script**

> "I'll switch to the app now. I'll narrate each step and tell you which Salesforce piece it maps to."

**Delivery and emphasis cues.** Switch the shared window to the browser first. Verify the audience sees it ("Can you see the app?"). Zoom the browser to 125% beforehand.

**Likely interviewer questions**
1. "Is this the real thing or a recording?"

**Suggested answers**
1. "It's running live on my machine. If anything misbehaves I have a CLI version that shows the same run in the terminal."

**Transition.** "Starting with the pipeline."

---

#### Slide 9 — Demo | Run of Show: *What you will see, and the Salesforce piece behind each step*

**Purpose.** The demo script. Keep this slide handy; narrate from the app, not the slide.

**Recommended delivery time.** 4:30 total, with these beats.

**Verbatim-ready speaking script (narrate in the app)**

> **0:00, Data Pipeline.** "Eighteen events came in. Fourteen were accepted and four quarantined, each with a reason: duplicate, invalid severity, missing required field, malformed JSON. Nothing is silently dropped. On Salesforce this is the Apex REST upsert, with Data 360 later."
>
> **0:45, Run agent on all.** "I'll run the agent across all findings. For each, you can see the tool trace: what it fetched and how it scored it. That visibility is how analysts come to trust it. On the platform these tools are Apex invocable actions."
>
> **1:30, E-1002, public S3 bucket.** "This is Critical. The agent recommends, but guardrail G2 holds it for a human approval; on Salesforce, a Flow approval."
>
> **2:15, E-1010, injection.** "This ticket contains text telling the agent to close everything. G4 blocks it. We treat ticket text as data, never as instructions."
>
> **2:45, E-1009, PII asset.** "This asset holds personal data, so G1 means it's never auto-closed, whatever the confidence."
>
> **3:15, Prompt Evals.** "Version one passed 64 percent of the golden set; version two passes all fourteen. I'll explain why on the next slide."
>
> **4:00, ROI tab.** "Sponsor inputs on the left, net value on the right. Everything here is an editable assumption."

**Delivery and emphasis cues.** Slow, deliberate mouse movements; name what you're clicking. After each guardrail moment, say what it prevents. Do not narrate faster than the screen updates.

**Likely interviewer questions**
1. "Why did E-1002 stop and E-1009 not auto-close, since both involve humans?"
2. "What's the classifier actually doing?"
3. "Show me the Agent_Run record for one finding."

**Suggested answers**
1. "Different guardrails for different risks: G2 is severity (Critical needs approval); G1 is data sensitivity (personal data is never auto-closed, so it's assigned to an owner). Both keep a human in the loop but route differently."
2. "It's a keyword stub standing in for an LLM, and the latency is simulated. The point of Beacon is the system around the model: pipeline, scoring, guardrails, evals, telemetry. Swapping in an LLM changes the classifier behind the same interface, which is why the evals matter so much."
3. "Yes: latency, tokens, minutes saved, guardrails fired, per run. [**Prep note:** rehearse opening one record in the UI.]"

**ROI tab trap.** Always click **Run agent on all** first. Fully run: 13.6 min, 635 h, $53,947 gross, $47,947 net, 799%, about 3 days to recover run cost. One finding only: 14 min, 653 h, $55,533, $49,533, 826%. Half volume: about 350%.

**Transition.** "Let me explain why that first prompt failed."

---

#### Slide 10 — Demo | Prompt Evals: *I can tell you why the first prompt failed* (PAUSE 2)

**Purpose.** The JD line: explain why a prompt failed and what you changed. Pair it with honesty about the 14-case set.

**Recommended delivery time.** 0:45 (including the pause), after about 4:30 of demo.

**Verbatim-ready speaking script**

> "Version one passed nine of fourteen, sixty-four percent, and it failed for three root causes plus one process gap. First, a vocabulary gap: it didn't recognize exposure terms like public-read, zero-dot-zero-dot-zero-dot-zero slash zero, or unencrypted. Second, negation: 'no evidence of malware' was labelled malware, because keyword matching sees the word. Version two adds a negation pre-check. Third, there was no identity class, so impossible travel and MFA-off events had no home; version two adds one. And the process gap: no regression gate. Now the golden set runs in CI with a ninety-five percent gate.
>
> One caveat I'd rather say than have you find: version two scores a hundred percent on a set its keywords were written against, so it is effectively a training set. The takeaway isn't the hundred percent; it's the process: a golden set, a measured regression, a fix, and a CI gate. For real use I'd hold out cases and grow them from analyst overrides.
>
> That's the demo. I'll pause here for questions."

**Delivery and emphasis cues.** Slow on the caveat; look at the camera. Then silence for 4 seconds.

**Likely interviewer questions**
1. "How would you evaluate a real LLM classifier differently?"
2. "How do you stop evals from becoming stale?"
3. "How would you test prompt injection resistance?"
4. "Why does a keyword stub count as a prompt?"

**Suggested answers**
1. "Held-out data from real findings, stratified by category and severity; precision and recall per class rather than a single pass rate; confusion matrix on the expensive errors (a missed Critical); confidence calibration; and repeated runs, since LLMs are non-deterministic, with a threshold on variance."
2. "Every human override becomes a candidate eval case; a weekly review adds them; drift alerts trigger a refresh. The suite should grow from production failures."
3. "A red-team set of injection strings in the ticket text: instructions to close, to reveal data, to ignore rules. Expected outcome is always 'blocked or routed to a human,' asserted in CI, and I'd add new attacks as they're seen."
4. "Fair. It's a stand-in for the classification step so I can demonstrate the harness and the failure analysis deterministically. The failure modes it shows (vocabulary, negation, missing class) are the same ones LLM prompts show, and the process transfers unchanged."

**Statistical intuition (if asked)**

With $n=14$, a result of 14/14 supports only a true pass rate $p\ge 0.025^{1/14}\approx 0.77$ at 95% confidence (two-sided exact lower bound). A 95% gate on 14 cases is therefore a 100% gate. A regression tripwire, not an accuracy estimate.

**Transition.** "Let me be candid about what went wrong along the way."

---

#### Slide 11 — Challenges: *Four obstacles, four fixes*

**Purpose.** Show ownership and learning. Tell two as stories.

**Recommended delivery time.** 0:30.

**Verbatim-ready speaking script**

> "Four obstacles, and I'll tell you two as stories. First, the prompt injection. A ticket comment told the agent to close everything. That could have forced a close, so G4 became code: ticket text is treated as data. Second, trust. Analysts don't trust black boxes, so we exposed the tool trace and measure the override rate, and let the data settle the argument. The other two, briefly: prompt v1 missed five of fourteen, which led to the eval harness and the CI gate; and noisy duplicate events led to the idempotent upsert and quarantine."

**Delivery and emphasis cues.** Tell the injection story with a beat of drama: "told the agent to close everything." Don't read the table.

**Likely interviewer questions**
1. "Was the injection a real incident or a test case in Beacon?"
2. "What was the hardest of the four?"
3. "What fails next if you scale?"

**Suggested answers**
1. "In Beacon it's a test finding I built (E-1010) to model a realistic attack on ticket text. I'd be careful not to present it as a customer incident."
2. "Trust, because it isn't solved by engineering alone. Guardrails and evals can make it safe, but adoption needs transparency and time. That's why the tool trace and staged autonomy exist."
3. "Likely volume spikes in a real incident, and drift on new log sources. I've designed for both (queue and back-pressure, drift alerts), but they're designed, not demonstrated."

**Transition.** "None of this was done alone."

---

#### Slide 12 — Collaboration: *A pod, not a hero*

**Purpose.** Show cross-functional navigation and how you handle disagreement, using roles, not names.

**Recommended delivery time.** 0:30.

**Verbatim-ready speaking script**

> "A deployment is a pod. The executive sponsor owns value and risk; the Deployment Strategist, adoption and scope; the SOC lead, thresholds and workflow; the customer architects, integration and security; the product team, platform feedback. I own components and integration.
>
> When we disagree, I do four things. I bring evidence, the eval numbers and the tool trace, not opinions. I make the trade-off visible in an ADR with options, cost and reversibility. I use staged autonomy so data settles trust arguments. And I feed platform gaps back to product, with a reproducible example."

**Delivery and emphasis cues.** Name the roles quickly; slow down on the four disagreement tactics.

**Likely interviewer questions**
1. "Tell me about a time you lost an argument and what you did."
2. "How do you handle a stakeholder who wants more autonomy than the evidence supports?"

**Suggested answers**
1. "[**Prep note:** prepare a real one.] Pattern: I recommended a stricter threshold, the sponsor chose a looser one with a rollback, and I made sure we measured. When the override rate rose, the data gave us a calm conversation instead of an argument."
2. "I agree to the goal and propose the path: 'we can get to auto-close, and here are the gates.' It converts a no into a roadmap with evidence checkpoints."

**Transition.** "Now the path to production."

---

#### Slide 13 — Deployment: *Release 1 earns trust. Scale earns savings.*

**Purpose.** Show phased delivery: a safe, measurable first release and a credible path to scale. Clarify designed vs demonstrated.

**Recommended delivery time.** 0:40.

**Verbatim-ready speaking script**

> "Release one is designed to earn trust. Autonomy: shadow mode, suggest and approve only. Data: the idempotent Apex REST ingest. Quality: a golden set with a ninety-five percent gate. Operations: a rollback switch and telemetry. Value: hours returned, measured.
>
> Scale is where savings come from, and each step is conditional. Auto-close low-risk findings only after the override rate is below the agreed threshold. Move history to Data 360 or Snowflake. Add drift alerts and weekly eval refresh. Add queue and back-pressure, service-level objectives and an on-call runbook. And track cost per finding and the override rate trend. I'll be clear that the right-hand column is designed, not demonstrated; it's the plan I'd propose."

**Delivery and emphasis cues.** Emphasize the contrast "trust" then "savings." Say "designed, not demonstrated."

**Likely interviewer questions**
1. "What exactly do you need to see before turning on auto-close?"
2. "What are your SLOs?"
3. "How do you handle an incident where the agent misbehaves?"

**Suggested answers**
1. "Evals passing the gate on a held-out set; shadow-mode agreement with analysts on low-risk findings above an agreed level; an override rate below the sponsor's threshold for a sustained period; and a tested rollback."
2. "I'd propose them with the sponsor, not impose them: availability of the ingest, time-to-triage, and a correctness measure like the share of auto-closed findings later reopened. I wouldn't quote numbers before seeing the customer's baselines."
3. "Flip the rollback switch to the previous autonomy level, preserve the telemetry, do a blameless review, add the failure as an eval case, and only then re-enable."

**Transition.** "So what's it worth?"

---

#### Slide 14 — Impact | ROI: *About $48K net value per month in the modelled case*

**Purpose.** Present the ROI crisply, with assumptions.

**Recommended delivery time.** 0:40.

**Verbatim-ready speaking script**

> "In the modelled case: four thousand findings a month, seventy percent in scope, thirteen point six minutes saved each, eighty-five dollars an hour loaded, six thousand a month to run. That's about six hundred thirty-five hours returned, about fifty-four thousand dollars gross, about forty-eight thousand net, a modelled ROI of about eight hundred percent: net over run cost. At half the volume it's still about three hundred fifty percent, with run cost held. And it's capacity redeployed to higher-risk work, not headcount cut. Every one of those inputs is an assumption I'd replace with the sponsor's numbers in the first workshop."

**Delivery and emphasis cues.** Say "about" with every figure. Pause after "not headcount cut."

**Likely interviewer questions**
1. "Is 799% credible?"
2. "What's missing from the run cost?"

**Suggested answers**
1. "As an arithmetic output, yes; as a forecast, no, which is why I call it modelled. It's high because the assumed saving is large and the run cost small. The credible claim is the method and the sensitivity, and the numbers become real only with the sponsor's data."
2. "Probably people time: evals, monitoring, human review of the escalations, and platform licensing. I'd build those in during discovery; it would reduce ROI, and I'd show that."

(Full derivation: see P1-S15.)

**Transition.** "And today?"

---

#### Slide 15 — Current State: *Running today: measured, monitored, improvable*

**Purpose.** Answer the "current state" part of the prompt: what's observable and how it improves.

**Recommended delivery time.** 0:25.

**Verbatim-ready speaking script**

> "In the demo run: fourteen of fourteen findings triaged, five guardrails fired, about six hundred sixty milliseconds average latency, which is simulated, and about three point one seven hours saved, which is the modelled minutes again. The chart shows which guardrails fired. The improvement loop has four verbs. Monitor: per-run telemetry and the KPI dashboard. Gate: golden-set evals in CI before any prompt change ships. Learn: every human override becomes a new eval case. Escalate: platform gaps go to product with a repro."

**Delivery and emphasis cues.** Say "simulated" for latency without hesitation.

**Likely interviewer questions**
1. "Why do you call it 'running today' if it's a reference build?"
2. "What would you alert on?"

**Suggested answers**
1. "I mean the local build is running and instrumented, and the loop is how a customer deployment would run. I'm not claiming production traffic."
2. "Eval pass rate falling, override rate rising, guardrail firing spikes, latency and error rates, and drift in the category mix of incoming findings."

**Transition.** "How does this land on your platform?"

---

#### Slide 16 — Closing | How This Lands on Salesforce: *The same pattern on Agentforce, Data 360 and Flow*

**Purpose.** Show platform homework. This is the Round 1 coaching answer. Verify names before the interview.

**Recommended delivery time.** 0:35.

**Verbatim-ready speaking script**

> "Every piece maps. The triage topic and instructions become an Agentforce agent topic. The tools (asset, control, score) become Apex invocable actions or Flow. The classification prompt, v1 to v2, becomes a versioned Prompt Builder template. PII masking, audit and injection defense are the Einstein Trust Layer plus my Apex guardrails. Pipeline and history map to Data 360, Snowflake or Databricks. Approval and routing are Flow approvals and Omni-Channel. The Control Tower is a Lightning Web Component. And the eval harness is Agentforce testing plus a golden set in CI. Agentforce may not exist in a free org, so the demo calls the same Apex action from an in-org console. I'd start building this in a customer-shaped environment on day one."

**Delivery and emphasis cues.** Don't read all rows; emphasize 3 (topic, Prompt Builder, Trust Layer). Own the ramp honestly.

**Likely interviewer questions**
1. "What does the Trust Layer do that your guardrails don't?"
2. "Where would Agentforce make this harder, not easier?"
3. "Why would you keep Apex guardrails if the Trust Layer exists?"

**Suggested answers**
1. "They're complementary. The Trust Layer handles platform-level concerns like data masking, audit and safety on prompts and responses; my guardrails encode this customer's business policy: personal data is never auto-closed, Critical needs approval. Platform controls can't know that policy. [**Prep note:** check the current Trust Layer feature list.]"
2. "Possibly in testing and iteration speed: debugging a topic's reasoning is less transparent than stepping through my own code. And governor and API limits shape the design. I'd learn those constraints early."
3. "Because business rules must hold regardless of how the model behaves, and they must be unit-testable. Defense in depth."

**Transition.** "Let me close."

---

#### Slide 17 — Closing | Summary: *What to take away*

**Purpose.** Land built, proved, valued; then ask for the conversation.

**Recommended delivery time.** 0:20–0:30.

**Verbatim-ready speaking script**

> "What I built: an agent with guardrails, a pipeline, evals and telemetry. What I proved in the demo: eval improvement from sixty-four to a hundred percent on a small set, four of fourteen auto-closed, three held for a human, one blocked. What it's worth: about forty-eight thousand dollars net a month, modelled, with the sponsor's numbers to replace mine. Real code, real guardrails, measurable value. I'd love to do this on Agentforce for your customers. I'd welcome your questions."

**Delivery and emphasis cues.** Camera. Then stop and wait.

**Likely interviewer questions**
1. "What would you build next on Beacon?"
2. "What is the single biggest weakness?"

**Suggested answers**
1. "Replace the stub with a real LLM behind the same interface, build a held-out eval set, measure analyst time by stopwatch, and port the agent to a real Agentforce topic."
2. "That it hasn't met a customer. Every design decision in it is defensible, but only a real deployment would tell me which ones are wrong."

**Transition.** "Before I ask my questions, I'd love to hear yours."

---

#### Slide 18 — Closing | Questions and Why Salesforce: *Why I want this role, and what I would like to learn from you*

**Purpose.** Hold in reserve until about 37:00; show curiosity.

**Recommended delivery time.** 0:30 in the walkthrough; 3–5 minutes at the end.

**Verbatim-ready speaking script**

> "Kaytie, what does a great first ninety days look like for an FDE in this pod, and how do you measure FDE impact, outcomes, reusable assets, or both? Anand, where do deployments stall most, data access, security review or adoption, and how do FDEs and Deployment Strategists split discovery? Real code, real environments, measurable business impact: that's how I've worked for seventeen years, and Agentforce is where I want to do it next. Thank you; I'd love to build this with you."

**Delivery and emphasis cues.** One question at a time; then silence. If short on time, skip the slide and say the bottom line aloud.

**Likely interviewer questions**
1. "What would make you decline an offer?"

**Suggested answers**
1. "A role that's described as forward-deployed but really isn't, where there's no access to customers or to production. Everything you've told me suggests that isn't this."

**Transition.** "Happy to go deeper on anything, including the backup slides."

---

#### Slide 19 — Backup | Only If Asked: *Appendix: Pipeline detail, agent outcomes, and what is built versus designed*

**Purpose.** Divider. Do not present unless asked or the demo fails.

**Recommended delivery time.** 0:05.

**Verbatim-ready speaking script**

> "I have three backup slides on the pipeline, the agent's outcomes, and what's built versus designed. Which would you like?"

**Delivery and emphasis cues.** Offer, don't push.

**Likely interviewer questions**
1. "What's built versus designed?"

**Suggested answers**
1. "Go straight to S22."

**Transition.** "Starting with the pipeline."

---

#### Slide 20 — Backup | Data Pipeline: *18 events in, 14 accepted, 4 quarantined: nothing silently dropped*

**Purpose.** Show data-quality discipline; demo fallback.

**Recommended delivery time.** 1:00.

**Verbatim-ready speaking script**

> "Eighteen events came in. Fourteen were accepted. Four were quarantined, one for each reason: a duplicate, an invalid severity, a missing required field and malformed JSON. The donut shows the split and the bars show the reasons, one record each. The principle is that bad data is kept, with a reason, so we can fix the source and replay, and nothing is silently dropped. The same idempotent upsert runs as Apex REST on Salesforce, keyed on the external ID."

**Delivery and emphasis cues.** Name each chart; slow on "silently dropped."

**Likely interviewer questions**
1. "How do you replay quarantined records?"
2. "How do you deduplicate across sources?"

**Suggested answers**
1. "Fix the source or the validation rule, then re-submit through the same ingest; because the upsert is idempotent, replays are safe."
2. "By a stable external ID per source event; the second arrival updates rather than inserts. Cross-source duplicates need a correlation key, which I'd define with the customer's data owners."

**Transition.** "And the agent's outcomes."

---

#### Slide 21 — Backup | Agent Outcomes: *Human where it matters, automation where it is safe*

**Purpose.** Show how autonomy is distributed across risk and confidence.

**Recommended delivery time.** 1:00.

**Verbatim-ready speaking script**

> "Of fourteen findings: four auto-closed, six assigned to owners, three held for approval and one blocked. The scatter plots risk score on the horizontal axis against confidence on the vertical. The auto-closed ones sit at low risk and high confidence. Critical or low-confidence findings force a human. So automation is concentrated where it's cheap to be wrong, and humans where it isn't."

**Delivery and emphasis cues.** Point out the cluster in the top-left verbally ("low risk, high confidence").

**Likely interviewer questions**
1. "Why is one dot at confidence around 0.55?"
2. "Are 4 auto-closed findings enough to learn from?"

**Suggested answers**
1. "That's the low-confidence case: G3 routes it to a human. It shows the guardrail catching uncertainty."
2. "No. It's an illustration. In a deployment, shadow mode would produce thousands of comparisons before auto-close is enabled."

**Transition.** "Finally, the evidence boundary."

---

#### Slide 22 — Backup | Evidence Boundary: *What I demonstrated, and what I only designed*

**Purpose.** The credibility close. Volunteer limits so nobody can "find" them.

**Recommended delivery time.** 1:00.

**Verbatim-ready speaking script**

> "Left column, what I demonstrated: idempotent ingest, 18 in, 14 accepted, 4 quarantined; triage across all findings with a visible tool trace; guardrails G1 to G4 firing five times; human approval for a critical finding; prompt evals from sixty-four to a hundred percent on a fourteen-case set, with a keyword stub classifier; and per-run telemetry with an ROI tab.
>
> Right column, what I designed but didn't show: shadow mode and staged autonomy rollout; drift alerts and weekly eval refresh; queue, back-pressure, SLOs and an on-call runbook; Data 360 and Snowflake history at scale; Agentforce as the runtime in a customer org; and sponsor-confirmed baselines.
>
> Plainly: synthetic data, eighteen events, a golden set that version two was written against, a keyword stub instead of an LLM, simulated latency and modelled ROI. This is a reference build of patterns I've used with customers, not a customer result."

**Delivery and emphasis cues.** Slow, even tone. Camera for the last sentence. Pause after it.

**Likely interviewer questions**
1. "So what do you actually have evidence for, in customer work?"
2. "Why should we take the design column seriously?"

**Suggested answers**
1. "From my resume: customer-facing delivery across three firms, ServiceNow and Archer integrations, containerized audit-ready services with ADRs, MVPs in under five days, and the 99.2% reliability improvement. Beacon packages patterns from that work; it doesn't replace it."
2. "Because each item has a known failure mode and a known mitigation, and I've built the pieces of them before. But I'd rather you hold me to showing them in your environment than take my word."

**Transition.** "That's everything; I'm happy to go anywhere you'd like."

---

### 4. Consolidated Interview Q&A (Presentation 2)

**Q1. Why is the LLM only allowed to classify?** *(Why: architecture and safety.)* "Because classification is the part that benefits from language understanding, and everything else must be auditable. Score, guardrails and routing are deterministic, so a CISO can verify the math and a failure of the model is bounded." *If probed:* what happens when the classifier is wrong (bounded by guardrails; caught by evals/overrides).

**Q2. A keyword stub isn't an LLM. What have you actually proven?** *(Why: reality check.)* "The system around the model: idempotent ingest, deterministic scoring, code guardrails, eval harness, telemetry. These are model-agnostic and are where most deployments fail. The stub lets me demonstrate failure analysis deterministically." *If probed:* describe how the LLM swap affects evals (non-determinism, held-out data, per-class metrics).

**Q3. How would this scale to 10× volume?** *(Why: scalability.)* "Queue and back-pressure in front of ingest, bulk and asynchronous processing, history in Data 360 or Snowflake, and monitoring on latency and queue depth. On Salesforce, mind governor and API limits. All designed, not demonstrated." *If probed:* batching (bulk upsert), async Apex, Platform Events.

**Q4. What are the security and governance risks?** *(Why: enterprise readiness.)* "Prompt injection, over-broad permissions, data leakage through prompts, and unauditable actions. Mitigations: treat text as data, least-privilege actions, masking via the Trust Layer, telemetry for every run, and human approval for irreversible actions." *If probed:* how to red-team and test it.

**Q5. How do you make analysts adopt it?** *(Why: Anand's lens.)* "Visible tool trace, human gates early, override rate as a trust metric, and a staged path to autonomy that analysts and the SOC lead control. Adoption is earned." *If probed:* training, feedback channel, weekly review of overrides.

**Q6. What does Release 1 look like, and how long?** *(Why: deployment realism.)* "Shadow mode, suggest-and-approve, idempotent ingest, golden-set gate, rollback and telemetry. I'd aim for a working MVP in the customer's environment in under five days, then harden over weeks. Durations are illustrative and depend on access and security review." *If probed:* what typically stalls (data access, security review).

**Q7. How would you measure success after launch?** *(Why: outcomes.)* "Hours returned (validated by time sampling), override rate, missed-Critical count (target zero), eval pass rate, cost per finding, and auditor satisfaction." *If probed:* separate leading from lagging indicators.

**Q8. What would you do differently?** *(Why: reflection.)* "Held-out evals from day one, stopwatch-measured analyst time, a real LLM, and testing earlier on a real Salesforce org with Agentforce instead of mapping on paper."

**Q9. How did you use AI tools while building it?** *(Why: modern FDE practice, honesty.)* "I use AI-assisted development as part of my workflow and I'm accountable for what ships; I can explain any component. [Prep: agree the exact truthful wording beforehand.]"

### 5. Presentation Timing and Rehearsal Strategy (Presentation 2)

| Slide | Target | Running | Notes |
|---|---|---|---|
| S1 | 0:10 | 0:10 | framing |
| S2 | 1:00 | 1:10 | fast |
| S3 | 0:20 | 1:30 | fast |
| S4 | 0:50 | 2:20 | careful: "modelled" |
| S5 | 1:10 | 3:30 | **don't rush** |
| S6 | 1:00 | 4:30 | **Pause 1** |
| S7 | 0:30 | 5:00 | |
| S8 | 0:05 | 5:05 | switch to app |
| S9 / demo | 0:10 + ~4:30 | ~9:45 | live |
| S10 | 0:15–0:45 | 10:00 | **Pause 2** |
| S11 | 0:30 | 10:30 | |
| S12 | 0:30 | 11:00 | |
| S13 | 0:40 | 11:40 | |
| S14 | 0:40 | 12:20 | |
| S15 | 0:25 | 12:45 | |
| S16 | 0:35 | 13:20 | |
| S17 | 0:20 | 13:40 | |
| S18 | 0:30 | 14:10 | |

This is the built-in budget; with the two pauses it will run to roughly 15–16 minutes, which fits the 14-minute-plus-buffer plan. **If behind by 1+ minute at S9:** cut S2 to 30 s, skip S12, compress S13 to two sentences. **If the demo runs long:** show only the pipeline, E-1002, E-1010 and the evals; talk the ROI tab over S14. **Never rush:** S5, S6, S10. **Appendix:** S19–S22 are ~4 minutes if all are requested; S22 is the one to use first when asked "what's real?".

Rehearsal: (1) run the demo end to end three times with a timer; (2) rehearse S5, S6, S10 without slides; (3) do one full run with the ROI trap deliberately triggered and recovered; (4) practice the stub-question answer until it is one sentence; (5) do one rehearsal over Google Meet with the same window setup as the interview.

### 6. Final Presentation Readiness Assessment (Presentation 2)

**Strengths:** the ambiguity/uncertainty table; the architecture-to-decision logic; guardrails as code; a rare level of honesty (S22) that converts weaknesses into credibility; a clean mapping to Salesforce on S16.
**Risks:** (1) the stub classifier and 14-case set will be probed, and your answer must be short and unembarrassed; (2) the ROI tab trap; (3) "modelled vs measured" wording discipline; (4) Agentforce hands-on depth; (5) scale and governor-limit questions (designed only); (6) the 13.6-minute derivation (confirm per-outcome minutes in the repo).
**Readiness:** strong on content and structure. Close the remaining gap by rehearsing the stub, ROI-trap and Agentforce answers aloud.

---

## Final Cross-Presentation Interview Preparation

### Overall narrative consistency

One story: *I deliver in customer environments (P1-S2, S5, S10) → I make AI safe to ship (P1-S13; P2-S7, S10) → I prove value (P1-S15; P2-S14).* P1 supplies the competency evidence; P2 supplies the proof object. Terminology is consistent across both: Critical = score ≥ 75; auto-close = Low band, confidence ≥ 0.85, no PII; G1–G4; v1 64% → v2 100%; ROI 799% / 350%.

**Consistency points to keep tight:**
- Always say **"modelled"** for 13.6 min, $53,947, $47,947, 799%, 3.17 h.
- ROI = net ÷ run cost.
- Agentforce: pick one honest sentence and use it everywhere (P1-S4 says "deployments"; P1-S7 says "ramping").
- Onsite share: "25–40%", per-role bars are approximations.

### Most important technical differentiators

1. Deterministic scoring with the LLM confined to classification.
2. Guardrails as code, bounding the blast radius of any model failure.
3. Ambiguity vs uncertainty discovery method, producing ADRs and experiments.
4. Evals as a regression gate, with honest awareness of their statistical limits.
5. Telemetry-first design that makes ROI provable.
6. Platform-vs-framework judgment (P1-S12).

### Most challenging anticipated questions

1. "A keyword stub isn't an LLM, and your golden set is a training set. What have you proven?"
2. "What have you actually done on Agentforce?"
3. "How is 13.6 minutes 'measured' if it comes from assumed minutes?" (Answer: it isn't; it's modelled; here's the arithmetic.)
4. "How would this behave at 10× volume with governor limits?"
5. "Isn't 799% a fantasy number?"
6. "Tell me about a real stakeholder conflict you lost or resolved."
7. "How would you defend against a sophisticated prompt injection?"
8. "Why should we hire someone still ramping on our platform?"

### Potential weaknesses to prepare for

| Weakness | How to handle it |
|---|---|
| Beacon is not a customer result | Say it first; point to S22 and the resume evidence. |
| Stub classifier, simulated latency | One sentence; redirect to the model-agnostic system. |
| 14-case golden set, v2 written against it | Volunteer it; emphasize the process and the held-out plan. |
| Modelled ROI | State inputs, sensitivity, "replace with sponsor numbers." |
| Agentforce depth | Name it; give the 30/60/90 plan. |
| Unverified resume figures (99.2%, 50%) | Know the denominator and comparison cold. |
| Scale is designed, not shown | Label as designed; describe the specific mechanisms. |

### Recommended final-round delivery strategy

1. Arrive early, test camera, headset, share, and the demo (including the CLI fallback) 30 minutes before.
2. Open with the plan (P1-S1), confirm audio/video, and switch to P2.
3. Speak to the lens for claims; glance at the screen for diagrams.
4. Volunteer limits before you're asked.
5. Answer in the shape: **claim → example → trade-off → how I'd validate.** Keep answers to 60–90 seconds, then stop.
6. Use both interviewers: technical depth to Kaytie, adoption and deployment to Anand; look for whoever asked.
7. End with your questions and a clear, short thank-you.

### Final 45-minute timing plan

| Clock | Segment | Slides |
|---|---|---|
| 0:00–2:00 | Greeting, plan, tech check | P1-S1 |
| 2:00–3:10 | Who I am | P2-S2 |
| 3:10–5:00 | Prompt, problem | P2-S3, S4 |
| 5:00–8:30 | Approach and architecture, **Pause 1** | P2-S5, S6 |
| 8:30–9:30 | Decisions | P2-S7 |
| 9:30–14:00 | **Live demo** and evals, **Pause 2** | P2-S8, S9, S10 |
| 14:00–16:30 | Challenges, collaboration, deployment, ROI, state, Salesforce, close | P2-S11 to S17 |
| 16:30–37:00 | Discussion and Q&A (open P1 or P2 backup by question) | P1-S4, S7, S9, S12, S13, S15; P2-S22 |
| 37:00–42:00 | Your questions | P2-S18 / P1-S18 |
| 42:00–45:00 | Close and buffer | camera only |

*Note: the clock above includes the pauses and slightly longer than the 14:10 slide budget; if you start at 2:00 and the walkthrough runs on budget, you'll finish around 16:00–16:30.*

---

## QA Audit (completed)

- **Coverage:** every slide of both presentations (P1: 18, P2: 22 = 40) has purpose, timing, spoken script, cues, questions with answers, and a transition. Each presentation has overview, strategy, consolidated Q&A, timing and readiness assessment.
- **Consistency:** slide numbers and titles match the enhanced files; the enhanced decks validate cleanly and render correctly.
- **Facts:** no customer results, benchmarks or implementation claims were invented. Items that rely on information outside the files are flagged **[Prep note]**. ROI, half-volume, payback, weighted-minutes and exact-binomial figures were recomputed and match.
- **Originals:** both original `.pptx` files are untouched.
