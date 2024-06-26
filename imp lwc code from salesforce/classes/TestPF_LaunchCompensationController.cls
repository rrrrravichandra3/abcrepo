@isTest
private class TestPF_LaunchCompensationController {

    static testMethod void Test_LaunchCompensationController() {
     	Test.startTest();
     		String Id = userInfo.getUserId();
			String collectionIDs = Id + ';';
			ListID__c listUserIDs = new ListID__c();
			listUserIDs.CollectionID__c = collectionIDs;
			insert listUserIDs;
			System.currentPageReference().getParameters().put('uIDs', listUserIDs.Id);
			LaunchCompensationController launchComp = new LaunchCompensationController();
			launchComp.getAllRecordTypes();
			launchComp.getCompRecordTypes();
			String recordID = [Select r.Id From RecordType r Where r.Name =: 'Distribution Record Type'].Id;
			launchComp.currentRecordType = recordID;
			launchComp.saveAndContinue();
			launchComp.currentUser 	= userInfo.getUserId();
			launchComp.usr 			= userInfo.getUserId();
			
	   	Test.stopTest();
     }  
}