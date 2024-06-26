@isTest
public class CEMCI_CampaignMembers_Test {
  @testSetup
  static void setup() {
    CEMCI_Test_Util.createCEMCICustomSetting();
    Test.startTest();
    List<CampaignMember> CampList = getCampaignMember();
    CampList.addAll(getLeadCampaignMember());
    Test.stopTest();
    insert CampList;
    CampList[0].Hired__c = false;
    CampList[0].Recruiting_Opt_In__c = 'Opt Out';
    CampList[0].Marketing_Opt_In__c = 'Opt Out';
    update CampList;
    CampaignMember cm = [
      SELECT id, Status, Contact.Id, Campaign.ID
      FROM CampaignMember
      WHERE Id = :CampList[0].Id AND Contact.Id != NULL
    ];
    System.assertEquals('Responded', CampList[0].Status);
  }
  static testMethod void updateApplicationCountsTest() {
    Id WDRCandirecordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
      .get('WDR_Candidate')
      .getRecordTypeId();
    Individual ind = new Individual(FirstName = 'Gonza', LastName = 'Alla', Salutation = 'Mr.');
    insert ind;
    Contact con = new Contact(
      FirstName = 'Mark',
      LastName = 'Kolen',
      IndividualId = ind.Id,
      recordtypeId = WDRCandirecordtypeId,
      Recruiting_Opt_In__c = 'Opt Out'
    );
    insert con;
    Contact con1 = new Contact(
      FirstName = 'Robin',
      LastName = 'jak',
      recordtypeId = WDRCandirecordtypeId,
      Recruiting_Opt_In__c = 'Opt Out'
    );
    insert con1;
    WDR_Candidate__c cand = new WDR_Candidate__c(
      Name = 'candidate',
      Candidate_Contact__c = con.Id,
      Email__c = 'cand@test.com',
      Status__c = 'New',
      First_Name__c = 'gopi',
      Last_Name__c = 'alladi'
    );
    insert cand;

    Campaign camp = new Campaign(Name = 'Test', IsActive = true, StartDate = system.Today() - 5);
    insert camp;
    Campaign camp1 = new Campaign(Name = 'Test', IsActive = true, StartDate = system.Today() - 5);
    insert camp1;

    Profile p1 = [SELECT id FROM Profile WHERE name = 'System administrator'];
    User opUser = new user(
      alias = 'test123',
      email = 'test123@noemail.com',
      emailencodingkey = 'UTF-8',
      firstName = 'Test user',
      lastname = 'Testing',
      languagelocalekey = 'en_US',
      localesidkey = 'en_US',
      profileid = p1.Id,
      country = 'United States',
      timezonesidkey = 'America/Los_Angeles',
      username = 'test01@noemail.com'
    );
    insert opUser;

    TF2_Business_Site__c bs = new TF2_Business_Site__c(
      Name = 'singapore',
      Country__c = 'Singapore',
      Type__c = 'test',
      Street_Address__c = 'testing'
    );
    insert bs;
    Business_Unit__c bunit = new Business_Unit__c(Name = 'unit1', Active__c = true, BU_Code__c = '12345');
    insert bunit;
    TF2_PCC__c pcc = new TF2_PCC__c(Name = 'pcc', Active__c = true, PCC_Code__c = '123');
    insert pcc;
    TF2_Department__c dp = new TF2_Department__c(Name = 'IT', Exclude_ESBP__c = true);
    insert dp;
    TF2_Company__c company = new TF2_Company__c(
      NAme = 'Test Company',
      Active__c = true,
      Region__c = 'LATAM',
      Company_Code__c = '100'
    );
    insert company;
    WDR_Job__c Job = new WDR_Job__c(
      Name = 'Job',
      Division__c = 'test',
      Job_Code__c = '123',
      Job_Title__c = 'soft',
      Employment_Type__c = 'type',
      Company__c = company.Id,
      Business_Unit__c = bunit.Id,
      Department__c = dp.Id,
      PCC__c = pcc.Id,
      Region__c = 'india',
      Hiring_Manager__c = opUser.Id
    );
    insert Job;
    Test.startTest();
    List<WDR_Application__c> wdAppList = new List<WDR_Application__c>();
    WDR_Application__c wsApp = new WDR_Application__c(
      Candidate_Stage__c = 'Placement',
      Business_Site__c = bs.Id,
      Candidate__c = cand.ID,
      Job__c = Job.Id,
      Offer_Type__c = 'offer',
      Application_Date__c = system.Today(),
      Start_Date__c = system.Today()
    );
    WDR_Application__c wsApp1 = new WDR_Application__c(
      Candidate_Stage__c = 'Pre-Placement',
      Business_Site__c = bs.Id,
      Candidate__c = cand.ID,
      Job__c = Job.Id,
      Offer_Type__c = 'offer',
      Application_Date__c = system.Today(),
      Start_Date__c = system.Today()
    );
    WDR_Application__c wsApp2 = new WDR_Application__c(
      Candidate_Stage__c = 'Placement',
      Business_Site__c = bs.Id,
      Candidate__c = cand.ID,
      Job__c = Job.Id,
      Offer_Type__c = 'offer',
      Application_Date__c = system.Today(),
      Start_Date__c = system.Today()
    );
    wdAppList.add(wsApp);
    wdAppList.add(wsApp1);
    wdAppList.add(wsApp2);
    insert wdAppList;
    wsApp.Candidate_Stage__c = 'Screen';
    update wsApp;
    List<CampaignMember> members = new List<CampaignMember>();
    CampaignMember member = new CampaignMember(
      ContactId = con.Id,
      Status = 'sent',
      CampaignId = camp.Id,
      Hired__c = true,
      Marketing_Opt_In__c = 'Opt Out',
      Recruiting_Opt_In__c = 'Opt Out',
      Total_Job_Applications__c = 1
    );
    members.add(member);
    CampaignMember member1 = new CampaignMember(
      ContactId = con1.Id,
      Status = 'Responded',
      CampaignId = camp1.Id,
      Hired__c = true,
      Marketing_Opt_In__c = 'Opt Out',
      Recruiting_Opt_In__c = 'Opt Out',
      Total_Job_Applications__c = 2
    );
    members.add(member1);
    insert members;
    System.assertEquals(2, members.size());
    List<WDR_Application__c> wdAppList1 = new List<WDR_Application__c>();
    WDR_Application__c wsApp3 = new WDR_Application__c(
      Candidate_Stage__c = 'Placement',
      Business_Site__c = bs.Id,
      Candidate__c = cand.ID,
      Job__c = Job.Id,
      Offer_Type__c = 'offer',
      Application_Date__c = system.Today(),
      Start_Date__c = system.Today()
    );
    WDR_Application__c wsApp4 = new WDR_Application__c(
      Candidate_Stage__c = 'Pre-Placement',
      Business_Site__c = bs.Id,
      Candidate__c = cand.ID,
      Job__c = Job.Id,
      Offer_Type__c = 'offer',
      Application_Date__c = system.Today(),
      Start_Date__c = system.Today()
    );
    wdAppList1.add(wsApp3);
    wdAppList1.add(wsApp4);
    insert wdAppList1;
    System.assertEquals(2, wdAppList1.size());
    Test.stopTest();
  }
  private static List<CampaignMember> getCampaignMember() {
    List<CampaignMember> CampMemList = new List<CampaignMember>();
    Id WDRCandirecordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
      .get('WDR_Candidate')
      .getRecordTypeId();
    for (integer i = 0; i < 2; i++) {
      Campaign camp = new Campaign(Name = 'Test1', IsActive = true, StartDate = system.Today() - 5);
      insert camp;

      Individual ind = new Individual(FirstName = 'Gonza', LastName = 'Alla', Salutation = 'Mr.');
      insert ind;
      Contact con = new Contact(
        FirstName = 'Mark1' + i,
        LastName = 'Kolen1',
        IndividualId = ind.Id,
        Recruiting_Opt_In__c = 'Opt Out',
        Initial_Interaction_Date__c = system.today() + 4,
        Last_Interaction_Date__c = system.today() - 2
      );
      con.recordtypeId = WDRCandirecordtypeId;
      insert con;

      CampaignMember aCampMemb = new CampaignMember();
      aCampMemb.ContactId = con.Id;
      aCampMemb.Status = 'Responded';
      aCampMemb.CampaignId = camp.Id;
      aCampMemb.Total_Job_Applications__c = 2;
      aCampMemb.Hired__c = true;
      aCampMemb.Member_Responded_Datetime__c = system.today();
      CampMemList.add(aCampMemb);
    }
    return CampMemList;
  }
  private static List<CampaignMember> getLeadCampaignMember() {
    List<CampaignMember> CampMemList = new List<CampaignMember>();
    Id WDRCandirecordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
      .get('WDR_Candidate')
      .getRecordTypeId();
    for (integer i = 0; i < 1; i++) {
      Campaign camp = new Campaign(Name = 'Test2' + i, IsActive = true, StartDate = system.Today() - 5);
      insert camp;
      Lead ld = new Lead(
        lastname = 'test lead123' + i,
        company = 'Test',
        Email = 'testlead123' + i + '@gmail.com',
        Status = 'Inquiry',
        Initial_Interaction_Date__c = system.today() + 4,
        Last_Interaction_Date__c = system.today() - 2,
        Marketing_Opt_In__c = 'Opt Out',
        Recruiting_Opt_In__c = 'Opt Out'
      );
      insert ld;
      ld.Company = 'Testing';
      update ld;
      CampaignMember aCampMemb1 = new CampaignMember();
      aCampMemb1.LeadId = ld.Id;
      aCampMemb1.Status = 'Responded';
      aCampMemb1.CampaignId = camp.Id;
      aCampMemb1.Hired__c = true;
      aCampMemb1.Total_Job_Applications__c = 1;
      aCampMemb1.Member_Responded_Datetime__c = system.today();
      CampMemList.add(aCampMemb1);
    }

    return CampMemList;
  }
  private static List<CampaignMember> addCampaigntoContact() {
    List<CampaignMember> CamMemList = new List<CampaignMember>();
    Id WDRCandirecordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
      .get('WDR_Candidate')
      .getRecordTypeId();
    for (integer i = 0; i < 1; i++) {
      Individual ind = new Individual(FirstName = 'Gonza', LastName = 'Alla', Salutation = 'Mr.');
      insert ind;
      Contact con = new Contact(
        FirstName = 'Mark1',
        LastName = 'Kolen1',
        email = 'testlead123@gmail.com',
        IndividualId = ind.Id,
        Initial_Interaction_Date__c = system.today() + 4,
        Last_Interaction_Date__c = system.today() - 2
      );
      con.recordtypeId = WDRCandirecordtypeId;
      insert con;
      Lead ld = new Lead(
        lastname = 'test lead123',
        company = 'Test',
        Email = 'testlead1@gmail.com',
        Status = 'Inquiry',
        Marketing_Opt_In__c = 'Opt In',
        Recruiting_Opt_In__c = 'Opt In',
        IsConverted = false
      );
      insert ld;

      ld.Company = 'Testing';
      ld.Email = 'testlead123@gmail.com';
      update ld;

      Campaign cam = new Campaign(Name = 'CampToCont', IsActive = true);
      insert cam;
      CampaignMember aCampMemb2 = new CampaignMember();
      aCampMemb2.contactId = ld.ConvertedContactId;
      aCampMemb2.Status = 'Responded';
      aCampMemb2.CampaignId = cam.Id;
      aCampMemb2.Marketing_Opt_In__c = ld.Marketing_Opt_In__c;
      aCampMemb2.Recruiting_Opt_In__c = ld.Recruiting_Opt_In__c;
      aCampMemb2.Member_Responded_Datetime__c = system.today() - 2;
      CamMemList.add(aCampMemb2);
    }
    return CamMemList;
  }
}