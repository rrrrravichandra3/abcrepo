@isTest

class EmployeeImportTriggerTest {
	static Map<String, Id>deptRecordTypeMap {get; set;}
	static Map<String, Id>empRecordTypeMap {get; set;}
	
	static String CRON_EXP {get; set;}
	
	static testmethod void bulkNewHireTest() {
		//HeadcountTriggerSettings__c triggerSettings = HeadcountTriggerSettings__c.getInstance('ImportDate');
		HeadcountSettings__c headcountSettings = [Select Name, Import_Date__c, Approximate_Headcount__c From HeadcountSettings__c][0];
		
		//Date importDate = triggerSettings.Import_Date__c;
		Date importDate = headcountSettings.Import_Date__c;
		
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
		/* New hire and term in same month test */
		Employee__c e2 = new Employee__c();
		e2.Name ='Test Emp2';
		e2.Active_Termed__c = 'Termed';
		e2.Hire_Date__c = importDate.addDays(-1);
		e2.Termination_Date__c = importDate;
		e2.Employee_Number__c = 'TST999';
		e2.Cost_Center_ID__c = dept1.Department_Number__c;
		eList.add(e2);
		Test.startTest();
		insert eList;
		Test.stopTest();
	}
	
	static testmethod void bulkPromotionTest() {
		//HeadcountTriggerSettings__c triggerSettings = HeadcountTriggerSettings__c.getInstance('ImportDate');
		HeadcountSettings__c headcountSettings = [Select Name, Import_Date__c, Approximate_Headcount__c From HeadcountSettings__c][0];
		
		//Date importDate = triggerSettings.Import_Date__c;
		Date importDate = headcountSettings.Import_Date__c;
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
		
		List<Employee__c>eList = new List<Employee__c>();
		for (Integer i = 0; i < 200; i++) {
			Employee__c emp1 = new Employee__c();
			emp1.Name = 'Test Emp';
			emp1.Active_Termed__c = 'Active'; 
			emp1.Location__c = 'CA - San Mateo';
			emp1.Compensation_Grade__c = '04';
			emp1.Hire_Date__c = Date.Today();
			emp1.Original_Hire_Date__c = Date.Today();
			emp1.Continuous_Service_Date__c = Date.Today();
			emp1.Cost_Center_ID__c = dept1.Department_Number__c;
			emp1.RecordTypeId = empRecordTypeMap.get('Current');
			
			Employee__c emp2 = new Employee__c();
			emp2.Name = 'Test Emp';
			emp2.Active_Termed__c = 'Active';
			emp2.Location__c = 'CA - San Mateo';
			emp2.Compensation_Grade__c = '04';
			emp2.Hire_Date__c = Date.Today();
			emp2.Original_Hire_Date__c = Date.Today();
			emp2.Continuous_Service_Date__c = Date.Today();
			emp2.Cost_Center_ID__c = '001';
			emp2.RecordTypeId = empRecordTypeMap.get('Snapshot');
			emp2.Snapshot_Date__c = importDate.toStartOfMonth().addDays(-1);
			String tempNum = i.format();
			if (tempNum.length() == 1) {
				tempNum = 'TST00' + tempNum;
			} else if (tempNum.length() == 2) {
				tempNum = 'TST0' + tempNum;
			} else {
				tempNum = 'TST' + tempNum;
			}
			emp1.Employee_Number__c = tempNum;
			emp2.Snapshot_Employee_Number__c = tempNum;
			eList.add(emp1);
			eList.add(emp2);
		}
		insert eList;
		
		for (Employee__c cur : eList) {
			cur.Compensation_Grade__c = '05';	
		}
		Test.startTest();
		update eList;
		
		for (Employee__c cur : eList) {
			cur.Compensation_Grade__c = '04';	
		}
		update eList;
		Test.stopTest();
	}
	
	static testmethod void basicInsertAndPromotionTest() {
		//HeadcountTriggerSettings__c triggerSettings = HeadcountTriggerSettings__c.getInstance('ImportDate');
		HeadcountSettings__c headcountSettings = [Select Name, Import_Date__c, Approximate_Headcount__c From HeadcountSettings__c][0];
		
		//Date importDate = triggerSettings.Import_Date__c;
		Date importDate = headcountSettings.Import_Date__c;
		
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
		List<Employee__c>eList = new List<Employee__c>();
		Test.startTest();
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
		//emp2.Snapshot_Date__c = Date.Today().toStartOfMonth().addDays(-1);
		emp2.Snapshot_Date__c = importDate.toStartOfMonth().addDays(-1);
		
		eList.add(emp2);
		insert eList;
		
		emp1.Compensation_Grade__c = '05';
		update emp1;
		
		emp1.Compensation_Grade__c = '04';
		update emp1;
		
		
		Test.stopTest();
	}
	
	static testmethod void basicInsertAndTransferTest() {
		//HeadcountTriggerSettings__c triggerSettings = HeadcountTriggerSettings__c.getInstance('ImportDate');
		HeadcountSettings__c headcountSettings = [Select Name, Import_Date__c, Approximate_Headcount__c From HeadcountSettings__c][0];
		
		//Date importDate = triggerSettings.Import_Date__c;
		Date importDate = headcountSettings.Import_Date__c;
		
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
		TF2_Department__c dept2 = new TF2_Department__c();
		dept2.Name = '407-Platform/Service AE\'s';
		dept2.ECOMM_Level_1__c = 'George';
		dept2.ECOMM_Level_2__c = 'Marketing';
		dept2.ECOMM_Level_3__c = 'TEST';
		dept2.ECOMM_Level_4__c = 'TEST AE';
		dept2.ECOMM_Level_5__c = 'TEST MARKETING';
		dept2.Department_Number__c = 'D_002';
		dept2.RecordTypeId = deptRecordTypeMap.get('Current');
		insert dept2;
		List<Employee__c>eList = new List<Employee__c>();
		Test.startTest();
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
		//emp2.Snapshot_Date__c = Date.Today().toStartOfMonth().addDays(-1);
		emp2.Snapshot_Date__c = importDate.toStartOfMonth().addDays(-1);
		
		elist.add(emp2);
		insert eList;
		
		emp1.Cost_Center_ID__c = '002';
		update emp1;
		
		emp1.Cost_Center_ID__c = '001';
		System.debug('$$$$$$ doing rescind transfer test now');
		update emp1;
		Test.stopTest();
	}
	
	static testmethod void basicInsertAndTermTest() {
		//HeadcountTriggerSettings__c triggerSettings = HeadcountTriggerSettings__c.getInstance('ImportDate');
		HeadcountSettings__c headcountSettings = [Select Name, Import_Date__c, Approximate_Headcount__c From HeadcountSettings__c][0];
		
		//Date importDate = triggerSettings.Import_Date__c;
		Date importDate = headcountSettings.Import_Date__c;
		
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
		List<Employee__c>eList = new List<Employee__c>();
		Test.startTest();
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
		emp2.Snapshot_Date__c = importDate.toStartOfMonth().addDays(-1);
		
		eList.add(emp2);
		insert eList;
		
		emp1.Active_Termed__c = 'Termed';
		emp1.Termination_Date__c = Date.Today();
		emp1.Termination_Type__c = 'Voluntary';
		update emp1;
		
		emp1.Active_Termed__c = 'Active';
		update emp1;
		
		Test.stopTest();
	}
	
	static testmethod void hireAndTermInOneMonthTest() {
		
		
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
		List<Employee__c>eList = new List<Employee__c>();
		Test.startTest();
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
		insert eList;
		
		emp1.Active_Termed__c = 'Termed';
		emp1.Termination_Date__c = Date.Today();
		emp1.Termination_Type__c = 'Voluntary';
		update emp1;
		
		Test.stopTest();
	}
	
	static testmethod void employeeRehireTest() {
		//HeadcountTriggerSettings__c triggerSettings = HeadcountTriggerSettings__c.getInstance('ImportDate');
		HeadcountSettings__c headcountSettings = [Select Name, Import_Date__c, Approximate_Headcount__c From HeadcountSettings__c][0];
		
		//Date importDate = triggerSettings.Import_Date__c;
		Date importDate = headcountSettings.Import_Date__c;
		
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
		List<Employee__c>eList = new List<Employee__c>();
		Test.startTest();
		Employee__c emp1 = new Employee__c();
		emp1.Name = 'Test Emp';
		emp1.Active_Termed__c = 'Termed';
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
		emp2.Active_Termed__c = 'Termed';
		emp2.Snapshot_Employee_Number__c = 'TEST14';
		emp2.Location__c = 'CA - San Mateo';
		emp2.Compensation_Grade__c = '04';
		emp2.Hire_Date__c = Date.Today();
		emp2.Original_Hire_Date__c = Date.Today();
		emp2.Continuous_Service_Date__c = Date.Today();
		emp2.Cost_Center_ID__c = '001';
		emp2.RecordTypeId = empRecordTypeMap.get('Snapshot');
		emp2.Snapshot_Date__c = importDate.toStartOfMonth().addDays(-1);
		
		eList.add(emp2);
		insert eList;
		
		emp1.Active_Termed__c = 'Active';
		update emp1;
		
		Test.stopTest();
	}
	
	static testmethod void basicRegionChangeTest() {
		//HeadcountTriggerSettings__c triggerSettings = HeadcountTriggerSettings__c.getInstance('ImportDate');
		HeadcountSettings__c headcountSettings = [Select Name, Import_Date__c, Approximate_Headcount__c From HeadcountSettings__c][0];
		
		//Date importDate = triggerSettings.Import_Date__c;
		Date importDate = headcountSettings.Import_Date__c;
		
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
		emp1.Region__c = 'Test Region 1';
		
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
		//emp2.Snapshot_Date__c = Date.Today().toStartOfMonth().addDays(-1);
		emp2.Snapshot_Date__c = importDate.toStartOfMonth().addDays(-1);
		emp2.Region__c = 'Test Region 1';
		
		eList.add(emp2);
		insert eList;
		Test.startTest();
		emp1.Region__c = 'Test Region 2';
		update emp1;
		
		emp1.Region__c = 'Test Region 1';
		update emp1;
		
		
		Test.stopTest();
	}
	
	static testmethod void basicDivisionChangeTest() {
		//HeadcountTriggerSettings__c triggerSettings = HeadcountTriggerSettings__c.getInstance('ImportDate');
		HeadcountSettings__c headcountSettings = [Select Name, Import_Date__c, Approximate_Headcount__c From HeadcountSettings__c][0];
		
		//Date importDate = triggerSettings.Import_Date__c;
		Date importDate = headcountSettings.Import_Date__c;
		
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
		emp1.Custom_Organization__c = 'Test Division 1';
		
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
		//emp2.Snapshot_Date__c = Date.Today().toStartOfMonth().addDays(-1);
		emp2.Snapshot_Date__c = importDate.toStartOfMonth().addDays(-1);
		emp2.Custom_Organization__c = 'Test Division 1';
		
		eList.add(emp2);
		insert eList;
		Test.startTest();
		emp1.Custom_Organization__c = 'Test Division 2';
		update emp1;
		
		emp1.Custom_Organization__c = 'Test Division 1';
		update emp1;
		
		
		Test.stopTest();
	}
}