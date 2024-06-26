/**
 * Test class for MA_DS_InUseTemplateTrigger & its associated classes.
 * 
 * Version      Date            Author                  Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         09/12/2023      Chakshu Malhotra        Adds test methods to cover MA_DS_InUseTemplateTrigger & its associated classes.
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
@isTest
public class MA_DS_Test_InUseTemplateTrigger {
    
    private static final String TEST_IDENTIFIER = 'InUseTemplateTrigger';

    private static final String ASSERT_MSG_TOTAL_INSERTED_IN_USE_TEMPLATES = 'Not an expected number of inserted In Use Templates!';
    private static final String ASSERT_MSG_NULL_CONCATENATED_ID = 'Concatenated Id not updated on the In Use Templates!';
    private static final String ASSERT_MSG_INELIGIBLE_RULES_SYNC_STATUS_EXCEPTION = 'No DmlException while inserting the In Use Template; should not have inserted due to ineligible Rules Sync Status of the Package Distribution!';
    private static final String ASSERT_MSG_NULL_SYNC_RULES_ON_PD_IDS = 'No Rules to be synced on the Package Distribution Ids!';
    private static final String ASSERT_MSG_NOT_NULL_AUDIT_FLAGS_JSON = 'Audit Flags JSON needs to be null when Audit Flags are suppressed!';
    private static final String ASSERT_MSG_NOT_NULL_RULES_CRITERIA_JSON = 'Rules Criteria JSON needs to be null when Rules Criteria are suppressed!';
    private static final String ASSERT_MSG_NOT_NULL_RULES_CRITERIA_QUERY = 'Rules Criteria Query needs to be null when Rules Criteria are suppressed!';

    private static final Set<MA_DS_TestUtil_Packages.MA_Package> maUSPackage = new Set<MA_DS_TestUtil_Packages.MA_Package> {MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE};
    private static final Set<MA_DS_TestUtil_Templates.Template> maUSTemplates = MA_DS_TestUtil_Templates.getUSPackageTemplates();

    @testSetup
    public static void setupTestData() {
        Map<MA_DS_TestUtil_Users.TestUser, User> userMap;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            userMap = MA_DS_TestUtil_Users.setupTestUsers(TEST_IDENTIFIER);
            MA_DS_TestUtil_Users.activatePermissions(userMap);
        }
        
        Acquisition_Company__c acqCompany;
        
        System.runAs(userMap.get(MA_DS_TestUtil_Users.TestUser.MA_ES_USER)) {
            acqCompany = MA_DS_TestUtil_Acquisition.setupTestAcquisitionCompany(TEST_IDENTIFIER);
        }

        Map<MA_DS_TestUtil_Packages.MA_Package, MA_DS_Package__c> acqUSPackageMap;

        System.runAs(userMap.get(MA_DS_TestUtil_Users.TestUser.SYSTEM_ADMIN_USER)) {
            MA_DS_TestUtil_SetupPackages.DataWrapper wrapperInstance = MA_DS_TestUtil_SetupPackages.setupMasterPackagesAndTemplatesWithRules(maUSPackage, maUSTemplates);
            acqUSPackageMap = MA_DS_TestUtil_Packages.setupAcquisitionPackages(acqCompany, wrapperInstance.packageMap);
            MA_DS_TestUtil_Templates.setupAcquisitionTemplates(acqCompany, wrapperInstance.templateMap, true);
        }

        System.runAs(userMap.get(MA_DS_TestUtil_Users.TestUser.MA_ES_USER)) {
            MA_DS_TestUtil_PackageDistributions.setupPackageDistributionsWithRules(MA_DS_TestUtil_PackageDistributions.getUSDistributions(), acqUSPackageMap.get(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE), true);
        }
    }

    @isTest
    public static void shouldInsertAcqInUseTemplates() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);

        List<MA_DS_In_Use_Template__c> inUseTemplates;

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.SYSTEM_ADMIN_USER, TEST_IDENTIFIER)) {
            inUseTemplates = MA_DS_TestUtil_InUseTemplateTrigger.insertAcquistionInUseTemplates(maUSPackage, maUSTemplates, acqCompany, false);
        }
        Test.stopTest();

        Assert.areEqual(maUSTemplates.size(), inUseTemplates.size(), ASSERT_MSG_TOTAL_INSERTED_IN_USE_TEMPLATES);
    }

    @isTest
    public static void shouldUpdateConcatenatedId() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);

        Set<MA_DS_TestUtil_Templates.Template> maUSTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.PIIA_CAL};
        List<MA_DS_In_Use_Template__c> inUseTemplates = MA_DS_TestUtil_InUseTemplateTrigger.insertAcquistionInUseTemplates(maUSPackage, maUSTemplates, acqCompany, true);

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.SYSTEM_ADMIN_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_InUseTemplateTrigger.updateConcatenatedId(inUseTemplates[0], false);
        }
        Test.stopTest();

        List<MA_DS_In_Use_Template__c> updatedAcqUSInUseTemplates = MA_DS_TestUtil_InUseTemplates.getInUseTemplateMap(maUSPackage, maUSTemplates, acqCompany, MA_DS_TestUtil_InUseTemplates.InUseTemplateTemplate.ACQUISITION_IN_USE_TEMPLATE).values();
        Assert.isNotNull(updatedAcqUSInUseTemplates[0].MA_DS_Concatenated_Id__c, ASSERT_MSG_NULL_CONCATENATED_ID);
    }

    @isTest
    public static void shouldThrowDmlExceptionForIneligibleRulesSyncStatus() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);
        MA_DS_TestUtil_InUseTemplateTrigger.updateRulesSyncStatus(MA_DS_TestUtil_InUseTemplateTrigger.SYNCING_PACKAGE_RULES, MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage, true);

        Boolean exceptionCaught = false;

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.SYSTEM_ADMIN_USER, TEST_IDENTIFIER)) {
            try {
                MA_DS_TestUtil_InUseTemplateTrigger.insertAcquistionInUseTemplates(maUSPackage, new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.PIIA_CAL}, acqCompany, false);
            }catch(DmlException ex) {
                exceptionCaught = true;
            }
        }
        Test.stopTest();

        Assert.isTrue(exceptionCaught, ASSERT_MSG_INELIGIBLE_RULES_SYNC_STATUS_EXCEPTION);
    }

    @isTest
    public static void shouldInsertWithNeedSyncOnPDIds() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);
        MA_DS_TestUtil_InUseTemplateTrigger.updateRulesSyncStatus(MA_DS_TestUtil_InUseTemplateTrigger.RULES_SYNCED, MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage, true);

        Set<MA_DS_TestUtil_Templates.Template> maUSTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.PIIA_CAL, MA_DS_TestUtil_Templates.Template.MANAGER_SUMMARY};

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.SYSTEM_ADMIN_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_InUseTemplateTrigger.insertAcquistionInUseTemplates(maUSPackage, maUSTemplates, acqCompany, false);
        }
        Test.stopTest();

        List<MA_DS_In_Use_Template__c> acqUSInUseTemplates = MA_DS_TestUtil_InUseTemplates.getInUseTemplateMap(maUSPackage, maUSTemplates, acqCompany, MA_DS_TestUtil_InUseTemplates.InUseTemplateTemplate.ACQUISITION_IN_USE_TEMPLATE).values();
        Assert.isNotNull(acqUSInUseTemplates[0].MA_DS_Sync_Rules_On_PD_Ids__c, ASSERT_MSG_NULL_SYNC_RULES_ON_PD_IDS);
        Assert.isNotNull(acqUSInUseTemplates[1].MA_DS_Sync_Rules_On_PD_Ids__c, ASSERT_MSG_NULL_SYNC_RULES_ON_PD_IDS);
    }

    @isTest
    public static void shouldUpdateWithNeedSyncOnPDIds() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);
        MA_DS_TestUtil_InUseTemplateTrigger.updateRulesSyncStatus(MA_DS_TestUtil_InUseTemplateTrigger.RULES_SYNCED, MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage, true);

        Set<MA_DS_TestUtil_Templates.Template> maUSTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.PIIA_CAL};

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.SYSTEM_ADMIN_USER, TEST_IDENTIFIER)) {
            List<MA_DS_In_Use_Template__c> acqUSInUseTemplates = MA_DS_TestUtil_InUseTemplateTrigger.insertAcquistionInUseTemplates(maUSPackage, maUSTemplates, acqCompany, false);
            MA_DS_TestUtil_InUseTemplateTrigger.updateRulesSyncStatus(MA_DS_TestUtil_InUseTemplateTrigger.RULES_SYNCED, MA_DS_TestUtil_PackageDistributions.Distribution.US_ILLINOIS, acqUSPackage, false);
            MA_DS_TestUtil_InUseTemplateTrigger.updateSuppressFlags(acqUSInUseTemplates[0], true, true, false);
        }
        Test.stopTest();

        List<MA_DS_In_Use_Template__c> updatedAcqUSInUseTemplates = MA_DS_TestUtil_InUseTemplates.getInUseTemplateMap(maUSPackage, maUSTemplates, acqCompany, MA_DS_TestUtil_InUseTemplates.InUseTemplateTemplate.ACQUISITION_IN_USE_TEMPLATE).values();
        Assert.isNotNull(updatedAcqUSInUseTemplates[0].MA_DS_Sync_Rules_On_PD_Ids__c, ASSERT_MSG_NULL_SYNC_RULES_ON_PD_IDS);
        Assert.isNull(updatedAcqUSInUseTemplates[0].MA_DS_Audit_Flags_JSON__c, ASSERT_MSG_NOT_NULL_AUDIT_FLAGS_JSON);
        Assert.isNull(updatedAcqUSInUseTemplates[0].MA_DS_Rules_Criteria_JSON__c, ASSERT_MSG_NOT_NULL_RULES_CRITERIA_JSON);
        Assert.isNull(updatedAcqUSInUseTemplates[0].MA_DS_Rules_Criteria_Query__c, ASSERT_MSG_NOT_NULL_RULES_CRITERIA_QUERY);
    }
}