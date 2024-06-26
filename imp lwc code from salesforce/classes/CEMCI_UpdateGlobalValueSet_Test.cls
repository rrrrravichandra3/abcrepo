@isTest
public class CEMCI_UpdateGlobalValueSet_Test {
  @testSetup
  static void setup() {
    TF2_Business_Site__c testBusinessSite = new TF2_Business_Site__c();
    testBusinessSite.Name = 'Test 1';
    testBusinessSite.Active__c = true;
    testBusinessSite.Country__c = 'USA';
    testBusinessSite.Type__c = 'test';
    testBusinessSite.Street_Address__c = 'test';
    insert testBusinessSite;

    WDR_Job__c testJob = new WDR_Job__c();
    testJob.Name = 'Test 2';
    testJob.Job_Family__c = 'Test Technical';
    testJob.Job_Family_Group__c = 'Test Sofwaree Engineering';
    insert testJob;
  }

  @isTest
  static void test_updatePicklistValuesFromWorkday() {
    Sobject rec = [SELECT Id, Name, Active__c FROM TF2_Business_Site__c WHERE Name = 'Test 1'];
    List<Sobject> recList = new List<SObject>();
    recList.add(rec);
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new CEMCI_HTTPCalloutMock());
    CEMCI_UpdateGlobalValueSet.updatePicklistValuesFromWorkday(recList);
    Test.stopTest();
    CEMCI_Global_Picklist_Map__mdt metaRecord = [
      SELECT Global_Picklist_Id__c
      FROM CEMCI_Global_Picklist_Map__mdt
      WHERE Source_Object_API_Name__c = 'TF2_Business_Site__c'
    ];
    if (metaRecord != null) {
      String requestEndpoint =
        '' +
        URL.getSalesforceBaseUrl().toExternalForm() +
        '/services/data/v47.0/tooling/sobjects/GlobalValueSet/' +
        metaRecord.Global_Picklist_Id__c +
        '';
      HttpResponse res = CEMCI_UpdateGlobalValueSet.sendRequest(requestEndpoint, 'GET', null);
      System.assertEquals(200, res.getStatusCode());
    }
  }
  /*
  @isTest
  static void test_updatePicklistValuesFromWorkdayForJobReq() {
    Sobject rec = [SELECT Id, Name, Job_Family__c, Job_Family_Group__c FROM WDR_Job__c WHERE Name = 'Test 2'];
    List<Sobject> recList = new List<SObject>();
    recList.add(rec);
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new CEMCI_HTTPCalloutMock());
    CEMCI_UpdateGlobalValueSet.updatePicklistValuesFromWorkday(recList);
    Test.stopTest();
    List<CEMCI_Global_Picklist_Map__mdt> metaRecordList = [
      SELECT Global_Picklist_Id__c
      FROM CEMCI_Global_Picklist_Map__mdt
      WHERE Source_Object_API_Name__c = 'WDR_Job__c'
    ];
    if (metaRecordList != null) {
      String requestEndpoint =
        '' +
        URL.getSalesforceBaseUrl().toExternalForm() +
        '/services/data/v47.0/tooling/sobjects/GlobalValueSet/' +
        metaRecordList[0].Global_Picklist_Id__c +
        '';
      HttpResponse res = CEMCI_UpdateGlobalValueSet.sendRequest(requestEndpoint, 'GET', null);
      System.assertEquals(200, res.getStatusCode());
    }
  }
  */
}