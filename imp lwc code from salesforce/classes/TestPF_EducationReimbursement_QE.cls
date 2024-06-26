/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestPF_EducationReimbursement_QE {

	/**
		Test the required fields
	*/
    static testMethod void requiredFields() {
        // try to insert a new Education Reimbursement Requests without filling in the required fields
        // verify that an DML exception is thrown due to the missing required fields
        Education_Reimbursement_Request__c er = new Education_Reimbursement_Request__c();
        try{
        	insert er;
        }catch(DmlException e){
        	 System.assertEquals(StatusCode.REQUIRED_FIELD_MISSING, e.getDmlType(0));
        	 //verify the list of required fields 
        	 sObjectField[] fields = e.getDmlFields(0);
        	 Map<String,sObjectField> fieldsMap = new Map<String,sObjectField>();
        	 for(sObjectField f : fields){
        	 	fieldsMap.put(f.getDescribe().getName(),f );
        	 }
        	 System.assert(fieldsMap.containsKey('Course_Name__c'));
        	 System.assert(fieldsMap.containsKey('Course_Provider__c'));
        	 System.assert(fieldsMap.containsKey('Course_Start_Date__c'));
        	 System.assert(fieldsMap.containsKey('Expected_Course_End_Date__c'));
        	 System.assert(fieldsMap.containsKey('Cost__c'));
        
        }
    }
    
    /**
    	Verify text fields length
    */
    static testMethod void fieldsLength() {
    	//verify the length of the text input fields
    	
    	//Course Name
    	Schema.DescribeFieldResult d = Education_Reimbursement_Request__c.Course_Name__c.getDescribe();
    	System.assert( d.getLength() == 80 );
    	
    	//Course Provider
    	d = Education_Reimbursement_Request__c.Course_Provider__c.getDescribe();
    	System.assert( d.getLength() == 80 );
    	
    	//Justification for Enrolling
    	d = Education_Reimbursement_Request__c.Justification_for_Enrolling_on_Course__c.getDescribe();
    	System.assert( d.getLength() == 32000 );
    	
    	//Course Description
    	d = Education_Reimbursement_Request__c.Course_Description__c.getDescribe();
    	System.assert( d.getLength() == 32000 );
    	
    	//Course Provier Website
    	d = Education_Reimbursement_Request__c.Course_Provider_Website__c.getDescribe();
    	System.assert( d.getLength() == 255 );
    	
    }
    
    /**
    	As an employee, create a new Education Reimbursement Request
    */    
    static testMethod void employeeCreatesEdReimbursementReq() {
    	User employee = GenerateEnvironmentTest.getEmployeeStandard();
    	System.runAs(employee){
    		Education_Reimbursement_Request__c er = new Education_Reimbursement_Request__c();
    		er.Course_Name__c = 'test course name';
    		er.Course_Provider__c = 'test course provider';    	
    		er.Course_Start_Date__c = System.now().addDays(2).date();    	
    		er.Expected_Course_End_Date__c =  er.Course_Start_Date__c.addDays(30);
    		er.Cost__c = 1000;
    		insert er;
    		
    		//Status after creation should be Not Submitted
    		er = [select status__c from Education_Reimbursement_Request__c where id=:er.Id];
    		System.assertEquals('Not Submitted',er.Status__c);
    	}
    	
    }
    
    /**
    	As an employee, submit a claim for an existing Education Reimbursement Request
    */    
    static testMethod void employeeSubmitsEdReimbursementClaim() {
    	User employee = GenerateEnvironmentTest.getEmployeeStandard();
    	
    		Education_Reimbursement_Request__c er = getEdReq();
    	System.runAs(employee){
    		Education_Reimbursement_Claim__c claim = new Education_Reimbursement_Claim__c();
    		claim.Education_Request_Number__c = er.Id;
    		claim.Claim_Amount__c = 500;
    		claim.Employee_Signature__c = true;
    		claim.Receipt_Date__c = System.now().date();
    		insert claim;
    	}
    }
    
    /**
    	As an employee, submit a claim for an existing Education Reimbursement Request
    	without entering a receipt date, a Dml Exception should be thrown due to the missing required field
    */    
    static testMethod void employeeSubmitsEdClaimWithoutReceiptDate() {
    	User employee = GenerateEnvironmentTest.getEmployeeStandard();
    	
    		Education_Reimbursement_Request__c er = getEdReq();
    	System.runAs(employee){
    		Education_Reimbursement_Claim__c claim = new Education_Reimbursement_Claim__c();
    		claim.Education_Request_Number__c = er.Id;
    		claim.Claim_Amount__c = 500;
    		claim.Employee_Signature__c = true;
    		try{
    			insert claim;
    		}catch(DmlException e){
    			 System.assertEquals(StatusCode.REQUIRED_FIELD_MISSING, e.getDmlType(0));
        		 //verify the list of required fields 
        		 sObjectField[] fields = e.getDmlFields(0);
        		 Map<String,sObjectField> fieldsMap = new Map<String,sObjectField>();
        		 for(sObjectField f : fields){
        		 	fieldsMap.put(f.getDescribe().getName(),f );
       		 	 }
       		 	System.assert(fieldsMap.containsKey('Receipt_Date__c'));
    		}
    	}
    }
    
    /**
    	As the manager of the employee, approve the Ed Reimbursement Request submitted by him
    */    
    static testMethod void managerApprovesEdReimbursementReq() {
    	User employee = GenerateEnvironmentTest.getEmployeeStandard();
    	employee = [select id, name, manager__c from user where id=:employee.Id];
    	User manager = [select id, name from user where id =: employee.manager__c];
    	Approval.ProcessResult result;
    	Education_Reimbursement_Request__c er = getEdReq();
    	System.runAs(employee){
    		result = submitForApproval(er, 'test comment, submitting the request to the manager');
    	}
    		
    	System.runAs(manager){
    		
    		if ( result.isSuccess() ){
    			Id newWorkItemId =result.getNewWorkitemIds().get(0);
        		
      			// Instantiate the new ProcessWorkitemRequest object and populate it 
    
      			Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        		req.setComments('Test comment, manager approving request.');
        		req.setAction('Approve');
        		
        		Group edQueue = [select id from Group where name='Education Reimbursement'];    
    			req.setNextApproverIds(new Id[] {edQueue.Id });
        		// Use the ID from the newly created item to specify the item to be worked 
        		req.setWorkitemId(newWorkItemId);
        
       			// Submit the request for approval     
        		Approval.ProcessResult result2 =  Approval.process(req);
        		
        		//Verify the results
        		System.assert( result2.isSuccess() );
        		//Ed.Request status shoud be now 'Manager Approved'
        		er = [select status__c from Education_Reimbursement_Request__c where id=:er.Id];
        		System.assertEquals ('Manager Approved', er.Status__c);
        
    		}
    	}
    }
    
    /**
    	As the Education Reimbursement Queue, approve the Ed Reimbursement Request
    */    
    static testMethod void EducationQueueApprovesEdReimbursementReq() {
    	User employee = GenerateEnvironmentTest.getEmployeeStandard();
    	employee = [select id, name, manager__c from user where id=:employee.Id];
    	User manager = [select id, name from user where id =: employee.manager__c];
    	Approval.ProcessResult result;
    	Education_Reimbursement_Request__c er = getEdReq();
    	System.runAs(employee){
    		result = submitForApproval(er, 'test comment, submitting the request to the manager');
    	}
    		
      
    	if ( result.isSuccess() ){
    			Id newWorkItemId =result.getNewWorkitemIds().get(0);
        		
      			// Instantiate the new ProcessWorkitemRequest object and populate it 
    
      			Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        		req.setComments('Test comment, manager approving request.');
        		req.setAction('Approve');
        		
        		Group edQueue = [select id from Group where name='Education Reimbursement'];    
    			req.setNextApproverIds(new Id[] {edQueue.Id });
        		// Use the ID from the newly created item to specify the item to be worked 
        		req.setWorkitemId(newWorkItemId);
        
        		System.runAs( manager ){
       				// Submit the request for approval     
        			result =  Approval.process(req);
        		}
        		if(result.isSuccess()){
        			User approver;
        			User nextApprover = GenerateEnvironmentTest.getSecondManager();
        			//Get a user from the Education Queue
        			Integer memberCount = [select count() from GroupMember where GroupId=:edQueue.Id ];
        			if(memberCount > 0){
        				Id approverId = [select UserOrGroupId from GroupMember where GroupId=:edQueue.Id  limit 1].UserOrGroupId;
        				approver = [select id from user where Id=:approverId];
        				req = new Approval.ProcessWorkitemRequest();
        				req.setComments('Test comment, Education Queue approving request.');
        				req.setAction('Approve');
        				req.setWorkitemId(result.getNewWorkitemIds().get(0));
        				req.setNextApproverIds(new Id[]{nextApprover.Id});
        				System.runAs(approver){
        					//As a member of the Education Queue, approve the Request
        					result =  Approval.process(req);
        					//Verify the results
        					System.assert(result.isSuccess());
        					//Ed Request status should be now 'ES Benefit Admin Approved'
        					er = [select status__c from Education_Reimbursement_Request__c where Id=:er.Id];
        					System.assertEquals('ES Benefit Admin Approved',er.Status__c);
        				}
        			}else{
        				// insert a user into the Education Queue
        			}
        		}
        		
    	}
    }
    
    /**
    	As the Education Reimbursement Queue, reject the Ed Reimbursement Request
    */    
    static testMethod void EducationQueueRejectsEdReimbursementReq() {
    	User employee = GenerateEnvironmentTest.getEmployeeStandard();
    	employee = [select id, name, manager__c from user where id=:employee.Id];
    	User manager = [select id, name from user where id =: employee.manager__c];
    	Approval.ProcessResult result;
    	Education_Reimbursement_Request__c er = getEdReq();
    	System.runAs(employee){
    		result = submitForApproval(er, 'test comment, submitting the request to the manager');
    	}
    		
      
    	if ( result.isSuccess() ){
    			Id newWorkItemId =result.getNewWorkitemIds().get(0);
        		
      			// Instantiate the new ProcessWorkitemRequest object and populate it 
    
      			Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        		req.setComments('Test comment, manager approving request.');
        		req.setAction('Approve');
        		
        		Group edQueue = [select id from Group where name='Education Reimbursement'];    
    			req.setNextApproverIds(new Id[] {edQueue.Id });
        		// Use the ID from the newly created item to specify the item to be worked 
        		req.setWorkitemId(newWorkItemId);
        
        		System.runAs( manager ){
       				// Submit the request for approval     
        			result =  Approval.process(req);
        		}
        		if(result.isSuccess()){
        			User approver;
        			User nextApprover = GenerateEnvironmentTest.getSecondManager();
        			//Get a user from the Education Queue
        			Integer memberCount = [select count() from GroupMember where GroupId=:edQueue.Id ];
        			if(memberCount > 0){
        				Id approverId = [select UserOrGroupId from GroupMember where GroupId=:edQueue.Id  limit 1].UserOrGroupId;
        				approver = [select id from user where Id=:approverId];
        				req = new Approval.ProcessWorkitemRequest();
        				req.setComments('Test comment, Education Queue rejecting request.');
        				req.setAction('Reject');
        				req.setWorkitemId(result.getNewWorkitemIds().get(0));
        				req.setNextApproverIds(new Id[]{nextApprover.Id});
        				System.runAs(approver){
        					//As a member of the Education Queue, reject the Request
        					result =  Approval.process(req);
        					//Verify the results
        					System.assert(result.isSuccess());
        					//Ed Request status should be now 'Course Rejected'
        					//Note: the Education Queue's rejection will actually cause two field updates on the Status field
        					//the first update will change the status to 'ES Benefit Admin Rejected'
        					//inmediately after that the final rejection actions will execute,
        					//changing the status to 'Course Rejected'
        		
        					er = [select status__c from Education_Reimbursement_Request__c where Id=:er.Id];
        					System.assertEquals('Course Rejected',er.Status__c);
        				}
        			}else{
        				// insert a user into the Education Queue
        			}
        		}
        		
    	}
    }
    
    
    
     /**
    	As the final approver assigned by the Education Queue, approve the Ed Reimbursement Request
    */    
    static testMethod void FinalApproverApprovesEdReimbursementReq() {
    	User employee = GenerateEnvironmentTest.getEmployeeStandard();
    	employee = [select id, name, manager__c from user where id=:employee.Id];
    	User manager = [select id, name from user where id =: employee.manager__c];
    	Approval.ProcessResult result;
    	Education_Reimbursement_Request__c er = getEdReq();
    	System.runAs(employee){
    		result = submitForApproval(er, 'test comment, submitting the request to the manager');
    	}
    		
      
    	if ( result.isSuccess() ){
    			Id newWorkItemId =result.getNewWorkitemIds().get(0);
        		
      			// Instantiate the new ProcessWorkitemRequest object and populate it 
    
      			Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        		req.setComments('Test comment, manager approving request.');
        		req.setAction('Approve');
        		
        		Group edQueue = [select id from Group where name='Education Reimbursement'];    
    			req.setNextApproverIds(new Id[] {edQueue.Id });
        		// Use the ID from the newly created item to specify the item to be worked 
        		req.setWorkitemId(newWorkItemId);
        
        		System.runAs( manager ){
       				// Submit the request for approval     
        			result =  Approval.process(req);
        		}
        		if(result.isSuccess()){
        			User approver;
        			User nextApprover = GenerateEnvironmentTest.getSystemAdmin();
        			//Get a user from the Education Queue
        			Integer memberCount = [select count() from GroupMember where GroupId=:edQueue.Id ];
        			if(memberCount > 0){
        				Id approverId = [select UserOrGroupId from GroupMember where GroupId=:edQueue.Id  limit 1].UserOrGroupId;
        				approver = [select id from user where Id=:approverId];
        				req = new Approval.ProcessWorkitemRequest();
        				req.setComments('Test comment, Education Queue approving request.');
        				req.setAction('Approve');
        				req.setWorkitemId(result.getNewWorkitemIds().get(0));
        				req.setNextApproverIds(new Id[]{nextApprover.Id});
        				System.runAs(approver){
        					//As a member of the Education Queue, approve the Request
        					result =  Approval.process(req);

        				}
        				if(result.isSuccess()){
        						req = new Approval.ProcessWorkitemRequest();
        						req.setComments('Test comment, last approver approving request.');
        						req.setAction('Approve');
        						req.setWorkitemId(result.getNewWorkitemIds().get(0));
        						//req.setNextApproverIds(new Id[]{nextApprover.Id});
        						System.runAs(nextApprover){
        							result =  Approval.process(req);
        							
        						}
        						//Verify the results
        						System.assert(result.isSuccess());
        						er = [select status__c from Education_Reimbursement_Request__c where Id=:er.Id];
        						//Ed.Request status should be now 'Course Approved'
        						System.assertEquals('Course Approved',er.Status__c);
        				}
        			}else{
        				// insert a user into the Education Queue
        			}
        		}
        		
        		
        		
    	}
    }
    
     
     /**
    	As the final approver assigned by the Education Queue, reject the Ed Reimbursement Request
    */    
    static testMethod void FinalApproverRejectsEdReimbursementReq() {
    	User employee = GenerateEnvironmentTest.getEmployeeStandard();
    	employee = [select id, name, manager__c from user where id=:employee.Id];
    	User manager = [select id, name from user where id =: employee.manager__c];
    	Approval.ProcessResult result;
    	Education_Reimbursement_Request__c er = getEdReq();
    	System.runAs(employee){
    		result = submitForApproval(er, 'test comment, submitting the request to the manager');
    	}
    		
      
    	if ( result.isSuccess() ){
    			Id newWorkItemId =result.getNewWorkitemIds().get(0);
        		
      			// Instantiate the new ProcessWorkitemRequest object and populate it 
    
      			Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        		req.setComments('Test comment, manager approving request.');
        		req.setAction('Approve');
        		
        		Group edQueue = [select id from Group where name='Education Reimbursement'];    
    			req.setNextApproverIds(new Id[] {edQueue.Id });
        		// Use the ID from the newly created item to specify the item to be worked 
        		req.setWorkitemId(newWorkItemId);
        
        		System.runAs( manager ){
       				// Submit the request for approval     
        			result =  Approval.process(req);
        		}
        		if(result.isSuccess()){
        			User approver;
        			User nextApprover = GenerateEnvironmentTest.getSystemAdmin();
        			//Get a user from the Education Queue
        			Integer memberCount = [select count() from GroupMember where GroupId=:edQueue.Id ];
        			if(memberCount > 0){
        				Id approverId = [select UserOrGroupId from GroupMember where GroupId=:edQueue.Id  limit 1].UserOrGroupId;
        				approver = [select id from user where Id=:approverId];
        				req = new Approval.ProcessWorkitemRequest();
        				req.setComments('Test comment, Education Queue approving request.');
        				req.setAction('Approve');
        				req.setWorkitemId(result.getNewWorkitemIds().get(0));
        				req.setNextApproverIds(new Id[]{nextApprover.Id});
        				System.runAs(approver){
        					//As a member of the Education Queue, approve the Request
        					result =  Approval.process(req);

        				}
        				if(result.isSuccess()){
        						req = new Approval.ProcessWorkitemRequest();
        						req.setComments('Test comment, last approver rejecting request.');
        						req.setAction('Reject');
        						req.setWorkitemId(result.getNewWorkitemIds().get(0));
        						//req.setNextApproverIds(new Id[]{nextApprover.Id});
        						System.runAs(nextApprover){
        							result =  Approval.process(req);
        							
        						}
        						//Verify the results
        						System.assert(result.isSuccess());
        						er = [select status__c from Education_Reimbursement_Request__c where Id=:er.Id];
        						//Ed.Request status should be now 'Course Rejected'
        						System.assertEquals('Course Rejected',er.Status__c);
        				}
        			}else{
        				// insert a user into the Education Queue
        			}
        		}
        		
        		
        		
    	}
    }
    
    
    
     /**
    	As the manager of the employee, reject the Ed Reimbursement Request submitted by him
    */    
    static testMethod void managerRejectsEdReimbursementReq() {
    	User employee = GenerateEnvironmentTest.getEmployeeStandard();
    	employee = [select id, name, manager__c from user where id=:employee.Id];
    	User manager = [select id, name from user where id =: employee.manager__c];
    	Approval.ProcessResult result;
    	Education_Reimbursement_Request__c er = getEdReq();
    	System.runAs(employee){
    		result = submitForApproval(er, 'test comment, submitting the request to the manager');
    	}
    		
    	System.runAs(manager){
    		
    		if ( result.isSuccess() ){
    			Id newWorkItemId =result.getNewWorkitemIds().get(0);
        		
      			// Instantiate the new ProcessWorkitemRequest object and populate it 
    
      			Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        		req.setComments('Test comment, manager rejecting request.');
        		req.setAction('Reject');
        		
        		Group edQueue = [select id from Group where name='Education Reimbursement'];    
    			req.setNextApproverIds(new Id[] {edQueue.Id });
        		// Use the ID from the newly created item to specify the item to be worked 
        		req.setWorkitemId(newWorkItemId);
        
       			// Submit the request for approval     
        		Approval.ProcessResult result2 =  Approval.process(req);
        		
        		//Verify the results
        		System.assert( result2.isSuccess() );
        		//Ed.Request status shoud be now 'Course Rejected' 
        		//Note: the manager's rejection will actually cause two field updates on the Status field
        		//the first update will change the status to 'Manager Rejected'
        		//inmediately after that the final rejection actions will execute,
        		//changing the status to 'Course Rejected'
        		er = [select status__c from Education_Reimbursement_Request__c where id=:er.Id];
        		System.assertEquals ('Course Rejected', er.Status__c);
        
    		}
    	}
    }
    
    
    
    /**
    	As an employee, submit an Education Reimbursement Request to the manager for approval
    */    
    static testMethod void employeeSubmitsEdReqForApproval() {
    	User employee = GenerateEnvironmentTest.getEmployeeStandard();
    	
    		Education_Reimbursement_Request__c er = getEdReq();
    	system.runAs(employee){
    
			Approval.ProcessResult result = submitForApproval(er, 'test comment, submitting the request to the manager');

			// Verify the results  
			System.assert(result.isSuccess());
			//status should be now Awaiting Approval		
			er = [select id, status__c from Education_Reimbursement_Request__c where id=:er.Id];
			System.assertEquals('Awaiting Approval', er.Status__c);
    	}
    }
    
    /**
    	As an employee, try to submit an ed.reimbursement req with cost 0 for
    	approval. The 0 cost should cause the initial criteria
    	for submittal to fail  */    
    static testMethod void employeeSubmitsEdReqForApprovalWithCostZero() {
    	User employee = GenerateEnvironmentTest.getEmployeeStandard();
    	
    		Education_Reimbursement_Request__c er = getEdReq();
    		er.Cost__c = 0;
    		update er;
    	system.runAs(employee){
    
    		//try to submit the request for approval and verify that the initial submition criteria is not met
    		try{
				Approval.ProcessResult result = submitForApproval(er, 'test comment, submitting the request to the manager');
    		}catch(DmlException e){
    			 System.assertEquals(StatusCode.NO_APPLICABLE_PROCESS, e.getDmlType(0));
        		
    		}
			//the ed.reimbursement request's status should still be 'Not Submitted'		
			er = [select id, status__c from Education_Reimbursement_Request__c where id=:er.Id];
			System.assertEquals('Not Submitted', er.Status__c);
    	}
    }
    
    
    private static Education_Reimbursement_Request__c getEdReq(){
    	User employee = GenerateEnvironmentTest.getEmployeeStandard();
    	
    	system.runAs(employee){
    		Education_Reimbursement_Request__c er  = new Education_Reimbursement_Request__c();
    		er.Course_Name__c = 'test course name';
    		er.Course_Provider__c = 'test course provider';    	
    		er.Course_Start_Date__c = System.now().addDays(2).date();    	
    		er.Expected_Course_End_Date__c =  er.Course_Start_Date__c.addDays(30);
    		er.Cost__c = 1000;
    		insert er;
    		return er;	
    		
    	}
    	return null;
    	
    }
    
    private static Approval.ProcessResult submitForApproval(Education_Reimbursement_Request__c er, String submittalComments){
    		//create the initial approval request
    		Approval.ProcessSubmitRequest initialApprovalRequest = new Approval.ProcessSubmitRequest();
			initialApprovalRequest.setComments(submittalComments);
			initialApprovalRequest.setObjectId(er.Id);
			//submit the approval request to the manager  
			Approval.ProcessResult result = Approval.process(initialApprovalRequest);      
    		return result;
    }
    
    private static Approval.ProcessResult approve(Education_Reimbursement_Request__c er, Id nextApproverId, Id approverId, String comment){
    	//get the process instance
    	ProcessInstance procInstance = [select id from ProcessInstance where TargetObjectId =:er.Id limit 1];
		
		//get the process instance step
		ProcessInstanceStep procStep = [select id from ProcessInstanceStep where ProcessInstanceId=:procInstance.Id order by createdDate desc limit 1];
    	
    	
    	Id newWorkItemId = procStep.Id;
        		
      	// Instantiate the new ProcessWorkitemRequest object and populate it 
    
      	Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments(comment);
        req.setAction('Approve');
        req.setNextApproverIds(new Id[] {nextApproverId });
        req.setWorkitemId(newWorkItemId);
        
       	Approval.ProcessResult approveResult;
        
        //run as approver
        	
        User approver = [select id from user where id=:approverId limit 1];
        System.runAs(approver){
        	approveResult =  Approval.process(req);
        }	
        		
        		
        
    	return approveResult;
    }
}