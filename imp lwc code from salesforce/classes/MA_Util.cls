/**
 * @description       : MA Util class, it stores all common methods for MA
 * @author            : Satyam Kumar
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   05-06-2021   Satyam Kumar   Initial Version
**/
public without sharing class MA_Util {
    
    public static final Set<String> nonStringDataTypes	= new Set<String>{'DOUBLE' , 'BOOLEAN' , 'CURRENCY' , 'PERCENT' , 'DATE' , 'DATETIME'};
    public static final Set<String> nonWildCardFields 	= new Set<String>{'DOUBLE' , 'BOOLEAN' , 'CURRENCY' , 'PERCENT' , 'REFERENCE' , 'DATE' , 'DATETIME'};
            
    /*
    * Utility method to return MA_TaskManagementSettings custom setting
    */
    public static MA_TaskManagementSettings__c getTaskManagementSettings () {
        
        return MA_TaskManagementSettings__c.getValues('MA_TaskManagementSettings');
        
    }
    
    /*
    * Utility method to process Acquisition Contact Id and Acquisition Company Task. Returns Acquisition Contact Task
    */
  /*  public static Acquisition_Contact_Task__c getAcquisitionContactTask(Acquisition_Company_Task__c companyTask, Id contactId) {
        if(companyTask == null || String.isBlank(contactId))
        {
            return null;
        }
        
        Acquisition_Contact_Task__c contactTask = new Acquisition_Contact_Task__c();
        contactTask.Acquisition_Contact__c 		= contactId;
        contactTask.Acquisition_Company_Task__c = companyTask.Id;
        contactTask.Due_Date__c 				= companyTask.Due_Date__c;
        contactTask.Priority__c 				= companyTask.Priority__c;
        contactTask.Status__c 					= companyTask.Status__c;
        contactTask.Subject__c 					= companyTask.Subject__c;
        contactTask.Category__c 				= companyTask.Category__c;
        contactTask.Required__c 				= companyTask.Required__c;
        contactTask.Task_Context__c 			= companyTask.Task_Context__c;
        return contactTask;
    }*/
    
    /*
    * Utility method to process Acquisition Company Task. Returns updated Acquisition Contact Task
    */
   /* public static Acquisition_Contact_Task__c getUpdatedAcquisitionContactTask(Acquisition_Company_Task__c companyTask, Acquisition_Contact_Task__c contactTask, Boolean statusChanged) {
        contactTask.Acquisition_Company_Task__c = companyTask.Id;
        contactTask.Due_Date__c 				= companyTask.Due_Date__c;
        contactTask.Priority__c 				= companyTask.Priority__c;
        contactTask.Subject__c 					= companyTask.Subject__c;
        contactTask.Category__c 				= companyTask.Category__c;
        contactTask.Required__c 				= companyTask.Required__c;
        contactTask.Task_Context__c 			= companyTask.Task_Context__c;
        if(statusChanged) {
            contactTask.Status__c = companyTask.Status__c;
        }
        return contactTask;
    }
*/    
    /*
    *Method to process Task notifications
	*/
    public static void processTaskNotification(List<Id> ids, Boolean isCreate){
        List<MA_SlackWayfinderService.SlackMessageBody> messages = new List<MA_SlackWayfinderService.SlackMessageBody>();
        Map<String, String> emailCummunityUrlMap = new Map<String, String>();
        List<Id> acqConIds = new List<Id>();
        List<Acquisition_Contact_Task__c> acqContactTasks = new List<Acquisition_Contact_Task__c>();
        String messageText = '' ;
        if(isCreate) {
            messageText = System.label.MA_Slack_New_Task ;
        } else {
            messageText = System.label.MA_Slack_Update_Task ;
        }
        
        acqContactTasks =  MA_SlackWayfinderService.getTaskInfo(ids);
        
         for(Acquisition_Contact_Task__c conTask :acqContactTasks) {
                acqConIds.add(conTask.Acquisition_Contact__c);
        }

        if(acqConIds != null && !acqConIds.isEmpty()){
            emailCummunityUrlMap = MA_SlackWayfinderService.getContactInfo(acqConIds);
            for(Acquisition_Contact_Task__c conTask : acqContactTasks) {
                String communityurl;
                String email = conTask.Acquisition_Contact__r.Email_Address_Target__c;
                
                if(emailCummunityUrlMap != null && String.isNotBlank(email) && email.contains('slack-corp.com') && emailCummunityUrlMap.containsKey(email) ) {
                    communityurl = emailCummunityUrlMap.get(email)+'s/mytasks';
                    MA_SlackWayfinderService.SlackMessageBody message = new MA_SlackWayfinderService.SlackMessageBody
                        (email,
                         messageText +' '+ conTask.Subject__c,
                         communityurl,
                         System.label.MA_Slack_Task_Button_Text);
                    
                    messages.add(message);
                }
            }
        }
        if(!messages.isEmpty()) {
            MA_SlackWayfinderService.sendMessagestoSlackWayfinderBot(messages,true);
        }
    }
    
    /*
    *Method to validate tasks critera before update and insert
	*/
    
 /*   public static void checkForValidOperators(List<sObject> lstSobject, String objectName){
        
        Map<String, String> mapOfFieldVsDataType    = MA_Util.getFieldsAndDataType(objectName);
        Map<String, Boolean> mapOfFieldVsFilterable = MA_Util.getFieldsAndFilterAbility(objectName);
        Set<String> nonWildCardFields               = MA_Util.nonWildCardFields;
        
        for(sObject taskCriteria : lstSobject){
            String fieldDataType = mapOfFieldVsDataType.get(String.valueOf(taskCriteria.get('Field__c')).toLowerCase());
            Boolean isFiltrable  = mapOfFieldVsFilterable.get(String.valueOf(taskCriteria.get('Field__c')).toLowerCase());
            if(taskCriteria.get('Field__c') != null && !isFiltrable ){
                taskCriteria.addError(taskCriteria.get('Field__c')+' Field can not be filtered');
            }else if(taskCriteria.get('Field__c') != null && 
                     nonWildCardFields.contains(fieldDataType) && 
                     (taskCriteria.get('Operator__c') == 'contains' || taskCriteria.get('Operator__c') == 'does not contain')) {
                taskCriteria.addError('Invalid operator for '+taskCriteria.get('Field__c'));
            }
        }
    }
    
    public static Map<String, String> getFieldsAndDataType(String objectType){
        
        Map<String, String> mapOfFieldVsDataType 	= new Map<String, String>();
        Map<String, Schema.SObjectType> schemaMap 	= Schema.getGlobalDescribe();
        Schema.SObjectType objectSchema 			= schemaMap.get(objectType);
        Map<String, Schema.SObjectField> fieldMap 	= objectSchema.getDescribe().fields.getMap();
        
        for (String fieldName: fieldMap.keySet()) {
            Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
            mapOfFieldVsDataType.put(fieldName.toLowerCase() , String.ValueOf(fielddataType));
        }
        return mapOfFieldVsDataType;
    }
    
    public static Map<String, Boolean> getFieldsAndFilterAbility(String objectType){
        
        Map<String, Boolean> mapOfFieldVsFilterable = new Map<String, Boolean>();
        Map<String, Schema.SObjectType> schemaMap 	= Schema.getGlobalDescribe();
        Schema.SObjectType objectSchema 			= schemaMap.get(objectType);
        Map<String, Schema.SObjectField> fieldMap 	= objectSchema.getDescribe().fields.getMap();
        
        for (String fieldName: fieldMap.keySet()) {
            mapOfFieldVsFilterable.put(fieldName.toLowerCase() , Boolean.ValueOf(fieldMap.get(fieldName).getDescribe().isFilterable()));
            
        }
        return mapOfFieldVsFilterable;
    }
    */
    
    public static Boolean checkTriggerEnabled(String className, String objectName, String event){
        MA_Trigger_Handler__mdt triggerSettings = [SELECT Id, Disabled__c  
                                                   FROM MA_Trigger_Handler__mdt
                                                   WHERE HelperClass__c =:className AND Object__c =: objectName AND Events__c =:event 
                                                   LIMIT 1];
        return (triggerSettings != null && triggerSettings.Disabled__c);
    }
    
}