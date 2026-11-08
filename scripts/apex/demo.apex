// Paste into Developer Console > Debug > Open Execute Anonymous Apex (check "Open Log"), or: sf apex run --file scripts/apex/demo.apex
// Run seed.apex first. Calls the SAME action an Agentforce agent or Flow would call.
Finding__c f = [SELECT Id FROM Finding__c WHERE External_Id__c = 'E-1002' LIMIT 1];
BeaconTriageAction.Request req = new BeaconTriageAction.Request();
req.findingId = f.Id;                                   // must be a record Id, not 'F-00002'
List<BeaconTriageAction.Response> out = BeaconTriageAction.triage(new List<BeaconTriageAction.Request>{ req });
System.debug('STATUS=' + out[0].status + ' BAND=' + out[0].band + ' SCORE=' + out[0].score + ' GUARDRAILS=' + out[0].guardrails);
System.debug(BeaconAgentController.ask('why is E-1002 pending').text);
