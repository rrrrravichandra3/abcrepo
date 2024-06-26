@isTest(seeAllData=false)

private class ES_DJC_AssignmentRulesTest {
	private static Contact amerFounContact = ESDJC_AssignmentHelper.createContactsByDeptDivWorkLoc(1, 'Americas - USA','FOUN-Foundation', 'San Francisco')[0];
	private static Contact APACFounContact = ESDJC_AssignmentHelper.createContactsByDeptDivWorkLoc(1, 'APAC - All Countries','FOUN-Foundation', 'Mumbai')[0];
	private static Contact EMEAFounContact = ESDJC_AssignmentHelper.createContactsByDeptDivWorkLoc(1, 'EMEA - All Countries','FOUN-Foundation', 'London')[0];
	private static Contact JpnFounContact = ESDJC_AssignmentHelper.createContactsByDeptDivWorkLoc(1, 'Japan','FOUN-Foundation', 'Tokyo')[0];

    private static set<string> caseTypesForFoun = new set<string>{'401K/RRSP','Benefits','Compensation','ESPP','G4G',
																	'Generic Concierge Ticket','Immigration','New Hire Setup','Payroll',
																	'Relocation & Visas','Separations','Talent Development','Travel','Expense / Amex',
																	'Employee Relations','My Team Information','My Information','ES Data Request'																	
																	};
	
	static testMethod void testFoundationCasesAssignmentAMER(){
		ESDJC_TestUtil.init();		
		ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
		system.assertEquals(settings.Foundation_Dept_Names__c,'FOUN-Foundation');
		system.assertEquals(amerFounContact.department,'FOUN-Foundation');
		list<case> cases = new list<case>();
		for(String s: new list<string>(caseTypesForFoun)){
			case Amercase = new case();
			Amercase.Type = s;
			Amercase.Tier__c = 'Tier 1'; 
			Amercase.origin= 'Concierge';
			Amercase.ContactId=amerFounContact.id;
			Amercase.setOptions(ESDJC_Util.getAssignmentRulesDMLOption(null));
			cases.add(Amercase);
		}
		insert cases;
		list<case> createdcases = [select type,Is_Foundation__c,ownerId,recordType.name from case where id in :cases];
		for(case c: createdcases){	
			system.assertEquals(c.Is_Foundation__c,true);		
			if(c.type.containsIgnoreCase('Expense') || c.type.containsIgnoreCase('Travel') ){
				system.assertEquals(c.ownerId,ESDJC_AssignmentHelper.getQueueId('org_Travel_Expense') );
			}
			else if(c.type.containsIgnoreCase('Payroll')){
				system.assertEquals(c.ownerId,ESDJC_AssignmentHelper.getQueueId('org_Payroll') );				
			}
			else{
				system.assertEquals(c.ownerId,ESDJC_AssignmentHelper.getQueueId('org_Employee_Success'),c.type );
			}
		}

	}

	static testMethod void testFoundationCasesAssignmentJapan(){
		ESDJC_TestUtil.init();		
		ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
		system.assertEquals(settings.Foundation_Dept_Names__c,'FOUN-Foundation');
		system.assertEquals(JpnFounContact.department,'FOUN-Foundation');
		list<case> cases = new list<case>();
		for(String s: new list<string>(caseTypesForFoun)){
			case Amercase = new case();
			Amercase.Type = s;
			Amercase.Tier__c = 'Tier 1'; 
			Amercase.origin= 'Concierge';
			Amercase.ContactId=JpnFounContact.id;
			Amercase.setOptions(ESDJC_Util.getAssignmentRulesDMLOption(null));			
			cases.add(Amercase);
		}
		insert cases;
		list<case> createdcases = [select type,Is_Foundation__c,ownerId,recordType.name from case where id in :cases];
		for(case c: createdcases){	
			system.assertEquals(c.Is_Foundation__c,true);		
			if(c.type.containsIgnoreCase('Expense') || c.type.containsIgnoreCase('Travel') ){
				system.assertEquals(c.ownerId,ESDJC_AssignmentHelper.getQueueId('org_Travel_Expense') );
			}
			else if(c.type.containsIgnoreCase('Payroll')){
				system.assertEquals(c.ownerId,ESDJC_AssignmentHelper.getQueueId('org_Payroll') );				
			}
			else{
				system.assertEquals(c.ownerId,ESDJC_AssignmentHelper.getQueueId('org_Employee_Success'),c.type );
			}
		}

	}
		static testMethod void testFoundationCasesAssignmentAPAC(){
		ESDJC_TestUtil.init();		
		ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
		system.assertEquals(settings.Foundation_Dept_Names__c,'FOUN-Foundation');
		system.assertEquals(APACFounContact.department,'FOUN-Foundation');
		list<case> cases = new list<case>();
		for(String s: new list<string>(caseTypesForFoun)){
			case Amercase = new case();
			Amercase.Type = s;
			Amercase.Tier__c = 'Tier 1'; 
			Amercase.origin= 'Concierge';
			Amercase.ContactId=APACFounContact.id;
			Amercase.setOptions(ESDJC_Util.getAssignmentRulesDMLOption(null));			
			cases.add(Amercase);
		}
		insert cases;
		list<case> createdcases = [select type,Is_Foundation__c,ownerId,recordType.name from case where id in :cases];
		for(case c: createdcases){	
			system.assertEquals(c.Is_Foundation__c,true);		
			if(c.type.containsIgnoreCase('Expense') || c.type.containsIgnoreCase('Travel') ){
				system.assertEquals(c.ownerId,ESDJC_AssignmentHelper.getQueueId('org_Travel_Expense') );
			}
			else if(c.type.containsIgnoreCase('Payroll')){
				system.assertEquals(c.ownerId,ESDJC_AssignmentHelper.getQueueId('org_Payroll') );				
			}
			else{
				system.assertEquals(c.ownerId,ESDJC_AssignmentHelper.getQueueId('org_Employee_Success'),c.type );
			}
		}

	}
	static testMethod void testFoundationCasesAssignmentEMEA(){
		ESDJC_TestUtil.init();		
		ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
		system.assertEquals(settings.Foundation_Dept_Names__c,'FOUN-Foundation');
		system.assertEquals(EMEAFounContact.department,'FOUN-Foundation');
		list<case> cases = new list<case>();
		for(String s: new list<string>(caseTypesForFoun)){
			case Amercase = new case();
			Amercase.Type = s;
			Amercase.Tier__c = 'Tier 1'; 
			Amercase.origin= 'Concierge';
			Amercase.ContactId=EMEAFounContact.id;
			Amercase.setOptions(ESDJC_Util.getAssignmentRulesDMLOption(null));			
			cases.add(Amercase);
		}
		insert cases;
		list<case> createdcases = [select type,Is_Foundation__c,ownerId,recordType.name from case where id in :cases];
		for(case c: createdcases){	
			system.assertEquals(c.Is_Foundation__c,true);		
			if(c.type.containsIgnoreCase('Expense') || c.type.containsIgnoreCase('Travel') ){
				system.assertEquals(c.ownerId,ESDJC_AssignmentHelper.getQueueId('org_Travel_Expense') );
			}
			else if(c.type.containsIgnoreCase('Payroll')){
				system.assertEquals(c.ownerId,ESDJC_AssignmentHelper.getQueueId('org_Payroll') );				
			}
			else{
				system.assertEquals(c.ownerId,ESDJC_AssignmentHelper.getQueueId('org_Employee_Success'),c.type );
			}
		}

	}	
	static testMethod void testEmailToCaseAMER(){
		Test.startTest();
	     
		/* Case created via email-to-case */
	 	/* ES Specialist Amer */
	 	createCaseAndAssert('Americas - USA','San Francisco','All Case Types except ER - AMER','Email to Case_AMER',ESDJC_AssignmentHelper.getQueueId('ES_Specialist_Amer'));
	  	/*Payroll Amer */
	 	createCaseAndAssert('Americas - USA','San Francisco','All Case Types except ER - AMER','Email to Case_Payroll AMER',ESDJC_AssignmentHelper.getQueueId('ES_Payroll_Amer'));
        /*Payroll Amer - Canada*/
        createCaseAndAssert('Americas - Canada','Monterial','All Case Types except ER - AMER','Email to Case_Payroll AMER',ESDJC_AssignmentHelper.getQueueId('ES_Payroll_Amer'));
	 	Test.stopTest();
	}
	
	static testMethod void testEmailToCaseEMEA(){
		Test.startTest();
		/* ES Specliast EMEA  */
	 	createCaseAndAssert('EMEA - All Countries','London','All Case Types except ER - EMEA','Email to Case_EMEA',ESDJC_AssignmentHelper.getQueueId('ES_Specialist_EMEA'));
	 	/*Payroll EMEA*/
	 	createCaseAndAssert('EMEA - All Countries','London','All Case Types except ER - EMEA','Email to Case_Payroll EMEA',ESDJC_AssignmentHelper.getQueueId('ES_Payroll_EMEA'));
	 	Test.stopTest();
	}
         
	static testMethod void testEmailToCaseAPAC(){
		Test.startTest();
		/*ES Specialist - APAC*/
	 	createCaseAndAssert('APAC - All Countries','Sydney','All Case Types except ER - APAC','Email to Case_APAC',ESDJC_AssignmentHelper.getQueueId('ES_Specialist_APAC'));
	 	/*Payroll APAC*/
	 	createCaseAndAssert('APAC - All Countries','Sydney','All Case Types except ER - APAC','Email to Case_Payroll APAC',ESDJC_AssignmentHelper.getQueueId('ES_Payroll_APAC'));
	 	Test.stopTest();
	}
         
	static testMethod void testEmailToCaseJapan(){
		Test.startTest();
		/*ES Specialist Japan*/
		createCaseAndAssert('Japan','Tokyo','All Case Types except ER - Japan','Email to Case_Japan',ESDJC_AssignmentHelper.getQueueId('ES_Specialist_Japan'));
		/*Payroll JAPAN*/
		createCaseAndAssert('Japan','Tokyo','All Case Types except ER - Japan','Email to Case_Payroll Japan',ESDJC_AssignmentHelper.getQueueId('Payroll_Japan'));
		Test.stopTest();
        
     }
     
     static testMethod void testREWSIndyQueue1() {
     	Test.startTest();
     	Id indyQueueId = ESDJC_AssignmentHelper.getQueueId('REWS_Workplace_Services_Indy');
     	createCaseAndAssert('Americas - USA', 'Indianapolis', 'All REWS cases - AMER - NonHQ', 'REWS - Web', 'Building Maintenance', null, 'New', indyQueueId);
     	createCaseAndAssert('Americas - USA', 'Indianapolis', 'All REWS cases - AMER - NonHQ', 'REWS - Web', 'Employee Moves & Workspace Assignments', null,'New', indyQueueId);
     	Test.stopTest();
     }
     
     static testMethod void testREWSIndyQueue2() {
     	Test.startTest();
     	Id indyQueueId = ESDJC_AssignmentHelper.getQueueId('REWS_Workplace_Services_Indy');
     	createCaseAndAssert('Americas - USA', 'Indianapolis', 'All REWS cases - AMER - NonHQ', 'REWS - Web', 'Event & Meeting Setup', null,'New', indyQueueId);
     	createCaseAndAssert('Americas - USA', 'Indianapolis', 'All REWS cases - AMER - NonHQ', 'REWS - Web', 'Furniture Requests',null,'New', indyQueueId);
     	Test.stopTest();
     }
     
     static testMethod void testREWSIndyQueue3() {
     	Test.startTest();
     	Id indyQueueId = ESDJC_AssignmentHelper.getQueueId('REWS_Workplace_Services_Indy');
     	createCaseAndAssert('Americas - USA', 'Indianapolis', 'All REWS cases - AMER - NonHQ', 'REWS - Web', 'Local Amenities',null, 'New',indyQueueId);
     	createCaseAndAssert('Americas - USA', 'Indianapolis', 'All REWS cases - AMER - NonHQ', 'REWS - Web', 'Mail Services', null,'New', indyQueueId);
     	createCaseAndAssert('Americas - USA', 'Indianapolis', 'All REWS cases - AMER - NonHQ', 'REWS - Web', 'Office & Workstation Supplies', null,'New', indyQueueId);
     	Test.stopTest();
     }
    
    //Wellness - Saved
     static testMethod void testWellnessSavedStatus() {
     	Test.startTest();
     	Id queueId = ESDJC_AssignmentHelper.getQueueId('DJC_Reimbursement_Cases_Saved');
     	createCaseAndAssert('EMEA - All Countries', 'France', 'All Expense Cases', 'Employee Success - Web', 'Wellness Reimbursement Request',null,'Saved', queueId);
        createCaseAndAssert('APAC - All Countries', 'India', 'All Expense Cases', 'Employee Success - Web', 'Wellness Reimbursement Request',null,'Saved', queueId);
     	Test.stopTest();
     }
    //Wellness - Submit - APAC
     static testMethod void testWellnessSubmitAPAC() {
     	Test.startTest();
     	Id queueId = ESDJC_AssignmentHelper.getQueueId('ES_Specialist_APAC');     
        createCaseAndAssert('APAC - All Countries', 'India', 'All Expense Cases', 'Employee Success - Web', 'Wellness Reimbursement Request',null,'Submitted', queueId);
     	Test.stopTest();
     }
	  //Wellness - Submit - ES_Specialist_LACA queue
     static testMethod void testWellnessSubmitQueue() {
       Test.startTest();
       Id queueId = ESDJC_AssignmentHelper.getQueueId('ES_Specialist_LACA');     
       createCaseAndAssert('Americas - Latin America', 'Brazil', 'All Expense Cases', 'Employee Success - Web', 'Wellness Reimbursement Request',null,'Submitted', queueId);
       Test.stopTest();
     }
     
     //Education - Submit - ES_Specialist_LACA queue
     static testMethod void testEducationSubmitQueue() {
       Test.startTest();
       Id queueId = ESDJC_AssignmentHelper.getQueueId('ES_Specialist_LACA');     
        createCaseAndAssert('Americas - Latin America', 'Brazil', 'All Expense Cases', 'Employee Success - Web', 'Education Reimbursement Request',null,'Submitted', queueId);
       Test.stopTest();
     }

	 //Wellness - Submit - EMEA
     static testMethod void testWellnessSubmitEMEA() {
     	Test.startTest();
     	Id queueId = ESDJC_AssignmentHelper.getQueueId('ES_Benefits_EMEA');     
        createCaseAndAssert('EMEA - All Countries', 'France', 'All Expense Cases', 'Employee Success - Web', 'Wellness Reimbursement Request',null,'Submitted', queueId);
     	Test.stopTest();
     }

	//feedback cases for ES Specialist
     static testMethod void testArticleFeedbackForESSpecialist1() {
     	Test.startTest();
     	Id esSpecialist = ESDJC_AssignmentHelper.getQueueId('ES_Specialist_Amer');
     	createCaseForFeedbackAndAssert('Americas - USA', 'Indianapolis', 'Article Feedback','Health & Safety', esSpecialist);
     	createCaseForFeedbackAndAssert('Americas - USA', 'Indianapolis', 'Article Feedback', 'Branding', esSpecialist);
     	createCaseForFeedbackAndAssert('Americas - USA', 'Indianapolis', 'Article Feedback', 'Foundation', esSpecialist);
     	Test.stopTest();
     }
	//feedback cases for ES Specialist
     static testMethod void testArticleFeedbackForESSpecialist2() {
     	Test.startTest();
     	Id esSpecialist = ESDJC_AssignmentHelper.getQueueId('ES_Specialist_Amer');
		createCaseForFeedbackAndAssert('Americas - USA', 'Indianapolis', 'Article Feedback', 'Internal Audit', esSpecialist);
		createCaseForFeedbackAndAssert('Americas - USA', 'Indianapolis', 'Article Feedback', 'Legal', esSpecialist);
		createCaseForFeedbackAndAssert('Americas - USA', 'Indianapolis', 'Article Feedback', 'Pricing & Product Ops', esSpecialist);
     	Test.stopTest();
     }
	//feedback cases for ES Specialist
     static testMethod void testArticleFeedbackForESSpecialist3() {
     	Test.startTest();
     	Id esSpecialist = ESDJC_AssignmentHelper.getQueueId('ES_Specialist_Amer');
		createCaseForFeedbackAndAssert('Americas - USA', 'Indianapolis', 'Article Feedback', 'Sales/CFL', esSpecialist);
		createCaseForFeedbackAndAssert('Americas - USA', 'Indianapolis', 'Article Feedback', 'Sustainability', esSpecialist);         
		createCaseForFeedbackAndAssert('Americas - USA', 'Indianapolis', 'Article Feedback', 'Foundation - Japan', esSpecialist);         
     	Test.stopTest();
     }
	//feedback cases for ES Specialist
     static testMethod void testArticleFeedbackForESSpecialist4() {
     	Test.startTest();
     	Id esSpecialist = ESDJC_AssignmentHelper.getQueueId('ES_Specialist_Amer');
		createCaseForFeedbackAndAssert('Americas - USA', 'Indianapolis', 'Article Feedback', 'CSG', esSpecialist);         
		createCaseForFeedbackAndAssert('Americas - USA', 'Indianapolis', 'Article Feedback', 'Employee Engagement', esSpecialist);                  
         createCaseForFeedbackAndAssert('Americas - USA', 'Indianapolis', 'Article Feedback', 'ES - AMER', esSpecialist);                  
     	Test.stopTest();
     }
    
	//feedback cases for ES Employee Referral - Global
     static testMethod void testArticleFeedbackForESEmpReferral() {
     	Test.startTest();
     	Id queueId = ESDJC_AssignmentHelper.getQueueId('ES_Employee_Referral_Global');
     	createCaseForFeedbackAndAssert('Americas - USA', 'Indianapolis', 'Article Feedback','Employee Referrals - Global', queueId);
     	Test.stopTest();
     }

	//feedback cases for ES Immigration - Global
     static testMethod void testArticleFeedbackForESImmigrationGlobal() {
     	Test.startTest();
     	Id queueId = ESDJC_AssignmentHelper.getQueueId('ES_Immigration_Global');
     	createCaseForFeedbackAndAssert('Americas - USA', 'Indianapolis', 'Article Feedback','Email to Case_Immigration',null,'Immigrations - Global', queueId);
     	createCaseForFeedbackAndAssert('Americas - USA', 'Indianapolis', 'Article Feedback','Email to Case_Immigration',null,'Mobility - Global', queueId);     	
     	Test.stopTest();
     }
    

	//feedback cases for Talent Dev Global
     static testMethod void testArticleFeedbackForTalentDevGlobal() {
     	Test.startTest();
     	Id queueId = ESDJC_AssignmentHelper.getQueueId('ES_Talent_Development_Global');
     	createCaseForFeedbackAndAssert('Americas - USA', 'Indianapolis', 'Article Feedback',null,'Talent Development','Talent Dev - Global', queueId);
     	createCaseForFeedbackAndAssert('Americas - USA', 'Indianapolis', 'Article Feedback',null,'Talent Development','Staff Up', queueId);     	
        createCaseForFeedbackAndAssert('Americas - USA', 'Indianapolis', 'Article Feedback',null,'Talent Development','Recruiting', queueId);      	         
     	Test.stopTest();
     }

	//feedback cases for Payroll APAC
     static testMethod void testArticleFeedbackForPayrollAPAC() {
     	Test.startTest();
     	Id queueId = ESDJC_AssignmentHelper.getQueueId('ES_Payroll_APAC');
     	createCaseForFeedbackAndAssert('APAC - All Countries', 'Mumbai', 'Article Feedback','Payroll APAC', queueId);
     	Test.stopTest();
     }
    
	//feedback cases for Payroll EMEA
     static testMethod void testArticleFeedbackForPayrollEMEA() {
     	Test.startTest();
     	Id queueId = ESDJC_AssignmentHelper.getQueueId('ES_Payroll_EMEA');
     	createCaseForFeedbackAndAssert('APAC - All Countries', 'Mumbai', 'Article Feedback','Payroll EMEA', queueId);
     	Test.stopTest();
     }

	//feedback cases for Payroll AMER
     static testMethod void testArticleFeedbackForPayrollAMER() {
     	Test.startTest();
     	Id queueId = ESDJC_AssignmentHelper.getQueueId('ES_Payroll_AMER');
     	createCaseForFeedbackAndAssert('APAC - All Countries', 'Mumbai', 'Article Feedback','Payroll AMER', queueId);
     	Test.stopTest();
     }

	//feedback cases for Payroll Japan
     static testMethod void testArticleFeedbackForPayrollJapan() {
     	Test.startTest();
     	Id queueId = ESDJC_AssignmentHelper.getQueueId('Payroll_Japan');
     	createCaseForFeedbackAndAssert('APAC - All Countries', 'Mumbai', 'Article Feedback','Payroll - Japan', queueId);
     	Test.stopTest();
     }
    
	//feedback cases for Mail Services HQ
     static testMethod void testArticleFeedbackForMailServicesHQ() {
     	Test.startTest();
     	Id queueId = ESDJC_AssignmentHelper.getQueueId('REWS_Mail_Services_HQ');
     	createCaseForFeedbackAndAssert('APAC - All Countries', 'Mumbai', 'Article Feedback','Mail Services - HQ', queueId);
     	Test.stopTest();
     }

    //feedback cases for Workplace Services - APAC
     static testMethod void testArticleFeedbackForWorkplaceServicesAPAC() {
     	Test.startTest();
     	Id queueId = ESDJC_AssignmentHelper.getQueueId('REWS_Workplace_Services_APAC');
     	createCaseForFeedbackAndAssert('APAC - All Countries', 'Mumbai', 'Article Feedback','Workplace Services - APAC', queueId);
     	Test.stopTest();
     }
    
    //feedback cases for Workplace Services - EMEA
     static testMethod void testArticleFeedbackForWorkplaceServicesEMEA() {
     	Test.startTest();
     	Id queueId = ESDJC_AssignmentHelper.getQueueId('REWS_Workplace_Services_EMEA');
     	createCaseForFeedbackAndAssert('EMEA - All Countries', 'France', 'Article Feedback','Workplace Services - EMEA', queueId);
     	Test.stopTest();
     }
    //feedback cases for Workplace Services - HQ
     static testMethod void testArticleFeedbackForWorkplaceServicesHQ() {
     	Test.startTest();
     	Id queueId = ESDJC_AssignmentHelper.getQueueId('REWS_Workplace_Services_HQ');
     	createCaseForFeedbackAndAssert('Americas - USA', 'San Francisco', 'Article Feedback','Workplace Services - HQ', queueId);
     	Test.stopTest();
     }
    
	//public static void createCaseAndAssert(String division, String workLocation, String recordType, String origin, String caseType, String articleOwner, String status, Id desiredOwnerId) {
	//Benefits Reimbursement ES Specialist - APAC queue
     static testMethod void testBenefitsReimbursementQueue() {
       Test.startTest();
       Id queueId = ESDJC_AssignmentHelper.getQueueId('ES_Specialist_APAC');     
        createCaseAndAssert('EMEA - All Countries', 'France', 'All Expense Cases', 'Employee Success - Web', 'Benefits Reimbursement',null,'Submitted', queueId);
       Test.stopTest();
     }

	//Education - Submit - Non Amer and LACA ES Specialist - APAC queue
     static testMethod void testEMEAEducationSubmitQueue() {
       Test.startTest();
       Id queueId = ESDJC_AssignmentHelper.getQueueId('ES_Specialist_APAC');     
        createCaseAndAssert('EMEA - All Countries', 'India', 'All Expense Cases', 'Employee Success - Web', 'Education Reimbursement Request',null,'Submitted', queueId);
       Test.stopTest();
     }

	//Education - Submit - Non Amer and LACA ES Specialist - APAC queue
     static testMethod void testAPACEducationSubmitQueue() {
       Test.startTest();
       Id queueId = ESDJC_AssignmentHelper.getQueueId('ES_Specialist_APAC');     
        createCaseAndAssert('APAC - All Countries', 'India', 'All Expense Cases', 'Employee Success - Web', 'Education Reimbursement Request',null,'Submitted', queueId);
       Test.stopTest();
     }
    
    public static void createCaseAndAssert(String division, String workLocation, String recordType,String origin,Id desiredOwnerId) {
		createCaseAndAssert(division, workLocation, recordType, origin, null, null, 'New', desiredOwnerId);
	}
  
	public static void createCaseAndAssert(String division, String workLocation, String recordType, String origin, String caseType, String articleOwner, String status, Id desiredOwnerId) {
		Contact con = (ESDJC_AssignmentHelper.getContacts(1,division,workLocation))[0];
		Case c = new Case();
		c.contactId= con.Id;
		c.RecordTypeId= ESDJC_AssignmentHelper.getRecordTypeId('case',recordType);
		c.origin = origin;
		c.Type = caseType;
        c.status = status;
        c.DJC_Article_Owner_Group__c = articleOwner;
		c.setOptions(ESDJC_Util.getAssignmentRulesDMLOption(null));
		insert c;
		
		System.assertEquals([select ownerId from case where Id=:c.Id].ownerId,desiredOwnerId);
	}
    public static void createCaseForFeedbackAndAssert(String division, String workLocation,String recordType, String articleOwner, Id desiredOwnerId) {
		createCaseAndAssert(division, worklocation, recordType, null, null, articleOwner,'New', desiredOwnerId);
	}
	public static void createCaseForFeedbackAndAssert(String division, String workLocation,String recordType, String origin, String caseType, String articleOwner, Id desiredOwnerId) {
		createCaseAndAssert(division, worklocation, recordType, origin, caseType, articleOwner,'New', desiredOwnerId);
	}
    
}