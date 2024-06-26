/**
 * ******************************************** W-12578110 : RULE ENGINE ********************************************
 * 
 * Query Parser class to set queryString & bindMap in the QueryWrapper & validate the queryString using the bindMap before storing it in the Rules Criteria Query field.
 * Serializes the QueryWrapper and returns the serialized string to store in the Rules Criteria Query field.
 * Creates QueryWrapper instance based on the serialized string stored in the Rules Criteria Query field, used while Applying Rules.
 * 
 * Version      Date            Author                  Description
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         10/03/2023      Chakshu Malhotra        W-12578110 - Adds Query Parser & validation logic for the Rules Criteria Query.
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_RulesCriteriaQueryParser {

    private static final String BIND_MAP_KEY = 'bindMap';
    private static final String QUERY_STRING_KEY = 'queryString';
    private static final String BIND_TYPE_MAP_KEY = 'bindTypeMap';

    @TestVisible
    private static Boolean skipQueryValidation = false;

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to set & hold the final singleton instance of MA_DS_RulesCriteriaQueryParser.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static final MA_DS_RulesCriteriaQueryParser instance {
        get {
            if(instance == null) {
                instance = new MA_DS_RulesCriteriaQueryParser();
            }
            return instance;
        }private set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Private default constructor of MA_DS_RulesCriteriaQueryParser class to enforce the singleton design.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private MA_DS_RulesCriteriaQueryParser() {
        // to enforce singleton design
    }

    private QueryWrapper queryWrapper {get; set;}

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to set & hold the map of Record Id to the QueryWrapper instance.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private Map<Id, QueryWrapper> queryWrapperMap {
        get {
            if(queryWrapperMap == null) {
                queryWrapperMap = new Map<Id, QueryWrapper>();
            }
            return queryWrapperMap;
        }set;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to set the QueryWrapper with the given queryString & the bindMap created by converting Rules Criteria JSON.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    queryString	                        DESCRIPTION (Data Type String, Query string containing with all the Rules Criteria applied on the sObject record)
    * @param    bindMap	                            DESCRIPTION (Data Type Map<String, Object>, Bind Variable map used by Database.query() method to execute the query)
    * @param    bindTypeMap	                        DESCRIPTION (Data Type Map<String, String>, Map of bind variable to Field Type, used while deserializing the bindMap)
    * @return   MA_DS_RulesCriteriaQueryParser      DESCRIPTION (return MA_DS_RulesCriteriaQueryParser instance)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public MA_DS_RulesCriteriaQueryParser setQueryWrapper(String queryString, Map<String, Object> bindMap, Map<String, String> bindTypeMap) {
        this.queryWrapper = new QueryWrapper(queryString, bindMap, bindTypeMap);
        return this;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to validate if the queryString is valid & doesn't throws any QueryException before storing it in the Rules Criteria Query field.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   MA_DS_RulesCriteriaQueryParser      DESCRIPTION (return MA_DS_RulesCriteriaQueryParser instance)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public MA_DS_RulesCriteriaQueryParser validateQueryString() {
        String queryStr = this.queryWrapper.queryString + ' LIMIT 1';
        if(!skipQueryValidation) {
            this.validateQueryString(queryStr);
        }
        return this;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to validate if the queryString is valid & doesn't throws any QueryException before storing it in the Rules Criteria Query field.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void validateQueryString(String queryStr) {
        try {
            Database.queryWithBinds(queryStr, this.queryWrapper.bindMap, AccessLevel.SYSTEM_MODE);
        }catch(QueryException exType) {
            MA_AbstractLogger.logException(exType, MA_DS_AddRulesCriteriaConfig.InvalidRulesCriteriaQueryException.class.getName());
            throw new MA_DS_AddRulesCriteriaConfig.InvalidRulesCriteriaQueryException(queryStr, this.queryWrapper.bindMap);
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get serialized string of QueryWrapper instance, to be stored in the Rules Criteria Query field.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   String      DESCRIPTION (return serialized string of QueryWrapper instance)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public String getSerializedQueryWrapper() {
        return JSON.serialize(this.queryWrapper);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to set the QueryWrapper with the given queryString & the bindMap created by converting Rules Criteria JSON.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    recordId	                DESCRIPTION (Data Type Id, Record Id of the sObject on which Rules are being applied)
    * @param    serializedQueryWrapper	    DESCRIPTION (Data Type String, Serialized string stored in the Rules Criteria Query)
    * @return   QueryWrapper                DESCRIPTION (return QueryWrapper instance)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public QueryWrapper getQueryWrapper(Id recordId, String serializedQueryWrapper) {
        if(!queryWrapperMap.containsKey(recordId)) {
            Map<String, Object> deserializedQueryWrapper = (Map<String, Object>)JSON.deserializeUntyped(serializedQueryWrapper);
            
            QueryWrapper queryWrapper = new QueryWrapper();
            queryWrapper.queryString = (String)deserializedQueryWrapper.get(QUERY_STRING_KEY);
            queryWrapper.bindMap = getBindMap((Map<String, Object>)deserializedQueryWrapper.get(BIND_MAP_KEY), (Map<String, Object>)deserializedQueryWrapper.get(BIND_TYPE_MAP_KEY));
            queryWrapperMap.put(recordId, queryWrapper);
        }
        return queryWrapperMap.get(recordId);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the bindMap after deserializing the QueryWrapper string.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    deserializedBindMap	        DESCRIPTION (Data Type Map<String, Object>, De-serialized bindMap)
    * @param    bindTypeMap	                DESCRIPTION (Data Type Map<String, Object>, De-serialized bindTypeMap)
    * @return   Map<String, Object>         DESCRIPTION (return Bind Variable map used by Database.query() method to execute the query)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private Map<String, Object> getBindMap(Map<String, Object> deserializedBindMap, Map<String, Object> bindTypeMap) {
        Map<String, Object> bindMap = new Map<String, Object>();

        for(String bindMapVar : bindTypeMap.keySet()) {
            Object fieldVal = deserializedBindMap.get(bindMapVar);
            String fieldType = (String)bindTypeMap.get(bindMapVar);
            Object bindMapVal = MA_DS_RulesCriteriaQueryFormatter.strategy.getDeserializedFieldValue(fieldVal, fieldType);
            bindMap.put(bindMapVar, bindMapVal);
        }

        return bindMap;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * QueryWrapper class to hold the queryString & the bindMap, used to serialize and store in the Rules Criteria Query field.
    * Use JSON.deserializeUntyped for deserializing QueryWrapper as bindMap has Object type value which is not supported Apex Type by JSON.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class QueryWrapper {
        public String queryString {get; set;}
        public Map<String, Object> bindMap {get; set;}
        public Map<String, String> bindTypeMap {get; set;}

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Default constructor of QueryWrapper class, to allow the deserialization of the serialized string stored in the Rules Criteria Query field.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public QueryWrapper() {
            // default constructor : for deserialization
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of QueryWrapper class, to initialize the QueryWrapper instance with queryString, bindMap & bindTypeMap.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public QueryWrapper(String queryString, Map<String, Object> bindMap, Map<String, String> bindTypeMap) {
            this.bindMap = bindMap;
            this.queryString = queryString;
            this.bindTypeMap = bindTypeMap;
        }
    }
}