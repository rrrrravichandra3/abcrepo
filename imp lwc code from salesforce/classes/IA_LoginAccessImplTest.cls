@istest
/**
 * @author Anchana Rajamathe
 * @date 11/28/2020
 *
 * @description : Test Class for IA_LoginAccessImplTest
 *
 *
 */
public with sharing class IA_LoginAccessImplTest {
  @testSetup
  static void setup() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    String candidateRTName = IA_Util.InsiderConfigDefaultRec.Candidate_Contact_Rec_Typ_Developer_Name__c;
    Id CandidateRTName1 = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(candidateRTName).getRecordTypeId();
    Account acc = new Account(name = 'Test Account');
    insert acc;
    Contact con = new Contact(
      firstname = 'Test F',
      lastname = 'Test L',
      AccountId = acc.id,
      email = 'Test_F_L@salesforce.com',
      recordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(candidateRTName).getRecordTypeId()
    );
    insert con;

    Profile p1 = [SELECT id FROM Profile WHERE name = 'Employee'];
    UserRole rol = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];
    User usr = new user(
      alias = 'testvin4',
      email = 'testvin1234@test.com',
      emailencodingkey = 'UTF-8',
      firstName = 'VinTest',
      lastname = 'Testing',
      languagelocalekey = 'en_US',
      localesidkey = 'en_US',
      profileid = p1.Id,
      country = 'United States',
      timezonesidkey = 'America/Los_Angeles',
      username = 'testvin1234@test.com'
    );
    //insert usr;
    //Create Job App for the Candidate
    //WDR_TestFactory testfactory = new WDR_TestFactory();

    //testFactory.createJobApp();
    //WDR_Application__c jobappInScreen = testFactory.getDefaultJobApp();
    //WDR_Candidate__c Candidate = testFactory.getDefaultCandidate();
    //Candidate.First_Name__c = con.firstname;
    //Candidate.Last_Name__c = con.LastName;
    //Candidate.Name = con.firstname + con.LastName;
    //Candidate.Email__c = con.email;
    //update Candidate;
    
      
    WDR_Job__c job = new WDR_Job__c (
            Name='Test Job',
            Job_Code__c = '123456',
            Hiring_Manager__c= UserInfo.getUserId()
        );
        insert job;
            //Insert WDR Candidate
        WDR_Candidate__c wdCandidate1 = new WDR_Candidate__c(
            Name = con.firstname + con.LastName,
            First_Name__c =con.firstname,
            Last_Name__c = con.LastName,
            Email__c = con.email,
            Candidate_Contact__c = con.id
        );
        insert wdCandidate1;
        
        WDR_Application__c wdApp2 = new WDR_Application__c (
            Candidate__c =  wdCandidate1.Id,
            Job__c = job.Id,
            Candidate_Stage__c = 'Interview',
            Internal_Candidate__c = true,
            Offer_type__c='FTE'
        );
        insert wdApp2;
      
      con.MPA_App__c = wdApp2.id;
    update con;
  }
  /*******************************************************************************************************
   * @description Test if Job App in Screen stage is filtered out.
   */
  @isTest
  static void filterIneligibleContact() {
   // IA_SignInService.customLoginAccessImplClass = IA_Util.InsiderConfigDefaultRec.LoginAccessClassName__c;
    Contact c = [SELECT id, firstname, lastname, email FROM contact WHERE email = 'Test_F_L@salesforce.com' LIMIT 1];
    List<User> u = [Select id,name,email from user LIMIT 1];
    test.startTest();
    List<Contact> eligibleContacts = IA_LoginAccessImpl.additionalLoginAccessChecks(new List<Contact>{ c });
    Boolean b = IA_LoginAccessImpl.additionalLoginAccessCheckAndProvisioningForUser(u);
    System.assertEquals(eligibleContacts.size(), 0, 'Expecting no contacts as candidate stage is in screeb');
    test.stopTest();
  }
  //TODO test with CEMCI MPA batch job.

  /*******************************************************************************************************
   * @description Test if Job App in Interview stage is accepted .
   */
  @isTest
  static void getEligibleContact() {
    //IA_SignInService.customLoginAccessImplClass = IA_Util.InsiderConfigDefaultRec.LoginAccessClassName__c;

    WDR_Application__c jobApp = [SELECT id, candidate_stage__c FROM WDR_Application__c LIMIT 1];
    jobApp.Candidate_Stage__c = 'Interview';
    update jobApp;
    Contact c = [
      SELECT id, firstname, lastname, MPA_App__r.Candidate_Stage__c, email
      FROM contact
      WHERE email = 'Test_F_L@salesforce.com' LIMIT 1
    ];
    //system.assertEquals(c.MPA_App__r.Candidate_Stage__c, 'Interview', c.MPA_App__r.Candidate_Stage__c);
    System.assert(IA_Util.eligibleCandidateStages.contains('Interview'), IA_Util.eligibleCandidateStages);
    test.startTest();
    List<Contact> eligibleContacts = IA_LoginAccessImpl.additionalLoginAccessChecks(new List<Contact>{ c });
    //System.assertEquals(eligibleContacts.size(), 1, 'Expecting 1 contacts as candidate stage is in Interview');
    test.stopTest();
  }
  /*******************************************************************************************************
   * @description Test if Job App in Screen stage is filtered out.
   */
  @isTest
  static void additionalLoginAccessCheckAndProvisioningForUserTest() {
   // IA_SignInService.customLoginAccessImplClass = IA_Util.InsiderConfigDefaultRec.LoginAccessClassName__c;
    Contact c = [SELECT id, firstname, lastname, email FROM contact WHERE email = 'Test_F_L@salesforce.com' LIMIT 1];
    List<User> u = [Select id,name,email from user LIMIT 1];
    test.startTest();
    Boolean b = IA_LoginAccessImpl.additionalLoginAccessCheckAndProvisioningForUser(u);
    System.assertEquals(b, false, 'No Applications found');
    test.stopTest();
  }
    
    /*******************************************************************************************************
   * @description Test if Job App in Screen stage is filtered out.
   */
  @isTest
  static void AssignPermissionSetAndPublicGroupTest() {
   // IA_SignInService.customLoginAccessImplClass = IA_Util.InsiderConfigDefaultRec.LoginAccessClassName__c;
    Contact c = [SELECT id, firstname, lastname, email FROM contact WHERE email = 'Test_F_L@salesforce.com' LIMIT 1];
    User u = [Select id from user LIMIT 1];
    test.startTest();
    IA_LoginAccessImpl.AssignPermissionSetAndPublicGroup(u.id,'Insiders_App_Candidate','Insiders_Candidates');
      List<PermissionSetAssignment> perms = [SELECT Id, PermissionSetId, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId =: u.Id];
      System.assert(!perms.isEmpty(), 'Permission Set Successfully Assigned');
    test.stopTest();
  }
}