@isTest
private class TestESDJC_CaseUpdate {

	//when no records are selected, system should throw an appropriate error message.. 
    private static testMethod void testNoneSelected(){
        ApexPages.StandardSetController stdContr = new ApexPages.StandardSetController(new List<Case>());
        ESDJC_CaseUpdate contrlr = new ESDJC_CaseUpdate(stdContr);
        contrlr.validateOnLoad();
        PageReference pageRef = Page.ESDJC_UpdateCaseStatusPage; 
        Test.setCurrentPage(pageRef);
         ApexPages.currentPage().getParameters().put('retURL', '/500');//take to list view of case object.. 
        //select the status to approved.. 
        Test.startTest();
        boolean selectAtleastOneRecord = false;
        for(ApexPages.Message msg : ApexPages.getMessages()){
            if(msg.getDetail().contains('Please select at least one record.')){
                selectAtleastOneRecord = true;
            }
        }
        System.assert(selectAtleastOneRecord);
        Test.stopTest();
    }

    //TODO: write unit test to test cancel button
}