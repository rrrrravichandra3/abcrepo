/**
 * ******************************************** W-12578110 : RULE ENGINE ********************************************
 * 
 * Wrapper class of MA_DS_AddRulesCriteria controller to hold details of Rules Criteria JSON & Audit Flags JSON.
 * Also holds details of Sobjects & Fields mapping required for user's selection on the UI.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         06/03/2023      Chakshu Malhotra        W-12578110 - Adds wrapper classes to hold details of package / template rules criteria & audit flags.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public with sharing class MA_DS_AddRulesCriteriaWrapper {

    @AuraEnabled public Integer maxSampleSize {get; set;}
    @AuraEnabled public String noRulesDisplayMessage {get; set;}

    @AuraEnabled public Boolean displayAuditFlags {get; set;} // false if flags are suppressed
    @AuraEnabled public Boolean displayRulesCriteria {get; set;} // false if PD status is not eligible or rules are suppressed

    @AuraEnabled public String parentSObject {get; set;}
    @AuraEnabled public Map<String, String> sObjectMap {get; set;} // objApiName to objLabel
    @AuraEnabled public Map<String, String> childRelationshipMap {get; set;}
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the Map of Field Type to List of Allowed Operators (based on MA_DS_Field_Type_To_Operators_Mapping custom metadata)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled public Map<String, List<String>> allowedOperatorsMap {
        get {
            if(allowedOperatorsMap == null) {
                allowedOperatorsMap = new Map<String, List<String>>();
            }
            return allowedOperatorsMap;
        }set;
    }
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the Map of sObjectType to fieldApiName key to FieldWapper type, containing Fields for Rules Criteria.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled public Map<String, Map<String, FieldWrapper>> auditFlagsFieldMap {
        get {
            if(auditFlagsFieldMap == null) {
                auditFlagsFieldMap = new Map<String, Map<String, FieldWrapper>>();
            }
            return auditFlagsFieldMap;
        }set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the Map of sObjectType to fieldApiName key to FieldWapper type, containing Fields for Audit Flags.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled public Map<String, Map<String, FieldWrapper>> rulesCriteriaFieldMap {
        get {
            if(rulesCriteriaFieldMap == null) {
                rulesCriteriaFieldMap = new Map<String, Map<String, FieldWrapper>>();
            }
            return rulesCriteriaFieldMap;
        }set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold DescribeFieldResult properties, along with Rules Criteria Configuration.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class FieldWrapper {
        @AuraEnabled public String name {get; set;}
        @AuraEnabled public String type {get; set;}
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public String value {get; set;}
        @AuraEnabled public Integer sampleSize {get; set;}
        @AuraEnabled public Map<String, String> picklistOptions {get; set;} // api name / value to label
    }

    @AuraEnabled public RulesCriteriaWrapper rulesCriteriaJSON {get; set;}

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold attributes of Rules Criteria JSON, used to create Rules Criteria Query.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class RulesCriteriaWrapper {
        @AuraEnabled public Map<String, String> fieldValueMap {get; set;} // objApiName + fieldApiName + rowNum to value
        @AuraEnabled public Map<String, Boolean> customLogicMap {get; set;} // objApiName to true if custom rule logic used
        @AuraEnabled public Map<String, String> fieldOperatorMap {get; set;} // objApiName + fieldApiName + rowNum to operator
        @AuraEnabled public Map<String, List<String>> ruleLogicMap {get; set;} // objApiName to list of rule logic - split by (/([()\s])/)
        @AuraEnabled public Map<String, List<FieldWrapper>> fieldRowMap {get; set;} // objApiName to list of FieldWrapper (selected for criteria)
    }
    
    @AuraEnabled public Map<String, Map<String, FieldWrapper>> auditFlagsJSON {get; set;}
}