@isTest
private class Test_DJC_Wellness_MyCases_View {

    private static testMethod void testMyReimbursementCases() {

        ESDJC_TestUtil.createSSOIdSetting();
        User testUser = ESDJC_TestUtil.getPortalUser('India','EMEA');
        
        user currentUser = [select id from user where id =:UserInfo.getUserId() ];
        system.runAs(currentUser){
            ESDJC_TestUtil.assignPermission( testUser.id,'ES_DJC_Employee_EMEA');
        }

        System.runAs(testUser) {
            
            RecordType rtAllExpenseCases = [SELECT Id FROM RecordType WHERE DeveloperName = 'All_Expense_Cases'];
            RecordType rtOther = [SELECT Id FROM RecordType WHERE DeveloperName = 'ES_DJC_All_Case_Types_except_ER_EMEA'];
            
            List<Case> caseList = new List<Case>();

            caseList.add(new Case(Status = 'New', RecordTypeId = rtAllExpenseCases.Id, ContactId = testUser.ContactId));
            caseList.add(new Case(Status = 'Rejected', RecordTypeId = rtAllExpenseCases.Id, ContactId = testUser.ContactId));
            caseList.add(new Case(Status = 'Closed', RecordTypeId = rtAllExpenseCases.Id, ContactId = testUser.ContactId));
            caseList.add(new Case(Status = 'Closed - Duplicate', RecordTypeId = rtAllExpenseCases.Id, ContactId = testUser.ContactId));

            caseList.add(new Case(Status = 'New', RecordTypeId = rtOther.Id, ContactId = testUser.ContactId));
            caseList.add(new Case(Status = 'Closed', RecordTypeId = rtOther.Id, ContactId = testUser.ContactId));

            insert caseList;
            
            DJC_Wellness_MyCases_View_Controller controller = new DJC_Wellness_MyCases_View_Controller();
            controller.selectedView = 0;
            controller.searchCases();
            
            List<Case> cases = controller.searchResults;
            System.assertEquals(1, cases.size());
            
            controller.selectedView = 1;
            controller.searchCases();
            
            cases = controller.searchResults;
            System.assertEquals(3, cases.size());
            
            controller.selectedView = 2;
            controller.searchCases();
            
            cases = controller.searchResults;
            System.assertEquals(4, cases.size());
        }
    }
}