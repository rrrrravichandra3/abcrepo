@isTest
public with sharing class PF_NHW_LookupProvider_Test {

    private static Contact con;
    private static User hiring_manager;
    private static Case case_test;
    private static TF2_Business_Site__c business_site;
    private static TF2_Department__c department;
    private static Business_Unit__c business_unit;
    private static TF2_Company__c company;
    private static TF2_PCC__c pcc;

    private static testMethod void testGetOptions() {
        hiring_manager = [SELECT id, contactId FROM User WHERE email = 'hiring@manager.com'];
        con = [SELECT id FROM Contact WHERE LastName = 'Smith'];
        business_site = [SELECT Id FROM  TF2_Business_Site__c WHERE Name = 'Canada - Toronto'];
        department = [SELECT Id FROM TF2_Department__c WHERE Name='TestDepartment'];
        business_unit = [SELECT id FROM Business_Unit__c WHERE BU_Code__c='5001'];
        pcc = [SELECT Id, Name FROM TF2_PCC__c WHERE Name='PCC'];
        company = [SELECT id FROM TF2_Company__c WHERE Company_Code__c='100'];

        Map<String,String> additionalContractorInformation = new Map<String,String>();
        additionalContractorInformation.put('FLOW_TYPE', 'contractor');

        Map<String,String> additionalRelocationInformation = new Map<String,String>();
        additionalRelocationInformation.put('FLOW_TYPE', 'relocation');
        additionalRelocationInformation.put('MANAGER_ID', hiring_manager.contactId);

        PF_NHW_LookupProvider pg = new PF_NHW_LookupProvider();

        List<PF_AuraLookupOption> nhw_business_list = pg.getOptions(PF_LookupId.NHW_BUSINESS_SITE, business_site.Id, null);
        List<PF_AuraLookupOption> nhw_cost_center_list = pg.getOptions(PF_LookupId.NHW_COST_CENTER, department.Id, null);
        List<PF_AuraLookupOption> nhw_hire_manager_list = pg.getOptions(PF_LookupId.NHW_HIRING_MANAGER, con.Id, null);
        List<PF_AuraLookupOption> nhw_hire_manager_job_list = pg.getOptions(PF_LookupId.NHW_HIRING_MANAGER_JOB_APP, hiring_manager.Id, null);
        List<PF_AuraLookupOption> nhw_pcc_list = pg.getOptions(PF_LookupId.NHW_PCC, pcc.Name, null);
        List<PF_AuraLookupOption> nhw_job_app_list = pg.getOptions(PF_LookupId.NHW_PCC_JOB_APP, pcc.Id, null);
        List<PF_AuraLookupOption> nhw_department_list = pg.getOptions(PF_LookupId.NHW_DEPARTMENT, department.Id, null);
        List<PF_AuraLookupOption> nhw_business_unit_list = pg.getOptions(PF_LookupId.NHW_BUSINESS_UNIT, business_unit.Id, null);
        List<PF_AuraLookupOption> nhw_company_list = pg.getOptions(PF_LookupId.NHW_COMPANY, company.Id, null);
        List<PF_AuraLookupOption> nhw_trail_guide_list = pg.getOptions(PF_LookupId.NHW_TRAIL_GUIDE, con.Id, null);
        List<PF_AuraLookupOption> nhw_org62_contractor_list = pg.getOptions(PF_LookupId.NHW_ORG62_USER_TO_CLONE, hiring_manager.Id, additionalContractorInformation);
        List<PF_AuraLookupOption> nhw_org62_list = pg.getOptions(PF_LookupId.NHW_ORG62_USER_TO_CLONE, hiring_manager.Id, additionalRelocationInformation);
        List<PF_AuraLookupOption> nhw_gus_list = pg.getOptions(PF_LookupId.NHW_GUS_USER_TO_CLONE, hiring_manager.Id, null);
        List<PF_AuraLookupOption> nhw_supportforce_list = pg.getOptions(PF_LookupId.NHW_SUPPORTFORCE_USER_TO_CLONE, hiring_manager.Id, null);
        List<PF_AuraLookupOption> nhw_generic_user_list = pg.getOptions(PF_LookupId.NHW_GENERIC_USER_TO_CLONE, hiring_manager.Id, null);
        List<PF_AuraLookupOption> nhw_empty_list = pg.getOptions(null, hiring_manager.Id, null);

        System.assertNotEquals(null, nhw_business_list);
        System.assertNotEquals(null, nhw_cost_center_list);
        System.assertNotEquals(null, nhw_hire_manager_list);
        System.assertNotEquals(null, nhw_hire_manager_job_list);
        System.assertNotEquals(null, nhw_pcc_list);
        System.assertNotEquals(null, nhw_department_list);
        System.assertNotEquals(null, nhw_business_unit_list);
        System.assertNotEquals(null, nhw_company_list);
        System.assertNotEquals(null, nhw_trail_guide_list);
        System.assertNotEquals(null, nhw_org62_contractor_list);
        System.assertNotEquals(null, nhw_org62_list);
        System.assertNotEquals(null, nhw_supportforce_list);
        System.assertNotEquals(null, nhw_generic_user_list);
        System.assertEquals(null, nhw_empty_list);
    }

    private static testMethod void testGetOption() {

        hiring_manager = [SELECT id FROM User WHERE email = 'hiring@manager.com'];
        con = [SELECT id FROM Contact WHERE LastName = 'Smith'];
        case_test = [SELECT id FROM Case WHERE Type = 'Compensation'];
        business_site = [SELECT Id FROM  TF2_Business_Site__c WHERE Name = 'Canada - Toronto'];
        department = [SELECT Id FROM TF2_Department__c WHERE Name='TestDepartment'];
        business_unit = [SELECT id FROM Business_Unit__c WHERE BU_Code__c='5001'];
        company = [SELECT id FROM TF2_Company__c WHERE Company_Code__c='100'];
        pcc = [SELECT Id, Name FROM TF2_PCC__c WHERE Name='PCC'];

        PF_NHW_LookupProvider pg = new PF_NHW_LookupProvider();
        PF_AuraLookupOption nhw_business_list = pg.getOption(PF_LookupId.NHW_BUSINESS_SITE, business_site.Id, null);
        PF_AuraLookupOption nhw_cost_center_list = pg.getOption(PF_LookupId.NHW_COST_CENTER, department.Id, null);
        PF_AuraLookupOption nhw_hire_manager_list = pg.getOption(PF_LookupId.NHW_HIRING_MANAGER, con.Id, null);
        PF_AuraLookupOption nhw_hire_manager_job_list = pg.getOption(PF_LookupId.NHW_HIRING_MANAGER_JOB_APP, hiring_manager.Id, null);
        PF_AuraLookupOption nhw_pcc_list = pg.getOption(PF_LookupId.NHW_PCC, pcc.Name, null);
        PF_AuraLookupOption nhw_job_app_list = pg.getOption(PF_LookupId.NHW_PCC_JOB_APP, pcc.Id, null);
        PF_AuraLookupOption nhw_department_list = pg.getOption(PF_LookupId.NHW_DEPARTMENT, department.Id, null);
        PF_AuraLookupOption nhw_business_unit_list = pg.getOption(PF_LookupId.NHW_BUSINESS_UNIT, business_unit.Id, null);
        PF_AuraLookupOption nhw_company_list = pg.getOption(PF_LookupId.NHW_COMPANY, company.Id, null);
        PF_AuraLookupOption nhw_trail_guide_list = pg.getOption(PF_LookupId.NHW_TRAIL_GUIDE, con.Id, null);
        PF_AuraLookupOption nhw_org62_list = pg.getOption(PF_LookupId.NHW_ORG62_USER_TO_CLONE, hiring_manager.Id, null);
        PF_AuraLookupOption nhw_gus_list = pg.getOption(PF_LookupId.NHW_GUS_USER_TO_CLONE, hiring_manager.Id, null);
        PF_AuraLookupOption nhw_supportforce_list = pg.getOption(PF_LookupId.NHW_SUPPORTFORCE_USER_TO_CLONE, hiring_manager.Id, null);
        PF_AuraLookupOption nhw_generic_user_list = pg.getOption(PF_LookupId.NHW_GENERIC_USER_TO_CLONE, hiring_manager.Id, null);
        PF_AuraLookupOption nhw_case_to_clone_list = pg.getOption(PF_LookupId.NHW_CASE_TO_CLONE, case_test.Id, null);
        PF_AuraLookupOption nhw_case_to_clone_null = pg.getOption(PF_LookupId.NHW_CASE_TO_CLONE, null, null);

        System.assertNotEquals(null, nhw_business_list);
        System.assertNotEquals(null, nhw_cost_center_list);
        System.assertNotEquals(null, nhw_hire_manager_list);
        System.assertNotEquals(null, nhw_hire_manager_job_list);
        System.assertNotEquals(null, nhw_pcc_list);
        System.assertNotEquals(null, nhw_job_app_list);
        System.assertNotEquals(null, nhw_department_list);
        System.assertNotEquals(null, nhw_business_unit_list);
        System.assertNotEquals(null, nhw_company_list);
        System.assertNotEquals(null, nhw_trail_guide_list);
        System.assertNotEquals(null, nhw_org62_list);
        System.assertNotEquals(null, nhw_gus_list);
        System.assertNotEquals(null, nhw_supportforce_list);
        System.assertNotEquals(null, nhw_generic_user_list);
        System.assertNotEquals(null, nhw_case_to_clone_list);
    }

    @testSetup static void setup() {

        business_site = new TF2_Business_Site__c();
        business_site.Name = 'Canada - Toronto';
        business_site.Business_Site_ID__c = 'Canada - Toronto';
        business_site.Country__c = 'Canada';
        business_site.Street_Address__c = 'n/a This will be updated';
        business_site.Type__c = 'TestMethod';
        business_site.City__c = 'Toronto';
        business_site.Active__c = true;
        insert business_site;

        con = new contact();
        con.FirstName = 'Roger';
        con.LastName = 'Smith';
        con.MailingState = 'FR';
        con.MailingCountry = 'Europe';
        con.MailingStreet = 'Mission';
        con.MailingCity = 'Paris';
        con.RecordTypeId = NHW_Util.getEmployeeContactRecordTypeId();
        insert con;

        Case caseTest = new Case();
        caseTest.Type = 'Compensation';
        caseTest.ES_DJC_Topic__c = 'Base';
        caseTest.ES_DJC_Sub_Topic__c = 'Merit;Other';

        insert caseTest;

        Profile p = [SELECT id FROM profile WHERE NAME = 'System Administrator'];
        hiring_manager = new User(alias = 'standt5', email = 'hiring@manager.com',
                emailencodingkey = 'UTF-8', lastname = 'Testing5', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = p.Id,
                timezonesidkey = 'America/Los_Angeles', username = 'test3hm@testorg.com', FirstName = 'John5', Title = 'Second Level manager',
                Management_Level__c = '3.1 manager');
        User currUser = [select id from User where id=:userInfo.getUserId()];

                System.runAs(currUser) {
              insert hiring_manager;
                      }


        department = new TF2_Department__c(Name='TestDepartment', Exclude_ESBP__c=true);
        insert department;

        Business_Unit__c business_unit = new Business_Unit__c(BU_Code__c='5001',Name = 'Shared Services');
        insert business_unit;

        company = new TF2_Company__c(Company_Code__c='100',Name='100-United States of America');
        insert company;

        pcc = new TF2_PCC__c(Name = 'PCC');
        insert pcc;
    }
}