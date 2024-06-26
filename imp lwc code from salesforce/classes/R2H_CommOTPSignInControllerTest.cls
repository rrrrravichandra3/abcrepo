@isTest
public class R2H_CommOTPSignInControllerTest {
    public static string candidateRTName;
    public static string candidateRTId;
	public static String communityName{
        get{
            if(communityName == null){
                if (Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().containskey('CandidateScratch')) {
                    communityName = 'Test_Comm_Scratch';
                } else {
                    communityName = 'Test_Comm';
                }   
            }
            return communityName;
        }
        set;
    }
    
    static final String TEST_EMAIL = 'test@email.com';

    
    @testSetup
    static void setup() {
        UserRole ur = new UserRole(Name = 'CEO');
        insert ur;
        User thisUser = new User(Id = UserInfo.getUserId(), UserRoleId = ur.Id);
        update thisUser;
        if (Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().containskey('CandidateScratch')) {
            // This is scratch org/packaging org
            candidateRTName = 'CandidateScratch';
        } else {
            candidateRTName = 'WDR_Candidate';
        }
        candidateRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(candidateRTName).getRecordTypeId();
        System.runAs(thisUser) {
            Account acc = new Account(name = 'Test Account');
            insert acc;
            Contact con = new Contact(firstname = 'test', lastname = 'contact', AccountId = acc.id, email = TEST_EMAIL, recordtypeId = candidateRTId);
            insert con;
            Contact con2 = new Contact(firstname = 'tst', lastname = 'contact', AccountId = acc.id, email = 'test2@email.com', recordtypeId = candidateRTId);
            insert con2;
            Contact con3 = new Contact(firstname = 'test 3', lastname = 'contact', AccountId = acc.id, email = 'test3@email.com', recordtypeId = candidateRTId);
            insert con3;
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Portal Manager Standard' LIMIT 1];
            User usr = new user(alias = 'testvin4', email = TEST_EMAIL, emailencodingkey = 'UTF-8', firstName = 'test', lastname = 'contact', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = portalProfile.Id, contactId = con.id, country = 'United States', timezonesidkey = 'America/Los_Angeles', username = 'testvin1234@test.com');
            insert usr;
        }
    }
    
   //validate wrong email format
    @isTest
    static void invalidEmail() {
        String email = null;
        Test.startTest();
        R2H_CommOTPSignInController.ResponseWrapper res = R2H_CommOTPSignInController.signInUser(email,communityName);
        System.assertEquals(res.errorMessage,'Invalid Email Format','invalid email');
        Test.stopTest();
    }
    
     //validate wrong code format
    @isTest
    static void invalidcode() {
        String code = null;
        Test.startTest();
        R2H_CommOTPSignInController.VerifyWrapper vw = R2H_CommOTPSignInController.verifyUser(null, code, null);
        System.assertEquals(vw.message,'Invalid verification code','invalid code');
        Test.stopTest();
    }
    
        //validate access when no associated contact exists for input email
    @isTest
    static void unAuthorizedNoContact() {
        test.startTest();
        R2H_CommOTPSignInController.ResponseWrapper res = R2H_CommOTPSignInController.signInUser('nocontact@test.com',communityName);
        System.assertequals(
            'No Contact exists. Pleae use the same email where you received the invitaion.',
            res.errorMessage,'no contact exists'
        );
        Test.stopTest();
    }
    
     //validate access when no eligible contact exists for input email
    @isTest
    static void unAuthorizedNotEligible() {
        test.startTest();
        Contact c = [select id,email,name,firstname, lastname from contact where firstname = 'tst'];
        R2H_CommOTPSignInController.ResponseWrapper res = R2H_CommOTPSignInController.signInUser(c.Email,communityName);
        System.assertequals(
            'Uh-oh! You do not have access to the Community. Please contact Support for help.',
            res.errorMessage,'not eligible'
        );
        Test.stopTest();
    }
    
     //validate access when contact is eligible and user is not already present
    @isTest
    static void authorizedRegister() {
        Test.startTest();
        Contact c = [select id,email,name,firstname, lastname from contact where firstname = 'test 3'];
        R2H_CommOTPSignInController.ResponseWrapper res = R2H_CommOTPSignInController.signInUser(c.Email,communityName);
        R2H_CommOTPSignInController.VerifyWrapper vw = R2H_CommOTPSignInController.verifyUser(res, '123456', c.Email);
        Test.stopTest();
        System.assertEquals('REGISTER',res.loginFlowType,'register flow');
        System.assert(vw.success,'register success');
        
    }
    
         //validate access when contact is eligible and user is not already present
    @isTest
    static void authorizedLogin() {
        Test.startTest();
        Contact c = [select id,email,name,firstname, lastname from contact where firstname = 'test'];
        R2H_CommOTPSignInController.ResponseWrapper res = R2H_CommOTPSignInController.signInUser(c.Email,communityName);
        R2H_CommOTPSignInController.VerifyWrapper vw = R2H_CommOTPSignInController.verifyUser(res, '123456', c.Email);
        Test.stopTest();
        System.assertEquals('SIGNIN',res.loginFlowType,'login flow');
        System.assert(vw.success,'login success');
        
    }
    
    
    
}