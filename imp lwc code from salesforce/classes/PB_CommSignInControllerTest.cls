@isTest
public class PB_CommSignInControllerTest {
    
    static final Id WDR_CANDIDATE_CNT_RT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('WDR_Candidate').getRecordTypeId();
    
    @testsetup
    static void setup() {
        WDR_TestFactory tf = new WDR_TestFactory();
        tf.createJobApp();
        WDR_Application__c app = [select id,Candidate_Stage__c from WDR_Application__c];
        app.Candidate_Stage__c = 'Placement';
        update app;
        Account acc = new Account(name = 'Test Account');
        insert acc;
        Contact cont = new Contact(firstname = 'test', lastname = 'contact 2', AccountId = acc.id, email = 'test@test.com', recordtypeId = WDR_CANDIDATE_CNT_RT);
        insert cont;
    }
    
    
    @isTest
    static void invalidEmail() {
        String email = null;
        Test.startTest();
        PB_CommSignInController.ResponseWrapper res = PB_CommSignInController.signInUser(email);
        System.assertEquals(res.errorMessage,'Invalid Email Format','invalid email');
        Test.stopTest();
    }
    
    
    @isTest
    static void invalidcode() {
        String code = null;
        Test.startTest();
        PB_CommSignInController.VerifyWrapper vw = PB_CommSignInController.verifyUser(null, code, null);
        System.assertEquals(vw.message,'Invalid verification code','invalid code');
        Test.stopTest();
    }
    
    @isTest
    static void unAuthorizedNoContact() {
        test.startTest();
        PB_CommSignInController.ResponseWrapper res = PB_CommSignInController.signInUser('test123@test.com');
        System.assertequals(
            'No Contact exists. Pleae use the same email where you received the invitaion.',
            res.errorMessage,'no contact exists'
        );
        Test.stopTest();
    }
    
    @isTest
    static void unAuthorizedNotEligible() {
        test.startTest();
        WDR_Application__c app = [select id,Candidate_Stage__c from WDR_Application__c];
        app.Candidate_Stage__c = 'Pre-Placement';
        update app;
        List<Contact> wdCont = [select id,Email from Contact where recordtypeid =:WDR_CANDIDATE_CNT_RT ];
        PB_CommSignInController.ResponseWrapper res = PB_CommSignInController.signInUser(wdCont[0].Email);
        System.assertequals(
            'Uh-oh! You do not have access to the Community. Please contact Support for help.',
            res.errorMessage,'not eligible'
        );
        Test.stopTest();
    }
    
    @isTest
    static void authorizedRegister() {
        WDR_Application__c app = [select id,Candidate_Stage__c,Candidate__r.Candidate_Contact__r.Email from WDR_Application__c];
        Test.startTest();
        app.Candidate_Stage__c = 'Placement';
        update app;
        PB_CommSignInController.ResponseWrapper res = PB_CommSignInController.signInUser(app.Candidate__r.Candidate_Contact__r.Email);
        PB_CommSignInController.VerifyWrapper vw = PB_CommSignInController.verifyUser(res, '123456', app.Candidate__r.Candidate_Contact__r.Email);
        Test.stopTest();
        System.assertEquals('REGISTER',res.loginFlowType,'register flow');
        System.assert(vw.success,'register success');
        
    }
    
    @isTest
    static void authorizedLogin() {
        WDR_Application__c app = [select id,Candidate_Stage__c,Candidate__r.Candidate_Contact__r.Email,Candidate__r.Candidate_Contact__c from WDR_Application__c];
        Test.startTest();
        UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'CEO' Limit 1];
        User adminUser = [Select Id, UserRoleId From User Where Id=:UserInfo.getUserId() Limit 1];
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        System.runAs(adminUser){
            Account a = new Account(Name='Test Account Name');
            insert a;
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Insiders App Candidate' LIMIT 1];
            Contact wdCont = [select id from Contact where id =: app.Candidate__r.Candidate_Contact__c ];
            wdCont.AccountId = a.id;
            update wdCont;
            User u = new user(alias = 'testvin4', email = app.Candidate__r.Candidate_Contact__r.Email , emailencodingkey = 'UTF-8', firstName = 'VinTest', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = portalProfile.Id, contactId = wdCont.id, country = 'United States', timezonesidkey = 'America/Los_Angeles', username = 'Test_F_L@salesforce.com');
            insert u;
            PB_CommSignInController.ResponseWrapper res = PB_CommSignInController.signInUser(app.Candidate__r.Candidate_Contact__r.Email);
            PB_CommSignInController.VerifyWrapper vw = PB_CommSignInController.verifyUser(res, '123456', app.Candidate__r.Candidate_Contact__r.Email);
            Test.stopTest();
            System.assertEquals('SIGNIN',res.loginFlowType,'login flow');
            System.assert(vw.success,'login success');
            
        }
    }
}