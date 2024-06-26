global  class SplitCandidateAccountsBatchJob implements Database.Batchable<sObject>,Database.Stateful{
	//This batch job split's the candidates into account buckets.
	//This is a batch job to be executed one time.
    global final String query ='SELECT Id,name,accountId,ownerId FROM  Contact Where recordType.name=\'Candidate\' order by createdDate';
	global integer totalProcessedCnt;
	
	private TF2Settings__c configurations = null; 
	private boolean isTest {get; set;}
	
	global SplitCandidateAccountsBatchJob() {
        this.isTest = false;
        this.configurations= TF2Settings__c.getInstance();
        this.totalProcessedCnt = 0;
	}
	
	global SplitCandidateAccountsBatchJob(boolean isTest) {
		this.isTest = isTest;
		this.configurations= TF2Settings__c.getInstance();
		this.totalProcessedCnt = 0;
	}
	

	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		String queryStr = query;
		if (isTest) {
			queryStr = queryStr+ ' limit 1';				
		}
		return Database.getQueryLocator(queryStr);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		if(Schema.sObjectType.Account.fields.recordTypeId.isCreateable() && Schema.sObjectType.Account.fields.name.isCreateable()){
			splitCandidatesAccount.candidatesAccount(scope, configurations, true);
		}
		else
		{
			System.debug('Insufficient FLS access on Account object');
		}
		totalProcessedCnt = totalProcessedCnt + scope.size();
	}
	
	global void finish(Database.BatchableContext BC){
   		System.debug('Total Processed Count --->'+ totalProcessedCnt);
	}
	
	static testMethod void testBatch() {
		Test.startTest();
		DeDupCandidatesBatchJob dedupe = new DeDupCandidatesBatchJob(true);
		Database.executeBatch(dedupe, 1); 
		Test.stopTest();
	}
}