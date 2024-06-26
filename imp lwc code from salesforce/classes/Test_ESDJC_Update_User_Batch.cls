@isTest
public class Test_ESDJC_Update_User_Batch {
    
    static final Integer noOfContacts = 6;
    static final Profile customerportalUserProfile = [select id from Profile where name='Customer Portal Manager Custom' limit 1];
    static final  Profile userProfiles = [select id from Profile where name='System Administrator' limit 1];
    static final Profile employeeProfile = [select id from Profile where name='Employee' limit 1];
    static final Profile preboardingProfileId = [select id from Profile where name='PrePost Employee Experience Site User' limit 1];
    static final Id employeeRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Employee').getRecordTypeId();
    static final String usernameSuffix = 'djctestsuffix.com';    
    static final string empNoforContactWithoutUser = '9999999999';
    static final String wdrCandidateEmail = 'testwdrpersonal@email.com';
    static final String UPDATESTRING = ' update';
	static final Id japanPermSetId = [select id from permissionset where name = 'ES_DJC_Employee_JAPAN' ].Id;
    static final Id apacPermSetId = [select id from permissionset where name = 'ES_DJC_Employee_APAC' ].Id;
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
        List<Contact> cc = new List<Contact>();
        for(INteger i =0;i<noOfContacts;i++) {
            Contact c = new Contact();
            c.FirstName = 'test';
            c.LastName = 'phoenix existing '+i;
            c.email = i+'testsalesforce999@email.com';
            c.Secondary_Email__c = i+'testPersonal999@email.com';
            c.Division__c = 'Americas';
            c.RecordTypeId = employeeRecordTypeId;
            c.EmployeeNumber__c = String.valueOf(Math.round((Math.random() * (9000000) + 1000000)));
            c.Status__c = 'Active';
            c.AccountId = salesforceAcc.Id;
            c.Start_Date__c = Date.Today().addDays(10);
            c.ES_DJC_Cost_Center__c = 'test CC';
            c.ES_DJC_Business_Unit__c = 'test BU';
            c.Title  = 'testTitle';
            c.ES_DJC_Record_Status__c = 'New';
            c.ES_DJC_Grade__c = 'COMP_GRADE_7';
            cc.add(c);
        }
        insert cc;
        
        ESDJC_Integration_Log__c log = new ESDJC_Integration_Log__c(Integration_Status__c='In Progress', Integration_Start_Time__c=Datetime.now(), Integration_Finish_Time__c=Datetime.now());
        insert log;
        ESDJC_New_User_Batch newUserBatch = new ESDJC_New_User_Batch(log);
        Id batchJobId = Database.executeBatch(newUserBatch);
    } 
    
    
    @isTest
    static void testPortalUserUpdationBasicDetails() {
        ESDJC_Integration_Log__c log = new ESDJC_Integration_Log__c(Integration_Status__c='In Progress', Integration_Start_Time__c=Datetime.now(), Integration_Finish_Time__c=Datetime.now());
        insert log;
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
        
        Test.startTest();
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
    
    @isTest
    static void testPortalUserUpdationDeactivation() {
        ESDJC_Integration_Log__c log = new ESDJC_Integration_Log__c(Integration_Status__c='In Progress', Integration_Start_Time__c=Datetime.now(), Integration_Finish_Time__c=Datetime.now());
        insert log;
        List<Contact> empContacts = [Select id,Status__c from Contact];
        Set<Id> contactIds = new Set<Id>();
        for(Contact c:empContacts) {
            c.Status__c = 'Deactive';
            contactIds.add(c.id);
        }
        update empContacts;
         
        Test.startTest();
        ESDJC_Update_User_Batch updateUserBatch = new ESDJC_Update_User_Batch(log);
        Database.executeBatch(updateUserBatch);
        Test.stopTest();
        
        List<User> portalUsersUpdated = new List<User>();
        portalUsersUpdated = [Select Id,IsActive from User where IsPortalEnabled = True and contactId in: contactIds];
        for(User u:portalUsersUpdated) {
           System.assert(!u.IsActive,'user should be deactivated');
        }        
        
    }
    
    @isTest
    static void testPortalUserUpdationDay1() {
        ESDJC_Integration_Log__c log = new ESDJC_Integration_Log__c(Integration_Status__c='In Progress', Integration_Start_Time__c=Datetime.now(), Integration_Finish_Time__c=Datetime.now());
        insert log;
        List<Contact> empContacts = [Select id,Start_date__c from Contact];
        Set<Id> contactIds = new Set<Id>();
        for(Contact c:empContacts) {
            c.Start_date__c = Date.Today();
            contactIds.add(c.id);
        }
        update empContacts;
         
        Test.startTest();
        ESDJC_Update_User_Batch updateUserBatch = new ESDJC_Update_User_Batch(log);
        Database.executeBatch(updateUserBatch);
        Test.stopTest();
        
        List<User> portalUsersUpdated = new List<User>();
        portalUsersUpdated = [Select Id,Email,ProfileId from User where IsPortalEnabled = True and contactId in: contactIds];
        for(User u:portalUsersUpdated) {
           System.assert(u.Email.contains('salesforce'),'user should have salesforce email');
           System.assertEquals(u.ProfileId,customerportalUserProfile.Id,'user should have employee profile');
        }        
        
    }
    
    @isTest
    static void testPortalUserUpdationDivisionChangetoAPAC() {
        ESDJC_Integration_Log__c log = new ESDJC_Integration_Log__c(Integration_Status__c='In Progress', Integration_Start_Time__c=Datetime.now(), Integration_Finish_Time__c=Datetime.now());
        insert log;
        List<Contact> empContacts = [Select id,Start_date__c,Division__c from Contact];
        Contact c = empContacts[5];
            c.Start_date__c = Date.Today();
            c.Division__c = 'APAC';
  
        update c;
         
        Test.startTest();
        ESDJC_Update_User_Batch updateUserBatch = new ESDJC_Update_User_Batch(log);
        Database.executeBatch(updateUserBatch);
        Test.stopTest();
        
         User portalUsersUpdated = [Select Id from User where IsPortalEnabled = True and contactId =: c.id];
        List<PermissionSetAssignment> permSetAssignment = [SELECT AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :portalUsersUpdated.Id and PermissionSetId =: apacPermSetId];
        system.assertEquals(permSetAssignment.size(),1,'user has APAC Perm Set');
        
    }
    
    @isTest
    static void testPortalUserUpdationDivisionChangetoJapan() {
        ESDJC_Integration_Log__c log = new ESDJC_Integration_Log__c(Integration_Status__c='In Progress', Integration_Start_Time__c=Datetime.now(), Integration_Finish_Time__c=Datetime.now());
        insert log;
        List<Contact> empContacts = [Select id,Start_date__c,Division__c from Contact];
        Contact c = empContacts[5];
            c.Start_date__c = Date.Today();
            c.Division__c = 'JAPAN';
  
        update c;
         
        Test.startTest();
        ESDJC_Update_User_Batch updateUserBatch = new ESDJC_Update_User_Batch(log);
        Database.executeBatch(updateUserBatch);
        Test.stopTest();
        
        User portalUsersUpdated = [Select Id from User where IsPortalEnabled = True and contactId =: c.id];
        List<PermissionSetAssignment> permSetAssignment = [SELECT AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :portalUsersUpdated.Id and PermissionSetId =: japanPermSetId];
        system.assertEquals(permSetAssignment.size(),1,'user has Japan Perm Set');
       
        
    }
    
    
}