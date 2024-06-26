global class DeDupCandidatesBatchJob implements Database.Batchable<sObject> {
	//This batch job updates cleans the duplicate candidates based on the email address providided.
	//This is a batch job to be executed one time.
    global final String query ='SELECT email,Id,name FROM  Contact Where recordType.name=\'Candidate\' order by createdDate';
	
	private boolean isTest {get; set;}
	
	global DeDupCandidatesBatchJob() {
        this.isTest = false;
	}
	
	global DeDupCandidatesBatchJob(boolean isTest) {
		this.isTest = isTest;
	}
	

	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		String queryStr = query;
		if (isTest) {
			queryStr = queryStr+ ' limit 1';				
		}
		return Database.getQueryLocator(queryStr);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		Set<String> emailAddressSet = new Set<String>();
		for (sObject sobj : scope) {
			Contact contact = (Contact)sobj;
			if (contact.email != null) {
			    emailAddressSet.add(contact.email);
			}
		}
		
   		System.debug('******* Duplicate Candidates Size:: '+emailAddressSet.size());
		if (emailAddressSet.size() > 0) {
			DeDupCandidateUtils.dedup(emailAddressSet);
		}
	}
	
	global void finish(Database.BatchableContext BC){
   		
	}
	
	static testMethod void testBatch() {
		Test.startTest();
		DeDupCandidatesBatchJob dedupe = new DeDupCandidatesBatchJob(true);
		Database.executeBatch(dedupe, 1); 
		Test.stopTest();
	}
}