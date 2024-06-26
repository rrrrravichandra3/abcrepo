/**
 * Test class for MA_DS_PackageDistributionTrigger & its associated classes.
 * 
 * Version      Date            Author                  Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         13/12/2023      Chakshu Malhotra        Adds test methods to cover MA_DS_PackageDistributionTrigger & its associated classes.
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
@isTest
public class MA_DS_Test_PackageDistributionTrigger {
    
    private static final String TEST_IDENTIFIER = 'PackageDistributionTrigger';

    private static final String ASSERT_MSG_NEED_SYNC_RULES_SYNC_STATUS = 'Not an expected value for Rules Sync Status!';
    private static final String ASSERT_MSG_INELIGIBLE_DISTRIBUTION_STATUS_EXCEPTION = 'No DmlException while updating the Package Distribution; should not have updated due to ineligible Status of the Package Distribution!';
    private static final String ASSERT_MSG_INELIGIBLE_RULES_SYNC_STATUS_EXCEPTION = 'No DmlException while updating the Package Distribution; should not have updated due to ineligible Rules Sync Status of the Package Distribution!';
    private static final String ASSERT_MSG_NULL_SUMMARY_DELIVERY_DATETIME_GMT = 'Not able to update the Package Distribution with the Summary Delivery schedule!';
    private static final String ASSERT_MSG_NOT_NULL_SUMMARY_DELIVERY_DATETIME_GMT = 'Not able to unschedule the Summary Delivery for the Package Distribution!';
    private static final String ASSERT_MSG_NULL_PACKAGE_DELIVERY_DATETIME_GMT = 'Not able to update the Package Distribution with the Package Delivery schedule!';
    private static final String ASSERT_MSG_NOT_NULL_PACKAGE_DELIVERY_DATETIME_GMT = 'Not able to unschedule the Package Delivery for the Package Distribution!';

    private static final Set<MA_DS_TestUtil_Packages.MA_Package> maPackages = new Set<MA_DS_TestUtil_Packages.MA_Package>(MA_DS_TestUtil_Packages.MA_Package.values());
    private static final Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template>(MA_DS_TestUtil_Templates.Template.values());

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

        MA_DS_TestUtil_SetupPackages.DataWrapper acqWrapperInstance;

        System.runAs(userMap.get(MA_DS_TestUtil_Users.TestUser.SYSTEM_ADMIN_USER)) {
            MA_DS_TestUtil_SetupPackages.DataWrapper masterWrapperInstance = MA_DS_TestUtil_SetupPackages.setupMasterPackagesAndTemplatesWithRules(maPackages, maTemplates);
            acqWrapperInstance = MA_DS_TestUtil_SetupPackages.setupAcquisitionPackagesAndTemplates(maPackages, maTemplates, acqCompany);
        }

        System.runAs(userMap.get(MA_DS_TestUtil_Users.TestUser.MA_ES_USER)) {
            MA_DS_TestUtil_PackageDistributions.setupPackageDistributionsWithRules(MA_DS_TestUtil_PackageDistributions.getUSDistributions(), acqWrapperInstance.packageMap.get(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE), true);
        }
    }

    @isTest
    public static void shouldUpdateRulesSyncStatusOnUpdateOfRulesCriteria() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqINPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.INDIA_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);

        Set<MA_DS_TestUtil_PackageDistributions.Distribution> maINDistributions = new Set<MA_DS_TestUtil_PackageDistributions.Distribution> {MA_DS_TestUtil_PackageDistributions.Distribution.IN_TELANGANA};

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_PackageDistributions.setupPackageDistributionsWithRules(maINDistributions, acqINPackage, false);
        }
        Test.stopTest();

        MA_DS_Package_Distribution__c updatedPkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.IN_TELANGANA, acqINPackage);
        Assert.areEqual(MA_DS_TestUtil_PkgDistributionTrigger.NEED_SYNC_PACKAGE_TEMPLATE_RULES, updatedPkgDistribution.MA_DS_Rules_Sync_Status__c, ASSERT_MSG_NEED_SYNC_RULES_SYNC_STATUS);
    }

    @isTest
    public static void shouldUpdateRulesSyncStatusOnUpdateOfSummaryRequired() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_PkgDistributionTrigger.updateRulesSyncStatus(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.RULES_SYNCED, true);

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_PkgDistributionTrigger.updateSummaryRequired(pkgDistribution, false, false);
        }
        Test.stopTest();

        MA_DS_Package_Distribution__c updatedPkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        Assert.areEqual(MA_DS_TestUtil_PkgDistributionTrigger.NEED_SYNC_TEMPLATE_RULES, updatedPkgDistribution.MA_DS_Rules_Sync_Status__c, ASSERT_MSG_NEED_SYNC_RULES_SYNC_STATUS);
    }

    @isTest
    public static void shouldThrowDmlExceptionForIneligibleDistributionStatus() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_PkgDistributionTrigger.updateDistributionStatus(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.SUMMARY_AUDIT_COMPLETE, true);

        Boolean exceptionCaught = false;

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            try {
                MA_DS_TestUtil_PkgDistributionTrigger.updateSummaryRequired(pkgDistribution, false, false);
            }catch(DmlException ex) {
                exceptionCaught = true;
            }
        }
        Test.stopTest();

        Assert.isTrue(exceptionCaught, ASSERT_MSG_INELIGIBLE_DISTRIBUTION_STATUS_EXCEPTION);
    }

    @isTest
    public static void shouldThrowDmlExceptionForIneligibleRulesSyncStatus() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_PkgDistributionTrigger.updateRulesSyncStatus(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.SYNCING_PACKAGE_RULES, true);

        Boolean exceptionCaught = false;

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            try {
                MA_DS_TestUtil_PkgDistributionTrigger.updateSummaryRequired(pkgDistribution, false, false);
            }catch(DmlException ex) {
                exceptionCaught = true;
            }
        }
        Test.stopTest();

        Assert.isTrue(exceptionCaught, ASSERT_MSG_INELIGIBLE_RULES_SYNC_STATUS_EXCEPTION);
    }

    @isTest
    public static void shouldScheduleSummaryDelivery() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_PkgDistributionTrigger.updateDistributionStatus(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.SUMMARY_AUDIT_COMPLETE, true);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MA_DS_TestCallout_MultiMock(MA_DS_TestCallout_MultiMock.CalloutResponse.WORKFLOW_STARTED));
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_PkgDistributionTrigger.updateSummaryDeliverySchedule(pkgDistribution, true, false);
        }
        Test.stopTest();

        MA_DS_Package_Distribution__c updatedPkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        Assert.isNotNull(updatedPkgDistribution.MA_DS_Summary_Delivery_Datetime_GMT__c, ASSERT_MSG_NULL_SUMMARY_DELIVERY_DATETIME_GMT);
    }

    @isTest
    public static void shouldUnscheduleSummaryDelivery() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_PkgDistributionTrigger.updateDistributionStatus(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.SUMMARY_AUDIT_COMPLETE, true);
        MA_DS_TestUtil_PkgDistributionTrigger.updateSummaryDeliverySchedule(pkgDistribution, true, true);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MA_DS_TestCallout_MultiMock(MA_DS_TestCallout_MultiMock.CalloutResponse.WORKFLOW_STARTED));
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_PkgDistributionTrigger.updateSummaryDeliverySchedule(pkgDistribution, false, false);
        }
        Test.stopTest();

        MA_DS_Package_Distribution__c updatedPkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        Assert.isNull(updatedPkgDistribution.MA_DS_Summary_Delivery_Datetime_GMT__c, ASSERT_MSG_NOT_NULL_SUMMARY_DELIVERY_DATETIME_GMT);
    }

    @isTest
    public static void shouldSchedulePackageDelivery() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_PkgDistributionTrigger.updateDistributionStatus(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.PACKAGE_AUDIT_COMPLETE, true);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MA_DS_TestCallout_MultiMock(MA_DS_TestCallout_MultiMock.CalloutResponse.WORKFLOW_STARTED));
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_PkgDistributionTrigger.updatePackageDeliverySchedule(pkgDistribution, true, false);
        }
        Test.stopTest();

        MA_DS_Package_Distribution__c updatedPkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        Assert.isNotNull(updatedPkgDistribution.MA_DS_Package_Delivery_Datetime_GMT__c, ASSERT_MSG_NULL_PACKAGE_DELIVERY_DATETIME_GMT);
    }

    @isTest
    public static void shouldUnschedulePackageDelivery() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_PkgDistributionTrigger.updateDistributionStatus(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.PACKAGE_AUDIT_COMPLETE, true);
        MA_DS_TestUtil_PkgDistributionTrigger.updatePackageDeliverySchedule(pkgDistribution, true, true);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MA_DS_TestCallout_MultiMock(MA_DS_TestCallout_MultiMock.CalloutResponse.WORKFLOW_STARTED));
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_PkgDistributionTrigger.updatePackageDeliverySchedule(pkgDistribution, false, false);
        }
        Test.stopTest();

        MA_DS_Package_Distribution__c updatedPkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        Assert.isNull(updatedPkgDistribution.MA_DS_Package_Delivery_Datetime_GMT__c, ASSERT_MSG_NOT_NULL_PACKAGE_DELIVERY_DATETIME_GMT);
    }

    @isTest
    public static void shouldLogCalloutServiceExceptionWhileSchedulingSummaryDelivery() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_PkgDistributionTrigger.updateDistributionStatus(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.SUMMARY_AUDIT_COMPLETE, true);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MA_DS_TestCallout_MultiMock(MA_DS_TestCallout_MultiMock.CalloutResponse.UNAUTHORIZED_ENDPOINT));
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_PkgDistributionTrigger.updateSummaryDeliverySchedule(pkgDistribution, true, false);
        }
        Test.stopTest();

        Assert.isTrue([SELECT Id FROM PF_Debug_Log__c WHERE NH_Name__c = :MA_DS_TestCallout_MultiMock.CALLOUT_SERVICE_EXCEPTION_IDENTIFIER].size() > 0, MA_DS_TestCallout_MultiMock.ASSERT_MSG_CALLOUT_SERVICE_EXCEPTION_NOT_LOGGED);
    }

    @isTest
    public static void shouldLogCalloutResponseExceptionWhileSchedulingSummaryDelivery() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_PkgDistributionTrigger.updateDistributionStatus(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.SUMMARY_AUDIT_COMPLETE, true);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MA_DS_TestCallout_MultiMock(MA_DS_TestCallout_MultiMock.CalloutResponse.WORKFLOW_BAD_REQUEST));
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_PkgDistributionTrigger.updateSummaryDeliverySchedule(pkgDistribution, true, false);
        }
        Test.stopTest();

        Assert.isTrue([SELECT Id FROM PF_Debug_Log__c WHERE NH_Name__c = :MA_DS_TestCallout_MultiMock.CALLOUT_RESPONSE_EXCEPTION_IDENTIFIER].size() > 0, MA_DS_TestCallout_MultiMock.ASSERT_MSG_CALLOUT_RESPONSE_EXCEPTION_NOT_LOGGED);
    }

    @isTest
    public static void shouldLogJSONExceptionWhileSchedulingSummaryDelivery() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_PkgDistributionTrigger.updateDistributionStatus(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.SUMMARY_AUDIT_COMPLETE, true);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MA_DS_TestCallout_MultiMock(MA_DS_TestCallout_MultiMock.CalloutResponse.WORKFLOW_MALFORMED_RESPONSE));
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_TestUtil_PkgDistributionTrigger.updateSummaryDeliverySchedule(pkgDistribution, true, false);
        }
        Test.stopTest();

        Assert.isTrue([SELECT Id FROM PF_Debug_Log__c WHERE NH_Name__c = :MA_DS_TestCallout_MultiMock.JSON_EXCEPTION_IDENTIFIER].size() > 0, MA_DS_TestCallout_MultiMock.ASSERT_MSG_JSON_EXCEPTION_NOT_LOGGED);
    }
}