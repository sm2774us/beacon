// Clean slate: wipes Beacon data and re-ingests the 18 demo events. Run: sf apex run --file scripts/apex/seed.apex
BeaconSeed.reset();
System.debug('Beacon reset complete: ' + [SELECT COUNT() FROM Finding__c] + ' findings');
