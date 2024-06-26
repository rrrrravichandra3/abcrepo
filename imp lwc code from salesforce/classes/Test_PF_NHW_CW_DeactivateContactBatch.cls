@isTest
public class Test_PF_NHW_CW_DeactivateContactBatch {
    
    //WD4S -deactivate contacts whose term dates are up
    @istest
    public static void deactivateContacts() {
        List<Contact> contacts = new List<Contact>();
        for(Integer i=0;i<10;i++) {
            contacts.add(new Contact(LastName = 'test'+i,Recordtypeid = NHW_Util.getContractorContactRecordTypeId(),
                                       Status__c = 'Active', 
                                     Term_Date__c = i < 8 ? System.today().addDays(-10) : System.today().addDays(10)));
        }
        insert contacts;
        
        Test.startTest();
        NHW_CW_DeactivateContactBatch batch = new NHW_CW_DeactivateContactBatch();
        Database.executeBatch(batch);
        Test.stopTest();
        contacts = [select id,CW_Work_Order_Status__c,Term_Date__c from contact where recordtypeid=:NHW_Util.getContractorContactRecordTypeId()];
        for(Contact c:contacts) {
            if(c.Term_Date__c <= System.today()) {
                System.assertEquals(c.CW_Work_Order_Status__c, 'Closed');
            } else {
                System.assertNotEquals(c.CW_Work_Order_Status__c, 'Closed');
                
            }
        }
    }
}