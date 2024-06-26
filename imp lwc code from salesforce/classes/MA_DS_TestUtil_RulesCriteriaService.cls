/**
 * Test Utility class to setup Rules (Rules Criteria JSON, Rules Criteria Query & Audit Flags JSON) data.
 * 
 * Version      Date            Author                  Description
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         05/12/2023      Chakshu Malhotra        Adds utility methods to setup Rules (Rules Criteria JSON, Rules Criteria Query & Audit Flags JSON) data.
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
@isTest
public class MA_DS_TestUtil_RulesCriteriaService {

    public enum RulesSObject {IN_USE_TEMPLATE, PACKAGE_DISTRIBUTION}

    private static final String ACQ_CONTACT_SOBJECT = 'Acquisition_Contacts__c';
    private static final String ACQ_COMPENSATION_SOBJECT = 'Acquisition_Compensation__c';

    private static final Map<String, String> CHILD_RELATIONSHIP_MAP = new Map<String, String> {'Acquisition_Compensation__c' => 'Acquisition_Compensation__r'};

    private static final List<MA_DS_In_Use_Template__c> inUseTemplatesWithRules = new List<MA_DS_In_Use_Template__c>();
    private static final List<MA_DS_Package_Distribution__c> packageDistributionsWithRules = new List<MA_DS_Package_Distribution__c>();

    public interface RulesCriteriaGeneratorUtility {
        List<String> getRulesSObjectTypes(MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper);
        List<String> getAuditSObjectTypes(MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper);
        Boolean customLogic(String sObjectType, MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper);
        List<String> ruleLogic(String sObjectType, MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper);
        List<String> ruleFieldOperators(String sObjectType, MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper);
        List<String> ruleFieldTypes(String sObjectType, MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper);
        List<String> ruleFieldValues(String sObjectType, MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper);
        List<String> ruleFieldLabels(String sObjectType, MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper);
        List<String> ruleFieldNames(String sObjectType, MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper);
        List<String> auditFieldNames(String sObjectType, MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper);
        List<String> auditFieldTypes(String sObjectType, MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper);
        List<Integer> auditFieldSampleSizes(String sObjectType, MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper);
        List<String> getRulesSObjectTypes(MA_DS_TestUtil_PackageDistributions.DistributionWrapper distributionWrapper);
        Boolean customLogic(String sObjectType, MA_DS_TestUtil_PackageDistributions.DistributionWrapper distributionWrapper);
        List<String> ruleLogic(String sObjectType, MA_DS_TestUtil_PackageDistributions.DistributionWrapper distributionWrapper);
        List<String> ruleFieldOperators(String sObjectType, MA_DS_TestUtil_PackageDistributions.DistributionWrapper distributionWrapper);
        List<String> ruleFieldTypes(String sObjectType, MA_DS_TestUtil_PackageDistributions.DistributionWrapper distributionWrapper);
        List<String> ruleFieldValues(String sObjectType, MA_DS_TestUtil_PackageDistributions.DistributionWrapper distributionWrapper);
        List<String> ruleFieldLabels(String sObjectType, MA_DS_TestUtil_PackageDistributions.DistributionWrapper distributionWrapper);
        List<String> ruleFieldNames(String sObjectType, MA_DS_TestUtil_PackageDistributions.DistributionWrapper distributionWrapper);
    }

    public static RulesCriteriaGeneratorStrategy getRulesCriteriaGeneratorStrategy(RulesSObject rulesSObjectType, RulesCriteriaGeneratorUtility generatorUtility) {
        return new RulesCriteriaGeneratorStrategy(rulesSObjectType, generatorUtility);
    }

    public static void updateRulesOnSObject(RulesSObject rulesSObjectType, Boolean triggerDisabled) {
        switch on rulesSObjectType {
            when IN_USE_TEMPLATE {
                updateInUseTemplates(triggerDisabled);
            }when PACKAGE_DISTRIBUTION {
                updatePackageDistributions(triggerDisabled);
            }
        }
    }

    private static void updateInUseTemplates(Boolean triggerDisabled) {
        MA_DS_InUseTemplateTriggerHandler.triggerDisabled = triggerDisabled;
        update inUseTemplatesWithRules;
        MA_DS_InUseTemplateTriggerHandler.triggerDisabled = false;
    }

    private static void updatePackageDistributions(Boolean triggerDisabled) {
        MA_DS_PackageDistributionTriggerHandler.triggerDisabled = triggerDisabled;
        update packageDistributionsWithRules;
        MA_DS_PackageDistributionTriggerHandler.triggerDisabled = false;
    }

    public class RulesCriteriaGeneratorStrategy {
        private RulesSObject rulesSObjectType;
        private RulesCriteriaGeneratorUtility generatorUtility;

        private MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper;
        private MA_DS_TestUtil_PackageDistributions.DistributionWrapper distributionWrapper;

        private RulesCriteriaGenerator rulesCriteriaGenerator;
        private MA_DS_AddRulesCriteriaConfig.RuleCriteriaService ruleCriteriaService;

        public RulesCriteriaGeneratorStrategy(RulesSObject rulesSObjectType, RulesCriteriaGeneratorUtility generatorUtility) {
            this.rulesSObjectType = rulesSObjectType;
            this.generatorUtility = generatorUtility;
        }

        public RulesCriteriaGeneratorStrategy initRulesCriteriaGenerator(MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper) {
            this.templateWrapper = templateWrapper;
            this.rulesCriteriaGenerator = new RulesCriteriaGenerator();
            return this;
        }

        public RulesCriteriaGeneratorStrategy initRulesCriteriaGenerator(MA_DS_TestUtil_PackageDistributions.DistributionWrapper distributionWrapper) {
            this.distributionWrapper = distributionWrapper;
            this.rulesCriteriaGenerator = new RulesCriteriaGenerator();
            return this;
        }

        public RulesCriteriaGeneratorStrategy initRulesCriteriaService() {
            Type rulesCriteriaServiceType;

            switch on this.rulesSObjectType {
                when IN_USE_TEMPLATE {
                    rulesCriteriaServiceType = TemplateRuleCriteriaService.class;
                }when PACKAGE_DISTRIBUTION {
                    rulesCriteriaServiceType = DistributionRuleCriteriaService.class;
                }
            }

            this.ruleCriteriaService = (MA_DS_AddRulesCriteriaConfig.RuleCriteriaService)rulesCriteriaServiceType.newInstance();
            return this;
        }
        
        public void generateRulesCriteria(Id srcRecordId) {
            this.ruleCriteriaService.setRuleRecord(srcRecordId);
            this.ruleCriteriaService.processRules(this.getRulesCriteriaWrapper());
        }

        public MA_DS_AddRulesCriteriaWrapper getRulesCriteriaWrapper() {
            MA_DS_AddRulesCriteriaWrapper rulesWrapper = new MA_DS_AddRulesCriteriaWrapper();
            rulesWrapper.parentSObject = ACQ_CONTACT_SOBJECT;
            rulesWrapper.childRelationshipMap = CHILD_RELATIONSHIP_MAP;
            
            switch on this.rulesSObjectType {
                when IN_USE_TEMPLATE {
                    rulesWrapper.auditFlagsJSON = this.rulesCriteriaGenerator.getAuditFlagsJSON(templateWrapper, generatorUtility);
                    rulesWrapper.rulesCriteriaJSON = this.rulesCriteriaGenerator.getRulesCriteriaJSON(templateWrapper, generatorUtility);
                }when PACKAGE_DISTRIBUTION {
                    rulesWrapper.rulesCriteriaJSON = this.rulesCriteriaGenerator.getRulesCriteriaJSON(distributionWrapper, generatorUtility);
                }
            }

            return rulesWrapper;
        }
    }

    private class RulesCriteriaGenerator {
        public MA_DS_AddRulesCriteriaWrapper.RulesCriteriaWrapper getRulesCriteriaJSON(MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper, RulesCriteriaGeneratorUtility generatorUtility) {
            MA_DS_AddRulesCriteriaWrapper.RulesCriteriaWrapper rulesCriteriaJSON = this.getRulesCriteriaJSON();
            List<String> sObjectTypes = generatorUtility.getRulesSObjectTypes(templateWrapper);

            for(String sObjectType : sObjectTypes) {
                this.updateRuleLogicMap(rulesCriteriaJSON.ruleLogicMap, sObjectType, generatorUtility.ruleLogic(sObjectType, templateWrapper));
                this.updateCustomLogicMap(rulesCriteriaJSON.customLogicMap, sObjectType, generatorUtility.customLogic(sObjectType, templateWrapper));
                this.updateFieldValueMap(rulesCriteriaJSON.fieldValueMap, sObjectType, generatorUtility.ruleFieldNames(sObjectType, templateWrapper), generatorUtility.ruleFieldValues(sObjectType, templateWrapper));
                this.updateFieldOperatorMap(rulesCriteriaJSON.fieldOperatorMap, sObjectType, generatorUtility.ruleFieldNames(sObjectType, templateWrapper), generatorUtility.ruleFieldOperators(sObjectType, templateWrapper));
                this.updateFieldRowMap(rulesCriteriaJSON.fieldRowMap, sObjectType, generatorUtility.ruleFieldLabels(sObjectType, templateWrapper), generatorUtility.ruleFieldNames(sObjectType, templateWrapper), generatorUtility.ruleFieldTypes(sObjectType, templateWrapper));
            }

            return rulesCriteriaJSON;
        }

        public MA_DS_AddRulesCriteriaWrapper.RulesCriteriaWrapper getRulesCriteriaJSON(MA_DS_TestUtil_PackageDistributions.DistributionWrapper distributionWrapper, RulesCriteriaGeneratorUtility generatorUtility) {
            MA_DS_AddRulesCriteriaWrapper.RulesCriteriaWrapper rulesCriteriaJSON = this.getRulesCriteriaJSON();
            List<String> sObjectTypes = generatorUtility.getRulesSObjectTypes(distributionWrapper);

            for(String sObjectType : sObjectTypes) {
                this.updateRuleLogicMap(rulesCriteriaJSON.ruleLogicMap, sObjectType, generatorUtility.ruleLogic(sObjectType, distributionWrapper));
                this.updateCustomLogicMap(rulesCriteriaJSON.customLogicMap, sObjectType, generatorUtility.customLogic(sObjectType, distributionWrapper));
                this.updateFieldValueMap(rulesCriteriaJSON.fieldValueMap, sObjectType, generatorUtility.ruleFieldNames(sObjectType, distributionWrapper), generatorUtility.ruleFieldValues(sObjectType, distributionWrapper));
                this.updateFieldOperatorMap(rulesCriteriaJSON.fieldOperatorMap, sObjectType, generatorUtility.ruleFieldNames(sObjectType, distributionWrapper), generatorUtility.ruleFieldOperators(sObjectType, distributionWrapper));
                this.updateFieldRowMap(rulesCriteriaJSON.fieldRowMap, sObjectType, generatorUtility.ruleFieldLabels(sObjectType, distributionWrapper), generatorUtility.ruleFieldNames(sObjectType, distributionWrapper), generatorUtility.ruleFieldTypes(sObjectType, distributionWrapper));
            }

            return rulesCriteriaJSON;
        }
        
        private MA_DS_AddRulesCriteriaWrapper.RulesCriteriaWrapper getRulesCriteriaJSON() {
            MA_DS_AddRulesCriteriaWrapper.RulesCriteriaWrapper rulesCriteriaJSON = new MA_DS_AddRulesCriteriaWrapper.RulesCriteriaWrapper();
            rulesCriteriaJSON.fieldValueMap = new Map<String, String>();
            rulesCriteriaJSON.fieldOperatorMap = new Map<String, String>();
            rulesCriteriaJSON.customLogicMap = new Map<String, Boolean> {ACQ_CONTACT_SOBJECT => false, ACQ_COMPENSATION_SOBJECT => false};
            rulesCriteriaJSON.ruleLogicMap = new Map<String, List<String>> {ACQ_CONTACT_SOBJECT => new List<String>(), ACQ_COMPENSATION_SOBJECT => new List<String>()};
            rulesCriteriaJSON.fieldRowMap = new Map<String, List<MA_DS_AddRulesCriteriaWrapper.FieldWrapper>> {ACQ_CONTACT_SOBJECT => new List<MA_DS_AddRulesCriteriaWrapper.FieldWrapper>(), ACQ_COMPENSATION_SOBJECT => new List<MA_DS_AddRulesCriteriaWrapper.FieldWrapper>()};
            return rulesCriteriaJSON;
        }

        private void updateRuleLogicMap(Map<String, List<String>> ruleLogicMap, String sObjectType, List<String> sObjectRuleLogic) {
            List<String> ruleLogic = ruleLogicMap.get(sObjectType);
            ruleLogic.addAll(sObjectRuleLogic);
        }

        private void updateFieldValueMap(Map<String, String> fieldValueMap, String sObjectType, List<String> fieldAPINames, List<Object> fieldValues) {
            for(Integer fieldNum=1; fieldNum <= fieldAPINames.size(); fieldNum++) {
                String fieldValueMapKey = sObjectType + fieldAPINames[fieldNum - 1].toLowerCase() + fieldNum;
                fieldValueMap.put(fieldValueMapKey, String.valueOf(fieldValues[fieldNum - 1]));
            }
        }

        private void updateFieldValueMap(Map<String, String> fieldValueMap, String sObjectType, List<String> fieldAPINames, List<String> fieldValues) {
            for(Integer fieldNum=1; fieldNum <= fieldAPINames.size(); fieldNum++) {
                String fieldValueMapKey = sObjectType + fieldAPINames[fieldNum - 1].toLowerCase() + fieldNum;
                fieldValueMap.put(fieldValueMapKey, String.valueOf(fieldValues[fieldNum - 1]));
            }
        }

        private void updateFieldRowMap(Map<String, List<MA_DS_AddRulesCriteriaWrapper.FieldWrapper>> fieldRowMap, String sObjectType, List<String> fieldLabels, List<String> fieldAPINames, List<String> fieldTypes) {
            List<MA_DS_AddRulesCriteriaWrapper.FieldWrapper> fieldWrapperList = fieldRowMap.get(sObjectType);
            
            for(Integer fieldNum=1; fieldNum <= fieldAPINames.size(); fieldNum++) {
                MA_DS_AddRulesCriteriaWrapper.FieldWrapper fieldWrapper = new MA_DS_AddRulesCriteriaWrapper.FieldWrapper();
                fieldWrapper.type = fieldTypes[fieldNum - 1];
                fieldWrapper.label = fieldLabels[fieldNum - 1];
                fieldWrapper.name = fieldAPINames[fieldNum - 1];
                fieldWrapper.value = fieldWrapper.name.toLowerCase();
                fieldWrapperList.add(fieldWrapper);
            }
        }

        private void updateFieldOperatorMap(Map<String, String> fieldOperatorMap, String sObjectType, List<String> fieldAPINames, List<String> operators) {
            for(Integer fieldNum=1; fieldNum <= fieldAPINames.size(); fieldNum++) {
                String fieldOperatorMapKey = sObjectType + fieldAPINames[fieldNum - 1].toLowerCase() + fieldNum;
                fieldOperatorMap.put(fieldOperatorMapKey, operators[fieldNum - 1]);
            }
        }

        private void updateCustomLogicMap(Map<String, Boolean> customLogicMap, String sObjectType, Boolean customLogic) {
            customLogicMap.put(sObjectType, customLogic);
        }

        public Map<String, Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper>> getAuditFlagsJSON(MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper, RulesCriteriaGeneratorUtility generatorUtility) {
            Map<String, Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper>> auditFlagsJSON = this.getAuditFlagsJSON();
            List<String> sObjectTypes = generatorUtility.getAuditSObjectTypes(templateWrapper);

            for(String sObjectType : sObjectTypes) {
                this.updateAuditFlagsJSON(auditFlagsJSON, sObjectType, generatorUtility.auditFieldNames(sObjectType, templateWrapper), generatorUtility.auditFieldTypes(sObjectType, templateWrapper), generatorUtility.auditFieldSampleSizes(sObjectType, templateWrapper));
            }
            
            return auditFlagsJSON;
        }

        private Map<String, Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper>> getAuditFlagsJSON() {
            Map<String, Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper>> auditFlagsJSON = new Map<String, Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper>>();
            auditFlagsJSON.put(ACQ_CONTACT_SOBJECT, new Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper>());
            auditFlagsJSON.put(ACQ_COMPENSATION_SOBJECT, new Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper>());
            return auditFlagsJSON;
        }

        private void updateAuditFlagsJSON(Map<String, Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper>> auditFlagsJSON, String sObjectType, List<String> fieldAPINames, List<String> fieldTypes, List<Integer> fieldSampleSizes) {
            Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper> fieldWrapperMap = auditFlagsJSON.get(sObjectType);
            
            for(Integer fieldNum=1; fieldNum <= fieldAPINames.size(); fieldNum++) {
                MA_DS_AddRulesCriteriaWrapper.FieldWrapper fieldWrapper = new MA_DS_AddRulesCriteriaWrapper.FieldWrapper();
                fieldWrapper.type = fieldTypes[fieldNum - 1];
                fieldWrapper.sampleSize = fieldSampleSizes[fieldNum - 1];

                String fieldWrapperMapKey = fieldAPINames[fieldNum - 1].toLowerCase();
                fieldWrapperMap.put(fieldWrapperMapKey, fieldWrapper);
            }
        }
    }

    private class TemplateRuleCriteriaService extends MA_DS_AbstractRuleCriteriaService {
        public override void setRuleRecord(Id recordId) {
            this.ruleRecord = new MA_DS_In_Use_Template__c(Id = recordId);
        }

        public override void setRulesWrapper(Integer maxSampleSize, String parentSObject, Map<String, String> childRelationshipMap) {}

        public override void processRules(MA_DS_AddRulesCriteriaWrapper rulesWrapper) {
            MA_DS_In_Use_Template__c ruleRecord = (MA_DS_In_Use_Template__c)super.ruleRecord;
            ruleRecord.MA_DS_Rules_Criteria_Query__c = (rulesWrapper.rulesCriteriaJSON.fieldValueMap.size() > 0) ? super.getSerializedQueryWrapper(rulesWrapper) : null;
            ruleRecord.MA_DS_Audit_Flags_JSON__c = (rulesWrapper.auditFlagsJSON != null) ? super.getSerializedAuditFlagsJSON(rulesWrapper.auditFlagsJSON) : null;
            ruleRecord.MA_DS_Rules_Criteria_JSON__c = (rulesWrapper.rulesCriteriaJSON.fieldValueMap.size() > 0) ? super.getSerializedRulesCriteriaJSON(rulesWrapper.rulesCriteriaJSON) : null;
            ruleRecord.MA_DS_Audit_Flags_Added__c = (ruleRecord.MA_DS_Audit_Flags_JSON__c != null);
            ruleRecord.MA_DS_Rules_Criteria_Added__c = (ruleRecord.MA_DS_Rules_Criteria_Query__c != null);
            MA_DS_TestUtil_RulesCriteriaService.inUseTemplatesWithRules.add(ruleRecord);
        }
    }

    private class DistributionRuleCriteriaService extends MA_DS_AbstractRuleCriteriaService {
        public override void setRuleRecord(Id recordId) {
            this.ruleRecord = new MA_DS_Package_Distribution__c(Id = recordId);
        }

        public override void setRulesWrapper(Integer maxSampleSize, String parentSObject, Map<String, String> childRelationshipMap) {}

        public override void processRules(MA_DS_AddRulesCriteriaWrapper rulesWrapper) {
            MA_DS_Package_Distribution__c ruleRecord = (MA_DS_Package_Distribution__c)super.ruleRecord;
            ruleRecord.MA_DS_Rules_Criteria_Query__c = (rulesWrapper.rulesCriteriaJSON.fieldValueMap.size() > 0) ? super.getSerializedQueryWrapper(rulesWrapper) : null;
            ruleRecord.MA_DS_Rules_Criteria_JSON__c = (rulesWrapper.rulesCriteriaJSON.fieldValueMap.size() > 0) ? super.getSerializedRulesCriteriaJSON(rulesWrapper.rulesCriteriaJSON) : null;
            MA_DS_TestUtil_RulesCriteriaService.packageDistributionsWithRules.add(ruleRecord);
        }
    }
}