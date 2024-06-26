@istest
public class NHW_WDRJobApplicationTriggerHandlerTest {
  private static final String PLACEMENT = 'Placement';
  private static final String CLOSED_CANCELLED = 'Closed - Cancelled';
  private static final String DECLINED_BY_CANDIDATE = 'Declined by Candidate';
  private static final String REMOTE_TESTCITY = 'Remote -testcity';
  private static final String MSG_SHOULD_NOT_BE_ANY_CASES = 'There should not be any Cases for Job Application';

  @TestSetup
  private static void setupTestData() {
    TF2_Business_Site__c buSite = new TF2_Business_Site__c(
      name = 'Remote -California - San Francisco',
      Country__c = 'Unites States',
      Street_Address__c = '350 Mission St',
      Type__c = 'Regional Site'
    );
    insert buSite;
  }

  public static testMethod void NHW_ValidateCaseCreationOnUpdate() {
    WDR_Testfactory testdata = new WDR_Testfactory();
    testdata.createJobApp();
    WDR_Application__c DefaultJobApplication = testdata.getDefaultJobApp();
    WDR_Job__c DefaultJobReq = testdata.getDefaultJobReq();
    WDR_Candidate__c DefaultCandidate = testdata.getDefaultCandidate();

    Test.startTest();
    DefaultJobApplication.Candidate_Stage__c = PLACEMENT;
    update DefaultJobApplication;
    Test.stopTest();
    List<Case> cases = [
      SELECT
        id,
        Offer_Type__c,
        Resource_Type__c,
        First_Name__c,
        Last_Name__c,
        Primary_Coverage_Country__c,
        Business_Title__c,
        Business_Unit_NHW__c,
        Cost_Center_NHW__c,
        NHW_Business_Unit__c,
        NHW_Cost_Center__c,
        NHW_Start_Date__c,
        Manager_s_Email__c,
        NH_Personal_Email__c,
        Company__c,
        NH_Business_Site__c,
        Division__c,
        Office_Address__c,
        Office_City__c,
        Office_State_Province__c,
        Office_Zip_Postal_Code__c,
        Office_Country__c,
        status,
        origin,
        type,
        subject,
        description,
        Internal_Support_Category__c,
        HR_Approved__c,
        contactid,
        Manager_Name__c,
        NHW_Employee__C
      FROM case
      WHERE NHW_Job_Application__c = :DefaultJobApplication.id
    ];

    system.assertEquals(1, cases.size());
    ValidateCasePopulation(cases[0], DefaultJobReq, DefaultCandidate, DefaultJobApplication);
    List<Contact> Contacts = [
      SELECT id, FirstName, LastName, email, NHW_Candidate__c, RecordTypeId
      FROM contact
      WHERE NHW_Candidate__c = :DefaultCandidate.id
    ];

    system.assertEquals(1, Contacts.size());
  }

  //If OfferType is processed by NHW -  enforce NHW reqd fields.
  //Currently testing Employment type

  public static testMethod void NHW_ValidateReqdFieldsForNHWOfferTypes() {
    WDR_Testfactory testdata = new WDR_Testfactory();
    testdata.createJobApp();
    WDR_Application__c DefaultJobApplication = testdata.getDefaultJobApp();
    WDR_Job__c DefaultJobReq = testdata.getDefaultJobReq();
    WDR_Candidate__c DefaultCandidate = testdata.getDefaultCandidate();
    DefaultJobApplication.Start_Date__c = System.Today().addDays(16);

    Test.startTest();
    //below offer type is valid
    DefaultJobApplication.Offer_Type__c = 'Not M&A';
    DefaultJobApplication.Candidate_Stage__c = PLACEMENT;
    DefaultJobreq.Employment_Type__c = null;
    update DefaultJobreq;
    update DefaultJobApplication;
    Test.stopTest();
    System.debug(
      [SELECT id, description__c, Error_Message__c, Component__c, Type__c, error_type__c FROM PF_DEbug_Log__c]
    );
    List<Case> cases = [SELECT Id, Email_Address__c FROM Case WHERE NHW_Job_Application__c = :DefaultJobApplication.id];
    DefaultJobApplication = [
      SELECT id, Do_Not_Send_NHW__c
      FROM WDR_Application__c
      WHERE id = :DefaultJobApplication.id
    ];
    System.assertEquals(cases.size(), 0); // no case spawned
  }

  public static testMethod void NHW_ValidateCaseCreationOnInsert() {
    WDR_Testfactory testdata = new WDR_Testfactory();
    testdata.setCandidateStage(PLACEMENT);
    Test.startTest();
    testdata.createJobApp();
    WDR_Application__c DefaultJobApplication = testdata.getDefaultJobApp();
    WDR_Job__c DefaultJobReq = testdata.getDefaultJobReq();
    WDR_Candidate__c DefaultCandidate = testdata.getDefaultCandidate();
    Test.stopTest();
    List<Case> cases = [
      SELECT
        id,
        Offer_Type__c,
        Resource_Type__c,
        First_Name__c,
        Last_Name__c,
        Primary_Coverage_Country__c,
        Business_Title__c,
        Business_Unit_NHW__c,
        Cost_Center_NHW__c,
        NHW_Business_Unit__c,
        NHW_Cost_Center__c,
        NHW_Start_Date__c,
        Manager_s_Email__c,
        NH_Personal_Email__c,
        Company__c,
        NH_Business_Site__c,
        Division__c,
        Office_Address__c,
        Office_City__c,
        Office_State_Province__c,
        Office_Zip_Postal_Code__c,
        Office_Country__c,
        status,
        origin,
        type,
        subject,
        description,
        Internal_Support_Category__c,
        HR_Approved__c,
        contactid,
        Manager_Name__c,
        NHW_Employee__C
      FROM case
      WHERE NHW_Job_Application__c = :DefaultJobApplication.id
    ];

    system.assertEquals(1, cases.size());
    ValidateCasePopulation(cases[0], DefaultJobReq, DefaultCandidate, DefaultJobApplication);
    List<Contact> Contacts = [
      SELECT id, FirstName, LastName, email, NHW_Candidate__c, RecordTypeId
      FROM contact
      WHERE NHW_Candidate__c = :DefaultCandidate.id
    ];

    system.assertEquals(1, Contacts.size());

    WDR_Application__c DefaultJobApplication1 = DefaultJobApplication.clone(false, true, false, false);
    DefaultJobApplication1.NHW_Create_Preboarding_Case__c = true;
    insert DefaultJobApplication1;
  }
  //Test Behaviour for below updates in same sequence
  // From false to true via controlling fields - [Internal Candidate true.] - No Case created
  // From true ro false via manual  - [Manual override] - Case spawned
  // From false to true - [Manual Override] - Error
  // From false to true - [controlling  field update] - Error

  public static testMethod void NHW_ValidateDoNotSendNHWUpdates() {
    //Do Not send derived
    WDR_Testfactory testdata = new WDR_Testfactory();
    testdata.createJobApp();
    WDR_Application__c DefaultJobApplication = testdata.getDefaultJobApp();
    WDR_Job__c DefaultJobReq = testdata.getDefaultJobReq();
    WDR_Candidate__c DefaultCandidate = testdata.getDefaultCandidate();

    Test.startTest();
    //update  Job App for internal candidate to placement.
    DefaultJobApplication.Candidate_Stage__c = PLACEMENT;
    DefaultJobApplication.Internal_Candidate__c = true;
    update DefaultJobApplication;
    WDR_Application__c JobApp = [
      SELECT Do_Not_Send_NHW__c, NHW_Create_Preboarding_Case__c
      FROM WDR_Application__c
      WHERE id = :DefaultJobApplication.id
    ];
    System.assertEquals(false, JobApp.NHW_Create_Preboarding_Case__c, 'Preboarding case should not be created.');
    System.assertEquals(true, JobApp.Do_Not_Send_NHW__c, 'Do Not send NHW should be set to true for internalCandidate');

    //Do Manual Override to false.
    DefaultJobApplication.Do_Not_Send_NHW__c = false;
    update DefaultJobApplication;

    Test.stopTest();

    List<Case> cases = [SELECT id FROM case WHERE NHW_Job_Application__c = :JobApp.id];
    system.assertEquals(1, cases.size(), 'Expecting case to be spawned after manual update of Do Not send to false');
    Boolean sawException = false;
  }

  //Test Behaviour for below updates in same sequence
  // From false to true Manual with incorrect stage/Date/Do not send- [Manual] -  error
  // From false to true via controlling fields - [Stage and start date.] -  Case created
  // From true to false via manual  - [Manual override] - error
  public static testMethod void NHW_ValidatePreboardingFlagUpdates() {
    WDR_Testfactory testdata = new WDR_Testfactory();
    testdata.createJobApp();
    WDR_Application__c DefaultJobApplication = testdata.getDefaultJobApp();
    WDR_Job__c DefaultJobReq = testdata.getDefaultJobReq();
    WDR_Candidate__c DefaultCandidate = testdata.getDefaultCandidate();
    Test.startTest();

    Boolean sawException = false;

    DefaultJobApplication.Start_Date__c = system.today().adddays(20);
    DefaultJobApplication.Candidate_Stage__c = PLACEMENT;
    DefaultJobApplication.Do_Not_Send_NHW__c = true;
    DefaultJobApplication.NHW_Create_Preboarding_Case__c = false;
    update DefaultJobApplication;
    WDR_Application__c JobApp = [
      SELECT Candidate_Stage__c, NHW_Create_Preboarding_Case__c
      FROM WDR_Application__c
      WHERE id = :DefaultJobApplication.id
    ];

    system.assertEquals(false, JobApp.NHW_Create_Preboarding_Case__c, 'Expecting preboarding to not happen.');

    //Manual update Preboarding flag with do Not send.
    sawException = false;
    try {
      DefaultJobApplication.NHW_Create_Preboarding_Case__c = true;
      update DefaultJobApplication;
    } catch (Exception ex) {
      sawException = true;
      System.assertEquals(
        true,
        ex.getMessage().contains(System.Label.Preboarding_Flag_manual_update_for_Do_Not_Send_NHW),
        'Error -' + ex.getMessage()
      );
    }
    system.assertEquals(true, sawException, 'Expecting error as Do not send is checked.');
    //Move job App to SD in preboarding window.
    DefaultJobApplication.Start_Date__c = system.today().adddays(20);
    DefaultJobApplication.Do_Not_Send_NHW__c = false;
    update DefaultJobApplication;
    JobApp = [
      SELECT Candidate_Stage__c, NHW_Create_Preboarding_Case__c
      FROM WDR_Application__c
      WHERE id = :DefaultJobApplication.id
    ];
    system.assertEquals(true, JobApp.NHW_Create_Preboarding_Case__c, 'Expecting preboarding to  happen.');
    Test.stopTest();

    //Manual update Preboarding flag to false once case exists.
    sawException = false;
    try {
      DefaultJobApplication.NHW_Create_Preboarding_Case__c = false;
      update DefaultJobApplication;
    } catch (Exception ex) {
      sawException = true;
      System.assertEquals(
        true,
        ex.getMessage().contains(System.Label.NHW_Uncheck_Pre_Boarding_Flag_Error),
        'Error -' + ex.getMessage()
      );
    }
    system.assertEquals(true, sawException, 'Expecting error as case exists.');
  }

  //Test Behaviours
  //Insert - Do Not NHW On - Incorrect Controlling fields - Manual override allowed.
  //Insert - Do Not NHW off - Controlling fields - Set to true.

  public static testMethod void NHW_ValidateDoNotSendNHWInserts() {
    WDR_Testfactory testdata = new WDR_Testfactory();

    testdata.setDoNotSend(true);
    Test.startTest();
    testdata.createJobApp();
    WDR_Application__c JobApp = [SELECT Do_Not_Send_NHW__c FROM WDR_Application__c];
    system.assertEquals(
      true,
      JobApp.Do_Not_Send_NHW__c,
      'Expecting NOT to be overwritten to false even though controlling fields are not set'
    );
    testdata.setInternalCandidateFlag(true);
    testdata.setDoNotSend(false);
    JobApp = [SELECT Do_Not_Send_NHW__c FROM WDR_Application__c];
    system.assertEquals(
      true,
      JobApp.Do_Not_Send_NHW__c,
      'Expecting to be overwritten to true as controlling fields are  set'
    );
    Test.stopTest();
  }

  //TODO Combo testing -
  //- When both Do Not Send & Preboarding are true and  inserted at same time
  // When Controlling field and Do not send are updated at sametime inversely - Manual value takes precedence.
  public static testMethod void NHW_FlagsComboTests() {
    WDR_Testfactory testdata = new WDR_Testfactory();
    testdata.setDoNotSend(true);
    testdata.setPreboardingFlag(true);
    testdata.setCandidateStage(PLACEMENT);
    Test.startTest();

    testdata.setPreboardingFlag(false);
    testdata.setDoNotSend(true);
    testdata.createJobApp();
    WDR_Application__c DefaultJobApp = testdata.getDefaultJobApp();

    DefaultJobApp.Do_Not_Send_NHW__c = false;
    DefaultJobApp.Offer_Type__c = 'M&A';
    update DefaultJobApp;

    WDR_APPlication__c jobapp = [SELECT Do_Not_Send_NHW__c FROM WDR_APPlication__c];
    system.assertEquals(false, jobapp.Do_Not_Send_NHW__c, 'Manual value takes precendence.');
    List<Case> cases = [SELECT id FROM Case WHERE NHW_Job_Application__c = :jobapp.Id];
    System.assertEquals(0, cases.size(), 'No case should have been generated');

    Test.stopTest();
  }

  public static testMethod void NHW_BulkTests() {
    WDR_Testfactory testdata = new WDR_Testfactory();
    Test.startTest();
    testdata.createJobApps(100);
    List<WDR_Application__c> JobApps = [SELECT id, name FROM WDR_Application__c];
    System.assertEquals(100, JobApps.size(), 'All 100 Job Apps inserted.');
    for (WDR_Application__c JobApp : JobApps) {
      JobApp.Candidate_Stage__c = PLACEMENT;
    }
    update JobApps;

    Test.stopTest();
    List<Case> Cases = [SELECT id FROM case WHERE NHW_Job_Application__c IN :JobApps];
    System.assertEquals(100, Cases.size(), 'Expcting 100 cases to be spawned.');
  }
  //Test if NHW reg fields on the job app are available when it moves to placement.
  public static testMethod void NHW_TestRequiredFieldsForPlacementMailingCity() {
    WDR_Testfactory testdata = new WDR_Testfactory();
    testdata.createJobApp();

    WDR_Candidate__c DefaultCandidate = testdata.getDefaultCandidate();

    WDR_Application__c DefaultJobApp = testdata.getDefaultJobApp();
    DefaultJobApp.Start_Date__c = System.Today().addDays(16);
    Id id = [SELECT Business_Site__c FROM WDR_Application__c].Business_Site__c;
    TF2_Business_Site__c buSite = [SELECT City__c FROM TF2_Business_Site__c WHERE id = :DefaultJobApp.Business_Site__c];
    buSite.City__c = REMOTE_TESTCITY;
    update buSite;
    Test.startTest();
    DefaultCandidate.Mailing_City__c = null;
    update DefaultCandidate;
    DefaultJobApp.Candidate_Stage__c = PLACEMENT;
    update DefaultJobApp;
    Test.stopTest();
    List<PF_Debug_Log__c> err = [
      SELECT id, description__c, Error_Message__c, Component__c, Type__c, error_type__c
      FROM PF_DEbug_Log__c
    ];
  }
  public static testMethod void NHW_TestRequiredFieldsForPlacementMailingCountry() {
    WDR_Testfactory testdata = new WDR_Testfactory();
    testdata.createJobApp();

    WDR_Candidate__c DefaultCandidate = testdata.getDefaultCandidate();

    WDR_Application__c DefaultJobApp = testdata.getDefaultJobApp();
    DefaultJobApp.Start_Date__c = System.Today().addDays(16);
    Id id = [SELECT Business_Site__c FROM WDR_Application__c].Business_Site__c;
    TF2_Business_Site__c buSite = [SELECT City__c FROM TF2_Business_Site__c WHERE id = :DefaultJobApp.Business_Site__c];
    buSite.City__c = REMOTE_TESTCITY;
    update buSite;
    Test.startTest();
    DefaultCandidate.Mailing_City__c = 'SF';
    DefaultCandidate.Mailing_Country__c = null;
    update DefaultCandidate;
    DefaultJobApp.Candidate_Stage__c = PLACEMENT;

    update DefaultJobApp;
    Test.stopTest();
    List<PF_Debug_Log__c> err = [
      SELECT id, description__c, Error_Message__c, Component__c, Type__c, error_type__c
      FROM PF_DEbug_Log__c
    ];
  }
  public static testMethod void NHW_TestRequiredFieldsForPlacementMailingPostalCode() {
    WDR_Testfactory testdata = new WDR_Testfactory();
    testdata.createJobApp();

    WDR_Candidate__c DefaultCandidate = testdata.getDefaultCandidate();

    WDR_Application__c DefaultJobApp = testdata.getDefaultJobApp();
    DefaultJobApp.Start_Date__c = System.Today().addDays(16);
    Id id = [SELECT Business_Site__c FROM WDR_Application__c].Business_Site__c;
    TF2_Business_Site__c buSite = [SELECT City__c FROM TF2_Business_Site__c WHERE id = :DefaultJobApp.Business_Site__c];
    buSite.City__c = REMOTE_TESTCITY;
    update buSite;

    Test.startTest();
    DefaultCandidate.Mailing_City__c = 'SF';
    DefaultCandidate.Mailing_Country__c = 'United States of America';
    DefaultCandidate.Mailing_Postal_Code__c = null;
    update DefaultCandidate;
    DefaultJobApp.Candidate_Stage__c = PLACEMENT;

    update DefaultJobApp;
    Test.stopTest();
    List<PF_Debug_Log__c> err = [
      SELECT id, description__c, Error_Message__c, Component__c, Type__c, error_type__c
      FROM PF_DEbug_Log__c
    ];
  }

  public static testMethod void NHW_TestRequiredFieldsForPlacementMailingStreet() {
    WDR_Testfactory testdata = new WDR_Testfactory();
    testdata.createJobApp();

    WDR_Candidate__c DefaultCandidate = testdata.getDefaultCandidate();

    WDR_Application__c DefaultJobApp = testdata.getDefaultJobApp();
    DefaultJobApp.Start_Date__c = System.Today().addDays(16);
    Id id = [SELECT Business_Site__c FROM WDR_Application__c].Business_Site__c;
    TF2_Business_Site__c buSite = [SELECT City__c FROM TF2_Business_Site__c WHERE id = :DefaultJobApp.Business_Site__c];
    buSite.City__c = REMOTE_TESTCITY;
    update buSite;
    Test.startTest();
    DefaultCandidate.Mailing_City__c = 'SF';
    DefaultCandidate.Mailing_Country__c = 'United States of America';
    DefaultCandidate.Mailing_Postal_Code__c = '94402';
    DefaultCandidate.Mailing_State__c = 'CA';
    DefaultCandidate.Mailing_Street__c = null;

    update DefaultCandidate;
    DefaultJobApp.Candidate_Stage__c = PLACEMENT;

    update DefaultJobApp;
    Test.stopTest();
    List<PF_Debug_Log__c> err = [
      SELECT id, description__c, Error_Message__c, Component__c, Type__c, error_type__c
      FROM PF_DEbug_Log__c
    ];
  }

  //Test if preboarding case is updated close cancelled from closed after Job App  updated to rejection stage.
  public static testMethod void NHW_ValidateJobAppRejectionUpdate() {
    WDR_Testfactory testdata = new WDR_Testfactory();
    testdata.createJobApp();
    WDR_Application__c DefaultJobApplication = testdata.getDefaultJobApp();
    WDR_Job__c DefaultJobReq = testdata.getDefaultJobReq();
    WDR_Candidate__c DefaultCandidate = testdata.getDefaultCandidate();

    Test.startTest();
    DefaultJobApplication.Candidate_Stage__c = PLACEMENT;
    update DefaultJobApplication;
    Test.stopTest();

    List<Case> cases = [SELECT id, status FROM case WHERE NHW_Job_Application__c = :DefaultJobApplication.id];
    system.assertEquals(1, cases.size());

    cases[0].status = 'Closed';
    update cases;

    DefaultJobApplication.Candidate_Stage__c = DECLINED_BY_CANDIDATE;
    update DefaultJobApplication;

    cases = [SELECT id, status FROM case WHERE NHW_Job_Application__c = :DefaultJobApplication.id];

    system.assertEquals(CLOSED_CANCELLED, cases[0].status, 'Expection case status to be updated to close - cancelled.');
  }

  //Test to see if no preboarding case is created if Job App is directly inserted in rejection stage.
  public static testMethod void NHW_ValidateJobAppRejectionInsert() {
    WDR_Testfactory testdata = new WDR_Testfactory();
    testdata.setCandidateStage(DECLINED_BY_CANDIDATE);

    Test.startTest();
    testdata.createJobApp();
    WDR_Application__c DefaultJobApplication = testdata.getDefaultJobApp();
    WDR_Job__c DefaultJobReq = testdata.getDefaultJobReq();
    WDR_Candidate__c DefaultCandidate = testdata.getDefaultCandidate();
    Test.stopTest();
    List<PF_Debug_Log__c> logs = [SELECT id, error_message__c, description__c FROM PF_Debug_Log__c];
    system.assertEquals(0, logs.size(), logs);
    List<Case> cases = [SELECT id, status FROM case WHERE NHW_Job_Application__c = :DefaultJobApplication.id];

    system.assertEquals(0, cases.size(), 'Expecting no cases to be created as Job App is rejected.');
  }
  //Test if portal user is missing the exception is logged correctly in PF Debug logs.

  /*
TODO: determine why failing due to the following information:
Unit test is failing due to Class.IFB_WDShareAppsWithHM.execute: line 36, column 1

    public static testmethod void NHW_TestExceptionHandling(){
        Test.startTest();
            List<AggregateResult> UsersAggregateResult = [select email,count(id) from user group by email having count(id)=1 limit 1];
            System.assertEquals(UsersAggregateResult.size(), 1,'There should be atleast one user without portal user setup for this test to pass');
            String Useremail = (string)UsersAggregateResult[0].get('email');
            User userWithoutPortal = [select id,name from user where email=:Useremail];
            WDR_Testfactory testdata = new WDR_Testfactory();
            testdata.createJobApp();
            WDR_Job__c DefaultJobReq = testdata.getDefaultJobReq();
            DefaultJobReq.Hiring_Manager__c = userWithoutPortal.id;
            update DefaultJobReq;
            testdata.setCandidateStage('Placement');
            
            ESDJC_Settings__c settings =  new ESDJC_Settings__c();
            settings.djc_Helpdesk_API_User__c=Userinfo.getUserId();
            settings.Site_URL__c = '/site/url';
            settings.Run_trigger__c = true;
            insert settings;
            settings = [select djc_Helpdesk_API_User__c from ESDJC_Settings__c];
            
            Test.startTest();
                system.assertNotEquals(settings.djc_Helpdesk_API_User__c,null);           
                testdata.createJobApp();
                WDR_Application__c DefaultJobApplication = testdata.getDefaultJobApp();
                WDR_Job__c DefaultJobReq = testdata.getDefaultJobReq();
                WDR_Candidate__c DefaultCandidate = testdata.getDefaultCandidate();
            Test.stopTest();

                List<Contact> WDRContacts = [Select id,name from contact where recordType.developerName = 'WDR_Candidate'];
                System.assertNotEquals(WDRContacts.size(),0);
                Case newCase = new case(Origin ='Email to case -ESsupport',type='New Hire',ContactId=WDRContacts[0].id,SuppliedEmail='testingCandidate@gmail.com')   ;
                insert newCase;    
                newCase = [select id,ContactId from case where id=:newCase.id];
                System.assertNotEquals(newCase.ContactId,null,'Expecting candidate info');      

        }

         */

  

  //Helper method to validate case populationg
  public static void ValidateCasePopulation(
    case c,
    WDR_Job__c Job,
    WDR_Candidate__c Candidate,
    WDR_Application__c JobApp
  ) {
    System.assertEquals(c.Offer_Type__c, JobApp.Offer_Type__c);
    System.assertEquals(c.Resource_Type__c, Job.Employment_Type__c);
    System.assertEquals(c.First_Name__c, Candidate.First_Name__c);
    System.assertEquals(c.Last_Name__c, Candidate.Last_Name__c);
    System.assertEquals(c.Primary_Coverage_Country__c, [SELECT id, name FROM TF2_PCC__c WHERE id = :Job.PCC__c].name);
    System.assertEquals(c.Business_Title__c, Job.Job_Title__c);
    System.assertEquals(
      c.Business_Unit_NHW__c,
      [SELECT id, name FROM Business_Unit__c WHERE id = :Job.Business_Unit__c]
      .name
    );
    System.assertEquals(
      c.Cost_Center_NHW__c,
      [SELECT id, name FROM TF2_Department__c WHERE id = :Job.Department__c]
      .name
    );
    System.assertEquals(c.NHW_Business_Unit__c, Job.Business_Unit__c);
    System.assertEquals(c.NHW_Cost_Center__c, Job.Department__c);
    System.assertEquals(c.NHW_Start_Date__c, JobApp.Start_Date__c);
    System.assertEquals(c.Manager_s_Email__c, [SELECT id, email FROM user WHERE id = :Job.Hiring_Manager__c].Email);
    System.assertEquals(c.NH_Personal_Email__c.toLowerCase(), Candidate.Email__c.toLowerCase());
    System.assertEquals(c.Company__c, Job.Company__c);
    System.assertEquals(c.NH_Business_Site__c, JobApp.Business_Site__c);
    System.assertEquals(c.Division__c, Job.Region__c);
    TF2_Business_Site__c bizSite = [
      SELECT id, name, Street_Address__c, City__c, State_Province__c, Country__c
      FROM TF2_Business_Site__c
      WHERE id = :JobApp.Business_Site__c
    ];

    if (JobApp.Business_Site__c != null && bizSite.Name.contains('Remote')) {
      System.assertEquals(c.Office_Address__c, Candidate.Mailing_Street__c);
      System.assertEquals(c.Office_City__c, Candidate.Mailing_City__c);
      System.assertEquals(c.Office_State_Province__c, Candidate.Mailing_State__c);
      System.assertEquals(c.Office_Zip_Postal_Code__c, Candidate.Mailing_Postal_Code__c);
      System.assertEquals(c.Office_Country__c, Candidate.Mailing_Country__c);
    } else {
      System.assertEquals(c.Office_Address__c, bizSite.Street_Address__c);
      System.assertEquals(c.Office_City__c, bizSite.City__c);
      System.assertEquals(c.Office_State_Province__c, bizSite.State_Province__c);
      System.assertEquals(c.Office_Zip_Postal_Code__c, bizSite.City__c);
      System.assertEquals(c.Office_Country__c, bizSite.Country__c);
    }
    Contact HMContact = [SELECT id FROM contact WHERE email = :UserInfo.getUserEmail()];
    Contact CandidateContact = [SELECT id FROM contact WHERE NHW_Candidate__c = :JobApp.Candidate__c];

    System.assertEquals(c.NHW_Employee__c, CandidateContact.id);

    System.assertEquals(c.status, 'Accounts in Progress - Peopleforce');
    System.assertEquals(c.origin, 'NHW');
    System.assertEquals(c.Type, 'NHW');
    System.assertEquals(c.Internal_Support_Category__c, 'New Hire Preboarding Request');
    System.assertEquals(
      c.Description,
      'Please create the AD account and the Supportforce Internal Contact record for the New Hire.'
    );
    System.assertEquals(c.Subject.contains('New Hire Preboarding Request for'), true);
    System.assertEquals(c.HR_Approved__c, true);
  }
  /*
    TODO: Not sure this is still a valid unit test. Not sure what the purpose of this test is.
    public static testmethod void testEmailToCaseforWDRCandidate(){
        WDR_Testfactory testdata = new WDR_Testfactory();
        testdata.setCandidateStage('Placement');
        
        ESDJC_Settings__c settings =  new ESDJC_Settings__c();
        settings.djc_Helpdesk_API_User__c=Userinfo.getUserId();
        settings.Site_URL__c = '/site/url';
        settings.Run_trigger__c = true;
        insert settings;
        settings = [select djc_Helpdesk_API_User__c from ESDJC_Settings__c];
        
        Test.startTest();
            system.assertNotEquals(settings.djc_Helpdesk_API_User__c,null);           
            testdata.createJobApp();
            WDR_Application__c DefaultJobApplication = testdata.getDefaultJobApp();
            WDR_Job__c DefaultJobReq = testdata.getDefaultJobReq();
            WDR_Candidate__c DefaultCandidate = testdata.getDefaultCandidate();
        Test.stopTest();

            List<Contact> WDRContacts = [Select id,name from contact where recordType.developerName = 'WDR_Candidate'];
            System.assertNotEquals(WDRContacts.size(),0);
            Case newCase = new case(Origin ='Email to case -ESsupport',type='New Hire',ContactId=WDRContacts[0].id,SuppliedEmail='testingCandidate@gmail.com')   ;
            insert newCase;    
            newCase = [select id,ContactId from case where id=:newCase.id];
            System.assertNotEquals(newCase.ContactId,null,'Expecting candidate info');      

    }

        */

  @isTest
  static void successfullEndToEndUpdate1() {
    Test.startTest();
    WDR_Testfactory testFactory = new WDR_Testfactory();
    testFactory.createJobApp();
    List<TF2_Business_Site__c> buSites = [SELECT Id FROM TF2_Business_Site__c WHERE Type__c = 'Regional Site'];
    List<Case> cases = [
      SELECT Id, CaseNumber
      FROM Case
      WHERE NHW_Job_Application__c = :testFactory.getDefaultJobApp().Id
    ];
    System.assertEquals(0, cases.size(), MSG_SHOULD_NOT_BE_ANY_CASES);

    testFactory.getDefaultJobApp().Candidate_Stage__c = PLACEMENT;
    testFactory.getDefaultJobApp().NHW_Create_Preboarding_Case__c = true;
    update testFactory.getDefaultJobApp();
    Test.stopTest();
    List<Case> casesAfterPlacement = [
      SELECT Id, CaseNumber, NH_Business_Site__c, NHW_Start_Date__c
      FROM Case
      WHERE NHW_Job_Application__c = :testFactory.getDefaultJobApp().Id
    ];

    System.assertEquals(1, casesAfterPlacement.size(), 'There should be Preboading Cases for Job Application');
    System.assertEquals(
      casesAfterPlacement[0].NHW_Start_Date__c,
      testFactory.getDefaultJobApp().Start_Date__c,
      'Start Date should be copied from Job Application'
    );
    System.assertEquals(
      casesAfterPlacement[0].NH_Business_Site__c,
      testFactory.getDefaultJobApp().Business_Site__c,
      'Business should be copied from Job Application'
    );

    testFactory.getDefaultJobApp().Business_Site__c = buSites[0].Id;
    testFactory.getDefaultJobApp().Start_Date__c = testFactory.getDefaultJobApp().Start_Date__c + 10;
    update testFactory.getDefaultJobApp();

    List<Case> casesAfterUpdate = [
      SELECT Id, CaseNumber, NH_Business_Site__c, NHW_Start_Date__c
      FROM Case
      WHERE NHW_Job_Application__c = :testFactory.getDefaultJobApp().Id
    ];
    System.assertEquals(1, casesAfterUpdate.size(), MSG_SHOULD_NOT_BE_ANY_CASES);
    System.assertEquals(
      casesAfterUpdate[0].NHW_Start_Date__c,
      testFactory.getDefaultJobApp().Start_Date__c,
      'Start Date should be copied from Job Application'
    );
    System.assertEquals(
      casesAfterUpdate[0].NH_Business_Site__c,
      buSites[0].Id,
      'Business should be upadated from Job Application.'
    );

    testFactory.getDefaultJobApp().Candidate_Stage__c = DECLINED_BY_CANDIDATE;
    update testFactory.getDefaultJobApp();
    List<Case> casesAfterDeclined = [
      SELECT Id, CaseNumber, NH_Business_Site__c, NHW_Start_Date__c, Status
      FROM Case
      WHERE NHW_Job_Application__c = :testFactory.getDefaultJobApp().Id
    ];
    System.assertEquals(CLOSED_CANCELLED, casesAfterDeclined[0].Status, 'Preboarding Case should be Cancelled.');
  }

  /*@isTest
  static void successfulEndToEndBulkUpdate() {
    Test.startTest();
    WDR_Testfactory testFactory = new WDR_Testfactory();
    testFactory.createJobApps(100);
    List<TF2_Business_Site__c> buSites = [SELECT Id FROM TF2_Business_Site__c WHERE Type__c = 'Regional Site'];
    List<Case> cases = [SELECT Id, CaseNumber FROM Case];
    System.assertEquals(0, cases.size(), MSG_SHOULD_NOT_BE_ANY_CASES);
    List<WDR_Application__c> jobApps = [
      SELECT Id, Candidate_Stage__c, NHW_Create_Preboarding_Case__c, Business_Site__c, Start_Date__c
      FROM WDR_Application__c
    ];
    System.assertEquals(100, jobApps.size());
    for (WDR_Application__c jobApp : jobApps) {
      jobApp.Candidate_Stage__c = PLACEMENT;
      jobApp.NHW_Create_Preboarding_Case__c = true;
    }
    update jobApps;
    Test.stopTest();
    List<Case> casesAfterPlacement = [SELECT Id, CaseNumber, NH_Business_Site__c, NHW_Start_Date__c FROM Case];

    System.assertEquals(100, casesAfterPlacement.size(), 'There should be Preboading Cases for each Job Application');
    for (Integer idx = 29; idx < 89; idx++) {
      jobApps[idx].Business_Site__c = buSites[0].Id;
      jobApps[idx].Start_Date__c = jobApps[idx].Start_Date__c + 10;
    }
    update jobApps;
    List<Case> casesAfterUpdate = [
      SELECT
        Id,
        CaseNumber,
        NH_Business_Site__c,
        NHW_Start_Date__c,
        Status,
        NHW_Job_Application__r.Start_Date__c,
        NHW_Job_Application__r.Business_Site__c
      FROM Case
    ];
    for (Case cse : casesAfterUpdate) {
      System.assertEquals(cse.NH_Business_Site__c, cse.NHW_Job_Application__r.Business_Site__c);
      System.assertEquals(cse.NHW_Start_Date__c, cse.NHW_Job_Application__r.Start_Date__c);
    }

    for (Integer idx = 0; idx < jobApps.size(); idx++) {
      jobApps[idx].Candidate_Stage__c = 'Rejected';
    }
    update jobApps;
    List<Case> casesAfterRejected = [
      SELECT
        Id,
        CaseNumber,
        NH_Business_Site__c,
        NHW_Start_Date__c,
        Status,
        NHW_Job_Application__r.Start_Date__c,
        NHW_Job_Application__r.Business_Site__c,
        NHW_Job_Application__r.Candidate_Stage__c
      FROM Case
    ];
    for (Case cse : casesAfterRejected) {
      if (cse.NHW_Job_Application__r.Candidate_Stage__c == 'Rejected')
        System.assertEquals(CLOSED_CANCELLED, cse.Status);
    }
  }*/

  @isTest
  static void isRescindHireTest() {
    WDR_Testfactory testdata = new WDR_Testfactory();
    List<WDR_Job__c> DefaultJobReqs = new List<WDR_Job__c>();
    List<WDR_Candidate__c> DefaultCandidates = new List<WDR_Candidate__c>();
    List<WDR_Application__c> DefaultJobApplications = new List<WDR_Application__c>();
    List<TF2_Business_Site__c> buSites = [SELECT Id FROM TF2_Business_Site__c WHERE Type__c = 'Regional Site'];

    WDR_Job__c DefaultJobReq = testdata.getDefaultJobReq();

    for (Integer i = 1; i < 4; i++) {
      DefaultCandidates.add(
        new WDR_Candidate__c(
          First_Name__c = 'Test F' + String.valueOf(i),
          Last_Name__c = 'Test L' + String.valueOf(i),
          Name = 'Test F' + String.valueOf(i) + 'Test L' + String.valueOf(i),
          Email__c = 'Test_F_L_' + String.valueOf(i) + '@salesforce.com',
          Mailing_City__c = 'San Francisco',
          Mailing_Country__c = 'Unites States',
          Mailing_Postal_Code__c = String.valueOf(94002 + i),
          Mailing_State__c = 'CA',
          Mailing_Street__c = '350 mission st',
          Employee_Number__c = String.valueOf(778690 + i)
        )
      );
    }

    insert DefaultCandidates;
    insert DefaultJobReq;

    for (Integer i = 0; i < 3; i++) {
      DefaultJobApplications.add(
        new WDR_Application__c(
          Business_Site__c = buSites[0].id,
          Offer_Type__c = 'Perm/FTE',
          Offer_Status__c = 'Approved',
          Start_Date__c = System.Today(),
          Candidate_Stage__c = PLACEMENT,
          Auto_Provisioning_Email_Sent__c = true,
          Candidate__c = DefaultCandidates[0].Id,
          Job__c = DefaultJobReq.Id
        )
      );
    }

    insert DefaultJobApplications;

    System.assertEquals(
      true,
      [SELECT Id, NHW_Create_Preboarding_Case__c FROM WDR_Application__c WHERE Id = :DefaultJobApplications[0].Id]
      .NHW_Create_Preboarding_Case__c
    );
    System.assertEquals(
      true,
      [SELECT Id, NHW_Create_Preboarding_Case__c FROM WDR_Application__c WHERE Id = :DefaultJobApplications[1].Id]
      .NHW_Create_Preboarding_Case__c
    );
    System.assertEquals(
      true,
      [SELECT Id, NHW_Create_Preboarding_Case__c FROM WDR_Application__c WHERE Id = :DefaultJobApplications[2].Id]
      .NHW_Create_Preboarding_Case__c
    );
    System.assertEquals(
      true,
      [SELECT Id, Auto_Provisioning_Email_Sent__c FROM WDR_Application__c WHERE Id = :DefaultJobApplications[0].Id]
      .Auto_Provisioning_Email_Sent__c
    );
    System.assertEquals(
      true,
      [SELECT Id, Auto_Provisioning_Email_Sent__c FROM WDR_Application__c WHERE Id = :DefaultJobApplications[1].Id]
      .Auto_Provisioning_Email_Sent__c
    );
    System.assertEquals(
      true,
      [SELECT Id, Auto_Provisioning_Email_Sent__c FROM WDR_Application__c WHERE Id = :DefaultJobApplications[2].Id]
      .Auto_Provisioning_Email_Sent__c
    );

    Test.startTest();

    DefaultJobApplications[0].Candidate_Stage__c = 'Pre-Placement';
    DefaultJobApplications[1].Candidate_Stage__c = DECLINED_BY_CANDIDATE;
    DefaultJobApplications[2].Start_Date__c = System.Today().addDays(-1);
    DefaultJobApplications[2].Candidate_Stage__c = 'Pre-Placement';
    update DefaultJobApplications;

    System.assertEquals(
      false,
      [SELECT Id, NHW_Create_Preboarding_Case__c FROM WDR_Application__c WHERE Id = :DefaultJobApplications[0].Id]
      .NHW_Create_Preboarding_Case__c
    );
    System.assertEquals(
      true,
      [SELECT Id, NHW_Create_Preboarding_Case__c FROM WDR_Application__c WHERE Id = :DefaultJobApplications[1].Id]
      .NHW_Create_Preboarding_Case__c
    );
    System.assertEquals(
      false,
      [SELECT Id, NHW_Create_Preboarding_Case__c FROM WDR_Application__c WHERE Id = :DefaultJobApplications[2].Id]
      .NHW_Create_Preboarding_Case__c
    );
    System.assertEquals(
      false,
      [SELECT Id, Auto_Provisioning_Email_Sent__c FROM WDR_Application__c WHERE Id = :DefaultJobApplications[0].Id]
      .Auto_Provisioning_Email_Sent__c
    );
    System.assertEquals(
      true,
      [SELECT Id, Auto_Provisioning_Email_Sent__c FROM WDR_Application__c WHERE Id = :DefaultJobApplications[1].Id]
      .Auto_Provisioning_Email_Sent__c
    );
    System.assertEquals(
      false,
      [SELECT Id, Auto_Provisioning_Email_Sent__c FROM WDR_Application__c WHERE Id = :DefaultJobApplications[2].Id]
      .Auto_Provisioning_Email_Sent__c
    );

    Test.stopTest();
  }
}