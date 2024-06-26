@isTest(seeAllData=true)
//see all data set to true, because apparantly unit tests do not see queues!
public class ESDJC_WorkflowRulesTest{

	private static Contact amerContact;
	private static Contact apacContact;
	private static Contact emeaContact;
	private static Contact jpnContact;
	private static Contact amerFounContact ;

	private static testmethod void testESPPEscalations1() {						
		User sysAdm = ESDJC_TestUtil.getSysAdminUser();    
    	User esUser = null;    
	    System.runAs(sysAdm) {            
	    	init();	
	      //create ES user
	      esUser = ESDJC_TestUtil.createStandardUser('Employee Success Representative', 'ES Specialist Amer', 'US', 'Americas - USA');
	      ESDJC_TestUtil.assignPermission(esUser.Id, 'ES_DJC_Specialist');                 
		  Case newCase;
		  Test.startTest();
		  System.runAs(esUser) {
			newCase = createCase(emeaContact.id, 'ESPP', null, 'ESPP','ESPP');			
			newCase = updateCaseTier(newCase, 'Tier 2');		
		  }
		 Test.stopTest();
		 newCase = [select owner.name, recordtype.Name, Tier__c from case where id = :newCase.id];
		 system.assertEquals('ES GEPS - Global',newCase.owner.name);
	   }
	}

	private static testmethod void testESPPEscalations3() {						
		User sysAdm = ESDJC_TestUtil.getSysAdminUser();    
    	User esUser = null;    
	    System.runAs(sysAdm) {            
	    	init();	
	      //create ES user
	      esUser = ESDJC_TestUtil.createStandardUser('Employee Success Representative', 'ES Specialist Amer', 'US', 'Americas - USA');
	      ESDJC_TestUtil.assignPermission(esUser.Id, 'ES_DJC_Specialist');                 
		  Case newCase;
		  Test.startTest();
		  System.runAs(esUser) {
			//ES DJC Escalate My Info and My Team Info cases
			newCase = createCase(amerContact.id, 'My Information', null, 'INFO','INFO');
			newCase = updateCaseTier(newCase, 'Tier 2');
		  }
		 Test.stopTest();
		 newCase = [select owner.name, recordtype.Name, Tier__c from case where id = :newCase.id];
		 system.assertEquals('ES Ops - AMER',newCase.owner.name);
	   }
	}

	private static testmethod void testESPPEscalations4() {						
		User sysAdm = ESDJC_TestUtil.getSysAdminUser();    
    	User esUser = null;    
	    System.runAs(sysAdm) {            
	    	init();	
	      //create ES user
	      esUser = ESDJC_TestUtil.createStandardUser('Employee Success Representative', 'ES Specialist Amer', 'US', 'Americas - USA');
	      ESDJC_TestUtil.assignPermission(esUser.Id, 'ES_DJC_Specialist');                 
		  Case newCase;
		  Test.startTest();
		  System.runAs(esUser) {
			newCase = createCase(amerContact.id, 'My Team Information', null,'INFO','INFO');
			newCase = updateCaseTier(newCase, 'Tier 2');
		  }
		 Test.stopTest();
		 newCase = [select owner.name, recordtype.Name, Tier__c from case where id = :newCase.id];
		 system.assertEquals('ES Ops - AMER',newCase.owner.name);
	   }
	}

    private testmethod static void escalateNHWCases1(){
        User sysAdm = ESDJC_TestUtil.getSysAdminUser();    
        User esUser = null;    
        System.runAs(sysAdm) {            
            init();	
            //create ES user
            esUser = ESDJC_TestUtil.createStandardUser('Employee Success Representative', 'ES Specialist Amer', 'US', 'Americas - USA');
            ESDJC_TestUtil.assignPermission(esUser.Id, 'ES_DJC_Specialist');        
            Case newCase;         		
            Test.startTest();
            System.runAs(esUser) {
                //ES DJC Escalate NHW Cases
                newCase = createCase(amerContact.id, 'Contractor Setup', null, 'test','test');
                newCase = updateCaseTier(newCase, 'Tier 2');
            }
            Test.stopTest();
            newCase = [select owner.name, recordtype.Name, Tier__c from case where id = :newCase.id];
            system.assertEquals('ES Ops - AMER',newCase.owner.name);
        }
    }
		
	private testmethod static void escalateNHWCases2(){
		User sysAdm = ESDJC_TestUtil.getSysAdminUser();    
    	User esUser = null;    
	    System.runAs(sysAdm) {            
	    	init();	
	      	//create ES user
	      	esUser = ESDJC_TestUtil.createStandardUser('Employee Success Representative', 'ES Specialist Amer', 'US', 'Americas - USA');
	      	ESDJC_TestUtil.assignPermission(esUser.Id, 'ES_DJC_Specialist');        
	      	Case newCase;         		
		  	Test.startTest();
		  	System.runAs(esUser) {
				//ES DJC Escalate NHW Cases
				newCase = createCase(amerContact.id, 'New Hire Setup', null, 'test', 'test');
				newCase = updateCaseTier(newCase, 'Tier 2');		
		  	}
		Test.stopTest();
		newCase = [select owner.name, recordtype.Name, Tier__c from case where id = :newCase.id];
		system.assertEquals('ES Ops - AMER',newCase.owner.name);
	    }
	}
	private testmethod static void checkFoundationCannotBeEscalated(){
		User sysAdm = ESDJC_TestUtil.getSysAdminUser();    
    	User esUser = null;    
	    System.runAs(sysAdm) {            
	    	init();	
	      //create ES user
	      esUser = ESDJC_TestUtil.createStandardUser('Employee Success Representative', 'ES Specialist Amer', 'US', 'Americas - USA');
	      ESDJC_TestUtil.assignPermission(esUser.Id, 'ES_DJC_Specialist');                 
		  Case newCase;
		  emeaContact.department='FOUN-Foundation';
		  update emeaContact;
		  Test.startTest();
			newCase = createCase(emeaContact.id, 'ESPP', 'Tier 1' , 'ESPP','ESPP');	

		  System.runAs(esUser) {
			Boolean sawException = false;
			try{
				newcase.tier__c = 'Tier 2';
				update newcase;
			}catch(Exception e){
				sawException = true;
				system.assertEquals(e.getMessage().containsIgnoreCase('.org cases cannot be escalated'),true,'Expecting exception');
			}	
			system.assertEquals(sawException,true,'Expecting exception that .org cases cannot be escalated to Tier 2');
		  }
		 Test.stopTest();
		 newCase = [select owner.name, recordtype.Name, Tier__c from case where id = :newCase.id];
		 system.assertNotEquals(newCase.Tier__c,'Tier 2','Expecting Tier to be unchanged');
	   }
	}

	private testmethod static void escalateImmigrationReloAndRehireCases1(){
		User sysAdm = ESDJC_TestUtil.getSysAdminUser();    
    	User esUser = null;    
	    System.runAs(sysAdm) {            
	    	init();	
	      	//create ES user
	      	esUser = ESDJC_TestUtil.createStandardUser('Employee Success Representative', 'ES Specialist Amer', 'US', 'Americas - USA');
	      	ESDJC_TestUtil.assignPermission(esUser.Id, 'ES_DJC_Specialist');                 		
		  	Case newCase;
		  	Test.startTest();
		  	System.runAs(esUser) {

				//ES DJC Escalate Rehire Eligibility Cases
				newCase = createCase(amerContact.id, 'Rehire Eligibility',null, 'test','test');
				newCase = updateCaseTier(newCase, 'Tier 2');				
		  	}
		Test.stopTest();
		newCase = [select owner.name, recordtype.Name, Tier__c from case where id = :newCase.id];
		system.assertEquals('ES Employee Relations - Amer',newCase.owner.name);
		system.assertEquals('Employee Relations Case Type - AMER',newCase.RecordType.Name); //TODO: This one is failing in dev		
	    }
	}



	private testmethod static void escalateImmigrationReloAndRehireCases3(){
		User sysAdm = ESDJC_TestUtil.getSysAdminUser();    
    	User esUser = null;    
	    System.runAs(sysAdm) {            
	    	init();	
	      	//create ES user
	      	esUser = ESDJC_TestUtil.createStandardUser('Employee Success Representative', 'ES Specialist Amer', 'US', 'Americas - USA');
	      	ESDJC_TestUtil.assignPermission(esUser.Id, 'ES_DJC_Specialist');                 		
		  	Case newCase;
		  	Test.startTest();
		  	System.runAs(esUser) {		
				//ES DJC Escalate Immigration cases
				newCase = createCase(amerContact.id, 'Immigration', null, 'test','test');
				newCase = updateCaseTier(newCase, 'Tier 2');				
		  	}
		Test.stopTest();
		newCase = [select owner.name, recordtype.Name, Tier__c from case where id = :newCase.id];
		system.assertEquals('ES Immigration - Global',newCase.owner.name);
	    }
	}


	private testmethod static void escalateReportRequest1(){
		User sysAdm = ESDJC_TestUtil.getSysAdminUser();    
    	User esUser = null;    
	    System.runAs(sysAdm) {            
	    	init();	
	     	//create ES user
	      	esUser = ESDJC_TestUtil.createStandardUser('Employee Success Representative', 'ES Specialist Amer', 'US', 'Americas - USA');
	      	ESDJC_TestUtil.assignPermission(esUser.Id, 'ES_DJC_Specialist');                 		
		  	Case newCase;
		  	Test.startTest();
		  	System.runAs(esUser) {
				//ES DJC Escalate ES Data Request cases
				newCase = createCase(amerContact.id, 'ES Data Request', null, 'test','test');
				newCase = updateCaseTier(newCase, 'Tier 2');
				
		  	}
		Test.stopTest();
		newCase = [select owner.name, recordtype.Name, Tier__c from case where id = :newCase.id];
		system.assertEquals('ES Reporting - Global',newCase.owner.name);		
	    }
	}	
	
	private testmethod static void escalateReportRequest2(){
		User sysAdm = ESDJC_TestUtil.getSysAdminUser();    
    	User esUser = null;    
	    System.runAs(sysAdm) {            
	    	init();	
	     	//create ES user
	      	esUser = ESDJC_TestUtil.createStandardUser('Employee Success Representative', 'ES Specialist Amer', 'US', 'Americas - USA');
	      	ESDJC_TestUtil.assignPermission(esUser.Id, 'ES_DJC_Specialist');                 		
			case newCase;
		  	Test.startTest();
		  	System.runAs(esUser) {
				//ES DJC Escalate ES Data Request cases
				newCase = createCase(jpnContact.id, 'ES Data Request', null, 'test','test');
				newCase = updateCaseTier(newCase, 'Tier 2');

		  	}
		Test.stopTest();
		newCase = [select owner.name, recordtype.Name, Tier__c from case where id = :newCase.id];
		system.assertEquals('ES Reporting - Global',newCase.owner.name);
	    }
	}	

	private static testmethod void escalateBenefitsAndCompensation1(){
		User sysAdm = ESDJC_TestUtil.getSysAdminUser();    
    	User esUser = null;    
    	case newCase;
	    System.runAs(sysAdm) {            
	    	init();	
	     	//create ES user
	      	esUser = ESDJC_TestUtil.createStandardUser('Employee Success Representative', 'ES Specialist Amer', 'US', 'Americas - USA');
	      	ESDJC_TestUtil.assignPermission(esUser.Id, 'ES_DJC_Specialist');                 		
		  	Test.startTest();
		  	System.runAs(esUser) {
				//ES DJC Escalate Benefits Amer cases
				newCase = createCase(amerContact.id, 'Benefits', null, '401K','Enrollment');
				newCase = updateCaseTier(newCase, 'Tier 2');						
		  	}
		Test.stopTest();
		newCase = [select owner.name, recordtype.Name, Tier__c from case where id = :newCase.id];
		system.assertEquals('T2-Benefits-Amer',newCase.owner.name);			
	    }
	}

	private static testmethod void escalateBenefitsAndCompensation2(){
		User sysAdm = ESDJC_TestUtil.getSysAdminUser();    
    	User esUser = null;    
	    System.runAs(sysAdm) {            
	    	init();	
	     	//create ES user
	      	esUser = ESDJC_TestUtil.createStandardUser('Employee Success Representative', 'ES Specialist Amer', 'US', 'Americas - USA');
	      	ESDJC_TestUtil.assignPermission(esUser.Id, 'ES_DJC_Specialist');
	      	case newCase;                 		
		  	Test.startTest();
		  	System.runAs(esUser) {
		
				//ES DJC Escalate Benefits EMEA cases
				newCase = createCase(emeaContact.id, 'Benefits', null, '401K','Enrollment');
				newCase = updateCaseTier(newCase, 'Tier 2');				
		  	}
		Test.stopTest();
		newCase = [select owner.name, recordtype.Name, Tier__c from case where id = :newCase.id];
		system.assertEquals('T2-Benefits-EMEA',newCase.owner.name); 
	    }
	}

	private static testmethod void escalateBenefitsAndCompensation3(){
		User sysAdm = ESDJC_TestUtil.getSysAdminUser();    
    	User esUser = null;    
	    System.runAs(sysAdm) {            
	    	init();	
	     	//create ES user
	      	esUser = ESDJC_TestUtil.createStandardUser('Employee Success Representative', 'ES Specialist Amer', 'US', 'Americas - USA');
	      	ESDJC_TestUtil.assignPermission(esUser.Id, 'ES_DJC_Specialist');
	      	case newCase;                 		
		  	Test.startTest();
		  	System.runAs(esUser) {
				//ES DJC Escalate Compensation cases
				newCase = createCase(amerContact.id, 'Compensation', null, '401K','Enrollment');
				newCase = updateCaseTier(newCase, 'Tier 2');				
		  	}
		Test.stopTest();
		newCase = [select owner.name, recordtype.Name, Tier__c from case where id = :newCase.id];
		system.assertEquals('ES Compensation - Global',newCase.owner.name);		
	    }
	}

	private static testmethod void escalateJapanCases01(){
		User sysAdm = ESDJC_TestUtil.getSysAdminUser();    
    	User esUser = null;    
	    System.runAs(sysAdm) {            
	    	init();	
	     	//create ES user
	      	esUser = ESDJC_TestUtil.createStandardUser('Employee Success Representative', 'ES Specialist Amer', 'US', 'Americas - USA');
	      	ESDJC_TestUtil.assignPermission(esUser.Id, 'ES_DJC_Specialist');
	      	Case newCase;                 		
		  	Test.startTest();
		  	System.runAs(esUser) {
				//ES DJC Escalate Japan cases of Type Payroll
				newCase = createCase(jpnContact.id, 'Payroll', null, 'payroll','payroll');
				newCase = updateCaseTier(newCase, 'Tier 2');		
		  	}
		Test.stopTest();
		newCase = [select owner.name, recordtype.Name, Tier__c from case where id = :newCase.id];
		system.assertEquals('Test User',newCase.owner.name);
	    }
	}

	private testmethod static void escalateERCases1(){
		User sysAdm = ESDJC_TestUtil.getSysAdminUser();    
    	User esUser = null;    
	    System.runAs(sysAdm) {            
	    	init();	
	     	//create ES user
	      	esUser = ESDJC_TestUtil.createStandardUser('Employee Success Representative', 'ES Specialist Amer', 'US', 'Americas - USA');
	      	ESDJC_TestUtil.assignPermission(esUser.Id, 'ES_DJC_Specialist');                 		
		  	Case newCase;
		  	Test.startTest();
		  	System.runAs(esUser) {
				//ES DJC Escalate ER Amer cases
				newCase = createCase(amerContact.id, 'Employee Relations', null, 'test','test');
				newCase = updateCaseTier(newCase, 'Tier 2');										
		  	}
		Test.stopTest();
		newCase = [select owner.name, recordtype.Name, Tier__c from case where id = :newCase.id];
		system.assertEquals('ES Employee Relations - Amer',newCase.owner.name);		
	    }
	}
	
	private testmethod static void escalateERCases2(){
		User sysAdm = ESDJC_TestUtil.getSysAdminUser();    
    	User esUser = null;    
	    System.runAs(sysAdm) {            
	    	init();	
	     	//create ES user
	      	esUser = ESDJC_TestUtil.createStandardUser('Employee Success Representative', 'ES Specialist Amer', 'US', 'Americas - USA');
	      	ESDJC_TestUtil.assignPermission(esUser.Id, 'ES_DJC_Specialist');
	      	case newCase;                 		
		  	Test.startTest();
		  	System.runAs(esUser) {
				//ES DJC Escalate ER APAC cases
				newCase = createCase(apacContact.id, 'Employee Relations', null, 'test','test');
				newCase = updateCaseTier(newCase, 'Tier 2');
				
		  	}
		Test.stopTest();
		newCase = [select owner.name, recordtype.Name, Tier__c from case where id = :newCase.id];
		system.assertEquals('ES Employee Relations - APAC',newCase.owner.name);		
	    }
	}	

	private testmethod static void escalateExpenseCases(){
		User sysAdm = ESDJC_TestUtil.getSysAdminUser();    
    	case newCase;
	    System.runAs(sysAdm) {            
	    	init();
		  	Test.startTest();
            newCase = createCase(amerContact.id, 'Expense / Amex', null, 'Expense', 'Banking Details');
            newCase = updateCaseTier(newCase, 'Tier 2');
			Test.stopTest();
			newCase = [select owner.name, recordtype.Name, Tier__c from case where id = :newCase.id];
			System.assertEquals('Expense - Global', newCase.owner.name);
            System.assertEquals('Tier 2', newCase.Tier__c);
        }
	}

	private static case createCase(id contactid, String type, String tier, String topic, String subtopic){
		Case c = new Case();
		c.ContactId = contactid;
		c.Type = type;
		c.Tier__c = tier;
		if (topic!=null){
			c.ES_DJC_Topic__c = topic;
		}
		if (subtopic!=null){
			c.ES_DJC_Sub_Topic__c = subtopic;
		}
		insert c;
		Case newCase = [select id, owner.name, recordtype.Name, Tier__c from case where id = :c.id];
		return newCase;		
	}

	private static User createESDJCRep(String userEmail, String plastname, String palias){
		Profile p = [select id from profile 
		where name = 'Employee' 
		limit 1];   
		
		User pu = new User(profileId = p.id, username = userEmail, email = userEmail, 
		emailencodingkey = 'UTF-8', localesidkey = 'en_US', 
		languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', 
		alias=palias, lastname=plastname);		
		//Database.insert(pu);
		
		List<PermissionSet> permsets = [SELECT Id,Name FROM PermissionSet where name IN ('ES_DJC_Specialist','ES_DJC_Specialist','ES_DJC_Sensitive')];
		List<PermissionSetAssignment> permSetAssignment = new List<PermissionSetAssignment>();
		permSetAssignment.add(new PermissionSetAssignment(PermissionSetId = permsets[0].Id,AssigneeId = pu.id ));
		permSetAssignment.add(new PermissionSetAssignment(PermissionSetId = permsets[1].Id,AssigneeId = pu.id ));
		permSetAssignment.add(new PermissionSetAssignment(PermissionSetId = permsets[2].Id,AssigneeId = pu.id ));
		insert permSetAssignment;
		return pu;
	}
	
	private static Case updateCaseTier(Case c, String tier){
		Case newCase = new Case(id=c.id);
		newCase.Tier__c = tier;
		update newCase;
		return newCase;		
	}
	
	private static void init(){
		amerContact = ESDJC_AssignmentHelper.getContacts(1, 'Americas - USA', 'San Francisco')[0];
		apacContact = ESDJC_AssignmentHelper.getContacts(1, 'APAC - All Countries', 'Mumbai')[0];
		emeaContact = ESDJC_AssignmentHelper.getContacts(1, 'EMEA - All Countries', 'London')[0];
		jpnContact = ESDJC_AssignmentHelper.getContacts(1, 'Japan', 'Tokyo')[0];		
		amerFounContact = ESDJC_AssignmentHelper.createContactsByDeptDivWorkLoc(1, 'Americas - USA','FOUN-Foundation', 'San Francisco')[0];

	}
	
}