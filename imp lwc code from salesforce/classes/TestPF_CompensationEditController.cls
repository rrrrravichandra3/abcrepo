@isTest
private class TestPF_CompensationEditController {

   static testMethod void Test_CompenationEditController() {
		Test.startTest();
			String Id = userInfo.getUserId();
			String collectionIDs = Id + ';';
			String recordID = [Select r.Id From RecordType r Where r.Name =: 'Distribution Record Type'].Id;
			ListID__c listUserIDs = new ListID__c();
			listUserIDs.CollectionID__c = collectionIDs;
			insert listUserIDs;
			System.currentPageReference().getParameters().put('uIDs', listUserIDs.Id);
			System.currentPageReference().getParameters().put('recordID', recordID);
			CompensationEditController compEdit = new CompensationEditController();
			compEdit.getAllCompensationStatus();
			compEdit.getAllRecordCurrency();
			compEdit.getCompUsers();
			compEdit.planDetail = 'Test';
			compEdit.recordName = 'Test_' + userInfo.getUserName();
			compEdit.recordStatus = compEdit.compStatus[1];//Not Completed
			compEdit.saveAndContinue();
		
		
		Test.stopTest();
		
	}
}