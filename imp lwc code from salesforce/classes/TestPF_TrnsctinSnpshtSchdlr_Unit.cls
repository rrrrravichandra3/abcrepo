@isTest
	
class TestPF_TrnsctinSnpshtSchdlr_Unit {

	static Map<String, Id>deptRecordTypeMap {get; set;}
	static Map<String, Id>empRecordTypeMap {get; set;}
	static Map<String, Id>transRecordTypeMap {get; set;}
	static String CRON_EXP {get; set;}
	
	static testmethod void startScheduleTest() {
		CRON_EXP = '0 0 0 3 9 ? 2022';
		
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
		
		TF2_Department__c dept1 = null;                            
        try{
        dept1 = [Select 	d.Name, d.ECOMM_Level_1__c, d.ECOMM_Level_2__c, 
							d.ECOMM_Level_3__c, d.ECOMM_Level_4__c, d.ECOMM_Level_5__c, 
							d.Department_Number__c, d.RecordTypeId From TF2_Department__c d 
							Where d.Department_Number__c =: 'D_001'];	
        }catch(Exception e){
        	System.debug('Department does not exist.');
        }
        
        if (dept1 == null){
        	dept1 = new TF2_Department__c();
        	dept1.Name = '406-Platform/Service AE\'s';
        	dept1.ECOMM_Level_1__c = 'Frank';
        	dept1.ECOMM_Level_2__c = 'Sales';
        	dept1.ECOMM_Level_3__c = 'AE';
        	dept1.ECOMM_Level_4__c = 'FS AE';
        	dept1.ECOMM_Level_5__c = 'Field Sales Quota';
        	dept1.Department_Number__c = 'D_001';
        	dept1.RecordTypeId = deptRecordTypeMap.get('Current');
        	upsert dept1;	
        } 
		TF2_Department__c dept2 = new TF2_Department__c();
		dept2.Name = '406-Platform/Service AE\'s';
		dept2.ECOMM_Level_1__c = 'Frank';
		dept2.ECOMM_Level_2__c = 'Sales';
		dept2.ECOMM_Level_3__c = 'AE';
		dept2.ECOMM_Level_4__c = 'FS AE';
		dept2.ECOMM_Level_5__c = 'Field Sales Quota';
		dept2.Snapshot_Department_Number__c = 'D_001';
		dept2.Department_Number__c = 'TD001';
		dept2.RecordTypeId = deptRecordTypeMap.get('Snapshot');
		dept2.Snapshot_Date__c = Date.Today().toStartOfMonth().addDays(-1);
		upsert dept2;
		
		 //verify that the headcount settings have been created, if not, then create them
        Integer hCount = [select count() from headcountsettings__c];
		if(hCount < 1){
			
			HeadcountSettings__C hcs = new HeadcountSettings__c(name ='Test Headcount Setting',
																 Approximate_Headcount__c = 1000,
																 Import_Date__c = date.today()
																 );
			System.runAs(GenerateEnvironmentTest.getSystemAdmin() ){
				insert hcs;
			}
		}
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
		Test.startTest();
   // Schedule the test job  
    

      String jobId = System.schedule('Testing Transaction Scheduler',CRON_EXP, new TransactionSnapshotScheduler());
   // Get the information from the CronTrigger API object  
    

		CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, 
							NextFireTime
						  FROM CronTrigger 
						  WHERE id = :jobId];

   // Verify the expressions are the same  
    
		System.assertEquals(CRON_EXP,ct.CronExpression);

   // Verify the job has not run  
    
		System.assertEquals(0, ct.TimesTriggered);

   // Verify the next time the job will run  
    
		System.assertEquals('2022-09-03 00:00:00', 
		String.valueOf(ct.NextFireTime));

		Test.stopTest();

	}
}