global with sharing class NHW_VerifyEmployeeFlagToFTEBatch implements Database.Batchable<sObject>, Schedulable{
	
    global Database.QueryLocator start(Database.BatchableContext BC){
      String query = 'SELECT Id, Is_Employee__c,EmployeeNumber FROM User WHERE IsActive = true AND isPortalEnabled = false AND Is_Employee__c = false AND EmployeeNumber != \'CTRCT\' AND EmployeeNumber != null';
      return Database.getQueryLocator(query);
     }
     
    global void execute(SchedulableContext SC) {
        Database.executeBatch(this, 200);
    }
    
    global void execute(Database.BatchableContext BC, List<User> userList){
      List<User> userListToUpdate = new List<User>();
      for(User userRecord : userList){
        if(userRecord.EmployeeNumber.isNumeric()){
          userRecord.Is_Employee__c = true;
          userListToUpdate.add(userRecord);
        }
      }
      Database.SaveResult[] updateResults;
      Integer succesfulUpdateCount = 0;
      Integer errorCount = 0;
      if(userListToUpdate.size() > 0){
        updateResults = Database.update(userListToUpdate, false);
        for(Database.SaveResult resultRecord : updateResults) {
          if (!resultRecord.isSuccess()) {
            for(Database.Error err : resultRecord.getErrors()) { 
              errorCount = errorCount + 1;
              System.debug(err.getStatusCode() + ': ' + err.getMessage());         
            }
          }else{
            succesfulUpdateCount = succesfulUpdateCount + 1;
          }
        }
      }
      System.debug('User list size : '+ userListToUpdate.size());
      System.debug('Users sucesfully updated: '+ succesfulUpdateCount);
      System.debug('Users not updated, because of errors: '+ errorCount);
    }
    
    global void finish(Database.BatchableContext BC){
        
   	}
}