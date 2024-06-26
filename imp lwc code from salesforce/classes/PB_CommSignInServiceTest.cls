@isTest
public class PB_CommSignInServiceTest {
    
    static final Id WDR_CANDIDATE_CNT_RT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('WDR_Candidate').getRecordTypeId();
    
    @testSetup
    static void setup() {
        WDR_TestFactory tf = new WDR_TestFactory();
        tf.createJobApp();
        Account acc = new Account(name = 'Test Account');
        insert acc;
        Contact cont = new Contact(firstname = 'test', lastname = 'contact 2', AccountId = acc.id, email = 'test@test.com', recordtypeId = WDR_CANDIDATE_CNT_RT);
        insert cont;
        
    }
    
    /*******************************************************************************************************
* @description Test for querying contact
*/
    @isTest
    static void getContactTest() {
        Test.startTest();
        WDR_Candidate__c wCand = [select id,email__c from WDR_Candidate__c];
        List<Contact> con = PB_CommSignInService.getContacts(wCand.Email__c);
        System.assertequals(1, con.size(), 'getContactTest');
        System.assertEquals(con[0].email,wCand.Email__c,'Correct Contact retreived');
    }
    
    /*******************************************************************************************************
* @description Test for querying User
*/
    @isTest
    static void getUserTest() {
        UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'CEO' Limit 1];
        User adminUser = [Select Id, UserRoleId From User Where Id=:UserInfo.getUserId() Limit 1];
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        System.runAs(adminUser){
            Account a = new Account(Name='Test Account Name');
            insert a;
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Insiders App Candidate' LIMIT 1];
            List<Contact> wdCont = [select id from Contact where recordtypeid =:WDR_CANDIDATE_CNT_RT ];
            wdCont[0].AccountId = a.id;
            update wdCont;
            User u = new user(alias = 'testvin4', email ='Test_F_L@salesforce.com' , emailencodingkey = 'UTF-8', firstName = 'VinTest', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = portalProfile.Id, contactId = wdCont[0].id, country = 'United States', timezonesidkey = 'America/Los_Angeles', username = 'Test_F_L@salesforce.com');
            insert u;
            Test.startTest();
            List<User> usr = PB_CommSignInService.getUser(u.email);
            System.assertequals(1, usr.size(), 'getUserTest');
            System.assertEquals(usr[0].Id,u.id,'match user');
            Test.stopTest();
        }
    }
    
    /*******************************************************************************************************
* @description Test for access to portal eligibility check
*/
    @isTest
    static void getEligibleContactsTest() {
        
        List<Contact> wdCont = [select id,Email from Contact where recordtypeid =:WDR_CANDIDATE_CNT_RT ];
        WDR_Application__c app = [select id,Candidate_Stage__c,Candidate__r.Candidate_Contact__c from WDR_Application__c];
        Test.startTest();
        System.assertEquals(2,wdCont.size(),'2 contacts');
        app.Candidate_Stage__c = 'Placement';
        update app;
        List<Contact> eliConts = PB_CommSignInService.getEligibleContacts(wdCont);
        System.assertEquals(eliConts.size(),1,'match eligible contacts');
        System.assertEquals(eliConts[0].id,app.Candidate__r.Candidate_Contact__c,'match contact id');
        app.Start_Date__c = Date.Today().addDays(-1);
        update app;
        eliConts = PB_CommSignInService.getEligibleContacts(wdCont);
        System.assertEquals(eliConts.size(),0,'no eligible contacts');
        Test.stopTest();
        
    }
    
    @isTest
    static void createUserTest() {
		WDR_Application__c app = [select id,Candidate_Stage__c,Candidate__r.Candidate_Contact__c from WDR_Application__c];
		Contact wdCont = [select Id,Email,FirstName,LastName from Contact where id =: app.Candidate__r.Candidate_Contact__c];
		Test.startTest();
		User newUser = PB_CommSignInService.createUser(wdCont.Email,wdCont);
        Test.stopTest();
        System.Domain d = System.DomainParser.parse(URL.getOrgDomainUrl());
        Id candidateProfileId = [
            SELECT id
            FROM Profile
            WHERE name = 'Insiders App Candidate'
        ].Id;
        System.assertEquals(newUser.Username,wdCont.Email+'.'+d.getSandBoxName(),'match username');
        System.assertEquals(newUser.ProfileId,candidateProfileId,'match profile');
    }
}