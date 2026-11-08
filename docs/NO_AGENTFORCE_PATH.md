# Running Beacon on a free Developer Edition / basic Trailhead Playground (no Agentforce)

Nothing in the core deployment needs Agentforce. The package deploys standard objects, Apex, an LWC and a permission set. Agentforce is only the optional last layer (docs/AGENTFORCE_SETUP.md). For orgs without it, the **Beacon Agent Console** (LWC + `BeaconAgentController`) plays the agent role: it parses a request, calls the *same* `BeaconTriageAction` an Agentforce topic would call, and prints the tool trace.

## Deploy (works on any org with API access)
1. Install Salesforce CLI. In cmd: `deploy-to-salesforce.bat`; give your org's My Domain URL (Setup > My Domain; Developer Edition `https://<name>.my.salesforce.com`).
   Manual: `sf org login web --instance-url <url> --alias beacon --set-default`, then `sf project deploy start --source-dir force-app`, `sf org assign permset --name Beacon_FDE_Demo`, `sf apex run --file scripts/apex/seed.apex`.
2. App Launcher > **Beacon** > **Control Tower**.
3. In the console type: `triage E-1002` (Critical -> Pending Approval) > `approve E-1002` > `triage E-1010` (prompt-injection, Blocked) > `triage all new` > `status`.

## No-CLI alternatives
- Anonymous Apex test of the action only (needs the classes deployed): run `scripts/apex/demo.apex` in Developer Console > Debug > Execute Anonymous.
- Corrected snippet (note the real method name is `triage` and `findingId` is a record Id):
```apex
Finding__c f = [SELECT Id FROM Finding__c WHERE External_Id__c = 'E-1002' LIMIT 1];
BeaconTriageAction.Request req = new BeaconTriageAction.Request(); req.findingId = f.Id;
System.debug(BeaconTriageAction.triage(new List<BeaconTriageAction.Request>{ req })[0]);
```

## Flow demo (point-and-click, same action)
Setup > Flows > New Flow > **Screen Flow**. Add a Screen with a text input `FindingId`; add an **Action** element > category *Beacon* > **Triage Security Finding**, map `findingId` to the input; add a final Screen showing Status, Risk Band, Recommendation. Save, Activate, Debug. (Lets you say: "this is how an admin or an Agentforce agent consumes the same action.")

## What to say in the interview
"The agent layer is a thin, swappable orchestrator. Scoring, guardrails and telemetry live in Apex, so the same action runs from this console, a Flow, REST, or an Agentforce topic. My playground has no Agentforce, so I demo the console; on an Agentforce org I attach the action to a topic in minutes." Be upfront that the console is rule-based, not an LLM.
