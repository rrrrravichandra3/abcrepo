@isTest
private class Test_Batch_BackfillDoNotCallReason {
	
	static testmethod void testDoNotCallReasonIsUpdated() {
		Id batchJobId;
		
		TestTF_Env_Unit.EnvSetup();
		
		// We create 200 candidates
		List<Contact> lst_Candidates = TestTF_Env_Unit.CreateCandidates(200, 'Test','Test','test@test.org','AMER');
      	
      	// For the first 100 candidates we check the 'Do Not Call' field checkbox	
      	for(Integer i = 0; i < 100; i++) {
      		lst_Candidates[i].Do_not_call__c = true;
      	}
      	
      	// Additionally, for the first 20 candidates we provide a value to the 'Do Not Call Reason' field
      	for(Integer i = 0; i < 20; i++) {
			lst_Candidates[i].Do_not_call_reason__c = 'Existing DNC reason';
      	}

		update lst_Candidates;
		
       	Test.startTest();
	       	Date startDate =  Date.today().addDays(-10);
			Date endDate =  Date.today().addDays(10);
			Batch_BackfillDoNotCallReason batch = new Batch_BackfillDoNotCallReason(false, 'DNC Reason NA: Historic Record.', startDate, endDate);
			batchJobId = Database.executeBatch(batch, 200);
        Test.stopTest();
		
		AsyncApexJob a = [SELECT Id,
                             Status,
                             NumberOfErrors,
                             JobItemsProcessed,
                             TotalJobItems,
                             CompletedDate,
                             ExtendedStatus,
                             ApexClass.name,
                             CreatedBy.Email,
                             CreatedBy.Name
                      FROM AsyncApexJob 
                      WHERE Id =:batchJobId];                   
		
		if (a.Status == 'Completed') {
			//Assert Do Not call reason is not null
			for(Contact c : [select Do_not_call__c, Do_not_call_reason__c from Contact where Id in :lst_Candidates and LastModifiedDate <= :a.CompletedDate]) {
				if(c.Do_not_call__c == true) {
					System.assert(c.Do_not_call_Reason__c != null);
				}
			}
		}
		
		
    }
}