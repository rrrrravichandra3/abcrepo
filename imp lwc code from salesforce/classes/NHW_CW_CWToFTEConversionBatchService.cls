public with sharing class NHW_CW_CWToFTEConversionBatchService {
    
    public static Database.QueryLocator performStartQuery(){
        return Database.getQueryLocator([Select Id, Name, Do_Not_Send_NHW__c, Candidate__c, Candidate__r.Employee_Number__c
                                         FROM WDR_Application__c
                                         WHERE Do_Not_Send_NHW__c=True
                                         AND Internal_Candidate__c=True
                                         AND Candidate_Stage__c='Placement'
                                         AND Candidate__c!=null
                                         AND Candidate__r.Employee_Number__c!=null
                                         AND Start_Date__c>=today]);
    }
    /*
    * Called by execute method of NHW_CW_CWToFTEConversionBatch
    * @param jobApps                      List of job apps in scope of current execution chunk
    * @param contractorContactRecId       Id of the recordsType Contractor for Object Contact
    * If a job App in scope has a Contractor Contact with matching Employee Id, we update it's Do_Not_Send_NHW__c to False
    */
    public static Map<String, String> performBatchExecute(List<WDR_Application__c> jobApps, Id contractorContactRecId){
        //Local data for the Job Apps that fail to update
        Map<String, String> failedUpdates = new Map<String, String>();
        //Map of WD Candidate's Employee Number to WD Job App record
        Map<String,WDR_Application__c> candidateEmpIdToJobAppMap = new Map<String,WDR_Application__c>();
        for(WDR_Application__c currentJobApp:jobApps){
            candidateEmpIdToJobAppMap.put(currentJobApp.Candidate__r.Employee_Number__c,currentJobApp);
        }
        //query CW Contacts with matching employee id
        List<Contact> cwContacts = [Select Id, EmployeeNumber__c 
                                    From Contact 
                                    Where RecordTypeId=:contractorContactRecId
                                        AND Status__c='Active'
                                        AND EmployeeNumber__c!=null 
                                        AND EmployeeNumber__c IN :candidateEmpIdToJobAppMap.keySet()];
        //save CPU cycles if No matching CW contacts are found. Return from this method
        if(cwContacts.isEmpty()){
            return null;
        }
        //Execute below code block if one or more WD Candidate's Employee Nnmbers were found in an Active CW Contact
        
        //Set of Employee Numbers that were found on CW Contacts
        Set<String> contractorEmpNumbers = new Set<String>();
        for(Contact currentContractor: cwContacts){
            contractorEmpNumbers.add(currentContractor.EmployeeNumber__c);
        }
        //Using Employee Numbers in above Set, find the corresponding Job App and Update its Do_Not_Send_NHW__c flag
        List<WDR_Application__c> jobAppsThatNeedUpdate = new List<WDR_Application__c>();
        for(String currentEmployeeNumber : contractorEmpNumbers){
            if(candidateEmpIdToJobAppMap.containsKey(currentEmployeeNumber)){
                WDR_Application__c currentJobApp = candidateEmpIdToJobAppMap.get(currentEmployeeNumber);
                currentJobApp.Do_Not_Send_NHW__c= False;
                jobAppsThatNeedUpdate.add(currentJobApp);
            }
        }       
        //perform the update. Store data about records that throw error, in Map failedUpdates
        Database.SaveResult[] updateResult = new Database.SaveResult[]{};
        if(WDR_Application__c.sObjectType.getDescribe().isUpdateable()){
            try {
                updateResult = Database.update(jobAppsThatNeedUpdate,false);
                for(Integer i=0;i<updateResult.size();i++){
                    if(!updateResult.get(i).isSuccess()){
                        String failedJobAppName = String.ValueOf((jobApps.get(i)).Name);
                        String errorMessage = '';
                        for(Database.Error err : updateResult.get(i).getErrors()){
                            errorMessage = errorMessage + ' | ' + err.getMessage();
                        }
                        failedUpdates.put(failedJobAppName,errorMessage);
                    }
                }
            } catch (DmlException ex) { 
                system.debug('The following exception has occurred: ' + 
                            ex.getDmlStatusCode(0) + ex.getMessage());
            }
        }        
        return failedUpdates;
    }

    /*
    * Called by finish method of NHW_CW_CWToFTEConversionBatch
    * @param failedUpdates contains Map of WD Job App record names that failed updates, along with error message
    * value of Onboarding_Setting__c.NHW_CW_CWToFTEConversion_Error_Reporting__c defines the type of error handling
    * If the value is CustomSettingRecords, failed records data is added to customs setting CW_To_FTE_Conversion_Job_Failed_Records__c
    * If the value is EmailToCase, email to case functionality is used to inform EOps about failed records
    * Any other value implies no error reporting is needed.
    */
    public static void performBatchFinish(Map<String,String> failedUpdates){
        if((failedUpdates!=null) || (failedUpdates.isEmpty())){
            return;
        }
        String errorHandlingStrategy='';
        try{
            errorHandlingStrategy = Onboarding_Setting__c.getOrgDefaults().NHW_CW_CWToFTEConversion_Error_Reporting__c;
        }catch(Exception e){
            //do nothing, no error handling will be performed
        }
        
        if(String.isBlank(errorHandlingStrategy)){
            System.debug('@@@@@ No exception Handling strategy defined in Onboarding_Setting__c.NHW_CW_CWToFTEConversion_Error_Reporting__c');
            return;
        }else if (errorHandlingStrategy.equalsIgnoreCase('CustomSettingRecords')) {
            System.debug('@@@@@ Adding failed records to custom setting CW_To_FTE_Conversion_Job_Failed_Records__c');
            logErrorsToCustomSetting(failedUpdates);
        }else if(errorHandlingStrategy.equalsIgnoreCase('EmailToCase')){
            System.debug('@@@@@ Using Email to Case functionality for error reporting');
            sendEmailToCase(failedUpdates);
        }else{
            System.debug('@@@@@ Invalid exception Handling strategy defined in Onboarding_Setting__c.NHW_CW_CWToFTEConversion_Error_Reporting__c');
            return;
        }
    }

    private static void logErrorsToCustomSetting(Map<String,String> failedUpdates){
        List<CW_To_FTE_Conversion_Job_Failed_Records__c> failedUpdatesCustomStRecords = new List<CW_To_FTE_Conversion_Job_Failed_Records__c>();
        for(String currentJobAppName : failedUpdates.keySet()){
            CW_To_FTE_Conversion_Job_Failed_Records__c newCSEntry = new CW_To_FTE_Conversion_Job_Failed_Records__c();
            //Name field of custom setting stored WD Job App Name
            newCSEntry.Name = currentJobAppName;
            //Error message is trimmed down to 255 charactes and saved in field Failure_Reason__c of custom setting
            String failureReason = failedUpdates.get(currentJobAppName);
            if(String.isNotEmpty(failureReason)){
                newCSEntry.Failure_Reason__c = failureReason.abbreviate(255);
            }  
            failedUpdatesCustomStRecords.add(newCSEntry);          
        }
        if(!failedUpdatesCustomStRecords.isEmpty()){
            //Upsert using Name field as the unique identifier, instead of ID field
            //Upsert failedUpdatesCustomStRecords Name;
            try {
                if(Schema.sObjectType.CW_To_FTE_Conversion_Job_Failed_Records__c.isUpdateable() && Schema.sObjectType.CW_To_FTE_Conversion_Job_Failed_Records__c.isCreateable()){
                    Database.upsert(failedUpdatesCustomStRecords, false);
                }
            }  catch (DmlException ex) { 
                system.debug('The following exception has occurred: ' + 
                             ex.getDmlStatusCode(0) + ex.getMessage());
            }
        }
    }

    private static void sendEmailToCase(Map<String,String> failedUpdates){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        String emailToCaseAddressField = '';
        try{
            emailToCaseAddressField =  NH_Settings__c.getOrgDefaults().EmailToCase_Address__c;
        }catch(Exception e){
            System.debug(e.getMessage());
        }
        if(String.isBlank(emailToCaseAddressField)){
            System.debug('@@@@@ No email address found in NH_Settings__c.EmailToCase_Address__c. Aborting email to case error reporting');
            return;
        }
        message.toAddresses = emailToCaseAddressField.split(';');
        message.subject = 'Updates to WD Job App record via Batch NHW_CW_CWToFTEConversionBatch failed';
        String messageText = 'Batch Job NHW_CW_CWToFTEConversionBatch failed to set Do_Not_Send_NHW flag to false on below Job Apps <br/>';
        for(String currentJobAppName : failedUpdates.keySet()){
            messageText+='<br/>'+currentJobAppName+' : '+failedUpdates.get(currentJobAppName);
        }
        message.htmlBody = messageText;
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{message};
        if (!Test.isRunningTest()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        }
    }
}