@isTest
private class IDP_ActionsTriggerHandlerTest {
    private static final String EMPLOYEE_NO = '826610';

    @testsetup static void createData(){
        IDP__c newIDP = new IDP__c();
        newIDP.Key_Strengths__c = 'Test Key Strengths';
        newIDP.Career_Interest__c = 'Test Place Holder';
        newIDP.Employee_Number__c = EMPLOYEE_NO;
        newIDP.QuipId__c = '87777886367';
        insert newIDP;
        
        IDP_Objective__c objective = new IDP_Objective__c();
        objective.IDP__c = newIDP.id;
        objective.IDP_Objective_Name__c = 'Objective';
        objective.QuipId__c = '877778863677';
        insert objective;
        
        IDP_Action__c actions = new IDP_Action__c();
        actions.Status__c='In Progress';
        actions.Action__c='action';
        actions.Completed_Date__c=system.today();
        actions.IDP_Objective__c = objective.id;
        actions.QuipId__c = '877778863677';
        insert actions;
        
    }
    
    static testMethod void testIdpLastSavedDateOnActionUpdate(){

        //arrange
        String query = 'SELECT Id, IDP_Objective__r.IDP__c, ' + String.join(IdpTriggerHandler.IDP_OBJECT_FIELDS_MAP.get(IdpTriggerHandler.IDP_OBJECT.IDP_ACTIONS), ', ') + ' FROM IDP_Action__c';
        List<IDP_Action__c> actions = Database.query(query);
        
        //act
        Test.startTest();
        actions[0].Action__c= 'Test Dummy Update';
        update actions;
        Test.stopTest();
        
        //assert
        List<IDP__c> updatedIdps = [SELECT Id, Last_Saved_Date__c FROM IDP__c WHERE Id = :actions[0].IDP_Objective__r.IDP__c];
        System.assertEquals(Date.valueOf(System.now()), Date.valueOf(updatedIdps[0].Last_Saved_Date__c), 'Last Saved date on IDP should have been updated to TODAY');
    }
    
    static testMethod void testIdpLastSavedDateOnActionDelete(){

        //arrange
        String query = 'SELECT Id, IDP_Objective__r.IDP__c, ' + String.join(IdpTriggerHandler.IDP_OBJECT_FIELDS_MAP.get(IdpTriggerHandler.IDP_OBJECT.IDP_ACTIONS), ', ') + ' FROM IDP_Action__c';
        List<IDP_Action__c> actions = Database.query(query);
        
        //act
        Test.startTest();
        actions [0].IsDeleted__c = true;
        update actions;
        Test.stopTest();
        
        //assert
        List<IDP__c> updatedIdps = [SELECT Id, Last_Saved_Date__c FROM IDP__c WHERE Id = :actions[0].IDP_Objective__r.IDP__c];
        System.assertEquals(Date.valueOf(System.now()), Date.valueOf(updatedIdps[0].Last_Saved_Date__c), 'Last Saved date on IDP should have been updated to TODAY');
    }
}