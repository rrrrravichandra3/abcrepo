@isTest
public with sharing class PF_NHW_TestDataPrepAuraService_Test {

    private static testMethod void testGetDataToClone() {
        WDR_Testfactory testFactory = new WDR_Testfactory();
        testFactory.populateDefaults();
        testFactory.createJobApp();

        String app_name = [SELECT Id, Name FROM WDR_Application__c WHERE Offer_Type__c = 'Perm/FTE'].Name;
        Map<String,Object> returned_map = PF_NHW_TestDataPrepAuraService.getDataToClone(app_name);

        System.assertEquals(3, returned_map.size());
        System.assertNotEquals(null, returned_map.get('application'));
        System.assertNotEquals(null, returned_map.get('candidate'));
        System.assertNotEquals(null, returned_map.get('job'));
    }


    private static testMethod void testCreateTestData() {

        Contact hiring_manager = new Contact();
        hiring_manager.FirstName = UserInfo.getFirstName();
        hiring_manager.LastName = UserInfo.getLastName();
        hiring_manager.Email = UserInfo.getUserEmail();
        hiring_manager.recordtypeid = NHW_Util.getEmployeeContactRecordTypeId();
		insert new Account(Name=System.Label.NHW_Data_Prep_Account_Detail);
        TF2_Department__c department = new TF2_Department__c(Department_Number__c='7419',Name='IT Apps');
        Business_Unit__c business_unit = new Business_Unit__c(BU_Code__c='2301',Name = 'Shared Services');
        TF2_Company__c company = new TF2_Company__c(Company_Code__c='100',Name='100-United States of America');
        TF2_PCC__c pcc = new TF2_PCC__c(name = '100-United States of America' );
        TF2_Business_Site__c business_site = new TF2_Business_Site__c(name='Remote -California - San Francisco',
                Country__c='Unites States',Street_Address__c='350 Mission St',
                Type__c='City');
        insert department;
        insert business_unit;
        insert company;
        insert PCC;
        insert business_site;
        insert hiring_manager;

        String json_candidate = '{"candidate": {"Email__c":"test@test.com","First_Name__c":"Test F", "Last_Name__c":"Test L","Business_Site__c":"a2lc0000007xijeAAA", "Candidate_Stage__c":"Screen", "Do_Not_Send_NHW__c":"false","Internal_Candidate__c":"false", "NHW_Create_Preboarding_Case__c":"false", "Offer_Status__c":"Approved", "Offer_Type__c":"Perm/FTE", "Start_Date__c":"2018-04-16"}}';
        String json_job = '{"job": {"PCC__c":"'+PCC.id+'","Business_Unit__c":"'+business_unit.id+'","Company__c":"'+ company.id+'","Department__c":"'+department.Id +'","Hiring_Manager__c":"'+UserInfo.getUserId()+'","Region__c":"AMER","Employment_Type__c":"SFDC Employee","Job_Level__c" : "Grade 4", "Job_Title__c":"MTS", "Job_Code__c":"1235PQ"}}';
        String json_app = '{"application":{"First_Name__c":"Test F", "Last_Name__c":"Test L","Business_Site__c":"'+business_site.Id +'", "Candidate_Stage__c":"Screen", "Do_Not_Send_NHW__c":"false", "Internal_Candidate__c":"false", "NHW_Create_Preboarding_Case__c":"false", "Offer_Status__c":"Approved", "Offer_Type__c":"Perm/FTE", "Start_Date__c":"2018-04-16"}}';

        Map<String, Object> candidate_map = (Map<String, Object>) JSON.deserializeUntyped(json_candidate);
        Map<String, Object> job_map = (Map<String, Object>) JSON.deserializeUntyped(json_job);
        Map<String, Object> application_map = (Map<String, Object>) JSON.deserializeUntyped(json_app);

        System.assertNotEquals(null, PF_NHW_TestDataPrepAuraService.createTestData(candidate_map, job_map, application_map, true ));
    }
}