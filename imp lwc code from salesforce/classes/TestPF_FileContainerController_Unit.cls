@isTest
private class TestPF_FileContainerController_Unit {
	 
    static testMethod void testAttachFile() {
    	Test.startTest();
	    	PerformanceReview__c perf = GeneratePerformanceReviewEnvironment.createPerformance_TestFile();
	    	System.currentPageReference().getParameters().put('id', perf.Id);
	       	FileContainerController fileCont = new FileContainerController();
	       	
	       	Attachment attach = new Attachment();
		 	attach.Name       = 'asdf';
		 	attach.Body       = blob.ValueOf('1234');
		 	fileCont.attached_file = attach;
	       	
	       	fileCont.save_file();
	       	fileCont.FileURL();
	       	fileCont.delete_file();
       Test.stopTest();	
       
    }
    
    static testMethod void testAttachFileI(){
    	Test.startTest();
	    	PerformanceReview__c perf = GeneratePerformanceReviewEnvironment.createPerformance_TestFile();
	    	Attachment attach = new Attachment();
		 	attach.Name       = 'asdf';
		 	attach.ParentId   = perf.id;
		 	attach.Body       = blob.ValueOf('1234');
		 	upsert attach;
		 	
	    	System.currentPageReference().getParameters().put('prId', perf.Id);
	    	FileContainerController fileCont = new FileContainerController();
	    	attach = new Attachment();
	    	fileCont.attached_file = attach;
	    	fileCont.save_file();
	    	fileCont.FileURL();
    	Test.stopTest();
    }
}