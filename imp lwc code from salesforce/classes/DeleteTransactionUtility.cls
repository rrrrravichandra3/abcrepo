global class DeleteTransactionUtility {

	@future
	global static void deleteTransactions(List<Id>employees, List<String>transTypes) {
		/* Get transaction record types */
		Map<String, Id>tRecordTypeMap = new Map<String, String>();
		
		List<RecordType> etypes = [select Name, Id 
								   from RecordType 
	                  			   where sObjectType='Transaction__c' and isActive=true];
	                  			
		for (RecordType et : eTypes) {
			tRecordTypeMap.put(et.Name, et.Id);
		}        
		
		/* Find transactions to delete */          	
		List<Transaction__c>dList = new List<Transaction__c>();
		if (employees != null && transTypes != null && !employees.isEmpty() && !transTypes.isEmpty()) {
			Integer counter = 0;
			/* Go through Lists and find transactions to delete */
			for (Id curEmp : employees) {
				if (Limits.getQueries() > 98) { break;}
				if (transTypes.size() < counter) {break;}
					
				try {
					
					Transaction__c tDelete = [select id, Employee__c, Transaction_Type__c, RecordTypeId 
											  from Transaction__c
											  where RecordTypeId = :tRecordTypeMap.get('Current')
											  	and Employee__c = :curEmp and Transaction_Type__c = :transTypes.get(counter)];
					if (tDelete != null) {
						dList.add(tDelete);
					}
				} catch(Exception e) {
					
				}
				counter++;
			}
			
			if (dList != null && !dList.isEmpty()) {
				delete dList;
			}
		}
	}
	
	@future
	global static void deleteRescindedHires(Set<String>employeesInImport) {
		List<Id>empsToDelete = new List<Id>();
		List<Id>transToDelete = new List<ID>();
		/* Get transaction record types */
		Map<String, Id>tRecordTypeMap = new Map<String, String>();
		
		List<RecordType> etypes = [select Name, Id 
								   from RecordType 
	                  			   where sObjectType='Transaction__c' and isActive=true];
	                  			
		for (RecordType et : eTypes) {
			tRecordTypeMap.put(et.Name, et.Id);
		}  
		try {
			List<Transaction__c>tList = [select id, Employee__c, Employee__r.Id, Employee__r.Employee_Number__c, 
												Transaction_Type__c, RecordTypeId 
										 from Transaction__c
										 where RecordTypeId = :tRecordTypeMap.get('Current')
										  	and Transaction_Type__c = 'New Hire'];
										  	
			for (Transaction__c cur : tList) {
				if (!employeesInImport.contains(cur.Employee__r.Employee_Number__c)) {
					transToDelete.add(cur.Id);
					empsToDelete.add(cur.Employee__c);
				}	
			}
			if (!transToDelete.isEmpty()) {
				List<Transaction__c>tDelete = [select id from Transaction__c where id in :transToDelete];
				delete tDelete;
			}
			if (!empsToDelete.isEmpty()) {
				List<Employee__c>eDelete = [select id from Employee__c where id in :empsToDelete];
				delete eDelete;
			}
		} catch (Exception e) {
			
		}							  	
	}
}