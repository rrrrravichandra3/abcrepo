@isTest

public class Test_DJC_MailServicesApp {
      
    
    static testMethod void testCreateCaseAndPackages(){
        ESDJC_TestUtil.init();
        Case ca; 
        List<REWS_Package_Delivery__c> packages = new  List<REWS_Package_Delivery__c>(); 
        RecordType employeeRT = [Select Id from RecordType where sObjectType='Contact' and Name='Employee' LIMIT 1]; 
        Contact con = new Contact(FirstName='TestMailApp',LastName='TestLast',Email='testmailapp@salesforce.com',RecordTypeId = employeeRT.Id);
        insert con; 
        ca = new Case(contactId = con.Id,origin = 'Package Delivery',Type='Mail Services',ES_DJC_Topic__c='Package Delivery',REWS_Received_Location__c='One California',REWS_Sender__c='Amazon',REWS_Carrier__c='USPS',REWS_Oversized__c=true);
        //attach 2 packages..
        packages.add(new REWS_Package_Delivery__c(REWS_Tracking_Number__c='123455',REWS_Status__c ='In Progress'));
        packages.add(new REWS_Package_Delivery__c(REWS_Tracking_Number__c='823455',REWS_Status__c ='In Progress'));
        DJC_MailServicesApp.ResponseWrapper response = new DJC_MailServicesApp.ResponseWrapper(); 
        Test.startTest();
        response = DJC_MailServicesApp.createCaseAndPackages(ca,packages); 
        Test.stopTest(); 
        //assert 
        System.assertEquals(null,response.errorMessage);
        System.assertEquals(false,response.isError);
        System.assertEquals([select caseNumber from case limit 1].caseNumber, response.caseDetail.caseNumber); 
    }
    
    static testMethod void testUpdateCurrentLocation(){
        ESDJC_TestUtil.init();
        Case ca; 
        String result; 
        List<REWS_Package_Delivery__c> packages = new  List<REWS_Package_Delivery__c>(); 
        RecordType employeeRT = [Select Id from RecordType where sObjectType='Contact' and Name='Employee' LIMIT 1]; 
        Contact con = new Contact(FirstName='TestMailApp',LastName='TestLast',Email='testmailapp@salesforce.com',RecordTypeId = employeeRT.Id);
        insert con; 
        ca = new Case(contactId = con.Id,origin = 'Package Delivery',Type='Mail Services',ES_DJC_Topic__c='Package Delivery',REWS_Received_Location__c='One California',REWS_Sender__c='Amazon',REWS_Carrier__c='USPS',REWS_Oversized__c=true);
        insert ca;
        //attach package.. 
        packages.add(new REWS_Package_Delivery__c(Case__c = ca.Id,REWS_Tracking_Number__c='123455',REWS_Status__c ='In Progress'));
        packages.add(new REWS_Package_Delivery__c(Case__c = ca.Id,REWS_Tracking_Number__c='823455',REWS_Status__c ='In Progress'));
        insert packages;
        Test.startTest();
        result = DJC_MailServicesApp.UpdateCurrentLocation(new List<String>{'123455','823455'},'50 Fremont'); 
        Test.stopTest();
        System.assertEquals(DJC_MailServicesApp.SUCCESS_MESSAGE,result);
        System.assertEquals('50 Fremont',[select REWS_Delivery_Location__c from Case where id = : ca.Id].REWS_Delivery_Location__c);
    }
    
    static testMethod void testErrorMessages(){
        ESDJC_TestUtil.init();
        Case ca; 
        String result; 
        List<REWS_Package_Delivery__c> packages = new  List<REWS_Package_Delivery__c>(); 
        RecordType employeeRT = [Select Id from RecordType where sObjectType='Contact' and Name='Employee' LIMIT 1]; 
        Contact con = new Contact(FirstName='TestMailApp',LastName='TestLast',Email='testmailapp@salesforce.com',RecordTypeId = employeeRT.Id);
        insert con; 
        ca = new Case(contactId = con.Id,origin = 'Package Delivery',Type='Mail Services',ES_DJC_Topic__c='Package Delivery',REWS_Received_Location__c='One California',REWS_Sender__c='Amazon',REWS_Carrier__c='USPS',REWS_Oversized__c=true);
        insert ca;
        //attach package.. 
        packages.add(new REWS_Package_Delivery__c(Case__c = ca.Id,REWS_Tracking_Number__c='123455',REWS_Status__c ='In Progress'));
        packages.add(new REWS_Package_Delivery__c(Case__c = ca.Id,REWS_Tracking_Number__c='823455',REWS_Status__c ='In Progress'));
        insert packages;
        Test.startTest();
        result = DJC_MailServicesApp.UpdateCurrentLocation(new List<String>{'123455','823455'},null); 
        Test.stopTest();
        System.assertEquals('Current Location field is required to update package location.',result);
    }

}