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
private class TestPF_FitnessReimbursement_QE {

	/**
		Test the required fields
	*/
    static testMethod void requiredFields() {
        // try to insert a new Fitness Reimbursement Requests without filling in the required fields
        // verify that an DML exception is thrown due to the missing required fields
        Fitness_Reimbursement__c fr = new Fitness_Reimbursement__c();
        fr.Signature__c = true;
        try{
        	insert fr;
        }catch(DmlException e){
        	 System.assertEquals(StatusCode.REQUIRED_FIELD_MISSING, e.getDmlType(0));
        	 //verify the list of required fields 
        	 sObjectField[] fields = e.getDmlFields(0);
        	 Map<String,sObjectField> fieldsMap = new Map<String,sObjectField>();
        	 for(sObjectField f : fields){
        	 	fieldsMap.put(f.getDescribe().getName(),f );
        	 }
        	 System.assert(fieldsMap.containsKey('Total_Amount_Requested__c'));
        	 System.assert(fieldsMap.containsKey('Fitness_Provider_Name_Location__c'));
        	 System.assert(fieldsMap.containsKey('Amount_Requested__c'));
        	 System.assert(fieldsMap.containsKey('Activity_Receipt_Date__c'));
        
        } 
    }
    

	/**
		As an employee, try to create a Fitness Reimbursement request without the employee signature
		A Custom Validation Exception should be thrown
	*/
    static testMethod void submitWithoutSignature() {
        Fitness_Reimbursement__c fr = new Fitness_Reimbursement__c();
        
       try{
        	insert fr;
       }catch(DmlException e){
        	 System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        	 //verify the Signature field was the one that caused the exception
        	 sObjectField[] fields = e.getDmlFields(0);
        	 Map<String,sObjectField> fieldsMap = new Map<String,sObjectField>();
        	 for(sObjectField f : fields){
        	 	fieldsMap.put(f.getDescribe().getName(),f );        	 	
        	 }
        	 System.assert(fieldsMap.containsKey('Signature__c'));
        
        } 
    }
    


     
    /**
    	As an employee, create a new Fitness Reimbursement Request
    */    
    static testMethod void employeeCreatesFitReimbursementReq() {
    	User employee = GenerateEnvironmentTest.getEmployeeStandard();
    	System.runAs(employee){
    		Fitness_Reimbursement__c fr = new Fitness_Reimbursement__c();
    		fr.Country__c = 'United States';
    		fr.Currency__c = 'USD';    	
    		fr.Claim_Period__c = 'Jan - Mar';    	
    		fr.Total_Amount_Requested__c = 700;
    		fr.Activity_Receipt_Date__c = System.now().Date();
    		fr.Fitness_Activity__c = 'Golf Lessons';
    		fr.Fitness_Provider_Name_Location__c = 'test provider location';
    		fr.Amount_Requested__c = 700;
    		fr.Signature__c = true;
    		insert fr;
    		
    		//Status after creation should be Not Submitted
    		fr = [select status__c from Fitness_Reimbursement__c where id=:fr.Id];
    		System.debug('fr status: ' + fr.Status__c);
    	}
    	
    }
    
    /**
    	As an employee, submit a Fitness Reimbursement Request for approval without attaching the receipt
    	A Field Custom Validation Exception should be thrown
    */    
    static testMethod void employeeSubmitsFitReqForApprovalWithoutAttach() {
    	User employee = GenerateEnvironmentTest.getEmployeeStandard();
    	
    		Fitness_Reimbursement__c fr = getFitReimbursementReq();
    	system.runAs(employee){
    
    		try{
				Approval.ProcessResult result = submitForApproval(fr, 'test comment, submitting the fitness reimb. request for approval');
    		}catch(DmlException e){
    			System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
       		 	System.assertEquals( 'Process failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, You must attach your receipts before submitting your fitness reimbursement request. Click the Back button on your browser to return to your claim request.: []',e.getMessage());
        	 }
    	
    	}
    }
    
    /**
    	As an employee, submit a Fitness Reimbursement Request for approval 
    */    
    static testMethod void employeeSubmitsFitReqForApproval() {
    	User employee = GenerateEnvironmentTest.getEmployeeStandard();
    	
    		Fitness_Reimbursement__c fr = getFitReimbursementReq();
    	system.runAs(employee){
    		//you need to add an attachment to the request in order to submit it for approval
    		Attachment a = new Attachment();
    		a.parentId = fr.Id;
    		a.name = 'test attachment name';    		
    		a.body = Blob.valueOf('test attachment body');
    		insert a;

			Approval.ProcessResult result = submitForApproval(fr, 'test comment, submitting the fitness reimb. request for approval');
 
    
			//Verify the results  
			System.assert(result.isSuccess());
			//status should be now Pending Approval		
			fr = [select id, status__c from Fitness_Reimbursement__c where id=:fr.Id];
			System.assertEquals('Pending Approval', fr.Status__c);
    	
    	}
    }
    
   /**
    	As the assigned approver, do the final approve on the Fitness Reimbursement request
    */    
    static testMethod void FitReqFinalApproval() {
    	User employee = GenerateEnvironmentTest.getEmployeeStandard();
    	
    	Fitness_Reimbursement__c fr = getFitReimbursementReq();
    	Approval.ProcessResult result;
    	system.runAs(employee){
    		//you need to add an attachment to the request in order to submit it for approval
    		Attachment a = new Attachment();
    		a.parentId = fr.Id;
    		a.name = 'test attachment name';    		
    		a.body = Blob.valueOf('test attachment body');
    		insert a;

			result = submitForApproval(fr, 'test comment, submitting the fitness reimb. request for approval');
 
    	}
    	if(result.isSuccess()){
    			Id newWorkItemId =result.getNewWorkitemIds().get(0);
        		
      			// Instantiate the new ProcessWorkitemRequest object and populate it 
    
      			Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        		req.setComments('Test comment, final approval on the Fitnes Reimbursement request.');
        		req.setAction('Approve');
        		
        		// Use the ID from the newly created item to specify the item to be worked 
        		req.setWorkitemId(newWorkItemId);
        
       			// Submit the request for approval     
        		result =  Approval.process(req);
        		
        		//Verify the results
        		System.assert( result.isSuccess() );
        		//Ed.Request status shoud be now 'Approved'
        		fr = [select status__c from Fitness_Reimbursement__c where id=:fr.Id];
        		System.assertEquals ('Approved', fr.Status__c);
        
    	}
    }
    
    /**
    	As the assigned approver, reject the Fitness Reimbursement request
    */    
    static testMethod void FitReqFinalRejection() {
    	User employee = GenerateEnvironmentTest.getEmployeeStandard();
    	
    	Fitness_Reimbursement__c fr = getFitReimbursementReq();
    	Approval.ProcessResult result;
    	system.runAs(employee){
    		//you need to add an attachment to the request in order to submit it for approval
    		Attachment a = new Attachment();
    		a.parentId = fr.Id;
    		a.name = 'test attachment name';    		
    		a.body = Blob.valueOf('test attachment body');
    		insert a;

			result = submitForApproval(fr, 'test comment, submitting the fitness reimb. request for approval');
 
    	}
    	if(result.isSuccess()){
    			Id newWorkItemId =result.getNewWorkitemIds().get(0);
        		
      			// Instantiate the new ProcessWorkitemRequest object and populate it 
    
      			Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        		req.setComments('Test comment, rejecting the Fitnes Reimbursement request.');
        		req.setAction('Reject');
        		
        		// Use the ID from the newly created item to specify the item to be worked 
        		req.setWorkitemId(newWorkItemId);
        
       			// Submit the request for approval     
        		result =  Approval.process(req);
        		
        		//Verify the results
        		System.assert( result.isSuccess() );
        		//Ed.Request status shoud be now 'Rejected'
        		fr = [select status__c from Fitness_Reimbursement__c where id=:fr.Id];
        		System.assertEquals ('Rejected', fr.Status__c);
        
    	}
    }
    
    
    /**
    	Attach 5000+ files to a Fitness Reimbursement req, test if the trigger explodes 
    */    
    static testMethod void stressAttachLimit() {
    	User employee = GenerateEnvironmentTest.getEmployeeStandard();
    	
    		Fitness_Reimbursement__c fr = getFitReimbursementReq();
    	system.runAs(employee){
    		List<Attachment> attachList = new List<Attachment>();
    		
    		//do the insert in two batchs, otherwise you get a too many dml statments error
    		for(Integer i=0; i <=6000; i++){
    			Attachment a = new Attachment();
    			a.parentId = fr.Id;
    			a.name = 'test attachment name';    		
    			a.body = Blob.valueOf('test attachment body');
    			attachList.add(a);
    		}
    		insertAttachs(attachList);
    	/*
    		attachList = new List<Attachment>();
    		
    		//second batch
    		for(Integer i=0; i <=6000; i++){
    			Attachment a = new Attachment();
    			a.parentId = fr.Id;
    			a.name = 'test attachment name';    		
    			a.body = Blob.valueOf('test attachment body');
    			attachList.add(a);
    		}
    		System.runAs( GenerateEnvironmentTest.getSystemAdmin() ){
    			insertAttachs(attachList);
    		}*/
			Approval.ProcessResult result = submitForApproval(fr, 'test comment, submitting the fitness reimb. request for approval');
 
    
			//Verify the results  
			System.assert(result.isSuccess());
			//status should be now Pending Approval		
			fr = [select id, status__c from Fitness_Reimbursement__c where id=:fr.Id];
			System.assertEquals('Pending Approval', fr.Status__c);
    	
    	}
    }
    
    
    private static Fitness_Reimbursement__c getFitReimbursementReq(){
    	User employee = GenerateEnvironmentTest.getEmployeeStandard();
    	System.runAs(employee){
    		Fitness_Reimbursement__c fr = new Fitness_Reimbursement__c();
    		fr.Country__c = 'United States';
    		fr.Currency__c = 'USD';    	
    		fr.Claim_Period__c = 'Jan - Mar';    	
    		fr.Total_Amount_Requested__c = 700;
    		fr.Activity_Receipt_Date__c = System.now().Date();
    		fr.Fitness_Activity__c = 'Golf Lessons';
    		fr.Fitness_Provider_Name_Location__c = 'test provider location';
    		fr.Amount_Requested__c = 700;
    		fr.Signature__c = true;
    		insert fr;
    		
    		return fr;
    	}
    	return null;
    }
    
    private static Approval.ProcessResult submitForApproval(Fitness_Reimbursement__c fr, String submittalComments){
    		//create the initial approval request
    		Approval.ProcessSubmitRequest initialApprovalRequest = new Approval.ProcessSubmitRequest();
			initialApprovalRequest.setComments(submittalComments);
			initialApprovalRequest.setObjectId(fr.Id);
			//submit the approval request to the manager  
			Approval.ProcessResult result = Approval.process(initialApprovalRequest);      
    		return result;
    }
    
    private static List<Attachment> insertAttachs(List<Attachment> attachs){
    	insert attachs;
    	return attachs;
    }
}