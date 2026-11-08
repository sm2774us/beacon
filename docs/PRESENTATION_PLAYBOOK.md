# Final Round Playbook - 2:1 Panel, 45 min (Salesforce FDE)
Panel: **Kaytie Zimmerman (VP, Forward Deployed Engineering)** + **Anand Narayan (FDE)**. 15 min presentation + demo, ~30 min Q&A.

## Honesty frame (say this early)
"Beacon is a reference build I created from patterns I have used on customer engagements - GRC/SOC triage, data pipelines, guardrails. Data is synthetic and the time-savings figures are modelled assumptions I would replace with the sponsor's numbers." Never present simulated metrics as client results. Where you cite real outcomes from your resume (e.g. 99.2% reliability, <5-day MVPs) be ready to explain how they were measured.

## Round-1 feedback -> where it lands
| Feedback | Where addressed |
|---|---|
| Ambiguity vs uncertainty | Slide 4 + the **Ambiguity vs Uncertainty** tab |
| Tie outcomes to business value/ROI | Slide 8 + **ROI** tab |
| Agentforce / Salesforce tools in FDE work | Slide 9 + **Salesforce Mapping** tab + Playground |

## 15-minute deck (9 slides, minimal text, one visual each)
| # | Min | Slide | Maps to prompt |
|---|---|---|---|
| 1 | 0:45 | Intro + agenda + assigned prompt (restate it) | Opening |
| 2 | 1:00 | Who I am: 17 yrs, customer-facing delivery, FDE pods, travel ~30%. One line per role | Intro/experience |
| 3 | 1:30 | **What and why**: analysts spend ~18 min/finding; 70% are low-risk noise; sponsor = CISO/GRC lead; success = hours returned, no missed criticals | What you built |
| 4 | 1:30 | **Discovery**: first conversation, what I asked. Ambiguities (ask) vs uncertainties (experiment) - 2 examples each | Approach / alignment |
| 5 | 1:30 | **Architecture** (diagram) + 3 key decisions: deterministic scoring, LLM only for classification, guardrails as code | Approach |
| 6 | 4:00 | **LIVE DEMO** (runbook script) | Showcase |
| 7 | 1:00 | **Challenges**: v1 prompt 64% -> v2 100% (why), injection, noisy data quarantine, trust (override rate) | Challenges |
| 8 | 1:00 | **Collaboration + deployment + impact**: Deployment Strategist, CISO, SOC lead, platform team. Release 1 = shadow mode, assign-only; Scale = auto-close, Data 360, SLOs | Collab/Deploy/Impact |
| 9 | 1:00 | **Current state + Salesforce mapping**: monitoring, drift, eval gate; Apex action/Agentforce topic/Prompt Builder/Trust Layer/Flow/LWC | Current state |
| 10 | 0:45 | Close: 3-point summary, bottom line, questions | Closing |
Plan 1-2 pauses (after slide 5 and after demo) for questions. Rehearse out loud 3x with a timer; cut slide 2 first if running long.

## Talk track (key lines)
- **Sponsor conversation**: "I started with the CISO and asked: what decision do analysts make 400 times a week, and what does a wrong auto-decision cost? That told me autonomy had to be staged."
- **Ambiguity vs uncertainty**: "Ambiguity is a missing fact someone has - I ask and document it (what is Critical?). Uncertainty is something no one can know yet (will classification hold on new log sources?) - I design a cheap experiment, keep decisions reversible, and set a trigger to revisit. I surface business deviations early by keeping an ADR log and a requirements ledger reviewed weekly with the strategist."
- **Release 1 vs scale**: R1 = shadow mode + assign/approve only + telemetry + eval gate + rollback switch. Scale = auto-close after override rate < agreed threshold, Data 360 history, queue/back-pressure, cost per finding, on-call runbook.
- **ROI**: hours returned x loaded cost - run cost, framed as capacity redeployed; present range, name assumptions, replace with sponsor numbers.
- **AI tools used building it**: Claude and Cursor for scaffolding, tests, Apex boilerplate; I reviewed every guardrail and scoring rule by hand and wrote the eval set myself.

## Salesforce-specific vocabulary to be fluent in (verify current names before the interview)
Agentforce agent + topics + instructions + actions (Apex/Flow/Prompt template); Prompt Builder; Einstein Trust Layer (masking, zero-retention, audit); Data 360 (ingest, harmonise, unify, activate); Agent Builder test/plan trace and Testing Center; Flow + approval processes; Apex invocable actions, Apex REST, LWC; permission sets and `WITH USER_MODE`; DX/CLI, scratch orgs and CI; MCP/headless; Vibes / AI coding tools. Be ready: "How does an FDE use Agentforce?" -> discover workflow, model data in the platform, build topic + actions on the customer's own objects/APIs, test with golden sets, deploy with guardrails, measure with telemetry, feed gaps back to product.

## Likely questions (prep 60-sec answers)
1. Why not let the LLM decide everything? 2. How do you evaluate non-deterministic output? 3. Walk me through a prompt that failed. 4. Customer says "just auto-close everything" - what do you do? 5. A stakeholder changes scope mid-build - how do you surface deviations? 6. How do you handle data quality? 7. How do you secure PII / prompt injection? 8. What would change at 100x volume? 9. How do you enable the customer's team to own it? 10. What platform gaps would you feed back to product? 11. Tell me about a time you pushed back on a sponsor. 12. How do you work with a Deployment Strategist?

## Closing + your questions to ask them
- "What does a successful first 90 days look like for an FDE in this pod?"
- "Where do deployments most often stall - data access, security review, or adoption?"
- "How does field feedback reach the Agentforce product teams, and can you share one that changed the roadmap?"
- "How do you measure FDE impact - customer outcomes, reusable assets, or both?"
- Close: "I enjoy being in the room where the business problem becomes a running system. Beacon is a small version of that - I would love to do it on Agentforce for your customers."
