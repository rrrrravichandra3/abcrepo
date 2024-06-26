/**
 * @description       :
 * @author            : Urvish Shah (ushah)
 * @group             :
 * @last modified on  : 01-20-2023
 * @last modified by  : Urvish Shah (ushah)
 **/
public with sharing class CEMCI_soslSearch {
  /**
   * @description soslSearch : Get Contact results based on all search text and search criteria using SOSL search
   * @param  keywordSearch : Boolean search text enter on UI by user
   * @param  clauses : All filter data entered by user in the form of CEMCI_CandidateCardController.ClauseWrapper wrapper
   * @return return Contact results as List
   */
  public static List<Contact> soslSearch(
    String keywordSearch,
    List<CEMCI_SearchDataModel.ClauseWrapper> clauses,
    Integer limitSize,
    Integer offset
  ) {
    Id rtId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('WDR_Candidate').getRecordTypeId();

    String whereClause = '';
    String searchQuery =
      'FIND \'' +
      string.escapeSingleQuotes(keywordSearch) +
      '\'' +
      ' IN ALL FIELDS RETURNING Contact(Id,' +
      'Email,Phone,Name,Title,Candidate_Stage__c,' +
      'Account.Name,URM__c,URG__c,WD_Candidate_Source__c,Linkedin_Profile__c,' +
      'LinkedIn_Profile_URL__c,IsValid_LinkedIn_URL__c,Boomerang__c,MRS_App__r.Gender__c,' +
      'MRS_App__r.Job__r.Name,MRS_App__r.Application_Date__c,' +
      'Silver_Medalist__c, Text_Resume__c ';

    if (clauses != null) {
      List<CEMCI_whereClauseGenerator> whereClauses = new List<CEMCI_whereClauseGenerator>();
      List<CEMCI_whereClauseGenerator> tagsWhereClauses = new List<CEMCI_whereClauseGenerator>();
      String locationWhere = '';
      for (CEMCI_SearchDataModel.ClauseWrapper clause : clauses) {
        CEMCI_whereClauseGenerator gen = new CEMCI_whereClauseGenerator(clause);
        if (clause.field.equalsIgnoreCase('tags__c')) {
          tagsWhereClauses.add(gen);
        } else if (clause.field.equalsIgnoreCase('Location__c')) {
          locationWhere = new CEMCI_whereClauseGenerator().generateLocationQuery(gen);
        } else {
          whereClauses.add(gen);
        }
      }
      String whereQuery =
        'WHERE (' +
        locationWhere +
        new CEMCI_whereClauseGenerator().generateWhereQuery(whereClauses, tagsWhereClauses) +
        ')';
      searchQuery += whereQuery;
    }
    searchQuery += ' LIMIT ' + limitSize + ' OFFSET ' + offset + ')';

    List<List<Object>> objectsData = new List<List<Object>>();
    datetime qryStart;
    datetime qryEnd;
    try {
      qryStart = datetime.now();
      objectsData = Search.query(searchQuery);
      qryEnd = datetime.now();
      EventBus.publish(
        new PF_Logging_Channel__e(
          ApplicationName__c = 'CEMCI',
          LogLevel__c = 'Success',
          Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
          Message__c = 'Candidate Search SOSL Executed: ' + searchQuery
        )
      );
    } catch (Exception e) {
      qryEnd = datetime.now();
      EventBus.publish(
        new PF_Logging_Channel__e(
          ApplicationName__c = 'CEMCI',
          LogLevel__c = 'Error',
          Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
          ErrorType__c = e.getTypeName(),
          Stack_Trace__c = e.getStackTraceString(),
          Message__c = 'Candidate Search SOSL Exception: ' + searchQuery,
          Error__c = e.getMessage()
        )
      );
      throw new AuraHandledException(e.getMessage());
    }
    List<Contact> listCons = (Contact[]) objectsData[0];

    return listCons;
  }

  /**
   * @description soslSearch : Get Contact results based on all search criteria ONLY using SOQL
   * @param  clauses : All filter data entered by user in the form of CEMCI_SearchDataModel.ClauseWrapper wrapper
   * @return return Contact results as List
   */
  public static List<Contact> soqlSearch(
    List<CEMCI_SearchDataModel.ClauseWrapper> clauses,
    Integer limitSize,
    Integer offset
  ) {
    Id rtId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('WDR_Candidate').getRecordTypeId();
    String whereClause = '';
    String searchQuery =
      'SELECT Id,' +
      'Email,Phone,Name,Title,Candidate_Stage__c,' +
      'Account.Name,URM__c,URG__c,WD_Candidate_Source__c,Linkedin_Profile__c,' +
      'LinkedIn_Profile_URL__c,IsValid_LinkedIn_URL__c,Boomerang__c,MRS_App__r.Gender__c,' +
      'MRS_App__r.Job__r.Name,MRS_App__r.Application_Date__c,' +
      'Silver_Medalist__c, Text_Resume__c FROM CONTACT ';

    if (clauses != null) {
      String locationWhere = '';
      List<CEMCI_whereClauseGenerator> whereClauses = new List<CEMCI_whereClauseGenerator>();
      List<CEMCI_whereClauseGenerator> tagsWhereClauses = new List<CEMCI_whereClauseGenerator>();
      for (CEMCI_SearchDataModel.ClauseWrapper clause : clauses) {
        CEMCI_whereClauseGenerator gen = new CEMCI_whereClauseGenerator(clause);
        if (clause.field.equalsIgnoreCase('tags__c')) {
          tagsWhereClauses.add(gen);
        } else if (clause.field.equalsIgnoreCase('Location__c')) {
          locationWhere = new CEMCI_whereClauseGenerator().generateLocationQuery(gen);
        } else {
          whereClauses.add(gen);
        }
      }
      String whereQuery =
        'WHERE (' +
        locationWhere +
        new CEMCI_whereClauseGenerator().generateWhereQuery(whereClauses, tagsWhereClauses) +
        ')';
      searchQuery += whereQuery;
    }
    searchQuery += ' LIMIT ' + limitSize + ' OFFSET ' + offset;
    List<Contact> listCons = new List<Contact>();
    datetime qryStart;
    datetime qryEnd;
    try {
      qryStart = datetime.now();
      listCons = Database.query(searchQuery);
      qryEnd = datetime.now();
      EventBus.publish(
        new PF_Logging_Channel__e(
          ApplicationName__c = 'CEMCI',
          LogLevel__c = 'Success',
          Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
          Message__c = 'Candidate Search SOQL Executed: ' + searchQuery
        )
      );
    } catch (Exception e) {
      qryEnd = datetime.now();
      EventBus.publish(
        new PF_Logging_Channel__e(
          ApplicationName__c = 'CEMCI',
          LogLevel__c = 'Error',
          Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
          ErrorType__c = e.getTypeName(),
          Stack_Trace__c = e.getStackTraceString(),
          Message__c = 'Candidate Search SOQL Exception: ' + searchQuery,
          Error__c = e.getMessage()
        )
      );
      throw new AuraHandledException(e.getMessage());
    }
    return listCons;
  }
}