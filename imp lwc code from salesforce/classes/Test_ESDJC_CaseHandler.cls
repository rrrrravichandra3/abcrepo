@isTest(SeeAllData=true)
public without sharing class Test_ESDJC_CaseHandler {
  //TODO - SeeAllData is set to true due to lack  of valid config data of upstream candidates/accounts/contacts
  //Need to have valid testfactory API from TAD .
  static testMethod void testUpdateBusinessHoursAMER() {    
    Contact aContact = ESDJC_TestUtil.getContact();
    System.assertEquals('Americas - USA', aContact.Division__c );

    Case aCase = new Case();
    aCase.ContactId = aContact.Id;
    insert aCase;   
    aCase = [SELECT Division_Lookup__c, BusinessHoursId from Case WHERE id=:aCase.Id];
    System.assertEquals('Americas - USA', aCase.Division_Lookup__c);

    BusinessHours bousinessHour = [SELECT ID, Name from BusinessHours WHERE name = 'Americas' ];
    System.assertEquals(bousinessHour.Id, aCase.BusinessHoursId);
  }
  static testMethod void testUpdateBusinessHoursEMEA() {    
    Contact aContact = ESDJC_TestUtil.getContact('EMEA – All Countries');
    System.assertEquals('EMEA – All Countries', aContact.Division__c );

    Case aCase = new Case();
    aCase.ContactId = aContact.Id;
    insert aCase;   
    aCase = [SELECT Division_Lookup__c, BusinessHoursId from Case WHERE id=:aCase.Id];
    System.assertEquals('EMEA – All Countries', aCase.Division_Lookup__c);

    BusinessHours bousinessHour = [SELECT ID, Name from BusinessHours WHERE name = 'EMEA' ];
    System.assertEquals(bousinessHour.Id, aCase.BusinessHoursId);
  }
  
  static testMethod void testUpdateBusinessHoursLACA() {    
    Contact aContact = ESDJC_TestUtil.getContact('Americas - Latin America');
    System.assertEquals('Americas - Latin America', aContact.Division__c );

    Case aCase = new Case();
    aCase.ContactId = aContact.Id;
    insert aCase;   
    aCase = [SELECT Division_Lookup__c, BusinessHoursId from Case WHERE id=:aCase.Id];
    System.assertEquals('Americas - Latin America', aCase.Division_Lookup__c);

    BusinessHours businessHour = [SELECT ID, Name from BusinessHours WHERE name = 'LACA' ];
    System.assertEquals(businessHour.Id, aCase.BusinessHoursId);
  }
  static testMethod void testCaseArticleCheck() { 
    Id howToRecordTypeId = [Select Id from RecordType where DeveloperName='How_To'].Id;
    Knowledge__kav article = new Knowledge__kav();
    article.title = 'My How To Article';
    article.UrlName = 'My-How-To-Article';
    //article.PublishStatus = 'online'; // this field is not writable
    article.Language = 'en_US';
    article.Review_Cycle__c = '3';
    article.Article_Owner_Group__c = 'Benefits - EMEA';
    article.RecordTypeId = howToRecordTypeId;
    insert article;

    article = [SELECT KnowledgeArticleId from Knowledge__kav WHERE id=:article.Id];  
    System.assertNotEquals(null, article.KnowledgeArticleId); 

    Contact aContact = ESDJC_TestUtil.getContact();
    Case aCase = new Case();
    aCase.ContactId = aContact.Id;
    insert aCase;   

    CaseArticle aCaseArticle = new CaseArticle();
    aCaseArticle.CaseId = aCase.Id;
    aCaseArticle.KnowledgeArticleId = article.KnowledgeArticleId;
    Profile adminProfile = [Select id, name from Profile where name = 'System Administrator' limit 1];
    User user = [SELECT EmployeeNumber,Id FROM User WHERE IsActive = true AND EmployeeNumber != null AND ProfileId =:adminProfile.id limit 1];
    System.runAs(user) {
      insert aCaseArticle;
    }
    aCaseArticle = [Select KnowledgeArticleId, CaseId, CreatedById from CaseArticle Where CaseId =: aCase.Id];
    System.assertEquals(article.KnowledgeArticleId, aCaseArticle.KnowledgeArticleId);

    //KnowledgeArticleVersion aKnowledgeArticleVersion = [SELECT SourceId, CreatedById, KnowledgeArticleId FROM KnowledgeArticleVersion WHERE PublishStatus = 'online' AND Language = 'en_US' AND KnowledgeArticleId =: aCaseArticle.KnowledgeArticleId];
    //System.assertNotEquals(null, aKnowledgeArticleVersion);
    //System.assertEquals(aCaseArticle.KnowledgeArticleId, aKnowledgeArticleVersion.KnowledgeArticleId);

    aCase = [SELECT Citation__c, Known_Vs_New__c, Has_Article_Linked__c FROM case WHERE id=:aCase.Id];
    System.assertEquals(false, aCase.Citation__c);
    System.assertEquals(false, aCase.Has_Article_Linked__c);

    aCase.Subject = 'This is case subject';
    update aCase;

    aCase = [SELECT Citation__c, Known_Vs_New__c, Has_Article_Linked__c FROM case WHERE id=:aCase.Id];
    //System.assertEquals(true, aCase.Citation__c);
    //System.assertEquals(true, aCase.Has_Article_Linked__c);

    article = [SELECT Chat_Answer__c from Knowledge__kav WHERE id=:article.id];
    System.debug('+++article='+article);
    System.assertNotEquals(null, article.Chat_Answer__c);
  }

  static testmethod void testMarkFoundationCases(){
    Contact aFounContact = ESDJC_TestUtil.getContact('EMEA – All Countries','FOUN-Foundation');
    Contact aContact = ESDJC_TestUtil.getContact('EMEA – All Countries');
    System.assertEquals('EMEA – All Countries', aFounContact.Division__c );
    System.assertEquals('FOUN-Foundation', aFounContact.Department );

    Case aCase = new Case();
    aCase.ContactId = aFounContact.Id;
    insert aCase;
    
    Test.startTest();
      aCase = [SELECT Contact.Department,Is_Foundation__c FROM case WHERE id=:aCase.Id];
      System.assertEquals(true, aCase.Is_Foundation__c);
      System.assertEquals('FOUN-Foundation', aCase.Contact.Department );


      aCase.ContactId = aContact.Id;
      update aCase;
      aCase = [SELECT Contact.Department,Is_Foundation__c FROM case WHERE id=:aCase.Id];
      System.assertNotEquals('FOUN-Foundation', aCase.Contact.Department );
      System.assertEquals(false, aCase.Is_Foundation__c);

    Test.stopTest();

    
  }

    static testmethod void testNotMarkFoundationCasesForDeptChg(){
    Contact aFounContact = ESDJC_TestUtil.getContact('EMEA – All Countries','FOUN-Foundation');
    System.assertEquals('EMEA – All Countries', aFounContact.Division__c );
    System.assertEquals('FOUN-Foundation', aFounContact.Department );

    Case aCase = new Case();
    aCase.ContactId = aFounContact.Id;
    insert aCase;
    
    Test.startTest();
      aCase = [SELECT Contact.Department,Is_Foundation__c,description FROM case WHERE id=:aCase.Id];
      System.assertEquals(true, aCase.Is_Foundation__c);
      System.assertEquals('FOUN-Foundation', aCase.Contact.Department );

      aFounContact.department='7410-IT';
      update aFounContact;

      acase.description= 'Some Update';
      update acase;

      aCase = [SELECT Contact.Department,Is_Foundation__c FROM case WHERE id=:aCase.Id];
      System.assertEquals(true, aCase.Is_Foundation__c,'Expecting foundation flag to not be updated.');
      System.assertNotEquals('FOUN-Foundation', aCase.Contact.Department );

    Test.stopTest();

    
  }

  static testMethod void testUpdateFullPhotoUrl() { 
    List<User> users = [SELECT ContactId,Email,EmployeeNumber,FullPhotoUrl,Id FROM User WHERE FullPhotoUrl != null AND ContactId != null AND EmployeeNumber != null];
    System.assertNotEquals(0,users.size());

    User aUser = users.get(0);

    Case aCase = new Case();
    aCase.ContactId = aUser.ContactId;
    insert aCase; 

    aCase = [SELECT FullPhotoUrl__c FROM Case WHERE id = :aCase.Id];
    System.assertEquals(aUser.FullPhotoUrl, aCase.FullPhotoUrl__c);
    System.debug('+++FullPhotoUrl__c='+aCase.FullPhotoUrl__c);
  }


  /*
   * Method which performs unit tests
   */
  static testMethod void testStatusUpdate()
  {
    List<RecordType> rtypes = [SELECT Name, Id From RecordType WHERE sObjectType='Contact' AND Name = 'Employee' AND isActive=true];
    // List<RecordType> rTypes = [SELECT Id, Name FROM RecordType];
    //System.assert(rTypes.size > 0);

    // create test account
    Account acc = new Account(Name = 'Test Account', Phone = '(312)111 2222', 
        BillingStreet = 'Test Street', BillingCity = 'Chicago', 
        BillingPostalCode = '60605', BillingState = 'IL');

    // insert account
    insert acc;

    System.assert(acc.Id != null);

    //create contact
    Contact cont = new Contact(RecordTypeId = rTypes[0].Id, LastName = 'LastName',
        FirstName = 'FirstName', AccountId = acc.Id, ES_DJC_Contact_Country__c='US',
        Division__c='Americas - USA');

    insert cont;

    System.assertEquals('Americas - USA', [select Division__c from Contact where Id = :cont.Id].Division__c);

    //create a list of cases
    List<Case> cases = new List<Case>();
    Case cse = null;
    for (integer i = 0; i < 20; i++)
    {
      cse = new Case(Account = acc, ContactId = cont.Id, Subject = 'Test Subject ' + i, 
          Description = 'Description ' + i, Tier__c = 'Tier 1', Type='Benefits');
      cases.add(cse);
    }

    insert cases;

    //refresh cases
    cases = [SELECT Id, Tier__c, Division_Lookup__c, Type, In_Reference_To__c FROM Case WHERE Tier__c = 'Tier 1' AND Id IN :cases];

    //update cases to tier 2
    for (integer i = 0; i < cases.size(); i++)
    {
      System.assert(cases[i].In_Reference_To__c == null);
      System.assertEquals('Tier 1', cases[i].Tier__c);
      System.assertEquals('Americas - USA', cases[i].Division_Lookup__c);
      System.assertEquals('Benefits', cases[i].Type);
      cases[i].Tier__c = 'Tier 2';
    }

    update cases;

    //refresh cases and verify escalation user set.
    cases = [SELECT Id, Tier__c, ES_DJC_Case_Escalated_By__c FROM Case WHERE Tier__c = 'Tier 2' AND Subject LIKE 'Test Subject%'];
    for (Case c: cases)
    {
      System.assert(c.ES_DJC_Case_Escalated_By__c != null);
    }

  }

  //test the entitllement processes 


  static testMethod void testUpdatecaseEntitlements() { 
    Test.startTest(); 
    Contact aContact = ESDJC_TestUtil.getContact();
    Contact exec_Contact = aContact.clone();
    exec_Contact.ES_DJC_Executive_Assistant_Flag__c=true;
    insert exec_Contact;
    Contact l1_l2_Contact = aContact.clone();
    l1_l2_Contact.ES_DJC_Is_L1_L2__c=true;
    insert l1_l2_Contact; 

    List<Case> new_Cases = new List<Case>();
    for(Integer i=0;i<200;i++){
      Case aCase = new Case();
      aCase.subject='Testing Entitlement'+i;
      if(i<10 && i>=0){
        aCase.ContactId= (aContact!=null)?aContact.Id:null;
        aCase.origin='Phone';

      }

      if(i>=10 && i<30){
        aCase.ContactId= (aContact!=null)?aContact.Id:null;
        aCase.origin='Chatter Answers';
        aCase.ES_DJC_Sub_Topic__c='Termination Future Date';
        aCase.Type='Separations';
      }

      if(i>=31 && i<50){
        aCase.ContactId= (exec_Contact!=null)?exec_Contact.Id:null;
        aCase.origin='Chatter Answers';

      }

      if(i>=50 && i<120){
        aCase.ContactId= (l1_l2_Contact!=null)?l1_l2_Contact.Id:null;
        aCase.origin='Chatter Answers';
      }

      if(i>=120 && i<180){
        aCase.contactId= (l1_l2_Contact!=null)?l1_l2_Contact.Id:null;
        aCase.Type='Payroll';
      }

      if(i>=180 && i<200){
        aCase.origin='Email - Tuition Reimbursement';
        aCase.contactId=(aContact!=null)?aContact.Id:null;
      }
      new_Cases.add(aCase);
    }

    insert new_Cases;
    System.assertequals(new_Cases.size(),200);
    List<Case> update_Cases = new List<Case>();
    for(Integer i=0;i<new_Cases.size();i++){
      if(new_Cases[i].Type==null){

        new_Cases[i].Type='Benefits';
        update_Cases.add(new_cases[i]);
      }  

    }

    update update_Cases;
    Test.stoptest();


  }

  static testMethod void testFindContact() {  
    Test.startTest(); 
    String email = 'dummy_user@djc.com';
    ESDJC_TestUtil.createCandidateContact(email);
    List<Case> new_Cases = new List<Case>();
    for(Integer i=0;i<200;i++){
      Case aCase = new Case();
      aCase.subject='Testing'+i;

      if(i>=0 && i<100){
        aCase.origin='Email - Tuition Reimbursement';
        aCase.suppliedEmail=email;
        aCase.contactId=null;

      }
      if(i>=100){
        aCase.origin='Employee Success - Web';
        aCase.suppliedEmail=email;
        aCase.contactId=null;
      }
      new_Cases.add(aCase);
    }

    insert new_Cases;
    System.assertequals(new_Cases.size(),200);

    Test.stoptest();
  }
    
     static testMethod void testAllowCandidatesForEmailToCase() {  
        Contact candidate = ESDJC_TestUtil.insertCandidateRecord('Testfn','ln','testingCandidate@gmail.com');
        Map<String,String> nameValuePair = new Map<String, String>();
        nameValuePair.put('Origin','Email - Web');
        nameValuePair.put('type','new Hire');               
        nameValuePair.put('ContactId', candidate.id); 
        nameValuePair.put('SuppliedEmail','testingCandidate@gmail.com');     
        Case candidateCase = createCase(nameValuePair);         
        nameValuePair.put('Origin','Concierge');
        case candidateCase2 = createCase(nameValuePair); 
        System.assertEquals(candidate.id, candidateCase.ContactId);         
        System.assertEquals(null, candidateCase2.ContactId);         
     }
    
        private static case createCase(Map<String,String> nameValPair){
        Case c = new Case();
        if ((nameValPair!=null)&&(nameValPair.size()>0)){
            for (String key: nameValPair.keySet()){
                String value= nameValPair.get(key);
                c.put(key, value);
            }
            insert c;
            Case newCase = [select owner.name, origin, contactId,recordtype.Name, priority,ES_DJC_Case_Re_open_Date__c,type, Tier__c from case where id = :c.id];
            return newCase;                 
        }
        return null;        
    }

  static testMethod void testPopulateMgmntHierarchy() {   

    Test.startTest();
    Id empRecordtypeId = ESDJC_Util.getEmployeeRecordTypeId();
    List<Contact> mgrsList = new List<Contact>();
    List<Contact> massContactList = new List<Contact>(); 
    Map<String,Id> LastNametoContactMap = new Map<String,Id>();
    List<Case> massCaseList = new List<Case>();

    Account acc = new Account(Name = 'Test Account', Phone = '(312)111 2222', 
        BillingStreet = 'Test Street', BillingCity = 'Chicago', 
        BillingPostalCode = '60605', BillingState = 'IL');

    // insert account
    insert acc;

    System.assert(acc.Id != null);

    //create few managers contact records  
    for(Integer i=0;i<10;i++){
      Contact aContact = new Contact(LastName='Manager'+i,recordtypeId=empRecordtypeId,EmployeeNumber__c='empNo'+i);
      mgrsList.add(aContact);
    }
    try{
      insert mgrsList;
    }
    catch(Exception e){}

    //mass insert contacts  with MH3-6 fields.  

    for(Integer i=0;i<500;i++){
      String mh3,mh4,mh5,mh6;

      if(i<50){
        mh3='empNo0'; mh4='empNo1';mh5='empNo2';mh6='empNo3';
      }
      else if(i>=50)
      {
        mh3='empNo4'; mh4='empNo5';mh5='empNo6';mh6='empNo7';
      }
      Contact aContact = new Contact(LastName='Testing'+i,recordtypeId=empRecordtypeId,ESDJC_Employee_Id_MH3__c=mh3,ESDJC_Employee_Id_MH4__c=mh4,ESDJC_Employee_Id_MH5__c=mh5,ESDJC_Employee_Id_MH6__c=mh6 ); 
      massContactList.add(aContact);
    }
    try{
      insert massContactList;
      for(Contact c : massContactList){
        LastNametoContactMap.put(c.LastName,c.Id);
      }

    }
    catch(Exception e){

    }

    // mass insert cases with few inreference to field in and few without. 

    for(Integer i=0;i<300;i++){
      //contacts without reference to field 
      if(i<50){

        Case acase = new Case(contactId=LastNametoContactMap.get('Testing'+i),accountId=acc.Id ); 
        massCaseList.add(acase);
      }
      //contacts with reference to field 
      else{
        Case aCase = new Case(contactId=LastNametoContactMap.get('Testing'+i),In_Reference_To__c=LastNametoContactMap.get('Testing'+(i+1)),accountId=acc.Id ); 
        massCaseList.add(aCase);
      }
    }

    try{
      insert massCaseList;
    }
    catch(Exception e){}

    Test.stopTest();
  }

  static testMethod void testCheckConsoleValidationsWaitingForResponse() {

    User sysAdm = ESDJC_TestUtil.getSysAdminUser();

    User portalUser = null;
    System.runAs(sysAdm) {

      portalUser = ESDJC_TestUtil.getPortalUser('US', 'Americas - USA');

      String caseId = null;

      Test.startTest();
      //Create a case
      System.runAs(portalUser) {
        Case c = new Case(ContactId=portalUser.ContactId, Subject='Test Private Question', Type='Benefits', Description='Test Description', Status='New', Origin='Chatter Answers');
        insert c;
        caseId = c.Id;
      }

      System.assert(caseId != null);

      Case c = [select Id, RecordType.Name, Status from Case where Id=:caseId];
      System.assertEquals('All Case Types except ER - AMER', c.RecordType.Name);

      String errMessage = null;

      //Update case status to 'Waiting for Response'
      try {
        c.Status = 'Waiting for Response';
        update c;
      } catch(System.DMLException e) {
        errMessage = e.getMessage();
      }

      //Since the case's required fields are blank, an error is thrown
      System.assert(errMessage != null);
      System.assert(errMessage.contains('You must complete all required fields before changing the case\'s status to Waiting for Response'));
      System.assertEquals('New', [select Status from Case where Id=:caseId].Status);

      errMessage = null;

      //Update the required fields along with status and save
      c.ES_DJC_Topic__c = '401K';
      c.ES_DJC_Sub_Topic__c = 'Change Amount';
      c.Status = 'Waiting for Response';

      try {
        update c;
      } catch(System.DMLException e) {
        errMessage = e.getMessage();
      }

      //No error is thrown this time
      System.assert(errMessage == null);

      //Verify the status of the case
      System.assertEquals('Waiting for Response', [select Status from Case where Id=:caseId].Status);
      Test.stopTest();
    }
  }

  static testMethod void testCaseCommentNotification() {

    Test.startTest();
    User sysAdm = ESDJC_TestUtil.getSysAdminUser();

    User portalUser = null;
    System.runAs(sysAdm) {
 
      portalUser = ESDJC_TestUtil.getPortalUser('US', 'Americas - USA');

      String caseId = null;


      //Create a case
      System.runAs(portalUser) {
        Case c = new Case(ContactId=portalUser.ContactId, Subject='Test Private Question', Type='Benefits', Description='Test Description', Status='New', Origin='Chatter Answers');
        insert c;
        caseId = c.Id;
      }

      System.assert(caseId != null);

      Case c = [select Id, RecordType.Name, Status from Case where Id=:caseId];
      System.assertEquals('All Case Types except ER - AMER', c.RecordType.Name);

      //Assert if there are no email messages
      System.assertEquals(0, [select Id from EmailMessage where ParentId = :caseId].size());

      //Create a new public case comment
      CaseComment cc = new CaseComment(ParentId=caseId, CommentBody='Test Public Comments', IsPublished=true);
      insert cc;

      System.assert(cc.id!=null);

      System.assertEquals(1, Limits.getEmailInvocations());

      //Create a new private case comment
      CaseComment cc1 = new CaseComment(ParentId=caseId, CommentBody='Test Private Comments', IsPublished=false);
      insert cc1;

      System.assert(cc1.id!=null);

      //No emails should have gone for private comment
      System.assertEquals(1, Limits.getEmailInvocations());

      Test.stopTest();
    }
  }

  static testMethod void testNoNotificationForCommentByConciergeUser() {
    User sysAdm = ESDJC_TestUtil.getSysAdminUser();

    User portalUser = null;
    User conciergeUser = null;

    System.runAs(sysAdm) {
      portalUser = ESDJC_TestUtil.getPortalUser('US', 'Americas - USA');
      conciergeUser = ESDJC_TestUtil.getConciergeUser('US', 'Americas - USA');

      String caseId = null;


      //Create a case
      System.runAs(conciergeUser) {
        Case c = new Case(ContactId=portalUser.ContactId, Subject='Test Private Question', Type='Benefits', Description='Test Description', Status='New', Origin='Chatter Answers');
        insert c;
        caseId = c.Id;
      }

      System.assert(caseId != null);

      System.runAs(conciergeUser) {
        CaseComment cc1 = new CaseComment(ParentId=caseId, CommentBody='Test Comments from Concierge', IsPublished=true);
        insert cc1;

        System.assertEquals(0, Limits.getEmailInvocations());
      }
    }
  }



  /*Below test method should check for following conditions : 
    1) If EMEA user creates mail services case, then it should route to EMEA queue
    2) else, it should route to Mail services HQ queue.. 
   */
       static testMethod void testSetPackageOwnerAssignmentHQ(){
        User hqUser = [select division from User where id=:userinfo.getUserId()];
        hqUser.division = 'Americas - USA';
        update hqUser;
        //create contact 
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Contact con = new Contact( AccountID = acc.id, FirstName = 'Test', LastName = 'User',ES_DJC_Contact_Country__c = 'US', ES_DJC_Work_Location__c='San Francisco', Division__c = 'Americas - USA',
                                  email = 'test-user@fakemail.com',RecordTypeId=[select id,name from RecordType where sObjectType='Contact' and Name='Employee'].Id );
        insert con;
        
        Id packageManagementId = [select id from recordtype where sObjectType='Case' and Developername='REWS_Package_Management' limit 1].Id;
        
        
        //run as emea user 
        System.runAs(hqUser){
            //create mail service case.. 
            Case packageCase = new Case(Origin='Package Delivery',contactId = con.Id,Type='Mail services',ES_DJC_Topic__c='Package Delivery',RecordTypeId = packageManagementId);
            Test.startTest();
            insert packageCase;
            Test.stopTest();
            System.debug('Mail services queue Id: ' + REWS_Setting__c.getInstance().Mail_services_queue_Id__c);
            System.assertEquals(REWS_Setting__c.getInstance().Mail_services_queue_Id__c,[select ownerId from case where Id=:packageCase.Id].ownerId);
        }
        
        
    }
    
    static testMethod void testSetPackageOwnerAssignmentEMEA(){
        User emeaUser = [select division from User where id=:userinfo.getUserId()];
        emeaUser.division = 'EMEA - All Countries';
        update emeaUser;
        
        //create contact 
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Contact con = new Contact( AccountID = acc.id, FirstName = 'Test', LastName = 'User',ES_DJC_Contact_Country__c = 'Ireland', ES_DJC_Work_Location__c='Dublin', Division__c = 'EMEA - All Countries',
                                  email = 'test-user@fakemail.com',RecordTypeId=[select id,name from RecordType where sObjectType='Contact' and Name='Employee'].Id );
        insert con;
        
        Id packageManagementId = [select id from recordtype where sObjectType='Case' and Developername='REWS_Package_Management' limit 1].Id;
        
        
        //run as emea user 
        System.runAs(emeaUser){
            //create mail service case.. 
            Case packageCase = new Case(Origin='Package Delivery',contactId= con.Id,Type='Mail services',ES_DJC_Topic__c='Package Delivery',RecordTypeId=packageManagementId);
            Test.startTest();
            insert packageCase;
            Test.stopTest();
            System.assertEquals(REWS_Setting__c.getInstance().EMEA_Mail_Services_Queue_Id__c,[select ownerId from case where Id=:packageCase.Id].ownerId);
        }
        
    }
    
    static testMethod void testSetOwnerSupportGroup(){
        //get random roleId from supportgroup custom settings... 
        
        List<ESDJC_Owner_Support_Group__c> G_settings = [select Id,RoleId__c,Support_Group__c from ESDJC_Owner_Support_Group__c where roleId__c!=null limit 1]; 
        Map<Id,String> settingMap = new Map<Id,String>();
        //get current user role..
        User currentUser = [select Id,userRoleId from User where id=:userinfo.getUserId()];
        if(!G_settings.isEmpty()){
            currentUser.userRoleId = G_settings[0].RoleId__c;
            update currentUser; 
        }
        for(ESDJC_Owner_Support_Group__c groupSetting : ESDJC_Owner_Support_Group__c.getAll().Values()){
            if(groupSetting.QueueId__c!=null){
                settingMap.put(groupSetting.QueueId__c,groupSetting.Support_Group__c);
            }
        }
        Case ca;
        System.runAs(currentUser){
            //create a case with owner as logged in user.. 
            Account acc = new Account(Name = 'Test Account');
            insert acc;
            Contact con = new Contact( AccountID = acc.id, FirstName = 'Test', LastName = 'User',ES_DJC_Contact_Country__c = 'US', 
                                      email = 'test-user@fakemail.com',RecordTypeId=[select id,name from RecordType where sObjectType='Contact' and Name='Employee'].Id );
            insert con;
            ca = new Case(Origin='Employee Success - Web',contactId=con.Id,ownerId=currentUser.Id,Subject='Test support group assignment');
            Test.startTest();
            insert ca; 
            Test.stopTest(); 
        }
        
        Case testSupportGroupCase = [select Id,ownerId,Owner_Support_Group__c from case where id = : ca.Id];
        if(String.valueOf(testSupportGroupCase.ownerId).startsWith('005')){//role
            System.assertEquals(testSupportGroupCase.Owner_Support_Group__c,G_settings[0].Support_Group__c);
        } else {//queue
            System.assertEquals(testSupportGroupCase.Owner_Support_Group__c,settingMap.get(testSupportGroupCase.ownerId));
               
        }
    }

    static testMethod void testVerifySubtopicSizeWithMultipleSelections(){

        Contact aContact = ESDJC_TestUtil.getContact();
        Case aCase = new Case();
        aCase.ContactId = aContact.Id;

        aCase.Type = 'Compensation';
        aCase.ES_DJC_Topic__c = 'Base';
        aCase.ES_DJC_Sub_Topic__c = 'Merit;Other';
        
        Test.startTest();
        
        Boolean error = false;

        try{
          insert aCase;
        }catch(Exception ex){
          error = true;
          System.assert(ex.getMessage().contains(Label.ESDJC_Subtopic_only_one_option_error));
        }

        System.assert(error);
    }
    
    static testMethod void testVerifySubtopicSizeWithOneSelection(){

        Contact aContact = ESDJC_TestUtil.getContact();
        Case aCase = new Case();
        aCase.ContactId = aContact.Id;

        aCase.Type = 'Compensation';
        aCase.ES_DJC_Topic__c = 'Base';
        aCase.ES_DJC_Sub_Topic__c = 'Merit';

        Database.SaveResult result = Database.insert(aCase);
        
        System.assert(result.isSuccess());
    }
    static testMethod void testVerifySubtopicSizeWithRecordType(){

        Contact aContact = ESDJC_TestUtil.getContact();
         Schema.DescribeSObjectResult caseSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo
                   = caseSchema.getRecordTypeInfosByName(); 
         Id rtId = CaseRecordTypeInfo.get('Employee Relations Case Type - APAC').getRecordTypeId();
        Case aCase = new Case();
        aCase.ContactId = aContact.Id;
        aCase.Type = 'Employee Relations';
        aCase.ES_DJC_Topic__c = 'Employee Relations';
        aCase.Recordtypeid =rtId;
        aCase.ES_DJC_Sub_Topic__c = 'Coaching;Position Elimination';

        Database.SaveResult result = Database.insert(aCase);
        
        System.assert(result.isSuccess());
    }
    static testMethod void testVerifySubtopicSizeOnExistingCase(){

        Case caseTest = new Case(Id = ESDJC_TestUtil.getFakeId(Case.SObjectType), Type = 'Compensation', ES_DJC_Topic__c = 'Base', ES_DJC_Sub_Topic__c = 'Merit;Other');        
        List<Case> newCases = new List<Case>{caseTest};
        Map<Id,Case> oldCases = new Map<Id,Case>();
        oldCases.put(caseTest.Id, caseTest);

        ESDJC_CaseHandler.verifySubtopicSize(newCases, oldCases);

        System.assert(!ApexPages.hasMessages());
    }
    static testMethod void testCaseMileStone()
    {
    Schema.DescribeSObjectResult cSchema = Schema.SObjectType.Case; 
    Map<String,Schema.RecordTypeInfo> caseRecordType = cSchema.getRecordTypeInfosByName();
    Id rtId = caseRecordType.get('All REWS Package Management').getRecordTypeId();
    Contact aContact = ESDJC_TestUtil.getContact();
    List<Case> caseList = new List<Case>();
    Case aCase = new Case();
    aCase.ContactId = aContact.Id;
    aCase.Type ='Mail Services';
    aCase.Origin ='Package Delivery';
    aCase.Recordtypeid = rtid;
    
    caseList.add(aCase);
    insert caseList;   
    
    List<CaseMilestone> mileStones = [SELECT ID, CaseId 
            FROM CaseMilestone WHERE CaseId=:aCase.id];
            
    System.assertEquals(0,mileStones.size());
    }
}