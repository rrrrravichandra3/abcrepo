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
private class Test_AddCandidateToShortListCTL {

    static testMethod void myUnitTest() {
        RecordType accountRecordType = [select id,name from RecordType where SObjectType='Account' and name='Candidate'];
		Account account =[Select Id, name from Account Where recordTypeId =: accountRecordType.Id and name='Candidates'];
		RecordType contactRecordType = [select id,name from RecordType where SObjectType='Contact' and name='Candidate'];
				
		
		Contact candidate = new Contact();
		candidate.RecordTypeId=contactRecordType.Id;
		candidate.AccountId = account.Id;
		candidate.FirstName = 'Test FS';
		candidate.lastName='Test Ls';
		candidate.email='a@b.com';
		candidate.Phone='1111111111';
		insert candidate;
		
		ts2__s_UserList__c shortList = new ts2__s_UserList__c();
		shortList.Name='Test';
		shortList.ts2__description__c ='Test 1234';
		insert shortList;
		
		Apexpages.currentPage().getParameters().put('ID', candidate.Id);
		AddCandidateToShortListCTL controller = new AddCandidateToShortListCTL(new ApexPages.StandardController(candidate));
		List<SelectOption> selectionOptions =controller.getShortListSelectionDetails();
		System.assert(selectionOptions != null && selectionOptions.size() > 0);
		controller.shortListId = shortList.id;
		controller.saveShortList();
		System.assert(Apexpages.hasMessages());
		List<ts2__s_UserListLink__c> userShortLinkList =[Select id,ts2__r_user_list__c,ts2__r_contact__c from ts2__s_UserListLink__c Where ts2__r_user_list__c =:shortList.Id and ts2__r_contact__c =: candidate.Id];
		System.assert(userShortLinkList != null && userShortLinkList.size() > 0);
		
		controller.saveShortList();
    }
    
    static testMethod void myUnitTest1() {
        delete [select id,name from ts2__s_UserList__c ];		
		
		AddCandidateToShortListCTL controller = new AddCandidateToShortListCTL(new ApexPages.StandardController(new Contact()));
		controller.hasShortLists();
		controller.shortListId = null;
		controller.saveShortList();
		System.debug('Apexpages.hasMessages()------------------>'+ Apexpages.hasMessages());
		System.assert(Apexpages.hasMessages());
    }    
}