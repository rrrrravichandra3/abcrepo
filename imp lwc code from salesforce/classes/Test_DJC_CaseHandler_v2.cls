/*
 * WARNING: A_testNotValidSLAOrigins() test fails if createCase() method is called
 * in other test before its executed.  So, in order for it to continue working,
 * when adding a new test, it's necessary to guarantee A_testNotValidSLAOrigins()
 * continues being executed first.  Tests are executed alphabetically.  So, any new
 * test method should be alphabetically greater than A_testNotValidSLAOrigins().
 */

@isTest(SeeAllData=false)
public class Test_DJC_CaseHandler_v2 {
    private static Contact amerContact = ESDJC_AssignmentHelper.getContacts(1, 'Americas - USA', 'San Francisco')[0];
         
    private static testmethod void testSurveyNotSentForCaseTransfer(){
        init();     
            Test.startTest();       

            Map<String,String> nameValuePair = new Map<String, String>();
            nameValuePair.put('ContactId', amerContact.id);
            nameValuePair.put('Type','GEPS');
            nameValuePair.put('ES_DJC_Sub_Topic__c','legal');
            nameValuePair.put('ES_DJC_Topic__c','Test');
            nameValuePair.put('Tier__c', 'Tier 1');
            nameValuePair.put('Origin','Concierge Desktop');
            nameValuePair.put('ESDJC_Supportforce_Case_Number__c','12345');
            nameValuePair.put('PII__c','No');
            for(Integer i=0;i<3;i++){
                Case newCase = createCase(nameValuePair);
                system.assertEquals(false, newCase.First_Response_Flag__c); 
            }
            List<Case> casesCreated = [select id,status from case];
            for(Case c: casesCreated){
                c.status = 'Closed';
            }
            update casesCreated;

            Test.stopTest();
            casesCreated= [select DJC_Is_Survey_Email_Sent__c from case order by closeddate DESC ];
            for(Case c: casesCreated){  
                system.assertEquals(false, c.DJC_Is_Survey_Email_Sent__c,'No survey should be sent for case transfer');
            }
        
    }
    private static testmethod void testSurveyNotSentForCaseInExcludeClsdStatus(){
        init();     
            Test.startTest();       
  
            Map<String,String> nameValuePair = new Map<String, String>();
            String excludeClosedStatus = 'Not a Case';
            String excludeOpenStatus = 'Getting ready';
            nameValuePair.put('ContactId', amerContact.id);
            nameValuePair.put('Type','GEPS');
            nameValuePair.put('ES_DJC_Sub_Topic__c','legal');
            nameValuePair.put('ES_DJC_Topic__c','Test');
            nameValuePair.put('Tier__c', 'Tier 1');
            nameValuePair.put('Origin','Concierge Desktop');
            nameValuePair.put('PII__c','No');
            for(Integer i=0;i<3;i++){
                Case newCase = createCase(nameValuePair);
            }
            List<Case> casesCreated = [select id,status from case];
            Integer j= 0;
            for(Case c: casesCreated){
                if(j==2){
                    c.status = 'Not a case';
                }
                j++;
            }
            update casesCreated;

            Test.stopTest();
            casesCreated= [select DJC_Is_Survey_Email_Sent__c from case order by closeddate DESC ];
            for(Case c: casesCreated){  
                system.assertEquals(false, c.DJC_Is_Survey_Email_Sent__c,'No survey should be sent as 3rd case is in exclude closed status');
            }

    }
    
        private static testmethod void testSurveySent(){
        init();     
            Test.startTest();       

            Map<String,String> nameValuePair = new Map<String, String>();
            nameValuePair.put('ContactId', amerContact.id);
            nameValuePair.put('Type','GEPS');
            nameValuePair.put('ES_DJC_Sub_Topic__c','legal');
            nameValuePair.put('ES_DJC_Topic__c','Test');
            nameValuePair.put('Tier__c', 'Tier 1');
            nameValuePair.put('Origin','Concierge Desktop');
            nameValuePair.put('PII__c','No');
            nameValuePair.put('ESDJC_Supportforce_Case_Number__c',null);
            for(Integer i=0;i<3;i++){
                Case newCase = createCase(nameValuePair);
                system.assertEquals(false, newCase.First_Response_Flag__c); 
            }
            List<Case> casesCreated = [select id,status from case];
            for(Case c: casesCreated){
                c.status = 'Closed';
            }
            update casesCreated;

            Test.stopTest();
              List<case> surveyCase = [select status,recordtype.name,DJC_Is_Survey_Email_Sent__c from case where DJC_Is_Survey_Email_Sent__c =true];
            system.assertEquals(1, surveyCase.size(),'survey should be sent for the 3rdcase');
               
    }

    private static testmethod void testSurveyCountSkipExclusion(){
         init();     
            Test.startTest();       
            List<case> casesCreated = new list<case>();

            for(Integer i=0;i<4;i++){
                Case newCase = new case();
                newCase.ContactId =amerContact.id;
                newCase.Type ='GEPS';
                newCase.ES_DJC_Sub_Topic__c ='legal';
                newCase.ES_DJC_Topic__c ='test';
                newCase.Origin ='Desktop';
                newCase.PII__c ='No';
                newCase.Tier__c ='Tier 1';
                
                casesCreated.add(newCase);
            }
            insert casesCreated;
            //Close all cases with one with exclude status
            Integer j=0;
            for(Case c: casesCreated){
                if(j==2){
                    c.status = 'Not a Case';     
                }else{
                    c.status = 'Closed';
                }
            }
            update casesCreated;

            Test.stopTest();
            List<case> surveyCase = [select status,recordtype.name,DJC_Is_Survey_Email_Sent__c from case where DJC_Is_Survey_Email_Sent__c =true];
            system.assertEquals(1, surveyCase.size(),'survey should be sent for the 4thcase');
                          
    }

    private static testmethod void testStatusClosedByEmployee(){
        init();     
        User cuser = ESDJC_TestUtil.getConciergeUser('United States','Americas - USA');
        System.runAs(cuser) { 
            Test.startTest();       
            //ES DJC Update AMER Record Type
            Map<String,String> nameValuePair = new Map<String, String>();
            nameValuePair.put('ContactId', amerContact.id);
            nameValuePair.put('Type','GEPS');
            nameValuePair.put('Tier__c', 'Tier 1');
            nameValuePair.put('Origin','Concierge Desktop');
            Case newCase = createCase(nameValuePair);
            system.assertEquals('New', newCase.status); 
            system.assertEquals(false, newCase.First_Response_Flag__c); 
            nameValuePair = new Map<String, String>();
            nameValuePair.put('status', 'Closed');
            newCase = updateCase(newCase, nameValuePair);
            Test.stopTest();
            //TODO: Uncomment the below line and remove the next line after concierge 
            //implements 'isclosed' flag to detect closed cases
            //system.assertEquals('Closed by Employee', newCase.status);        
            system.assertEquals('Closed', newCase.status);
        }
    }
    @istest
    public static void SentEmailNotificationFortheCaseCommentOfNonM_A(){
        init();
         List<RecordType> rtypes = [Select Name, Id,DeveloperName From RecordType where sObjectType='case' and isActive=true];
         Map<String,Id> caseRecordTypes = new Map<String,Id>{};
         for(RecordType rt: rtypes){
         caseRecordTypes.put(rt.DeveloperName,rt.Id);
         }
        
        Case caseForNonM_A = new Case();
        caseForNonM_A.Source__c = 'Employee';
        caseForNonM_A.ContactId = amerContact.id;
        caseFOrNonM_A.Origin = 'Email';
        caseForNonM_A.DJC_ER_Date_Reported__c = system.today()+5;
        caseForNonM_A.Status = 'New';
        caseForNonM_A.RecordTypeId = caseRecordTypes.get('Global_Ethics_Integrity');
        insert caseForNonM_A;

       List<caseComment> checkComments = new List<caseComment>();
        for(Integer i=0; i<=3 ;i++){
        caseComment caseCommentForNonM_A = new caseComment();
        caseCommentForNonM_A.ParentId = caseForNonM_A.Id;
        caseCommentForNonM_A.CommentBody = 'test';
        caseCommentForNonM_A.IsPublished = true;
        checkComments.add(caseCommentForNonM_A);
        }
        insert checkComments;
        Integer invocations = Limits.getEmailInvocations();
        system.assertEquals(1,invocations);
            
    }
    
    @istest
    public static void SentEmailNotificationFortheCaseCommentOfM_A(){
        init();
         List<RecordType> rtypes = [Select Name, Id,DeveloperName From RecordType where sObjectType='case' and isActive=true];
         Map<String,Id> caseRecordTypes = new Map<String,Id>{};
         for(RecordType rt: rtypes){
         caseRecordTypes.put(rt.DeveloperName,rt.Id);
         }
        Contact con = new Contact();
        con.Email='random1'+(Math.random()*1000).intValue()+'@salesforce.com';
        con.FirstName='TestForM_A';
        con.LastName='LastNameForM_A';
        con.ES_DJC_Record_Status__c='New - Completed';
        con.EmployeeNumber__c='98765';
        con.ES_DJC_Work_Location__c = 'San Francisco';
        con.recordTypeId = ESDJC_AssignmentHelper.getRecordTypeId('Contact','Employee');
        con.Status__c='Active';
        insert con;
        
        id recordTypeId = caseRecordTypes.get('M_A');
        system.debug('check the id'+recordTypeId);
        Case caseForM_A = new Case();
        caseForM_A.Subject = 'testingM_A';
        caseForM_A.ContactId = con.id;
        caseForM_A.Type = 'Benefits';
        caseForM_A.ES_DJC_Topic__c = 'BabyBonus';
        caseForM_A.Origin = 'Email';
        caseForM_A.Status = 'New';
        caseForM_A.RecordTypeId = recordTypeId;
        insert caseForM_A;
        system.debug('check the id'+caseForM_A.Division_Lookup__c);
        system.debug('check the id'+caseForM_A.Division__c);
        
        Test.startTest();
        caseComment caseCommentForM_A = new caseComment();
        caseCommentForM_A.ParentId = caseForM_A.Id;
        caseCommentForM_A.CommentBody = 'test23';
        caseCommentForM_A.IsPublished = true;
        insert caseCommentForM_A;
        Test.stopTest();
        Integer invocations = Limits.getEmailInvocations();
        system.assertEquals(0,invocations); 
    }

    
    private static testmethod void testSFCaseStatusClosedByEmployee(){
        init();     
        User cuser = ESDJC_TestUtil.getConciergeUser('United States','Americas - USA');
        System.runAs(cuser) { 
            Test.startTest();       
            //ES DJC Update AMER Record Type
            Map<String,String> nameValuePair = new Map<String, String>();
            nameValuePair.put('ContactId', amerContact.id);
            nameValuePair.put('Type','GEPS');
            nameValuePair.put('Tier__c', 'Tier 1');
            nameValuePair.put('Origin','Concierge Desktop');
            nameValuePair.put('ESDJC_Supportforce_Case_Id__c','123123');
            Case newCase = createCase(nameValuePair);
            system.assertEquals('New', newCase.status); 
            system.assertEquals(false, newCase.First_Response_Flag__c); 
            nameValuePair = new Map<String, String>();
            nameValuePair.put('status', 'Closed');
            newCase = updateCase(newCase, nameValuePair);
            Test.stopTest();        
            system.assertEquals('Closed', newCase.status);      
        }
    }

    public static testmethod void testUpdateCaseResponseFlag(){

        init();
        
        User cuser = ESDJC_TestUtil.getConciergeUser('United States','Americas - USA');
        
        System.runAs(cuser) { 
            Test.startTest();       
            Map<String,String> nameValuePair = new Map<String, String>();
            nameValuePair.put('ContactId', amerContact.id);
            nameValuePair.put('Type','GEPS');
            nameValuePair.put('Tier__c', 'Tier 1');
            nameValuePair.put('Origin','Concierge Desktop');

            Case newCase = createCase(nameValuePair);
            system.assertEquals('New', newCase.status); 
            system.assertEquals(false, newCase.First_Response_Flag__c);
            
            Set<Id> caseIds = new Set<Id>();
            caseIds.add(newCase.Id);

            ESDJC_CaseHandler.updateCaseResponseFlag(caseIds);
            
            Test.stopTest();
            
            newCase = [SELECT Id, First_Response_Flag__c FROM Case WHERE Id = :newCase.Id];
            System.assert(newCase.First_Response_Flag__c);
        }
    }
    
    static testMethod void A_testNotValidSLAOrigins() {

        List<String> notValidOrigins = new String[]{'Email to Case_internaltickets_PF','Face to Face', 'Phone', 'Live Agent', 'NHW', 'Package Delivery', 'Email', 'Ethics Point'};
        List<Case> cases = new List<Case>();

        init();
        
        User cuser = ESDJC_TestUtil.getConciergeUser('United States','Americas - USA');
        
        System.runAs(cuser) { 

            Test.startTest();
            
            for(String notValidOrigin : notValidOrigins){
              cases.add(new Case(Origin = notValidOrigin, type = 'Compensation', ContactId = amerContact.id));
            }

            insert cases;
            
            Test.stopTest();
        }
        
        List<Id> casesIds = new List<Id>();

        for(Case c : cases){
          casesIds.add(c.Id);
        }

        List<Case> createdCases = [SELECT Id, Valid_SLA_Origin__c, origin FROM Case WHERE Id in :casesIds];

        for(Case c : createdCases){
          System.assertEquals(false, c.Valid_SLA_Origin__c);
        }
     }

    static testMethod void testValidSLAOrigins() {

        List<String> validOrigins = new String[]{'Article Feedback','Chatter', 'Email to Case_AMER', 'Email to Case_APAC', 'Email to Case_EMEA', 'REWS - Web', 'Ergo - Web', 'Employee Success - Web'};
        List<Case> cases = new List<Case>();

        User cuser = ESDJC_TestUtil.getConciergeUser('United States','Americas - USA');
        
        System.runAs(cuser) { 
            for(String validOrigin : validOrigins){
              cases.add(new Case(Origin = validOrigin, type = 'Compensation'));
            }

            insert cases;

            List<Id> casesIds = new List<Id>();

            for(Case c : cases){
              casesIds.add(c.Id);
            }

            List<Case> createdCases = [SELECT Id, Valid_SLA_Origin__c FROM Case WHERE Id in :casesIds];

            for(Case c : createdCases){
              System.assert(c.Valid_SLA_Origin__c);
            }
        }
     }

    public static testMethod void testWarmlineCaseClosure() {
    
    init();    
    Map<String,String> nameValuePair = new Map<String, String>();
    Case caseRec;
    Warmline__c warmlineRec; 

    User cuser = ESDJC_TestUtil.getConciergeUser('United States','Americas - USA');
    
    System.runAs(cuser) { 
        Test.startTest();       
        nameValuePair.put('ContactId', amerContact.id);
        nameValuePair.put('Type','Warmline');
        caseRec = createCase(nameValuePair);
        system.assertEquals('New', caseRec.status); 
        warmlineRec = new Warmline__c(Case__c=caseRec.Id,Primary_Topic__c='Equity',Engage_Stakeholders__c='No',Disposition__c='Career Advice',Recommendations__c='Test');
        insert warmlineRec;
        Test.stopTest();

    }
             
    try {
                nameValuePair.put('status', 'Closed');
                caseRec = updateCase(caseRec, nameValuePair);
        }
    catch(Exception e) {
            System.assert(e.getMessage().contains('WARMLINE_CONNECT_DATE/TIME_REQUIRED'));
        }
        
    }
    
   /* static testMethod void testValidateEmailToCaseContacts(){
        
        init();
        
        Contact caseContact = TestDJC_Env_Unit.CreateCandidates('CandidateFN', 'ContactLN', 'validatecontacttest@emailtocasetest.com', 'AMER');
        User cuser = ESDJC_TestUtil.getConciergeUser('United States','Americas - USA');
        cuser.Id = '00570000002SpX4AAK';

        System.runAs(cuser) {
            Test.startTest();       
            Map<String,String> nameValuePair = new Map<String, String>();
            nameValuePair.put('ContactId', caseContact.id);
            nameValuePair.put('Type','GEPS');
            nameValuePair.put('Tier__c', 'Tier 1');
            nameValuePair.put('Origin','Email to Case_AMER');
            nameValuePair.put('SuppliedEmail', caseContact.Email);

            Case newCase = createCase(nameValuePair);
            
            Test.stopTest();
            
            system.assertEquals('New', newCase.status); 
            system.assert(newCase.ContactId == null);
        }
        
    }*/
    
    /* static testMethod void testValidateContacts(){

        init();

        Contact caseContact = TestDJC_Env_Unit.CreateCandidates('CandidateFN', 'ContactLN', 'validatecontacttest@heroku.com', 'AMER');
        User cuser = ESDJC_TestUtil.getConciergeUser('United States','Americas - USA');
        
        System.runAs(cuser) { 
            Test.startTest();       
            Map<String,String> nameValuePair = new Map<String, String>();
            nameValuePair.put('ContactId', caseContact.id);
            nameValuePair.put('Type','GEPS');
            nameValuePair.put('Tier__c', 'Tier 1');
            nameValuePair.put('Origin','Email to Case_AMER');
            nameValuePair.put('SuppliedEmail', caseContact.Email);

            Case newCase = createCase(nameValuePair);
            
            Test.stopTest();
            
            system.assertEquals('New', newCase.status); 
            system.assert(newCase.ContactId == null);
        }
     }
    
     static testMethod void testValidateContactsNoWhitelistDomain(){

        init();
        
        Contact caseContact = TestDJC_Env_Unit.CreateCandidates('CandidateFN', 'ContactLN', 'validatecontacttest@test.com', 'AMER');
        User cuser = ESDJC_TestUtil.getConciergeUser('United States','Americas - USA');
        
        System.runAs(cuser) { 
            Test.startTest();       
            Map<String,String> nameValuePair = new Map<String, String>();
            nameValuePair.put('ContactId', caseContact.id);
            nameValuePair.put('Type','GEPS');
            nameValuePair.put('Tier__c', 'Tier 1');
            nameValuePair.put('Origin','Email to Case_AMER');
            nameValuePair.put('SuppliedEmail', caseContact.Email);

            Case newCase = createCase(nameValuePair);
            
            Test.stopTest();
            
            system.assertEquals('New', newCase.status); 
            system.assert(newCase.ContactId == caseContact.Id);
        }
     }   */

     //W-3533591 This logic is removed from Reimbursement_Case_Totals_Claimed__c and calculated on the fly
/*
     static testMethod void testSetupReimbursementCase(){

        Test_Wellness_Util.init();

        Contact caseContact = Test_Wellness_Util.emeaContact;
        User cuser = ESDJC_TestUtil.getConciergeUser('France', 'EMEA - All Countries');

        System.runAs(cuser){

            Test.startTest();

            Map<String,Object> nameValuePair = new Map<String,Object>();
            nameValuePair.put('ContactId', caseContact.Id);
            nameValuePair.put('Type', 'Wellness Reimbursement Request');
            nameValuePair.put('Tier__c', 'Tier 1');
            nameValuePair.put('Origin', 'Employee Success - Web');
            nameValuePair.put('ES_DJC_Topic__c', 'Wellness');
            nameValuePair.put('Reimbursement_Policy_Id__c', Test_Wellness_Util.EMEA_WELLNESS_POLICY);
            nameValuePair.put('Reimbursement_Category_Id__c', Test_Wellness_Util.WELLNESS_CATEGORY);
            nameValuePair.put('Status', 'Submitted');
            nameValuePair.put('Division__c', 'EMEA - All Countries');

            Case newCase = createCase(nameValuePair);

            Test.stopTest();

            List<Reimbursement_Case_Totals_Claimed__c> totals = [SELECT Case__c, Total_Claimed__r.Status__c FROM Reimbursement_Case_Totals_Claimed__c WHERE Case__c = :newCase.Id];

            System.assertEquals(4, totals.size());

            Integer countSubmitted = 0;
            Integer countApproved = 0;

            for(Reimbursement_Case_Totals_Claimed__c total : totals){
                if(total.Total_Claimed__r.Status__c == 'Submitted'){
                    countSubmitted++;
                }else if(total.Total_Claimed__r.Status__c == 'Approved'){
                    countApproved++;
                }
            }

            System.assertEquals(2, countApproved);
            System.assertEquals(2, countSubmitted);
        }

     }

     static testMethod void testSetupReimbursementCaseAssociation(){

        Test_Wellness_Util.init();

        Contact caseContact = Test_Wellness_Util.emeaContact;
        User cuser = ESDJC_TestUtil.getConciergeUser('France', 'EMEA - All Countries');

        System.runAs(cuser){

            Test.startTest();

            Map<String,Object> nameValuePair = new Map<String,Object>();
            nameValuePair.put('ContactId', caseContact.Id);
            nameValuePair.put('Type', 'Wellness Reimbursement Request');
            nameValuePair.put('Tier__c', 'Tier 1');
            nameValuePair.put('Origin', 'Employee Success - Web');
            nameValuePair.put('ES_DJC_Topic__c', 'Wellness');
            nameValuePair.put('Reimbursement_Policy_Id__c', Test_Wellness_Util.EMEA_WELLNESS_POLICY);
            nameValuePair.put('Reimbursement_Category_Id__c', Test_Wellness_Util.WELLNESS_CATEGORY);
            nameValuePair.put('Status', 'Submitted');

            Case newCase1 = createCase(nameValuePair);

            nameValuePair = new Map<String,Object>();
            nameValuePair.put('ContactId', caseContact.Id);
            nameValuePair.put('Type', 'Wellness Reimbursement Request');
            nameValuePair.put('Tier__c', 'Tier 1');
            nameValuePair.put('Origin', 'Employee Success - Web');
            nameValuePair.put('ES_DJC_Topic__c', 'Wellness');
            nameValuePair.put('Reimbursement_Policy_Id__c', Test_Wellness_Util.EMEA_WELLNESS_POLICY);
            nameValuePair.put('Reimbursement_Category_Id__c', Test_Wellness_Util.WELLNESS_CATEGORY);
            nameValuePair.put('Status', 'Submitted');

            Case newCase2 = createCase(nameValuePair);

            Test.stopTest();

            List<DJC_Reimbursement_Total_Claimed__c> totals = [SELECT Period__c, Policy__c, Status__c FROM DJC_Reimbursement_Total_Claimed__c];

            System.assertEquals(4, totals.size());

            Integer countSubmitted = 0;
            Integer countApproved = 0;

            for(DJC_Reimbursement_Total_Claimed__c total : totals){
                if(total.Status__c == 'Submitted'){
                    countSubmitted++;
                }else if(total.Status__c == 'Approved'){
                    countApproved++;
                }
            }

            System.assertEquals(2, countApproved);
            System.assertEquals(2, countSubmitted);
        }

     }
*/
    private static case createCase(Map<String,Object> nameValPair){
        Case c = new Case();
        if ((nameValPair!=null)&&(nameValPair.size()>0)){
            for (String key: nameValPair.keySet()){
                Object value= nameValPair.get(key);
                c.put(key, value);
            }
            insert c;
            Case newCase = [select owner.name, status, recordtype.Name, priority,ES_DJC_Case_Re_open_Date__c,type, Tier__c, 
                            ES_DJC_Topic__c, ES_DJC_Sub_Topic__c, First_Response_Flag__c, contactId from case where id = :c.id];
            return newCase;                 
        }
        return null;        
    }
    
    private static case updateCase(Case c, Map<String,String> nameValPair){
        if (c==null || nameValPair == null || nameValPair.size()==0){
            return null;
        }                       
        for (String key: nameValPair.keySet()){
            String value= nameValPair.get(key);
            c.put(key, value);
        }
        update c;
        Case newCase = [select owner.name, recordtype.Name, priority,ES_DJC_Case_Re_open_Date__c, type, Tier__c, status from case where id = :c.id];
        return newCase;                                 
    }
    
    
    private static void init(){
        ESDJC_Settings__c setting = new ESDJC_Settings__c();
        setting.Run_trigger__c = true;
        setting.Site_URL__c = '/site/url';
        setting.Portal_User_Profile_Id__c = [select id from profile where name = 'Customer Portal Manager Custom'].id;
        setting.Concierge_API_User_Profile_Id__c = [select id from profile where name = 'API Internal - eApps Facade'].id;
        setting.djc_Helpdesk_API_User__c = '00570000002SpX4AAK';
        setting.Valid_SLA_Origins__c = 'Employee Success - Web,REWS - Web,Chatter Answers,Email,Concierge Desktop,Concierge Mobile,Article Feedback';
        setting.Status_list_to_exclude_for_Survey__c='Closed - Duplicate ready,Not a Case';
        setting.ES_Support_Org_Wide_Email_Id__c = [SELECT Id  FROM OrgWideEmailAddress WHERE IsAllowAllProfiles = true limit 1].id;
        setting.Survey_Email_Frequency__c=3;
        insert setting;
        REWS_Setting__c rewsSetting = new REWS_Setting__c();
        rewsSetting.Mail_services_queue_Id__c = '00Gn0000000JH8YEAW';
        rewsSetting.Case_Package_Delivery_Record_Type__c = '00Gn0000000JH8YEAW';
        insert  rewsSetting;

        List<ESDJC_Domains_Whitelist__c> whiteListDomains = new List<ESDJC_Domains_Whitelist__c>{new ESDJC_Domains_Whitelist__c(Name = 'Heroku', domain__c = 'heroku.com'), new ESDJC_Domains_Whitelist__c(Name = 'ABC', domain__c = 'abc.com')};
        insert whiteListDomains;
    }


}