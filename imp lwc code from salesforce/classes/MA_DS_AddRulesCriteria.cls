/**
 * ******************************************** W-12578110 : RULE ENGINE ********************************************
 * 
 * Controller class of madsAddRulesCriteria (LWC component) to save Rules Criteria & Audit Flags.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         10/03/2023      Chakshu Malhotra        W-12578110 - Adds controller logic for LWC to save Rules Criteria & Audit Flags.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public with sharing class MA_DS_AddRulesCriteria {
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch MA_DS_AddRulesCriteriaWrapper type to populate Rules Criteria & Audit Flags in the component.
    * Method gets the Rule Criteria Config based on the sObjectType and initialize the the MA_DS_AddRulesCriteriaWrapper.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    recordId	 	                DESCRIPTION (Data Type Id, Record Id from the Record Detail Page of the sObject where the component is added)
    * @param    sObjectType	 	                DESCRIPTION (Data Type String, Object API Name of the sObject from the Record Detail Page of the sObject)
    * @return   ResponseWrapper                 DESCRIPTION (return ResponseWrapper instance)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled
    public static ResponseWrapper getRulesWrapper(Id recordId, String sObjectType) {
        ResponseWrapper responseWrapper = new ResponseWrapper();
        try {
            responseWrapper.rulesWrapper = MA_DS_AddRulesCriteriaConfig.strategyInstance.setRuleCriteriaConfig(sObjectType)
                                                                                        .setRuleRecord(recordId)
                                                                                        .setRulesWrapper()
                                                                                        .getRulesWrapper();
        }catch(MA_DS_AddRulesCriteriaConfig.AuditFlagsJSONParseException exType) {
            responseWrapper.errorMessage = exType.getMessage();
        }catch(MA_DS_AddRulesCriteriaConfig.RulesCriteriaJSONParseException exType) {
            responseWrapper.errorMessage = exType.getMessage();
        }catch(MA_DS_AddRulesCriteriaConfig.UnknownRuleCriteriaConfigException exType) {
            responseWrapper.errorMessage = exType.getMessage();
        }catch(Exception exType) {
            throw new AuraHandledException(exType.getMessage());
        }

        if(String.isNotBlank(responseWrapper.errorMessage)) {
            responseWrapper.isError = true;
        }

        return responseWrapper;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to process Rules Criteria & Audit Flags. Gets the Rules Criteria Config and converts Rules Criteria JSON to Rules Crteria Query.
    * Stores the Rules Criteria JSON / Audit Flags JSON / Rules Criteria Query in the sObject record.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    recordId	 	        DESCRIPTION (Data Type Id, Record Id from the Record Detail Page of the sObject where the component is added)
    * @param    sObjectType	 	        DESCRIPTION (Data Type String, Object API Name of the sObject from the Record Detail Page of the sObject)
    * @param    rulesWrapper	 	    DESCRIPTION (Data Type MA_DS_AddRulesCriteriaWrapper, Rules Wrapper containing Rules Criteria JSON & Audit Flags JSON)
    * @return   ResponseWrapper                 DESCRIPTION (return ResponseWrapper instance)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled
    public static ResponseWrapper processRules(Id recordId, String sObjectType, MA_DS_AddRulesCriteriaWrapper rulesWrapper) {
        ResponseWrapper responseWrapper = new ResponseWrapper();

        try {
            MA_DS_AddRulesCriteriaConfig.strategyInstance.setRuleCriteriaConfig(sObjectType)
                                                         .setRuleRecord(recordId)
                                                         .processRules(rulesWrapper);
        }catch(MA_DS_AddRulesCriteriaConfig.RulesCriteriaUpdateException exType) {
            responseWrapper.errorMessage = exType.getMessage();
        }catch(MA_DS_AddRulesCriteriaConfig.InvalidRulesCriteriaQueryException exType) {
            responseWrapper.errorMessage = exType.getMessage();
        }catch(Exception exType) {
            throw new AuraHandledException(exType.getMessage());
        }

        if(String.isNotBlank(responseWrapper.errorMessage)) {
            responseWrapper.isError = true;
        }

        return responseWrapper;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold Response for the @AuraEnabled methods of MA_DS_AddRulesCriteria class.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class ResponseWrapper {
        @AuraEnabled public Boolean isError {get; set;}
        @AuraEnabled public String errorMessage {get; set;}
        @AuraEnabled public MA_DS_AddRulesCriteriaWrapper rulesWrapper {get; set;}

        public ResponseWrapper() {
            this.isError = false;
            this.errorMessage = null;
            this.rulesWrapper = null;
        }
    }
}