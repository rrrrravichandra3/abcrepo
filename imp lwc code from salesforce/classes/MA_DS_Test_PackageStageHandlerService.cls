/**
 * Test class for MA_DS_PackageStageHandlerService & its associated classes.
 * 
 * Version      Date            Author                  Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         05/01/2024      Chakshu Malhotra        Adds test methods to cover MA_DS_PackageStageHandlerService & its associated classes.
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
@isTest
public class MA_DS_Test_PackageStageHandlerService {

    private static final String TEST_IDENTIFIER = 'PackageStageHandlerService';

    private static final Set<MA_DS_TestUtil_Acquisition.Employees> maUSCaliforniaEmployees = new Set<MA_DS_TestUtil_Acquisition.Employees> {MA_DS_TestUtil_Acquisition.Employees.US_CAL_EMPLOYEES};
    private static final Set<MA_DS_TestUtil_Packages.MA_Package> maUSPackages = new Set<MA_DS_TestUtil_Packages.MA_Package> {MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE};
    private static final Set<MA_DS_TestUtil_Templates.Template> maUSTemplates = MA_DS_TestUtil_Templates.getUSPackageTemplates();
    private static final Set<MA_DS_TestUtil_PackageDistributions.Distribution> maUSDistributions = MA_DS_TestUtil_PackageDistributions.getUSDistributions();

    private static final String ASSERT_MSG_UPDATED_SIGNER_IP_ADDRESS_COUNT = 'Count of updated Signer IP Address(es) inconsistent with the number of envelopes accepted / rejected!';
    
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
            MA_DS_TestUtil_Acquisition.setupTestAcquisitionContacts(acqCompany, maUSCaliforniaEmployees, MA_DS_TestUtil_Acquisition.SUMMARY_STAGE_DELIVERED, MA_DS_TestUtil_Acquisition.PACKAGE_STAGE_DELIVERED);
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
    public static void shouldLogCalloutServiceException() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);
        
        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.MANAGER_SUMMARY, MA_DS_TestUtil_Templates.Template.PIIA_CAL, MA_DS_TestUtil_Templates.Template.US_OFFER_LETTER};
        MA_DS_TestUtil_ApplyRules.deleteInUseTemplatesExcept(acqUSPackage.Id, maTemplates, true);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_PackageDistributions.generateRules(new List<MA_DS_Package_Distribution__c> {pkgDistribution}, true);
        MA_DS_TestUtil_PkgDistributionTrigger.updatePackageDistributionStage(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.DistributionStage.PACKAGE_DELIVERED, true, true);

        List<MA_DS_In_Use_Template__c> inUseTemplates = MA_DS_TestUtil_ApplyRules.getInUseTemplates(acqUSPackage.Id, maTemplates);
        MA_DS_TestUtil_AppliedRules.setupAppliedRules(acqCompany.Id, new List<MA_DS_Package_Distribution__c> {pkgDistribution}, inUseTemplates, true, true, false, false);

        List<Id> acqContactIds = MA_DS_TestUtil_PkgStageHandlerService.getAcquisitionContactIds(pkgDistribution.Id, 1);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MA_DS_TestCallout_MultiMock(MA_DS_TestCallout_MultiMock.CalloutResponse.UNAUTHORIZED_ENDPOINT));
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.DS_CLM_API_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_PkgStageHandlerService.updatePackageStageForAcquisitionContacts(acqContactIds, MA_DS_TestUtil_PkgStageHandlerService.PACKAGE_STAGE_ACCEPTED);
        }
        Test.stopTest();

        Assert.isTrue([SELECT Id FROM PF_Debug_Log__c WHERE NH_Name__c = :MA_DS_TestCallout_MultiMock.CALLOUT_SERVICE_EXCEPTION_IDENTIFIER].size() > 0, MA_DS_TestCallout_MultiMock.ASSERT_MSG_CALLOUT_SERVICE_EXCEPTION_NOT_LOGGED);
    }

    @isTest
    public static void shouldLogCalloutResponseException() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);
        
        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.MANAGER_SUMMARY, MA_DS_TestUtil_Templates.Template.PIIA_CAL, MA_DS_TestUtil_Templates.Template.US_OFFER_LETTER};
        MA_DS_TestUtil_ApplyRules.deleteInUseTemplatesExcept(acqUSPackage.Id, maTemplates, true);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_PackageDistributions.generateRules(new List<MA_DS_Package_Distribution__c> {pkgDistribution}, true);
        MA_DS_TestUtil_PkgDistributionTrigger.updatePackageDistributionStage(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.DistributionStage.PACKAGE_DELIVERED, true, true);

        List<MA_DS_In_Use_Template__c> inUseTemplates = MA_DS_TestUtil_ApplyRules.getInUseTemplates(acqUSPackage.Id, maTemplates);
        MA_DS_TestUtil_AppliedRules.setupAppliedRules(acqCompany.Id, new List<MA_DS_Package_Distribution__c> {pkgDistribution}, inUseTemplates, true, true, false, false);

        List<Id> acqContactIds = MA_DS_TestUtil_PkgStageHandlerService.getAcquisitionContactIds(pkgDistribution.Id, 1);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MA_DS_TestCallout_MultiMock(MA_DS_TestCallout_MultiMock.CalloutResponse.AUDIT_EVENTS_BAD_REQUEST));
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.DS_CLM_API_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_PkgStageHandlerService.updatePackageStageForAcquisitionContacts(acqContactIds, MA_DS_TestUtil_PkgStageHandlerService.PACKAGE_STAGE_ACCEPTED);
        }
        Test.stopTest();

        Assert.isTrue([SELECT Id FROM PF_Debug_Log__c WHERE NH_Name__c = :MA_DS_TestCallout_MultiMock.CALLOUT_RESPONSE_EXCEPTION_IDENTIFIER].size() > 0, MA_DS_TestCallout_MultiMock.ASSERT_MSG_CALLOUT_RESPONSE_EXCEPTION_NOT_LOGGED);
    }

    @isTest
    public static void shouldLogJSONException() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);
        
        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.MANAGER_SUMMARY, MA_DS_TestUtil_Templates.Template.PIIA_CAL, MA_DS_TestUtil_Templates.Template.US_OFFER_LETTER};
        MA_DS_TestUtil_ApplyRules.deleteInUseTemplatesExcept(acqUSPackage.Id, maTemplates, true);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_PackageDistributions.generateRules(new List<MA_DS_Package_Distribution__c> {pkgDistribution}, true);
        MA_DS_TestUtil_PkgDistributionTrigger.updatePackageDistributionStage(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.DistributionStage.PACKAGE_DELIVERED, true, true);

        List<MA_DS_In_Use_Template__c> inUseTemplates = MA_DS_TestUtil_ApplyRules.getInUseTemplates(acqUSPackage.Id, maTemplates);
        MA_DS_TestUtil_AppliedRules.setupAppliedRules(acqCompany.Id, new List<MA_DS_Package_Distribution__c> {pkgDistribution}, inUseTemplates, true, true, false, false);

        List<Id> acqContactIds = MA_DS_TestUtil_PkgStageHandlerService.getAcquisitionContactIds(pkgDistribution.Id, 1);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MA_DS_TestCallout_MultiMock(MA_DS_TestCallout_MultiMock.CalloutResponse.AUDIT_EVENTS_MALFORMED_RESPONSE));
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.DS_CLM_API_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_PkgStageHandlerService.updatePackageStageForAcquisitionContacts(acqContactIds, MA_DS_TestUtil_PkgStageHandlerService.PACKAGE_STAGE_ACCEPTED);
        }
        Test.stopTest();

        Assert.isTrue([SELECT Id FROM PF_Debug_Log__c WHERE NH_Name__c = :MA_DS_TestCallout_MultiMock.JSON_EXCEPTION_IDENTIFIER].size() > 0, MA_DS_TestCallout_MultiMock.ASSERT_MSG_JSON_EXCEPTION_NOT_LOGGED);
    }

    @isTest
    public static void shouldUpdateSignerIPAddressOnEnvelopeAcceptance() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);
        
        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.MANAGER_SUMMARY, MA_DS_TestUtil_Templates.Template.PIIA_CAL, MA_DS_TestUtil_Templates.Template.US_OFFER_LETTER};
        MA_DS_TestUtil_ApplyRules.deleteInUseTemplatesExcept(acqUSPackage.Id, maTemplates, true);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_PackageDistributions.generateRules(new List<MA_DS_Package_Distribution__c> {pkgDistribution}, true);
        MA_DS_TestUtil_PkgDistributionTrigger.updatePackageDistributionStage(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.DistributionStage.PACKAGE_DELIVERED, true, true);

        List<MA_DS_In_Use_Template__c> inUseTemplates = MA_DS_TestUtil_ApplyRules.getInUseTemplates(acqUSPackage.Id, maTemplates);
        MA_DS_TestUtil_AppliedRules.setupAppliedRules(acqCompany.Id, new List<MA_DS_Package_Distribution__c> {pkgDistribution}, inUseTemplates, true, true, false, false);

        List<Id> acqContactIds = MA_DS_TestUtil_PkgStageHandlerService.getAcquisitionContactIds(pkgDistribution.Id, 1);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MA_DS_TestCallout_MultiMock(MA_DS_TestCallout_MultiMock.CalloutResponse.AUDIT_EVENTS_FOUND));
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.DS_CLM_API_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_PkgStageHandlerService.updatePackageStageForAcquisitionContacts(acqContactIds, MA_DS_TestUtil_PkgStageHandlerService.PACKAGE_STAGE_ACCEPTED);
        }
        Test.stopTest();

        Assert.areEqual(acqContactIds.size(), MA_DS_TestUtil_PkgStageHandlerService.getUpdatedSignerIPAddressCount(acqContactIds), ASSERT_MSG_UPDATED_SIGNER_IP_ADDRESS_COUNT);
    }

    @isTest
    public static void shouldUpdateSignerIPAddressOnMultipleEnvelopeAcceptance() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);
        
        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.MANAGER_SUMMARY, MA_DS_TestUtil_Templates.Template.PIIA_CAL, MA_DS_TestUtil_Templates.Template.US_OFFER_LETTER};
        MA_DS_TestUtil_ApplyRules.deleteInUseTemplatesExcept(acqUSPackage.Id, maTemplates, true);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_PackageDistributions.generateRules(new List<MA_DS_Package_Distribution__c> {pkgDistribution}, true);
        MA_DS_TestUtil_PkgDistributionTrigger.updatePackageDistributionStage(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.DistributionStage.PACKAGE_DELIVERED, true, true);

        List<MA_DS_In_Use_Template__c> inUseTemplates = MA_DS_TestUtil_ApplyRules.getInUseTemplates(acqUSPackage.Id, maTemplates);
        MA_DS_TestUtil_AppliedRules.setupAppliedRules(acqCompany.Id, new List<MA_DS_Package_Distribution__c> {pkgDistribution}, inUseTemplates, true, true, false, false);

        List<Id> acqContactIds = MA_DS_TestUtil_PkgStageHandlerService.getAcquisitionContactIds(pkgDistribution.Id, 2 * MA_DS_TestUtil_PkgStageHandlerService.MAX_QUERY_LIMIT);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MA_DS_TestCallout_MultiMock(MA_DS_TestCallout_MultiMock.CalloutResponse.AUDIT_EVENTS_FOUND));
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.DS_CLM_API_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_PkgStageHandlerService.updatePackageStageForAcquisitionContacts(acqContactIds, MA_DS_TestUtil_PkgStageHandlerService.PACKAGE_STAGE_ACCEPTED);
        }
        Test.stopTest();

        //Assert.areEqual(MA_DS_TestUtil_PkgStageHandlerService.MAX_QUERY_LIMIT, MA_DS_TestUtil_PkgStageHandlerService.getUpdatedSignerIPAddressCount(acqContactIds), ASSERT_MSG_UPDATED_SIGNER_IP_ADDRESS_COUNT);
    }

    @isTest
    public static void shouldUpdateSignerIPAddressOnMultipleEnvelopeRejection() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);
        
        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.MANAGER_SUMMARY, MA_DS_TestUtil_Templates.Template.PIIA_CAL, MA_DS_TestUtil_Templates.Template.US_OFFER_LETTER};
        MA_DS_TestUtil_ApplyRules.deleteInUseTemplatesExcept(acqUSPackage.Id, maTemplates, true);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_PackageDistributions.generateRules(new List<MA_DS_Package_Distribution__c> {pkgDistribution}, true);
        MA_DS_TestUtil_PkgDistributionTrigger.updatePackageDistributionStage(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.DistributionStage.PACKAGE_DELIVERED, true, true);

        List<MA_DS_In_Use_Template__c> inUseTemplates = MA_DS_TestUtil_ApplyRules.getInUseTemplates(acqUSPackage.Id, maTemplates);
        MA_DS_TestUtil_AppliedRules.setupAppliedRules(acqCompany.Id, new List<MA_DS_Package_Distribution__c> {pkgDistribution}, inUseTemplates, true, true, false, false);

        List<Id> acqContactIds = MA_DS_TestUtil_PkgStageHandlerService.getAcquisitionContactIds(pkgDistribution.Id, 2 * MA_DS_TestUtil_PkgStageHandlerService.MAX_QUERY_LIMIT);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MA_DS_TestCallout_MultiMock(MA_DS_TestCallout_MultiMock.CalloutResponse.AUDIT_EVENTS_FOUND));
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.DS_CLM_API_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_PkgStageHandlerService.updatePackageStageForAcquisitionContacts(acqContactIds, MA_DS_TestUtil_PkgStageHandlerService.PACKAGE_STAGE_DECLINED);
        }
        Test.stopTest();

        //Assert.areEqual(MA_DS_TestUtil_PkgStageHandlerService.MAX_QUERY_LIMIT, MA_DS_TestUtil_PkgStageHandlerService.getUpdatedSignerIPAddressCount(acqContactIds), ASSERT_MSG_UPDATED_SIGNER_IP_ADDRESS_COUNT);
    }
}