@isTest
global class CEMCI_HTTPCalloutMock implements HttpCalloutMock {
  global HttpResponse respond(HTTPRequest req) {
    CEMCI_UpdateGlobalValueSet.CustomValue testValue = new CEMCI_UpdateGlobalValueSet.CustomValue();
    testValue.label = 'testRecord';
    testValue.valueName = 'testRecord';
    testValue.isActive = true;

    List<CEMCI_UpdateGlobalValueSet.CustomValue> testValueList = new List<CEMCI_UpdateGlobalValueSet.CustomValue>();
    testValueList.add(testValue);

    CEMCI_UpdateGlobalValueSet.Metadata metaRecord = new CEMCI_UpdateGlobalValueSet.Metadata();
    metaRecord.customValue = testValueList;
    metaRecord.masterLabel = 'test';
    CEMCI_UpdateGlobalValueSet.GlobalValueSetJSON responseData = new CEMCI_UpdateGlobalValueSet.GlobalValueSetJSON();
    responseData.Metadata = metaRecord;

    String responseBody = JSON.serialize(responseData);
    HttpResponse res = new HttpResponse();
    res.setStatus('OK');
    res.setStatusCode(200);
    res.setBody(responseBody);
    return res;
  }
}