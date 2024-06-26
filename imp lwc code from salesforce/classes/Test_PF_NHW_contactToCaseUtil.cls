@isTest
public class Test_PF_NHW_contactToCaseUtil {
    @testSetup
    static void createData() {
        
        NH_Settings__c nhs = new NH_Settings__c(NoOfDaysBeforeStartDateToSendRemindEmail__c = 15,Valid_AD_Email_Domains__c='@salesforce.com');
        insert nhs;
        
        Onboarding_Setting__c obs = new Onboarding_Setting__c(Candidate_Record_Type__c = NHW_Util.getcandidateContactRecordTypeId());
        insert obs;
        
        TF2_Department__c cc = new TF2_Department__c(Department_Number__c='7419',Name='IT Apps');
        Business_Unit__c BU = new Business_Unit__c(BU_Code__c='2301',Name = 'Shared Services');
        TF2_Company__c Comp = new TF2_Company__c(Company_Code__c='100',Name='100-United States of America');
        TF2_PCC__c pcc = new TF2_PCC__c(name = '100-United States of America' );
        TF2_Business_Site__c buSite = new TF2_Business_Site__c(name='Remote -California - San Francisco',City__c = 'California',
                                                               Country__c='Unites States',Street_Address__c='350 Mission St',State_Province__c = 'San Francisco',
                                                               Type__c='City');
        WDR_Candidate__c candidate = new WDR_Candidate__c();
        candidate.First_Name__c = 'Test F';
        candidate.Last_Name__c = 'Test L';
        candidate.Name = 'Test F'+'Test L';
        candidate.Email__c = 'Test_F_L@salesforce.com';
        candidate.Mailing_City__c = buSite.State_Province__c;
        candidate.Mailing_Country__c = 'United States of America';
        candidate.Mailing_Postal_Code__c = '94002';
        candidate.Mailing_State__c = 'CA';
        candidate.Mailing_Street__c = buSite.Street_Address__c;
        
        insert candidate;
        insert BU;
        insert Comp;
        insert pcc;
        insert cc;
        insert buSite;
        
        Contact con = new Contact();
        con.FirstName = candidate.First_Name__c;
        con.LastName = candidate.Last_Name__c;
        con.Email = candidate.Email__c;
        con.NHW_Candidate__c = candidate.Id;
        con.RecordTypeId = NHW_Util.getcandidateContactRecordTypeId();
        insert con;
        
        Contact HiringMgerContact = new Contact();
        HiringMgerContact.FirstName = UserInfo.getFirstName();
        HiringMgerContact.LastName = UserInfo.getLastName();
        HiringMgerContact.Email = UserInfo.getUserEmail();
        insert HiringMgerContact; 
        
        Case cse = new Case();
        cse.Offer_Type__c = 'External (normal) hire';
        cse.Resource_Type__c = 'Perm/FTE';
        cse.First_Name__c = 'Test';
        cse.Last_Name__c = 'New Hire 1';
        cse.Company__c = Comp.id;
        cse.Primary_Coverage_Country__c = pcc.Id;
        cse.Business_Title__c = 'AMTS';
        cse.Business_Unit_NHW__c = '2301-Shared Services';
        cse.Cost_Center_NHW__c =  '7419-IT Apps';
        cse.NHW_Business_Unit__c = BU.id;
        cse.NHW_Cost_Center__c =  cc.id;
        cse.NHW_Start_Date__c = Date.today().addDays(16);
        cse.NH_Personal_Email__c = 'test123@email.com';  
        cse.NH_Business_Site__c = buSite.id;
        cse.Office_Address__c = buSite.Street_Address__c;
        cse.Office_City__c = buSite.State_Province__c;
        cse.Office_State_Province__c = buSite.State_Province__c;
        cse.Office_Zip_Postal_Code__c = '94002';
        cse.contactId = HiringMgerContact.id;
        cse.Office_Country__c = 'United States';
        cse.Manager_s_Email__c = UserInfo.getUserEmail();
        cse.Email_Address__c = 'test@email.com';
        cse.NHW_Employee_Type__c = 'regular employee';
        cse.Division__c = 'AMER';
        cse.RecordTypeId = NHW_Util.getnhwCaseRecordTypeId();
        cse.NHW_Send_Reminder__c = false;
        cse.origin = 'NHW';
        cse.status = 'New';
        cse.NHW_Employee__c = con.id;
        cse.NHW_Start_Date__c = Date.today().addDays(10);
        insert cse;
        
    }
    
    //validate correct Change flows to case when Business Unit is updated on WDR contact
    @istest
    static void validateBusinessUnitChange() {
        WDR_Candidate__c cand = [select id from WDR_Candidate__c];
        Contact con = [select WD_Business_Unit__c from Contact where NHW_Candidate__c =: cand.id];
        Case cse = [select NHW_Business_Unit__c, Business_Unit_NHW__c from case where NHW_Employee__c =: con.id];
        Test.startTest();
        Business_Unit__c BU = new Business_Unit__c(BU_Code__c='1111',Name = 'Test BU');
        insert BU;
        con.WD_Business_Unit__c = BU.id;
        update con;
        Test.stopTest();
        Case newcse = [select NHW_Business_Unit__c, Business_Unit_NHW__c from case where NHW_Employee__c =: con.id];
        System.assertNotEquals(cse.NHW_Business_Unit__c,newcse.NHW_Business_Unit__c);
        System.assertEquals(BU.Name,newcse.Business_Unit_NHW__c);
    }
    
    //validate correct No Change flows to case when Business Unit is update to Null on WDR contact
    @istest
    static void validateBusinessUnitChangeToNull() {
        WDR_Candidate__c cand = [select id from WDR_Candidate__c];
        Contact con = [select WD_Business_Unit__c from Contact where NHW_Candidate__c =: cand.id];
        Case cse = [select NHW_Business_Unit__c, Business_Unit_NHW__c from case where NHW_Employee__c =: con.id];
        Test.startTest();
        con.WD_Business_Unit__c = null;
        Test.stopTest();
        Case newcse = [select NHW_Business_Unit__c, Business_Unit_NHW__c from case where NHW_Employee__c =: con.id];
        System.assertEquals(cse.NHW_Business_Unit__c,newcse.NHW_Business_Unit__c);
        System.assertEquals(cse.Business_Unit_NHW__c,newcse.Business_Unit_NHW__c);
    }
    
    //validate correct Change flows to case when Business Site is updated on WDR contact
    @istest
    static void validateBusinessSiteChange() {
        WDR_Candidate__c cand = [select id from WDR_Candidate__c];
        Contact con = [select Business_Site__c from Contact where NHW_Candidate__c =: cand.id];
        Case cse = [select Office_City__c, NH_Business_Site__c from case where NHW_Employee__c =: con.id];
        Test.startTest();
        TF2_Business_Site__c buSite = new TF2_Business_Site__c(name='Test buSite',City__c = 'New York',
                                                               Country__c='Unites States',Street_Address__c='350 Mission St',State_Province__c = 'San Francisco',
                                                               Type__c='City');
        insert buSite;
        con.Business_Site__c = buSite.id;
        update con;
        Test.stopTest();
        Case newcse = [select Office_City__c, NH_Business_Site__c from case where NHW_Employee__c =: con.id];
        System.assertNotEquals(cse.NH_Business_Site__c,newcse.NH_Business_Site__c);
        System.assertEquals(buSite.City__c,newcse.Office_City__c);
    }
    
    //validate No Change flows to case when Business Site is updated to null on WDR contact
    @istest
    static void validateBusinessSiteChangeToNull() {
        WDR_Candidate__c cand = [select id from WDR_Candidate__c];
        Contact con = [select Business_Site__c from Contact where NHW_Candidate__c =: cand.id];
        Case cse = [select Office_City__c, NH_Business_Site__c from case where NHW_Employee__c =: con.id];
        Test.startTest();
        con.Business_Site__c = null;
        update con;
        Test.stopTest();
        Case newcse = [select Office_City__c, NH_Business_Site__c from case where NHW_Employee__c =: con.id];
        System.assertEquals(cse.NH_Business_Site__c,newcse.NH_Business_Site__c);
        System.assertEquals(cse.Office_City__c,newcse.Office_City__c);
    }
    
    //validate correct Change flows to case when Cost Center is updated on WDR contact
    @istest
    static void validateCostCenterChange() {
        WDR_Candidate__c cand = [select id from WDR_Candidate__c];
        Contact con = [select WD_Department__c from Contact where NHW_Candidate__c =: cand.id];
        Case cse = [select NHW_Cost_Center__c, Cost_Center_NHW__c from case where NHW_Employee__c =: con.id];
        Test.startTest();
        TF2_Department__c cc = new TF2_Department__c(Department_Number__c='1112',Name='IT Apps Test',Active__c=True);
        insert cc;
        con.WD_Department__c = cc.id;
        update con;
        Test.stopTest();
        Case newcse = [select NHW_Cost_Center__c, Cost_Center_NHW__c from case where NHW_Employee__c =: con.id];
        System.assertNotEquals(cse.NHW_Cost_Center__c,newcse.NHW_Cost_Center__c);
        System.assertEquals(cc.Name,newcse.Cost_Center_NHW__c);
    }
    
    //validate No Change flows to case when Cost Center is updated to null on WDR contact
    @istest
    static void validateCostCenterChangeToNull() {
        WDR_Candidate__c cand = [select id from WDR_Candidate__c];
        Contact con = [select WD_Department__c from Contact where NHW_Candidate__c =: cand.id];
        Case cse = [select NHW_Cost_Center__c, Cost_Center_NHW__c from case where NHW_Employee__c =: con.id];
        Test.startTest();
        con.WD_Department__c = null;
        update con;
        Test.stopTest();
        Case newcse = [select NHW_Cost_Center__c, Cost_Center_NHW__c from case where NHW_Employee__c =: con.id];
        System.assertEquals(cse.NHW_Cost_Center__c,newcse.NHW_Cost_Center__c);
        System.assertEquals(cse.Cost_Center_NHW__c,newcse.Cost_Center_NHW__c);
    }
    
    //validate correct Change flows to case when Hiring manager is updated on WDR contact
    @istest
    static void validateHMChange() {
        WDR_Candidate__c cand = [select id from WDR_Candidate__c];
        Contact con = [select Hiring_Manager__c from Contact where NHW_Candidate__c =: cand.id];
        Case cse = [select contactId, Manager_s_Email__c from case where NHW_Employee__c =: con.id];
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', FirstName = 'Test', LastName='TestingHMChange', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testHMChange.com');
        User currUser = [select id from User where id=:userInfo.getUserId()];
        
        System.runAs(currUser) {
            insert u;  
        }
        Contact HiringMgerContact = new Contact();
        HiringMgerContact.FirstName = u.FirstName;
        HiringMgerContact.LastName = u.LastName;
        HiringMgerContact.Email = u.Email;
        insert HiringMgerContact; 
        Test.startTest();
        con.Hiring_Manager__c = u.id;
        update con;
        Test.stopTest();
        Case newcse = [select contactId, Manager_s_Email__c from case where NHW_Employee__c =: con.id];
        System.assertNotEquals(u.Email,newcse.Manager_s_Email__c);
    }
    
    //validate no Change flows to case when Hiring Manager is updated to Null on WDR contact
    @istest
    static void validateHMChangeToNull() {
        WDR_Candidate__c cand = [select id from WDR_Candidate__c];
        Contact con = [select Hiring_Manager__c from Contact where NHW_Candidate__c =: cand.id];
        Case cse = [select contactId, Manager_Name__c from case where NHW_Employee__c =: con.id];
        Test.startTest();
        con.Hiring_Manager__c = null;
        update con;
        Test.stopTest();
        Case newcse = [select contactId, Manager_Name__c from case where NHW_Employee__c =: con.id];
        System.assertEquals(cse.contactId,newcse.contactId);
        System.assertEquals(cse.Manager_Name__c,newcse.Manager_Name__c);
    }
    
    //validate correct Change flows to case when Start Date is updated on WDR contact
    @istest
    static void validateSDChange() {
        WDR_Candidate__c cand = [select id from WDR_Candidate__c];
        Contact con = [select Start_Date__c from Contact where NHW_Candidate__c =: cand.id];
        Case cse = [select NHW_Start_Date__c from case where NHW_Employee__c =: con.id];
        Test.startTest();
        con.Start_Date__c = Date.today().addDays(12);
        update con;
        Test.stopTest();
        Case newcse = [select NHW_Start_Date__c from case where NHW_Employee__c =: con.id];
        System.assertNotEquals(cse.NHW_Start_Date__c,newcse.NHW_Start_Date__c);
        System.assertEquals(con.Start_Date__c,newcse.NHW_Start_Date__c);
    }
    
    //validate no Change flows to case when Start Date is updated to null on WDR contact
    @istest
    static void validateSDChangeToNull() {
        WDR_Candidate__c cand = [select id from WDR_Candidate__c];
        Contact con = [select Start_Date__c from Contact where NHW_Candidate__c =: cand.id];
        Case cse = [select NHW_Start_Date__c from case where NHW_Employee__c =: con.id];
        Test.startTest();
        con.Start_Date__c = null;
        update con;
        Test.stopTest();
        Case newcse = [select NHW_Start_Date__c from case where NHW_Employee__c =: con.id];
        System.assertEquals(cse.NHW_Start_Date__c,newcse.NHW_Start_Date__c);
    }
    
    //validate correct Change flows to case when Candidate Stage is updated on WDR contact
    @istest
    static void validateCandStageChange() {
        WDR_Candidate__c cand = [select id from WDR_Candidate__c];
        Contact con = [select Candidate_stage__c from Contact where NHW_Candidate__c =: cand.id];
        Case cse = [select Status from case where NHW_Employee__c =: con.id];
        Test.startTest();
        con.Candidate_stage__c = 'Declined by Candidate';
        update con;
        Test.stopTest();
        Case newcse = [select Status from case where NHW_Employee__c =: con.id];
        System.assertNotEquals(cse.Status,newcse.Status);
        System.assertEquals('Closed - Cancelled',newcse.Status);
    }
    
    //validate no Change flows to case when candidate stage is updated to null on WDR contact
    @istest
    static void validateCandStageChangeToNull() {
        WDR_Candidate__c cand = [select id from WDR_Candidate__c];
        Contact con = [select Candidate_stage__c from Contact where NHW_Candidate__c =: cand.id];
        Case cse = [select Status from case where NHW_Employee__c =: con.id];
        Test.startTest();
        con.Candidate_stage__c = null;
        update con;
        Test.stopTest();
        Case newcse = [select Status from case where NHW_Employee__c =: con.id];
        System.assertEquals(cse.Status,newcse.Status);
    }
    
}