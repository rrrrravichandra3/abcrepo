@isTest

class BatchableDepartmentSnapshotTest {
	static Map<String, Id>deptRecordTypeMap {get; set;}
	static Map<String, Id>empRecordTypeMap {get; set;}
	static String CRON_EXP {get; set;}
	
	static testmethod void startScheduleTest() {
		
		
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
		
		Employee__c emp1 = new Employee__c();
		emp1.Name = 'Test Emp';
		emp1.Active_Termed__c = 'Active';
		emp1.Employee_Number__c = 'TEST14';
		emp1.Location__c = 'CA - San Mateo';
		emp1.Hire_Date__c = Date.Today();
		emp1.Original_Hire_Date__c = Date.Today();
		emp1.Continuous_Service_Date__c = Date.Today();
		emp1.Cost_Center_ID__c = dept1.Department_Number__c;
		emp1.RecordTypeId = empRecordTypeMap.get('Current');
		insert emp1;
		
		Test.startTest();
		 
		String q = 'select id, Cost_Center_ID__c, RecordTypeId, Snapshot_Date__c, Name, ECOMM_Level_5__c, ECOMM_Level_4__c, ' +
					'ECOMM_Level_3__c, ECOMM_Level_2__c, ECOMM_Level_1__c, Department_Number__c ' +
  			   		'from TF2_Department__c ' +
			   		'where RecordTypeId = \'' + deptRecordTypeMap.get('Current') + '\' limit 200';	
		BatchableDepartmentSnapshot bds = new BatchableDepartmentSnapshot(q, deptRecordTypeMap.get('Snapshot'), Date.Today());
	
		ID batchprocessid = Database.executeBatch(bds);
		Test.stopTest();


	}
	
	static testmethod void startBulkTest() {
		
		
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
		List<TF2_Department__c>dList = new List<TF2_Department__c>();
		
		for (Integer i = 0; i < 200; i++) {
			TF2_Department__c dept1 = new TF2_Department__c();
			dept1.Name = '406-Platform/Service AE\'s';
			dept1.ECOMM_Level_1__c = 'Frank';
			dept1.ECOMM_Level_2__c = 'Sales';
			dept1.ECOMM_Level_3__c = 'AE';
			dept1.ECOMM_Level_4__c = 'FS AE';
			dept1.ECOMM_Level_5__c = 'Field Sales Quota';
			
			dept1.Department_Number__c = i.format();
			dept1.RecordTypeId = deptRecordTypeMap.get('Current');
			dList.add(dept1);
		}
		insert dList;
		
		
		Test.startTest();
		 
		String q = 'select id, Cost_Center_ID__c, RecordTypeId, Snapshot_Date__c, Name, ECOMM_Level_5__c, ECOMM_Level_4__c, ' +
					'ECOMM_Level_3__c, ECOMM_Level_2__c, ECOMM_Level_1__c, Department_Number__c ' +
  			   		'from TF2_Department__c ' +
			   		'where RecordTypeId = \'' + deptRecordTypeMap.get('Current') + '\' limit 200';	
		BatchableDepartmentSnapshot bds = new BatchableDepartmentSnapshot(q, deptRecordTypeMap.get('Snapshot'), Date.Today());
	
		ID batchprocessid = Database.executeBatch(bds);
		Test.stopTest();


	}
}