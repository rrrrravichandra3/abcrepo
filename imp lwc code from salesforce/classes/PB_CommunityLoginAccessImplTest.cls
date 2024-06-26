@istest
public class PB_CommunityLoginAccessImplTest {

    @testSetup
    static void setup() {
        WDR_TestFactory tf = new WDR_TestFactory();
        tf.createJobApp();
        WDR_Application__c app = [select id,Candidate_Stage__c from WDR_Application__c];
        app.Candidate_Stage__c = 'Placement';
        update app;
    }
    
    @isTest
    static void eligibleJobApp() {
        Test.startTest();
        List<Contact> contacts = [select id,name,email from contact where email = 'test_f_l@salesforce.com'];
        Type t = Type.forName('PB_CommunityLoginAccessImpl');
        R2H_LoginAccessInterface loginImplClass = (R2H_LoginAccessInterface) t.newInstance();
        List<Contact> eligibleConts = loginImplClass.additionalLoginAccessChecks(contacts);
        Test.stopTest();
        System.assertEquals(eligibleConts[0].email,contacts[0].email, 'match contact');
    }
    
    @isTest
    static void inEligibleJobApp() {
        Test.startTest();
        List<Contact> contacts = [select id,name,email from contact where email = 'test_f_l@salesforce.com'];
        WDR_Application__c jobApp = [select Start_Date__c from WDR_Application__c];
        jobApp.Start_Date__c = Date.Today().addDays(45);
        update jobApp;
        Type t = Type.forName('PB_CommunityLoginAccessImpl');
        R2H_LoginAccessInterface loginImplClass = (R2H_LoginAccessInterface) t.newInstance();
        List<Contact> eligibleConts = loginImplClass.additionalLoginAccessChecks(contacts);
        Test.stopTest();
        System.assertEquals(eligibleConts.size(),0, 'not eligible');
    }
}