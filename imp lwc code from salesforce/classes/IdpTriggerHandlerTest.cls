@isTest
private class IdpTriggerHandlerTest {
    private static final String EMPLOYEE_NO = '826610';
    private static final String QUERY_PREFIX = 'SELECT Id, Last_Saved_Date__c, ';
    private static final String QUERY_OBJECT_IDP = ' FROM IDP__c';

    @testsetup static void createData(){
        IDP__c newIDP = new IDP__c();
        newIDP.Key_Strengths__c = 'Test Key Strengths';
        newIDP.Career_Interest__c = 'Test Place Holder';
        newIDP.Employee_Number__c = EMPLOYEE_NO;
        newIDP.QuipId__c = '877778863677';
        insert newIDP;
    }
    
    static testMethod void testIdpLastSavedDate(){

        //arrange
        String query = QUERY_PREFIX + String.join(IdpTriggerHandler.IDP_OBJECT_FIELDS_MAP.get(IdpTriggerHandler.IDP_OBJECT.IDP), ', ') + QUERY_OBJECT_IDP;
        List<IDP__c> idps = Database.query(query);
        
        //act
        Test.startTest();
        idps[0].Key_Strengths__c = 'Test Dummy Update';
        Update idps;
        Test.stopTest();
        
        //assert
        List<IDP__c> updatedIdps = [SELECT Id, Last_Saved_Date__c FROM IDP__c WHERE Id = :idps[0].Id];
        System.assertEquals(Date.valueOf(System.now()), Date.valueOf(updatedIdps[0].Last_Saved_Date__c), 'Last Saved date on IDP should have been updated to TODAY');
    }
    
    static testMethod void testQueryIdp(){

        //arrange
        String query = QUERY_PREFIX + String.join(IdpTriggerHandler.IDP_OBJECT_FIELDS_MAP.get(IdpTriggerHandler.IDP_OBJECT.IDP), ', ') + QUERY_OBJECT_IDP;
        List<IDP__c> idps = Database.query(query);
        Set<Id> idpIds = new Set<Id>{idps[0].Id};
        
        //act
        Test.startTest();
            List<IDP__c> quaeriedIdps = IdpTriggerHandler.queryIdp(idpIds);
        Test.stopTest();
        
        //assert
        System.assertNotEquals(0, quaeriedIdps.size(), 'Idps not queried unexpectedly');
    }
    
    static testMethod void testUpdateIdp(){

        //arrange
        String query = QUERY_PREFIX + String.join(IdpTriggerHandler.IDP_OBJECT_FIELDS_MAP.get(IdpTriggerHandler.IDP_OBJECT.IDP), ', ') + QUERY_OBJECT_IDP;
        List<IDP__c> idps = Database.query(query);
        
        //act
        Test.startTest();
            IdpTriggerHandler.updateLastSavedOnIdp(idps );
        Test.stopTest();
        
        //assert
        List<IDP__c> updatedIdps = [SELECT Id, Last_Saved_Date__c FROM IDP__c WHERE Id = :idps[0].Id];
        System.assertEquals(Date.valueOf(System.now()), Date.valueOf(updatedIdps[0].Last_Saved_Date__c), 'Last Saved date on IDP should have been updated to TODAY');
    }
    
       
}