@IsTest
private class ESDJC_UpdateDivisionOnContactFlowTest {
    
    static Id empRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employee').getRecordTypeId();
    static Id contractRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contractor').getRecordTypeId();
    
    @TestSetup 
    private static void setup() {
            
        List<String> geoRegions = new List<String>{'APAC','EMEA', 'Japan','LATAM', 'AMER', 'AMER'};     
         
        Account acc = new Account(Name='Test1');
        insert acc;      
        
        //Data setup for Employee Record Type with and without Canada as Mailing Country
        List<Contact> contactList = new List<Contact>();
        for (Integer i = 0; i< geoRegions.size(); i++) {
            Contact con = new Contact(
                AccountID = acc.id,
                Geo_Region__c = geoRegions[i], 
                FirstName = 'Test', 
                LastName = 'User',
                MailingCountry = 'CA',
                email = 'test-user@empemail.com', 
                RecordTypeId= empRecordTypeId
            );
            
            contactList.add(Con);
        }
        
        Contact con1 = new Contact(
            AccountID = acc.id,
            FirstName = 'Test', 
            LastName = 'User',
            MailingCountry = 'US',
            email = 'test-user@empemail.com', 
            RecordTypeId= empRecordTypeId
        );
        
        contactList.add(Con1);
        
        Contact con2 = new Contact(
            AccountID = acc.id,
            FirstName = 'Test', 
            LastName = 'User',
            MailingCountry = 'KR',
            email = 'test-user@empemail.com', 
            RecordTypeId= empRecordTypeId
        );
        
        contactList.add(con2);
        
        //Data setup for Contractor Record Type with and without Canada as Mailing Country
        for (Integer i = 0; i< geoRegions.size(); i++) {
            Contact con = new Contact(
                AccountID = acc.id,
                Geo_Region__c = geoRegions[i], 
                FirstName = 'Test', 
                LastName = 'User',
                MailingCountry = 'US',
                email = 'test-user@empemail.com', 
                RecordTypeId= contractRecTypeId
            );
            
            contactList.add(Con);
        }
        
        
        Contact conCat = new Contact(
            AccountID = acc.id,
            FirstName = 'Test', 
            LastName = 'User',
            MailingCountry = 'CA',
            email = 'test-user@empemail.com', 
            RecordTypeId= contractRecTypeId);
        
        contactList.add(conCat);
        
        Contact conCat1 = new Contact(
            AccountID = acc.id,
            FirstName = 'Test', 
            LastName = 'User',
            MailingCountry = 'KR',
            email = 'test-user@empemail.com', 
            RecordTypeId= contractRecTypeId);
        
        contactList.add(conCat1);
                
        insert contactList;
        
    }
    
    @IsTest
    static void testUpdateDivisionBasedonGeoRegionEmployeeRT() {
        Test.startTest();
        
        List<Contact> contactList = [SELECT Division__c, MailingCountry, Geo_Region__c FROM Contact WHERE RecordTypeId =:empRecordTypeId];
        
        for (contact con:contactList) {
            
            if (con.Geo_Region__c == 'APAC') {
                System.assertEquals('APAC - All Countries', con.Division__c);
            } else if (con.Geo_Region__c == 'EMEA') {
                System.assertEquals('EMEA - All Countries', con.Division__c);
            } else if (con.Geo_Region__c == 'Japan') {
                System.assertEquals('Japan', con.Division__c);
            } else if (con.Geo_Region__c == 'LATAM') {
                System.assertEquals('Americas - Latin America', con.Division__c);
            } else if (con.Geo_Region__c == 'AMER' && !con.MailingCountry.contains('CA')) {
                System.assertEquals('Americas - USA', con.Division__c);
            } else if (con.Geo_Region__c == 'AMER' && con.MailingCountry.contains('CA')) {
                System.assertEquals('Americas - Canada', con.Division__c);
            } else if (con.Geo_Region__c == 'Japan' && con.MailingCountry.contains('KR')) {
                System.assertEquals('APAC - All Countries', con.Division__c);
            }
        }
        
        Test.stopTest();
    }
    
    @IsTest
    static void testUpdateGeoRegionEmployeeRT() {
        Test.startTest();
        
        List<Contact> contactList = [SELECT Division__c, MailingCountry, Geo_Region__c FROM Contact  WHERE RecordTypeId =:empRecordTypeId];
        contactList[0].Geo_Region__c = 'LATAM';
        
        update contactList[0];
        
        List<Contact> contactList1 = [Select id,Division__c FROM Contact WHERE Geo_Region__c='LATAM'  AND RecordTypeId =:empRecordTypeId];      
        System.assertEquals('Americas - Latin America', contactList1[0].Division__c);
        
        Test.stopTest();
    }
    
    @IsTest
    static void testUpdateGeoRegionEmployeeRTNullCheck() {
        Test.startTest();
        
        List<Contact> contactList = [SELECT Division__c, MailingCountry, Geo_Region__c FROM Contact  WHERE  Geo_Region__c = null AND RecordTypeId =:empRecordTypeId];
        
        System.assertEquals(null, contactList[0].Division__c);
        
        Test.stopTest();
    }
    
    @IsTest
    static void testUpdateMailingCountryEmployeeRT() {
        Test.startTest();
        
        List<Contact> contactListNA = [Select id,Division__c,Geo_Region__c FROM Contact WHERE Geo_Region__c='AMER'  AND RecordTypeId =:empRecordTypeId limit 1];
        contactListNA[0].MailingCountry = 'US';
        
        update contactListNA[0];
        
        List<Contact> contactListUSA = [Select id,Division__c FROM Contact WHERE MailingCountry='US' AND RecordTypeId =:empRecordTypeId];
        System.assertEquals('Americas - USA', contactListUSA[0].Division__c);
        
        Test.stopTest();
    }
    
    @IsTest
    static void testUpdateDivisionBasedonGeoRegionContractorRT() {
        Test.startTest();
        
        List<Contact> contactList = [SELECT Division__c, MailingCountry, Geo_Region__c FROM Contact WHERE RecordTypeId =:contractRecTypeId];
        //Verify if Division field is updated
        for (contact con:contactList) {
            
            if (con.Geo_Region__c == 'APAC') {
                System.assertEquals('APAC - All Countries', con.Division__c);
            } else if (con.Geo_Region__c == 'EMEA') {
                System.assertEquals('EMEA - All Countries', con.Division__c);
            } else if (con.Geo_Region__c == 'Japan') {
                System.assertEquals('Japan', con.Division__c);
            } else if (con.Geo_Region__c == 'LATAM') {
                System.assertEquals('Americas - Latin America', con.Division__c);
            } else if (con.Geo_Region__c == 'AMER' && !con.MailingCountry.contains('CA')) {
                System.assertEquals('Americas - USA', con.Division__c);
            } else if (con.Geo_Region__c == 'AMER' && con.MailingCountry.contains('CA')) {
                System.assertEquals('Americas - Canada', con.Division__c);
            }else if (con.Geo_Region__c == 'Japan' && con.MailingCountry.contains('KR')) {
                System.assertEquals('APAC - All Countries', con.Division__c);
            }
        }
        
        Test.stopTest();
    }
    
    @IsTest
    static void testUpdateGeoRegionContractorRT() {
        Test.startTest();
        
        List<Contact> contactList = [SELECT Division__c, MailingCountry, Geo_Region__c FROM Contact  WHERE RecordTypeId =:contractRecTypeId];
        contactList[0].Geo_Region__c = 'APAC';
        
        update contactList[0];
        
        List<Contact> contactList1 = [Select id,Division__c FROM Contact WHERE Geo_Region__c='APAC'  AND RecordTypeId =:contractRecTypeId];      
        System.assertEquals('APAC - All Countries', contactList1[0].Division__c);
        
        Test.stopTest();
    }
    
    @IsTest
    static void testUpdateMailingCountryContractorRT() {
        Test.startTest();
        
        List<Contact> contactListNA = [Select id,Division__c,Geo_Region__c FROM Contact WHERE Geo_Region__c='AMER' AND RecordTypeId =:contractRecTypeId limit 1];
        contactListNA[0].MailingCountry = 'CA';
        
        update contactListNA[0];
        
        List<Contact> contactListUSA = [Select id,Division__c FROM Contact WHERE MailingCountry='CA' AND RecordTypeId =:contractRecTypeId];
        System.assertEquals('Americas - Canada', contactListUSA[0].Division__c);
        
        Test.stopTest();
    }
    
    @IsTest
    static void testUpdateGeoRegionContractorRTNullCheck() {
        Test.startTest();
        List<Contact> contactList = [SELECT Division__c, MailingCountry, Geo_Region__c FROM Contact  WHERE  Geo_Region__c = null AND RecordTypeId =:contractRecTypeId];
        
        System.assertEquals(null, contactList[0].Division__c);
        
        Test.stopTest();
    }
    
}