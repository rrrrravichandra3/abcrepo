/*
*****Written By: Charu Goyal
*****Created On: 06/28/2014
*****Description: Test Class for EIWorkdayRESTControllerJobProfile class
*/

@isTest
private class EIWorkdayRESTControllerJobProfileTest {

public class exemptInfo{
    public string exemptCountry;
    public boolean exempt;
}

public class itemArray{
    public boolean active;
    public string jobTitle;
    public string jobGrade;
    public string jobCode;
    public string managementLevelId;
    public List<exemptInfo> exemptInfos = new List<exemptInfo>();
    public List<String> jobFamilyIds = new List<String>();
    public string summary;
    public List<String> compensationEligibilityRules = new List<String>();
}
public class JSONPacket{
    public string businessObjectName;
    public string businessObjectEvent;
    public List<itemArray> items = new List<itemArray>();
}


  static testMethod void testDoPOST() {
    Job_Family__c newJobFamily = new Job_Family__c(Name = 'Test Job Family', Job_Family_Name__c = 'Test Job Family', Job_Family_Reference_ID__c = 'Test Job Family' );
    insert newJobFamily;
    System.RestContext.request = new RestRequest();
    JSONPacket inputString = new JSONPacket();
    inputString.businessObjectName = 'jobProfile';
    inputString.businessObjectEvent = 'update';
    itemArray item = new itemArray();
    exemptInfo eI = new exemptInfo();
    item.active = true;
    item.jobTitle = 'Employee Benefits Manager';
    item.jobGrade = '7';
    item.jobCode = '134C07';
    item.managementLevelId = 'Professional';
    item.summary = 'test summary';
    item.compensationEligibilityRules.add('Kokua Plan - 20%'); 
    ei.exemptCountry = 'US';
    ei.exempt = true;
    item.exemptInfos.add(ei);
    item.jobFamilyIds.add(newJobFamily.Name);
    inputString.items.add(item);
    String s = JSON.serialize(inputString);
    system.debug('**************s '+ s);
    RestContext.request.requestURI = 'https://dreamjobcentral--pfdev.cs1.my.salesforce.com/services/apexrest/EIWorkdayMetadataJobProfile/';  
    RestContext.request.httpMethod = 'POST';
    RestContext.request.requestBody = blob.ValueOf(s);
    
    system.debug('**************req.requestBody '+ RestContext.request.requestBody);
    Map<String, String> results = EIWorkdayRESTControllerJobProfile.sendJSONPacket();

    System.RestContext.request = new RestRequest();
    JSONPacket inputString1 = new JSONPacket();
    inputString1.businessObjectName = 'jobProfile';
    inputString1.businessObjectEvent = 'delete';
    itemArray item1 = new itemArray();
    exemptInfo eI1 = new exemptInfo();
    item1.active = true;
    item1.jobTitle = 'Employee Benefits Manager';
    item1.jobGrade = '7';
    item1.jobCode = '134C07';
    item1.managementLevelId = 'Professional';
    item.compensationEligibilityRules.add('Kokua Plan - 20%'); 
    ei1.exemptCountry = 'US';
    ei1.exempt = true;
    item1.exemptInfos.add(ei);
    item1.jobFamilyIds.add(newJobFamily.Name);
    inputString1.items.add(item);
    String s1 = JSON.serialize(inputString1);
    system.debug('**************s1 '+ s1);
    RestContext.request.requestURI = 'https://dreamjobcentral--pfdev.cs1.my.salesforce.com/services/apexrest/EIWorkdayMetadataJobProfile/';  
    RestContext.request.httpMethod = 'POST';
    RestContext.request.requestBody = blob.ValueOf(s1);
    
    system.debug('**************req.requestBody '+ RestContext.request.requestBody);
    Map<String, String> results1 = EIWorkdayRESTControllerJobProfile.sendJSONPacket();
    system.debug('************** results1.get(ack) ' + results1.get('ack'));
    system.assertEquals(results1.get('ack'),'NOT OK, Not an Insert or Update operation');

    System.RestContext.request = new RestRequest();
    JSONPacket inputString2 = new JSONPacket();
    inputString2.businessObjectName = 'jobProfile';
    inputString2.businessObjectEvent = 'update';
    itemArray item2 = new itemArray();
    exemptInfo eI2 = new exemptInfo();
    item2.active = true;
    item2.jobTitle = 'Employee Benefits Manager';
    item2.jobGrade = '7';
    item2.jobCode = '';
    item2.managementLevelId = 'Professional';
    item.compensationEligibilityRules.add('Kokua Plan - 20%'); 
    item2.summary = 'test summary';
    ei2.exemptCountry = 'US';
    ei2.exempt = true;
    item2.exemptInfos.add(ei);
    item2.jobFamilyIds.add(newJobFamily.Name);
    inputString2.items.add(item2);
    String s2 = JSON.serialize(inputString2);
    system.debug('**************s2 '+ s2);
    RestContext.request.requestURI = 'https://dreamjobcentral--pfdev.cs1.my.salesforce.com/services/apexrest/EIWorkdayMetadataJobProfile/';  
    RestContext.request.httpMethod = 'POST';
    RestContext.request.requestBody = blob.ValueOf(s2);
    
    system.debug('**************req.requestBody '+ RestContext.request.requestBody);
    Map<String, String> results2 = EIWorkdayRESTControllerJobProfile.sendJSONPacket();    
    
  }
}