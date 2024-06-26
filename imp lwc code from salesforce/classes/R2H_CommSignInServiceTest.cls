@isTest
public class R2H_CommSignInServiceTest {
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
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Portal Manager Standard' LIMIT 1];
            User usr = new user(alias = 'testvin4', email = TEST_EMAIL, emailencodingkey = 'UTF-8', firstName = 'test', lastname = 'contact', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = portalProfile.Id, contactId = con.id, country = 'United States', timezonesidkey = 'America/Los_Angeles', username = 'testvin1234@test.com');
            insert usr;
        }
    }
    
    
    /*******************************************************************************************************
* @description Test for querying contact
*/
    @isTest
    static void getContactTest() {
        Test.startTest();
        Contact c = [select id,email from Contact];      
        R2H_CommSignInService service = new R2H_CommSignInService(communityName);
        List<Contact> con = service.getContacts(c.Email);
        System.debug([Select id,name,recordtype.name from contact]);
        System.assertequals(1, con.size(), 'getContactTest');
        System.assertEquals(con[0].email,c.email,'Correct Contact retreived');
    }
    
    /*******************************************************************************************************
* @description Test for querying User
*/
    @isTest
    static void getUserTest() {
        test.startTest();      
        R2H_CommSignInService service = new R2H_CommSignInService(communityName);
        List<User> usr = service.getUser(TEST_EMAIL);
        System.assertequals(1, usr.size(), 'getUserTest');
        test.stopTest();
    }
    
    /*******************************************************************************************************
* @description Test for create user
*/
    @isTest
    static void createUserTest() {
        test.startTest();
        Contact testContact = [
            SELECT id, name, AccountId, firstname, lastname FROM contact WHERE email =: TEST_EMAIL
        ];
        R2H_CommSignInService service = new R2H_CommSignInService(communityName);
        User u = service.createUser(TEST_EMAIL, testContact);
        System.assertNotEquals(null, u, 'createUserTest');
        test.stopTest();
    }
    
    /*******************************************************************************************************
* @description Test for access to portal eligibility check
*/
    @isTest
    static void getEligibleContactsTest() {
        test.startTest();
        Contact testContact = [
            SELECT id, name, AccountId, firstname, lastname FROM contact WHERE email =: TEST_EMAIL
        ];
        R2H_CommSignInService service = new R2H_CommSignInService(communityName);
        List<Contact> testContactReturn = service.getEligibleContacts(new List<Contact>{testContact});
        System.assertEquals(testContactReturn[0].id,testContact.id,'get eligible contact');
        test.stopTest();
    }
    
    
}