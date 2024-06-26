/**
* @author Apuroop Gadde
* @date 06-26-2017
* @group Util Classes
* @description Class containing util methods to be used across WDR triggers
*/
public with sharing class WDR_CommonTriggerUtils {
    /**
    * @description Reads the field set for required fields on WDR_Candidate__c and throws an error if 
    * the fields are empty.
    * @param soType sObjectType of the object whose fields need to be validated
    * @param triggerNew List of objects which need to be inserted or updated.
    **/
    public static void validateRequiredFields(Schema.SObjectType soType, List<SObject> triggerNew) {
        String errorPrefix = getErrorPrefix(soType);
        String requiredFieldsErrors = '';
        Map<String,String> requiredFieldsMap = getRequiredFieldsForObject(soType);
        for(sObject record : triggerNew) {
            requiredFieldsErrors = '';
            for(String fieldName : requiredFieldsMap.keySet()) {
                if(record.get(fieldName) == null) {
                    requiredFieldsErrors = requiredFieldsErrors + getErrorTextForRequiredField(errorPrefix,requiredFieldsMap.get(fieldName)) + ',';
                }
            }
            if(String.isBlank(requiredFieldsErrors) == false) {
                record.addError(requiredFieldsErrors);
            } 
        }
    }

    /**
    * @description Returns the error prefix based on the object type
    * @param soType sObjectType of the object whose prefix needs to be returned
    **/
    @testVisible    
    private static String getErrorPrefix(Schema.sObjectType soType) {
        if(soType == WDR_Application__c.sObjectType) {
            return 'WDR_APPLICATION';
        }
        else if(soType == WDR_Candidate__c.sObjectType) {
            return 'WDR_CANDIDATE';
        }
        else if(soType == WDR_Job__c.sObjectType) {
            return 'WDR_JOB';
        }
        return '';
    }

    /**
    * @description Method to return the appropriate Map of Api names and labels for required fields based on the object type
    * @param soType sObjectType of the object whose required fields need to be returned.
    **/
    @testVisible    
    private static Map<String,String> getRequiredFieldsForObject(Schema.sObjectType soType){
        Map<String,String> fieldNamesAndLabels = new Map<String,String>();
        List<Schema.FieldSetMember> fields = new List<Schema.FieldSetMember>();
        if(soType == WDR_Application__c.sObjectType) {
            fields = SObjectType.WDR_Application__c.FieldSets.WDR_Application_Required_Fields.getFields();
        }
        else if(soType == WDR_Candidate__c.sObjectType) {
            fields = SObjectType.WDR_Candidate__c.FieldSets.WDR_Candidate_Required_Fields.getFields();
        }
        else if(soType == WDR_Job__c.sObjectType) {
            fields = SObjectType.WDR_Job__c.FieldSets.WDR_Job_Required_Fields.getFields();
        }

        for(Schema.FieldSetMember field : fields){
            fieldNamesAndLabels.put(field.getFieldPath(),field.getLabel());
        }

        return fieldNamesAndLabels;
    }

    /**
    * @description Constructs the error message for required fields that needs to be attached to 
    * object if the field is empty.
    * @param fieldLabel label of the field that is empty.
    **/
    @testVisible    
    private static String getErrorTextForRequiredField(String objectName, String fieldLabel) {
        return objectName + '_' + fieldLabel.replaceAll(' ', '_').toUpperCase()+'_REQUIRED';
    }
}