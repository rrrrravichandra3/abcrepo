/**
 * ******************************************** W-12578108 : RULE ENGINE ********************************************
 * 
 * Abstract Wrapper class to hold JobParams, used while processing Applied Rules of type Package Distribution & In Use Template.
 * Holds JobParams type used while Purging Applied Rules.
 * Holds JobParams type used while setting "Manager Summary Rule Applied" & "Package Rule Applied" checks on Applied Rule records.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         18/03/2023      Chakshu Malhotra        W-12578108 - Adds logic to hold JobParams, used while processing Applied Rules of type Package Distribution & In Use Template.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_AppliedRulesWrapper {

    @TestVisible private static final Integer PACKAGE_RULE_MAX_QUERY_COUNT = 10;
    @TestVisible private static final Integer PACKAGE_RULE_QUERY_SIZE_LIMIT = 200;

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold serialized state of properties used while upserting Package Distribution type Applied Rules across recursively instantiated queueable jobs.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class PackageAppliedRuleParams implements MA_DS_AppliedRulesService.JobParams {
        public Integer maxQueryCount = PACKAGE_RULE_MAX_QUERY_COUNT;
        public Integer querySizeLimit = PACKAGE_RULE_QUERY_SIZE_LIMIT;
        
        public Id lastRecordId {get; set;}
        
        public Id pkgId {get; set;}
        public Id acqCompanyId {get; set;}
        public Id pkgDistributionId {get; set;}
        public String parentSObject {get; set;}

        public MA_DS_AppliedRulesService.ExecutionJob originExecJob {get; set;}  // originExecJob will help in deciding what to update in Status field 
        public MA_DS_AppliedRulesService.ExecutionMode originExecMode {get; set;}
        public MA_DS_RulesCriteriaQueryParser.QueryWrapper rulesQueryWrapper {get; set;}

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of AsyncApexJob Ids that processed all Package Distribution type Applied Rules.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Set<Id> asyncApexJobIds {
            get {
                if(asyncApexJobIds == null) {
                    asyncApexJobIds = new Set<Id>();
                }
                return asyncApexJobIds;
            }set;
        }
    }

    private static final Integer DEFAULT_LAST_IUT_INDEX = -1;
    private static final Integer DEFAULT_CURRENT_IUT_INDEX = 0;
    @TestVisible private static final Integer TEMPLATE_RULE_MAX_QUERY_COUNT = 10;
    @TestVisible private static final Integer TEMPLATE_RULE_QUERY_SIZE_LIMIT = 50;

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold serialized state of properties used while upserting In Use Template type Applied Rules across recursively instantiated queueable jobs.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class TemplateAppliedRuleParams implements MA_DS_AppliedRulesService.JobParams {
        public Integer lastIUTIndex = DEFAULT_LAST_IUT_INDEX;
        public Integer currentIUTIndex = DEFAULT_CURRENT_IUT_INDEX;
        public Integer maxQueryCount = TEMPLATE_RULE_MAX_QUERY_COUNT;
        public Integer querySizeLimit = TEMPLATE_RULE_QUERY_SIZE_LIMIT;

        public Boolean summaryDocRuleSync = false;
        public Boolean packageDocRuleSync = false;

        public Id lastRecordId {get; set;}

        public Id pkgId {get; set;}
        public Id acqCompanyId {get; set;}
        public Id pkgDistributionId {get; set;}
        
        public Boolean auditAll {get; set;}
        public String parentSObject {get; set;}
        public String templateDocumentType {get; set;}

        public MA_DS_AppliedRulesService.ExecutionJob originExecJob {get; set;}
        public MA_DS_AppliedRulesService.ExecutionMode originExecMode {get; set;}
        public MA_DS_RulesCriteriaQueryParser.QueryWrapper rulesQueryWrapper {get; set;}

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of AsyncApexJob Ids that processed all Package Distribution type Applied Rules.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Set<Id> packageRulesAsyncApexJobIds {
            get {
                if(packageRulesAsyncApexJobIds == null) {
                    packageRulesAsyncApexJobIds = new Set<Id>();
                }
                return packageRulesAsyncApexJobIds;
            }set;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of all eligible Derived Template Ids that need to be processed for Applying Rules.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public List<Id> templateIds {
            get {
                if(templateIds == null) {
                    templateIds = new List<Id>();
                }
                return templateIds;
            }set;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the List of all eligible In Use Template Ids that need to be processed for Applying Rules.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public List<Id> inUseTemplateIds {get; set;}

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Map of Child sObjName to its Relationship Field Name.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Map<String, String> childRelationshipMap {get; set;}

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Map of sObjName (parentSObject / childRelationshipName) to List of Audit Fields.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Map<String, List<String>> auditFlagsFieldMap {
            get {
                if(auditFlagsFieldMap == null) {
                    auditFlagsFieldMap = new Map<String, List<String>>();
                }
                return auditFlagsFieldMap;
            }set;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Map of sObjName (parentSObject / childRelationshipName) + fieldKey => fieldType.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Map<String, String> auditFlagsTypeMap {
            get {
                if(auditFlagsTypeMap == null) {
                    auditFlagsTypeMap = new Map<String, String>();
                }
                return auditFlagsTypeMap;
            }set;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Map of sObjName (parentSObject / childRelationshipName) + fieldKey => sampleSize.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Map<String, Integer> auditFlagsSampleSizeMap {
            get {
                if(auditFlagsSampleSizeMap == null) {
                    auditFlagsSampleSizeMap = new Map<String, Integer>();
                }
                return auditFlagsSampleSizeMap;
            }set;
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Map of auditFieldKey => appliedSampleSize.
        * Added to MA_DS_Applied_Audit_Flags_JSON__c i.e. pkgDistributionId => appliedAuditFlagsMap, at the end of processing each In Use Template for Applied Rules.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Map<String, Integer> appliedAuditFlagsMap {
            get {
                if(appliedAuditFlagsMap == null) {
                    appliedAuditFlagsMap = new Map<String, Integer>();
                }
                return appliedAuditFlagsMap;
            }set;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of AsyncApexJob Ids that processed all In Use Template type Applied Rules.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Set<Id> templateRulesAsyncApexJobIds {
            get {
                if(templateRulesAsyncApexJobIds == null) {
                    templateRulesAsyncApexJobIds = new Set<Id>();
                }
                return templateRulesAsyncApexJobIds;
            }set;
        }
    }

    @TestVisible private static final Integer PURGE_RULE_MAX_QUERY_COUNT = 10;
    @TestVisible private static final Integer PURGE_RULE_QUERY_SIZE_LIMIT = 200;

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold serialized state of properties used while purging unwanted Applied Rules across recursively instantiated queueable jobs.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class PurgeAppliedRuleParams implements MA_DS_AppliedRulesService.JobParams {
        public Integer maxQueryCount = PURGE_RULE_MAX_QUERY_COUNT;
        public Integer querySizeLimit = PURGE_RULE_QUERY_SIZE_LIMIT;

        public Boolean summaryDocRuleSync = false;
        public Boolean packageDocRuleSync = false;

        public Id pkgDistributionId {get; set;}

        public MA_DS_AppliedRulesService.ExecutionJob originExecJob {get; set;}
        public MA_DS_AppliedRulesService.ExecutionMode originExecMode {get; set;}

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the List of all eligible Derived Template Ids that need to be processed for Applying Rules.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public List<Id> templateIds {
            get {
                if(templateIds == null) {
                    templateIds = new List<Id>();
                }
                return templateIds;
            }set;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of AsyncApexJob Ids that processed all Applied Rules.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Set<Id> asyncApexJobIds {
            get {
                if(asyncApexJobIds == null) {
                    asyncApexJobIds = new Set<Id>();
                }
                return asyncApexJobIds;
            }set;
        }
    }

    @TestVisible private static final Integer RULE_APPLIED_MAX_QUERY_COUNT = 10;
    @TestVisible private static Integer RULE_APPLIED_QUERY_SIZE_LIMIT = 200;

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold serialized state of properties used while upserting Rule Applied Flags on Applied Rule records across recursively instantiated queueable jobs.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class RuleAppliedParams implements MA_DS_AppliedRulesService.JobParams {
        public Integer maxQueryCount = RULE_APPLIED_MAX_QUERY_COUNT;
        public Integer querySizeLimit = RULE_APPLIED_QUERY_SIZE_LIMIT;
        
        public Boolean summaryDocRuleSync = false;
        public Boolean packageDocRuleSync = false;

        public Id lastRecordId {get; set;}
        public Id pkgDistributionId {get; set;}

        public MA_DS_AppliedRulesService.ExecutionJob originExecJob {get; set;}
        public MA_DS_AppliedRulesService.ExecutionMode originExecMode {get; set;}
    }
}