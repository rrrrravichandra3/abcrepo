/**
 * ******************************************** W-12578110 : RULE ENGINE ********************************************
 * 
 * Query Converter class to convert Rules Criteria JSON to form the Rules Criteria Query.
 * Query is created based on the rules criteria added on the fields and the rule logic used for all the added criteria.
 * 
 * Version      Date            Author                  Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         10/03/2023      Chakshu Malhotra        W-12578110 - Adds logic to create Rules Criteria Query from the Rules Criteria JSON.
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_RulesCriteriaQueryConverter {

    private static final String DEFAULT_TYPE = Label.MA_DS_Default_Criteria_Operator;
    private static final String PICKLIST_TYPE = Label.MA_DS_Picklist_Criteria_Operator;

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to set & hold the singleton instance of MA_DS_RulesCriteriaQueryConverter.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static MA_DS_RulesCriteriaQueryConverter instance {
        get {
            if(instance == null) {
                instance = new MA_DS_RulesCriteriaQueryConverter();
            }
            return instance;
        }set;
    }

    public Integer bindVariableCount {get; set;}

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Private default constructor of MA_DS_RulesCriteriaQueryConverter class to enforce the singleton design.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private MA_DS_RulesCriteriaQueryConverter() {
        this.bindVariableCount = 1;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the map of sObjectName to the Query Criteria string.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private Map<String, String> queryCriteriaMap {
        get {
            if(queryCriteriaMap == null) {
                queryCriteriaMap = new Map<String, String>();
            }
            return queryCriteriaMap;
        }set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to set & hold the map of operatorKey (Type + Rule Criteria Operator) to the SOQL Query Operator.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private Map<String, String> queryOperatorMap {
        get {
            if(queryOperatorMap == null) {
                queryOperatorMap = new Map<String, String>();
                List<MA_DS_Criteria_To_Query_Operator_Mapping__mdt> operatorsMapping = [SELECT MA_DS_Type__c, MA_DS_Rule_Criteria_Operator__c, MA_DS_SOQL_Query_Operator__c
                                                                                        FROM MA_DS_Criteria_To_Query_Operator_Mapping__mdt];

                for(MA_DS_Criteria_To_Query_Operator_Mapping__mdt operatorMapping : operatorsMapping) {
                    String operatorKey = operatorMapping.MA_DS_Type__c + operatorMapping.MA_DS_Rule_Criteria_Operator__c;
                    queryOperatorMap.put(operatorKey, operatorMapping.MA_DS_SOQL_Query_Operator__c);
                }
            }
            return queryOperatorMap;
        }set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to  hold the bind variable map, to be used in Database.query() method to validate the Rules Critria Query created.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public Map<String, Object> bindMap {
        get {
            if(bindMap == null) {
                bindMap = new Map<String, Object>();
            }
            return bindMap;
        }set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to  hold the map of bind variable to Field Type, to be used while deserializing the bindMap.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public Map<String, String> bindTypeMap {
        get {
            if(bindTypeMap == null) {
                bindTypeMap = new Map<String, String>();
            }
            return bindTypeMap;
        }set;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to add parenthesis string to the criteria query string, for the given sObjectName.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    sObjectName	        DESCRIPTION (Data Type String, Name of sObject)
    * @param    parenthesis	        DESCRIPTION (Data Type String, Opening or Closing parenthesis used in Rule Logic)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void addParenthesisToQueryCriteria(String sObjectName, String parenthesis) {
        Boolean containsSObjectKey = queryCriteriaMap.containsKey(sObjectName);
        String criteriaQuery = containsSObjectKey ? queryCriteriaMap.get(sObjectName) : '';
        criteriaQuery += parenthesis;
        queryCriteriaMap.put(sObjectName, criteriaQuery);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to add logical query operator to the criteria query string, for the given sObjectName.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    sObjectName	        DESCRIPTION (Data Type String, Name of sObject)
    * @param    logicalOperator	    DESCRIPTION (Data Type String, Logical Operator used in Rule Logic)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void addLogicalOperatorToQueryCriteria(String sObjectName, String logicalOperator) {
        String criteriaQuery = queryCriteriaMap.get(sObjectName);
        criteriaQuery += ' ' + logicalOperator + ' ';
        queryCriteriaMap.put(sObjectName, criteriaQuery);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to add field to the criteria query string by formatting the queryOperator with fieldName and fieldValue.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    sObjectName	        DESCRIPTION (Data Type String, Name of sObject)
    * @param    fieldName	        DESCRIPTION (Data Type String, Name of sObject field)
    * @param    fieldType	        DESCRIPTION (Data Type String, Type of sObject field)
    * @param    fieldOperator	    DESCRIPTION (Data Type String, Criteria Operator used for the Rule Criteria added on the sObject field)
    * @param    fieldValue	        DESCRIPTION (Data Type String, Value of sObject field)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void addFieldToQueryCriteria(String sObjectName, String fieldName, String fieldType, String fieldOperator, String fieldValue) {
        Boolean containsSObjectKey = queryCriteriaMap.containsKey(sObjectName);
        String criteriaQuery = containsSObjectKey ? queryCriteriaMap.get(sObjectName) : '';
        String queryOperator = getQueryOperator(fieldType, fieldOperator);
        
        criteriaQuery += MA_DS_RulesCriteriaQueryFormatter.strategy.getFormattedCriteria(fieldName, fieldOperator, queryOperator, fieldValue.trim(), fieldType);
        queryCriteriaMap.put(sObjectName, criteriaQuery);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get Query Operator from the queryOperatorMap based on the queryOperatorKey (Type + Rule Criteria Operator).
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    fieldType	        DESCRIPTION (Data Type String, Type of sObject field)
    * @param    fieldOperator	    DESCRIPTION (Data Type String, Criteria Operator used for the Rule Criteria added on the sObject field)
    * @return   String              DESCRIPTION (return Query Operator string to be formatted with sObject field name & the field value)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private String getQueryOperator(String fieldType, String fieldOperator) {
        String queryOperatorKey = (fieldType.equalsIgnoreCase(PICKLIST_TYPE) ? PICKLIST_TYPE : DEFAULT_TYPE) + fieldOperator;
        return this.queryOperatorMap.get(queryOperatorKey);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the serialized string of QueryWrapper instance to be stored in Rules Criteria Query field.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    parentSObject	        DESCRIPTION (Data Type String, Name of the parent sObject for the query)
    * @param    childRelationshipMap	DESCRIPTION (Data Type String, Child Relationship Map - Child sObject Name to the Relationship name)
    * @return   String                  DESCRIPTION (return Serialized string of QueryWrapper instance)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public String getSerializedQueryWrapper(String parentSObject, Map<String, String> childRelationshipMap) {
        String childQueries = (childRelationshipMap.size() > 0) ? getChildQueries(childRelationshipMap) : '';
        Boolean containsParentSObject = queryCriteriaMap.containsKey(parentSObject);

        String parentQuery = 'SELECT Id' + (String.isBlank(childQueries) ? '' : ', ' + childQueries);
        parentQuery += ' FROM ' + parentSObject;
        parentQuery += containsParentSObject ? (' WHERE (' + queryCriteriaMap.get(parentSObject) + ')') : '';
        return MA_DS_RulesCriteriaQueryParser.instance.setQueryWrapper(parentQuery, bindMap, bindTypeMap)
                                                      .validateQueryString()
                                                      .getSerializedQueryWrapper();
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get all the Child Queries converted from the Rules Criteria JSON.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    childRelationshipMap	DESCRIPTION (Data Type String, Child Relationship Map - Chils sObject Name to the Relationship name)
    * @return   String                  DESCRIPTION (return String of Child Queries, to be appended to Parent Query)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private String getChildQueries(Map<String, String> childRelationshipMap) {
        String childQueries = '';

        for(String childSObject : childRelationshipMap.keySet()) {
            String childRelationship = childRelationshipMap.get(childSObject);
            childQueries += String.isBlank(childQueries) ? '' : ', ';
            Boolean containsChildSObject = queryCriteriaMap.containsKey(childSObject);
            childQueries += containsChildSObject ? getChildQuery(childRelationship, queryCriteriaMap.get(childSObject)) : getChildQuery(childRelationship);
        }

        return childQueries;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the default Child sObject query when no Criteria Query exists for the Child sObject.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    childRelationshipMap	DESCRIPTION (Data Type String, Child Relationship Map - Chils sObject Name to the Relationship name)
    * @return   String                  DESCRIPTION (return String of default Child Query, to be clubbed with all the Child Queries string)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private String getChildQuery(String childRelationship) {
        return '(SELECT Id FROM ' + childRelationship + ' LIMIT 1)';
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the Child sObject query when Criteria Query exists for the Child sObject.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    childRelationshipMap	DESCRIPTION (Data Type String, Child Relationship Map - Chils sObject Name to the Relationship name)
    * @return   String                  DESCRIPTION (return String of Child Query with Query Criteria, to be clubbed with all the Child Queries string)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private String getChildQuery(String childRelationship, String queryCrieteria) {
        return '(SELECT Id FROM ' + childRelationship + ' WHERE ' + queryCrieteria + ' LIMIT 1)';
    }
}