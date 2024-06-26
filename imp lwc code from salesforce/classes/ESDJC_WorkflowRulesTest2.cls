@isTest(seeAllData=false)
public class ESDJC_WorkflowRulesTest2 {
	private static Contact amerContact = ESDJC_AssignmentHelper.getContacts(1, 'Americas - USA', 'San Francisco')[0];
	private static Contact apacContact = ESDJC_AssignmentHelper.getContacts(1, 'APAC - All Countries', 'Mumbai')[0];
	private static Contact emeaContact = ESDJC_AssignmentHelper.getContacts(1, 'EMEA - All Countries', 'London')[0];
	private static Contact jpnContact = ESDJC_AssignmentHelper.getContacts(1, 'Japan', 'Tokyo')[0];

	private static Contact amerFounContact = ESDJC_AssignmentHelper.createContactsByDeptDivWorkLoc(1, 'Americas - USA','FOUN-Foundation', 'San Francisco')[0];
	private static Contact APACFounContact = ESDJC_AssignmentHelper.createContactsByDeptDivWorkLoc(1, 'APAC - All Countries','FOUN-Foundation', 'Mumbai')[0];
	private static Contact EMEAFounContact = ESDJC_AssignmentHelper.createContactsByDeptDivWorkLoc(1, 'EMEA - All Countries','FOUN-Foundation', 'London')[0];
	private static Contact JpnFounContact = ESDJC_AssignmentHelper.createContactsByDeptDivWorkLoc(1, 'Japan','FOUN-Foundation', 'Tokyo')[0];

    private static set<string> caseTypesForFoun = new set<string>{'401K/RRSP','Benefits','Compensation','ESPP','G4G',
																	'Generic Concierge Ticket','Immigration','New Hire Setup','Payroll',
																	'Relocation & Visas','Separations','Talent Development','Travel','Expense / Amex',
																	'Employee Relations','My Team Information','My Information','ES Data Request'																	
																	};
	

	private static testmethod void testFoundationRecordtypeAMER(){
		ESDJC_TestUtil.init();	
		ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
		system.assertEquals(settings.Foundation_Dept_Names__c,'FOUN-Foundation');
		system.assertEquals(amerFounContact.department,'FOUN-Foundation');	
		Test.startTest();	
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

		case AmerOthercase = new case();	
	    AmerOthercase.Type = 'GEPS';		
		AmerOthercase.Tier__c = 'Tier 1';
		AmerOthercase.origin= 'Concierge';
		AmerOthercase.ContactId=amerFounContact.id;
		AmerOthercase.setOptions(ESDJC_Util.getAssignmentRulesDMLOption(null));
		cases.add(AmerOthercase);

		insert cases;
		
		list<case> createdcases = [ select ownerid,type,Is_Foundation__c,recordType.name from case where id in :cases];
		for(case c: createdcases){
			if(caseTypesForFoun.contains(c.type)){
				system.assertEquals(c.Is_Foundation__c,true);							
				system.assertEquals('All .org Cases - Global', c.recordType.Name,c.type);
			}
			else{
				system.assertEquals('All Case Types except ER - AMER', c.recordType.Name);
			}
		}

		
		Test.stopTest();		
	}

	private static testmethod void testFoundationRecordtypeAPAC(){
		ESDJC_TestUtil.init();	
		ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
		system.assertEquals(settings.Foundation_Dept_Names__c,'FOUN-Foundation');
		system.assertEquals(APACFounContact.department,'FOUN-Foundation');	
		Test.startTest();	
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

		case AmerOthercase = new case();	
	    AmerOthercase.Type = 'GEPS';		
		AmerOthercase.Tier__c = 'Tier 1';
		AmerOthercase.origin= 'Concierge';
		AmerOthercase.ContactId=APACFounContact.id;
		AmerOthercase.setOptions(ESDJC_Util.getAssignmentRulesDMLOption(null));		
		cases.add(AmerOthercase);

		insert cases;
		
		list<case> createdcases = [ select ownerid,type,Is_Foundation__c,recordType.name from case where id in :cases];
		for(case c: createdcases){
			if(caseTypesForFoun.contains(c.type) && !((c.type).equals('Employee Relations'))){
				system.assertEquals(c.Is_Foundation__c,true);							
				system.assertEquals('All Case Types except ER - APAC', c.recordType.Name);
			}
		}

		
		Test.stopTest();		
	}

	private static testmethod void testFoundationRecordtypeEMEA(){
		ESDJC_TestUtil.init();	
		ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
		system.assertEquals(settings.Foundation_Dept_Names__c,'FOUN-Foundation');
		system.assertEquals(EMEAFounContact.department,'FOUN-Foundation');	
		Test.startTest();	
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

		case AmerOthercase = new case();	
	    AmerOthercase.Type = 'GEPS';		
		AmerOthercase.Tier__c = 'Tier 1';
		AmerOthercase.origin= 'Concierge';
		AmerOthercase.ContactId=EMEAFounContact.id;
		AmerOthercase.setOptions(ESDJC_Util.getAssignmentRulesDMLOption(null));		
		cases.add(AmerOthercase);

		insert cases;
		
		list<case> createdcases = [ select ownerid,type,Is_Foundation__c,recordType.name from case where id in :cases];
		for(case c: createdcases){
			if(caseTypesForFoun.contains(c.type) && !((c.type).equals('Employee Relations'))){
				system.assertEquals(c.Is_Foundation__c,true);							
				system.assertEquals('All Case Types except ER - EMEA', c.recordType.Name);
			}
		}

		
		Test.stopTest();		
	}

	private static testmethod void testFoundationRecordtypeJapan(){
		ESDJC_TestUtil.init();	
		ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
		system.assertEquals(settings.Foundation_Dept_Names__c,'FOUN-Foundation');
		system.assertEquals(JpnFounContact.department,'FOUN-Foundation');	
		Test.startTest();	
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

		case AmerOthercase = new case();	
	    AmerOthercase.Type = 'GEPS';		
		AmerOthercase.Tier__c = 'Tier 1';
		AmerOthercase.origin= 'Concierge';
		AmerOthercase.ContactId=JpnFounContact.id;
		AmerOthercase.setOptions(ESDJC_Util.getAssignmentRulesDMLOption(null));
		
		cases.add(AmerOthercase);

		insert cases;
		
		list<case> createdcases = [ select ownerid,type,Is_Foundation__c,recordType.name from case where id in :cases];
		for(case c: createdcases){
			if(caseTypesForFoun.contains(c.type) && !((c.type).equals('Employee Relations'))){
				system.assertEquals(c.Is_Foundation__c,true);							
				system.assertEquals('All Case Types except ER - Japan',c.recordType.Name);
			}
		}

		
		Test.stopTest();		
	}

	private static testmethod void testUpdateAmerRecordTypes(){
		ESDJC_TestUtil.init();		
		Test.startTest();		
		//ES DJC Update AMER Record Type
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('ContactId', amerContact.id);
		nameValuePair.put('Type','GEPS');
		nameValuePair.put('Tier__c', 'Tier 1');
		nameValuePair.put('Origin','Concierge');
		Case newCase = createCase(nameValuePair);
		system.assertEquals('All Case Types except ER - AMER', newCase.recordType.Name);
		
		nameValuePair = new Map<String, String>();
		nameValuePair.put('ContactId', amerContact.id);
		nameValuePair.put('Type','ESPP');
		nameValuePair.put('Tier__c', 'Tier 1');
		nameValuePair.put('Origin','Employee Success - Web');
		newCase = createCase(nameValuePair);
		system.assertEquals('All Case Types except ER - AMER', newCase.recordType.Name);
		Test.stopTest();		
	}
	
	private static testmethod void testUpdateErgoRecordTypes(){
		ESDJC_TestUtil.init();		
		Test.startTest();		
		
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('ContactId', amerContact.id);
		nameValuePair.put('Type','GEPS');
		nameValuePair.put('Tier__c', 'Tier 1');
		nameValuePair.put('Origin','Concierge');
		Case newCase = createCase(nameValuePair);
		system.assertEquals('All Case Types except ER - AMER', newCase.recordType.Name);
		
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'DJC_Ergo_All_Ergo_cases_AMER' AND SObjectType = 'Case'];
        
		nameValuePair = new Map<String, String>();
		nameValuePair.put('RecordTypeId', rt.Id);
		newCase = updateCase(newCase, nameValuePair);
		Test.stopTest();
		system.assertEquals('DJC_Ergo_All_Ergo_cases_AMER', newCase.recordType.DeveloperName);
	}
    
	private static testmethod void testUpdateAPACRecordType(){
		ESDJC_TestUtil.init();
		Test.startTest();		
		//ES DJC Update APAC Record Type
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('ContactId', apacContact.id);
		nameValuePair.put('Type','GEPS');
		nameValuePair.put('Origin','Concierge');
		Case newCase = createCase(nameValuePair);
		system.assertEquals('All Case Types except ER - APAC', newCase.recordType.Name);		
		Test.stopTest();					
	}
	
	private static testmethod void testUpdateAPACRecordType2(){
		ESDJC_TestUtil.init();
		Test.startTest();		
		//ES DJC Update APAC Record Type
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('ContactId', apacContact.id);
		nameValuePair.put('Type','ESPP');
		nameValuePair.put('Origin','Employee Success - Web');
		Case newCase = createCase(nameValuePair);
		system.assertEquals('All Case Types except ER - APAC', newCase.recordType.Name);		
		Test.stopTest();					
	}
	
	
	private static testmethod void testUpdateCasePriorityToHigh(){
		ESDJC_TestUtil.init();
		Test.startTest();
		//ES DJC Update Case Priority to High++++
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('ContactId', apacContact.id);
		nameValuePair.put('Type','My Team Information');
		nameValuePair.put('Origin','Phone');
		nameValuePair.put('ES_DJC_Sub_Topic__c','Termination Future Date');		
		Case newCase = createCase(nameValuePair);
		system.assertEquals('High', newCase.Priority);
		
		nameValuePair = new Map<String, String>();
		nameValuePair.put('ContactId', amerContact.id);
		nameValuePair.put('Type','My Team Information');
		nameValuePair.put('Origin','Employee Success - Web');
		nameValuePair.put('ES_DJC_Sub_Topic__c','Termination Urgent');
		newCase = createCase(nameValuePair);
		system.assertEquals('High', newCase.Priority);
		
		nameValuePair = new Map<String, String>();
		nameValuePair.put('ContactId', amerContact.id);
		nameValuePair.put('Type','Talentforce');
		nameValuePair.put('ES_DJC_Topic__c','Offers');
		nameValuePair.put('Origin','Phone');
		newCase = createCase(nameValuePair);
		system.assertEquals('High', newCase.Priority);
		Test.stopTest();		
	}
	
	private static testmethod void testUpdateCasePriorityToLow(){
		ESDJC_TestUtil.init();
		Test.startTest();
		//ES DJC Update Case Priority to Low
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('ContactId', amerContact.id);
		nameValuePair.put('Type','Leave of Absence');
		nameValuePair.put('Origin','Phone');				
		Case newCase = createCase(nameValuePair);
		system.assertEquals('Low', newCase.Priority);
		
		
		nameValuePair = new Map<String, String>();
		nameValuePair.put('ContactId', amerContact.id);
		nameValuePair.put('Type','Talentforce');
		nameValuePair.put('ES_DJC_Topic__c','NotOffer');
		nameValuePair.put('Origin','Employee Success - Web');
		newCase = createCase(nameValuePair);
		system.assertEquals('Low', newCase.Priority);
		
		nameValuePair = new Map<String, String>();
		nameValuePair.put('ContactId', amerContact.id);
		nameValuePair.put('Type','My Team Information');
		nameValuePair.put('ES_DJC_Sub_Topic__c','NotTermination');
		nameValuePair.put('Origin','Employee Success - Web');
		newCase = createCase(nameValuePair);
		system.assertEquals('Low', newCase.Priority);
		Test.stopTest();
	}
	
	private static testmethod void updateCasePriorityToMedium(){
		ESDJC_TestUtil.init();
		Test.startTest();
		//ES DJC Update Case Priority to Medium
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('ContactId', amerContact.id);
		nameValuePair.put('Type','Employee Relations');
		nameValuePair.put('Origin','Concierge');				
		Case newCase = createCase(nameValuePair);
		system.assertEquals('Medium', newCase.Priority);
		
		nameValuePair = new Map<String, String>();
		nameValuePair.put('ContactId', amerContact.id);
		nameValuePair.put('Type','Relocation & Visas');
		nameValuePair.put('Origin','Employee Success - Web');
		newCase = createCase(nameValuePair);
		system.assertEquals('Medium', newCase.Priority);

		nameValuePair = new Map<String, String>();
		nameValuePair.put('ContactId', amerContact.id);
		nameValuePair.put('Type','Separations');
		nameValuePair.put('Origin','Concierge');
		newCase = createCase(nameValuePair);
		system.assertEquals('Medium', newCase.Priority);		
		Test.stopTest();		
	}
	
	private static testmethod void testUpdateCaseReopen(){
		ESDJC_TestUtil.init();
		Test.startTest();
		//ES DJC Update Case Reopen Date
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('ContactId', amerContact.id);
		nameValuePair.put('Type','Employee Relations');
		nameValuePair.put('ES_DJC_Topic__c','test'); 
		nameValuePair.put('ES_DJC_Sub_Topic__c','test');
		nameValuePair.put('Origin','Concierge');
		nameValuePair.put('Status','New');
		Case newCase = createCase(nameValuePair);
		nameValuePair.put('Status','Closed');
		nameValuePair.put('PII__c','No'); 
		newCase = updateCase(newCase, nameValuePair);
		nameValuePair.put('Status','Re-Opened');
		newCase = updateCase(newCase, nameValuePair);
		system.assertNotEquals(null,newCase.ES_DJC_Case_Re_open_Date__c);
		Test.stopTest();
	}
	
    private static testmethod void testExpenseERAAccuracy(){
		ESDJC_TestUtil.init();
		Test.startTest();
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('ContactId', amerContact.id);
		nameValuePair.put('Origin','E2C_Accuracy');
		Case newCase = createCase(nameValuePair);
		system.assertEquals('Expense / Amex', newCase.Type);
		Test.stopTest();		
	}
	
    private static testmethod void testExpenseMgmemt(){
		ESDJC_TestUtil.init();
		Test.startTest();
		//EMEA Expense mgmt
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('ContactId', amerContact.id);
		nameValuePair.put('Origin','Email to Case_Expense Management');
		Case newCase = createCase(nameValuePair);
		system.assertEquals('Expense / Amex', newCase.Type);
		Test.stopTest();		
	}
	
    private static testmethod void testExpenseEMEA(){
		ESDJC_TestUtil.init();
		Test.startTest();
		//Expense EMEA trigger logic
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('ContactId', emeaContact.id);
		nameValuePair.put('Origin','Email to Case_Expense EMEA Corp Card');
		Case newCase = createCase(nameValuePair);
		system.assertEquals('Expense / Amex', newCase.Type);
        system.assertEquals('Amex', newCase.ES_DJC_Topic__c);
        system.assertEquals('Corporate Card Applications', newCase.ES_DJC_Sub_Topic__c);
		Test.stopTest();
	}

	private static testmethod void testExpenseNotice(){
		ESDJC_TestUtil.init();
		Test.startTest();
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('ContactId', emeaContact.id);
		nameValuePair.put('Origin','Email to Case_Expense Notice Claims');
		Case newCase = createCase(nameValuePair);
		system.assertEquals('Expense / Amex', newCase.Type);
		Test.stopTest();
	}
	
	private static testmethod void testEmailLOA(){
		ESDJC_TestUtil.init();
		Test.startTest();
		//ES DJC Update Case Type for Email - LOA
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('Origin','Email to Case_LOA');
		nameValuePair.put('Type','Benefits');
		Case newCase = createCase(nameValuePair);
		system.assertEquals('Benefits', newCase.Type);
		Test.stopTest();		
	}
	
	private static testmethod void testMyInfoJapan(){
		ESDJC_TestUtil.init();
		Test.startTest();
		//ES DJC Update Case Type for Email - My Information - Japan	
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('Origin','Email to Case_Japan');
		Case newCase = createCase(nameValuePair);
		system.assertEquals('My Information', newCase.Type);
		Test.stopTest();		
	}
	
	private static testmethod void testPayroll1(){
		ESDJC_TestUtil.init();
		Test.startTest();
		//ES DJC Update Case Type for Email - Payroll	
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('Origin','Email to Case_Payroll APAC');
		nameValuePair.put('Type','Payroll');
		Case newCase = createCase(nameValuePair);
		system.assertEquals('Payroll', newCase.Type);
		
		nameValuePair.put('Origin','Email to Case_Payroll AMER');
		newCase = createCase(nameValuePair);
		system.assertEquals('Payroll', newCase.Type);		
		Test.stopTest();
				
	}
	private static testmethod void testPayroll2(){
		ESDJC_TestUtil.init();
		Test.startTest();
		//ES DJC Update Case Type for Email - Payroll			
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('Origin','Email to Case_Payroll EMEA');
		nameValuePair.put('Type','Payroll');
		Case newCase = createCase(nameValuePair);
		system.assertEquals('Payroll', newCase.Type);
		
		nameValuePair.put('Origin','Email to Case_Payroll Japan');
		newCase = createCase(nameValuePair);
		system.assertEquals('Payroll', newCase.Type);		
		Test.stopTest();				
	}
	
	
	private static testmethod void testEmailPreHireTerm(){
		ESDJC_TestUtil.init();
		Test.startTest();
		//ES DJC Update Case Type for Email - Pre-Hire/Term	
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('Origin','Email to Case_AMER');
		Case newCase = createCase(nameValuePair);
		system.assertEquals('Pre-Hire / Term', newCase.Type);

		nameValuePair.put('Origin','Email to Case_APAC');
		newCase = createCase(nameValuePair);
		system.assertEquals('Pre-Hire / Term', newCase.Type);

		nameValuePair.put('Origin','Email to Case_EMEA');
		newCase = createCase(nameValuePair);
		system.assertEquals('Pre-Hire / Term', newCase.Type);
		Test.stopTest();
	}
	

	private static testmethod void testUpdateEmeaERRecordType(){
		ESDJC_TestUtil.init();
		Test.startTest();
		//ES DJC Update EMEA ER Record Type
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('ContactId', emeaContact.id);
		nameValuePair.put('Type','Employee Relations');
		nameValuePair.put('Tier__c','Tier 3');
		nameValuePair.put('Origin','Concierge');				
		Case newCase = createCase(nameValuePair);
		system.assertEquals('Employee Relations Case Type - EMEA', newCase.RecordType.Name);
		system.assertEquals('Tier 1', newCase.Tier__c);
		Test.stopTest();		
	}
	
	private static testmethod void testUpdateEMEARecordType(){
		ESDJC_TestUtil.init();
		Test.startTest();
		//ES DJC Update EMEA Record Type
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('ContactId', emeaContact.id);
		nameValuePair.put('Type','ESPP');
		nameValuePair.put('Origin','Concierge');				
		Case newCase = createCase(nameValuePair);
		system.assertEquals('All Case Types except ER - EMEA', newCase.RecordType.Name);
		Test.stopTest();
	}
	
	private static testmethod void testUpdateJapanERRecordType(){
		ESDJC_TestUtil.init();
		Test.startTest();
		//ES DJC Update JAPAN ER Record Type
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('ContactId', jpnContact.id);
		nameValuePair.put('Type','Employee Relations');
		nameValuePair.put('Tier__c','Tier 1');
		nameValuePair.put('Origin','Concierge');				
		Case newCase = createCase(nameValuePair);
		system.assertEquals('Employee Relations Case Type - Japan', newCase.RecordType.Name);
		Test.stopTest();		
	}
	
	private static testmethod void testUpdateJapanRecordType(){
		ESDJC_TestUtil.init();
		Test.startTest();
		//ES DJC Update JAPAN Record Type
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('ContactId', jpnContact.id);
		nameValuePair.put('Type','ESPP');
		nameValuePair.put('Origin','Concierge');				
		Case newCase = createCase(nameValuePair);
		system.assertEquals('All Case Types except ER - Japan', newCase.RecordType.Name);
		Test.stopTest();
	}
	
	private static testmethod void testUpdateTierForEmaiToCase1(){
		ESDJC_TestUtil.init();
		Test.startTest();
		//ES DJC Update Tier for Email to Case
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('Origin','Email to Case_Employee Relations');				
		Case newCase = createCase(nameValuePair);
		system.assertEquals('Tier 1', newCase.Tier__c);
		
		nameValuePair.put('Origin','Email to Case_LOA');				
		newCase = createCase(nameValuePair);
		system.assertEquals('Tier 1', newCase.Tier__c);
		Test.stopTest();
	} 
	
	private static testmethod void testUpdateTierForEmaiToCase2(){
		ESDJC_TestUtil.init();
		Test.startTest();
		//ES DJC Update Tier for Email to Case
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('Origin','Email to Case_Payroll AMER');				
		Case newCase = createCase(nameValuePair);
		system.assertEquals('Tier 1', newCase.Tier__c);
		
		nameValuePair.put('Origin','Email to Case_Payroll APAC');				
		newCase = createCase(nameValuePair);
		system.assertEquals('Tier 1', newCase.Tier__c);
		Test.stopTest();
	} 
	 
	private static testmethod void testREWSUpdateCaseRecordTypeAmerHQ(){
		ESDJC_TestUtil.init();
		Test.startTest();
		//REWS Update Case Record Type Amer HQ
		Contact amerREWSContact = ESDJC_AssignmentHelper.getContacts(1, 'Americas - USA', 'San Francisco')[0];	
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('Origin','Concierge');
		nameValuePair.put('type','Building Maintenance');				
		nameValuePair.put('ContactId', amerREWSContact.id);		
		Case newCase = createCase(nameValuePair);
		system.assertEquals('All REWS cases - AMER HQ', newCase.RecordType.Name);
		Test.stopTest();		
	}
	
	private static testmethod void testREWSUpdateCaseRecordTypeAmerHQ2(){
		ESDJC_TestUtil.init();
		Test.startTest();
		//REWS Update Case Record Type Amer HQ		
		Contact amerREWSContact = ESDJC_AssignmentHelper.getContacts(1, 'Americas - USA', null)[0];	
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('Origin','Concierge');
		nameValuePair.put('type','Event & Meeting Setup');				
		nameValuePair.put('ContactId', amerREWSContact.id);		
		Case newCase = createCase(nameValuePair);
		system.assertEquals('All REWS cases - AMER HQ', newCase.RecordType.Name);
		Test.stopTest();		
	}
	
	private static testmethod void testREWSUpdateCaseRecordTypeAmerNonHQ(){
		ESDJC_TestUtil.init();
		Test.startTest();
		//REWS Update Case Record Type Amer NonHQ
		Contact amerREWSContact = ESDJC_AssignmentHelper.getContacts(1, 'Americas - USA', 'New York')[0];	
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('Origin','Concierge');
		nameValuePair.put('type','Building Maintenance');				
		nameValuePair.put('ContactId', amerREWSContact.id);		
		Case newCase = createCase(nameValuePair);
		system.assertEquals('All REWS cases - AMER - NonHQ', newCase.RecordType.Name);
		Test.stopTest();		
	}  
	  
	private static testmethod void testFeedbackWF(){
		ESDJC_TestUtil.init();
		Test.startTest();
		Contact amerREWSContact = ESDJC_AssignmentHelper.getContacts(1, 'Americas - USA', 'New York')[0];	
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('Origin','Concierge');
		nameValuePair.put('type','Article Feedback');				
		nameValuePair.put('ContactId', amerREWSContact.id);		
		Case newCase = createCase(nameValuePair);
		system.assertEquals('Article Feedback', newCase.RecordType.Name);
		Test.stopTest();		
	}

    
	private static case createCase(Map<String,String> nameValPair){
		Case c = new Case();
		if ((nameValPair!=null)&&(nameValPair.size()>0)){
			for (String key: nameValPair.keySet()){
				String value= nameValPair.get(key);
				c.put(key, value);
			}
			insert c;
			Case newCase = [select owner.name, recordtype.Name, priority,ES_DJC_Case_Re_open_Date__c,type, Tier__c, ES_DJC_Topic__c, ES_DJC_Sub_Topic__c from case where id = :c.id];
			return newCase;					
		}
		return null;		
	}
	
	private static case updateCase(Case c, Map<String,String> nameValPair){
		if (c==null || nameValPair == null || nameValPair.size()==0){
			return null;
		}						
		for (String key: nameValPair.keySet()){
			String value= nameValPair.get(key);
			c.put(key, value);
		}
		update c;
		Case newCase = [select owner.name, recordtype.Name, recordtype.DeveloperName, priority,ES_DJC_Case_Re_open_Date__c, type, Tier__c from case where id = :c.id];
		return newCase;									
	}
	
}