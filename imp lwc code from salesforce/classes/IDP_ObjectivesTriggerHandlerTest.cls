@isTest
private class IDP_ObjectivesTriggerHandlerTest {
    private static final String EMPLOYEE_NO = '826610';

    @testsetup static void createData(){
        IDP__c newIDP = new IDP__c();
        newIDP.Key_Strengths__c = 'Test Key Strengths';
        newIDP.Career_Interest__c = 'Test Place Holder';
        newIDP.Employee_Number__c = EMPLOYEE_NO;
        newIDP.QuipId__c = '877778863677';
        insert newIDP;
        
        IDP_Objective__c objective = new IDP_Objective__c();
        objective.IDP__c = newIDP.id;
        objective.IDP_Objective_Name__c = 'Objective';
        objective.QuipId__c = '877778863677';
        insert objective;
        
    }
    
    static testMethod void testIdpLastSavedDateOnObjectiveUpdate(){

        //arrange
        String query = 'SELECT Id, IDP__c, ' + String.join(IdpTriggerHandler.IDP_OBJECT_FIELDS_MAP.get(IdpTriggerHandler.IDP_OBJECT.IDP_OBJECTIVES), ', ') + ' FROM IDP_Objective__c';
        List<IDP_Objective__c> objs = Database.query(query);
        
        //act
        Test.startTest();
        objs[0].IDP_Objective_Name__c= 'Test Dummy Update';
        update objs;
        Test.stopTest();
        
        //assert
        List<IDP__c> updatedIdps = [SELECT Id, Last_Saved_Date__c FROM IDP__c WHERE Id = :objs[0].IDP__c];
        System.assertEquals(Date.valueOf(System.now()), Date.valueOf(updatedIdps[0].Last_Saved_Date__c), 'Last Saved date on IDP should have been updated to TODAY');
    }
    
    static testMethod void testIdpLastSavedDateOnObjectiveDelete(){

        //arrange
        String query = 'SELECT Id, IDP__c, ' + String.join(IdpTriggerHandler.IDP_OBJECT_FIELDS_MAP.get(IdpTriggerHandler.IDP_OBJECT.IDP_OBJECTIVES), ', ') + ' FROM IDP_Objective__c';
        List<IDP_Objective__c> objs = Database.query(query);
        
        //act
        Test.startTest();
        objs[0].IsDeleted__c = true;
        update objs;
        Test.stopTest();
        
        //assert
        List<IDP__c> updatedIdps = [SELECT Id, Last_Saved_Date__c FROM IDP__c WHERE Id = :objs[0].IDP__c];
        System.assertEquals(Date.valueOf(System.now()), Date.valueOf(updatedIdps[0].Last_Saved_Date__c), 'Last Saved date on IDP should have been updated to TODAY');
    }
}