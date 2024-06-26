/**
 * ******************************************** W-12578110 : RULE ENGINE ********************************************
 * 
 * Abstract class to setup the Rule Criteria Config, and initialize the RuleCriteriaService class with all the Rules Criteria & Audit Flags details to show on the UI.
 * Exposes singleton instance of RuleStrategy & its methods to dynamically initialize the RuleCriteriaService & setup the MA_DS_AddRulesCriteriaWrapper instance.
 * 
 * Version      Date            Author                  Description
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         07/03/2023      Chakshu Malhotra        W-12578110 - Adds a framework to provide a common strategy to setup MA_DS_AddRulesCriteriaWrapper instance.
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_AddRulesCriteriaConfig {

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to set & hold the final singleton instance of RuleStrategy.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static final RuleStrategy strategyInstance {
        get {
            if(strategyInstance == null) {
                strategyInstance = new RuleStrategy();
            }
            return strategyInstance;
        }private set;
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Strategy class to dynamically inititalize the RuleCriteriaService & setup the MA_DS_AddRulesCriteriaWrapper instance.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class RuleStrategy {
        private Double maxSampleSize;
        private List<String> criteriaSObjects;
        private RuleCriteriaService ruleCriteriaService;
        private MA_DS_Rule_Criteria_Config__mdt criteriaConfig;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Private default constructor of RuleStrategy class to enforce the singleton design.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private RuleStrategy() {
            // to enforce singleton design
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to set and hold the Child Relationship Map from the the Rule Criteria Config.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Map<String, String> childRelationshipMap {
            get {
                if(childRelationshipMap == null) {
                    childRelationshipMap = (this.criteriaConfig != null && this.criteriaConfig.MA_DS_Child_Relationships__c != null) ? 
                                           (Map<String, String>)JSON.deserialize(this.criteriaConfig.MA_DS_Child_Relationships__c, Map<String, String>.class) : new Map<String, String>();
                }
                return childRelationshipMap;
            }set;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the Rule Criteria Config based on the given sObjectType, used by RuleCriteriaService to setup the MA_DS_AddRulesCriteriaWrapper instance.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    sObjectType	    DESCRIPTION (Data Type String, Object API Name of the sObject used, used to fetch the Rule Criteria Config Metadata)
        * @return   RuleStrategy    DESCRIPTION (return RuleStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public RuleStrategy setRuleCriteriaConfig(String sObjectType) {
            List<MA_DS_Rule_Criteria_Config__mdt> configList = this.getRuleCriteriaConfigList(sObjectType);
            this.criteriaConfig = (configList.size() > 0) ? configList[0] : null;
            this.throwExceptionIfUnknownCriteriaConfig(sObjectType);
            return this;
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get the Rule Criteria Config based on the given sObjectType.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    sObjectType	                            DESCRIPTION (Data Type String, Object API Name of the sObject used, used to fetch the Rule Criteria Config Metadata)
        * @return   List<MA_DS_Rule_Criteria_Config__mdt>   DESCRIPTION (return List of MA_DS_Rule_Criteria_Config__mdt)
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private List<MA_DS_Rule_Criteria_Config__mdt> getRuleCriteriaConfigList(String sObjectType) {
            return [SELECT Id, MA_DS_SObject_Type__c, MA_DS_Rule_Criteria_Service__c, MA_DS_Rule_Criteria_SObjects__c, MA_DS_Parent_SObject__c, 
                    MA_DS_Child_Relationships__c, MA_DS_Maximum_Sample_Size__c
                    FROM MA_DS_Rule_Criteria_Config__mdt
                    WHERE MA_DS_SObject_Type__c = :sObjectType];
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Throws UnknownRuleCriteriaConfigException if no Rule Criteria Config found for the given sObjectType.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void throwExceptionIfUnknownCriteriaConfig(String sObjectType) {
            if(this.criteriaConfig == null) {
                UnknownRuleCriteriaConfigException exType = new UnknownRuleCriteriaConfigException(String.format(UNKNOWN_CRITERIA_CONFIG_EXCEPTION, new String[] {sObjectType}));
                MA_AbstractLogger.logException(exType, MA_DS_AddRulesCriteriaConfig.UnknownRuleCriteriaConfigException.class.getName());
                throw exType;
            }
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the sObject record based on the recordId, used by RuleCriteriaService to setup the MA_DS_AddRulesCriteriaWrapper instance.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    recordId	    DESCRIPTION (Data Type Id, Record Id of the sObject where the Rules Criteria Component in added.)
        * @return   RuleStrategy    DESCRIPTION (return RuleStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public RuleStrategy setRuleRecord(Id recordId) {
            if(recordId != null) {
                String criteriaService = this.criteriaConfig.MA_DS_Rule_Criteria_Service__c;
                this.ruleCriteriaService = (RuleCriteriaService)Type.forName(criteriaService).newInstance();
                this.maxSampleSize = (this.criteriaConfig.MA_DS_Maximum_Sample_Size__c == null) ? 0 : this.criteriaConfig.MA_DS_Maximum_Sample_Size__c;
                this.criteriaSObjects = (List<String>)JSON.deserialize(this.criteriaConfig.MA_DS_Rule_Criteria_SObjects__c, List<String>.class);
                this.ruleCriteriaService.setRuleRecord(recordId);
            }
            return this;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to setup the MA_DS_AddRulesCriteriaWrapper instance with all the required details needed to prepare the component.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   RuleStrategy    DESCRIPTION (return RuleStrategy instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public RuleStrategy setRulesWrapper() {
            if(this.ruleCriteriaService != null) {
                Integer maxSampleSize = Integer.valueOf(this.maxSampleSize);
                String parentSObject = this.criteriaConfig.MA_DS_Parent_SObject__c;
                
                this.ruleCriteriaService.setRulesWrapper(maxSampleSize, parentSObject, childRelationshipMap);
                this.ruleCriteriaService.setAuditFlagsJSON();
                this.ruleCriteriaService.setRulesCriteriaJSON();
                this.ruleCriteriaService.setAllowedOperatorsMap();
                this.ruleCriteriaService.setFieldMaps(this.criteriaSObjects);
            }
            return this;
        }
        
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get the MA_DS_AddRulesCriteriaWrapper instance, once setup by the strategy.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   MA_DS_AddRulesCriteriaWrapper    DESCRIPTION (return MA_DS_AddRulesCriteriaWrapper instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public MA_DS_AddRulesCriteriaWrapper getRulesWrapper() {
            return this.ruleCriteriaService.getRulesWrapper();
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to process Rules Criteria & Audit Flags. Gets the Rules Criteria Config and converts Rules Criteria JSON to Rules Crteria Query.
        * Stores the Rules Criteria JSON / Audit Flags JSON / Rules Criteria Query in the sObject record.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    rulesWrapper	    DESCRIPTION (Data Type MA_DS_AddRulesCriteriaWrapper, Rules Wrapper containing Rules Criteria JSON & Audit Flags JSON)
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void processRules(MA_DS_AddRulesCriteriaWrapper rulesWrapper) {
            try {
                this.ruleCriteriaService.processRules(rulesWrapper);
            }catch(DMLException exType) {
                MA_AbstractLogger.logException(exType, RulesCriteriaUpdateException.class.getName());
                throw new RulesCriteriaUpdateException(exType.getMessage());
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Interface to implement different Rule Criteria Services based on the sObjectType of the Rule Criteria Config.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public interface RuleCriteriaService {
        void setAuditFlagsJSON();
        void setRulesCriteriaJSON();
        void setAllowedOperatorsMap();
        void setRuleRecord(Id recordId);
        void setFieldMaps(List<String> sObjects);
        MA_DS_AddRulesCriteriaWrapper getRulesWrapper();
        void processRules(MA_DS_AddRulesCriteriaWrapper rulesWrapper);
        void setRulesWrapper(Integer maxSampleSize, String parentSObject, Map<String, String> childRelationshipMap);
    }

    private static final String STACK_TRACE_KEY = Label.MA_DS_Stack_Trace_Key;
    private static final String AUDIT_FLAGS_JSON = Label.MA_DS_Audit_Flags_JSON;
    private static final String RULES_CRITERIA_JSON = Label.MA_DS_Rules_Criteria_JSON;
    private static final String JSON_PARSE_KEY = Label.MA_DS_JSON_Parse_Exception_Key;
    private static final String RULES_QUERY_KEY = Label.MA_DS_Invalid_Rules_Query_Key;
    private static final String JSON_PARSE_EXCEPTION = Label.MA_DS_JSON_Parse_Exception_Message;
    private static final String RULE_CRITERIA_QUERY_EXCEPTION = Label.MA_DS_Rule_Criteria_Query_Exception;
    private static final String UNKNOWN_CRITERIA_CONFIG_EXCEPTION = Label.MA_DS_Unknown_Criteria_Config_Exception;

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception to override the message for the exception thrown while parsing Audit Flags JSON.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class AuditFlagsJSONParseException extends Exception {
        private Id recordId;
        private String auditFlagsJSON;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the AuditFlagsJSONParseException class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public AuditFlagsJSONParseException(Id recordId, String auditFlagsJSON) {
            this.recordId = recordId;
            this.auditFlagsJSON = auditFlagsJSON;
            MA_AbstractLogger.logException(this, AuditFlagsJSONParseException.class.getName());
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method overrides the getMessage() method of the Exception class to return the custom exception message.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getMessage() {
            return String.format(JSON_PARSE_EXCEPTION, new String[] {AUDIT_FLAGS_JSON, this.recordId});
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method overrides the getStackTraceString() method of the Exception class to return the Stack Trace of the custom exception.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getStackTraceString() {
            Map<String, Object> stackTrace = new Map<String, Object> {JSON_PARSE_KEY => JSON.serialize(this), STACK_TRACE_KEY => super.getStackTraceString()};
            return JSON.serialize(stackTrace);
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception to override the message for the exception thrown while parsing Rules Criteria JSON.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class RulesCriteriaJSONParseException extends Exception {
        private Id recordId;
        private String rulesCriteriaJSON;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the RulesCriteriaJSONParseException class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public RulesCriteriaJSONParseException(Id recordId, String rulesCriteriaJSON) {
            this.recordId = recordId;
            this.rulesCriteriaJSON = rulesCriteriaJSON;
            MA_AbstractLogger.logException(this, RulesCriteriaJSONParseException.class.getName());
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method overrides the getMessage() method of the Exception class to return the custom exception message.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getMessage() {
            return String.format(JSON_PARSE_EXCEPTION, new String[] {RULES_CRITERIA_JSON, this.recordId});
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method overrides the getStackTraceString() method of the Exception class to return the Stack Trace of the custom exception.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getStackTraceString() {
            Map<String, Object> stackTrace = new Map<String, Object> {JSON_PARSE_KEY => JSON.serialize(this), STACK_TRACE_KEY => super.getStackTraceString()};
            return JSON.serialize(stackTrace);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception to override the message for the exception thrown if no Rule Criteria Config is found for the sObjectType.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class UnknownRuleCriteriaConfigException extends Exception {}
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception to override the message for the exception thrown while validating the Rules Citeria Query created from the Rules Criteria JSON.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class InvalidRulesCriteriaQueryException extends Exception {
        private String queryString;
        private Map<String, Object> bindMap;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the InvalidRulesCriteriaQueryException class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public InvalidRulesCriteriaQueryException(String queryString, Map<String, Object> bindMap) {
            this.bindMap = bindMap;
            this.queryString = queryString;
            MA_AbstractLogger.logException(this, InvalidRulesCriteriaQueryException.class.getName());
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method overrides the getMessage() method of the Exception class to return the custom exception message.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getMessage() {
            return UNKNOWN_CRITERIA_CONFIG_EXCEPTION;
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method overrides the getStackTraceString() method of the Exception class to return the Stack Trace of the custom exception.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getStackTraceString() {
            Map<String, Object> stackTrace = new Map<String, Object> {RULES_QUERY_KEY => JSON.serialize(this), STACK_TRACE_KEY => super.getStackTraceString()};
            return JSON.serialize(stackTrace);
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception to be thrown upon handling DMLException while processing Rules Wrapper and saving the Rules Criteria / Audit Flags.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class RulesCriteriaUpdateException extends Exception {}
}