@isTest
public class Accused_ContactInvocableControllerTest {
	 @isTest static void ContactInvocableControllerTest() {

    List<Contact> contacts = ESDJC_TestUtil.getContactManagementHirearchy();
    Integer j=1;

    for(Integer i=0;i<contacts.size();i++){
            
            contacts.get(i).ReportsToId = contacts.get(j).Id;
            j++;
            
            if(j == contacts.size())
            break;

        }

        update contacts;
		
        Case investigationCase = ESDJC_TestUtil.getERInvestigationCase();
    ER_Restricted_Case__c erRestrictedCase = ESDJC_TestUtil.getERRestrictedCase(); 
        Allegations__c allegation = new Allegations__c();
    Id RecTypeId = [SELECT Id FROM RecordType WHERE SobjectType ='Allegations__c' 
                        and DeveloperName='ER_Allegations' LIMIT 1].Id;

        allegation.RecordTypeId = RecTypeId;
        allegation.Case__c = investigationCase.Id;
        allegation.Accused__c = contacts.get(0).Id;
        insert allegation;
		
		contacts[0].email ='test@test1.com';
		   update contacts;      
}
}