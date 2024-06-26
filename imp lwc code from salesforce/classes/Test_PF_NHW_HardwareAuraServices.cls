@istest
public class Test_PF_NHW_HardwareAuraServices {
    
    static final String CONTACT_CITY = 'New York';
    static final String CONTACT_LASTNAME = 'Test contact';
    static final String ASSERT_MSG = 'city populated from contact';
    static final String ASSERT_MSG2 = 'city populated from bu site';
    static final String AGENCY_TEMP = 'Agency Temp';

    @istest
    static void validateBuSiteRelatedFieldsRemoteFTE() {
        Contact cntOncase = new Contact(RecordTypeid = NHW_Util.getCandidateContactRecordTypeId(),LastName= CONTACT_LASTNAME,MailingCity = CONTACT_CITY );
        insert cntOnCase;
        Case provisioningCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
        provisioningCase.NHW_Employee__c = cntOnCase.id;
        insert provisioningCase;
		Tf2_Business_site__c buSite = [select id from Tf2_Business_site__c limit 1];
        Test.startTest();
        Map<String,Object> buRelatedFields = PF_NHW_HardwareAuraServices.getBSRelatedFieldsInfo(buSite.id,provisioningCase.id);
        Test.stopTest();
        System.assertEquals(buRelatedFields.get('City'),cntOncase.MailingCity,ASSERT_MSG);
    }
    
    @istest
    static void validateBuSiteRelatedFieldsNonRemoteFTEGlobalRedirectFlagOff() {
        Onboarding_Setting__c settings = new Onboarding_Setting__c(Activate_feature_for_Business_Site_redir__c = false);
        insert settings;
        Contact cntOncase = new Contact(RecordTypeid = NHW_Util.getCandidateContactRecordTypeId(),LastName=CONTACT_LASTNAME,MailingCity = CONTACT_CITY );
        insert cntOnCase;
        Case provisioningCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
        provisioningCase.NHW_Employee__c = cntOnCase.id;
        insert provisioningCase;
		Tf2_Business_site__c buSite = [select id,City__c,Name from Tf2_Business_site__c limit 1];
        buSite.name = 'California';
        Test.startTest();
        update buSite;
        Map<String,Object> buRelatedFields = PF_NHW_HardwareAuraServices.getBSRelatedFieldsInfo(buSite.id,provisioningCase.id);
        Test.stopTest();
        System.assertEquals(buRelatedFields.get('City'),buSite.City__c,ASSERT_MSG2);
    }
    
    @istest
    static void validateBuSiteRelatedFieldsNonRemoteContractorGlobalRedirectFlagOff() {
        Onboarding_Setting__c settings = new Onboarding_Setting__c(COVID_contractor_delivery_to_BS__c = false);
        insert settings;
        Contact cntOncase = new Contact(RecordTypeid = NHW_Util.getCandidateContactRecordTypeId(),LastName=CONTACT_LASTNAME,MailingCity = CONTACT_CITY );
        insert cntOnCase;
        Case provisioningCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
        provisioningCase.NHW_Employee__c = cntOnCase.id;
        provisioningCase.NHW_Employee_Type__c = 'Contractor';
        provisioningCase.Contractor_Hire_Reason__c = 'Standard';
        provisioningCase.Resource_Type__c = AGENCY_TEMP;
        insert provisioningCase;
		Tf2_Business_site__c buSite = [select id,City__c,Name from Tf2_Business_site__c limit 1];
        buSite.name = 'California';
        Test.startTest();
        update buSite;
        Map<String,Object> buRelatedFields = PF_NHW_HardwareAuraServices.getBSRelatedFieldsInfo(buSite.id,provisioningCase.id);
        Test.stopTest();
        System.assertEquals(buRelatedFields.get('City'),buSite.City__c,ASSERT_MSG2);
    }
    
    @istest
    static void validateBuSiteRelatedFieldsNonRemoteContractorBUSiteClosed() {
        Onboarding_Setting__c settings = new Onboarding_Setting__c(COVID_contractor_delivery_to_BS__c = true);
        insert settings;
        Contact cntOncase = new Contact(RecordTypeid = NHW_Util.getCandidateContactRecordTypeId(),LastName=CONTACT_LASTNAME,MailingCity = CONTACT_CITY);
        insert cntOnCase;
        Case provisioningCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
        provisioningCase.NHW_Employee__c = cntOnCase.id;
        provisioningCase.NHW_Employee_Type__c = 'Contractor';
        provisioningCase.Contractor_Hire_Reason__c = 'Standard';
        provisioningCase.Resource_Type__c = AGENCY_TEMP;
        insert provisioningCase;
		Tf2_Business_site__c buSite = [select id,City__c,Name,isReopen__c from Tf2_Business_site__c limit 1];
        buSite.name = 'California';
        buSite.isReopen__c = false;
        Test.startTest();
        update buSite;
        Map<String,Object> buRelatedFields = PF_NHW_HardwareAuraServices.getBSRelatedFieldsInfo(buSite.id,provisioningCase.id);
        Test.stopTest();
        System.assertEquals(buRelatedFields.get('City'),cntOnCase.MailingCity,ASSERT_MSG);
    }
    
    @istest
    static void validateBuSiteRelatedFieldsNonRemoteContractorBuSiteOpen() {
        Onboarding_Setting__c settings = new Onboarding_Setting__c(COVID_contractor_delivery_to_BS__c = true);
        insert settings;
        Contact cntOncase = new Contact(RecordTypeid = NHW_Util.getCandidateContactRecordTypeId(),LastName=CONTACT_LASTNAME,MailingCity = CONTACT_CITY);
        insert cntOnCase;
        Case provisioningCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
        provisioningCase.NHW_Employee__c = cntOnCase.id;
        provisioningCase.NHW_Employee_Type__c = 'Contractor';
        provisioningCase.Contractor_Hire_Reason__c = 'Standard';
        provisioningCase.Resource_Type__c = AGENCY_TEMP;
        insert provisioningCase;
		Tf2_Business_site__c buSite = [select id,City__c,Name,IsReOpen__c from Tf2_Business_site__c limit 1];
        buSite.name = 'California';
        buSite.isReopen__c = true;
        Test.startTest();
        update buSite;
        Map<String,Object> buRelatedFields = PF_NHW_HardwareAuraServices.getBSRelatedFieldsInfo(buSite.id,provisioningCase.id);
        Test.stopTest();
        System.assertEquals(buRelatedFields.get('City'),buSite.City__c,ASSERT_MSG2);
    }
    
    @istest
    static void validateBuSiteRelatedFieldsNonRemoteFTEBuSiteClosed() {
        Onboarding_Setting__c settings = new Onboarding_Setting__c(Activate_feature_for_Business_Site_redir__c = true);
        insert settings;
        Contact cntOncase = new Contact(RecordTypeid = NHW_Util.getCandidateContactRecordTypeId(),LastName=CONTACT_LASTNAME,MailingCity = CONTACT_CITY);
        insert cntOnCase;
        Case provisioningCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
        provisioningCase.NHW_Employee__c = cntOnCase.id;
        insert provisioningCase;
		Tf2_Business_site__c buSite = [select id,City__c,Name,isReOpen__c from Tf2_Business_site__c limit 1];
        buSite.name = 'California';
        buSite.isReopen__c = false;
        Test.startTest();
        update buSite;
        Map<String,Object> buRelatedFields = PF_NHW_HardwareAuraServices.getBSRelatedFieldsInfo(buSite.id,provisioningCase.id);
        Test.stopTest();
        System.assertEquals(buRelatedFields.get('City'),cntOnCase.MailingCity,ASSERT_MSG);
    }
    
    @istest
    static void validateBuSiteRelatedFieldsNonRemoteFTEBuSiteOpen() {
        Onboarding_Setting__c settings = new Onboarding_Setting__c(Activate_feature_for_Business_Site_redir__c = true);
        insert settings;
        Contact cntOncase = new Contact(RecordTypeid = NHW_Util.getCandidateContactRecordTypeId(),LastName=CONTACT_LASTNAME,MailingCity = CONTACT_CITY);
        insert cntOnCase;
        Case provisioningCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
        provisioningCase.NHW_Employee__c = cntOnCase.id;
        insert provisioningCase;
		Tf2_Business_site__c buSite = [select id,City__c,Name,isReopen__c from Tf2_Business_site__c limit 1];
        buSite.name = 'California';
        buSite.isReopen__c = true;
        Test.startTest();
        update buSite;
        Map<String,Object> buRelatedFields = PF_NHW_HardwareAuraServices.getBSRelatedFieldsInfo(buSite.id,provisioningCase.id);
        Test.stopTest();
        System.assertEquals(buRelatedFields.get('City'),buSite.City__c,'city populated bu site');
    }
    
    @istest
    static void validateBuSiteRelatedFieldsNonRemoteFTEBuSiteClosedwdCandidate() {
        WDR_TestFactory testdata = new WDR_TestFactory();
        testdata.createJobApp();
        Onboarding_Setting__c settings = [select id,Activate_feature_for_Business_Site_redir__c from Onboarding_setting__c];
        settings.Activate_feature_for_Business_Site_redir__c = true;
        update settings;
        Contact cntOncase = new Contact(RecordTypeid = NHW_Util.getCandidateContactRecordTypeId(),LastName=CONTACT_LASTNAME,MailingCity = CONTACT_CITY);
        insert cntOnCase;
        WDR_Application__c jobApp = testdata.getDefaultJobApp();
        Case provisioningCase = new Case();
        provisioningCase.NHW_Employee_Type__c = 'Regular Employee';
        provisioningCase.NHW_Employee__c = cntOnCase.id;
        provisioningCase.NHW_Job_Application__c = jobApp.id;
        insert provisioningCase;
		Tf2_Business_site__c buSite = [select id,City__c,Name,isReOpen__c from Tf2_Business_site__c limit 1];
        buSite.name = 'San francisco';
        buSite.isReopen__c = false;
        Test.startTest();
        update buSite;
        Map<String,Object> buRelatedFields = PF_NHW_HardwareAuraServices.getBSRelatedFieldsInfo(buSite.id,provisioningCase.id);
        Test.stopTest();
        jobApp = [select Candidate__r.Mailing_City__c from WDR_Application__c where id=:jobApp.id];
        System.assertEquals(buRelatedFields.get('City'),jobApp.Candidate__r.Mailing_City__c,'city populated from wd candidate');
    }
    
    @istest
    static void validateBuSiteRelatedFieldsRemoteContractor() {
        Contact cntOncase = new Contact(RecordTypeid = NHW_Util.getCandidateContactRecordTypeId(),LastName=CONTACT_LASTNAME,MailingCity = CONTACT_CITY);
        insert cntOnCase;
        Case provisioningCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
        provisioningCase.NHW_Employee__c = cntOnCase.id;
        provisioningCase.NHW_Employee_Type__c = 'Contractor';
        provisioningCase.Contractor_Hire_Reason__c = 'Standard';
        provisioningCase.Resource_Type__c = AGENCY_TEMP;
        insert provisioningCase;
		Tf2_Business_site__c buSite = [select id from Tf2_Business_site__c limit 1];
        Test.startTest();
        Map<String,Object> buRelatedFields = PF_NHW_HardwareAuraServices.getBSRelatedFieldsInfo(buSite.id,provisioningCase.id);
        Test.stopTest();
        System.assertEquals(buRelatedFields.get('City'),cntOncase.MailingCity,ASSERT_MSG);
    }
    
    @istest
    static void validateBuSiteRelatedFieldsRemoteFTEMcLaren() {
        WDR_TestFactory testdata = new WDR_TestFactory();
        testdata.createJobApp();
        Contact cntOncase = new Contact(RecordTypeid = NHW_Util.getCandidateContactRecordTypeId(),LastName=CONTACT_LASTNAME,MailingCity = CONTACT_CITY);
        insert cntOnCase;
        WDR_Application__c jobApp = testdata.getDefaultJobApp();
        Case provisioningCase = new Case();
        provisioningCase.NHW_Employee_Type__c = 'Regular Employee';
        provisioningCase.NHW_Employee__c = cntOnCase.id;
        provisioningCase.NHW_Job_Application__c = jobApp.id;
        insert provisioningCase;
		Tf2_Business_site__c buSite = [select id from Tf2_Business_site__c limit 1];
        Test.startTest();
        Map<String,Object> buRelatedFields = PF_NHW_HardwareAuraServices.getBSRelatedFieldsInfo(buSite.id,provisioningCase.id);
        Test.stopTest();
        jobApp = [select Candidate__r.Mailing_City__c from WDR_Application__c where id=:jobApp.id];
        System.assertEquals(buRelatedFields.get('City'),jobApp.Candidate__r.Mailing_City__c,'city populated from wd candidate');
    }
}