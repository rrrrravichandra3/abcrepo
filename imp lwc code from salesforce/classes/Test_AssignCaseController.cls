/*
* @Author : Kshitiz Srivastava
* Test for class AssignCaseController.cls
*/
@isTest
public class Test_AssignCaseController {

    @testSetup static void setup(){
        RecordType contactEmployeeRecType = [SELECT Id From RecordType WHERE sObjectType='Contact' AND DeveloperName = 'Employee' AND isActive=true limit 1];
        RecordType caseExceptAmerRecType = [Select Id from RecordType WHERE sObjectType='Case' AND DeveloperName = 'ES_DJC_All_Case_Types_except_ER_AMER' AND isActive=true limit 1];

        // create test account
        Account acc = new Account(Name = 'TestReassignCase Test Account', Phone = '(312)111 2222', BillingStreet = 'Test Street', BillingCity = 'Chicago', BillingPostalCode = '60605', BillingState = 'IL');
        insert acc;
        acc = [SELECT Id, Name FROM Account WHERE Name = 'TestReassignCase Test Account' limit 1];
                
        //create contact
        Contact cont = new Contact(RecordTypeId = contactEmployeeRecType.Id, LastName = 'TestReassignCase LastName', AccountId = acc.Id);
        insert cont;
        cont = [SELECT Id, Name FROM Contact WHERE LastName = 'TestReassignCase LastName' limit 1];

        //create a case
        Case cse = new Case(Account = acc, Contact = cont, Subject = 'TestReassignCase Test Subject', Description = 'Description', Tier__c = 'Tier 1', RecordTypeId = caseExceptAmerRecType.Id);
        insert cse;
    }


	static testMethod void testReassignCase()
	{
		Case testCase = [SELECT Id FROM Case WHERE Tier__c = 'Tier 1' AND Subject = 'TestReassignCase Test Subject' limit 1];
        
        Test.startTest();
            AssignCaseController.reassignCase(testCase.Id);
        Test.stopTest();
        
        Case cseAfterAssignment = [SELECT OwnerId FROM Case WHERE Id= :testCase.Id limit 1];

        Group g = [select Id from Group where  Type = 'Queue' AND DeveloperNAME = 'ES_Specialist_Amer' limit 1];
        
        System.assertEquals(g.Id, cseAfterAssignment.OwnerId);


    	
	}
}