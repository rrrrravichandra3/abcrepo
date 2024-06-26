/**
 * Test class for MA_DS_TemplateTrigger & its associated classes.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         07/12/2023      Chakshu Malhotra        Adds test methods to cover MA_DS_TemplateTrigger & its associated classes.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
@isTest
public class MA_DS_Test_TemplateTrigger {

    private static final String TEST_IDENTIFIER = 'TemplateTrigger';

    private static final String ASSERT_MSG_NO_MASTER_TEMPLATE = 'Cannot find the Master Template; should have been able to insert by the Admin User!';
    private static final String ASSERT_MSG_NO_MASTER_TEMPLATE_DML_EXCEPTION = 'No DmlException while inserting Master Template; should not have been able to insert by the M&A ES User!';
    private static final String ASSERT_MSG_NO_ACQ_TEMPLATE = 'Cannot find the Acquisition Template; should have been able to insert by the Admin User!';
    private static final String ASSERT_MSG_NO_ACQ_TEMPLATE_DML_EXCEPTION = 'No DmlException while inserting Acquisition Template; should not have been able to insert by the M&A ES User!';
    private static final String ASSERT_MSG_NO_SUMMARY_TEMPLATE = 'Cannot find the Manager Summary Template; should have been able to insert by the Admin User!';
    private static final String ASSERT_MSG_NO_SUMMARY_TEMPLATE_DML_EXCEPTION = 'No DmlException while inserting duplicate Manager Summary Template; should not have been able to insert duplicate template!';
    private static final String ASSERT_MSG_NO_BGC_TEMPLATE = 'Cannot find the Background Check Template; should have been able to insert by the M&A ES User!';
    private static final String ASSERT_MSG_NO_BGC_TEMPLATE_DML_EXCEPTION = 'No DmlException while inserting duplicate Backgorund Check Template; should not have been able to insert duplicate template!';
    private static final String ASSERT_MSG_NO_UPDATE_MASTER_TEMPLATE = 'Cannot update the Master Template; should have been able to update by the Admin User!';
    private static final String ASSERT_MSG_NO_UPDATE_MASTER_TEMPLATE_DML_EXCEPTION = 'No DmlException while updating Master Template; should not have been able to update by the M&A ES User!';
    private static final String ASSERT_MSG_NO_UDATE_ACQ_TEMPLATE = 'Cannot update the Acquisition Template; should have been able to update by the Admin User!';
    private static final String ASSERT_MSG_NO_UPDATE_ACQ_TEMPLATE_DML_EXCEPTION = 'No DmlException while updating Acquisition Template; should not have been able to update by the M&A ES User!';
    private static final String ASSERT_MSG_NO_UPDATE_BGC_TEMPLATE = 'Cannot update the Background Check Template; should have been able to update by the M&A ES User!';
    private static final String ASSERT_MSG_NO_DELETE_MASTER_TEMPLATE_DML_EXCEPTION = 'No DmlException while deleting Master Template; should not have been able to delete by the M&A ES User!';
    private static final String ASSERT_MSG_NO_DELETE_ACQ_TEMPLATE_DML_EXCEPTION = 'No DmlException while deleting Acquisition Template; should not have been able to delete by the M&A ES User!';
    private static final String ASSERT_MSG_NO_DELETE_BGC_TEMPLATE = 'Cannot delete the Background Check Template; should have been able to delete by the M&A ES User!';

    @testSetup
    public static void setupTestData() {
        Map<MA_DS_TestUtil_Users.TestUser, User> userMap;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            userMap = MA_DS_TestUtil_Users.setupTestUsers(TEST_IDENTIFIER);
            MA_DS_TestUtil_Users.activatePermissions(userMap);
        }
        
        System.runAs(userMap.get(MA_DS_TestUtil_Users.TestUser.SYSTEM_ADMIN_USER)) {
            MA_DS_TestUtil_Packages.setupMasterPackages();
        }
        
        System.runAs(userMap.get(MA_DS_TestUtil_Users.TestUser.MA_ES_USER)) {
            Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.setupTestAcquisitionCompany(TEST_IDENTIFIER);
        }
    }

    @isTest
    public static void shouldInsertMasterTemplate() {
        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.PIIA_CAL};

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.SYSTEM_ADMIN_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_Templates.setupMasterTemplates(maTemplates, false);
        }
        Test.stopTest();

        Map<MA_DS_TestUtil_Templates.Template, MA_DS_Template__c> templateMap = MA_DS_TestUtil_Templates.getTemplateMap(maTemplates, MA_DS_TestUtil_Templates.TemplateType.MASTER);
        Assert.areEqual(1, templateMap.size(), ASSERT_MSG_NO_MASTER_TEMPLATE);
    }

    @isTest
    public static void shouldNotInsertMasterTemplate() {
        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.PIIA_CAL};

        Boolean exceptionCaught = false;

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            try {
                MA_DS_TestUtil_Templates.setupMasterTemplates(maTemplates, false);
            }catch(DmlException ex) {
                exceptionCaught = true;
            }
        }
        Test.stopTest();

        Assert.isTrue(exceptionCaught, ASSERT_MSG_NO_MASTER_TEMPLATE_DML_EXCEPTION);
    }

    @isTest
    public static void shouldInsertAcquisitionTemplate() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);

        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.PIIA_CAL};
        Map<MA_DS_TestUtil_Templates.Template, MA_DS_Template__c> masterTemplateMap = MA_DS_TestUtil_Templates.setupMasterTemplates(maTemplates, true);

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.SYSTEM_ADMIN_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_Templates.setupAcquisitionTemplates(acqCompany, masterTemplateMap, false);
        }
        Test.stopTest();

        Map<MA_DS_TestUtil_Templates.Template, MA_DS_Template__c> templateMap = MA_DS_TestUtil_Templates.getTemplateMap(maTemplates, MA_DS_TestUtil_Templates.TemplateType.ACQUISITION, acqCompany);
        Assert.areEqual(1, templateMap.size(), ASSERT_MSG_NO_ACQ_TEMPLATE);
    }

    @isTest
    public static void shouldNotInsertAcquisitionTemplate() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);

        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.PIIA_CAL};
        Map<MA_DS_TestUtil_Templates.Template, MA_DS_Template__c> masterTemplateMap = MA_DS_TestUtil_Templates.setupMasterTemplates(maTemplates, true);

        Boolean exceptionCaught = false;

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            try {
                MA_DS_TestUtil_Templates.setupAcquisitionTemplates(acqCompany, masterTemplateMap, false);
            }catch(DmlException ex) {
                exceptionCaught = true;
            }
        }
        Test.stopTest();

        Assert.isTrue(exceptionCaught, ASSERT_MSG_NO_ACQ_TEMPLATE_DML_EXCEPTION);
    }

    @isTest
    public static void shouldInsertManagerSummaryTemplate() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);

        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.MANAGER_SUMMARY};
        Map<MA_DS_TestUtil_Templates.Template, MA_DS_Template__c> masterTemplateMap = MA_DS_TestUtil_Templates.setupMasterTemplates(maTemplates, true);

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.SYSTEM_ADMIN_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_Templates.setupAcquisitionTemplates(acqCompany, masterTemplateMap, false);
        }
        Test.stopTest();

        Map<MA_DS_TestUtil_Templates.Template, MA_DS_Template__c> templateMap = MA_DS_TestUtil_Templates.getTemplateMap(maTemplates, MA_DS_TestUtil_Templates.TemplateType.ACQUISITION, acqCompany);
        Assert.areEqual(1, templateMap.size(), ASSERT_MSG_NO_SUMMARY_TEMPLATE);
    }

    @isTest
    public static void shouldNotInsertDuplicateManagerSummaryTemplate() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);

        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.MANAGER_SUMMARY};
        Map<MA_DS_TestUtil_Templates.Template, MA_DS_Template__c> masterTemplateMap = MA_DS_TestUtil_Templates.setupMasterTemplates(maTemplates, true);
        MA_DS_TestUtil_Templates.setupAcquisitionTemplates(acqCompany, masterTemplateMap, true);

        Boolean exceptionCaught = false;

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.SYSTEM_ADMIN_USER, TEST_IDENTIFIER)) {
            try {
                MA_DS_TestUtil_Templates.setupAcquisitionTemplates(acqCompany, masterTemplateMap, false);
            }catch(DmlException ex) {
                exceptionCaught = true;
            }
        }
        Test.stopTest();

        Assert.isTrue(exceptionCaught, ASSERT_MSG_NO_SUMMARY_TEMPLATE_DML_EXCEPTION);
    }

    @isTest
    public static void shouldInsertBackgroundCheckTemplate() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);

        Set<MA_DS_TestUtil_Templates.BGCTemplate> bgcTemplates = new Set<MA_DS_TestUtil_Templates.BGCTemplate> {MA_DS_TestUtil_Templates.BGCTemplate.US_BGC_TEMPLATE};

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_Templates.setupBGCTemplates(bgcTemplates, acqCompany, false);
        }
        Test.stopTest();

        Map<MA_DS_TestUtil_Templates.BGCTemplate, MA_DS_Template__c> templateMap = MA_DS_TestUtil_Templates.getBGCTemplateMap(bgcTemplates, acqCompany);
        Assert.areEqual(1, templateMap.size(), ASSERT_MSG_NO_BGC_TEMPLATE);
    }

    @isTest
    public static void shouldNotInsertDuplicateBackgroundCheckTemplate() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);

        Set<MA_DS_TestUtil_Templates.BGCTemplate> bgcTemplates = new Set<MA_DS_TestUtil_Templates.BGCTemplate> {MA_DS_TestUtil_Templates.BGCTemplate.US_BGC_TEMPLATE};
        MA_DS_TestUtil_Templates.setupBGCTemplates(bgcTemplates, acqCompany, true);

        Boolean exceptionCaught = false;

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            try {
                MA_DS_TestUtil_Templates.setupBGCTemplates(bgcTemplates, acqCompany, false);
            }catch(DmlException ex) {
                exceptionCaught = true;
            }
        }
        Test.stopTest();

        Assert.isTrue(exceptionCaught, ASSERT_MSG_NO_BGC_TEMPLATE_DML_EXCEPTION);
    }

    @isTest
    public static void shouldUpdateMasterTemplate() {
        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.PIIA_CAL};
        MA_DS_TestUtil_Templates.setupMasterTemplates(maTemplates, true);

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.SYSTEM_ADMIN_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_TemplateTrigger.updateTemplates(maTemplates, MA_DS_TestUtil_Templates.TemplateType.MASTER);
        }
        Test.stopTest();

        Map<MA_DS_TestUtil_Templates.Template, MA_DS_Template__c> templateMap = MA_DS_TestUtil_Templates.getTemplateMap(maTemplates, MA_DS_TestUtil_Templates.TemplateType.MASTER);
        Assert.areEqual(1, templateMap.size(), ASSERT_MSG_NO_UPDATE_MASTER_TEMPLATE);
    }

    @isTest
    public static void shouldNotUpdateMasterTemplate() {
        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.PIIA_CAL};
        MA_DS_TestUtil_Templates.setupMasterTemplates(maTemplates, true);

        Boolean exceptionCaught = false;

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            try {
                MA_DS_TestUtil_TemplateTrigger.updateTemplates(maTemplates, MA_DS_TestUtil_Templates.TemplateType.MASTER);
            }catch(DmlException ex) {
                exceptionCaught = true;
            }
        }
        Test.stopTest();

        Assert.isTrue(exceptionCaught, ASSERT_MSG_NO_UPDATE_MASTER_TEMPLATE_DML_EXCEPTION);
    }

    @isTest
    public static void shouldUpdateAcquisitionTemplate() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);

        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.PIIA_CAL};
        Map<MA_DS_TestUtil_Templates.Template, MA_DS_Template__c> masterTemplateMap = MA_DS_TestUtil_Templates.setupMasterTemplates(maTemplates, true);
        MA_DS_TestUtil_Templates.setupAcquisitionTemplates(acqCompany, masterTemplateMap, true);

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.SYSTEM_ADMIN_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_TemplateTrigger.updateTemplates(maTemplates, MA_DS_TestUtil_Templates.TemplateType.ACQUISITION, acqCompany);
        }
        Test.stopTest();    

        Map<MA_DS_TestUtil_Templates.Template, MA_DS_Template__c> templateMap = MA_DS_TestUtil_Templates.getTemplateMap(maTemplates, MA_DS_TestUtil_Templates.TemplateType.ACQUISITION, acqCompany);
        Assert.areEqual(1, templateMap.size(), ASSERT_MSG_NO_UDATE_ACQ_TEMPLATE);
    }

    @isTest
    public static void shouldNotUpdateAcquisitionTemplate() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);

        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.PIIA_CAL};
        Map<MA_DS_TestUtil_Templates.Template, MA_DS_Template__c> masterTemplateMap = MA_DS_TestUtil_Templates.setupMasterTemplates(maTemplates, true);
        MA_DS_TestUtil_Templates.setupAcquisitionTemplates(acqCompany, masterTemplateMap, true);

        Boolean exceptionCaught = false;

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            try {
                MA_DS_TestUtil_TemplateTrigger.updateTemplates(maTemplates, MA_DS_TestUtil_Templates.TemplateType.ACQUISITION, acqCompany);
            }catch(DmlException ex) {
                exceptionCaught = true;
            }
        }
        Test.stopTest();

        Assert.isTrue(exceptionCaught, ASSERT_MSG_NO_UPDATE_ACQ_TEMPLATE_DML_EXCEPTION);
    }

    @isTest
    public static void shouldUpdateBackgroundCheckTemplate() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);

        Set<MA_DS_TestUtil_Templates.BGCTemplate> bgcTemplates = new Set<MA_DS_TestUtil_Templates.BGCTemplate> {MA_DS_TestUtil_Templates.BGCTemplate.US_BGC_TEMPLATE};
        MA_DS_TestUtil_Templates.setupBGCTemplates(bgcTemplates, acqCompany, true);

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_TemplateTrigger.updateBGCTemplates(bgcTemplates, acqCompany);
        }
        Test.stopTest();

        Map<MA_DS_TestUtil_Templates.BGCTemplate, MA_DS_Template__c> templateMap = MA_DS_TestUtil_Templates.getBGCTemplateMap(bgcTemplates, acqCompany);
        Assert.areEqual(1, templateMap.size(), ASSERT_MSG_NO_UPDATE_BGC_TEMPLATE);
    }

    @isTest
    public static void shouldNotDeleteMasterTemplate() {
        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.PIIA_CAL};
        MA_DS_TestUtil_Templates.setupMasterTemplates(maTemplates, true);

        Boolean exceptionCaught = false;

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            try {
                MA_DS_TestUtil_TemplateTrigger.deleteTemplates(maTemplates, MA_DS_TestUtil_Templates.TemplateType.MASTER);
            }catch(DmlException ex) {
                exceptionCaught = true;
            }
        }
        Test.stopTest();

        Assert.isTrue(exceptionCaught, ASSERT_MSG_NO_DELETE_MASTER_TEMPLATE_DML_EXCEPTION);
    }

    @isTest
    public static void shouldNotDeleteAcquisitionTemplate() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);

        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.PIIA_CAL};
        Map<MA_DS_TestUtil_Templates.Template, MA_DS_Template__c> masterTemplateMap = MA_DS_TestUtil_Templates.setupMasterTemplates(maTemplates, true);
        MA_DS_TestUtil_Templates.setupAcquisitionTemplates(acqCompany, masterTemplateMap, true);

        Boolean exceptionCaught = false;

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            try {
                MA_DS_TestUtil_TemplateTrigger.deleteTemplates(maTemplates, MA_DS_TestUtil_Templates.TemplateType.ACQUISITION, acqCompany);
            }catch(DmlException ex) {
                exceptionCaught = true;
            }
        }
        Test.stopTest();

        Assert.isTrue(exceptionCaught, ASSERT_MSG_NO_DELETE_ACQ_TEMPLATE_DML_EXCEPTION);
    }

    @isTest
    public static void shouldDeleteBackgroundCheckTemplate() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);

        Set<MA_DS_TestUtil_Templates.BGCTemplate> bgcTemplates = new Set<MA_DS_TestUtil_Templates.BGCTemplate> {MA_DS_TestUtil_Templates.BGCTemplate.US_BGC_TEMPLATE};
        MA_DS_TestUtil_Templates.setupBGCTemplates(bgcTemplates, acqCompany, true);

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_TemplateTrigger.deleteBGCTemplates(bgcTemplates, acqCompany);
        }
        Test.stopTest();

        Map<MA_DS_TestUtil_Templates.BGCTemplate, MA_DS_Template__c> templateMap = MA_DS_TestUtil_Templates.getBGCTemplateMap(bgcTemplates, acqCompany);
        Assert.areEqual(0, templateMap.size(), ASSERT_MSG_NO_DELETE_BGC_TEMPLATE);
    }
}