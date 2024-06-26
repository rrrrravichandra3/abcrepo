/**
 * ******************************************** W-12578110 : RULE ENGINE ********************************************
 * 
 * Abstract class to format query criteria string based on Field Type.
 * Query Criteria string is formatted using field name, query operator and field value.
 * 
 * Version      Date            Author                  Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         11/03/2023      Chakshu Malhotra        W-12578110 - Adds strategy pattern to identify right implemtation of Formatter to return formatted query criteria string.
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_RulesCriteriaQueryFormatter {

    private static final String BIND_VARIABLE_PREFIX = 'var';

    private static final String TRUE_COUNT_KEY = 'trueCount';
    private static final String FALSE_COUNT_KEY = 'falseCount';

    private static final String NULL_COUNT_KEY = 'nullCount';
    private static final String NOT_NULL_COUNT_KEY = 'notNullCount';

    private static final String OPERATOR_CONTAINS = Label.MA_DS_Criteria_Operator_Contains;
    private static final String OPERATOR_ENDS_WITH = Label.MA_DS_Criteria_Operator_Ends_With;
    private static final String OPERATOR_STARTS_WITH = Label.MA_DS_Criteria_Operator_Starts_With;
    private static final String OPERATOR_DOES_NOT_CONTAIN = Label.MA_DS_Criteria_Operator_Does_Not_Contain;
    
    public enum FormatterType {BOOLEAN_TYPE, STRING_TYPE, NUMBER_TYPE, DATE_TYPE, DATETIME_TYPE, PICKLIST_TYPE}

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Interface to implement different Formatter implementations based on each FormatterType
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private interface Formatter {
        Object getDeserializedFieldValue(Object value);
        String getAppliedAuditFlagKey(String concatenatedKey, Object value);
        String getFormattedCriteria(String field, String criteriaOperator, String queryOperator, String value, String fieldType);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to set & hold the final singleton instance of FormatterStrategy.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static final FormatterStrategy strategy {
        get {
            if(strategy == null) {
                strategy = new FormatterStrategy();
            }
            return strategy;
        }private set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Strategy class to dynamically inititalize the Formatter implementation & get the formatted query criteria string.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class FormatterStrategy {
        private FormatterStrategy() {
            // to enforce singleton design
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to inititalize the Formatter and get the formatted query criteria string based on the FormatterType.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    field	                DESCRIPTION (Data Type String, Name of the sObject field)
        * @param    criteriaOperator	    DESCRIPTION (Data Type String, Criteria Operator used for the sObject field)
        * @param    queryOperator	        DESCRIPTION (Data Type String, Query Operator to use for the sObject field)
        * @param    value	                DESCRIPTION (Data Type String, Value of the sObject field)
        * @param    fieldType	            DESCRIPTION (Data Type String, Type of sObject field)
        * @return   String                  DESCRIPTION (return Formatted query criteria string)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public String getFormattedCriteria(String field, String criteriaOperator, String queryOperator, String value, String fieldType) {
            Formatter formatter = getFormatter(getFormatterType(fieldType));
            return formatter.getFormattedCriteria(field, criteriaOperator, queryOperator, value, fieldType);
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get FormatterType based on the Field Type.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    fieldType	        DESCRIPTION (Data Type String, Type of sObject field)
        * @return   FormatterType       DESCRIPTION (return FormatterType enum value)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private FormatterType getFormatterType(String fieldType) {
            FormatterType formatterType;
            switch on fieldType {
                when 'BOOLEAN' {
                    formatterType = MA_DS_RulesCriteriaQueryFormatter.FormatterType.BOOLEAN_TYPE;
                }when 'PICKLIST' {
                    formatterType = MA_DS_RulesCriteriaQueryFormatter.FormatterType.PICKLIST_TYPE;
                }when 'DATE' {
                    formatterType = MA_DS_RulesCriteriaQueryFormatter.FormatterType.DATE_TYPE;
                }when 'DATETIME' {
                    formatterType = MA_DS_RulesCriteriaQueryFormatter.FormatterType.DATETIME_TYPE;
                }when 'DOUBLE', 'CURRENCY', 'PERCENT' {
                    formatterType = MA_DS_RulesCriteriaQueryFormatter.FormatterType.NUMBER_TYPE;
                }when 'STRING', 'TEXTAREA', 'EMAIL', 'PHONE', 'REFERENCE', 'URL' {
                    formatterType = MA_DS_RulesCriteriaQueryFormatter.FormatterType.STRING_TYPE;
                }
            }
            return formatterType;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to dynamically create and return Formatter instance based on the FormatterType enum value.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    formatterEnumType	    DESCRIPTION (Data Type FormatterType, FormatterType enum value)
        * @return   Formatter               DESCRIPTION (return Formatter implementation)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Formatter getFormatter(FormatterType formatterEnumType) {
            Type formatterTypeImpl;

            switch on formatterEnumType {
                when DATE_TYPE {
                    formatterTypeImpl = DateFormatter.class;
                }when STRING_TYPE {
                    formatterTypeImpl = StringFormatter.class;
                }when NUMBER_TYPE {
                    formatterTypeImpl = NumberFormatter.class;
                }when BOOLEAN_TYPE {
                    formatterTypeImpl = BooleanFormatter.class;
                }when DATETIME_TYPE {
                    formatterTypeImpl = DatetimeFormatter.class;
                }when PICKLIST_TYPE {
                    formatterTypeImpl = PicklistFormatter.class;
                }
            }

            return (Formatter)formatterTypeImpl.newInstance();
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get the deserialized value of the sObject field in the bindMap of the QueryWrapper.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    value	                DESCRIPTION (Data Type String, Value of the sObject field)
        * @param    fieldType	            DESCRIPTION (Data Type String, Type of sObject field)
        * @return   Object                  DESCRIPTION (return Deserialized form of the sObject field value)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Object getDeserializedFieldValue(Object value, String fieldType) {
            Formatter formatter = getFormatter(getFormatterType(fieldType));
            return formatter.getDeserializedFieldValue(value);
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get the Applied Audit Flag Key for the given Concatenated Key (sObjectKey + fieldKey), fieldValue and the type of the field.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    concatenatedKey	        DESCRIPTION (Data Type String, Concatenation of sObjectKey + fieldKey)
        * @param    value	                DESCRIPTION (Data Type String, Value of the sObject field)
        * @param    fieldType	            DESCRIPTION (Data Type String, Type of sObject field)
        * @return   String                  DESCRIPTION (return the Applied Audit Flag Key)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public String getAppliedAuditFlagKey(String concatenatedKey, Object value, String fieldType) {
            Formatter formatter = getFormatter(getFormatterType(fieldType));
            return formatter.getAppliedAuditFlagKey(concatenatedKey, value);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Abstract class to implement Formatter interface and provide common methods for Fromatter implementations.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @TestVisible
    private abstract class AbstractFormatter implements Formatter {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to set the bind variable in bindMap and return the formatted query criteria string by formatting queryOperator with field & varValue.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    field	            DESCRIPTION (Data Type String, Name of the sObject field)
        * @param    queryOperator	    DESCRIPTION (Data Type String, Query Operator to use for the sObject field)
        * @param    varValue	        DESCRIPTION (Data Type Object, Value of the sObject field)
        * @param    fieldType	        DESCRIPTION (Data Type String, Type of sObject field)
        * @return   String              DESCRIPTION (return Formatted query criteria string)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        protected String getFormattedCriteria(String field, String queryOperator, Object varValue, String fieldType) {
            String varName = this.getNextBindVariable();
            this.addToBindMap(varName, varValue, fieldType);
            return String.format(queryOperator, new String[] {field, varName});
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to create and return next bind map variable based on the current bindVariableCount.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   String              DESCRIPTION (return Bind variable)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        protected String getNextBindVariable() {
            return BIND_VARIABLE_PREFIX + MA_DS_RulesCriteriaQueryConverter.instance.bindVariableCount;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to add the varName & varValue to the bindMap and increment the bindVariableCount by 1.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    varName	            DESCRIPTION (Data Type String, Name of the bind variable to be stored in the bindMap)
        * @param    varValue	        DESCRIPTION (Data Type Object, Value of the sObject field to be stored for the bind variable)
        * @param    fieldType	        DESCRIPTION (Data Type String, Type of sObject field)
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        protected void addToBindMap(String varName, Object varValue, String fieldType) {
            MA_DS_RulesCriteriaQueryConverter.instance.bindMap.put(varName, varValue);
            MA_DS_RulesCriteriaQueryConverter.instance.bindTypeMap.put(varName, fieldType);
            MA_DS_RulesCriteriaQueryConverter.instance.bindVariableCount++;
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to be implemented by the AbstractFormatter implementation classes, to get the Applied Audit Flag Key for the given Concatenated Key (sObjectKey + fieldKey) and the fieldValue.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public virtual String getAppliedAuditFlagKey(String concatenatedKey, Object value) {
            return '';
        }

        protected abstract Object getDeserializedFieldValue(Object value);
        protected abstract String getFormattedCriteria(String field, String criteriaOperator, String queryOperator, String value, String fieldType);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Formatter implementation to provide the formatted query criteria string for the FormatterType.BOOLEAN_TYPE
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class BooleanFormatter extends AbstractFormatter {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get the formatted query criteria string for the FormatterType.BOOLEAN_TYPE.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    field	                DESCRIPTION (Data Type String, Name of the sObject field)
        * @param    criteriaOperator	    DESCRIPTION (Data Type String, Criteria Operator used for the sObject field)
        * @param    queryOperator	        DESCRIPTION (Data Type String, Query Operator to use for the sObject field)
        * @param    value	                DESCRIPTION (Data Type String, Value of the sObject field)
        * @param    fieldType	            DESCRIPTION (Data Type String, Type of sObject field)
        * @return   String                  DESCRIPTION (return Formatted query criteria string)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getFormattedCriteria(String field, String criteriaOperator, String queryOperator, String value, String fieldType) {
            Boolean varValue = Boolean.valueOf(value);
            return super.getFormattedCriteria(field, queryOperator, varValue, fieldType);
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get the deserialized value of the sObject field in the bindMap of the QueryWrapper.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    value	                DESCRIPTION (Data Type String, Value of the sObject field)
        * @return   Object                  DESCRIPTION (return Deserialized form of the sObject field value)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override Object getDeserializedFieldValue(Object value) {
            return Boolean.valueOf(value);
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get the Applied Audit Flag Key for the given Concatenated Key (sObjectKey + fieldKey) and the fieldValue.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    concatenatedKey	        DESCRIPTION (Data Type String, Concatenation of sObjectKey + fieldKey)
        * @param    value	                DESCRIPTION (Data Type String, Value of the sObject field)
        * @return   String                  DESCRIPTION (return the Applied Audit Flag Key)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getAppliedAuditFlagKey(String concatenatedKey, Object value) {
            String valueKey = Boolean.valueOf(value) ? TRUE_COUNT_KEY : FALSE_COUNT_KEY;
            return concatenatedKey + valueKey;
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Formatter implementation to provide the formatted query criteria string for the FormatterType.NUMBER_TYPE
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class NumberFormatter extends AbstractFormatter {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get the formatted query criteria string for the FormatterType.NUMBER_TYPE.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    field	                DESCRIPTION (Data Type String, Name of the sObject field)
        * @param    criteriaOperator	    DESCRIPTION (Data Type String, Criteria Operator used for the sObject field)
        * @param    queryOperator	        DESCRIPTION (Data Type String, Query Operator to use for the sObject field)
        * @param    value	                DESCRIPTION (Data Type String, Value of the sObject field)
        * @param    fieldType	            DESCRIPTION (Data Type String, Type of sObject field)
        * @return   String                  DESCRIPTION (return Formatted query criteria string)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getFormattedCriteria(String field, String criteriaOperator, String queryOperator, String value, String fieldType) {
            Double varValue = String.isBlank(value) ? null : Double.valueOf(value);
            return super.getFormattedCriteria(field, queryOperator, varValue, fieldType);
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get the deserialized value of the sObject field in the bindMap of the QueryWrapper.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    value	                DESCRIPTION (Data Type String, Value of the sObject field)
        * @return   Object                  DESCRIPTION (return Deserialized form of the sObject field value)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override Object getDeserializedFieldValue(Object value) {
            return (value == null) ? null : Double.valueOf(value);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Formatter implementation to provide the formatted query criteria string for the FormatterType.PCIKLIST_TYPE
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class PicklistFormatter extends AbstractFormatter {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get the formatted query criteria string for the FormatterType.PCIKLIST_TYPE.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    field	                DESCRIPTION (Data Type String, Name of the sObject field)
        * @param    criteriaOperator	    DESCRIPTION (Data Type String, Criteria Operator used for the sObject field)
        * @param    queryOperator	        DESCRIPTION (Data Type String, Query Operator to use for the sObject field)
        * @param    value	                DESCRIPTION (Data Type String, Value of the sObject field)
        * @param    fieldType	            DESCRIPTION (Data Type String, Type of sObject field)
        * @return   String                  DESCRIPTION (return Formatted query criteria string)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getFormattedCriteria(String field, String criteriaOperator, String queryOperator, String value, String fieldType) {
            List<String> varValue = value.split(',');
            return super.getFormattedCriteria(field, queryOperator, varValue, fieldType);
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get the deserialized value of the sObject field in the bindMap of the QueryWrapper.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    value	                DESCRIPTION (Data Type String, Value of the sObject field)
        * @return   Object                  DESCRIPTION (return Deserialized form of the sObject field value)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override Object getDeserializedFieldValue(Object value) {
            List<String> valueList = new List<String>();

            for(Object picklistVal : (List<Object>)value) {
                valueList.add(String.valueOf(picklistVal));
            }

            return valueList;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get the Applied Audit Flag Key for the given Concatenated Key (sObjectKey + fieldKey) and the fieldValue.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    concatenatedKey	        DESCRIPTION (Data Type String, Concatenation of sObjectKey + fieldKey)
        * @param    value	                DESCRIPTION (Data Type String, Value of the sObject field)
        * @return   String                  DESCRIPTION (return the Applied Audit Flag Key)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getAppliedAuditFlagKey(String concatenatedKey, Object value) {
            String valueKey = (value == null) ? NULL_COUNT_KEY : String.valueOf(value);
            return concatenatedKey + valueKey;
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Formatter implementation to provide the formatted query criteria string for the FormatterType.DATE_TYPE
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class DateFormatter extends AbstractFormatter {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get the formatted query criteria string for the FormatterType.DATE_TYPE.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    field	                DESCRIPTION (Data Type String, Name of the sObject field)
        * @param    criteriaOperator	    DESCRIPTION (Data Type String, Criteria Operator used for the sObject field)
        * @param    queryOperator	        DESCRIPTION (Data Type String, Query Operator to use for the sObject field)
        * @param    value	                DESCRIPTION (Data Type String, Value of the sObject field)
        * @param    fieldType	            DESCRIPTION (Data Type String, Type of sObject field)
        * @return   String                  DESCRIPTION (return Formatted query criteria string)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getFormattedCriteria(String field, String criteriaOperator, String queryOperator, String value, String fieldType) {
            Date varValue = String.isBlank(value) ? null :  Date.valueOf(value);
            return super.getFormattedCriteria(field, queryOperator, varValue, fieldType);
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get the deserialized value of the sObject field in the bindMap of the QueryWrapper.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    value	                DESCRIPTION (Data Type String, Value of the sObject field)
        * @return   Object                  DESCRIPTION (return Deserialized form of the sObject field value)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override Object getDeserializedFieldValue(Object value) {
            return (value == null) ? null : Date.valueOf(String.valueOf(value));
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Formatter implementation to provide the formatted query criteria string for the FormatterType.DATETIME_TYPE
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class DatetimeFormatter extends AbstractFormatter {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get the formatted query criteria string for the FormatterType.DATETIME_TYPE.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    field	                DESCRIPTION (Data Type String, Name of the sObject field)
        * @param    criteriaOperator	    DESCRIPTION (Data Type String, Criteria Operator used for the sObject field)
        * @param    queryOperator	        DESCRIPTION (Data Type String, Query Operator to use for the sObject field)
        * @param    value	                DESCRIPTION (Data Type String, Value of the sObject field)
        * @param    fieldType	            DESCRIPTION (Data Type String, Type of sObject field)
        * @return   String                  DESCRIPTION (return Formatted query criteria string)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getFormattedCriteria(String field, String criteriaOperator, String queryOperator, String value, String fieldType) {
            Datetime varValue = String.isBlank(value) ? null :  getApexDatetime(value);
            return super.getFormattedCriteria(field, queryOperator, varValue, fieldType);
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get create Datetime instance from the formatted ISO Datetime string.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    isoDatetimeString       DESCRIPTION (Data Type String, ISO formatted Datetime string)
        * @return   String                  DESCRIPTION (return Datetime instance)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Datetime getApexDatetime(String isoDatetimeString) {            
            String[] isoDatetimeStringList = isoDatetimeString.split('T');
            return (isoDatetimeStringList != null && isoDatetimeStringList.size() > 0) ? getApexDatetime(isoDatetimeStringList) : Datetime.now();
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get the formatted Date string from the ISO formatted Datetime string.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    isoDatetimeStringList   DESCRIPTION (Data Type String[], ISO formatted Date / Time string list)
        * @return   String                  DESCRIPTION (return Formatted Date string)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Datetime getApexDatetime(String[] isoDatetimeStringList) {
            String datetimeString = isoDatetimeStringList[0] + ' ' + getApexTimeString(isoDatetimeStringList);
            return Datetime.valueOf(datetimeString);
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get the formatted Time string from the ISO formatted Datetime string.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    isoDatetimeStringList   DESCRIPTION (Data Type String[], ISO formatted Date / Time string list)
        * @return   String                  DESCRIPTION (return Formatted Time string)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private String getApexTimeString(String[] isoDatetimeStringList) {
            return (isoDatetimeStringList.size() > 1) ? isoDatetimeStringList[1].split('\\.')[0] : '00:00:00';
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get the deserialized value of the sObject field in the bindMap of the QueryWrapper.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    value	                DESCRIPTION (Data Type String, Value of the sObject field)
        * @return   Object                  DESCRIPTION (return Deserialized form of the sObject field value)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override Object getDeserializedFieldValue(Object value) {
            return (value == null) ? null : getApexDatetime(String.valueOf(value));
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Formatter implementation to provide the formatted query criteria string for the FormatterType.STRING_TYPE
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class StringFormatter extends AbstractFormatter {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get the formatted query criteria string for the FormatterType.STRING_TYPE.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    field	                DESCRIPTION (Data Type String, Name of the sObject field)
        * @param    criteriaOperator	    DESCRIPTION (Data Type String, Criteria Operator used for the sObject field)
        * @param    queryOperator	        DESCRIPTION (Data Type String, Query Operator to use for the sObject field)
        * @param    value	                DESCRIPTION (Data Type String, Value of the sObject field)
        * @param    fieldType	            DESCRIPTION (Data Type String, Type of sObject field)
        * @return   String                  DESCRIPTION (return Formatted query criteria string)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getFormattedCriteria(String field, String criteriaOperator, String queryOperator, String value, String fieldType) {
            String formattedString = '';

            if(criteriaOperator.equalsIgnoreCase(OPERATOR_CONTAINS)) {
                formattedString += getFormattedCriteria(field, 'OR', queryOperator, value.split(','), fieldType);
            }else if(criteriaOperator.equalsIgnoreCase(OPERATOR_ENDS_WITH)) {
                formattedString += super.getFormattedCriteria(field, queryOperator, '%' + value, fieldType);
            }else if(criteriaOperator.equalsIgnoreCase(OPERATOR_STARTS_WITH)) {
                formattedString += super.getFormattedCriteria(field, queryOperator, value + '%', fieldType);
            }else if(criteriaOperator.equalsIgnoreCase(OPERATOR_DOES_NOT_CONTAIN)) {
                formattedString += getFormattedCriteria(field, 'AND', queryOperator, value.split(','), fieldType);
            }else {
                formattedString += super.getFormattedCriteria(field, queryOperator, String.isBlank(value) ? null : value, fieldType);
            }
            
            return formattedString;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get the formatted query criteria string for the FormatterType.STRING_TYPE if criteriaOperator is either "CONTAINS" or "DOES NOT CONTAIN".
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    field	                DESCRIPTION (Data Type String, Name of the sObject field)
        * @param    logicalOperator	        DESCRIPTION (Data Type String, Logical Operator to be used for the Criteria Operator)
        * @param    queryOperator	        DESCRIPTION (Data Type String, Query Operator to use for the sObject field)
        * @param    value	                DESCRIPTION (Data Type String, List of the sObject field values)
        * @param    fieldType	            DESCRIPTION (Data Type String, Type of sObject field)
        * @return   String                  DESCRIPTION (return Formatted query criteria string)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private String getFormattedCriteria(String field, String logicalOperator, String queryOperator, List<String> values, String fieldType) {
            String formattedString = (values.size() > 0) ? '(' : '';
            for(String value : values) {
                formattedString += (formattedString.length() > 1) ? (' ' + logicalOperator + ' ') : '';
                formattedString += super.getFormattedCriteria(field, queryOperator, '%' + value.trim() + '%', fieldType);
            }
            formattedString += (values.size() > 0) ? ')' : '';
            return formattedString;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get the deserialized value of the sObject field in the bindMap of the QueryWrapper.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    value	                DESCRIPTION (Data Type String, Value of the sObject field)
        * @return   Object                  DESCRIPTION (return Deserialized form of the sObject field value)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override Object getDeserializedFieldValue(Object value) {
            return (value == null) ? null : String.valueOf(value);
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get the Applied Audit Flag Key for the given Concatenated Key (sObjectKey + fieldKey) and the fieldValue.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    concatenatedKey	        DESCRIPTION (Data Type String, Concatenation of sObjectKey + fieldKey)
        * @param    value	                DESCRIPTION (Data Type String, Value of the sObject field)
        * @return   String                  DESCRIPTION (return the Applied Audit Flag Key)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getAppliedAuditFlagKey(String concatenatedKey, Object value) {
            String valueKey = (value == null) ? NULL_COUNT_KEY : NOT_NULL_COUNT_KEY;
            return concatenatedKey + valueKey;
        }
    }
}