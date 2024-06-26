public with sharing class CEMCI_UpdateGlobalValueSet {
  public CEMCI_UpdateGlobalValueSet() {
  }

  public static void updatePicklistValuesFromWorkday(List<SObject> recordList) {
    List<CEMCI_Global_Picklist_Map__mdt> metaRecordList;
    Map<String, Map<String, Boolean>> picklistIdToNewValueMap = new Map<String, Map<String, Boolean>>();
    Map<String, CEMCI_Global_Picklist_Map__mdt> metadataRecordMap = new Map<String, CEMCI_Global_Picklist_Map__mdt>();
    Map<String, Boolean> newValueMap;

    if (recordList != null && recordList.size() > 0) {
      metaRecordList = [
        SELECT
          MasterLabel,
          Active_Field_API_Name__c,
          Can_be_deactivated__c,
          Global_Picklist_Id__c,
          Include_Mapping_Record__c,
          Object_Field_API_Name__c,
          Source_Object_API_Name__c
        FROM CEMCI_Global_Picklist_Map__mdt
        WHERE
          Source_Object_API_Name__c = :String.valueOf(recordList.get(0).getSObjectType())
          AND Include_Mapping_Record__c = TRUE
      ];

      if (metaRecordList != null) {
        for (CEMCI_Global_Picklist_Map__mdt metaRecord : metaRecordList) {
          newValueMap = new Map<String, Boolean>();
          if (picklistIdToNewValueMap.containsKey(metaRecord.Global_Picklist_Id__c))
            newValueMap = picklistIdToNewValueMap.get(metaRecord.Global_Picklist_Id__c);
          metadataRecordMap.put(metaRecord.Global_Picklist_Id__c, metaRecord);

          for (SObject recordITem : recordList) {
            if (recordITem.get(metaRecord.Object_Field_API_Name__c) != null) {
              if (metaRecord.Can_be_deactivated__c)
                newValueMap.put(
                  String.valueOf(recordITem.get(metaRecord.Object_Field_API_Name__c)),
                  (Boolean) recordITem.get(metaRecord.Active_Field_API_Name__c)
                );
              else
                newValueMap.put(String.valueOf(recordITem.get(metaRecord.Object_Field_API_Name__c)), null);
            }
          }
          if (!newValueMap.isEmpty())
            picklistIdToNewValueMap.put(metaRecord.Global_Picklist_Id__c, newValueMap);
        }
      }
      if (!picklistIdToNewValueMap.isEmpty())
        processPicklistValuesfromSObject(picklistIdToNewValueMap, metadataRecordMap);
    }
  }

  public static void processPicklistValuesfromSObject(
    Map<String, Map<String, Boolean>> picklistIdToNewValueMap,
    Map<String, CEMCI_Global_Picklist_Map__mdt> metadataRecordMap
  ) {
    for (String globalPicklistId : picklistIdToNewValueMap.keySet()) {
      if (
        metadataRecordMap.get(globalPicklistId) != null &&
        picklistIdToNewValueMap.get(globalPicklistId) != null &&
        !Test.isRunningTest()
      ) {
        List<String> sortedMapKeys = new List<String>(picklistIdToNewValueMap.get(globalPicklistId).keySet());
        processPicklistValues(
          metadataRecordMap.get(globalPicklistId).Global_Picklist_Id__c,
          metadataRecordMap.get(globalPicklistId).MasterLabel,
          picklistIdToNewValueMap.get(globalPicklistId),
          sortedMapKeys
        );
      }
    }
  }

  @future(callout=true)
  public static void processPicklistValues(
    Id globalPicklistId,
    String globalPicklistLabel,
    Map<String, Boolean> newValueMap,
    List<String> sortedMapKeys
  ) {
    Boolean newValueAdded = false;
    //Get the latest picklist values from Org
    HttpResponse calloutResponse = getValueFromSFDC(globalPicklistId);

    if (calloutResponse != null && calloutResponse.getStatusCode() == 200) {
      GlobalValueSetJSON result = (GlobalValueSetJSON) JSON.deserialize(
        calloutResponse.getBody(),
        GlobalValueSetJSON.class
      );
      List<CustomValue> valueList = (List<CustomValue>) result.Metadata.customValue;

      for (CustomValue value : valueList) {
        if (!newValueMap.containsKey(value.label)) {
          newValueMap.put(value.label, value.isActive);
          sortedMapKeys.add(value.label);
        }
      }
      if (valueList.size() < newValueMap.size())
        newValueAdded = true;
    }
    if (newValueAdded) {
      sortedMapKeys.sort();
      GlobalValueSetJSON requestData = new GlobalValueSetJSON();
      List<CustomValue> valueList = new List<CustomValue>();
      for (String newValue : sortedMapKeys) {
        //newValue = newValue.replaceAll('[!@#$%^*()?"{}|<>]', '');
        CustomValue value = new CustomValue();
        value.label = newValue;
        value.valueName = newValue;
        value.isActive = newValueMap.get(newValue);
        valueList.add(value);
      }
      Metadata metadataRecord = new Metadata();
      metadataRecord.customValue = valueList;
      metadataRecord.masterLabel = globalPicklistLabel;
      requestData.Metadata = metadataRecord;
      String picklistValue = JSON.serialize(requestData);
      updateValueInSFDC(picklistValue, globalPicklistId);
    }
  }

  public static HttpResponse getValueFromSFDC(Id globalPicklistId) {
    CEMCI_Settings__c settings = CEMCI_Settings__c.getOrgDefaults();
    String requestEndpoint =
      '' +
      URL.getSalesforceBaseUrl().toExternalForm() +
      '/services/data/' +
      settings.GlobalValueSet_API_Version__c +
      '/tooling/sobjects/GlobalValueSet/' +
      globalPicklistId +
      '';
    String reqMethod = 'GET';
    HttpResponse calloutResponse;

    try {
      calloutResponse = sendRequest(requestEndpoint, reqMethod, null);
    } catch (CalloutException e) {
      PF_Logger.log(
        'CEMCI',
        'Callout Exception Occured',
        e.getMessage(),
        String.valueof(calloutResponse.getStatusCode()),
        null,
        null,
        ' Error during GlobalValueSet update ' +
        ' UserId ' +
        UserInfo.getUserId()
      );
    }
    return calloutResponse;
  }
  public static void updateValueInSFDC(String picklistValue, Id globalPicklistId) {
    String requestEndpoint =
      '' +
      URL.getSalesforceBaseUrl().toExternalForm() +
      '/services/data/v47.0/tooling/sobjects/GlobalValueSet/' +
      globalPicklistId +
      '?_HttpMethod=PATCH';
    String reqMethod = 'POST';
    String reqBody = picklistValue;

    try {
      sendRequest(requestEndpoint, reqMethod, reqBody);
    } catch (CalloutException e) {
      PF_Logger.log(
        'CEMCI',
        'Callout Exception Occured',
        e.getMessage(),
        null,
        null,
        null,
        ' Error during GlobalValueSet update ' +
        ' UserId ' +
        UserInfo.getUserId()
      );
    }
  }
  public static HttpResponse sendRequest(String endpoint, String method, String body) {
    HttpRequest req = new HttpRequest();
    if (body != null)
      req.setBody(body);
    req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
    req.setHeader('Content-Type', 'application/json');
    req.setEndpoint(endpoint);
    req.setMethod(method);
    Http httpreq = new Http();
    HttpResponse res = httpreq.send(req);
    return res;
  }

  public class GlobalValueSetJSON {
    public Metadata Metadata { get; set; }
  }

  public class Metadata {
    public List<CustomValue> customValue { get; set; }
    public String masterLabel { get; set; }
  }

  public class CustomValue {
    public Object color { get; set; }
    public Object description { get; set; }
    public Boolean isActive { get; set; }
    public String label { get; set; }
    public Object urls { get; set; }
    public String valueName { get; set; }
  }
}