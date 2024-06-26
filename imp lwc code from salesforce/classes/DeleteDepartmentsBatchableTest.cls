@isTest
	
class DeleteDepartmentsBatchableTest {
	
	static testmethod void startSmallBatchTest() {
		
		TF2_Department__c dept1 = new TF2_Department__c();
		dept1.Name = '406-Platform/Service AE\'s';
		dept1.ECOMM_Level_1__c = 'Frank';
		dept1.ECOMM_Level_2__c = 'Sales';
		dept1.ECOMM_Level_3__c = 'AE';
		dept1.ECOMM_Level_4__c = 'FS AE';
		dept1.ECOMM_Level_5__c = 'Field Sales Quota';
		dept1.Department_Number__c = 'D_001';
		
		insert dept1;
		
		Test.startTest();
		 
		String theQuery = 'select id, name ' +
						  'from TF2_Department__c ' +  
						  'limit 200';
		DeleteDepartmentsBatchable dtb = new DeleteDepartmentsBatchable(theQuery);
	
		ID batchprocessid = Database.executeBatch(dtb);
		Test.stopTest();


	}
	
	static testmethod void startLargeBatchTest() {
		List<TF2_Department__c>deptsToInsert = new List<TF2_Department__c>();
		for (Integer i = 0; i < 200; i++) {
			TF2_Department__c dept1 = new TF2_Department__c();
			dept1.Name = '406-Platform/Service AE\'s';
			dept1.ECOMM_Level_1__c = 'Frank';
			dept1.ECOMM_Level_2__c = 'Sales';
			dept1.ECOMM_Level_3__c = 'AE';
			dept1.ECOMM_Level_4__c = 'FS AE';
			dept1.ECOMM_Level_5__c = 'Field Sales Quota';
			dept1.Department_Number__c = i.format();
			
			deptsToInsert.add(dept1);
		}
		insert deptsToInsert;
		
		Test.startTest();
		 
		String theQuery = 'select id, name ' +
						  'from TF2_Department__c ' + 
						  'limit 200';
		DeleteDepartmentsBatchable dtb = new DeleteDepartmentsBatchable(theQuery);
	
		ID batchprocessid = Database.executeBatch(dtb);
		Test.stopTest();


	}
}