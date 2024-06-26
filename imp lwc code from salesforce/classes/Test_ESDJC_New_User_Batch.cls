@isTest
public class Test_ESDJC_New_User_Batch {
    
    static final Integer noOfContacts = 6;
    static final Profile customerportalUserProfile = [select id from Profile where name='Customer Portal Manager Custom' limit 1];
    static final  Profile userProfiles = [select id from Profile where name='System Administrator' limit 1];
    static final Profile employeeProfile = [select id from Profile where name='Employee' limit 1];
    static final Profile preboardingProfileId = [select id from Profile where name='PrePost Employee Experience Site User' limit 1];
    static final Id employeeRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employee').getRecordTypeId();
    static final Id candidateRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('WDR_Candidate').getRecordTypeId();
    static final String usernameSuffix = 'djctestsuffix.com';    
    static final string empNoforContactWithoutSecondaryEmail = '9999999999';
    static final String wdrCandidateEmail = 'testwdrpersonal@email.com';
    static final String IN_PROGRESS = 'In Progress';
    static final Id japanPermSetId = [select id from permissionset where name = 'ES_DJC_Employee_JAPAN' ].Id;
    static final Id apacPermSetId = [select id from permissionset where name = 'ES_DJC_Employee_APAC' ].Id;
    static final String UPDATESTRING = ' update';
    
    @testSetup
    static void testSetup() {
        ESDJC_Settings__c setting = new ESDJC_Settings__c(SSO_Dreamjobcentral_ID__c = usernameSuffix,Update_User_Batch_Record_Limit__c = 2000,Site_URL__c = 'testURL'
                                                          ,Phoenix_ESDJC_Batch_Cutoff_Date__c = '2024-06-18 00:00:00', Portal_User_Profile_Id__c = customerportalUserProfile.Id,
                                                          Portal_User_Japan_Permset_Id__c = japanPermSetId, Portal_User_APAC_Permset_Id__c = apacPermSetId,
                                                          Preboarding_LanguageLocaleKey__c = 'en_US', Preboarding_LocaleSidKey__c = 'en_US', Preboarding_TimeZoneSidKey__c = 'America/Los_Angeles',
                                                          Preboarding_EmailEncodingKey__c = 'ISO-8859-1', Preboarding_ProfileId__c = preboardingProfileId.Id,BU_Exclusion_list__c ='testBU');
        insert setting; 
        
        Account salesforceAcc = new Account(Name='Salesforce', CurrencyIsoCode='USD');
        insert salesforceAcc;
        insert new Contact(Status__c= 'Active', Email = wdrCandidateEmail, LastName='wdr LastName', AccountId= salesforceAcc.Id, EmployeeNumber__c = empNoforContactWithoutSecondaryEmail, RecordTypeId=candidateRecordTypeId);
        List<Contact> cc = new List<Contact>();
        for(INteger i =0;i<noOfContacts;i++) {
            Contact c = new Contact();
            c.FirstName = 'test';
            c.LastName = 'phoenix new '+i;
            c.email = i+'testsalesforce789@email.com';
            c.Secondary_Email__c = i+'testPersonal789@email.com';
            c.Division__c = 'Americas';
            c.RecordTypeId = employeeRecordTypeId;
            c.EmployeeNumber__c = String.valueOf(Math.round((Math.random() * (9000000) + 1000000)));
             if(i == 2) {
                c.Secondary_Email__c = null;
                c.EmployeeNumber__c = empNoforContactWithoutSecondaryEmail;
            }
            c.Status__c = 'Active';
            c.AccountId = salesforceAcc.Id;
            c.Start_Date__c = Date.Today().addDays(10);
            if(i==5) {
                c.Start_Date__c = Date.Today();
            }
            c.ES_DJC_Record_Status__c = 'New';
            c.ES_DJC_Grade__c = 'COMP_GRADE_7';
            c.ES_DJC_Cost_Center__c = 'test CC 1';
            c.ES_DJC_Business_Unit__c = 'test BU 1';
            c.Title  = 'testTitle';
            cc.add(c);
        }
        insert cc;
    } 
    
    @isTest
    static void testNewPortalUserCreation() {

        ESDJC_Integration_Log__c log = new ESDJC_Integration_Log__c(Integration_Status__c=IN_PROGRESS, Integration_Start_Time__c=Datetime.now(), Integration_Finish_Time__c=Datetime.now());
        
        Test.startTest();
        insert log;
        ESDJC_New_User_Batch newUserBatch = new ESDJC_New_User_Batch(log);
        Database.executeBatch(newUserBatch);
        Test.stopTest();
        
        List<Contact> contactIds = [select id from Contact];
        List<User> portalUsersCreated = new List<User>();
        portalUsersCreated = [Select Id,Username,Email,profileId,Contact.Start_date__c,Contact.Secondary_Email__c from User where IsPortalEnabled = True and contactId in: contactIds];
        System.assertEquals(noOfContacts,portalUsersCreated.size(),'users created for all contacts');
        for(User u:portalUsersCreated) {
            if(u.Contact.Start_Date__c == Date.Today()) {
                System.assertEquals(u.ProfileId,customerportalUserProfile.Id,'assert profile is customer portal if start date = today');
                System.assert(u.Email.Contains('salesforce'),'assert if profile = custom then email = salesforce');
            } else {
                System.debug(u.Email);
                System.assertEquals(u.ProfileId,preboardingProfileId.Id,'assert profile is preboarding if start date > today');
                System.assert(u.Email.Contains('personal'),'assert if profile = preboarding then email = personal');
            }
            if(u.Contact.Secondary_Email__c == null) {
                System.assertEquals(u.Email,wdrCandidateEmail,'assert if personal is filled from wdr candidate if there is no secondary email');
            }
            System.assert(u.Username.contains(usernameSuffix),'assert users have djc username');
        }
    }
    
    @isTest
    static void testNewPortalUserCreationRehire() {
        List<Contact> contacts = [select employeenumber__c,Secondary_Email__c from contact where recordtypeId =: employeeRecordTypeId];

        User rehireUser = new User(alias = 'standt',email='testrehireuser1234salesforce@email.com',emailencodingkey='UTF-8',lastname='rehireuser1234', 
                                      languagelocalekey='en_US',localesidkey='en_US', profileid = customerportalUserProfile.id, contactId = contacts[3].Id,
                                      timezonesidkey='America/Los_Angeles',username='rehireuser1234NewBatch@dreamjobcentral.com', EmployeeNumber= contacts[3].employeenumber__c,IsActive = false);
        
        
        ESDJC_Integration_Log__c log = new ESDJC_Integration_Log__c(Integration_Status__c=IN_PROGRESS, Integration_Start_Time__c=Datetime.now(), Integration_Finish_Time__c=Datetime.now());
        
        Test.startTest();
        insert log;
        
        insert rehireUser;
        ESDJC_New_User_Batch newUserBatch = new ESDJC_New_User_Batch(log);
        Database.executeBatch(newUserBatch);
        Test.stopTest();
       
        List<Contact> contactIds = [select id from Contact];
        List<User> portalUsersCreated = new List<User>();
        portalUsersCreated = [Select Id,Username,Email,profileId,Contact.Start_date__c,Contact.Secondary_Email__c from User where IsPortalEnabled = True and contactId in: contactIds];
        rehireUser = [select Id,IsActive,profileId,Email from user where id =: rehireUser.Id];
        System.assertEquals(noOfContacts,portalUsersCreated.size(),'users created for all contacts');
        System.assertEquals(rehireUser.IsActive,true,'portal user reactivated');
		System.assertEquals(rehireUser.profileId,preboardingProfileId.Id,'portal user has preboarding profile');    
        System.assertEquals(rehireUser.Email,contacts[3].Secondary_Email__c,'portal user has correct email');    
        
    }
    
    
    @isTest
    static void testNewPortalUserCreationFailureNoEmployeeNumber() {
        List<Contact> contacts = [select employeenumber__c from contact];
        for(Contact c:contacts) {
            c.employeenumber__c = null;
        }
        
        update contacts;
        
        ESDJC_Integration_Log__c log = new ESDJC_Integration_Log__c(Integration_Status__c=IN_PROGRESS, Integration_Start_Time__c=Datetime.now(), Integration_Finish_Time__c=Datetime.now());
        
        Test.startTest();
        insert log;
        ESDJC_New_User_Batch newUserBatch = new ESDJC_New_User_Batch(log);
        Database.executeBatch(newUserBatch);
        Test.stopTest();
       
        List<Contact> contactIds = [select id from Contact];
        List<User> portalUsersCreated = new List<User>();
        portalUsersCreated = [Select Id,Username,Email,profileId,Contact.Start_date__c,Contact.Secondary_Email__c from User where IsPortalEnabled = True and contactId in: contactIds];
        System.assertEquals(0,portalUsersCreated.size(),'users created for no contacts');
        
    }
    
    @isTest
    static void testNewPortalUserCreationFailureBUExclusion() {
        List<Contact> contacts = [select ES_DJC_Business_Unit__c from contact];
        for(Contact c:contacts) {
            c.ES_DJC_Business_Unit__c = 'testBU';
        }
        
        update contacts;
        
        ESDJC_Integration_Log__c log = new ESDJC_Integration_Log__c(Integration_Status__c=IN_PROGRESS, Integration_Start_Time__c=Datetime.now(), Integration_Finish_Time__c=Datetime.now());
        
        Test.startTest();
        insert log;
        ESDJC_New_User_Batch newUserBatch = new ESDJC_New_User_Batch(log);
        Database.executeBatch(newUserBatch);
        Test.stopTest();
       
        List<Contact> contactIds = [select id from Contact];
        List<User> portalUsersCreated = new List<User>();
        portalUsersCreated = [Select Id,Username,Email,profileId,Contact.Start_date__c,Contact.Secondary_Email__c from User where IsPortalEnabled = True and contactId in: contactIds];
        System.assertEquals(0,portalUsersCreated.size(),'users created for no contacts');
        
    }
    
    @isTest
    static void testPortalUserUpdationBasicDetails() {
       
        Test.startTest();
        ESDJC_Integration_Log__c log = new ESDJC_Integration_Log__c(Integration_Status__c='In Progress', Integration_Start_Time__c=Datetime.now(), Integration_Finish_Time__c=Datetime.now());
        insert log;
        ESDJC_New_User_Batch newUserBatch = new ESDJC_New_User_Batch(log);
        Database.executeBatch(newUserBatch);
        List<Contact> empContacts = [Select id,FirstName,LastName,Title,EmployeeNumber__c,ES_DJC_Business_Unit__c,ES_DJC_Cost_Center__c from Contact];
        Set<Id> contactIds = new Set<Id>();
        for(Contact c:empContacts) {
            c.FirstName = c.FirstName + UPDATESTRING;
            c.LastName = c.LastName + UPDATESTRING;
            c.Title = c.Title + UPDATESTRING;
           	c.ES_DJC_Business_Unit__c = c.ES_DJC_Business_Unit__c + UPDATESTRING;
            c.ES_DJC_Cost_Center__c = c.ES_DJC_Cost_Center__c + UPDATESTRING;
            contactIds.add(c.Id);
        }
        
        update empContacts;
        User portalUser =[Select Id,FirstName,LastName,Title,Business_Unit__c,Cost_Center__c,EmployeeNumber from User where IsPortalEnabled = True and contactId in: contactIds][5];
        portalUser.employeenumber = null;
        system.runas(new User(Id = Userinfo.getUserId())) {
            update portalUser;
        }
        ESDJC_Update_User_Batch updateUserBatch = new ESDJC_Update_User_Batch(log);
        Database.executeBatch(updateUserBatch);
        Test.stopTest();
        
        List<User> portalUsersUpdated = new List<User>();
        portalUsersUpdated = [Select Id,FirstName,LastName,Title,Business_Unit__c,Cost_Center__c from User where IsPortalEnabled = True and contactId in: contactIds and employeenumber != null];
        for(User u:portalUsersUpdated) {
            system.assert(u.FirstName.Contains(UPDATESTRING),'first name updated');
            System.assert(u.LastName.Contains(UPDATESTRING),'last name updated');
            System.assert(u.Title.Contains(UPDATESTRING),'title updated');
            System.assert(u.Business_Unit__c.Contains(UPDATESTRING),'Business unit updated');
            System.assert(u.Cost_Center__c.Contains(UPDATESTRING),'Cost center updated');
        }        
        
    }
    
}