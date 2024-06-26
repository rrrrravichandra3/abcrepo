public with sharing class PF_CaseUIComponentController {
/*
**  Dev notes: If you change something, don't forget to check/change the Test Class "PF_CaseUIComponentController_Test"
*/
    //============================================== RESULT STATUSES ===================================================
    public static final String STATUS_SUCCESS   = 'SUCCESS';
    public static final String STATUS_ERROR     = 'ERROR';
    //========================================= ERROR AND INFO MESSAGES ================================================
    public static final String COMPONENT_RESTRICTION_MESSAGE = 'This Component is not available for the current Record Type.';
    public static final String EMPTY_RECORD_ID_MESSAGE       = 'Empty Record Id has been received.';
    public static final String IN_REFERENCE_TO_IS_MISSING    = 'The "In Reference To" field is required for the current Record Type.';
    public static final String CONTACT_ID_IS_MISSING         = 'The "Contact Id" field is required for the current Record Type.';
    public static final String ALLEGATIONS_IS_MISSING        = 'At least one "Allegation" record must be created.';
    //===================================== COMPONENT SUPPORTED RECORD TYPES ===========================================
    public static final String CASE_RECORD_TYPE_ER_INVESTIGATIONS           = 'ER_Investigations';
    public static final String CASE_RECORD_TYPE_ER_PERFORMANCE_IMPROVEMENT  = 'ER_Performance_Improvement';
    public static final String CASE_RECORD_TYPE_GENERAL_ER_CASE             = 'General_Employee_Relations_Case';
    public static final String CASE_RECORD_TYPE_MANAGER_GUIDANCE            = 'Manager_Guidance_CRT';
    public static final String CASE_RECORD_TYPE_WARM_LINE                   = 'Warmline';
    public static final String KEYWORD_RT_DEVELOPER_NAME                    = 'DeveloperName';
    public static final String KEYWORD_RT_NAME                              = 'Name';

    public static final List<String> SUPPORTED_CASE_RECORD_TYPES = new List<String> {
        CASE_RECORD_TYPE_ER_INVESTIGATIONS,
        CASE_RECORD_TYPE_ER_PERFORMANCE_IMPROVEMENT,
        CASE_RECORD_TYPE_GENERAL_ER_CASE,
        CASE_RECORD_TYPE_MANAGER_GUIDANCE,
        CASE_RECORD_TYPE_WARM_LINE
    };
    public static final List<String> SUPPORTED_ER_RECORD_TYPES = new List<String> {
        CASE_RECORD_TYPE_ER_INVESTIGATIONS,
        CASE_RECORD_TYPE_ER_PERFORMANCE_IMPROVEMENT,
        CASE_RECORD_TYPE_MANAGER_GUIDANCE,
        CASE_RECORD_TYPE_GENERAL_ER_CASE
    };
    public static final List<String> SUPPORTED_ER_RESTRICTED_RECORD_TYPES = new List<String> {
        CASE_RECORD_TYPE_ER_INVESTIGATIONS,
        CASE_RECORD_TYPE_ER_PERFORMANCE_IMPROVEMENT,
        CASE_RECORD_TYPE_GENERAL_ER_CASE
    };
    public static final List<String> REQUIRED_CONTACT_ID_RECORD_TYPES = new List<String> {
        CASE_RECORD_TYPE_WARM_LINE
    };
    public static final List<String> REQUIRED_IN_REFERENCE_TO_RECORD_TYPES = new List<String> {
        CASE_RECORD_TYPE_ER_PERFORMANCE_IMPROVEMENT,
        CASE_RECORD_TYPE_MANAGER_GUIDANCE,
        CASE_RECORD_TYPE_GENERAL_ER_CASE
    };
    public static final List<String> REQUIRED_ALLEGATIONS_RECORD_TYPES = new List<String> {
        CASE_RECORD_TYPE_ER_INVESTIGATIONS
    };
    //=============================================== FIELD TYPES ======================================================
    public static final String FIELD_TYPE_STRING = 'STRING';
    public static final List<String> SUPPORTED_EXTRA_FIELD_TYPES = new List<String> {
        FIELD_TYPE_STRING
    };
    //============================================== OBJECT FIELDS =====================================================
    public static final String F_ID                                     = 'Id';
    public static final String CASE_OBJECT                              = 'Case';
    public static final String ER_RESTRICTED_CASE_OBJECT                = 'ER_Restricted_Case__c';
    public static final String CASE_F_ACCUSED_SEARCH_ONLY               = 'Accused_Search_only__c';
    public static final String CASE_F_CASE_NUMBER                       = 'CaseNumber';
    public static final String CASE_F_OWNER_ID                          = 'OwnerId';
    public static final String CASE_F_CONTACT_ID                        = 'ContactId';
    public static final String CASE_R_CONTACT_F_NAME                    = 'Contact.Name';
    public static final String CASE_F_FINDINGS                          = 'Findings__c';
    public static final String CASE_F_OUTCOME                           = 'ES_DJC_Outcome_of_Plan__c';
    public static final String CASE_F_STATUS                            = 'Status';
    public static final String CASE_R_OWNER_F_NAME                      = 'Owner.Name';
    public static final String CASE_R_RECORD_TYPE_F_NAME                = 'RecordType.Name';
    public static final String CASE_R_RECORD_TYPE_F_DEVELOPER_NAME      = 'RecordType.DeveloperName';
    public static final String CASE_R_IN_REFERENCE_TO                   = 'In_Reference_To__c';
    public static final String CASE_R_IN_REFERENCE_TO_F_NAME            = 'In_Reference_To__r.Name';
    public static final String CASE_F_ATTORNEY_CLIENT_PRIVILEGE         = 'Attorney_client_privilege__c';
    public static final String ER_CASE_F_NAME                           = 'Name';
    public static final String ER_CASE_F_CASE_NUMBER                    = 'Case__r.CaseNumber';
    public static final String ER_CASE_F_CASE_OWNER                     = 'Case_Owner__c';
    public static final String ER_CASE_R_CONTACT                        = 'Contact__c';
    public static final String ER_CASE_R_CONTACT_F_NAME                 = 'Contact__r.Name';
    public static final String ER_CASE_F_RECORD_TYPE_ID                 = 'Case_Record_Type_Id__c';
    public static final String ER_CASE_R_IN_REFERENCE_TO                = 'In_Reference_To__c';
    public static final String ER_CASE_R_IN_REFERENCE_TO_F_NAME         = 'In_Reference_To__r.Name';
    public static final String ER_CASE_F_STATUS                         = 'Case_Status__c';

    public static final List<String> DEFAULT_ER_RESTRICTED_CASE_QUERY_FIELDS = new List<String> {
        F_ID,
        ER_CASE_F_NAME,
        ER_CASE_F_CASE_OWNER,
        ER_CASE_R_CONTACT,
        ER_CASE_R_CONTACT_F_NAME,
        ER_CASE_R_IN_REFERENCE_TO,
        ER_CASE_R_IN_REFERENCE_TO_F_NAME,
        ER_CASE_F_STATUS,
        ER_CASE_F_RECORD_TYPE_ID
    };
    public static final List<String> DEFAULT_ER_QUERY_FIELDS = new List<String> {
        F_ID,
        CASE_F_CASE_NUMBER,
        CASE_F_OWNER_ID,
        CASE_R_OWNER_F_NAME,
        CASE_F_CONTACT_ID,
        CASE_R_CONTACT_F_NAME,
        CASE_R_IN_REFERENCE_TO,
        CASE_R_IN_REFERENCE_TO_F_NAME,
        CASE_F_STATUS,
        CASE_R_RECORD_TYPE_F_NAME,
        CASE_R_RECORD_TYPE_F_DEVELOPER_NAME,
        CASE_F_ATTORNEY_CLIENT_PRIVILEGE,
        CASE_F_ACCUSED_SEARCH_ONLY
       
    };
    public static final List<String> DEFAULT_WARM_LINE_QUERY_FIELDS = new List<String> {
        F_ID,
        CASE_F_CASE_NUMBER,
        CASE_F_OWNER_ID,
        CASE_R_OWNER_F_NAME,
        CASE_F_CONTACT_ID,
        CASE_R_CONTACT_F_NAME,
        CASE_F_STATUS,
        CASE_F_FINDINGS,
        CASE_F_OUTCOME,
        CASE_R_RECORD_TYPE_F_NAME,
        CASE_R_RECORD_TYPE_F_DEVELOPER_NAME,
        CASE_F_ACCUSED_SEARCH_ONLY
    };
    public static final Map<String, List<String>> DEFAULT_QUERY_FIELDS_BY_RECORD_TYPE = new Map<String, List<String>> {
        CASE_RECORD_TYPE_WARM_LINE                  => DEFAULT_WARM_LINE_QUERY_FIELDS,
        CASE_RECORD_TYPE_ER_INVESTIGATIONS          => DEFAULT_ER_QUERY_FIELDS,
        CASE_RECORD_TYPE_ER_PERFORMANCE_IMPROVEMENT => DEFAULT_ER_QUERY_FIELDS,
        CASE_RECORD_TYPE_MANAGER_GUIDANCE           => DEFAULT_ER_QUERY_FIELDS,
        CASE_RECORD_TYPE_GENERAL_ER_CASE            => DEFAULT_ER_QUERY_FIELDS
    };
    //=============================================== TABLE DATA =======================================================
    public static final String COLUMN_TYPE_TEXT = 'text';
    public static final String KEYWORD_COLUMNS              = 'COLUMNS';
    public static final String KEYWORD_FIELDS               = 'FIELDS';
    public static final String KEYWORD_EXTRA_COLUMN_COUNT   = 'EXTRA_COLUMN_COUNT';
    public static final String COLUMN_CASE_NUMBER_LABEL             = 'Case Number';
    public static final String COLUMN_CASE_OWNER_LABEL              = 'Case Owner';
    public static final String COLUMN_CASE_CONTACT_NAME_LABEL       = 'Contact Name';
    public static final String COLUMN_CASE_IN_REFERENCE_TO_LABEL    = 'In Reference To';
    public static final String COLUMN_CASE_STATUS_LABEL             = 'Status';
    public static final String COLUMN_CASE_RECORD_TYPE_LABEL        = 'Record Type';
    public static final String COLUMN_CASE_FINDINGS_LABEL           = 'Findings';
    public static final String COLUMN_CASE_OUTCOME_LABEL            = 'Outcome';

    public static final List<TableColumn> DEFAULT_ER_TABLE_COLUMNS = new List<TableColumn> {
        new TableColumn(COLUMN_CASE_NUMBER_LABEL,          CASE_F_CASE_NUMBER,            COLUMN_TYPE_TEXT),
        new TableColumn(COLUMN_CASE_OWNER_LABEL,           CASE_R_OWNER_F_NAME,           COLUMN_TYPE_TEXT),
        new TableColumn(COLUMN_CASE_CONTACT_NAME_LABEL,    CASE_R_CONTACT_F_NAME,         COLUMN_TYPE_TEXT),
        new TableColumn(COLUMN_CASE_IN_REFERENCE_TO_LABEL, CASE_R_IN_REFERENCE_TO_F_NAME, COLUMN_TYPE_TEXT),
        new TableColumn(COLUMN_CASE_STATUS_LABEL,          CASE_F_STATUS,                 COLUMN_TYPE_TEXT),
        new TableColumn(COLUMN_CASE_RECORD_TYPE_LABEL,     CASE_R_RECORD_TYPE_F_NAME,     COLUMN_TYPE_TEXT)
    };
    public static final List<TableColumn> DEFAULT_WARM_LINE_TABLE_COLUMNS = new List<TableColumn> {
        new TableColumn(COLUMN_CASE_NUMBER_LABEL,      CASE_F_CASE_NUMBER,        COLUMN_TYPE_TEXT),
        new TableColumn(COLUMN_CASE_OWNER_LABEL,       CASE_R_OWNER_F_NAME,       COLUMN_TYPE_TEXT),
        new TableColumn(COLUMN_CASE_STATUS_LABEL,      CASE_F_STATUS,             COLUMN_TYPE_TEXT),
        new TableColumn(COLUMN_CASE_FINDINGS_LABEL,    CASE_F_FINDINGS,           COLUMN_TYPE_TEXT),
        new TableColumn(COLUMN_CASE_OUTCOME_LABEL,     CASE_F_OUTCOME,            COLUMN_TYPE_TEXT),
        new TableColumn(COLUMN_CASE_RECORD_TYPE_LABEL, CASE_R_RECORD_TYPE_F_NAME, COLUMN_TYPE_TEXT)
    };
    public static final Map<String, List<TableColumn>> DEFAULT_COLUMNS_BY_RECORD_TYPE = new Map<String, List<TableColumn>> {
        CASE_RECORD_TYPE_WARM_LINE                  => DEFAULT_WARM_LINE_TABLE_COLUMNS,
        CASE_RECORD_TYPE_ER_INVESTIGATIONS          => DEFAULT_ER_TABLE_COLUMNS,
        CASE_RECORD_TYPE_ER_PERFORMANCE_IMPROVEMENT => DEFAULT_ER_TABLE_COLUMNS,
        CASE_RECORD_TYPE_MANAGER_GUIDANCE           => DEFAULT_ER_TABLE_COLUMNS,
        CASE_RECORD_TYPE_GENERAL_ER_CASE            => DEFAULT_ER_TABLE_COLUMNS
    };
    //============================================= SOQL CONSTANTS =====================================================
    public static final String SOQL_SELECT          = 'SELECT';
    public static final String SOQL_FROM            = 'FROM';
    public static final String SOQL_WHERE           = 'WHERE';
    public static final String SOQL_ORDER_BY        = 'ORDER BY';
    public static final String SOQL_DESC            = 'DESC';
    public static final String SOQL_LIMIT           = 'LIMIT';
    public static final String SOQL_DEFAULT_LIMIT   = '1000';
    public static final String DIVIDER_SPACE            = ' ';
    public static final String DIVIDER_COMA             = ', ';
    public static final String DIVIDER_COMA_WITH_QUOTES = '\', \'';
    public static final String DIVIDER_AND              = ' AND ';
    public static final String DIVIDER_OR               = ' OR ';

    private static final String ER_RESTRICTED_CASE_NUMBER_REGEX = '[\\S\\W\\D\\w\\d\\s]*-';

    @AuraEnabled
    public static ResultData getInitData(String recordId, String fieldSetName) {
        ResultData result = new ResultData();

        try {
            // When empty Id has been Received from the UI
            if (String.isBlank(recordId)) throw new ResultException(EMPTY_RECORD_ID_MESSAGE);

            Case context = getCurrentCaseData(recordId);

            if (!SUPPORTED_CASE_RECORD_TYPES.contains(context.RecordType.DeveloperName)) {
                // We currently support 5 following record types:
                // - Warmline
                // - ER_Investigation
                // - ER_Performance_Improvement
                // - General_Employee_Relations_Case
                // - Manager_Guidance_CRT
                throw new ResultException(COMPONENT_RESTRICTION_MESSAGE);
            }
            setResultData(result, context, fieldSetName);
        } catch (Exception e) {
            result.setError(e);
            System.debug('PF_CaseUIComponentController.getInitData');
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }

        return result;
    }

    private static void setResultData(ResultData result, Case context, String fieldSetName) {
    //================================================== VARIABLES =====================================================
        Map<String, UIRecordWrapper> recordsByCaseNumber    = new Map<String, UIRecordWrapper>();
        Map<String, List<Object>> fieldsAndColumns          = new Map<String, List<Object>>();
        Map<String, Map<String, String>> recordTypeMap      = new Map<String, Map<String, String>>();
        List<String> excludedIds                            = new List<String> { context.Id };
        String query                                        = '';
        String queryERRestricted                            = '';
        String queryWithAccusedSearch                       = '';
    //================================================= CHECK DATA =====================================================
        if (REQUIRED_CONTACT_ID_RECORD_TYPES.contains(context.RecordType.DeveloperName) && context.ContactId == null) {
            // if required "ContactId" field is Empty
            throw new ResultException(CONTACT_ID_IS_MISSING);
        }
        if (REQUIRED_IN_REFERENCE_TO_RECORD_TYPES.contains(context.RecordType.DeveloperName) && context.In_Reference_To__c == null) {
            // if required "In Reference To" field is Empty
            throw new ResultException(IN_REFERENCE_TO_IS_MISSING);
        }
        if (REQUIRED_ALLEGATIONS_RECORD_TYPES.contains(context.RecordType.DeveloperName) && context.Allegations__r.isEmpty()) {
            // if ER Investigation case doesn't have any Allegations that might be used
            // to find related records by accused persons
            throw new ResultException(ALLEGATIONS_IS_MISSING);
        }
    //============================================= DATA MANIPULATION ==================================================
        fieldsAndColumns = getQueryFieldsAndColumns(context.RecordType.DeveloperName, fieldSetName);
        query = String.join(new List<String> {
            SOQL_SELECT, String.join(fieldsAndColumns.get(KEYWORD_FIELDS), DIVIDER_COMA),
            SOQL_FROM, CASE_OBJECT,
            SOQL_WHERE, getRelatedCaseQueryWhereState(context),
            SOQL_ORDER_BY, CASE_F_CASE_NUMBER, SOQL_DESC,
            SOQL_LIMIT, SOQL_DEFAULT_LIMIT
        }, DIVIDER_SPACE);
        queryWithAccusedSearch = String.join(new List<String> {
            SOQL_SELECT, String.join(fieldsAndColumns.get(KEYWORD_FIELDS), DIVIDER_COMA),
            SOQL_FROM, CASE_OBJECT,
            SOQL_WHERE, getRelatedCaseQueryWhereAccusedCondition(context),
            SOQL_ORDER_BY, CASE_F_CASE_NUMBER, SOQL_DESC,
            SOQL_LIMIT, SOQL_DEFAULT_LIMIT
        }, DIVIDER_SPACE);
        List<Case> allRelatedCasesForER = Database.query(query);
        List<Case> allRelatedCasesWithAccusedSearch  = Database.query(queryWithAccusedSearch);
        if (context.RecordType.DeveloperName != CASE_RECORD_TYPE_WARM_LINE){
            allRelatedCasesForER.addall(removeUserNonRelatedErCases(allRelatedCasesWithAccusedSearch,context));
        }

        for (Case erc : allRelatedCasesForER) {
            UIRecordWrapper uiRecord = new UIRecordWrapper(erc, context.RecordType.DeveloperName);
            for (TableColumn column : (List<TableColumn>) fieldsAndColumns.get(KEYWORD_COLUMNS)) {
                if (!column.isExtraColumn) continue;
                uiRecord.extraFields.add(new ExtraField(erc, column.fsm));
            }
            recordsByCaseNumber.put(erc.CaseNumber, uiRecord);
            excludedIds.add(erc.Id);
        }

        result.tableColumns     = (List<TableColumn>) fieldsAndColumns.get(KEYWORD_COLUMNS);
        result.caseRecordType   = context.RecordType.DeveloperName;
        result.records          = recordsByCaseNumber.values();

        if (!SUPPORTED_ER_RESTRICTED_RECORD_TYPES.contains(context.RecordType.DeveloperName)) return;
        // The following logic is only for the ER Record Types
        queryERRestricted = String.join(new List<String> {
            SOQL_SELECT, String.join(DEFAULT_ER_RESTRICTED_CASE_QUERY_FIELDS, DIVIDER_COMA),
            SOQL_FROM, ER_RESTRICTED_CASE_OBJECT,
            SOQL_WHERE, getRelatedRestrictedCaseQueryWhereState(context, excludedIds),
            SOQL_ORDER_BY, ER_CASE_F_CASE_NUMBER, SOQL_DESC,
            SOQL_LIMIT, SOQL_DEFAULT_LIMIT
        }, DIVIDER_SPACE);
        recordTypeMap = getRecordTypeNamesById();

        for (ER_Restricted_Case__c errc : (List<ER_Restricted_Case__c>) Database.query(queryERRestricted)) {
            UIRecordWrapper uiRecord = new UIRecordWrapper(errc, fieldsAndColumns.get(KEYWORD_EXTRA_COLUMN_COUNT).size());
            uiRecord.recordType      = recordTypeMap.get(errc.Case_Record_Type_Id__c).get(KEYWORD_RT_NAME);
            uiRecord.recordTypeDev   = recordTypeMap.get(errc.Case_Record_Type_Id__c).get(KEYWORD_RT_DEVELOPER_NAME);
            recordsByCaseNumber.put(uiRecord.caseNumber, uiRecord);
        }

        result.records = recordsByCaseNumber.values();
    }

    private static Case getCurrentCaseData(String recordId) {
        return [
            SELECT  Id,
                    OwnerId,
                    Attorney_client_privilege__c,
                    ContactId,
                    RecordTypeId,
                    RecordType.DeveloperName,
                    In_Reference_To__c,
                    In_Reference_To__r.Id,
                    In_Reference_To__r.Name,
                    In_Reference_To_Search_only__c,
                    Accused_Search_only__c,
            (
                    SELECT Id
                    FROM Allegations__r
                    LIMIT 2
            )
            FROM Case
            WHERE Id = :recordId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }

    private static Map<String, List<Object>> getQueryFieldsAndColumns(String recordType, String fieldSetName) {
        Map<String, List<Object>> result = new Map<String, List<Object>> {
            KEYWORD_COLUMNS            => DEFAULT_COLUMNS_BY_RECORD_TYPE.get(recordType).clone(),
            KEYWORD_FIELDS             => DEFAULT_QUERY_FIELDS_BY_RECORD_TYPE.get(recordType).clone(),
            KEYWORD_EXTRA_COLUMN_COUNT => new List<String>()
        };

        if (String.isBlank(fieldSetName)) return result;

        FieldSet caseFieldSet = SObjectType.Case.fieldSets.getMap().get(fieldSetName);

        if (caseFieldSet == null || caseFieldSet.fields.isEmpty()) return result;

        for (FieldSetMember fsm : caseFieldSet.fields) {
            if (result.get(KEYWORD_FIELDS).contains(fsm.fieldPath) || !SUPPORTED_EXTRA_FIELD_TYPES.contains(String.valueOf(fsm.getType()))){
                continue;
            }

            result.get(KEYWORD_COLUMNS).add(new TableColumn(fsm));
            result.get(KEYWORD_FIELDS).add(fsm.fieldPath);
            result.get(KEYWORD_EXTRA_COLUMN_COUNT).add(fsm.fieldPath);

            if (result.get(KEYWORD_COLUMNS).size() == 9) break;
        }

        return result;
    }

    private static String getRelatedCaseQueryWhereState(Case context) {
        String whereStatement = String.join(new List<String> {
            'Id != \'' + context.Id + '\'',
            'RecordType.DeveloperName IN (\'' + String.join(SUPPORTED_ER_RECORD_TYPES, DIVIDER_COMA_WITH_QUOTES) + '\')'
        }, DIVIDER_AND);

        if (context.RecordType.DeveloperName == CASE_RECORD_TYPE_WARM_LINE) {
            whereStatement += ' AND ContactId = \'' + context.ContactId + '\'';
        }

        if (context.RecordType.DeveloperName == CASE_RECORD_TYPE_ER_INVESTIGATIONS) {
            // Search all ER cases that is related to accused persons by:
            // Case Contact Name, In Reference To Name Or is part of Accused(Search Only)
            List<String> accusedCondition = new List<String>();
            List<String> accusedPersons   = new List<String>();
            for (String accusedPerson : context.Accused_Search_only__c.split(',')) {
                accusedPersons.add(accusedPerson.trim());
            }

            for (String accusedPerson : accusedPersons) {
                accusedCondition.add('Accused_Search_only__c LIKE \'%' + accusedPerson + '%\'');
            }

            whereStatement += ' AND (' + String.join(new List<String> {
                'Contact.Name IN (\'' + String.join(accusedPersons, DIVIDER_COMA_WITH_QUOTES) + '\')',
                'In_Reference_To__r.Name IN (\'' + String.join(accusedPersons, DIVIDER_COMA_WITH_QUOTES) + '\')'
            }, DIVIDER_OR) + ')';
            system.debug('check the query'+whereStatement);
          
        }

        if (REQUIRED_IN_REFERENCE_TO_RECORD_TYPES.contains(context.RecordType.DeveloperName)) {
            // Search All ER Cases that is related by:
            // ContactId to the context Case In Reference To Id,
            // In Reference To Id to the context Case In Reference To Id,
            // Context Case In Reference To Name is Accused Person and is part of ER Case Accused(Search Only)
            whereStatement += ' AND (' + String.join(new List<String> {
                'ContactId = \'' + context.In_Reference_To__c + '\'',
                'In_Reference_To__c = \'' + context.In_Reference_To__c + '\''
            }, DIVIDER_OR) + ')';
           
        }

        return whereStatement;
    }
    private static String getRelatedCaseQueryWhereAccusedCondition (Case context){
        String whereStatement = String.join(new List<String> {
            'Id != \'' + context.Id + '\'',
            'RecordType.DeveloperName IN (\'' + String.join(SUPPORTED_ER_RECORD_TYPES, DIVIDER_COMA_WITH_QUOTES) + '\')'
        }, DIVIDER_AND);
        if (context.RecordType.DeveloperName == CASE_RECORD_TYPE_ER_INVESTIGATIONS) {
            // Search all ER cases that is related to accused persons by:
            // Case Contact Name, In Reference To Name Or is part of Accused(Search Only)
            List<String> accusedCondition = new List<String>();
            List<String> accusedPersons   = new List<String>();
            for (String accusedPerson : context.Accused_Search_only__c.split(',')) {
                accusedPersons.add(accusedPerson.trim());
            }

            for (String accusedPerson : accusedPersons) {
                accusedCondition.add('Accused_Search_only__c LIKE \'%' + accusedPerson + '%\'');
            }
             wherestatement += ' AND (' + String.join(accusedCondition, DIVIDER_OR)+ ')';
             system.debug('check the condition'+wherestatement);
            
        }
        if (REQUIRED_IN_REFERENCE_TO_RECORD_TYPES.contains(context.RecordType.DeveloperName)) {
            // Search All ER Cases that is related by:
            // ContactId to the context Case In Reference To Id,
            // In Reference To Id to the context Case In Reference To Id,
            // Context Case In Reference To Name is Accused Person and is part of ER Case Accused(Search Only)
            whereStatement += 'AND Accused_Search_only__c LIKE \'%' + context.In_Reference_To__r.Name + '%\'';
            system.debug('check he whereStatement'+wherestatement);
        }
        return whereStatement;
    }


    private static String getRelatedRestrictedCaseQueryWhereState(Case context, List<String> excludedIds) {
        // ER_Restricted_Case__c might be created only for the following Record Types:
        // - ER_Investigations
        // - ER_Performance_Improvement
        // - General_Employee_Relations_Case
        // that is why we don't add the RecordType Developer Name Where Statement
        String whereStatement = String.join(new List<String> {
            'Name != null',
            'Name != \'\'',
            'Case_Record_Type_Id__c != null',
            'Case_Record_Type_Id__c != \'\'',
            'Case__c NOT IN (\'\', \'' + String.join(excludedIds, DIVIDER_COMA_WITH_QUOTES) + '\')'
        }, DIVIDER_AND);


        if (context.RecordType.DeveloperName == CASE_RECORD_TYPE_ER_INVESTIGATIONS) {
            List<String> accusedPersons = new List<String>();
            for (String accusedPerson : context.Accused_Search_only__c.split(',')) {
                accusedPersons.add(accusedPerson.trim());
            }

            whereStatement += ' AND (' + String.join(new List<String> {
                'Contact__r.Name IN (\'' + String.join(accusedPersons, DIVIDER_COMA_WITH_QUOTES) + '\')',
                'In_Reference_To__r.Name IN (\'' + String.join(accusedPersons, DIVIDER_COMA_WITH_QUOTES) + '\')',
                'Accused__r.Name IN (\'' +  String.join(accusedPersons, DIVIDER_COMA_WITH_QUOTES) + '\')'
            }, DIVIDER_OR) + ')';
        }

        if (context.RecordType.DeveloperName == CASE_RECORD_TYPE_ER_PERFORMANCE_IMPROVEMENT ||
            context.RecordType.DeveloperName == CASE_RECORD_TYPE_GENERAL_ER_CASE) {
            whereStatement += ' AND (' + String.join(new List<String> {
                'Contact__c = \'' + context.In_Reference_To__c + '\'',
                'In_Reference_To__c = \'' + context.In_Reference_To__c + '\'',
                'Accused__r.Name = \'' + context.In_Reference_To__r.Name + '\''
            }, DIVIDER_OR) + ')';
        }

        return whereStatement;
    }
           /*
    *********************************************************
    @Story          : W-13588822
    @Method Name    : removeUserNonRelatedErCases
    @author         : Dharma Teja
    @description    : We are removing the cases from the list of cases based on the below conditions.
    For the ER_Investigation Record type  we are checking whether the current case rcord value of the Accused_Search_only__c is present in the list of the cases Accused_Search_only__c. 
    For the ER_Performance_Improvement,General_Employee_Relations_Case,Manager_Guidance_CRT Record type  we are checking whether the current case rcord value of the In_Reference_To__r.Name is present in the list of the cases. 
    @param          : List of the all the cases related to ER, Current Case record
    @return         : List of case records
    ********************************************************
    */  
    private static List<Case> removeUserNonRelatedErCases(List<Case> allRelatedCasesForER,Case context){
        List<Case> allFilteredCasesForER = new List<Case>();
        Map<Id,List<String>> caseIdByAccusedPerson= new Map<Id,List<String>>();
        List<String> contextCaseAccusedPerson = new List<string>();
        //Split the Accused_Search_only__c for the ContextCaseRecord
        for(String accusedPerson : context.Accused_Search_only__c.split(',')){
            contextCaseAccusedPerson.add(accusedPerson);
        }
        //Get the Map of the caseIDByAcussedSearchNames
        for(Case caseRecord : allRelatedCasesForER){
            if(caseRecord.Accused_Search_only__c !=null){
                for (String accusedPerson : caseRecord.Accused_Search_only__c.split(',')) {
                    if(caseIdByAccusedPerson.containsKey(caseRecord.Id)){
                        caseIdByAccusedPerson.get(caseRecord.Id).add(accusedPerson);
                    }else{
                        caseIdByAccusedPerson.put(caseRecord.Id,new List<String>{ accusedPerson });
                    }
                }
                
            }
        }
        //
        for(Case caseRecord : allRelatedCasesForER){
            if(context.RecordType.DeveloperName == CASE_RECORD_TYPE_ER_INVESTIGATIONS){
                if(caseRecord.Accused_Search_only__c !=null){
                    for (String accusedPerson : contextCaseAccusedPerson) {
                        if(caseIdByAccusedPerson.get(caseRecord.Id).contains(accusedPerson.trim())){
                            allFilteredCasesForER.add(caseRecord);
                        }
                    }
                }
            }else{
                if(REQUIRED_IN_REFERENCE_TO_RECORD_TYPES.contains(context.RecordType.DeveloperName) && context.In_Reference_To__r.Name!=null){
                    if(caseRecord.Accused_Search_only__c !=null){
                        if(caseIdByAccusedPerson.get(caseRecord.Id).contains(context.In_Reference_To__r.Name)){
                            allFilteredCasesForER.add(caseRecord);
                        }
                    }
                }
                
            }
        }
        return allFilteredCasesForER;
        
    }

    private static Map<String, Map<String, String>> getRecordTypeNamesById() {
        Map<String, Map<String, String>> result = new Map<String, Map<String, String>>();
        List<RecordType> recordTypes = [
            SELECT  Id,
                    Name,
                    DeveloperName
            FROM RecordType
            WHERE SobjectType = :CASE_OBJECT
            AND DeveloperName IN :SUPPORTED_ER_RESTRICTED_RECORD_TYPES
            WITH SECURITY_ENFORCED
            LIMIT :SUPPORTED_ER_RESTRICTED_RECORD_TYPES.size()
        ];

        for (RecordType rt : recordTypes) {
            result.put(rt.Id, new Map<String, String> {
                KEYWORD_RT_NAME           => rt.Name,
                KEYWORD_RT_DEVELOPER_NAME => rt.DeveloperName
            });
        }

        return result;
    }

    public class ResultData {
        @AuraEnabled public String status;
        @AuraEnabled public String message;
        @AuraEnabled public String caseRecordType;
        @AuraEnabled public List<TableColumn> tableColumns;
        @AuraEnabled public List<UIRecordWrapper> records = new List<UIRecordWrapper>();

        public ResultData() {
            this.status = STATUS_SUCCESS;
        }

        public void setError(Exception e) {
            this.status  = STATUS_ERROR;
            this.message = e.getMessage();
        }
    }

    public class TableColumn {
        @AuraEnabled public String label;
        @AuraEnabled public String fieldName;
        @AuraEnabled public String type;
        @AuraEnabled public Boolean isExtraColumn = false;
        public FieldSetMember fsm;

        public TableColumn(String label, String fieldName, String type) {
            this.label     = label;
            this.fieldName = fieldName;
            this.type      = type;
        }

        public TableColumn(FieldSetMember fsm) {
            this.label         = getCorrectReferenceLabel(fsm);
            this.fieldName     = fsm.fieldPath;
            this.type          = String.valueOf(fsm.type);
            this.isExtraColumn = true;
            this.fsm = fsm;
        }

        private String getCorrectReferenceLabel(FieldSetMember fsm) {
            return fsm.fieldPath.contains('.')
                ? (fsm.fieldPath.substringBefore('.').replace('__r', '').replaceAll('_', ' ') + ': ' + fsm.label)
                : fsm.label;
        }
    }

    public class UIRecordWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String caseNumber;
        @AuraEnabled public String ownerId;
        @AuraEnabled public String ownerName;
        @AuraEnabled public String contactId;
        @AuraEnabled public String contactName;
        @AuraEnabled public String inReferenceToId;
        @AuraEnabled public String inReferenceToName;
        @AuraEnabled public String outcome;
        @AuraEnabled public String findings;
        @AuraEnabled public String status;
        @AuraEnabled public String recordType;
        @AuraEnabled public String recordTypeDev;
        @AuraEnabled public Boolean isRestricted = false;
        @AuraEnabled public Boolean isOriginCase = false;
        @AuraEnabled public List<ExtraField> extraFields = new List<ExtraField>();

        public UIRecordWrapper(Case entry, String recordType) {
            this.isOriginCase           = true;
            this.id                     = entry.Id;
            this.caseNumber             = entry.CaseNumber;
            this.ownerId                = entry.OwnerId;
            this.ownerName              = entry.Owner.Name;
            this.recordTypeDev          = entry.RecordType.DeveloperName;
            this.recordType             = entry.RecordType.Name;
            this.status                 = entry.Status;
            this.setERFields(entry, recordType);
            this.setWarmLineFields(entry, recordType);
        }

        public UIRecordWrapper(ER_Restricted_Case__c entry, Integer extraFieldsCount) {
            this.id                 = entry.Id;
            this.caseNumber         = entry.Name.replaceAll(ER_RESTRICTED_CASE_NUMBER_REGEX, '');
            this.ownerName          = entry.Case_Owner__c;
            this.contactId          = entry.Contact__c;
            this.contactName        = this.contactId != null ? entry.Contact__r.Name : null;
            this.inReferenceToId    = entry.In_Reference_To__c;
            this.inReferenceToName  = this.inReferenceToId != null ? entry.In_Reference_To__r.Name : null;
            this.status             = entry.Case_Status__c;
            this.isRestricted       = true;
            this.setEmptyExtraCell(extraFieldsCount);
        }

        private void setEmptyExtraCell(Integer count) {
            for (Integer i = 0;  i < count; i++) {
                this.extraFields.add(new ExtraField());
            }
        }

        private void setWarmLineFields(Case entry, String recordType) {
            if (recordType != CASE_RECORD_TYPE_WARM_LINE) return;
            this.outcome  = entry.ES_DJC_Outcome_of_Plan__c;
            this.findings = entry.Findings__c;
        }

        private void setERFields(Case entry, String recordType) {
            if (!SUPPORTED_ER_RECORD_TYPES.contains(recordType)) return;
            this.contactId          = entry.ContactId;
            this.contactName        = this.contactId != null ? entry.Contact.Name : null;
            this.inReferenceToId    = entry.In_Reference_To__c;
            this.inReferenceToName  = this.inReferenceToId != null ? entry.In_Reference_To__r.Name : null;
            this.isRestricted       = entry.Attorney_client_privilege__c;
        }
    }

//  Might be extended by demands,
//  currently we support only Text Fields
    public class ExtraField {
        @AuraEnabled public String label;
        @AuraEnabled public String fieldPath;
        @AuraEnabled public String valueType;
        @AuraEnabled public Object value;
        @AuraEnabled public Boolean isText;
        @AuraEnabled public Boolean isEmptyCell = true;

        public ExtraField(SObject item, FieldSetMember fsm) {
            this.isEmptyCell = false;
            this.label       = fsm.getLabel();
            this.fieldPath   = fsm.getFieldPath();
            this.valueType   = String.valueOf(fsm.getType());
            this.value       = getCorrectValue(item, this.fieldPath);

            if (this.valueType == FIELD_TYPE_STRING) this.isText = true;
        }
        public ExtraField() {
            this.fieldPath = String.valueOf(Math.random());
        }

        private Object getCorrectValue(SObject item, String fieldPath) {
            if (!fieldPath.contains('.')) return item.get(fieldPath);

            return item.getSObject(fieldPath.substringBefore('.')) != null
                ? item.getSObject(fieldPath.substringBefore('.')).get(fieldPath.substringAfter('.'))
                : null;
        }
    }

    private class ResultException extends Exception { }
}