@isTest
private class Test_ESDJC_MyCasesController {
    
    static testMethod void testCaseHome() {
        ESDJC_TestUtil.createSSOIdSetting();
        User u = ESDJC_TestUtil.getPortalUser('India','EMEA');
        
        user currentUser = [select id from user where id =:UserInfo.getUserId() ];
        system.runAs(currentUser){
            ESDJC_TestUtil.assignPermission( u.id,'ES_DJC_Employee_EMEA');
        }
        
        List<Case> caseList = new List<Case>() ;
        System.runAs(u) {
            PageReference pageRef = Page.ESDJC_CasesHomePage;
            Test.setCurrentPageReference(pageRef);
            ESDJC_MyCasesController con1 = new ESDJC_MyCasesController();
            
            system.assertEquals(3,con1.getViews().size());
            con1.getCases();
            con1.searchCases();
            system.assertEquals(false,con1.getHasPrevious());
            system.assertEquals(false,con1.getHasNext());
            con1.previous();
            con1.first();
            con1.next();
            con1.last();
            con1.previous();
            con1.first();
            boolean b = con1.renderTable;
            for(integer i = 0;i<10;i++){
                if(i<5)
                    caseList.add(new Case(Status = 'New'));
                else 
                    caseList.add(new Case(Status = 'Closed - Duplicate'));
            }   
            caseList.add(new Case(Status = 'Not a Case'));
            insert caseList;
            
            //commented some lines due to Too many SOQL queries: on ESDJC_MyCasesController.
            ESDJC_MyCasesController con = new ESDJC_MyCasesController();
            con.getViews();
            con.getCases();
            con.searchCases();
            system.assertEquals(5,con.searchResults.size());
            con.getHasPrevious();
            con.previous();
            con.next();
            con.previous();
            con.getHasNext();
            con.getHasNext();
            b = con1.renderTable;
            con.selectedView = 'closed';
            con.searchCases();
            system.assertEquals(5,con.searchResults.size());
            con.selectedView = 'all';
            con.searchCases();
            system.assertEquals(10,con.searchResults.size()); 
            list<Case> cList = con.searchResults; 
            
            ESDJC_MyCasesController con3 = new ESDJC_MyCasesController();
            con3.setController = null;
            ApexPages.StandardSetController  cont= con3.setController;
            con3.getHasPrevious();
            con3.renderTable = null;
            boolean c = con3.renderTable;
            cList = con3.searchResults;
        }   
    }    
}