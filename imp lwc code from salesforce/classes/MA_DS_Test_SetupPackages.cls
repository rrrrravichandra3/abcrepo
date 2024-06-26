/**
 * Test class for MA_DS_SetupPackages & its associated classes.
 * 
 * Version      Date            Author                  Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         03/12/2023      Chakshu Malhotra        Adds test methods to cover MA_DS_SetupPackages & its associated classes.
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
@isTest
public class MA_DS_Test_SetupPackages {
    
    private static final String TEST_IDENTIFIER = 'SetupPackages';

    private static final String ASSERT_MSG_TOTAL_MASTER_PACKAGES = 'Not an expected number of Master Packages!';
    private static final String ASSERT_MSG_NO_IN_USE_TEMPLATES = 'No In Use Templates found for the selected Master Package!';
    private static final String ASSERT_MSG_ACQ_PACKAGE_COPIED = 'No Acquisition Master Package copied for the selected Master Package!';
    private static final String ASSERT_MSG_ACQ_PACKAGE_DERIVED_FROM = 'Acquisition Master Package is not copied from the selected Master Package!';
    private static final String ASSERT_MSG_TOTAL_COPIED_TEMPLATES = 'Not an expected number of copied Templates!';
    private static final String ASSERT_MSG_ACQ_IN_USE_TEMPLATE_COUNT = 'Count of copied Acquisition Templates do not match with the number of selected Templates!';
    private static final String ASSERT_MSG_ACQ_IN_USE_TEMPLATE_UNSELECTED_COUNT = 'Count of Acquisition Templates inconsistent with the number of unselected Templates!';
    private static final String ASSERT_MSG_ACQ_PACKAGE_NULL_REFERENCE = 'Acquisition Master Package is not deleted after unselecting all of its Templates!';
    private static final String ASSERT_MSG_ACQ_IN_USE_TEMPLATE_NEW_SELECTED_COUNT = 'Count of Acquisition Templates inconsistent with the number of newly selected Templates!';
    private static final String ASSERT_MSG_AURA_HANDLED_EXCEPTION_NOT_CAUGHT = 'Failed to catch AuraHandledException!';

    @testSetup
    public static void setupTestData() {
        Map<MA_DS_TestUtil_Users.TestUser, User> userMap;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            userMap = MA_DS_TestUtil_Users.setupTestUsers(TEST_IDENTIFIER);
            MA_DS_TestUtil_Users.activatePermissions(userMap);
        }
        
        System.runAs(userMap.get(MA_DS_TestUtil_Users.TestUser.SYSTEM_ADMIN_USER)) {
            MA_DS_TestUtil_SetupPackages.setupMasterPackagesAndTemplates();
        }
        
        System.runAs(userMap.get(MA_DS_TestUtil_Users.TestUser.MA_ES_USER)) {
            Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.setupTestAcquisitionCompany(TEST_IDENTIFIER);
        }
    }

    @isTest
    public static void shouldGetMasterPackages() {
        Integer totalMasterPackages;

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            List<MA_DS_Package__c> masterPackages = MA_DS_SetupPackages.getMasterPackages();
            totalMasterPackages = masterPackages.size();
        }
        Test.stopTest();

        Assert.areEqual(2, totalMasterPackages, ASSERT_MSG_TOTAL_MASTER_PACKAGES);
    }

    @isTest
    public static void shouldGetInUseTemplates() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c masterPackageUS = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.MASTER);
        
        Integer totalInUseTemplates;
        
        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            List<MA_DS_In_Use_Template__c> inUseTemplates = MA_DS_SetupPackages.getInUseTemplates(acqCompany.Id, masterPackageUS.Id);
            totalInUseTemplates = inUseTemplates.size();
        }
        Test.stopTest();

        Assert.isTrue(totalInUseTemplates > 0, ASSERT_MSG_NO_IN_USE_TEMPLATES);
    }

    @isTest
    public static void shouldSetupUSPackageTemplates() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        List<MA_DS_SetupPackagesWrapper> selectedInUseTemplates = MA_DS_TestUtil_SetupPackages.getSelectedInUseTemplates(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.MASTER, MA_DS_TestUtil_Templates.getUSPackageTemplates(), MA_DS_TestUtil_Templates.TemplateType.MASTER, MA_DS_TestUtil_InUseTemplates.InUseTemplateTemplate.MASTER_IN_USE_TEMPLATE);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MA_DS_TestCallout_MultiMock(MA_DS_TestCallout_MultiMock.CalloutResponse.WORKFLOW_STARTED));
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_SetupPackages.copyPackagesAndTemplates(acqCompany.Id, selectedInUseTemplates, new List<MA_DS_SetupPackagesWrapper>());
        }
        Test.stopTest();

        MA_DS_Package__c masterUSPackageRef = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.MASTER);
        MA_DS_Package__c acqUSPackageRef = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);
        
        Assert.isNotNull(acqUSPackageRef, ASSERT_MSG_ACQ_PACKAGE_COPIED);
        Assert.areEqual(masterUSPackageRef.Id, acqUSPackageRef?.MA_DS_Derived_From_Package__c, ASSERT_MSG_ACQ_PACKAGE_DERIVED_FROM);

        Map<MA_DS_TestUtil_Templates.Template, MA_DS_Template__c> acqUSTemplateMap = MA_DS_TestUtil_Templates.getTemplateMap(MA_DS_TestUtil_Templates.getUSPackageTemplates(), MA_DS_TestUtil_Templates.TemplateType.ACQUISITION, acqCompany);
        Map<MA_DS_TestUtil_Templates.Template, MA_DS_In_Use_Template__c> acqUSInUseTemplateMap = MA_DS_TestUtil_InUseTemplates.getInUseTemplateMap(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, acqUSTemplateMap.keySet(), acqCompany, MA_DS_TestUtil_InUseTemplates.InUseTemplateTemplate.ACQUISITION_IN_USE_TEMPLATE);

        Assert.isTrue(acqUSInUseTemplateMap.keySet().size() > 0, ASSERT_MSG_TOTAL_COPIED_TEMPLATES);
        Assert.isTrue(selectedInUseTemplates.size() == acqUSInUseTemplateMap.keySet().size(), ASSERT_MSG_ACQ_IN_USE_TEMPLATE_COUNT);
    }

    @isTest
    public static void shouldSetupIndiaAndUpdateUSPackageTemplates() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_TestUtil_SetupPackages.setupAcquisitionPackagesAndTemplates(new Set<MA_DS_TestUtil_Packages.MA_Package> {MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE}, MA_DS_TestUtil_Templates.getUSPackageTemplates(), acqCompany);

        Set<MA_DS_TestUtil_Templates.Template> unselectedUSTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.CAL_WORKER_COMP_GUIDE, MA_DS_TestUtil_Templates.Template.US_HIPAA_NOTICE};
        List<MA_DS_SetupPackagesWrapper> unselectedUSInUseTemplates = MA_DS_TestUtil_SetupPackages.getUnselectedInUseTemplates(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, unselectedUSTemplates, MA_DS_TestUtil_Templates.TemplateType.ACQUISITION, acqCompany, MA_DS_TestUtil_InUseTemplates.InUseTemplateTemplate.ACQUISITION_IN_USE_TEMPLATE);
        List<MA_DS_SetupPackagesWrapper> selectedIndiaInUseTemplates = MA_DS_TestUtil_SetupPackages.getSelectedInUseTemplates(MA_DS_TestUtil_Packages.MA_Package.INDIA_PACKAGE, MA_DS_TestUtil_Packages.PackageType.MASTER, MA_DS_TestUtil_Templates.getIndiaPackageTemplates(), MA_DS_TestUtil_Templates.TemplateType.MASTER, MA_DS_TestUtil_InUseTemplates.InUseTemplateTemplate.MASTER_IN_USE_TEMPLATE);

        Integer templateCountBeforeUnselection = MA_DS_TestUtil_Templates.getTemplateMap(MA_DS_TestUtil_Templates.getUSPackageTemplates(), MA_DS_TestUtil_Templates.TemplateType.ACQUISITION, acqCompany).size();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MA_DS_TestCallout_MultiMock(MA_DS_TestCallout_MultiMock.CalloutResponse.WORKFLOW_STARTED));
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_SetupPackages.copyPackagesAndTemplates(acqCompany.Id, selectedIndiaInUseTemplates, unselectedUSInUseTemplates);
        }
        Test.stopTest();

        MA_DS_Package__c acqIndiaPackageRef = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.INDIA_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);        
        Assert.isNotNull(acqIndiaPackageRef, ASSERT_MSG_ACQ_PACKAGE_COPIED);

        Integer templateCountAfterUnselection = MA_DS_TestUtil_Templates.getTemplateMap(MA_DS_TestUtil_Templates.getUSPackageTemplates(), MA_DS_TestUtil_Templates.TemplateType.ACQUISITION, acqCompany).size();
        Assert.areEqual(templateCountBeforeUnselection - unselectedUSTemplates.size(), templateCountAfterUnselection, ASSERT_MSG_ACQ_IN_USE_TEMPLATE_UNSELECTED_COUNT);
    }

    @isTest
    public static void shouldUpdateIndiaAndUnselectUSPackageTemplates() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        
        Set<MA_DS_TestUtil_Templates.Template> acqTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.PIIA_TL};
        acqTemplates.addAll(MA_DS_TestUtil_Templates.getUSPackageTemplates());
        MA_DS_TestUtil_SetupPackages.setupAcquisitionPackagesAndTemplates(new Set<MA_DS_TestUtil_Packages.MA_Package> {MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.MA_Package.INDIA_PACKAGE}, acqTemplates, acqCompany);

        Set<MA_DS_TestUtil_Templates.Template> selectedIndiaTemplates = new Set<MA_DS_TestUtil_Templates.Template> {MA_DS_TestUtil_Templates.Template.PIIA_KA};
        List<MA_DS_SetupPackagesWrapper> selectedIndiaInUseTemplates = MA_DS_TestUtil_SetupPackages.getSelectedInUseTemplates(MA_DS_TestUtil_Packages.MA_Package.INDIA_PACKAGE, MA_DS_TestUtil_Packages.PackageType.MASTER, selectedIndiaTemplates, MA_DS_TestUtil_Templates.TemplateType.MASTER, MA_DS_TestUtil_InUseTemplates.InUseTemplateTemplate.MASTER_IN_USE_TEMPLATE);
        List<MA_DS_SetupPackagesWrapper> unselectedUSInUseTemplates = MA_DS_TestUtil_SetupPackages.getUnselectedInUseTemplates(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, MA_DS_TestUtil_Templates.getUSPackageTemplates(), MA_DS_TestUtil_Templates.TemplateType.ACQUISITION, acqCompany, MA_DS_TestUtil_InUseTemplates.InUseTemplateTemplate.ACQUISITION_IN_USE_TEMPLATE);

        Integer templateCountBeforeNewSelection = MA_DS_TestUtil_Templates.getTemplateMap(MA_DS_TestUtil_Templates.getIndiaPackageTemplates(), MA_DS_TestUtil_Templates.TemplateType.ACQUISITION, acqCompany).size();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MA_DS_TestCallout_MultiMock(MA_DS_TestCallout_MultiMock.CalloutResponse.WORKFLOW_STARTED));
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_SetupPackages.copyPackagesAndTemplates(acqCompany.Id, selectedIndiaInUseTemplates, unselectedUSInUseTemplates);
        }
        Test.stopTest();

        MA_DS_Package__c acqUSPackageRef = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);        
        Assert.isNull(acqUSPackageRef, ASSERT_MSG_ACQ_PACKAGE_NULL_REFERENCE);

        Integer templateCountAfterNewSelection = MA_DS_TestUtil_Templates.getTemplateMap(MA_DS_TestUtil_Templates.getIndiaPackageTemplates(), MA_DS_TestUtil_Templates.TemplateType.ACQUISITION, acqCompany).size();
        Assert.areEqual(templateCountBeforeNewSelection + 1, templateCountAfterNewSelection, ASSERT_MSG_ACQ_IN_USE_TEMPLATE_NEW_SELECTED_COUNT);
    }

    @isTest
    public static void shouldThrowAuraHandledException() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        List<MA_DS_SetupPackagesWrapper> selectedInUseTemplates = MA_DS_TestUtil_SetupPackages.getSelectedInUseTemplates(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.MASTER, MA_DS_TestUtil_Templates.getUSPackageTemplates(), MA_DS_TestUtil_Templates.TemplateType.MASTER, MA_DS_TestUtil_InUseTemplates.InUseTemplateTemplate.MASTER_IN_USE_TEMPLATE);

        Boolean exceptionCaught = false;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MA_DS_TestCallout_MultiMock(MA_DS_TestCallout_MultiMock.CalloutResponse.WORKFLOW_STARTED));
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            try {
                MA_DS_SetupPackages.copyPackagesAndTemplates(acqCompany.Id, selectedInUseTemplates, null);
            }catch(AuraHandledException ex) {
                exceptionCaught = true;
            }
        }
        Test.stopTest();

        Assert.isTrue(exceptionCaught, ASSERT_MSG_AURA_HANDLED_EXCEPTION_NOT_CAUGHT);
    }

    @isTest
    public static void shouldLogCalloutServiceException() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        List<MA_DS_SetupPackagesWrapper> selectedInUseTemplates = MA_DS_TestUtil_SetupPackages.getSelectedInUseTemplates(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.MASTER, MA_DS_TestUtil_Templates.getUSPackageTemplates(), MA_DS_TestUtil_Templates.TemplateType.MASTER, MA_DS_TestUtil_InUseTemplates.InUseTemplateTemplate.MASTER_IN_USE_TEMPLATE);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MA_DS_TestCallout_MultiMock(MA_DS_TestCallout_MultiMock.CalloutResponse.UNAUTHORIZED_ENDPOINT));
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_SetupPackages.copyPackagesAndTemplates(acqCompany.Id, selectedInUseTemplates, new List<MA_DS_SetupPackagesWrapper>());
        }
        Test.stopTest();

        Assert.isTrue([SELECT Id FROM PF_Debug_Log__c WHERE NH_Name__c = :MA_DS_TestCallout_MultiMock.CALLOUT_SERVICE_EXCEPTION_IDENTIFIER].size() > 0, MA_DS_TestCallout_MultiMock.ASSERT_MSG_CALLOUT_SERVICE_EXCEPTION_NOT_LOGGED);
    }

    @isTest
    public static void shouldLogCalloutResponseException() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        List<MA_DS_SetupPackagesWrapper> selectedInUseTemplates = MA_DS_TestUtil_SetupPackages.getSelectedInUseTemplates(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.MASTER, MA_DS_TestUtil_Templates.getUSPackageTemplates(), MA_DS_TestUtil_Templates.TemplateType.MASTER, MA_DS_TestUtil_InUseTemplates.InUseTemplateTemplate.MASTER_IN_USE_TEMPLATE);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MA_DS_TestCallout_MultiMock(MA_DS_TestCallout_MultiMock.CalloutResponse.WORKFLOW_BAD_REQUEST));
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_SetupPackages.copyPackagesAndTemplates(acqCompany.Id, selectedInUseTemplates, new List<MA_DS_SetupPackagesWrapper>());
        }
        Test.stopTest();

        Assert.isTrue([SELECT Id FROM PF_Debug_Log__c WHERE NH_Name__c = :MA_DS_TestCallout_MultiMock.CALLOUT_RESPONSE_EXCEPTION_IDENTIFIER].size() > 0, MA_DS_TestCallout_MultiMock.ASSERT_MSG_CALLOUT_RESPONSE_EXCEPTION_NOT_LOGGED);
    }

    @isTest
    public static void shouldLogJSONException() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        List<MA_DS_SetupPackagesWrapper> selectedInUseTemplates = MA_DS_TestUtil_SetupPackages.getSelectedInUseTemplates(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.MASTER, MA_DS_TestUtil_Templates.getUSPackageTemplates(), MA_DS_TestUtil_Templates.TemplateType.MASTER, MA_DS_TestUtil_InUseTemplates.InUseTemplateTemplate.MASTER_IN_USE_TEMPLATE);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MA_DS_TestCallout_MultiMock(MA_DS_TestCallout_MultiMock.CalloutResponse.WORKFLOW_MALFORMED_RESPONSE));
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            MA_DS_SetupPackages.copyPackagesAndTemplates(acqCompany.Id, selectedInUseTemplates, new List<MA_DS_SetupPackagesWrapper>());
        }
        Test.stopTest();

        Assert.isTrue([SELECT Id FROM PF_Debug_Log__c WHERE NH_Name__c = :MA_DS_TestCallout_MultiMock.JSON_EXCEPTION_IDENTIFIER].size() > 0, MA_DS_TestCallout_MultiMock.ASSERT_MSG_JSON_EXCEPTION_NOT_LOGGED);
    }
}