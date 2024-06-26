/**
 * ******************************************** W-12578108 : RULE ENGINE ********************************************
 * 
 * Controller class of madsApplyRules (LWC Headless Quick Action) to process Applied Rules.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         17/03/2023      Chakshu Malhotra        W-12578108 - Adds controller logic for LWC to process Applied Rules (Package & Template rules).
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public with sharing class MA_DS_ApplyRules {
    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method updates Rules Sync Status to "Syncing Package Rules" / "Syncing Templates Rules" and enqueues job to process Applied Rules.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    recordId 	   	                DESCRIPTION (Data type Id, Package Distribution record Id)
    * @return   ResponseWrapper                 DESCRIPTION (return ResponseWrapper instance)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled
    public static ResponseWrapper applyRules(Id recordId) {
        ResponseWrapper responseWrapper = new ResponseWrapper();

        try {
            responseWrapper.statusMessage = MA_DS_AppliedRulesHelper.processAppliedRules(recordId);
        }catch(MA_DS_AppliedRulesHelper.IneligibleIntegrationStatusException exType) {
            responseWrapper.errorMessage = exType.getMessage();
        }catch(MA_DS_AppliedRulesHelper.IneligibleRulesSyncStatusException exType) {
            responseWrapper.errorMessage = exType.getMessage();
        }catch(MA_DS_AppliedRulesHelper.NoRulesCriteriaQueryException exType) {
            responseWrapper.errorMessage = exType.getMessage();
        }catch(MA_DS_AppliedRulesHelper.IneligibleStatusException exType) {
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
    * Wrapper class to hold Response for the @AuraEnabled methods of MA_DS_ApplyRules class.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class ResponseWrapper {
        @AuraEnabled public Boolean isError {get; set;}
        @AuraEnabled public String errorMessage {get; set;}
        @AuraEnabled public String statusMessage {get; set;}

        public ResponseWrapper() {
            this.isError = false;
            this.errorMessage = null;
            this.statusMessage = null;
        }
    }
}