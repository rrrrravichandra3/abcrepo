public with sharing class NHWSendCaseToSupportforce {
  private static Onboarding_Setting__c onBoardingSetting = Onboarding_Setting__c.getInstance();
  private static Map<String, String> fieldMapping = getAllMapping();


  public static String sendCasesToSf(List<Id> caseIds) {
    String casesToSendJson = prepareSFCasesJSON(caseIds);

    if (casesToSendJson == '')
      return null;

    try {
      HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Onboarding_PF_SF'+'/services/data/v55.0/composite/sobjects/Case/NHW_djc_Record_Id__c/');
            req.setMethod('PATCH');
        	req.setHeader('Content-Type', 'application/json');
            req.setBody(casesToSendJson);
            Http http = new Http();
            HTTPResponse res = http.send(req);      
        List<String> sfCaseIds = new List<String>();
      if (res != null && res.getStatusCode() == 200) {
        System.JSONParser parser = System.JSON.createParser(res.getBody());
        while (parser.nextToken() != null) {
          if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'id')) {
            parser.nextToken();
            sfCaseIds.add(parser.getText());
          }
        }
        if (caseIds.size() == 1 && sfCaseIds.size() == 1) {
          updatePfCaseWithSfId(caseIds[0], sfCaseIds[0]);
        }
        return 'success';
      } else {
        return 'Received response with code other than 200 in sendCasesToSf method for Case Ids = ' +
          String.join(caseIds, ',') +
          ' and response = ' +
          res.getBody();
      }
    } catch (Exception e) {
      return 'Exception while sending Case to Supportforce in sendCasesToSf method ' + e.getMessage();
    }
  }

  public static Map<string, string> getAllMapping() {
    Map<String, String> mapMappingTable = new Map<String, String>();
    try {
      for (NHW_PFtoSF_Case_Field_Mapping__mdt mappingTableRec : NHW_PFtoSF_Case_Field_Mapping__mdt.getall().Values()) {
        if (mappingTableRec.PF_Field_API_Name__c != null && mappingTableRec.SF_Field_API_Name__c != null) {
          mapMappingTable.put(mappingTableRec.PF_Field_API_Name__c, mappingTableRec.SF_Field_API_Name__c);
        }
      }
    } catch (exception ex) {
      /*PF_Logger.log(
        'NHW',
        'ERROR',
        null,
        null,
        'Error during getting NHW_PFtoSF_Case_Field_Mapping__mdt in getAllMapping method and exception is: ' +
        ex.getMessage(),
        'NHWSendCaseToSupportforce'
      );*/
      EventBus.publish(
                        new PF_Logging_Channel__e(
                                ApplicationName__c = 'NHW',
                                LogLevel__c = 'ERROR',
                                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                                ErrorType__c = 'ERROR',
                                Stack_Trace__c = 'NHWSendCaseToSupportforce',
                                Message__c = ex.getMessage(),
                                Error__c = 'Error during getting NHW_PFtoSF_Case_Field_Mapping__mdt in getAllMapping method'
                                )
                        );
    }
    return mapMappingTable;
  }

  public static String convertCasesToJson(List<Case> pfCases) {
    if (!fieldMapping.isEmpty()) {
      JSONGenerator generator = JSON.createGenerator(true);
      generator.writeStartObject();
      generator.writeObjectField('allOrNone', false);
      generator.writeFieldName('records');
      generator.writeStartArray();
      for (Case pfCase : pfCases) {
        generator.writeStartObject();
        generator.writeFieldName('attributes');
        generator.writeStartObject();
        generator.writeObjectField('type', 'Case');
        generator.writeEndObject();
        for (String pfFieldApiName : fieldMapping.keySet()) {
            if(pfCase.get(pfFieldApiName) == null ) {
                          continue;

            } else {
                          generator.writeObjectField(fieldMapping.get(pfFieldApiName), pfCase.get(pfFieldApiName));

            }
        }
        generator.writeEndObject();
      }
      generator.writeEndArray();
      generator.writeEndObject();
      return generator.getAsString();
    } else {
      /*PF_Logger.log(
        'NHW',
        'ERROR',
        null,
        null,
        'Error during JSON generator in convertCasesToJson method',
        'NHWSendCaseToSupportforce'
      );*/
      EventBus.publish(
                        new PF_Logging_Channel__e(
                                ApplicationName__c = 'NHW',
                                LogLevel__c = 'ERROR',
                                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                                ErrorType__c = 'ERROR',
                                Stack_Trace__c = 'NHWSendCaseToSupportforce',
                                Message__c = 'Error during JSON generator in convertCasesToJson method',
                                Error__c = 'Error during JSON generator in convertCasesToJson method'
                                )
                        );
      return '';
    }
  }

  public static String prepareSFCasesJSON(List<Id> pfCaseIds) {
    List<Case> pfCases = null;
    pfCases = [
      SELECT
        Id,
        ESDJC_djc_case__c,
        NH_Business_Site_Lookup__c,
        Subject,
        ES_DJC_Business_Justification__c,
        Origin,
        Company_Agency_Name__c ,
        ESDJC_Supportforce_Case_Id__c ,
        NH_Profile__c,
        NH_SLA_Due_Date__c,
        ESDJC_Case_Owner_Email__c,
        Type,
        ESDJC_Contact_Email__c,
        Description,
        Division__c,
        Internal_Support_Category__c,
        Business_Title__c,
        Business_Unit_NHW__c,
        Computer_Type__c,
        Contractor_Hire_Reason__c,
        Cost_Center_NHW__c,
        Department_Admin_Contact__c,
        Email_Address__c,
        NH_Employee_Id__c,
        NHW_Employee_Type__c,
        End_Date__c,
        Existing_Equipment__c,
        First_Name__c,
        Floor_Location_Cube_Location__c,
        HR_Approved__c,
        NH_Is_Exact_Target__c,
        Job_Status__c,
        Laptop_Type__c,
        Last_Name__c,
        Location_Type__c,
        Manager_Name__c,
        Manager_Name__r.Name,
        Manager_s_Email__c,
        Mobile_Phone_Required__c,
        ESDJC_Supportforce_Case_Number__c ,
        Offer_Type__c,
        Office_Address__c,
        Office_City__c,
        NHW_Coupa_PR__c ,
        ESDJC_Supportforce_Case_Owner__c ,
        Office_Country__c,
        Office_State_Province__c,
        Office_Zip_Postal_Code__c,
        Onboarding_Buddy_Email__c,
        Onboarding_Buddy_Name__c,
        NH_Personal_Email__c,
        Primary_Coverage_Country__c,
        Resource_Type__c,
        NHW_Role__c,
        Company__c,
        CaseNumber,
        Company__r.Name,
        Same_as_Office_Location__c,
        NH_Setup_Similar_To__c,
        NH_Shipping_Local_Contact_Info__c,
        Shipping_Address__c,
        Shipping_City__c,
        Shipping_Country__c,
        Shipping_State__c,
        Shipping_Zip_Postal__c,
        NHW_Start_Date__c,
        NH_Training_Email_Merge__c,
        NHW_Access_Code__c,
        Priority,
        ESDJC_Private_Case_Comment__c,
        Status,
        ES_DJC_Sub_Topic__c,
        ES_DJC_Topic__c,
        Nhw_Submitter__c
      FROM Case
      WHERE Id IN :pfCaseIds
    ];
    if (!pfCases.isEmpty()) {
      return convertCasesToJson(pfCases);
    } else {
      //PF_Logger.log('NHW','ERROR',null,null,'Error provided Case Ids is not exist in PF, prepareSFCasesJSON method','NHWSendCaseToSupportforce');
      EventBus.publish(
                            new PF_Logging_Channel__e(
                                ApplicationName__c = 'NHW',
                                LogLevel__c = 'ERROR',
                                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                                ErrorType__c = 'ERROR',
                                Stack_Trace__c = 'NHWSendCaseToSupportforce',
                                Message__c = 'Error provided Case Ids is not exist in PF, prepareSFCasesJSON method',
                                Error__c = 'Error provided Case Ids is not exist in PF, prepareSFCasesJSON method'
                                )
                        );
      return '';
    }
  }

  public static void updatePfCaseWithSfId(Id pfCaseId, Id sfCaseId) {
    Case pfCase = [SELECT Id, ESDJC_Supportforce_Case_Id__c FROM Case WHERE Id = :pfCaseId];
    if (pfCase != null && pfCase.ESDJC_Supportforce_Case_Id__c == null) {
      pfCase.ESDJC_Supportforce_Case_Id__c = sfCaseId;
      update pfCase;
    }
  }
}