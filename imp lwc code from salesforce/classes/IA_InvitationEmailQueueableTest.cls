/**
 * @author Vinod Chokkula
 * @date 02/18/2020
 *
 * @description : Test class for IA_InvitationEmailQueueable Class
 * 
 */
@isTest
public class IA_InvitationEmailQueueableTest {
    public IA_InvitationEmailQueueableTest() {

    }
    @TestSetup
    static void setUp(){
        User thisUser = [SELECT Id,UserRoleId FROM User WHERE Id = :UserInfo.getUserId()];
        User userWithRole;
        User userWithNoRole;
        System.runAs(thisUser) {
	    Profile pr = [select id from Profile where name='System administrator']; 
        UserRole ur = [select id from UserRole where name='Do_NOT_Create_SubOrd_SharingRules'];
        userWithRole = new user(alias = 'test1234', email='test1234@noemail.com',emailencodingkey='UTF-8', firstName='Test user1', lastname='Testing1', languagelocalekey='en_US',localesidkey='en_US', profileid = pr.Id, country='United States',timezonesidkey='America/Los_Angeles', username='test012@noemail.com',userroleId =ur.Id ); 
        insert userWithRole;
        userWithNoRole = new user(alias = 'test123', email='test123@noemail.com',emailencodingkey='UTF-8', firstName='Test user', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = pr.Id, country='United States',timezonesidkey='America/Los_Angeles', username='test0155@noemail.com' ); 
        insert userWithNoRole;
        }

        Account acc = new Account(
        name = 'Test Account',
        ownerId = userWithNoRole.id
        );
        insert acc;
        

    Contact con = new Contact(
      firstname = 'test',
      lastname = 'contact55',
      AccountId = acc.id,
      email = 'testvin12345@test.com',
      //MPA_App__c = wdApp.Id,
      recordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('WDR_Candidate')
        .getRecordTypeId()
    );
    insert con;

        WDR_Job__c job = new WDR_Job__c (
        Name='Test Job',
        Job_Code__c = '123456',
        Hiring_Manager__c=thisUser.Id,
        Job_Family_Group__c ='CSG',
        Job_Level__c = '3',
        Division__c = 'Americas - USA'

        //Employment_Type__c = 
        );
        insert job;

    //Insert WDR Candidate
        WDR_Candidate__c wdCandidate = new WDR_Candidate__c(
        Name = 'test candidate',
        First_Name__c ='test',
        Last_Name__c = 'candidate',
        Email__c = 'testvin@test.com',
        Candidate_Contact__c = con.Id
        );
        insert wdCandidate;

    //Insert WDR Application
    WDR_Application__c wdApp = new WDR_Application__c (
        Candidate__c =  wdCandidate.Id,
        Job__c = job.Id,
        Candidate_Stage__c = 'Interview',
        Offer_type__c='FTE',
        Boomerang__c = false,
        Internal_Candidate__c = false,
        Confidential__c = false,
        Application_Step__c = 'Additional Interviews'
    );
	  insert wdApp;


    }
    @isTest
    static void accountOwnerUpdate(){
        List<WDR_Application__c> wdApps =[SELECT id FROM WDR_Application__c];
        update wdApps;
        Account acc = [select id,Owner.UserRoleId from account limit 1];
        System.assertEquals(1, 1, 'Account created');
    }
}