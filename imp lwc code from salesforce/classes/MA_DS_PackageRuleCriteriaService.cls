/**
 * ******************************************** W-12578110 : RULE ENGINE ********************************************
 * 
 * Extends MA_DS_AbstractRuleCriteriaService class to setup the MA_DS_AddRulesCriteriaWrapper instance for the Package Distribution.
 * Processes Rules Wrapper to convert the Rules Criteria JSON to the query string.
 * 
 * Version      Date            Author                  Description
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         08/03/2023      Chakshu Malhotra        W-12578110 - Adds logic to setup the MA_DS_AddRulesCriteriaWrapper instance for the Package Distribution.
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_PackageRuleCriteriaService extends MA_DS_AbstractRuleCriteriaService {

    private static final String INVALID_RULES_STATUS = Label.MA_DS_Invalid_Status_For_Rules;
    private static final String INVALID_RULES_SYNC_STATUS = Label.MA_DS_Invalid_Rules_Sync_Status;
    private static final String SYNCING_PACKAGE_RULES_STATUS = Label.MA_DS_Syncing_Package_Rules_Status;
    private static final String SYNCING_TEMPLATE_RULES_STATUS = Label.MA_DS_Syncing_Templates_Rules_Status;
    private static final String ELIGIBLE_PACKAGE_STATUS = Label.MA_DS_Eligible_Package_Status_For_Rules_Update;

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the set of Rules Sync Status values denoting Syncing of Package or Template Rules.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private Set<String> rulesSyncingStatus {
        get {
            if(rulesSyncingStatus == null) {
                rulesSyncingStatus = new Set<String> {SYNCING_PACKAGE_RULES_STATUS.toLowerCase(), SYNCING_TEMPLATE_RULES_STATUS.toLowerCase()};
            }
            return rulesSyncingStatus;
        }set;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the Package Distribution record and set it to the ruleRecord property of the abstract base class.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    recordId	        DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void setRuleRecord(Id recordId) {
        this.ruleRecord = getPackageDistribution(recordId);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get Package Distribution record to setup the MA_DS_AddRulesCriteriaWrapper instance.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    recordId	                        DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @return   MA_DS_Package_Distribution__c       DESCRIPTION (return Package Distribution record)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static MA_DS_Package_Distribution__c getPackageDistribution(Id recordId) {
        List<MA_DS_Package_Distribution__c> ruleRecordList = [SELECT Id, MA_DS_Status__c, MA_DS_Rules_Sync_Status__c, MA_DS_Rules_Criteria_JSON__c, MA_DS_Rules_Criteria_Query__c
                                                              FROM MA_DS_Package_Distribution__c
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
        MA_DS_Package_Distribution__c ruleRecord = (MA_DS_Package_Distribution__c)super.ruleRecord;

        if(ruleRecord != null) {
            Boolean rulesSyncing = rulesSyncingStatus.contains(ruleRecord.MA_DS_Rules_Sync_Status__c.toLowerCase());
            Boolean displayRulesCriteria = !rulesSyncing && eligiblePackageDistributionStatus(ruleRecord.MA_DS_Status__c);
            String noRulesDisplayMessage = displayRulesCriteria ? '' : getNoRulesDisplayMessage(rulesSyncing, ruleRecord);
            this.initRulesWrapper(maxSampleSize, noRulesDisplayMessage, false, displayRulesCriteria, parentSObject, childRelationshipMap);
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to check if Package Distribution Status is eligible to display the Rules Criteria component.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    status	        DESCRIPTION (Data Type String, Status of the Package Distribution record)
    * @return   Boolean         DESCRIPTION (return True if Status is eligible to display the component)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean eligiblePackageDistributionStatus(String status) {
        Set<String> eligiblePackageStatusSet = new Set<String>((List<String>)JSON.deserialize(ELIGIBLE_PACKAGE_STATUS, List<String>.class));
        return eligiblePackageStatusSet.contains(status);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the noRulesDisplayMessage to display when the component is not eligible to display on the UI.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    rulesSyncing	    DESCRIPTION (Data Type Boolean, True if either Package or Template rules are currently syncing)
    * @param    ruleRecord	        DESCRIPTION (Data Type MA_DS_Package_Distribution__c, Package Distribution record)
    * @return   String              DESCRIPTION (return noRulesDisplayMessage)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getNoRulesDisplayMessage(Boolean rulesSyncing, MA_DS_Package_Distribution__c ruleRecord) {
        String msg = rulesSyncing ? INVALID_RULES_SYNC_STATUS : INVALID_RULES_STATUS;
        String msgParam = rulesSyncing ? ruleRecord.MA_DS_Rules_Sync_Status__c : ruleRecord.MA_DS_Status__c;
        return String.format(msg, new String[] {msgParam});
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
        MA_DS_Package_Distribution__c ruleRecord = (MA_DS_Package_Distribution__c)super.ruleRecord;
        this.setRulesCriteriaJSON(ruleRecord.MA_DS_Rules_Criteria_JSON__c);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to process the Rules Wrapper (MA_DS_AddRulesCriteriaWrapper instance), containing the Rules Criteria JSON.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    rulesWrapper	    DESCRIPTION (Data Type MA_DS_AddRulesCriteriaWrapper, Rules Wrapper containing Rules Criteria JSON)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void processRules(MA_DS_AddRulesCriteriaWrapper rulesWrapper) {
        MA_DS_Package_Distribution__c ruleRecord = (MA_DS_Package_Distribution__c)super.ruleRecord;
        ruleRecord.MA_DS_Rules_Criteria_Query__c = (rulesWrapper.rulesCriteriaJSON != null) ? super.getSerializedQueryWrapper(rulesWrapper) : null;
        ruleRecord.MA_DS_Rules_Criteria_JSON__c = (rulesWrapper.rulesCriteriaJSON != null) ? super.getSerializedRulesCriteriaJSON(rulesWrapper.rulesCriteriaJSON) : null;
        update ruleRecord;
    }
}