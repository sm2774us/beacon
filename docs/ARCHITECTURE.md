# Architecture
```
Splunk/CloudTrail/ServiceNow/Archer --> Ingest (REST, idempotent) --> Validate/Normalise/Dedupe --> Quarantine (reason codes)
                                                              |
                                                              v
                                 Triage Agent: get_asset_context > lookup_control > classify(LLM prompt vX) > score_risk > guardrails
                                                              |
              +-------------------+-----------------+--------+---------+
              v                   v                 v                  v
         AUTO_CLOSED          ASSIGNED        PENDING_APPROVAL      BLOCKED
        (low, conf>=.85,    (owner queue)     (critical / low conf)  (injection)
         no PII)                                   |
                                             human approve/reject --> override-rate metric
All paths -> Agent_Run__c telemetry -> KPI dashboard (latency, tokens, minutes saved, guardrails) -> ROI
```
**Scoring**: severity x10 + category bonus + control criticality + asset (tier1 +15, tier2 +8, PII +10, internet +8), cap 100. Bands: >=75 Critical, >=50 High, >=30 Medium.
**Confidence**: 0.50 + control known .15 + asset known .15 + category found .15 + deduped .05.
**Guardrails**: G1 PII never auto-closed; G2 Critical needs human; G3 confidence < 0.6 needs human; G4 prompt injection blocked.
**Scale-out path**: Data 360 / Snowflake for history and zero-copy; Prompt Builder for versioned prompts; Flow approvals; Testing Center in CI; MCP/headless for third-party agents.
