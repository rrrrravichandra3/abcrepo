public without sharing class MA_MyTasksController {
    
    @AuraEnabled 
    public static List<Acquisition_Contact_Task__c> getActivities(){ 
        String currentUserEmail = UserInfo.getUserEmail();
        List<Acquisition_Contact_Task__c > allTasks = new List<Acquisition_Contact_Task__c >();
        Acquisition_Contacts__c[] acqContactRec = [Select Id From Acquisition_Contacts__c where Email_Address_Target__c  =:currentUserEmail];
        if(acqContactRec.size() > 0) {
            String acqContactId = acqContactRec[0].Id;
            allTasks = [Select Id, Subject__c, Description__c, Task_Context__c, Owner.Name, Due_Date__c, Status__c, Required__c, Category__c From Acquisition_Contact_Task__c Where Acquisition_Contact__c =:acqContactId ORDER By Due_Date__c ASC];
        }
        return allTasks;
    }
    
    @AuraEnabled
    public static void updateTaskStatus(Acquisition_Contact_Task__c taskToUpdate, Boolean checked) {
        Id taskId = taskToUpdate.Id;
        Acquisition_Contact_Task__c currTask = [Select Status__c From Acquisition_Contact_Task__c Where Id=:taskId];
                
        if(checked) {
            currTask.Status__c = 'Completed';
        }
        else {
            currTask.Status__c = 'In Progress';
        }
        update currTask;
    }

    @AuraEnabled
    public static String getOrgDomainUrl(){
        return URL.getOrgDomainUrl().toExternalForm();
    }

}