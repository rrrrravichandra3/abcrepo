/**
 * ******************************************** W-12578110 : RULE ENGINE ********************************************
 * 
 * Abstract Class that implements RuleCriteriaService interface to setup the MA_DS_AddRulesCriteriaWrapper instance.
 * MA_DS_AddRulesCriteriaWrapper instance is set based on the Rule Criteria Config.
 * Processes Rules Wrapper to convert the Rules Criteria JSON to the query string.
 * 
 * Version      Date            Author                  Description
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         07/03/2023      Chakshu Malhotra        W-12578110 - Adds an abstract class to contain the logic to setup MA_DS_AddRulesCriteriaWrapper instance.
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_AbstractRuleCriteriaService implements MA_DS_AddRulesCriteriaConfig.RuleCriteriaService {

    public SObject ruleRecord {get; set;}
    public MA_DS_AddRulesCriteriaWrapper rulesWrapper {get; set;}

    private static final String NUMBER_PATTERN = Label.MA_DS_Number_Pattern;

    private static final String FIELD_TYPE_PICKLIST = Label.MA_DS_Field_Type_Picklist;
    private static final String FIELD_TYPE_REFERENCE = Label.MA_DS_Field_Type_Reference;

    private static final String VALID_STRING_FIELDS = Label.MA_DS_Valid_String_Fields;
    private static final String VALID_AUDIT_FIELD_TYPE = Label.MA_DS_Valid_Audit_Field_Type;
    private static final String IGNORE_FIELDS_DEFAULT_TYPE = Label.MA_DS_Ignore_SObject_Fields_Default_Type;

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the set of String type fields - ["STRING","REFERENCE","PICKLIST","PHONE","EMAIL","TEXTAREA"]
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Set<String> validStringFields {
        get {
            if(validStringFields == null) {
                validStringFields = new Set<String>((List<String>)JSON.deserialize(VALID_STRING_FIELDS, List<String>.class));
            }
            return validStringFields;
        }set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the set of valid field types for Audit Flags - ["BOOLEAN","PICKLIST","STRING","TEXTAREA"]
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Set<String> validAuditFieldTypes {
        get {
            if(validAuditFieldTypes == null) {
                validAuditFieldTypes = new Set<String>((List<String>)JSON.deserialize(VALID_AUDIT_FIELD_TYPE, List<String>.class));
            }
            return validAuditFieldTypes;
        }set;
    }

    protected void initRulesWrapper(Integer maxSampleSize, String noRulesDisplayMessage, Boolean displayAuditFlags, Boolean displayRulesCriteria, String parentSObject, Map<String, String> childRelationshipMap) {
        this.rulesWrapper = new MA_DS_AddRulesCriteriaWrapper();
        this.rulesWrapper.maxSampleSize = maxSampleSize;
        this.rulesWrapper.parentSObject = parentSObject;
        this.rulesWrapper.displayAuditFlags = displayAuditFlags;
        this.rulesWrapper.displayRulesCriteria = displayRulesCriteria;
        this.rulesWrapper.childRelationshipMap = childRelationshipMap;
        this.rulesWrapper.noRulesDisplayMessage = noRulesDisplayMessage;
    }

    public virtual void setRulesCriteriaJSON() {
        this.rulesWrapper.rulesCriteriaJSON = null;
    }

    protected void setRulesCriteriaJSON(String rulesCriteriaJSON) {
        if(this.rulesWrapper.displayRulesCriteria && String.isNotBlank(rulesCriteriaJSON)) {
            try {
                this.rulesWrapper.rulesCriteriaJSON = (MA_DS_AddRulesCriteriaWrapper.RulesCriteriaWrapper)JSON.deserialize(rulesCriteriaJSON, MA_DS_AddRulesCriteriaWrapper.RulesCriteriaWrapper.class);
            }catch(Exception exType) {
                throw new MA_DS_AddRulesCriteriaConfig.RulesCriteriaJSONParseException(ruleRecord.Id, rulesCriteriaJSON);
            }
        }
    }

    public virtual void setAuditFlagsJSON() {
        this.rulesWrapper.auditFlagsJSON = null;
    }

    protected void setAuditFlagsJSON(String auditFlagsJSON) {
        if(this.rulesWrapper.displayAuditFlags && String.isNotBlank(auditFlagsJSON)) {
            try {
                this.rulesWrapper.auditFlagsJSON = (Map<String, Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper>>)JSON.deserialize(auditFlagsJSON, Map<String, Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper>>.class);
            }catch(Exception exType) {
                throw new MA_DS_AddRulesCriteriaConfig.AuditFlagsJSONParseException(ruleRecord.Id, auditFlagsJSON);
            }
        }
    }

    public virtual void setAllowedOperatorsMap() {
        if(this.rulesWrapper.displayRulesCriteria) {
            List<MA_DS_Field_Type_To_Operators_Mapping__mdt> operatorsMapping = [SELECT MA_DS_Field_Type__c, MA_DS_Operators__c
                                                                                 FROM MA_DS_Field_Type_To_Operators_Mapping__mdt];
            this.rulesWrapper.allowedOperatorsMap.putAll(getAllowedOperatorsMap(operatorsMapping));
        }
    }

    private static Map<String, List<String>> getAllowedOperatorsMap(List<MA_DS_Field_Type_To_Operators_Mapping__mdt> operatorsMapping) {
        Map<String, List<String>> allowedOperatorsMap = new Map<String, List<String>>();
        for(MA_DS_Field_Type_To_Operators_Mapping__mdt operatorMapping : operatorsMapping) {
            allowedOperatorsMap.put(operatorMapping.MA_DS_Field_Type__c, getDeserializedOperators(operatorMapping.MA_DS_Operators__c));
        }
        return allowedOperatorsMap;
    }

    private static List<String> getDeserializedOperators(String operators) {
        return (List<String>)JSON.deserialize(operators, List<String>.class);
    }

    public virtual void setFieldMaps(List<String> sObjects) {
        if(this.rulesWrapper.displayAuditFlags || this.rulesWrapper.displayRulesCriteria) {
            Map<String, String> sObjectMap = new Map<String, String>();
            Set<String> ignoredFieldSet = getIgnoredFieldSet(sObjects);

            List<Schema.DescribeSObjectResult> sObjectResults = Schema.describeSObjects(sObjects);

            for(Schema.DescribeSObjectResult sObjectResult : sObjectResults) {
                String sObjectName = sObjectResult.getName();
                Map<String, Schema.SObjectField> fieldMap = sObjectResult.fields.getMap();

                for(String fieldKey : sObjectResult.fields.getMap().keySet()) {
                    Schema.DescribeFieldResult fieldResult = fieldMap.get(fieldKey).getDescribe();
                    Boolean isIgnoredField = isIgnoredField(sObjectName, fieldKey, ignoredFieldSet);

                    if(fieldResult.isFilterable() && !isIgnoredField) {
                        setRuleCriteriaField(sObjectName, fieldKey, fieldResult);
                        setAuditFlagField(sObjectName, fieldKey, fieldResult);
                    }
                }
                sObjectMap.put(sObjectName, sObjectResult.getLabel());
            }

            this.rulesWrapper.sObjectMap = sObjectMap;
        }
    }

    private static Set<String> getIgnoredFieldSet(List<String> sObjects) {
        Set<String> sObjectSet = new Set<String>(sObjects);
        Set<String> ignoredFieldSet = new Set<String>();

        List<MA_DS_Ignore_SObject_Fields__mdt> ignoredFields = [SELECT MA_DS_Type__c, MA_DS_SObject_Fields__c
                                                                FROM MA_DS_Ignore_SObject_Fields__mdt
                                                                WHERE MA_DS_Type__c IN :sObjectSet OR
                                                                MA_DS_Type__c = :IGNORE_FIELDS_DEFAULT_TYPE];

        for(MA_DS_Ignore_SObject_Fields__mdt ignoredField : ignoredFields) {
            for(String deserializedIgnoredField : getDeserializedIgnoredFields(ignoredField.MA_DS_SObject_Fields__c.toLowerCase())) {
                ignoredFieldSet.add(ignoredField.MA_DS_Type__c.toLowerCase() + deserializedIgnoredField);
            }
        }

        return ignoredFieldSet;
    }

    private static Set<String> getDeserializedIgnoredFields(String sObjectFields) {
        return new Set<String>((List<String>)JSON.deserialize(sObjectFields, List<String>.class));
    }

    private static Boolean isIgnoredField(String sObjectName, String fieldKey, Set<String> ignoredFieldSet) {
        return ignoredFieldSet.contains(sObjectName.toLowerCase() + fieldKey) || ignoredFieldSet.contains(IGNORE_FIELDS_DEFAULT_TYPE.toLowerCase() + fieldKey);
    }

    private void setRuleCriteriaField(String sObjectName, String fieldKey, Schema.DescribeFieldResult fieldResult) {
        if(this.rulesWrapper.displayRulesCriteria) {
            Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper> fieldWrapperMap = getRuleFieldWrapperMap(sObjectName);
            MA_DS_AddRulesCriteriaWrapper.FieldWrapper fieldWrapper = getFieldWrapper(true, fieldKey, fieldResult);
            fieldWrapperMap.put(fieldKey, fieldWrapper);

            if(!this.rulesWrapper.rulesCriteriaFieldMap.containsKey(sObjectName)) {
                this.rulesWrapper.rulesCriteriaFieldMap.put(sObjectName, fieldWrapperMap);
            }
        }
    }

    private Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper> getRuleFieldWrapperMap(String sObjectName) {
        Boolean containsSObjectKey = this.rulesWrapper.rulesCriteriaFieldMap.containsKey(sObjectName);
        return containsSObjectKey ? this.rulesWrapper.rulesCriteriaFieldMap.get(sObjectName) : new Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper>();
    }

    private static MA_DS_AddRulesCriteriaWrapper.FieldWrapper getFieldWrapper(Boolean isRuleField, String fieldKey, Schema.DescribeFieldResult fieldResult) {
        return isRuleField ? getRuleFieldWrapper(fieldKey, fieldResult) : getAuditFieldWrapper(fieldKey, fieldResult);
    }

    private static MA_DS_AddRulesCriteriaWrapper.FieldWrapper getRuleFieldWrapper(String fieldKey, Schema.DescribeFieldResult fieldResult) {
        MA_DS_AddRulesCriteriaWrapper.FieldWrapper fieldWrapper = initFieldWrapper(fieldKey, fieldResult);
        if(validStringFields.contains(fieldWrapper.type)) {
            fieldWrapper.picklistOptions = fieldWrapper.type.equalsIgnoreCase(FIELD_TYPE_PICKLIST) ? getPicklistOptions(fieldResult.getPicklistValues()) : null;
        }
        return fieldWrapper;
    }

    private static MA_DS_AddRulesCriteriaWrapper.FieldWrapper initFieldWrapper(String fieldKey, Schema.DescribeFieldResult fieldResult) {
        MA_DS_AddRulesCriteriaWrapper.FieldWrapper fieldWrapper = new MA_DS_AddRulesCriteriaWrapper.FieldWrapper();
        fieldWrapper.value = fieldKey;
        fieldWrapper.type = String.valueOf(fieldResult.getType());
        fieldWrapper.label = String.valueOf(fieldResult.getLabel());
        fieldWrapper.name = getFieldName(fieldWrapper.type, fieldResult);
        return fieldWrapper;
    }

    private static String getFieldName(String fieldType, Schema.DescribeFieldResult fieldResult) {
        return fieldType.equalsIgnoreCase(FIELD_TYPE_REFERENCE) ? fieldResult.getRelationshipName() + '.Name' : String.valueOf(fieldResult.getName());
    }

    private static Map<String, String> getPicklistOptions(List<Schema.PicklistEntry> picklistEntries) {
        Map<String, String> picklistOptions = new Map<String, String>();
        for(Schema.PicklistEntry picklistEntry : picklistEntries) {
            picklistOptions.put(picklistEntry.getValue(), picklistEntry.getLabel());
        }
        return picklistOptions;
    }

    private void setAuditFlagField(String sObjectName, String fieldKey, Schema.DescribeFieldResult fieldResult) {
        if(this.rulesWrapper.displayAuditFlags) {
            Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper> fieldWrapperMap = getAuditFieldWrapperMap(sObjectName);
            MA_DS_AddRulesCriteriaWrapper.FieldWrapper fieldWrapper = getFieldWrapper(false, fieldKey, fieldResult);

            if(fieldWrapper != null) {
                fieldWrapper.sampleSize = 0;
                fieldWrapperMap.put(fieldKey, fieldWrapper);
            }

            if(!this.rulesWrapper.auditFlagsFieldMap.containsKey(sObjectName)) {
                this.rulesWrapper.auditFlagsFieldMap.put(sObjectName, fieldWrapperMap);
            }
        }
    }

    private Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper> getAuditFieldWrapperMap(String sObjectName) {
        Boolean containsSObjectKey = this.rulesWrapper.auditFlagsFieldMap.containsKey(sObjectName);
        return containsSObjectKey ? this.rulesWrapper.auditFlagsFieldMap.get(sObjectName) : new Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper>();
    }

    private static MA_DS_AddRulesCriteriaWrapper.FieldWrapper getAuditFieldWrapper(String fieldKey, Schema.DescribeFieldResult fieldResult) {
        return validAuditFieldTypes.contains(String.valueOf(fieldResult.getType())) ? initFieldWrapper(fieldKey, fieldResult) : null;
    }

    public virtual MA_DS_AddRulesCriteriaWrapper getRulesWrapper() {
        return this.rulesWrapper;
    }

    protected String getSerializedQueryWrapper(MA_DS_AddRulesCriteriaWrapper rulesWrapper) {
        Set<String> parenthesisSet = new Set<String> {'(', ')'};
        Set<String> logicalOperatorSet = new Set<String> {'AND', 'OR'};

        MA_DS_AddRulesCriteriaWrapper.RulesCriteriaWrapper rulesCriteriaJSON = rulesWrapper.rulesCriteriaJSON;

        for(String sObjectName : getSortedKeys(rulesCriteriaJSON.ruleLogicMap.keySet())) {
            List<MA_DS_AddRulesCriteriaWrapper.FieldWrapper> sObjectFieldRows = rulesCriteriaJSON.fieldRowMap.get(sObjectName);

            for(String ruleLogic : rulesCriteriaJSON.ruleLogicMap.get(sObjectName)) {
                if(parenthesisSet.contains(ruleLogic)) {
                    MA_DS_RulesCriteriaQueryConverter.instance.addParenthesisToQueryCriteria(sObjectName, ruleLogic);
                }else if(logicalOperatorSet.contains(ruleLogic)) {
                    MA_DS_RulesCriteriaQueryConverter.instance.addLogicalOperatorToQueryCriteria(sObjectName, ruleLogic);
                }else if(Pattern.compile(NUMBER_PATTERN).matcher(ruleLogic).find()) {
                    addFieldToQueryCriteria(sObjectName, ruleLogic, sObjectFieldRows, rulesCriteriaJSON);
                }
            }
        }

        String serializedQueryWrapper = MA_DS_RulesCriteriaQueryConverter.instance.getSerializedQueryWrapper(rulesWrapper.parentSObject, rulesWrapper.childRelationshipMap);
        resetQueryConverterInstance(); // to support rules generation process for multiple records at the same time
        
        return serializedQueryWrapper;
    }

    private static List<String> getSortedKeys(Set<String> keySet) {
        List<String> keyList = new List<String>(keySet);
        keyList.sort();
        return keyList;
    }

    private static void addFieldToQueryCriteria(String sObjectName, String ruleLogic, List<MA_DS_AddRulesCriteriaWrapper.FieldWrapper> sObjectFieldRows, MA_DS_AddRulesCriteriaWrapper.RulesCriteriaWrapper rulesCriteriaJSON) {
        Integer rowNum = Integer.valueOf(ruleLogic);
        String fieldType = sObjectFieldRows[rowNum - 1].type;
        String fieldkey = sObjectFieldRows[rowNum - 1].value;
        String fieldName = sObjectFieldRows[rowNum - 1].name;
        String concatenatedId = sObjectName + fieldkey + rowNum;
        String fieldValue = rulesCriteriaJSON.fieldValueMap.get(concatenatedId);
        String fieldOperator = rulesCriteriaJSON.fieldOperatorMap.get(concatenatedId);
        MA_DS_RulesCriteriaQueryConverter.instance.addFieldToQueryCriteria(sObjectName, fieldName, fieldType, fieldOperator, fieldValue);

    }

    private static void resetQueryConverterInstance() {
        MA_DS_RulesCriteriaQueryConverter.instance = null;
    }

    protected String getSerializedAuditFlagsJSON(Map<String, Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper>> auditFlagsJSON) {
        Map<String, Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper>> sortedAuditFlagsJSON = getSortedAuditFlagsJSON(auditFlagsJSON);
        return (sortedAuditFlagsJSON.size() > 0) ? JSON.serialize(sortedAuditFlagsJSON, true) : null;
    }

    private static Map<String, Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper>> getSortedAuditFlagsJSON(Map<String, Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper>> auditFlagsJSON) {
        Map<String, Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper>> sortedAuditFlagsJSON = new Map<String, Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper>>();

        for(String sObjectKey : getSortedKeys(auditFlagsJSON.keySet())) {
            Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper> fieldWrapperMap = auditFlagsJSON.get(sObjectKey);
            Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper> sortedFieldWrapperMap = new Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper>();
            
            for(String fieldKey : getSortedKeys(fieldWrapperMap.keySet())) {
                sortedFieldWrapperMap.put(fieldKey, fieldWrapperMap.get(fieldKey));
            }

            if(sortedFieldWrapperMap.size() > 0) {
                sortedAuditFlagsJSON.put(sObjectKey, sortedFieldWrapperMap);
            }
        }

        return sortedAuditFlagsJSON;
    }

    protected String getSerializedRulesCriteriaJSON(MA_DS_AddRulesCriteriaWrapper.RulesCriteriaWrapper rulesCriteriaJSON) {
        return JSON.serialize(rulesCriteriaJSON, true);
    }

    protected abstract void setRuleRecord(Id recordId);
    protected abstract void processRules(MA_DS_AddRulesCriteriaWrapper rulesWrapper);
    protected abstract void setRulesWrapper(Integer maxSampleSize, String parentSObject, Map<String, String> childRelationshipMap);
}