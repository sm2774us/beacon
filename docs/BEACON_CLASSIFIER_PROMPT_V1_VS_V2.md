# Beacon Classifier: Prompt v1 vs v2

Nov 8, 2026 · @SM-interview

## How the classifier works

Both versions run the same rule-based classifier in `local/lib/engine.js`, a keyword stand-in for an LLM prompt that mirrors `BeaconTriageEngine.cls` in the org. Only the vocabulary and one extra check differ; scoring, guardrails and routing after classification are identical.

1. Lower-case the finding's title and description.
2. **(v2 only)** If a negation phrase appears ("no evidence of", "false positive", "came back clean", "not malicious"), classify as `benign` and stop.
3. Otherwise check categories in fixed order: malware, phishing, identity, exposure, privilege, drift. The first keyword hit wins.
4. If nothing matches, the category is `other`.

## What v2 changes

v2 adds a negation check and widens every category's vocabulary; identity goes from no keywords to two.

| Aspect | v1 | v2 |
| --- | --- | --- |
| Negation check | none | runs first, routes to `benign` |
| malware | malware, ransomware, "c2 beacon" | malware, ransomware, "c2 " (wider) |
| phishing | phish | adds "credential harvest" |
| identity | no keywords | "impossible travel", "mfa disabled" |
| exposure | "exposed" only | adds public-read, publicly accessible, 0.0.0.0/0, unencrypted |
| privilege | sudo, admin role | adds "root account", "privilege" |
| drift | drift | adds "baseline" |

## Three ways v1 fails

- **Vocabulary gap (E-1001, E-1002, E-1007, E-1011).** Real security text rarely uses the exact word a rule expects. E-1001 "Impossible travel… MFA disabled" should be `identity`, but v1 has no identity keywords. E-1002 "public-read ACL" and E-1007 "0.0.0.0/0" should be `exposure`, but v1 only knows "exposed". All return `other`. E-1011 ("unencrypted at rest") is the fifth miss, inferred from the project docs.
- **Negation blindness (E-1003).** "No evidence of malware; rescan came back clean" contains the word "malware", so v1 labels it `malware`: a false alarm. v2 catches the negation first and labels it `benign`.
- **Missing class.** With no identity keywords, v1 can never produce that category at all.

## Impact, results and demo caveat

The category feeds the risk score (`severity×10 + category bonus + control criticality + asset tier/PII/internet`), so a wrong label changes the score, band, guardrails, owner and recommendation. Mislabelling `benign` as `malware` swings the score by 35 points (−25 vs +10); `other` gets no bonus, so real exposures are under-scored.

v1 scores 9/14 (64.3%); v2 scores 14/14 (100%). Test #7 in `local/test/engine.test.js` requires v2 ≥ 95% and v1 < v2, and CI runs it on every push.

**Caveat:** v2's 100% is measured on a 14-item golden set its keywords were written against, so it is effectively a training set. Frame the demo around the process (golden set, measured regression, fix, CI gate) and say a real LLM prompt would replace the keyword rules while the eval harness stays.
