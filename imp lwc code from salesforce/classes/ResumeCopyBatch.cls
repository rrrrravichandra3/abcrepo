global class ResumeCopyBatch implements Database.Batchable<sObject> {
    global final String query ='select id, name, ts2__Candidate_Contact__c,ts2__Candidate_Contact__r.ts2__Text_Resume__c,ts2__Application_Status__c from ts2__application__c  where ts2__Candidate_Contact__c != null';
	
	global ResumeCopyBatch() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		List<TF2Settings__c> configurationList = [select id, batch_process__c from TF2Settings__c ];
		List<TF2Settings__c> updateList = new List<TF2Settings__c>();
		for(TF2Settings__c configurations :configurationList ) {
		    configurations.Batch_Process__c=true;
		    updateList.add(configurations);
		}
		update updateList;
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		List<ts2__Application__c> updateApplicatioList = new List<ts2__Application__c>();
		Map<Id,ts2__Application__c> applicationMap = new Map<Id,ts2__Application__c>();
		for (sObject sobj : scope) {
			ts2__Application__c applicationInfo = (ts2__Application__c)sobj;
			if (applicationInfo.ts2__Candidate_Contact__r.ts2__Text_Resume__c != null) {
				applicationMap.put(applicationInfo.Id,applicationInfo);
			    applicationInfo.Resume__c = applicationInfo.ts2__Candidate_Contact__r.ts2__Text_Resume__c;
			    updateApplicatioList.add(applicationInfo);
			}
		}
		List<ts2__Offer__c> updateOfferList = new List<ts2__Offer__c>();
		for(ts2__offer__c offerInfo : [Select id, name,resume__c,ts2__Candidate__c,ts2__Related_Application__c from ts2__offer__c Where ts2__Related_Application__c IN :applicationMap.keySet() ]) {
			ts2__Application__c applicationInfo = applicationMap.get(offerInfo.ts2__Related_Application__c);
			offerInfo.resume__c = applicationInfo.ts2__Candidate_Contact__r.ts2__Text_Resume__c;
			updateOfferList.add(offerInfo);
		}
		
		if (updateApplicatioList.size() > 0) {
			update updateApplicatioList;
		}
		
		if (updateOfferList.size() > 0) {
			update updateOfferList;
		}
	}
	
	global void finish(Database.BatchableContext BC){
		List<TF2Settings__c> configurationList = [select id, batch_process__c from TF2Settings__c ];
		List<TF2Settings__c> updateList = new List<TF2Settings__c>();
		for(TF2Settings__c configurations :configurationList ) {
		    configurations.Batch_Process__c=false;
		    updateList.add(configurations);
		}
		update updateList;
   		System.debug('******* Update Done. *******');
	}
	
	static testMethod void testBatch() {
		Test.startTest();
		ResumeCopyBatch job = new ResumeCopyBatch();
		Database.executeBatch(job, 1); 
		Test.stopTest();
	}
}