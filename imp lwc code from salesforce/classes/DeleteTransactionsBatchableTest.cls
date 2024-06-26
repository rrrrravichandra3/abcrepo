@isTest
	
class DeleteTransactionsBatchableTest {
	
	static testmethod void startSmallBatchTest() {
		
		Transaction__c trans1 = new Transaction__c();
		insert trans1;
		
		Test.startTest();
		 
		String theQuery = 'select id, name ' +
						  'from Transaction__c ' + 
						  'limit 200';
		DeleteTransactionsBatchable dtb = new DeleteTransactionsBatchable(theQuery);
	
		ID batchprocessid = Database.executeBatch(dtb);
		Test.stopTest();


	}
	
	static testmethod void startLargeBatchTest() {
		List<Transaction__c>transToInsert = new List<Transaction__c>();
		for (Integer i = 0; i < 200; i++) {
			transToInsert.add(new Transaction__c());
		}
		insert transToInsert;
		
		Test.startTest();
		 
		String theQuery = 'select id, name ' +
						  'from Transaction__c ' + 
						  'limit 200';
		DeleteTransactionsBatchable dtb = new DeleteTransactionsBatchable(theQuery);
	
		ID batchprocessid = Database.executeBatch(dtb);
		Test.stopTest();


	}
}