@isTest
	
class BatchableTransactionSnapshotTest {

	static Map<String, Id>deptRecordTypeMap {get; set;}
	static Map<String, Id>empRecordTypeMap {get; set;}
	static Map<String, Id>transRecordTypeMap {get; set;}
	
	static testmethod void startBatchTransactionTest() {
		
		/*
			Get record type ids for dept and employees
		*/
		List<RecordType> rtypes = [select Name, Id from RecordType  
                  				   where sObjectType='TF2_Department__c' and isActive=true];
        deptRecordTypeMap = new Map<String, String>();
        for (RecordType rt : rtypes) {
        	deptRecordTypeMap.put(rt.Name, rt.Id);  
        }          				   
        
        List<RecordType> etypes = [select Name, Id from RecordType 
                  				   where sObjectType='Employee__c' and isActive=true];
                  				   
		empRecordTypeMap = new Map<String, String>();  
		for (RecordType et : eTypes) {  
			empRecordTypeMap.put(et.Name, et.Id); 
		}
		List<RecordType> ttypes = [select Name, Id from RecordType  
                  				   where sObjectType='Transaction__c' and isActive=true];
        transRecordTypeMap = new Map<String, String>();
        for (RecordType tt : ttypes) {
        	transRecordTypeMap.put(tt.Name, tt.Id);  
        }          				     
		
		TF2_Department__c dept1 = new TF2_Department__c();
		dept1.Name = '406-Platform/Service AE\'s';
		dept1.ECOMM_Level_1__c = 'Frank';
		dept1.ECOMM_Level_2__c = 'Sales';
		dept1.ECOMM_Level_3__c = 'AE';
		dept1.ECOMM_Level_4__c = 'FS AE';
		dept1.ECOMM_Level_5__c = 'Field Sales Quota';
		dept1.Department_Number__c = 'D_001';
		dept1.RecordTypeId = deptRecordTypeMap.get('Current');
		insert dept1;
		TF2_Department__c dept2 = new TF2_Department__c();
		dept2.Name = '406-Platform/Service AE\'s';
		dept2.ECOMM_Level_1__c = 'Frank';
		dept2.ECOMM_Level_2__c = 'Sales';
		dept2.ECOMM_Level_3__c = 'AE';
		dept2.ECOMM_Level_4__c = 'FS AE';
		dept2.ECOMM_Level_5__c = 'Field Sales Quota';
		dept2.Snapshot_Department_Number__c = 'D_001';
		dept2.Department_Number__c = 'D001';
		dept2.RecordTypeId = deptRecordTypeMap.get('Snapshot');
		dept2.Snapshot_Date__c = Date.Today().toStartOfMonth().addDays(-1);
		insert dept2;
		
		
		List<Employee__c>eList = new List<Employee__c>();
		
		Employee__c emp1 = new Employee__c();
		emp1.Name = 'Test Emp';
		emp1.Active_Termed__c = 'Active';
		emp1.Employee_Number__c = 'TEST14';
		emp1.Location__c = 'CA - San Mateo';
		emp1.Compensation_Grade__c = '04';
		emp1.Hire_Date__c = Date.Today();
		emp1.Original_Hire_Date__c = Date.Today();
		emp1.Continuous_Service_Date__c = Date.Today();
		emp1.Cost_Center_ID__c = '001';
		
		eList.add(emp1);
		
		Employee__c emp2 = new Employee__c();
		emp2.Name = 'Test Emp';
		emp2.Active_Termed__c = 'Active';
		emp2.Snapshot_Employee_Number__c = 'TEST14';
		emp2.Location__c = 'CA - San Mateo';
		emp2.Compensation_Grade__c = '04'; 
		emp2.Hire_Date__c = Date.Today();
		emp2.Original_Hire_Date__c = Date.Today();
		emp2.Continuous_Service_Date__c = Date.Today();
		emp2.Cost_Center_ID__c = '001';
		emp2.RecordTypeId = empRecordTypeMap.get('Snapshot');
		emp2.Snapshot_Date__c = Date.Today().toStartOfMonth().addDays(-1);
		emp2.TF2_Department_Snapshot__c = dept2.Id;
		
		eList.add(emp2);
		insert eList;
		
		Transaction__c trans1 = new Transaction__c();
		trans1.Date__c = Date.Today();
		trans1.TF2_Department__c = dept1.Id;
		trans1.Employee__c = emp1.Id;
		trans1.Department_Level_Change__c = true;
		trans1.Transaction_Type__c = 'Termination';
		
		insert trans1;
		
		String query = 'select Transaction_Type__c, Termination_Type__c, Snapshot_Employee__c, TF2_Snapshot_Department__c, ' +
							'Snapshot_Date__c, Regrettable__c, RecordTypeId, Name, Id, Employee__c, ECOMM_Level_5_Change__c, ' +
							'ECOMM_Level_4_Change__c, ECOMM_Level_3_Change__c, ECOMM_Level_2_Change__c, ECOMM_Level_1_Change__c, ' +
							'TF2_Department__c, Department_Level_Change__c, Date__c, Department__r.Department_Number__c, Employee__r.Employee_Number__c ' + 
						'from Transaction__c ' + 
						'where RecordTypeId = \'' + transRecordTypeMap.get('Current') + '\' limit 200';
						  
		BatchableTransactionSnapshot bts = new BatchableTransactionSnapshot(query, transRecordTypeMap.get('Snapshot'), deptRecordTypeMap.get('Snapshot'), empRecordTypeMap.get('Snapshot'), Date.Today());
	System.debug('%%%%%% before execute 1 ');
		Test.startTest();
		ID batchprocessid = Database.executeBatch(bts);
	System.debug('%%%%%% after execute 1 ');
		Test.stopTest();


	}
}