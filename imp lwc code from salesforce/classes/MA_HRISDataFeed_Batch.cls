global with sharing class MA_HRISDataFeed_Batch implements Database.Batchable<sObject>, Database.Stateful {
       
    private List<String> truncatedErrorList = new List<String>();
    private List<String> fullErrorList = new List<String>();
    private Integer totalAcquisitionContactsUpdated = 0;
    Map<String, Id> acquirerCompKeyToAcqContactId;
    Map<String, Id> acquiredCompKeyToAcqContactId;
    String companyname;
    public MA_HRISDataFeed_Batch(){
    }
     
     public MA_HRISDataFeed_Batch(string companyname){
     this.companyname = companyname;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        acquirerCompKeyToAcqContactId = new Map<String,Id>();
        acquiredCompKeyToAcqContactId = new Map<String,Id>();
        String query = 'Select Id, Acquisition_Company_Name__c,Employee_ID_Target__c, Employee_ID__c,Manager_ID_Target__c, Manager_ID__c From Acquisition_Contacts__c';
        if(companyname != null){
         query = query + ' where Acquisition_Company__r.name=:companyname';
        } 
        List<Acquisition_Contacts__c> allacqContacts = Database.query(query);

        for(Acquisition_Contacts__c acqContact : allacqContacts) {
            if(acqContact.Employee_ID__c != null) {
           	    acquirerCompKeyToAcqContactId.put(acqContact.Acquisition_Company_Name__c + acqContact.Employee_ID__c, acqContact.Id);
            }

            if(acqContact.Employee_ID_Target__c != null) {
                acquiredCompKeyToAcqContactId.put(acqContact.Acquisition_Company_Name__c + acqContact.Employee_ID_Target__c, acqContact.Id);
            }
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Acquisition_Contacts__c> scope) {
        Database.SaveResult[] srList;

        
        List<Acquisition_Contacts__c> acqContactsToUpdate = new List<Acquisition_Contacts__c>();
        Boolean updateMade;
        for(Acquisition_Contacts__c acqContact : scope) {
            updateMade = False;
            
            if(acqContact.Manager_ID__c != null) {
                String managerNameKey = acqContact.Acquisition_Company_Name__c + acqContact.Manager_ID__c;
                
                if(acquirerCompKeyToAcqContactId.containsKey(managerNameKey)) {
                    acqContact.Manager_Name__c = acquirerCompKeyToAcqContactId.get(managerNameKey);
                    updateMade = True;
                }
            }

            if(acqContact.Manager_ID_Target__c != null) {
                String managerNameTargetKey = acqContact.Acquisition_Company_Name__c + acqContact.Manager_ID_Target__c;

                if(acquiredCompKeyToAcqContactId.containsKey(managerNameTargetKey)) {
                    acqContact.Manager_Name_Target__c = acquiredCompKeyToAcqContactId.get(managerNameTargetKey);
                   	updateMade = True;
                }
            }
            
            if(updateMade) {
                acqContactsToUpdate.add(acqContact);
                totalAcquisitionContactsUpdated +=1;
            }
        }
        
        
        
        List<String> fieldsToCheck = new List<String>();
        fieldsToCheck.add('Manager_Name__c');
        fieldsToCheck.add('Manager_Name_Target__c');

        if(PF_AccessibilityUtils.checkFLS('Acquisition_Contacts__c', PF_AccessibilityUtils.PermissionType.UPDATEABLE,fieldsToCheck)) {
        	 srList = Database.update(acqContactsToUpdate, false);
        }
        
        for(Integer index = 0; index < srList.size(); index++) {
            if(!srList[index].isSuccess()) {
                for(Database.Error err : srList[index].getErrors()) {
                    if(truncatedErrorList.size() != 100) {
                    	truncatedErrorList.add('Failed to update Acquisition Contact : ' +acqContactsToUpdate[index].Id+'--with the following error : '+err);
                    }
                    fullErrorList.add('Failed to update Acquisition Contact : ' +acqContactsToUpdate[index].Id+'--with the following error : '+err);
                }
            }
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        String fullMessage = String.join(fullErrorList, '\n');
        String truncatedMessage = String.join(truncatedErrorList, '\n');
        
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
            errorLogFile.Title = '[SUCCESS] - HRISDataFeed-Update-Results';
        }
        
        else {
            errorLogFile.Title = '[ERROR] - HRISDataFeed-Update-Results';
        }
        errorLogFile.pathOnClient ='/'+errorLogFile.title;
        errorLogFile.origin = 'H';
        insert errorLogFile;        

        List<String> logsInsertedIds = new List<String>();
        logsInsertedIds.add(errorLogFile.Id);
        
        PF_MA_Settings__c customSettings = PF_MA_Settings__c.getOrgDefaults();		
   		List<String> emailId = new List<String>();
        emailId.add(customSettings.HRIS_Batch_Support_Email__c);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(emailId);  
        mail.setSenderDisplayName('MA_HRISDataFeed_Batch');    
        mail.setSubject('MA HRIS Data Feed Update Results');    
        
        if(noErrorsFound) {
           mail.setPlainTextBody('JobId : '+BC.getJobID()+'\nTotal Acquisition Contacts Updated: '+totalAcquisitionContactsUpdated+ 
           '\nNo errors found!');  
        }
        
        else {
            mail.setPlainTextBody('JobId : '+BC.getJobID()+'\nTotal Acquisition Contacts Updated: '+totalAcquisitionContactsUpdated+ 
                              '\nHere are the following errors : '+truncatedMessage+
                                 '\nAttached is the file of errors \n' +URL.getSalesforceBaseUrl().toExternalForm() + '/' + errorLogFile.Id+ '\n');  
        }  
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }
}