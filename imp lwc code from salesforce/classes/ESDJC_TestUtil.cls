/**
    This class contains common utility methods to used in other test clases
*/
public with sharing class ESDJC_TestUtil {
    public Integer testVar = 1;
    
    //Creates an Account record
    public static Account createAccount() {
        Account anAccount = new Account();
        anAccount.Name = 'DJC Account';
        insert anAccount;//Default recordtype is Candidate
        return anAccount;
    }
    
    //Creates a Contact record
    public static Contact getContact() {
        return getContact('Americas - USA');
    }
    public static Contact getContact(String division) {
        Contact aContact = new Contact();
        aContact.AccountId = createAccount().Id;
        aContact.FirstName = 'DJC';
        aContact.LastName = 'Dream Job Central';
        aContact.Email = 'test@salesforce.com';
        aContact.Division__c = division;
        insert aContact;
        return aContact;
    }

     public static Contact getContact(String division,string dept) {
        Contact aContact = new Contact();
        aContact.AccountId = createAccount().Id;
        aContact.FirstName = 'DJCDept';
        aContact.LastName = 'Dream Job Central';
        aContact.Division__c = division;
        aContact.Department = dept;
        insert aContact;
        return aContact;
    }

    public static List<Contact> getContactManagementHirearchy() {
        
        List<Contact> contactList = new List<Contact>();
        
        for(Integer i=0;i<5;i++){

            Contact aContact = new Contact();
            aContact.AccountId = createAccount().Id;
            aContact.FirstName = 'DJC';
            aContact.LastName = 'Dream Job Central';
            aContact.Division__c = 'Americas - USA';
            aContact.Email = 'testcontactemail@test.com';
            contactList.add(aContact);

        }
        
        insert contactList;

        return contactList;

    }

    //Creates an Acquistion Company
    public static Acquisition_Company__c getAcquistionCompany() { 
        
      Acquisition_Company__c acquistionCompany = new Acquisition_Company__c();
      acquistionCompany.Acquisition_Company_Name__c = 'Test Acquisition Company';
      insert acquistionCompany;
      return acquistionCompany;
    }  
    
    //Creates an Acquistion Contact
    public static Acquisition_Contacts__c getAcquistionContact() { 
        
      Acquisition_Contacts__c acq = new Acquisition_Contacts__c();
      acq.Acquisition_Company__c = getAcquistionCompany().Id;
      acq.Email_Address_Target__c = 'test@example.com';
      acq.Salesforce_Email_Address__c = 'test@salesforce.com';
      insert acq;
      return acq;
    }
       
    //Creates a Case record 
    public static Case createCase() {       
        Case aCase = new Case();
        
        List<RecordType> recordTypes = [SELECT Id,SobjectType FROM RecordType WHERE SobjectType = 'Case'];
        if(recordTypes != null && recordTypes.size() > 0) {
            aCase.RecordTypeId = recordTypes.get(0).Id;
        }
        aCase.ContactId = getContact().Id;
        insert aCase;
        return aCase;
    }

    //Creates ER Investigation Case  
    public static Case getERInvestigationCase() {       
        
        Case investigationCase = new Case();

        Id RecTypeId = [SELECT Id FROM RecordType WHERE SobjectType ='Case' 
                        and DeveloperName='ER_Investigations' LIMIT 1].Id;

        investigationCase.RecordTypeId = RecTypeId;
        investigationCase.ContactId = getContact().Id;
        insert investigationCase;
        
		investigationCase.Subject = 'test';
        update investigationCase;
        
        return investigationCase;
    }
//Creates ER Restricted  Case  
    public static ER_Restricted_Case__c getERRestrictedCase() {       
        
        ER_Restricted_Case__c erRestrictedCase = new ER_Restricted_Case__c();

        erRestrictedCase.Name = 'test ER';
        erRestrictedCase.Accused__c = getContact().ID;
        insert erRestrictedCase;
        
		erRestrictedCase.Name = 'test';
        update erRestrictedCase;
        
        erRestrictedCase.Name = 'test ERCase';
        delete erRestrictedCase;
        return erRestrictedCase;
    }
    //Creates Allegation  
    public static Allegations__c getAllegationCase() {       
        
        Allegations__c anAllegation = new Allegations__c();
		Id RecTypeId = [SELECT Id FROM RecordType WHERE SobjectType ='Allegations__c' 
                        and DeveloperName='ER_Allegations' LIMIT 1].Id;

        anAllegation.RecordTypeId = RecTypeId;
        anAllegation.Accused_Type__c = 'Employee';
        anAllegation.Issue_Type__c = 'Attendance';
        anAllegation.Case__c = createCase().Id;
        anAllegation.Accused__c = getContact().ID;
        insert anAllegation;
        
		anAllegation.Accused_Type__c = 'Vendor';
        update anAllegation;
        
        anAllegation.Accused_Type__c = 'Employee';
        delete anAllegation;
        
        return anAllegation;
    }
    //Creates General ER Case  
    public static Case getGERInvestigationCase() {       
        
        Case gerCase = new Case();

        Id RecTypeId = [SELECT Id FROM RecordType WHERE SobjectType ='Case' 
                        and DeveloperName='General_Employee_Relations_Case' LIMIT 1].Id;

        gerCase.RecordTypeId = RecTypeId;
        gerCase.ContactId = getContact().Id;
        gerCase.Origin = 'Email';
        gerCase.Type = 'Feedback';
        gerCase.ES_DJC_Topic__c = 'Employee Relations';
        gerCase.PII__c = 'Yes';
        gerCase.Subject = 'Unit Testing';
        insert gerCase;
        
        gerCase.PII__c = 'No';
        update gerCase;
        
        return gerCase;
    }

    //Creates GE&I Case     
    public static Case getGEICase() { 

        Case GEICase = new Case();

        Id RecTypeId = [SELECT Id FROM RecordType WHERE SobjectType ='Case' 
                        and DeveloperName='Global_Ethics_Integrity' LIMIT 1].Id;

        GEICase.RecordTypeId = RecTypeId;
        GEICase.ContactId = getContact().Id;
        insert GEICase;
        return GEICase;
    }
    
    //Creates GE&I Allegation  
    public static Allegations__c getGEIAllegation() { 

        Allegations__c GEIAllegation = new Allegations__c();

        Id RecTypeId = [SELECT Id FROM RecordType WHERE SobjectType ='Allegations__c' 
                        and DeveloperName='GE_I_Allegations' LIMIT 1].Id;

        GEIAllegation.RecordTypeId = RecTypeId;
        GEIAllegation.Case__c = getGEICase().Id;
        GEIAllegation.Accused__c = getContact().Id;
        insert GEIAllegation;
        return GEIAllegation;
    }
      
    //Creates Warmline Case
    public static Case getWarmlineCase() { 

        Case WarmlineCase = new Case();

        Id RecTypeId = [SELECT Id FROM RecordType WHERE SobjectType ='Case' 
                        and DeveloperName='Warmline' LIMIT 1].Id;

        WarmlineCase.RecordTypeId = RecTypeId;
        WarmlineCase.ContactId = getContact().Id;
        insert WarmlineCase;
        return WarmlineCase;
    }

    //Creates Warmline record
    public static Warmline__c getWarmlineCase(Case c) { 

        Warmline__c record = new Warmline__c();
        record.Case__c = c.Id;
        insert record;
        return record;
    }

    //Create candidate record 
    public static Contact createCandidateContact(String referralemail) {
        Contact aContact = new Contact();
        aContact.AccountId = createAccount().Id;
        aContact.FirstName = 'DJC';
        aContact.LastName = 'Dream Job Central';
        aContact.Email='fake_email@djc.com';
        aContact.Referrer_Email__c=referralemail;
        insert aContact;
        return aContact;        
    }
    
    public static Contact insertCandidateRecord(String fn, String ln, String email){ 
    Contact candidate = new Contact();
    candidate.RecordTypeId=candidateRecType;
    candidate.AccountId = candidateAcctId;
    candidate.FirstName = fn;
    candidate.lastName=ln;
    candidate.email=email;
    candidate.ts2__EmployerOrgName_1__c='Sample Employee Org Name';
    candidate.MailingStreet = '123 Mission street';
    candidate.MailingCity = 'San Francisco';
    candidate.MailingState = 'CA';
    candidate.MailingPostalCode = '95104';
    candidate.MailingCountry = 'US';
    insert candidate;
    return candidate;
}
    
    
    private static Id candidateRecType {
        get {
            if (candidateRecType == null) {
                candidateRecType = [select id from RecordType where name = 'Candidate' and sobjectType = 'Contact' limit 1].id;
            }
            return candidateRecType;            
        }
        private set;
    }


    //TODO:We need to have testfactory API with TAD instead of relying on org data
    private static Id candidateAcctId {
        get {
            if (candidateAcctId == null) {
                candidateAcctId = [Select Id, name from Account Where recordType.name ='Candidate' and name='Candidates' limit 1].id;
            }
            return candidateAcctId;            
        }
        private set;
    }
    
    
    //Create a new User 
    
    public static User getUserRecord(boolean isCustomerPortalUser){
            
            List<Profile> userProfiles; 
            if(!isCustomerPortalUser){
                userProfiles = [select id from Profile where name='Employee Success Representative' limit 1];
                }
                else{
                  userProfiles =  [select id from Profile where userlicense.name='Customer Portal Manager Custom' limit 1];
                }
            if(userProfiles!=null && userProfiles.size()>0){
                Profile userProfile = userProfiles[0];
                User djc_test_user = new User(alias = 'standt',email='standarduser@drmjob.com',emailencodingkey='UTF-8',lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', 
                                           profileid = userProfiles[0].id,timezonesidkey='America/Los_Angeles',username='standarduser@fakeusername.com');
               insert djc_test_user;
               return djc_test_user;
           
        }
        return null;
    }
    
    
    //create a community 
    
    public static Community getCommunity(){
        List<Community> comms= [select id from Community where isActive = true ];
        
        if(comms!=null && comms.size()>0){
            return comms[0];
        }
        return null; 
    }
    
    //create question 
    
    public static Question getQuestion(Community comm){
        Community test_community ;
        if(comm==null){
            test_community = getCommunity();
        }
        else{
            test_community = comm;
        }
        Question test_question = new Question(Title = 'testing question', CommunityId=test_community.id,Body='testing question');
        try{
            insert test_question;
        }
        catch(Exception e){
            System.debug('failed question insertion' + e.getMessage());
        }
        if(test_question!=null && test_question.id!=null){
            return test_question;
        }
        return null;
    }
    public static void createRegionRecords(){
        list< ESDJC_Region__c > regionList= new list<ESDJC_Region__c>();
        list< ESDJC_Country__c > countryList= new list< ESDJC_Country__c >();
        regionList.add(new ESDJC_Region__c(Name = 'APAC'));
        regionList.add(new ESDJC_Region__c(Name = 'Americas'));
        regionList.add(new ESDJC_Region__c(Name = 'EMEA'));
        regionList.add(new ESDJC_Region__c(Name = 'Japan'));
        
        insert regionList;
        
        countryList.add(new ESDJC_Country__c(Region__c = regionList[0].id,Name = 'Australia'));
        countryList.add(new ESDJC_Country__c(Region__c = regionList[0].id,Name = 'China'));
        countryList.add(new ESDJC_Country__c(Region__c = regionList[0].id,Name = 'Hong Kong'));
        countryList.add(new ESDJC_Country__c(Region__c = regionList[0].id,Name = 'India'));
        countryList.add(new ESDJC_Country__c(Region__c = regionList[0].id,Name = 'Seoul'));
        countryList.add(new ESDJC_Country__c(Region__c = regionList[0].id,Name = 'New Zealand'));
        
        countryList.add(new ESDJC_Country__c(Region__c = regionList[1].id,Name = 'Canada'));
        countryList.add(new ESDJC_Country__c(Region__c = regionList[1].id,Name = 'United States')); 
        
               
        countryList.add(new ESDJC_Country__c(Region__c = regionList[2].id,Name = 'Belgium'));
        countryList.add(new ESDJC_Country__c(Region__c = regionList[2].id,Name = 'Denmark'));
        countryList.add(new ESDJC_Country__c(Region__c = regionList[2].id,Name = 'Finland'));
        countryList.add(new ESDJC_Country__c(Region__c = regionList[2].id,Name = 'Germany'));
        countryList.add(new ESDJC_Country__c(Region__c = regionList[2].id,Name = 'Israel'));
        countryList.add(new ESDJC_Country__c(Region__c = regionList[2].id,Name = 'Ireland'));
        countryList.add(new ESDJC_Country__c(Region__c = regionList[2].id,Name = 'Italy'));
        countryList.add(new ESDJC_Country__c(Region__c = regionList[2].id,Name = 'Netherlands'));
        countryList.add(new ESDJC_Country__c(Region__c = regionList[2].id,Name = 'Spain'));
        countryList.add(new ESDJC_Country__c(Region__c = regionList[2].id,Name = 'Sweden'));
        countryList.add(new ESDJC_Country__c(Region__c = regionList[2].id,Name = 'Switzerland'));
        countryList.add(new ESDJC_Country__c(Region__c = regionList[2].id,Name = 'United Kingdom'));
        
        countryList.add(new ESDJC_Country__c(Region__c = regionList[3].id,Name = 'Japan'));
        
        insert countryList;
    }
    
    public static User getPortalUser(string country,string division){
        ID ProfileID = [ Select id from Profile where name = 'Customer Portal Manager Custom'].id;
        Account A1 = new Account(Name = 'Test Account');
        insert A1;
        
        
        List<Contact> ContactList = new List<Contact>();
        Contact C1 = new Contact( AccountID = A1.id, FirstName = 'Test', LastName = 'User',ES_DJC_Contact_Country__c = country, Division__c = division,
        email = 'test-user@fakemail.com',RecordTypeId=[select id,name from RecordType where sObjectType='Contact' and Name='Employee'].Id );
        insert C1;
        
        User u1 = new User( email='test-user@fakemail.com', contactid = c1.id, profileid = profileid, 
                UserName='test-user@fakemail.com', alias='tuser1', CommunityNickName='tuser2', 
        TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
        LanguageLocaleKey='en_US', FirstName = 'Test', LastName = 'User',Division = division );
        insert u1;
        
        insert new ContactShare(UserOrGroupId= u1.Id,ContactAccessLevel='Read',ContactId = C1.Id);
        return u1;
    }
    
    public static User getPortalUser(string country,string division, String workLoc){
        ID ProfileID = [ Select id from Profile where name = 'Customer Portal Manager Custom'].id;
        Account A1 = new Account(Name = 'Test Account');
        insert A1;
        
        
        List<Contact> ContactList = new List<Contact>();
        Contact C1 = new Contact( AccountID = A1.id, FirstName = 'Test', LastName = 'User',ES_DJC_Contact_Country__c = country, Division__c = division,
        email = 'test-user@fakemail.com', ES_DJC_Work_Location__c= workLoc, RecordTypeId=[select id,name from RecordType where sObjectType='Contact' and Name='Employee'].Id );
        insert C1;
        
        User u1 = new User( email='test-user@fakemail.com', contactid = c1.id, profileid = profileid, 
                UserName='test-user@fakemail.com', alias='tuser1', CommunityNickName='tuser2', 
        TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
        LanguageLocaleKey='en_US', FirstName = 'Test', LastName = 'User',Division = division );
        insert u1;
        
        insert new ContactShare(UserOrGroupId= u1.Id,ContactAccessLevel='Read',ContactId = C1.Id);
        return u1;
    }


    public static User getConciergeUser(string country,string division){        
        return createStandardUser('API Internal - eApps Facade', null, country, division);
    }
    
    public static User getSysAdminUser() {
      return createStandardUser('System Administrator', 'CEO', null, null);
    }
    
    public static void createCommunitySetting(){
        list<ESDJC_Comunities__c> communityList = new list<ESDJC_Comunities__c>();  
        communityList.add(new ESDJC_Comunities__c(Name = 'About Me', Image__c = 'aboutme', IsDefault__c = true, Sequence__c = 1));
        communityList.add(new ESDJC_Comunities__c(Name = 'Manager Resources', Image__c = 'manager_resources', IsDefault__c = false, Sequence__c = 2));
        
        insert communityList;
    }
    
    public static void createArticleTypesSetting(){
        list<ESDJC_Article_Types__c > artList = new list<ESDJC_Article_Types__c>();
        artList.add(new ESDJC_Article_Types__c(Custom_Fields__c = 'Question__c,Solution__c',Name = 'How_To__kav'));
        insert artList;
    }
    
    public static void createSSOIdSetting(){
        if([select count() from ESDJC_Settings__c] <1){
            ESDJC_Settings__c mSettings = new ESDJC_Settings__c(SSO_Dreamjobcentral_ID__c = 'fakemail.com', Site_URL__C='test/url');
            insert mSettings;
        }
        else{
            ESDJC_Settings__c mSettings = [select SSO_Dreamjobcentral_ID__c from ESDJC_Settings__c];
            mSettings.SSO_Dreamjobcentral_ID__c = 'fakemail.com';
            update mSettings;
        } 
    }
    
    public static void assignPermission(id uId,string permissionSet){
        PermissionSetAssignment ps = new PermissionSetAssignment(AssigneeId = uId,PermissionSetId = [select id from PermissionSet where name=:permissionSet].Id);
        insert ps;
    }
    
    public static User createStandardUser(String profileName, String userRoleName, String country, String division) {
      return createStandardUser(profileName, userRoleName, country, division, null);
    }
    
    /**
     ** Use this to create a user with username that has the random number appended to
     ** the username. Usernames are created using profile names and this method is useful
     ** when we want multiple users with same profiles in a test method so as to avoid
     ** duplicate username exception. Max length of randNum is 2. If it is greater than 2,
     ** first two characters are taken
     */
    public static User createStandardUser(String profileName, String userRoleName, String country, String division, String randNum) {
      Id profileId = [select Id from Profile where Name = :profileName].Id;
      
      Id userRoleId = null;
      String alias = null;
      Boolean isAPIUser = false;
      
      if(profileName.contains('API Internal')){
        	isAPIUser = true;
      }
      if (randNum == null) {
        alias = profileName.replaceAll(' ', '').left(8);
        
      } else {
        if (randNum.length() > 2) {
          randNum = randNum.left(2);
        }
        alias = profileName.replaceAll(' ', '').left(8 - randNum.length()) + randNum;
      }
      String userName =  alias + '-test@fakeuser.com' + Integer.valueof((Math.random() * 100));
      if (userRoleName != null) {
        userRoleId = [select id from UserRole where Name = :userRoleName].Id;
      }
      
      User u1 = new User( email='test-user@fakemail.com', ProfileId = profileId, 
                UserName=userName, alias=alias, CommunityNickName=alias, 
        TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
        LanguageLocaleKey='en_US', FirstName = 'Test', LastName = 'User', UserRoleId=userRoleId, Division = division );
        if(isAPIUser){
        	u1.API_User__c = true;
        	u1.Team_DL_Email__c = 'test-user@fakemail.com';
        	u1.Login_Policy__c = '60'; 
        }

        insert u1;       
        return u1;
    }
        
    public static void createEntitlements(String accountId) {
    List<Entitlement> entitlements = new List<Entitlement>();
    
    for (SlaProcess slaProcess : [select Id, Name from SlaProcess]) {
      entitlements.add(new Entitlement(Name=slaProcess.Name, SlaProcessId=slaProcess.Id, AccountId=accountId, StartDate=System.today()));
    }
    
    insert entitlements;
  }

  public static void init(){
    ESDJC_Settings__c setting = new ESDJC_Settings__c();
    setting.Run_trigger__c = true;
    setting.Site_URL__c = '/site/url';
    setting.Portal_User_Profile_Id__c = '00e70000000xEB1';
    setting.Concierge_API_User_Profile_Id__c = '00en0000000HgEa';
    setting.djc_Helpdesk_API_User__c = '00570000002SpX4AAK';
    setting.Valid_SLA_Origins__c='Employee Success - Web,REWS - Web,Chatter Answers,Email,Concierge Desktop,Concierge Mobile,Article Feedback';
    setting.DJC_Override_Entitlement_Origins__c = 'Phone,Live Agent,Face To Face,Ethics Point,Email,Package Delivery';
    setting.DJC_Override_Entitlement_Types__c = 'Wellness Reimbursement Request,Mail Services';   
    setting.Ergo_Locations__c = 'san francisco,new york,chicago,portland,spokane,toronto';
    setting.Payroll_Amer_ID__c='00E70000001L66A';
    setting.Tier_Age_Date_Filter__c = Date.newInstance(2015,02,01);
    setting.All_Cases_Except_ER_EMEA_RT__c = [select id from RecordType where DeveloperName = 'ES_DJC_All_Case_Types_except_ER_EMEA'].id;
    setting.DJC_Batchjob_Support_Email__c  = 'test@qa4.dev';
    setting.DJC_Integration_Batch_Size__c  = 200; 
    setting.DJC_WD_Depts_To_Exclude__c  = 'FOUN-Foundation'; 
    setting.Foundation_Dept_Names__c  = 'FOUN-Foundation'; 
  	setting.Survey_Email_Frequency__c=5;
    setting.DJC_WD_Cutoff_Date_DD__c=1;
    
    insert setting;
    REWS_Setting__c rewsSetting = new REWS_Setting__c();
    try{
     RecordType packageRT = [select Id from RecordType where sObjectType = 'Case' and Name='All REWS Package Management' LIMIT 1];
     Group mailQueue = [select Id from Group where Type='Queue' and Name='REWS - Mail Services HQ' LIMIT 1];
     rewsSetting.Mail_services_queue_Id__c = mailQueue.Id;
     rewsSetting.Case_Package_Delivery_Record_Type__c = packageRT.Id;
     } catch (System.QueryException e){
         SYstem.debug('Query exception' + e.getMessage());
     }
     List<RecordType> rt = [SELECT id, DeveloperName FROM RecordType where sobjecttype = 'case' and developername in ('All_REWS_cases_AMER_NonHQ', 'All_REWS_cases_AMER_HQ', 'All_REWS_cases_APAC','All_REWS_cases_EMEA','All_REWS_cases_Japan')];
      for (recordType r : rt) {
          if (r.developername == 'All_REWS_cases_AMER_HQ') {
              rewsSetting.REWS_Case_Record_Type_Amer_HQ__c = r.id;
          }  
		if (r.developername == 'All_REWS_cases_AMER_NonHQ') {
              rewsSetting.REWS_Case_Record_Type_Amer_Non_HQ__c = r.id;
          }  
		if (r.developername == 'All_REWS_cases_APAC') {
              rewsSetting.REWS_Case_Record_Type_APAC__c = r.id;
          }  
		if (r.developername == 'All_REWS_cases_EMEA') {
              rewsSetting.REWS_Case_Record_Type_EMEA__c = r.id;
          }  
		if (r.developername == 'All_REWS_cases_Japan') {
              rewsSetting.REWS_Case_Record_Type_Japan__c = r.id;
          }
      }      
    insert  rewsSetting;
      
    List<ESDJC_Domains_Whitelist__c> whiteListDomains = new List<ESDJC_Domains_Whitelist__c>{new ESDJC_Domains_Whitelist__c(Name = 'Heroku', domain__c = 'heroku.com'), new ESDJC_Domains_Whitelist__c(Name = 'ABC', domain__c = 'abc.com')};
    insert whiteListDomains;
  }
  
    //This methods produces fake ids for testing
    static Integer s_num = 1;
    
    public static String getFakeId(Schema.SObjectType sot){
        String result = String.valueOf(s_num++);
        return sot.getDescribe().getKeyPrefix() + '0'.repeat(12 - result.length()) + result;
    }
}