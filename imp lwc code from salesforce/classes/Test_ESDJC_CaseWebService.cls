@isTest
public with sharing class Test_ESDJC_CaseWebService {

	static testMethod void testReassignCase()
	{
		List<RecordType> rtypes = [SELECT Name, Id From RecordType WHERE sObjectType='Contact' AND Name = 'Employee' AND isActive=true];
        
        // create test account
        Account acc = new Account(Name = 'TestReassignCase Test Account', Phone = '(312)111 2222', 
                                    BillingStreet = 'Test Street', BillingCity = 'Chicago', 
                                    BillingPostalCode = '60605', BillingState = 'IL');
        
        // insert account
        insert acc;
                
        // refesh account
        acc = [SELECT Id, Name FROM Account WHERE Name = 'TestReassignCase Test Account'];
        
        System.assert(acc != null);
        
        //create contact
        Contact cont = new Contact(RecordTypeId = rTypes[0].Id, LastName = 'TestReassignCase LastName',
                                    AccountId = acc.Id);
        
        insert cont;
        
        //refresh contact
        cont = [SELECT Id, Name FROM Contact WHERE LastName = 'TestReassignCase LastName'];
        System.assert(cont != null);
        
        //create a list of cases
        List<Case> cases = new List<Case>();
        Case cse = null;
        for (integer i = 0; i < 5; i++)
        {
            cse = new Case(Account = acc, Contact = cont, Subject = 'TestReassignCase Test Subject ' + i, 
                            Description = 'Description ' + i, Tier__c = 'Tier 1');
            cases.add(cse);
        }
        
        insert cases;
        
        //refresh cases
        cases = [SELECT Id, Tier__c FROM Case WHERE Tier__c = 'Tier 1' AND Subject LIKE 'TestReassignCase Test Subject%'];
        
        //reassign case
        for (integer i = 0; i < cases.size(); i++)
        {
            ESDJC_CaseWebService.reassignCase(cases[i].Id);
        }
        
        //refresh cases and verify escalation user set.
        cases = [SELECT Id, Tier__c, ES_DJC_Case_Escalated_By__c FROM Case WHERE Subject LIKE 'TestReassignCase Test Subject%'];
    	for (Case c: cases)
    	{
    		//System.assert(c.ES_DJC_Case_Escalated_By__c != null);
    	}
    	
	}

}