/**
* @author Apuroop Gadde
* @date 07-09-2017
* @group TriggerHandlerUtils
* @description Utils class for methods used across SIFT WDR trigger handlers.
*/
public with sharing class IFB_WDUtils {
    private static Map<String,Set<String>> customSettingsAndValues = new Map<String,Set<String>>();
    /**
    * @description Returns the ids of SOBjects whose SIFT Object related fields have been updated. 
    * @param triggerNewMap Trigger.newMap of the SObject which was updated.
    * @param triggerOldMap Trigger.oldMap of the SObject which was updated.
    * @param objectType SObjectType of the SObject which has been updated.
    * @return List of Ids of records whose recruit related fields have changed.
    **/
    public static List<Id> getIdsOfSObjectswithFieldsChange(Map<Id,SObject> triggerNewMap , Map<Id,SObject> triggerOldMap, Schema.SObjectType objectType,Schema.SObjectType SIFTObjectType) {
        if(triggerNewMap == null || triggerOldMap == null || objectType == null || SIFTObjectType == null) {
            return new List<Id>();
        }        
        List<String> recruitFieldsForSObject = getFieldsForObject(objectType,SIFTObjectType);
        List<Id> idsOfSObjectswithRecruitFieldsChange = new List<Id>();
        for(Id sObjectId : triggerNewMap.keySet()) {
            SObject newObject = triggerNewMap.get(sObjectId);
            SObject oldObject = triggerOldMap.get(sObjectId);
            if(newObject != null && oldObject != null && recruitFieldsChanged(newObject,oldObject,recruitFieldsForSObject)) {
                idsOfSObjectswithRecruitFieldsChange.add(sObjectId);
            }
        }
        return idsOfSObjectswithRecruitFieldsChange;
    }

    /**
    * @description Returns the fields from the appropriate object that are populated on the SIFT Object. These are stored in fieldsets on the 
    * respective objects.
    * @param objectType SObjectType of the object whose recruit related fields need to be retrieved.
    * @return Returns the API names of the fields based on the input parameters.
    **/
    public static List<String> getFieldsForObject(Schema.SObjectType objectType,Schema.sObjectType SIFTObjectType) {
        List<String> fieldNames = new List<String>();
        List<Schema.FieldSetMember> fields = new List<Schema.FieldSetMember>();
        if(SIFTObjectType == IFB_Interview_Candidate__c.sObjectType) {
            if(objectType == WDR_Application__c.sObjectType) {
                fields = SObjectType.WDR_Application__c.FieldSets.WDR_Application_Recruit_Related_Fields.getFields();
            }
            else if(objectType == WDR_Candidate__c.sObjectType) {
                fields = SObjectType.WDR_Candidate__c.FieldSets.WDR_Candidate_Recruit_Related_Fields.getFields();
            }
            else if(objectType == WDR_Job__c.sObjectType) {
                fields = SObjectType.WDR_Job__c.FieldSets.WDR_Job_Recruit_Related_Fields.getFields();
            }
        }
        else if(SIFTObjectType == IFB_Interview__c.sObjectType) {
            if(objectType == WDR_Job__c.sObjectType) {
                fields = SObjectType.WDR_Job__c.FieldSets.WDR_Job_Interview_Related_Fields.getFields();
            }
            else if(objectType == WDR_Application__c.sObjectType) {
                fields = SObjectType.WDR_Application__c.FieldSets.WDR_Application_Interview_Related_Fields.getFields();
            }              
        }

        for(Schema.FieldSetMember field : fields){
              fieldNames.add(field.getFieldPath());
        }
        return fieldNames;    
    }

    /**
    * @description Returns true if any of the recruit related fields have been updated.
    * @param newObject object from the Trigger.newMap.  
    * @param oldObject object from the Trigger.oldMap.
    * @param recruitRelatedFields List of fields on the SObject that are related to SIFT Recruit.
    **/
    private static boolean recruitFieldsChanged(SObject newObject, SObject oldObject, List<String> recruitRelatedFields) {
        for(String recruitRelatedField : recruitRelatedFields) {
            if(newObject.get(recruitRelatedField) != oldObject.get(recruitRelatedField)) {
                return true;
            }
        }
        return false;
    }

    /**
    * @description Util method to send a email to interested parties
    * with attachment of the error log of errors that occur when updating SIFT objects from WDR objects on org 
    * @param errorLog String that contains all the errors 
    * @param errorFileDesc Description of the error file
    * @param errorFileTitle Title for the error file.
    **/
    public static void mailErrors(String errorLog, String errorFileDesc,String errorFileTitle) {

        String emailIdsFromCustomSetting = IFB_SIFT_Settings_List__c.getInstance('SIFT').IFB_WD_Integration_Downstream_Err_Emails__c;
        if(String.isEmpty(emailIdsFromCustomSetting) == true) {
            return;
        }
        List<String>emailIds = emailIdsFromCustomSetting.split(',');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(emailIds);
        mail.setSenderDisplayName('WDR Integation - SIFT Object Update failures');
        mail.setSubject(errorFileDesc);
        mail.setPlainTextBody('Attached is the log file for the errors \n');

        Messaging.EmailFileAttachment txtAttachment = new Messaging.EmailFileAttachment();
        txtAttachment.setBody(Blob.valueOf(errorLog));
        txtAttachment.setFileName(errorFileTitle+'.txt');		
        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{txtAttachment});

        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });         
    }

    /**
    * @description This method returns set of values that are listed for the incoming custom setting.
    * @param customSetting Name of the custom setting whose values need to be read from SIFT Settings list custom setting.
    * @return Set of values that are listed for the input custom setting.
    **/
    public static Set<String> getValuesForCustomSetting(String customSetting) {
        if(String.isEmpty(customSetting) == true) {
            return new Set<String>();
        }        
        if (customSettingsAndValues.get(customSetting) == null) {
            Set<String> values = new Set<String>();
            IFB_SIFT_Settings_List__c siftSettings = IFB_SIFT_Settings_List__c.getInstance('SIFT');
            if (siftSettings != null && siftSettings.get(customSetting) != null) {
                String valuesInString = (String)siftSettings.get(customSetting);
                values.addAll(valuesInString.split(','));
            }
            customSettingsAndValues.put(customSetting,values);
        }
        return customSettingsAndValues.get(customSetting);
    }

    /**
    * @description This method creates a WDR Application share object based on the input WD Job Application and returns it
    * @param inApp The application which needs to be shared
    * @return Share object for the imput WD Job Application
    **/
    public static WDR_Application__share createShareForApplication(WDR_Application__c inApp) {
        WDR_Application__share shareForApplication = new WDR_Application__share();
        shareForApplication.ParentId = inApp.Id;
        shareForApplication.UserOrGroupId = inApp.Job__r.Hiring_Manager__c;
        shareForApplication.AccessLevel = 'Read';
        shareForApplication.RowCause = Schema.WDR_Application__share.RowCause.Hiring_Manager__c;
        return shareForApplication;
    }
}