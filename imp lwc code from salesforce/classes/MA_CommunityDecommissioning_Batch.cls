global with sharing class MA_CommunityDecommissioning_Batch implements Database.Batchable<sObject>, Database.Stateful {
    
    private String companyName;

    private List<String> truncatedErrorList = new List<String>();
    private List<String> fullErrorList = new List<String>();
    private Integer scopeSize = 0;
    
    public MA_CommunityDecommissioning_Batch(String companyName) {
        this.companyName = companyName;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = Test.isRunningTest() ? 'Select Id, IsActive From User Where IsActive = True LIMIT 1' : 
        'Select Id, IsActive From User Where Contact.Acquisition_Contacts__r.Acquisition_Company_Name__c =:companyName AND IsActive = True';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<User> scope) {
        scopeSize += scope.size();
        List<User> usersToDecommission = new List<User>();
        Database.SaveResult[] srList;
       
        for(User user : scope) {
			user.IsActive = False;
            usersToDecommission.add(user);
        }
        
        if(Schema.sObjectType.User.fields.IsActive.isUpdateable()) {
            srList = Database.update(usersToDecommission, false);
        }
        
        for(Integer index = 0; index < srList.size(); index++) {
            if(!srList[index].isSuccess()) {
                for(Database.Error err : srList[index].getErrors()) {
                    if(truncatedErrorList.size() != 100) {
                        truncatedErrorList.add('Failed to decommission User : ' +usersToDecommission[index].Id+'--with the following error : '+err);
                    }
                    fullErrorList.add('Failed to decommission User : ' +usersToDecommission[index].Id+'--with the following error : '+err);
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        String fullMessage = String.join(fullErrorList, '\n');
        String truncatedMessage = String.join(truncatedErrorList,'\n');
        Boolean noErrorsFound;
        
        //Insert Error Log as a File in Salesforce.com
        ContentVersion errorLogFile = new ContentVersion();
        if(fullMessage!='') {
            errorLogFile.versionData = Blob.valueOf(fullMessage) ;
            noErrorsFound = False;
        }
        else {
            errorLogFile.versionData = Blob.valueOf('No Errors Found');
            noErrorsFound = True; 
        }
        
        errorLogFile.description = 'Errors : ';
        if (noErrorsFound) {
            errorLogFile.Title = '[SUCCESS] - Community-Decommission-Results';
        }
        
        else {
            errorLogFile.Title = '[ERROR] - Community-Decommission-Results';
        }
        errorLogFile.pathOnClient ='/'+errorLogFile.title;
        errorLogFile.origin = 'H';
        insert errorLogFile;        

        List<String> logsInsertedIds = new List<String>();
        logsInsertedIds.add(errorLogFile.Id);
        
        PF_MA_Settings__c customSettings = PF_MA_Settings__c.getOrgDefaults();      
        List<String> emailId = new List<String>();
        emailId.add(customSettings.Community_Decommission_Contact__c);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(emailId);  
        mail.setSenderDisplayName('MA_CommunityDecommissioning_Batch');    
        mail.setSubject('MA Community Decommissioning Results');    
        if(noErrorsFound) {
           mail.setPlainTextBody('JobId : '+BC.getJobID()+'\nTotal Users Decommissioned: '+scopeSize+ 
           '\nNo errors found!');  
        }
        
        else {
            mail.setPlainTextBody('JobId : '+BC.getJobID()+'\nTotal Users Decommissioned: '+scopeSize+ 
                              '\nHere are the following errors : '+truncatedMessage+
                                 '\nAttached is the file of errors \n' +URL.getSalesforceBaseUrl().toExternalForm() + '/' + errorLogFile.Id+ '\n');  
        }  
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
     }
}