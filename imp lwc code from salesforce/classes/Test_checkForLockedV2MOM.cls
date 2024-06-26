@isTest
private class Test_checkForLockedV2MOM {
      
    public static testMethod void execute_methods_checkForLockedV2MOM() {
        
        GenerateEnvironmentTest1.gen();
        
        Test.startTest();
         
        V2MOM__c v2mom = GenerateEnvironmentTest1.v2momLocked;
         
        try{
            v2mom.Vision__c = v2mom.Vision__c + ' extra';
            update v2mom;
        }catch(Exception e){
            System.debug(' ****************** Test_checkForLockedV2MOM * Could not update v2mom');
            System.debug(e.getMessage());
        }
     
        try{
            delete v2mom;
        }catch(Exception e){
            System.debug(' ****************** Test_checkForLockedV2MOM * Could not delete v2mom');
            System.debug(e.getMessage());
        }
        
        Test.stopTest();
        
    }
    
}