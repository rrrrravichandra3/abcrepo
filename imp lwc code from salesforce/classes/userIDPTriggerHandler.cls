public class userIDPTriggerHandler {
    
    
    public static void createIDP(List<user> userList){
        List<idp__c> IdpsToInsert = new List<idp__c>();
        for (user u:userList){
            if(u.EmployeeNumber != null) {
            IdpsToInsert.add(new idp__c(Employee_Number__c = u.EmployeeNumber));
            }
        }
        if(IdpsToInsert.size()>0){
           List<Database.SaveResult> results = Database.insert(IdpsToInsert);
           for (Database.SaveResult sr : results) {
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    PF_Logger.log('userIDPTriggerHandler','ERROR','Failure happen when Inserting the records','Insert Error',err.getMessage(),'userIDPTriggerHandler');
                }
            } 
        }
        if(!PF_Logger.logs.isEmpty()){
            PF_Logger.createLogs(PF_Logger.logs);
        }

        }
     
     }
    
    public static void updateIDP(List<user> newUserList, List<user> oldUserList){
        List<idp__c> IdpsToUpdate = new List<idp__c>();
        Map<id,user> oldUsers = new Map<id,user>(oldUserList);
        for (user u:newUserList){
            if(u.ManagerId != oldUsers.get(u.id).ManagerId) {
            IdpsToUpdate.add(new idp__c(Manager_Name__c = u.Manager.name));
            }
        }
        if(IdpsToUpdate.size()>0){
           List<Database.SaveResult> results = Database.update(IdpsToUpdate);
           for (Database.SaveResult sr : results) {
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    PF_Logger.log('userIDPTriggerHandler','ERROR','Failure happen when Updating the records','Update Error',err.getMessage(),'userIDPTriggerHandler');
                }
            } 
        }
        if(!PF_Logger.logs.isEmpty()){
            PF_Logger.createLogs(PF_Logger.logs);
        }

        }
     
     }

}