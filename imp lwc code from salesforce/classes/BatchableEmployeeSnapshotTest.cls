@isTest
	
class BatchableEmployeeSnapshotTest {

	static Map<String, Id>deptRecordTypeMap {get; set;}
	static Map<String, Id>empRecordTypeMap {get; set;}
	static String CRON_EXP {get; set;}
	
	static testmethod void startBatchEmployeeTest() {
		
		
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
		dept1.ECOMM_Level_2__c = 'Sales';
		dept1.ECOMM_Level_3__c = 'AE';
		dept1.ECOMM_Level_4__c = 'FS AE';
		dept1.ECOMM_Level_5__c = 'Field Sales Quota';
		dept1.Department_Number__c = 'D_001';
		dept1.RecordTypeId = deptRecordTypeMap.get('Current');
		insert dept1;
		
		List<Employee__c>eList = new List<Employee__c>();
		for (Integer i = 0; i < 200; i++) {
			Employee__c emp1 = new Employee__c();
			emp1.Name = 'Test Emp';
			emp1.Active_Termed__c = 'Active'; 
			emp1.Location__c = 'CA - San Mateo';
			emp1.Hire_Date__c = Date.Today();
			emp1.Original_Hire_Date__c = Date.Today();
			emp1.Continuous_Service_Date__c = Date.Today();
			emp1.Cost_Center_ID__c = dept1.Department_Number__c;
			emp1.RecordTypeId = empRecordTypeMap.get('Current');
			String tempNum = i.format();
			if (tempNum.length() == 1) {
				tempNum = 'TST00' + tempNum;
			} else if (tempNum.length() == 2) {
				tempNum = 'TST0' + tempNum;
			} else {
				tempNum = 'TST' + tempNum;
			}
			emp1.Employee_Number__c = tempNum;
			eList.add(emp1);
		}
		insert eList;
		
		Test.startTest();
		 
		String theQuery = 'select id, TF2_Department__c, TF2_Department__r.Cost_Center_ID__c, RecordTypeId, ' +
							'Termination_Type__c, Termination_Date__c, Service_Time_in_Years__c, Regrettable__c, Region__c, ' + 
							'Original_Hire_Date__c, Name, Manager_ID__c, Location__c, Job_Profile_Name__c, Job_Code__c, ' + 
							'Hire_Date__c, Employee_Type__c, Employee_Number__c, Effective_Date__c, Department_Snapshot__c, ' + 
							'Custom_Organization__c, Continuous_Service_Date__c, Compensation_Grade__c, Company__c, Business_Title__c, ' + 
							'Active_Termed__c, AE_Type__c ' + 
						  'from Employee__c ' + 
						  'where RecordTypeId = \'' + empRecordTypeMap.get('Current') + '\' limit 200';
						  
		BatchableEmployeeSnapshot bes = new BatchableEmployeeSnapshot(theQuery, empRecordTypeMap.get('Snapshot'), deptRecordTypeMap.get('Snapshot'), Date.Today());
	System.debug('%%%%%% before execute 1 ');
	
		ID batchprocessid = Database.executeBatch(bes);
	System.debug('%%%%%% after execute 1 ');
		Test.stopTest();


	}
}