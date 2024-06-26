/**
 * Test class for MA_DS_ApplyRules & its associated classes.
 * 
 * Version      Date            Author                  Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         18/12/2023      Chakshu Malhotra        Adds test methods to cover MA_DS_ApplyRules & its associated classes.
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
@isTest
public class MA_DS_Test_ApplyRules {
    
    private static final String TEST_IDENTIFIER = 'ApplyRules';

    private static final String ASSERT_MSG_INELIGIBLE_INT_STATUS_EXCEPTION = 'No MA_DS_AppliedRulesHelper.IneligibleIntegrationStatusException handled while applying rules for the package distribution record!';
    private static final String ASSERT_MSG_INELIGIBLE_RULES_SYNC_STATUS_EXCEPTION = 'No MA_DS_AppliedRulesHelper.IneligibleRulesSyncStatusException handled while applying rules for the package distribution record!';
    private static final String ASSERT_MSG_NO_RULES_CRITERIA_QUERY_EXCEPTION = 'No MA_DS_AppliedRulesHelper.NoRulesCriteriaQueryException handled while applying rules for the package distribution record!';
    private static final String ASSERT_MSG_INELIGIBLE_STATUS_EXCEPTION = 'No MA_DS_AppliedRulesHelper.IneligibleStatusException handled while applying rules for the package distribution record!';
    private static final String ASSERT_MSG_AURA_HANDLED_EXCEPTION = 'Failed to catch AuraHandledException while applying rules for the package distribution record!';
    private static final String ASSERT_MSG_PD_TYPE_APPLIED_RULE_COUNT = 'Not an expected number of Applied Rule records of type \'Package Distribution Rule\'!';
    private static final String ASSERT_MSG_PD_RULE_SYNC_QUERY_EXCEPTION = 'Failed to log QueryException while creating Applied Rule records of type \'Package Distribution Rule\'!';
    private static final String ASSERT_MSG_SUMMARY_IUT_TYPE_RULE_COUNT = 'Not an expected number of IUT type Applied Rule records for \'Manager Summary Template\'!';
    private static final String ASSERT_MSG_US_OFFER_LETTER_IUT_TYPE_RULE_COUNT = 'Not an expected number of IUT type Applied Rule records for \'US Offer Letter Template\'!';
    private static final String ASSERT_MSG_IUT_TYPE_RULE_COUNT = 'Not an expected number of Applied Rule records of type \'In Use Template Rule\'!';
    private static final String ASSERT_MSG_PIIA_CAL_IUT_TYPE_RULE_COUNT = 'Not an expected number of IUT type Applied Rule records for \'PIIA CAL Template\'!';
    private static final String ASSERT_MSG_US_HIPPA_NOTICE_IUT_TYPE_RULE_COUNT = 'Not an expected number of IUT type Applied Rule records for \'US HIPPA Notice Template\'!';
    private static final String ASSERT_MSG_GL_RSU_IUT_TYPE_RULE_COUNT = 'Not an expected number of IUT type Applied Rule records for \'GL RSU Template\'!';
    private static final String ASSERT_MSG_APPLIED_RULE_QUERY_EXCEPTION = 'Failed to log QueryException while fetching Applied Rule records!';
    private static final String ASSERT_MSG_IUT_RULE_SYNC_QUERY_EXCEPTION = 'Failed to log QueryException while creating Applied Rule records of type \'In Use Template Rule\'!';
    private static final String ASSERT_MSG_US_CALIFORNIA_PURGE_RULE_COUNT = 'Not an expected number of Applied Rule records for \'US California Distribution\' after PurgeRuleSync!';
    private static final String ASSERT_MSG_US_WASHINGTON_PURGE_RULE_COUNT = 'Not an expected number of Applied Rule records for \'US Washington Distribution\' after PurgeRuleSync!';
    private static final String ASSERT_MSG_SUMMARY_RULE_APPLIED_COUNT = 'Not an expected number of Applied Rule records with Manager Summary Rule Applied!';
    private static final String ASSERT_MSG_PACKAGE_RULE_APPLIED_COUNT = 'Not an expected number of Applied Rule records with Package Rule Applied!';

    private static final Set<MA_DS_TestUtil_Acquisition.Employees> maUSEmployees = new Set<MA_DS_TestUtil_Acquisition.Employees> {MA_DS_TestUtil_Acquisition.Employees.US_EMPLOYEES};
    private static final Set<MA_DS_TestUtil_Packages.MA_Package> maUSPackages = new Set<MA_DS_TestUtil_Packages.MA_Package> {MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE};
    private static final Set<MA_DS_TestUtil_Templates.Template> maUSTemplates = MA_DS_TestUtil_Templates.getUSPackageTemplates();
    private static final Set<MA_DS_TestUtil_PackageDistributions.Distribution> maUSDistributions = MA_DS_TestUtil_PackageDistributions.getUSDistributions();

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
            MA_DS_TestUtil_Acquisition.setupTestAcquisitionContacts(acqCompany, maUSEmployees);
        }

        MA_DS_TestUtil_SetupPackages.DataWrapper acqWrapperInstance;

        System.runAs(userMap.get(MA_DS_TestUtil_Users.TestUser.SYSTEM_ADMIN_USER)) {
            MA_DS_TestUtil_SetupPackages.setupMasterPackagesAndTemplatesWithRules(maUSPackages, maUSTemplates);
            acqWrapperInstance = MA_DS_TestUtil_SetupPackages.setupAcquisitionPackagesAndTemplates(maUSPackages, maUSTemplates, acqCompany);
        }

        System.runAs(userMap.get(MA_DS_TestUtil_Users.TestUser.MA_ES_USER)) {
            MA_DS_TestUtil_PackageDistributions.setupPackageDistributions(maUSDistributions, acqWrapperInstance.packageMap.get(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE), true);
        }
    }

    @isTest
    public static void shouldHandleIneligibleIntegrationStatusException() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_PackageDistributions.generateRules(new List<MA_DS_Package_Distribution__c> {pkgDistribution}, true);
        MA_DS_TestUtil_ApplyRules.updatePackageDistributionToCauseIneligibleIntegrationStatusException(pkgDistribution, true);

        MA_DS_ApplyRules.ResponseWrapper responseWrapper;

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            responseWrapper = MA_DS_ApplyRules.applyRules(pkgDistribution.Id);
        }
        Test.stopTest();

        Assert.isTrue(responseWrapper.isError, ASSERT_MSG_INELIGIBLE_INT_STATUS_EXCEPTION);
    }

    @isTest
    public static void shouldHandleIneligibleRulesSyncStatusException() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_PackageDistributions.generateRules(new List<MA_DS_Package_Distribution__c> {pkgDistribution}, true);
        MA_DS_TestUtil_ApplyRules.updatePackageDistributionToCauseIneligibleRulesSyncStatusException(pkgDistribution, true);

        MA_DS_ApplyRules.ResponseWrapper responseWrapper;

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            responseWrapper = MA_DS_ApplyRules.applyRules(pkgDistribution.Id);
        }
        Test.stopTest();

        Assert.isTrue(responseWrapper.isError, ASSERT_MSG_INELIGIBLE_RULES_SYNC_STATUS_EXCEPTION);
    }

    @isTest
    public static void shouldHandleNoRulesCriteriaQueryException() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_PackageDistributions.generateRules(new List<MA_DS_Package_Distribution__c> {pkgDistribution}, true);
        MA_DS_TestUtil_PkgDistributionTrigger.updateRulesSyncStatus(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.NEED_SYNC_PACKAGE_TEMPLATE_RULES, true);
        MA_DS_TestUtil_ApplyRules.updatePackageDistributionToCauseNoRulesCriteriaQueryException(pkgDistribution, true);

        MA_DS_ApplyRules.ResponseWrapper responseWrapper;

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            responseWrapper = MA_DS_ApplyRules.applyRules(pkgDistribution.Id);
        }
        Test.stopTest();

        Assert.isTrue(responseWrapper.isError, ASSERT_MSG_NO_RULES_CRITERIA_QUERY_EXCEPTION);
    }

    @isTest
    public static void shouldHandleIneligibleStatusException() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_PackageDistributions.generateRules(new List<MA_DS_Package_Distribution__c> {pkgDistribution}, true);
        MA_DS_TestUtil_PkgDistributionTrigger.updateRulesSyncStatus(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.NEED_SYNC_PACKAGE_TEMPLATE_RULES, true);
        MA_DS_TestUtil_ApplyRules.updatePackageDistributionToCauseIneligibleStatusException(pkgDistribution, true);

        MA_DS_ApplyRules.ResponseWrapper responseWrapper;

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            responseWrapper = MA_DS_ApplyRules.applyRules(pkgDistribution.Id);
        }
        Test.stopTest();

        Assert.isTrue(responseWrapper.isError, ASSERT_MSG_INELIGIBLE_RULES_SYNC_STATUS_EXCEPTION);
    }

    @isTest
    public static void shouldThrowAuraHandledException() {
        Boolean exceptionCaught = false;

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            try {
                MA_DS_ApplyRules.applyRules(null);
            }catch(AuraHandledException ex) {
                exceptionCaught = true;
            }
        }
        Test.stopTest();

        Assert.isTrue(exceptionCaught, ASSERT_MSG_AURA_HANDLED_EXCEPTION);
    }

    @isTest
    public static void shouldLogQueryExceptionForUSCaliforniaDistributionRuleSync() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_PackageDistributions.generateRules(new List<MA_DS_Package_Distribution__c> {pkgDistribution}, false);
        
        MA_DS_Package_Distribution__c updatedPkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_ApplyRules.updatePackageDistributionToLogQueryExceptionForPDRuleSync(updatedPkgDistribution, true);

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_ApplyRules.applyRules(pkgDistribution.Id);
        }
        Test.stopTest();

        Assert.isTrue([SELECT Id FROM PF_Debug_Log__c WHERE NH_Name__c = :MA_DS_PackageAppliedRuleSyncUtility.class.getName()].size() > 0, ASSERT_MSG_PD_RULE_SYNC_QUERY_EXCEPTION);
    }

    @isTest
    public static void shouldInitPackageRuleSyncForUSCaliforniaDistribution() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_PackageDistributions.generateRules(new List<MA_DS_Package_Distribution__c> {pkgDistribution}, false);

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_ApplyRules.applyRules(pkgDistribution.Id);
        }
        Test.stopTest();

        Integer expectedRuleCount = MA_DS_TestUtil_ApplyRules.getExpectedAcqContactCountForUSCaliforniaDistribution(acqCompany.Id);
        Assert.areEqual(expectedRuleCount, MA_DS_TestUtil_ApplyRules.getPackageDistributionTypeAppliedRuleCount(pkgDistribution.Id), ASSERT_MSG_PD_TYPE_APPLIED_RULE_COUNT);
    }

    @isTest
    public static void shouldInitPackageRuleSyncForUSAllEmpDistribution() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_ALL_EMP, acqUSPackage);
        MA_DS_TestUtil_PackageDistributions.generateRules(new List<MA_DS_Package_Distribution__c> {pkgDistribution}, false);

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_ApplyRules.applyRules(pkgDistribution.Id);
        }
        Test.stopTest();

        Integer expectedRuleCount = MA_DS_TestUtil_ApplyRules.getExpectedAcqContactCountForUSAllEmpDistribution(acqCompany.Id);
        Assert.areEqual(expectedRuleCount, MA_DS_TestUtil_ApplyRules.getPackageDistributionTypeAppliedRuleCount(pkgDistribution.Id), ASSERT_MSG_PD_TYPE_APPLIED_RULE_COUNT);
    }

    @isTest
    public static void shouldInitManagerSummaryTemplateRuleSyncForUSCaliforniaDistribution() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);
        
        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.MANAGER_SUMMARY};
        MA_DS_TestUtil_ApplyRules.deleteInUseTemplatesExcept(acqUSPackage.Id, maTemplates, true);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_PackageDistributions.generateRules(new List<MA_DS_Package_Distribution__c> {pkgDistribution}, true);
        MA_DS_TestUtil_PkgDistributionTrigger.updateRulesSyncStatus(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.SYNCING_TEMPLATE_RULES, true);

        MA_DS_TestUtil_AppliedRules.setupAppliedRules(acqCompany.Id, new List<MA_DS_Package_Distribution__c> {pkgDistribution});

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_ApplyRules.initTemplateAppliedRuleSyncJob(acqCompany.Id, pkgDistribution.MA_DS_Package__c, pkgDistribution.Id);
        }
        Test.stopTest();

        Integer expectedRuleCount = MA_DS_TestUtil_ApplyRules.getExpectedAcqContactCountForSummaryTemplateInUSCalDistribution(acqCompany.Id);
        Assert.areEqual(expectedRuleCount, MA_DS_TestUtil_ApplyRules.getInUseTemplateTypeAppliedRuleCount(pkgDistribution.Id, maTemplates), ASSERT_MSG_SUMMARY_IUT_TYPE_RULE_COUNT);
    }

    @isTest
    public static void shouldInitOfferLetterTemplateRuleSyncForUSCaliforniaDistribution() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);
        
        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.US_OFFER_LETTER};
        MA_DS_TestUtil_ApplyRules.deleteInUseTemplatesExcept(acqUSPackage.Id, maTemplates, true);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_PackageDistributions.generateRules(new List<MA_DS_Package_Distribution__c> {pkgDistribution}, true);
        MA_DS_TestUtil_PkgDistributionTrigger.updateRulesSyncStatus(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.SYNCING_TEMPLATE_RULES, true);

        MA_DS_TestUtil_AppliedRules.setupAppliedRules(acqCompany.Id, new List<MA_DS_Package_Distribution__c> {pkgDistribution});

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_ApplyRules.initTemplateAppliedRuleSyncJob(acqCompany.Id, pkgDistribution.MA_DS_Package__c, pkgDistribution.Id);
        }
        Test.stopTest();

        Integer expectedRuleCount = MA_DS_TestUtil_ApplyRules.getExpectedAcqContactCountForUSOfferLetterTemplateInUSCalDistribution(acqCompany.Id);
        Assert.areEqual(expectedRuleCount, MA_DS_TestUtil_ApplyRules.getInUseTemplateTypeAppliedRuleCount(pkgDistribution.Id, maTemplates), ASSERT_MSG_US_OFFER_LETTER_IUT_TYPE_RULE_COUNT);
    }

    @isTest
    public static void shouldInitManagerSummaryTemplateRuleSyncForUSKeyEmpDistribution() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);
        
        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.MANAGER_SUMMARY};
        MA_DS_TestUtil_ApplyRules.deleteInUseTemplatesExcept(acqUSPackage.Id, maTemplates, true);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_KEY_EMP, acqUSPackage);
        MA_DS_TestUtil_PackageDistributions.generateRules(new List<MA_DS_Package_Distribution__c> {pkgDistribution}, true);
        MA_DS_TestUtil_PkgDistributionTrigger.updateRulesSyncStatus(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.SYNCING_TEMPLATE_RULES, true);

        MA_DS_TestUtil_AppliedRules.setupAppliedRules(acqCompany.Id, new List<MA_DS_Package_Distribution__c> {pkgDistribution});

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_ApplyRules.initTemplateAppliedRuleSyncJob(acqCompany.Id, pkgDistribution.MA_DS_Package__c, pkgDistribution.Id);
        }
        Test.stopTest();

        Integer expectedRuleCount = MA_DS_TestUtil_ApplyRules.getExpectedAcqContactCountForSummaryTemplateInUSKeyEmpDistribution(acqCompany.Id);
        Assert.areEqual(expectedRuleCount, MA_DS_TestUtil_ApplyRules.getInUseTemplateTypeAppliedRuleCount(pkgDistribution.Id, maTemplates), ASSERT_MSG_SUMMARY_IUT_TYPE_RULE_COUNT);
    }

    @isTest
    public static void shouldInitManagerSummaryTemplateRuleSyncWithAuditAllForUSKeyEmpDistribution() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);
        
        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.MANAGER_SUMMARY};
        MA_DS_TestUtil_ApplyRules.deleteInUseTemplatesExcept(acqUSPackage.Id, maTemplates, true);
        MA_DS_TestUtil_ApplyRules.updateInUseTemplatesWithAuditAll(acqUSPackage.Id, maTemplates, true);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_KEY_EMP, acqUSPackage);
        MA_DS_TestUtil_PackageDistributions.generateRules(new List<MA_DS_Package_Distribution__c> {pkgDistribution}, true);
        MA_DS_TestUtil_PkgDistributionTrigger.updateRulesSyncStatus(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.SYNCING_TEMPLATE_RULES, true);

        MA_DS_TestUtil_AppliedRules.setupAppliedRules(acqCompany.Id, new List<MA_DS_Package_Distribution__c> {pkgDistribution});

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_ApplyRules.initTemplateAppliedRuleSyncJob(acqCompany.Id, pkgDistribution.MA_DS_Package__c, pkgDistribution.Id);
        }
        Test.stopTest();

        Integer expectedRuleCount = MA_DS_TestUtil_ApplyRules.getExpectedAcqContactCountForSummaryTemplateInUSKeyEmpDistribution(acqCompany.Id);
        Assert.areEqual(expectedRuleCount, MA_DS_TestUtil_ApplyRules.getInUseTemplateTypeAppliedRuleCountWithFlaggedForAudit(pkgDistribution.Id, maTemplates), ASSERT_MSG_SUMMARY_IUT_TYPE_RULE_COUNT);
    }

    @isTest
    public static void shouldInitTemplateRuleSyncForUSKeyEmpDistribution() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);
        
        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.PIIA_CAL, MA_DS_TestUtil_Templates.Template.MANAGER_SUMMARY};
        MA_DS_TestUtil_ApplyRules.deleteInUseTemplatesExcept(acqUSPackage.Id, maTemplates, true);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_KEY_EMP, acqUSPackage);
        MA_DS_TestUtil_PackageDistributions.generateRules(new List<MA_DS_Package_Distribution__c> {pkgDistribution}, true);
        MA_DS_TestUtil_PkgDistributionTrigger.updateRulesSyncStatus(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.SYNCING_TEMPLATE_RULES, true);

        MA_DS_TestUtil_AppliedRules.setupAppliedRules(acqCompany.Id, new List<MA_DS_Package_Distribution__c> {pkgDistribution});

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_ApplyRules.initTemplateAppliedRuleSyncJob(acqCompany.Id, pkgDistribution.MA_DS_Package__c, pkgDistribution.Id);
        }
        Test.stopTest();

        Integer expectedSummaryTemplateRuleCount = MA_DS_TestUtil_ApplyRules.getExpectedAcqContactCountForSummaryTemplateInUSKeyEmpDistribution(acqCompany.Id);
        Integer expectedPIIACalTemplateRuleCount = MA_DS_TestUtil_ApplyRules.getExpectedAcqContactCountForPIIACalTemplateInUSKeyEmpDistribution(acqCompany.Id);
        Integer actualIUTRuleCount = MA_DS_TestUtil_ApplyRules.getInUseTemplateTypeAppliedRuleCount(pkgDistribution.Id, maTemplates);
        Boolean assertRuleCount = (actualIUTRuleCount == expectedSummaryTemplateRuleCount || actualIUTRuleCount == expectedPIIACalTemplateRuleCount);
        Assert.isTrue(assertRuleCount, ASSERT_MSG_IUT_TYPE_RULE_COUNT);
    }

    @isTest
    public static void shouldInitPIIACalTemplateRuleSyncForUSKeyEmpDistribution() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);

        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.PIIA_CAL};
        MA_DS_TestUtil_ApplyRules.deleteInUseTemplatesExcept(acqUSPackage.Id, maTemplates, true);
        
        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_KEY_EMP, acqUSPackage);
        MA_DS_TestUtil_PackageDistributions.generateRules(new List<MA_DS_Package_Distribution__c> {pkgDistribution}, true);
        MA_DS_TestUtil_PkgDistributionTrigger.updateDistributionAndRulesSyncStatus(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.SUMMARY_AUDIT_COMPLETE, MA_DS_TestUtil_PkgDistributionTrigger.NEED_SYNC_PACKAGE_TEMPLATE_RULES, true);

        MA_DS_TestUtil_AppliedRules.setupAppliedRules(acqCompany.Id, new List<MA_DS_Package_Distribution__c> {pkgDistribution});
        MA_DS_TestUtil_ApplyRules.updateInUseTemplateWithSyncRulesOnPDIds(acqUSPackage.Id, pkgDistribution.Id, maTemplates, true);

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_ApplyRules.applyRules(pkgDistribution.Id);
        }
        Test.stopTest();

        Integer expectedRuleCount = MA_DS_TestUtil_ApplyRules.getExpectedAcqContactCountForPIIACalTemplateInUSKeyEmpDistribution(acqCompany.Id);
        Assert.areEqual(expectedRuleCount, MA_DS_TestUtil_ApplyRules.getInUseTemplateTypeAppliedRuleCount(pkgDistribution.Id, maTemplates), ASSERT_MSG_PIIA_CAL_IUT_TYPE_RULE_COUNT);
    }

    @isTest
    public static void shouldInitUSHippaNoticeTemplateRuleSyncForUSKeyEmpDistribution() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);

        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.US_HIPAA_NOTICE};
        MA_DS_TestUtil_ApplyRules.deleteInUseTemplatesExcept(acqUSPackage.Id, maTemplates, true);
        
        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_KEY_EMP, acqUSPackage);
        MA_DS_TestUtil_PackageDistributions.generateRules(new List<MA_DS_Package_Distribution__c> {pkgDistribution}, true);
        MA_DS_TestUtil_PkgDistributionTrigger.updateRulesSyncStatus(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.NEED_SYNC_TEMPLATE_RULES, true);

        MA_DS_TestUtil_AppliedRules.setupAppliedRules(acqCompany.Id, new List<MA_DS_Package_Distribution__c> {pkgDistribution});
        MA_DS_TestUtil_ApplyRules.updateInUseTemplateWithSyncRulesOnPDIds(acqUSPackage.Id, pkgDistribution.Id, maTemplates, true);

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_ApplyRules.applyRules(pkgDistribution.Id);
        }
        Test.stopTest();

        Integer expectedRuleCount = MA_DS_TestUtil_ApplyRules.getExpectedAcqContactCountForUSHippaNoticeTemplateInUSKeyEmpDistribution(acqCompany.Id);
        Assert.areEqual(expectedRuleCount, MA_DS_TestUtil_ApplyRules.getInUseTemplateTypeAppliedRuleCount(pkgDistribution.Id, maTemplates), ASSERT_MSG_US_HIPPA_NOTICE_IUT_TYPE_RULE_COUNT);
    }

    @isTest
    public static void shouldInitGLRSULetterTemplateRuleSyncForUSKeyEmpDistribution() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);

        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.GL_RSU_LETTER};
        MA_DS_TestUtil_ApplyRules.deleteInUseTemplatesExcept(acqUSPackage.Id, maTemplates, true);
        
        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_KEY_EMP, acqUSPackage);
        MA_DS_TestUtil_PackageDistributions.generateRules(new List<MA_DS_Package_Distribution__c> {pkgDistribution}, true);
        MA_DS_TestUtil_PkgDistributionTrigger.updateRulesSyncStatus(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.NEED_SYNC_TEMPLATE_RULES, true);

        MA_DS_TestUtil_AppliedRules.setupAppliedRules(acqCompany.Id, new List<MA_DS_Package_Distribution__c> {pkgDistribution});
        MA_DS_TestUtil_ApplyRules.updateInUseTemplateWithSyncRulesOnPDIdsAndAppliedAuditFlagsJSON(acqUSPackage.Id, pkgDistribution.Id, maTemplates, true);

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_ApplyRules.applyRules(pkgDistribution.Id);
        }
        Test.stopTest();

        Integer expectedRuleCount = MA_DS_TestUtil_ApplyRules.getExpectedAcqContactCountForGlRSUTemplateInUSKeyEmpDistribution(acqCompany.Id);
        Assert.areEqual(expectedRuleCount, MA_DS_TestUtil_ApplyRules.getInUseTemplateTypeAppliedRuleCount(pkgDistribution.Id, maTemplates), ASSERT_MSG_GL_RSU_IUT_TYPE_RULE_COUNT);
    }

    @isTest
    public static void shouldLogQueryExceptionForTemplateRuleSyncInvalidAppliedRuleQueryString() {
        String queryString = MA_DS_TestUtil_ApplyRules.getInvalidAppliedRuleQueryStringToCauseQueryException();

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_TemplateAppliedRuleSyncUtility.getAppliedRules(queryString, new Map<String, Object>());
        }
        Test.stopTest();

        Assert.isTrue([SELECT Id FROM PF_Debug_Log__c WHERE NH_Name__c = :MA_DS_TemplateAppliedRuleSyncUtility.class.getName()].size() > 0, ASSERT_MSG_APPLIED_RULE_QUERY_EXCEPTION);
    }

    @isTest
    public static void shouldLogQueryExceptionForPIIACalTemplateRuleSync() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);
        
        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.PIIA_CAL};
        MA_DS_TestUtil_ApplyRules.deleteInUseTemplatesExcept(acqUSPackage.Id, maTemplates, true);
        MA_DS_TestUtil_ApplyRules.updateInUseTemplatesToLogQueryExceptionForTemplateRuleSync(acqUSPackage.Id, maTemplates, true);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_KEY_EMP, acqUSPackage);
        MA_DS_TestUtil_PackageDistributions.generateRules(new List<MA_DS_Package_Distribution__c> {pkgDistribution}, true);
        MA_DS_TestUtil_PkgDistributionTrigger.updateRulesSyncStatus(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.SYNCING_TEMPLATE_RULES, true);

        MA_DS_TestUtil_AppliedRules.setupAppliedRules(acqCompany.Id, new List<MA_DS_Package_Distribution__c> {pkgDistribution});
        
        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_ApplyRules.initTemplateAppliedRuleSyncJob(acqCompany.Id, pkgDistribution.MA_DS_Package__c, pkgDistribution.Id);
        }
        Test.stopTest();

        Assert.isTrue([SELECT Id FROM PF_Debug_Log__c WHERE NH_Name__c = :MA_DS_TemplateAppliedRuleSyncUtility.class.getName()].size() > 0, ASSERT_MSG_IUT_RULE_SYNC_QUERY_EXCEPTION);
    }

    @isTest
    public static void shouldInitPurgeRuleSyncForUSCaliforniaDistribution() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);
        
        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.MANAGER_SUMMARY, MA_DS_TestUtil_Templates.Template.GL_OBA_FORM};
        MA_DS_TestUtil_ApplyRules.deleteInUseTemplatesExcept(acqUSPackage.Id, maTemplates, true);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_PkgDistributionTrigger.updateRulesSyncStatus(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.SYNCING_TEMPLATE_RULES, true);

        List<MA_DS_In_Use_Template__c> inUseTemplates = MA_DS_TestUtil_ApplyRules.getInUseTemplates(acqUSPackage.Id, maTemplates);

        MA_DS_TestUtil_AppliedRules.setupAppliedRules(acqCompany.Id, new List<MA_DS_Package_Distribution__c> {pkgDistribution}, inUseTemplates, false, false, true, false, MA_DS_TestUtil_AppliedRules.PURGED_PD_RULE_ASYNC_APEX_ID, MA_DS_TestUtil_AppliedRules.PURGED_IUT_RULE_ASYNC_APEX_ID);
        Integer expectedPurgeRuleCount = MA_DS_TestUtil_ApplyRules.getExpectedAppliedRuleCountForPurgeRuleSync(pkgDistribution.Id, new Set<Id> {MA_DS_TestUtil_AppliedRules.PURGED_PD_RULE_ASYNC_APEX_ID, MA_DS_TestUtil_AppliedRules.PURGED_IUT_RULE_ASYNC_APEX_ID});

        MA_DS_TestUtil_ApplyRules.updateDistributionWrapperWithState(pkgDistribution, MA_DS_TestUtil_ApplyRules.STATE_WASHINGTON);
        MA_DS_TestUtil_PackageDistributions.generateRules(new List<MA_DS_Package_Distribution__c> {pkgDistribution}, true);

        MA_DS_TestUtil_AppliedRules.setupAppliedRules(acqCompany.Id, new List<MA_DS_Package_Distribution__c> {pkgDistribution}, inUseTemplates, false, false, true, false);
        Integer ruleCountBeforePurge = MA_DS_TestUtil_ApplyRules.getAppliedRuleCountForPackageDistribution(pkgDistribution.Id);

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_ApplyRules.initPurgeAppliedRuleSyncJob(pkgDistribution.Id, inUseTemplates, MA_DS_AppliedRulesService.ExecutionJob.PACKAGE_RULE_SYNC, true, true);
        }
        Test.stopTest();

        Integer ruleCountAfterPurge = MA_DS_TestUtil_ApplyRules.getAppliedRuleCountForPackageDistribution(pkgDistribution.Id);
        Assert.areEqual(ruleCountBeforePurge - expectedPurgeRuleCount, ruleCountAfterPurge, ASSERT_MSG_US_CALIFORNIA_PURGE_RULE_COUNT);
    }

    @isTest
    public static void shouldInitPurgeRuleSyncForUSWashingtonDistribution() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);
        
        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.MANAGER_SUMMARY, MA_DS_TestUtil_Templates.Template.GL_OBA_FORM, MA_DS_TestUtil_Templates.Template.GL_COC};
        MA_DS_TestUtil_ApplyRules.deleteInUseTemplatesExcept(acqUSPackage.Id, maTemplates, true);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_WASHINGTON, acqUSPackage);
        MA_DS_TestUtil_PkgDistributionTrigger.updateRulesSyncStatus(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.SYNCING_TEMPLATE_RULES, true);

        List<MA_DS_In_Use_Template__c> inUseTemplates = MA_DS_TestUtil_ApplyRules.getInUseTemplates(acqUSPackage.Id, maTemplates);

        MA_DS_TestUtil_AppliedRules.setupAppliedRules(acqCompany.Id, new List<MA_DS_Package_Distribution__c> {pkgDistribution}, inUseTemplates, false, false, true, false, MA_DS_TestUtil_AppliedRules.PURGED_PD_RULE_ASYNC_APEX_ID, MA_DS_TestUtil_AppliedRules.PURGED_IUT_RULE_ASYNC_APEX_ID);
        Integer expectedPurgeRuleCount = MA_DS_TestUtil_ApplyRules.getExpectedAppliedRuleCountForPurgeRuleSync(pkgDistribution.Id, new Set<Id> {MA_DS_TestUtil_AppliedRules.PURGED_PD_RULE_ASYNC_APEX_ID, MA_DS_TestUtil_AppliedRules.PURGED_IUT_RULE_ASYNC_APEX_ID});

        MA_DS_TestUtil_ApplyRules.updateDistributionWrapperWithState(pkgDistribution, MA_DS_TestUtil_ApplyRules.STATE_CALIFORNIA);
        MA_DS_TestUtil_PackageDistributions.generateRules(new List<MA_DS_Package_Distribution__c> {pkgDistribution}, true);

        MA_DS_TestUtil_AppliedRules.setupAppliedRules(acqCompany.Id, new List<MA_DS_Package_Distribution__c> {pkgDistribution}, inUseTemplates, false, false, true, false);
        Integer ruleCountBeforePurge = MA_DS_TestUtil_ApplyRules.getAppliedRuleCountForPackageDistribution(pkgDistribution.Id);

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_ApplyRules.initPurgeAppliedRuleSyncJob(pkgDistribution.Id, inUseTemplates, MA_DS_AppliedRulesService.ExecutionJob.PACKAGE_RULE_SYNC, true, false);
        }
        Test.stopTest();

        Integer ruleCountAfterPurge = MA_DS_TestUtil_ApplyRules.getAppliedRuleCountForPackageDistribution(pkgDistribution.Id);
        Assert.areEqual(ruleCountBeforePurge - expectedPurgeRuleCount, ruleCountAfterPurge, ASSERT_MSG_US_WASHINGTON_PURGE_RULE_COUNT);
    }

    @isTest
    public static void shouldLogQueryExceptionForPurgeRuleSyncInvalidAppliedRuleQueryString() {
        String queryString = MA_DS_TestUtil_ApplyRules.getInvalidAppliedRuleQueryStringToCauseQueryException();

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_PurgeAppliedRuleSyncUtility.getPurgedAppliedRules(queryString, new Map<String, Object>());
        }
        Test.stopTest();

        Assert.isTrue([SELECT Id FROM PF_Debug_Log__c WHERE NH_Name__c = :MA_DS_PurgeAppliedRuleSyncUtility.class.getName()].size() > 0, ASSERT_MSG_APPLIED_RULE_QUERY_EXCEPTION);
    }

    @isTest
    public static void shouldInitRuleAppliedSyncForUSCaliforniaDistribution() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);
        
        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.PIIA_CAL, MA_DS_TestUtil_Templates.Template.MANAGER_SUMMARY};
        MA_DS_TestUtil_ApplyRules.deleteInUseTemplatesExcept(acqUSPackage.Id, maTemplates, true);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_PackageDistributions.generateRules(new List<MA_DS_Package_Distribution__c> {pkgDistribution}, true);
        MA_DS_TestUtil_PkgDistributionTrigger.updateRulesSyncStatus(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.SYNCING_TEMPLATE_RULES, true);

        List<MA_DS_In_Use_Template__c> inUseTemplates = MA_DS_TestUtil_ApplyRules.getInUseTemplates(acqUSPackage.Id, maTemplates);
        MA_DS_TestUtil_AppliedRules.setupAppliedRules(acqCompany.Id, new List<MA_DS_Package_Distribution__c> {pkgDistribution}, inUseTemplates, false, false, true, false);

        Integer expectedPackageRuleCount = MA_DS_TestUtil_ApplyRules.getExpectedRuleAppliedCount(pkgDistribution.Id, new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.PIIA_CAL});
        Integer expectedSummaryRuleCount = MA_DS_TestUtil_ApplyRules.getExpectedRuleAppliedCount(pkgDistribution.Id, new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.MANAGER_SUMMARY});

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_ApplyRules.initRuleAppliedSyncJob(pkgDistribution.Id, MA_DS_AppliedRulesService.ExecutionJob.PACKAGE_RULE_SYNC, true, true);
        }
        Test.stopTest();

        Integer summaryRuleAppliedCount = MA_DS_TestUtil_ApplyRules.getAppliedRuleCountWithSummaryRuleApplied(pkgDistribution.Id);
        Integer packageRuleAppliedCount = MA_DS_TestUtil_ApplyRules.getAppliedRuleCountWithPackageRuleApplied(pkgDistribution.Id);

        Assert.areEqual(expectedSummaryRuleCount, summaryRuleAppliedCount, ASSERT_MSG_SUMMARY_RULE_APPLIED_COUNT);
        Assert.areEqual(expectedPackageRuleCount, packageRuleAppliedCount, ASSERT_MSG_PACKAGE_RULE_APPLIED_COUNT);
    }

    @isTest
    public static void shouldInitRuleAppliedSyncForUSWashingtonDistribution() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);
        
        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.MANAGER_SUMMARY};
        MA_DS_TestUtil_ApplyRules.deleteInUseTemplatesExcept(acqUSPackage.Id, maTemplates, true);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_WASHINGTON, acqUSPackage);
        MA_DS_TestUtil_PackageDistributions.generateRules(new List<MA_DS_Package_Distribution__c> {pkgDistribution}, true);
        MA_DS_TestUtil_PkgDistributionTrigger.updateRulesSyncStatus(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.SYNCING_TEMPLATE_RULES, true);

        List<MA_DS_In_Use_Template__c> inUseTemplates = MA_DS_TestUtil_ApplyRules.getInUseTemplates(acqUSPackage.Id, maTemplates);
        MA_DS_TestUtil_AppliedRules.setupAppliedRules(acqCompany.Id, new List<MA_DS_Package_Distribution__c> {pkgDistribution}, inUseTemplates, false, false, true, false);

        MA_DS_AppliedRulesWrapper.RULE_APPLIED_QUERY_SIZE_LIMIT = 10;
        Integer expectedSummaryRuleCount = MA_DS_TestUtil_ApplyRules.getExpectedRuleAppliedCount(pkgDistribution.Id, new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.MANAGER_SUMMARY});

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_ApplyRules.initRuleAppliedSyncJob(pkgDistribution.Id, MA_DS_AppliedRulesService.ExecutionJob.TEMPLATE_RULE_SYNC, false, true);
        }
        Test.stopTest();

        Integer summaryRuleAppliedCount = MA_DS_TestUtil_ApplyRules.getAppliedRuleCountWithSummaryRuleApplied(pkgDistribution.Id);
        Integer packageRuleAppliedCount = MA_DS_TestUtil_ApplyRules.getAppliedRuleCountWithPackageRuleApplied(pkgDistribution.Id);

        Assert.areEqual(expectedSummaryRuleCount, summaryRuleAppliedCount, ASSERT_MSG_SUMMARY_RULE_APPLIED_COUNT);
        Assert.areEqual(0, packageRuleAppliedCount, ASSERT_MSG_PACKAGE_RULE_APPLIED_COUNT);
    }

    @isTest
    public static void shouldInitRuleAppliedSyncForUSKeyEmpDistribution() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);
        
        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.US_OFFER_LETTER};
        MA_DS_TestUtil_ApplyRules.deleteInUseTemplatesExcept(acqUSPackage.Id, maTemplates, true);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_KEY_EMP, acqUSPackage);
        MA_DS_TestUtil_PackageDistributions.generateRules(new List<MA_DS_Package_Distribution__c> {pkgDistribution}, true);
        MA_DS_TestUtil_PkgDistributionTrigger.updateRulesSyncStatus(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.SYNCING_TEMPLATE_RULES, true);

        List<MA_DS_In_Use_Template__c> inUseTemplates = MA_DS_TestUtil_ApplyRules.getInUseTemplates(acqUSPackage.Id, maTemplates);
        MA_DS_TestUtil_AppliedRules.setupAppliedRules(acqCompany.Id, new List<MA_DS_Package_Distribution__c> {pkgDistribution}, inUseTemplates, false, false, true, false);

        Integer expectedPackageRuleCount = MA_DS_TestUtil_ApplyRules.getExpectedRuleAppliedCount(pkgDistribution.Id, new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.US_OFFER_LETTER});
        
        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_ApplyRules.initRuleAppliedSyncJob(pkgDistribution.Id, MA_DS_AppliedRulesService.ExecutionJob.TEMPLATE_RULE_SYNC, false, true);
        }
        Test.stopTest();

        Integer summaryRuleAppliedCount = MA_DS_TestUtil_ApplyRules.getAppliedRuleCountWithSummaryRuleApplied(pkgDistribution.Id);
        Integer packageRuleAppliedCount = MA_DS_TestUtil_ApplyRules.getAppliedRuleCountWithPackageRuleApplied(pkgDistribution.Id);

        Assert.areEqual(0, summaryRuleAppliedCount, ASSERT_MSG_SUMMARY_RULE_APPLIED_COUNT);
        Assert.areEqual(expectedPackageRuleCount, packageRuleAppliedCount, ASSERT_MSG_PACKAGE_RULE_APPLIED_COUNT);
    }

    @isTest
    public static void shouldLogQueryExceptionForRuleAppliedSyncInvalidAppliedRuleQueryString() {
        String queryString = MA_DS_TestUtil_ApplyRules.getInvalidAppliedRuleQueryStringToCauseQueryException();

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_RuleAppliedSyncUtility.getAggregatedAppliedRules(queryString, new Map<String, Object>());
        }
        Test.stopTest();

        Assert.isTrue([SELECT Id FROM PF_Debug_Log__c WHERE NH_Name__c = :MA_DS_RuleAppliedSyncUtility.class.getName()].size() > 0, ASSERT_MSG_APPLIED_RULE_QUERY_EXCEPTION);
    }

    @isTest
    public static void shouldCoverEmptyVirtualMethodsOfAbstractFormatter() {
        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.SYSTEM_ADMIN_USER, TEST_IDENTIFIER)) {
            TestAbstractFormatter formatter = new TestAbstractFormatter();
            formatter.getAppliedAuditFlagKey(null, null);
            formatter.getDeserializedFieldValue(null);
            formatter.getFormattedCriteria(null, null, null, null, null);
        }
        Test.stopTest();
    }

    @isTest
    public static void shouldCoverEmptyVirtualMethodsOfAbstractAppliedRuleSyncService() {
        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.SYSTEM_ADMIN_USER, TEST_IDENTIFIER)) {
            TestAppliedRuleSyncService syncService = new TestAppliedRuleSyncService();
            syncService.initAppliedRuleJob(null, null, null, null);
            syncService.initAppliedRuleJob(null, null, null, null, new Set<Id>());
            syncService.initAppliedRuleJob(null, false, false, null, null);
            syncService.initAppliedRuleJob(null, false, false, null, null, null, null);
        }
        Test.stopTest();
    }

    private class TestAbstractFormatter extends MA_DS_RulesCriteriaQueryFormatter.AbstractFormatter {
        public override String getAppliedAuditFlagKey(String concatenatedKey, Object value) {
            return super.getAppliedAuditFlagKey(concatenatedKey, value);
        }

        public override Object getDeserializedFieldValue(Object value) {
            return null;
        }

        public override String getFormattedCriteria(String field, String criteriaOperator, String queryOperator, String value, String fieldType) {
            return null;
        }
    }

    private class TestAppliedRuleSyncService extends MA_DS_AppliedRulesService.AppliedRuleSyncService {
        public override void initAppliedRuleJob(Id acqCompanyId, Id pkgId, Id pkgDistributionId, ExecutionMode originExecMode) {
            super.initAppliedRuleJob(acqCompanyId, pkgId, pkgDistributionId, originExecMode);
        }

        public override void initAppliedRuleJob(Id acqCompanyId, Id pkgId, Id pkgDistributionId, ExecutionMode originExecMode, Set<Id> asyncApexJobIds) {
            super.initAppliedRuleJob(acqCompanyId, pkgId, pkgDistributionId, originExecMode, asyncApexJobIds);
        }

        public override void initAppliedRuleJob(Id pkgDistributionId, Boolean summaryDocRuleSync, Boolean packageDocRuleSync, ExecutionJob originExecJob, ExecutionMode originExecMode) {
            super.initAppliedRuleJob(pkgDistributionId, summaryDocRuleSync, packageDocRuleSync, originExecJob, originExecMode);
        }

        public override void initAppliedRuleJob(Id pkgDistributionId, Boolean summaryDocRuleSync, Boolean packageDocRuleSync, ExecutionJob originExecJob, ExecutionMode originExecMode, Set<Id> asyncApexJobIds, List<Id> templateIds) {
            super.initAppliedRuleJob(pkgDistributionId, summaryDocRuleSync, packageDocRuleSync, originExecJob, originExecMode, asyncApexJobIds, templateIds);
        }
    }
}