@isTest
private class TestPF_CSVDownloadTemplateController {

    static testMethod void Test_CSVDownloadTemplateController() {
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
			String filePath	 		= '\\fakePath';
			String fileExtension 	= '.pdf';
			System.currentPageReference().getParameters().put('compIDs', listCompensationIDs.Id);
			System.currentPageReference().getParameters().put('path', filePath);
			System.currentPageReference().getParameters().put('ext', fileExtension);		
			CSVDownloadTemplateController csvDownload = new CSVDownloadTemplateController();
			csvDownload.getAttachments();
		Test.stopTest();
	}
}