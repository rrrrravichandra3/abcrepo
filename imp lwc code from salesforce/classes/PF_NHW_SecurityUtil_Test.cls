/**
 * Created by egnocchi on 4/9/18.
 */
@isTest
public with sharing class PF_NHW_SecurityUtil_Test {

    private static testMethod void testGetDataToClone() {
        RecordType employeeRT = [Select Id from RecordType where sObjectType='Contact' and Name='Employee' LIMIT 1];
        Contact con = new Contact(FirstName='TestMailApp',LastName='TestLast',Email='testmailapp@salesforce.com',RecordTypeId = employeeRT.Id);
        insert con;
		Case ca;
        List<REWS_Package_Delivery__c> packages = new  List<REWS_Package_Delivery__c>();
        ca = new Case(contactId = con.Id,origin = 'Package Delivery',Type='Mail Services',Manager_s_Email__c =UserInfo.getUserEmail(), ES_DJC_Topic__c='Package Delivery',NHW_Employee_Type__c='relocation',REWS_Received_Location__c='Landmark',REWS_Sender__c='Amazon',REWS_Carrier__c='USPS',REWS_Oversized__c=true);
        insert ca;
        try {
            PF_NHW_SecurityUtil.checkUserHasAccessToCase(ca);
        }
        catch (Exception unexpectedException)
        {
            system.assert(false, 'Exceptions should be handled by the method');
        }
    }
}