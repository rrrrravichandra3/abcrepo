/**
 * ******************************************** W-12578110 : RULE ENGINE ********************************************
 * 
 * Extends MA_DS_AbstractRuleCriteriaService class to setup the MA_DS_AddRulesCriteriaWrapper instance for the In Use Template.
 * Processes Rules Wrapper to convert the Rules Criteria JSON to the query string.
 * 
 * Version      Date            Author                  Description
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         09/03/2023      Chakshu Malhotra        W-12578110 - Adds logic to setup the MA_DS_AddRulesCriteriaWrapper instance for the In Use Template.
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_TemplateRuleCriteriaService extends MA_DS_AbstractRuleCriteriaService {

    private static final String RULES_SUPPRESSED = Label.MA_DS_Rules_Suppressed_For_In_Use_Template;

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the In Use Template record and set it to the ruleRecord property of the abstract base class.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    recordId	        DESCRIPTION (Data Type Id, In Use Template record Id)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void setRuleRecord(Id recordId) {
        this.ruleRecord = getInUseTemplate(recordId);
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get In Use Template record to setup the MA_DS_AddRulesCriteriaWrapper instance.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    recordId	                    DESCRIPTION (Data Type Id, In Use Template record Id)
    * @return   MA_DS_In_Use_Template__c        DESCRIPTION (return In Use Template record)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static MA_DS_In_Use_Template__c getInUseTemplate(Id recordId) {
        List<MA_DS_In_Use_Template__c> ruleRecordList = [SELECT Id, MA_DS_Audit_All__c, MA_DS_Audit_Flags_JSON__c, MA_DS_Rules_Criteria_JSON__c, MA_DS_Rules_Criteria_Query__c, MA_DS_Audit_Flags_Added__c, MA_DS_Rules_Criteria_Added__c, 
                                                         MA_DS_Suppress_Audit_Flags__c, MA_DS_Suppress_Rules_Criteria__c
                                                         FROM MA_DS_In_Use_Template__c 
                                                         WHERE Id = :recordId];
        return (ruleRecordList.size() > 0) ? ruleRecordList[0] : null;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to setup Rules Wrapper properties to display Rules Criteria / Audit Flags, Parent SObject, Child Relationship Map, etc.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    maxSampleSize	            DESCRIPTION (Data Type Integer, Maximum sample size for the Audit Flags)
    * @param    parentSObject	            DESCRIPTION (Data Type String, Parent SObject Name)
    * @param    childRelationshipMap	    DESCRIPTION (Data Type Map<String, String>, Map of Child SObject to the Relationship Name)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void setRulesWrapper(Integer maxSampleSize, String parentSObject, Map<String, String> childRelationshipMap) {
        MA_DS_In_Use_Template__c ruleRecord = (MA_DS_In_Use_Template__c)super.ruleRecord;

        if(ruleRecord != null) {
            Boolean displayRulesCriteria = !ruleRecord.MA_DS_Suppress_Rules_Criteria__c;
            Boolean displayAuditFlags = !(ruleRecord.MA_DS_Audit_All__c || ruleRecord.MA_DS_Suppress_Audit_Flags__c);
            String noRulesDisplayMessage = (displayAuditFlags || displayRulesCriteria) ? '' : RULES_SUPPRESSED;
            this.initRulesWrapper(maxSampleSize, noRulesDisplayMessage, displayAuditFlags, displayRulesCriteria, parentSObject, childRelationshipMap);
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to set the Rules Criteria JSON in MA_DS_AddRulesCriteriaWrapper instance.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void setRulesCriteriaJSON() {
        super.setRulesCriteriaJSON();
        MA_DS_In_Use_Template__c ruleRecord = (MA_DS_In_Use_Template__c)super.ruleRecord;
        this.setRulesCriteriaJSON(ruleRecord.MA_DS_Rules_Criteria_JSON__c);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to set the Audit Flags JSON in MA_DS_AddRulesCriteriaWrapper instance.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void setAuditFlagsJSON() {
        super.setAuditFlagsJSON();
        MA_DS_In_Use_Template__c ruleRecord = (MA_DS_In_Use_Template__c)super.ruleRecord;
        this.setAuditFlagsJSON(ruleRecord.MA_DS_Audit_Flags_JSON__c);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to process the Rules Wrapper (MA_DS_AddRulesCriteriaWrapper instance), containing the Rules Criteria JSON & the Audit Flags JSON.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    rulesWrapper	    DESCRIPTION (Data Type MA_DS_AddRulesCriteriaWrapper, Rules Wrapper containing Rules Criteria JSON & the Audit Flags JSON)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void processRules(MA_DS_AddRulesCriteriaWrapper rulesWrapper) {
        MA_DS_In_Use_Template__c ruleRecord = (MA_DS_In_Use_Template__c)super.ruleRecord;
        ruleRecord.MA_DS_Rules_Criteria_Query__c = (rulesWrapper.rulesCriteriaJSON != null) ? super.getSerializedQueryWrapper(rulesWrapper) : null;
        ruleRecord.MA_DS_Audit_Flags_JSON__c = (rulesWrapper.auditFlagsJSON != null) ? super.getSerializedAuditFlagsJSON(rulesWrapper.auditFlagsJSON) : null;
        ruleRecord.MA_DS_Rules_Criteria_JSON__c = (rulesWrapper.rulesCriteriaJSON != null) ? super.getSerializedRulesCriteriaJSON(rulesWrapper.rulesCriteriaJSON) : null;
        ruleRecord.MA_DS_Audit_Flags_Added__c = (ruleRecord.MA_DS_Audit_Flags_JSON__c != null);
        ruleRecord.MA_DS_Rules_Criteria_Added__c = (ruleRecord.MA_DS_Rules_Criteria_Query__c != null);
        update ruleRecord;
    }
}