@isTest
public with sharing class NHW_contactToCaseUtilTest{
    private static final String DEPARTMENT_NAME = '2301 - Shared Services';
    private static final String BU_NAME = '1001 - BT Technology';
    private static final String EMAIL_DOMAIN = '@example.com';
    private static final String MAILING_STREET = '750 Bing dr';
    private static final String DIVISION = 'Americas - USA';
    private static final String CW_BS_NAME = 'Test Site';
    private static final String PCC2 = '100 - Salesforce';
    private static final String CW_HIRE_REASON = 'Badge-Only';
    private static final String RESOURCE_TYPE = 'Deliverable: Project';
    private static final String CASE_STATUS_CLOSED_CANCELLED = 'Closed - Cancelled';

    private static final String MSG_EXPECTING_CONTACT_TO_BE_CREATED = 'Expecting Contact to be created ';
    private static final String MSG_EXPECTING_CONTACT_STATUS_TO_NOT_BE_ACTIVE = 'Expecting Contact status to NOT be active';
    private static final String MSG_EXPECTING_ONE_CASE_TO_BE_CREATED = 'Expecting One Case to be created ';
    private static final String MSG_EXPECTING_NO_CASES_TO_CREATED = 'Expecting no cases to created';
    private static final String MSG_EXPECTING_NO_CASE_TO_BE_CREATED = 'Expecting No Case to be created ';
    private static final String MSG_EXPECTING_NO_CASE_TO_BE_CREATED_AS_LOOKUPS_ARE_EMPTY = 'Expecting No Case to be created as lookups are empty';
    private static final String MSG_EXPECTING_ERROR_LOGS = 'Expecting error logs';
    private static final String MSG_BEFORE_UPDATE_CASE_SHOULD_EXIST = 'Before Update a Case should exist';
    private static final String MSG_EXPECTING_UPDATES_TO_CASCADE_TO_CASE = 'Expecting updates to cascade to Case';
    private static final String MSG_EXPECTING_ONLY_ONE_CASE_TO_BE_CREATED = 'Expecting ONLY one Case to be created';
    private static final String MSG_BEFORE_UPDATE_TO_CW_ONLY_ONE_CASE_TO_BE_CREATED = 'Before Update to CW only one Cases to be created';
    private static final String MSG_ONLY_ONE_CASE_SHOULD_EXIST = 'Only one case should exist.';
    private static final String MSG_EXPECTING_TWO_CASES_TO_BE_CREATED = 'Expecting two Cases to be created';
    private static final String MSG_EXPECTING_NEW_CASE_TO_BE_CREATED_FOR_CW = 'Expecting new Case to be created for CW';
    private static final String MSG_BEFORE_UPDATE_TO_CW_EXPECTING_ONE_CASE_TO_BE_CREATED_FOR_CW = 'Before Update to CW expecting one Case to be created for CW';
    private static final String MSG_START_DATES_FOR_CASE_SHOULD_MATCH = 'Start Dates for Case Should Match';
    private static final String MSG_EXPECTING_CASE_TO_BE_CLOSED_CANCELLED = 'Expecting Case to be Closed - Cancelled';
    private static final String THE_CASE_STATUS_SHOULD_BE_ON_HOLD = 'Expecting Case Status On Hold when contact is deactive';
    //W-15308729 code added for SD changes > 30 requirements 
     /**
     * Given: a contact gets deactivated when start date is updated beyond 30 days (to cover method :NHW_contactToCaseUtilperformUpdatesToCaseIfEmployeeContact)
     * When: an employee contact is activated or deactivated
     * Then: associated case status should be updated to 'On Hol' or back.
     */
    static testmethod void testCasestoOnHold(){
        
        TF2_Department__c dept = new TF2_Department__c(Department_Number__c = '7419', Name = 'IT Apps',Active__c=true);
        Business_Unit__c BU = new Business_Unit__c(BU_Code__c = '2301', Name = 'Shared Services');
        TF2_Company__c Comp = new TF2_Company__c(Company_Code__c = '100', Name = '100-United States of America');
        TF2_PCC__c pcc = new TF2_PCC__c(name = '100-United States of America');
        TF2_Business_Site__c buSite = new TF2_Business_Site__c(name = 'Remote -California - San Francisco',Country__c = 'Unites States', Street_Address__c = '350 Mission St',  Type__c = 'City');
        insert dept;
        insert BU;
        insert COMP;
        insert pcc;
        insert buSite;
        
        Contact conManager = new Contact();
        conManager.FirstName = 'Manager';
        conManager.LastName ='TestData';
        conManager.email= 'managerTest@example.com';
        conManager.EmployeeNumber__c ='12345';
        conManager.recordTypeId = NHW_Util.getEmployeeContactRecordTypeId();
        insert conManager;
        
        Date TenDaysInFuture = system.today()+ 10;
            
            Contact CWCon = new Contact();
            CWCon.FirstName = 'Test Contact';
            CWCon.LastName = 'data'+String.valueOf(math.random()).left(6);
            CWCon.CW_Work_Order_Status__c = 'Accepted';
            CWCon.Email = 'testOffice'+String.valueOf(math.random()).left(3)+ EMAIL_DOMAIN;
            CWCon.Secondary_Email__c = 'testPersonal'+String.valueOf(math.random()).left(3)+ EMAIL_DOMAIN;
            CWCon.CW_Hire_Reason__c = 'Standard';
            CWCon.CW_Type__c = 'SOW';
            CWCon.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contractor').getRecordTypeId();

            CWCon.Start_Date__c = TenDaysInFuture;
            CWCon.Term_Date__c = TenDaysInFuture +90;

            CWCon.Resource_Type__c = 'CW';
            CWCon.Title = 'Standard';
            CWCon.EmployeeNumber__c = '789'+ String.valueOf(math.random()).left(6);
            CWCon.CW_Reason_for_Request__c = 'TBD';
            CWCon.MailingStreet =  MAILING_STREET;
            CWCon.MailingCity = 'Fremont';
            CWCon.MailingCountry = 'California';
            CWCon.MailingPostalCode = '95051';
            CWCon.MailingState = 'CA';

            CWCon.Division__c =  DIVISION;
            CWCon.CW_Business_Site_Name__c =  CW_BS_NAME;
            CWCon.Business_Site__c = [SELECT id from TF2_Business_Site__c limit 1].Id;
            CWCon.ReportsToId = [SELECT id from Contact where FirstName = 'Manager' limit 1].Id;

            CWCon.WD_Business_Unit__c = [SELECT id from Business_Unit__c limit 1].id;
            CWCon.ES_DJC_Business_Unit__c=  BU_NAME;

            CWCon.WD_Department__c = [SELECT id FROM TF2_Department__c limit 1].Id;
            CWCon.ES_DJC_Cost_Center__c=  DEPARTMENT_NAME;

            CWCon.CW_Company__c = [SELECT id FROM TF2_Company__c limit 1].Id;
            CWCon.Primary_Country_of_Coverage_PCC__c =  PCC2;
        

        CWCon.Status__c ='Active';
        CWCon.recordTypeId=NHW_Util.getEmployeeContactRecordTypeId();
        CWCon.SF_Work_Email__c ='testemail12121@salesforce.com';
        CWCon.EmployeeNumber__c='testemail12121';
        insert CWCon;
        
        WDR_Job__c DefaultJobReq = new WDR_Job__c();
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
        insert DefaultJobReq;
        
        WDR_Candidate__c DefaultCandidate = new WDR_Candidate__c();
        DefaultCandidate.First_Name__c = 'Test F';
        DefaultCandidate.Last_Name__c = 'Test L';
        DefaultCandidate.Name = 'Test F' + 'Test L';
        DefaultCandidate.Email__c = 'Test_F_L@salesforce.com';
        DefaultCandidate.Mailing_City__c = 'San Francisco';
        DefaultCandidate.Mailing_Country__c = 'United States of America';
        DefaultCandidate.Mailing_Postal_Code__c = '94002';
        DefaultCandidate.Mailing_State__c = 'CA';
        DefaultCandidate.Mailing_Street__c = '350 mission st';
        DefaultCandidate.Candidate_Contact__c = CWCon.Id;
        DefaultCandidate.Employee_Number__c='testemail12121';
        insert DefaultCandidate;
        
        WDR_Application__c DefaultJobApplication = new WDR_Application__c();
        DefaultJobApplication.Business_Site__c = buSite.id;
        DefaultJobApplication.Offer_Type__c = 'Perm/FTE';
        DefaultJobApplication.Offer_Status__c = 'Approved';
        DefaultJobApplication.Start_Date__c = System.Today().adddays(10);
        DefaultJobApplication.Candidate_Stage__c = 'Placement';
        DefaultJobApplication.Candidate__c = DefaultCandidate.Id;
        DefaultJobApplication.Job__c = DefaultJobReq.Id;
        insert DefaultJobApplication;
                

        Case existingCase = new Case();
        existingCase.Subject = 'New Hire Provisioning Request for test user' ;
        existingCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('New_Hire_Process_Onboarding').getRecordTypeId();
        existingCase.NHW_Employee_Type__c = 'contractor';
        existingCase.NHW_Page_Number__c = 0;
        existingCase.Origin = 'NHW';
        existingCase.Type = 'NHW';
        existingCase.Description = '';
        existingCase.Job_Status__c = '';
        existingCase.NHW_Start_Date__c =TenDaysInFuture;
        existingCase.NHW_Employee_Type__c='';
        existingCase.NHW_Employee__c =CWCon.id;
        existingCase.NHW_Job_Application__c =DefaultJobApplication.id;
        existingCase.Status='New';
    
        
        insert existingCase;
        Case te= [select Id, NHW_Employee__c,
                              NHW_Start_Date__c, 
                              Status,
                              Email_Address__c, 
                              NHW_Business_Unit__c, Business_Unit_NHW__c, 
                              NHW_Cost_Center__c, Cost_Center_NHW__c,
                              NH_Business_Site__c, Office_Address__c, Office_City__c, Office_Country__c, Office_State_Province__c, Office_Zip_Postal_Code__c,
                              NHW_Job_Application__r.Candidate__c, NHW_Job_Application__r.Candidate__r.Name,
                              NHW_Job_Application__r.Candidate__r.Mailing_Street__c,
                              NHW_Job_Application__r.Candidate__r.Mailing_City__c,
                              NHW_Job_Application__r.Candidate__r.Mailing_State__c,
                              NHW_Job_Application__r.Candidate__r.Mailing_Country__c,
                              NHW_Job_Application__r.Candidate__r.Mailing_Postal_Code__c
                              ,recordtype.DeveloperName,
                              Status_before_OnHold__c,
                              NHW_Employee__r.SF_Work_Email__c,
                              NHW_Employee__r.EmployeeNumber__c,
                              NHW_Job_Application__r.Candidate__r.Employee_Number__c
                      from case where id=:existingCase.id ];
        System.debug('test class case-->'+te);
        

        Test.startTest();
        
            Contact updateCont = [SELECT Id, (Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) FROM Contact WHERE Id =: CWCon.Id];
            
            System.AssertEquals(1,updateCont.EmlpoyeeCases__r.size(),MSG_BEFORE_UPDATE_CASE_SHOULD_EXIST );
            updateCont.Status__c ='Deactive';
            NHW_ContactHandler.isexecuted = false;
            update updateCont;
            
            Case casecheck= [select Id, NHW_Employee__c,
                              NHW_Start_Date__c, 
                              Status,
                              Email_Address__c, 
                              NHW_Business_Unit__c, Business_Unit_NHW__c, 
                              NHW_Cost_Center__c, Cost_Center_NHW__c,
                              NH_Business_Site__c, Office_Address__c, Office_City__c, Office_Country__c, Office_State_Province__c, Office_Zip_Postal_Code__c,
                              NHW_Job_Application__r.Candidate__c, NHW_Job_Application__r.Candidate__r.Name,
                              NHW_Job_Application__r.Candidate__r.Mailing_Street__c,
                              NHW_Job_Application__r.Candidate__r.Mailing_City__c,
                              NHW_Job_Application__r.Candidate__r.Mailing_State__c,
                              NHW_Job_Application__r.Candidate__r.Mailing_Country__c,
                              NHW_Job_Application__r.Candidate__r.Mailing_Postal_Code__c
                              ,recordtype.DeveloperName,
                              Status_before_OnHold__c,
                              NHW_Employee__r.SF_Work_Email__c,
                              NHW_Employee__r.EmployeeNumber__c,
                              NHW_Job_Application__r.Candidate__r.Employee_Number__c
                      from case where id=:existingCase.id ];
            System.debug('test class case2-->'+casecheck);
            System.assertEquals(casecheck.Status,'New',THE_CASE_STATUS_SHOULD_BE_ON_HOLD);
            
            
            existingCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('New_Hire_Process').getRecordTypeId();
            existingCase.Status='On Hold';
            update existingCase;
            Case tes= [select Id, NHW_Employee__c,
                              NHW_Start_Date__c, 
                              Status,
                              Email_Address__c, 
                              NHW_Business_Unit__c, Business_Unit_NHW__c, 
                              NHW_Cost_Center__c, Cost_Center_NHW__c,
                              NH_Business_Site__c, Office_Address__c, Office_City__c, Office_Country__c, Office_State_Province__c, Office_Zip_Postal_Code__c,
                              NHW_Job_Application__r.Candidate__c, NHW_Job_Application__r.Candidate__r.Name,
                              NHW_Job_Application__r.Candidate__r.Mailing_Street__c,
                              NHW_Job_Application__r.Candidate__r.Mailing_City__c,
                              NHW_Job_Application__r.Candidate__r.Mailing_State__c,
                              NHW_Job_Application__r.Candidate__r.Mailing_Country__c,
                              NHW_Job_Application__r.Candidate__r.Mailing_Postal_Code__c
                              ,recordtype.DeveloperName,
                              Status_before_OnHold__c,
                              NHW_Employee__r.SF_Work_Email__c,
                              NHW_Employee__r.EmployeeNumber__c,
                              NHW_Job_Application__r.Candidate__r.Employee_Number__c
                      from case where id=:existingCase.id ];
            System.debug('test class case2-->'+tes);
            
            updateCont.Status__c ='Active';
            NHW_ContactHandler.isexecuted = false;
            update updateCont;
            
            updateCont.Status__c ='Deactive';
            NHW_ContactHandler.isexecuted = false;
            update updateCont;
            
        	existingCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('New_Hire_Process_Onboarding').getRecordTypeId();
            existingCase.Status='Accounts in Progress - Supportforce';
            update existingCase;
            
        Test.stopTest();//Async threads will end.

           Contact con = [ select Id, Status__c,Resource_Type__c,(Select id,status,Resource_Type__c from EmlpoyeeCases__r ) from Contact where Id = :CWCon.Id ];
            System.debug(con);



    }
}