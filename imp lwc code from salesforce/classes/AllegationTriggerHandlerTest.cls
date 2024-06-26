@isTest
private class AllegationTriggerHandlerTest {
	
	@isTest static void allegationManagementHirearchyTest() {

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

        allegation.Accused__c = contacts.get(1).Id;
        update allegation;
        
        allegation.Accused_Type__c = 'Employee';
        delete allegation;
	}

    @isTest static void accusedAcquiredCompanyTest(){
      Acquisition_Contacts__c acq = ESDJC_TestUtil.getAcquistionContact();
      
      Case investigationCase = ESDJC_TestUtil.getERInvestigationCase();
      
      Allegations__c allegation = ESDJC_TestUtil.getGEIAllegation();
      ER_Restricted_Case__c erRestrictedCase = ESDJC_TestUtil.getERRestrictedCase();   
      System.assertEquals('Test Acquisition Company', [Select Id,Accused_Acquired_Company_Name__c from Allegations__c where Id =:allegation.Id].Accused_Acquired_Company_Name__c);     

    }
		
}