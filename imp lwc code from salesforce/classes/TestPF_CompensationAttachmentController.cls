@isTest
private class TestPF_CompensationAttachmentController {

    static testMethod void Test_CompenationAttachmentController() {
		Test.startTest();
			String recordID = [Select r.Id From RecordType r Where r.Name =: 'Distribution Record Type'].Id;
			ListID__c listCompensationIDs = new ListID__c();
			Compensation__c comp = new Compensation__c();
			comp.CurrencyIsoCode = 'USD';
			comp.OwnerId = userInfo.getUserId();
			comp.Plan_Details__c = 'Test';
			comp.RecordTypeId = recordID;
			insert comp;
			String collection = comp.Id + ';';
			listCompensationIDs.CollectionID__c = collection;
			insert listCompensationIDs;
			System.currentPageReference().getParameters().put('compIDs', listCompensationIDs.Id);
			CompensationAttachmentController compAttach = new CompensationAttachmentController();
			compAttach.getAllFileExtension();
			compAttach.downloadTemplate();
			compAttach.filePath = '\\fakepath';
			compAttach.fileExtension = '.pdf';
			compAttach.downloadTemplate();
		Test.stopTest();
	}
}