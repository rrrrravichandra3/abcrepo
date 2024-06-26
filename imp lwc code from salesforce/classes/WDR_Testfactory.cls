@istest
public class WDR_Testfactory {
  private WDR_Job__c DefaultJobReq;
  private WDR_Application__c DefaultJobApplication;
  private WDR_Candidate__c DefaultCandidate;
  private TF2_Company__c Comp;
  private Business_Unit__c BU;
  private TF2_Department__c dept;
  private TF2_PCC__c pcc;
  private TF2_Business_Site__c buSite;
  public static Id accId {
    get {
      if (accId == null) {
        Id accRId = [SELECT Id, name FROM RecordType WHERE developerName = 'Candidate' AND SobjectType = 'Account'].Id;
        Account acc = new Account(Name = 'Candidates', recordTypeId = accRId);
        insert acc;
        accId = acc.Id;
      }
      return accId;
    }
    set;
  }
  //Default Constructor
  public WDR_Testfactory() {
    dept = new TF2_Department__c(Department_Number__c = '7419', Name = 'IT Apps');
    BU = new Business_Unit__c(BU_Code__c = '2301', Name = 'Shared Services');
    Comp = new TF2_Company__c(Company_Code__c = '100', Name = '100-United States of America');
    pcc = new TF2_PCC__c(name = '100-United States of America');
    buSite = new TF2_Business_Site__c(
      name = 'Remote -California - San Francisco',
      Country__c = 'Unites States',
      Street_Address__c = '350 Mission St',
      Type__c = 'City'
    );
    insert dept;
    insert BU;
    insert COMP;
    insert PCC;
    insert buSite;

    Onboarding_Setting__c onboardSetting = new Onboarding_Setting__c();
    onboardSetting.OfferTypes_to_Exclude_For_NHW__c = 'Internal transfer,M&A,Inter-department Transfer,Intra-department Transfer, Salesforce Core to .Org Transfer, .Org to Salesforce Core Transfer,OOM-Internal Transfer,Contingent Worker,ARC';
    onboardSetting.JobCreationReasons_to_Exclude_For_NHW__c = 'Acquisition > Acquisition';
    //onboardSetting.WDR_Placement_And_Later_Stages__c ='Placement';
    //onboardSetting.WDR_Preplacement_Stages__c = 'Pre-Placement';
    onboardSetting.Pre_boarding_window__c = 30;
    onboardSetting.move_validations_to_apex__c = true;
    insert onboardSetting;

    user portaluser = [SELECT id FROM user WHERE contactid != NULL AND email = :UserInfo.getUserEmail() LIMIT 1];

    //Create Contact - Moving it after jobscience foundation as QA4 has default record type as candidate
    Contact HiringMgerContact = new Contact();
    HiringMgerContact.FirstName = UserInfo.getFirstName();
    HiringMgerContact.LastName = UserInfo.getLastName();
    HiringMgerContact.Email = UserInfo.getUserEmail();
    HiringMgerContact.recordtypeid = NHW_Util.getEmployeeContactRecordTypeId();
    insert HiringMgerContact;
    populateDefaults();
  }
  //Construtor to override defaults
  public WDR_Testfactory(WDR_Job__c JobReq, WDR_Candidate__c Candidate, WDR_Application__c JobApp) {
    this.DefaultJobReq = JobReq;
    this.DefaultCandidate = Candidate;
    this.DefaultJobApplication = JobApp;
  }

  public void populateDefaults() {
    DefaultJobReq = new WDR_Job__c();
    DefaultJobReq.Name = 'Test JobReq';
    DefaultJobReq.Job_Title__c = 'MTS';
    DefaultJobReq.Job_Level__c = 'Grade 4';
    DefaultJobReq.Job_Code__c = '1235PQ';
    DefaultJobReq.Employment_Type__c = 'SFDC Employee';
    DefaultJobReq.PCC__c = pcc.id;
    DefaultJobReq.Region__c = 'AMER';
    DefaultJobReq.Division__c = 'Americas - All countries';
    DefaultJobReq.Target_Hire_Date__c = System.today().adddays(15);
    DefaultJobReq.Department__c = dept.id;
    DefaultJobReq.Business_Unit__c = bu.id;
    DefaultJobReq.Company__c = comp.id;
    DefaultJobReq.Hiring_Manager__c = UserInfo.getUserId();
    DefaultJobReq.Req_Creation_Reason__c = 'Regular';

    DefaultCandidate = new WDR_Candidate__c();
    DefaultCandidate.First_Name__c = 'Test F';
    DefaultCandidate.Last_Name__c = 'Test L';
    DefaultCandidate.Name = 'Test F' + 'Test L';
    DefaultCandidate.Email__c = 'Test_F_L@salesforce.com';
    DefaultCandidate.Mailing_City__c = 'San Francisco';
    DefaultCandidate.Mailing_Country__c = 'United States of America';
    DefaultCandidate.Mailing_Postal_Code__c = '94002';
    DefaultCandidate.Mailing_State__c = 'CA';
    DefaultCandidate.Mailing_Street__c = '350 mission st';

    DefaultJobApplication = new WDR_Application__c();
    DefaultJobApplication.Business_Site__c = buSite.id;
    DefaultJobApplication.Offer_Type__c = 'Perm/FTE';
    DefaultJobApplication.Offer_Status__c = 'Approved';
    DefaultJobApplication.Start_Date__c = System.Today().adddays(10);
    //Creating Job App is start stage - respective stage can be updated by consuming classes
    DefaultJobApplication.Candidate_Stage__c = 'Screen';
  }

  //Getters to get populated defaults
  public WDR_Application__c getDefaultJobApp() {
    return DefaultJobApplication;
  }

  public WDR_Job__c getDefaultJobReq() {
    return DefaultJobReq;
  }

  public WDR_Candidate__c getDefaultCandidate() {
    return DefaultCandidate;
  }
  public void resetIds() {
    DefaultCandidate.id = null;
    DefaultJobReq.id = null;
    DefaultJobApplication.id = null;
  }
  public void createJobApp() {
    Savepoint sp = Database.setSavepoint();
    try {
      insert DefaultCandidate;
      Contact con = createContact(DefaultCandidate);
      insert con;
      DefaultCandidate.Candidate_Contact__c = con.Id;
      update DefaultCandidate;
      insert DefaultJobReq;
      DefaultJobApplication.Candidate__c = DefaultCandidate.Id;
      DefaultJobApplication.Job__c = DefaultJobReq.Id;
      insert DefaultJobApplication;
    } catch (Exception ex) {
      Database.rollback(sp);
      resetIds(); //As id of sobject var is not reset after roolback
      throw ex;
    }
  }

  //Create Job Apps in bulk - N candidates applying for given Job.
  public void createJobApps(Integer N) {
    List<WDR_Candidate__c> candidates = new List<WDR_Candidate__c>();
    List<Contact> cons = new List<Contact>();
    List<WDR_Application__c> jobApps = new List<WDR_Application__c>();
    WDR_Candidate__c defaultCandidate = getDefaultCandidate();
    WDR_Job__c defaultJobReq = getDefaultJobReq();
    WDR_Application__c defaultJobApp = getDefaultJobApp();
    Savepoint sp = Database.setSavepoint();
    try {
      insert defaultJobReq;
      for (Integer i = 0; i < N; i++) {
        WDR_Candidate__c cand = defaultCandidate.clone(false, true, false, false);
        Contact c = new Contact();
        c.FirstName = cand.First_Name__c + i;
        c.LastName = cand.Last_Name__c + i;
        c.recordtypeid = NHW_Util.getCandidateContactRecordTypeId();
        c.Email = 'Test' + i + '@test.com';
        cons.add(c);
      }
      insert cons;

      for (Integer i = 0; i < N; i++) {
        WDR_Candidate__c c = defaultCandidate.clone(false, true, false, false);
        c.First_Name__c = c.First_Name__c + i;
        c.Last_Name__c = c.Last_Name__c + i;
        c.Name = c.First_Name__c + c.Last_Name__c;
        c.Email__c = 'Test' + i + '@test.com';
        c.Candidate_Contact__c = cons.get(i).Id;
        candidates.add(c);
      }
      insert candidates;

      for (Integer i = 0; i < N; i++) {
        WDR_Application__c jobApp = defaultJobApp.clone(false, true, false, false);
        jobApp.Candidate__c = candidates[i].id;
        jobApp.Job__c = defaultJobReq.id;
        jobApps.add(jobApp);
      }
      insert jobApps;
    } catch (Exception ex) {
      Database.rollback(sp);
      resetids();
      throw ex;
    }
  }
  public Contact createContact(WDR_Candidate__c cand) {
    Contact con = new Contact();
    con.FirstName = cand.First_Name__c;
    con.LastName = cand.Last_Name__c;
    con.Email = cand.Email__c;
    con.NHW_Candidate__c = cand.Id;
    con.recordtypeid = NHW_Util.getCandidateContactRecordTypeId();
    return con;
  }

  //Setter Methods to override default
  public void setBusinessUnit(id BusinessUnit) {
    DefaultJobReq.Business_Unit__c = BusinessUnit;
  }
  public void setCostCenter(id costCenterId) {
    DefaultJobReq.Department__c = costCenterId;
  }
  public void setBusinessSite(id BizSiteId) {
    DefaultJobApplication.Business_Site__c = BizSiteId;
  }
  public void setPCC(id PrimaryCvrgeCountry) {
    DefaultJobReq.PCC__c = PrimaryCvrgeCountry;
  }
  public void setCompany(Id CompanyId) {
    DefaultJobReq.Company__c = CompanyId;
  }
  public void setStartDate(Date StartDate) {
    DefaultJobApplication.Start_Date__c = StartDate;
  }
  public void setDoNotSend(Boolean DoNotSend) {
    DefaultJobApplication.Do_Not_Send_NHW__c = DoNotSend;
  }
  public void setPreboardingFlag(Boolean PreboardingFlag) {
    DefaultJobApplication.NHW_Create_Preboarding_Case__c = PreboardingFlag;
  }
  public void setInternalCandidateFlag(Boolean InternalFlag) {
    DefaultJobApplication.Internal_Candidate__c = InternalFlag;
  }
  public void setCandidateStage(String Stage) {
    DefaultJobApplication.Candidate_Stage__c = Stage;
  }
}