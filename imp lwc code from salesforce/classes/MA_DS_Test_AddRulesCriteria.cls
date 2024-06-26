/**
 * Test class for MA_DS_AddRulesCriteria & its associated classes.
 * 
 * Version      Date            Author                  Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         15/12/2023      Chakshu Malhotra        Adds test methods to cover MA_DS_AddRulesCriteria & its associated classes.
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
@isTest
public class MA_DS_Test_AddRulesCriteria {
    
    private static final String TEST_IDENTIFIER = 'AddRulesCriteria';

    private static final String SOBJECT_TYPE_TEMPLATE = 'MA_DS_Template__c';
    private static final String SOBJECT_TYPE_IN_USE_TEMPLATE = 'MA_DS_In_Use_Template__c';
    private static final String SOBJECT_TYPE_PACKAGE_DISTRIBUTION = 'MA_DS_Package_Distribution__c';

    private static final String ASSERT_MSG_RULES_CRITERIA_JSON_PARSE_EXCEPTION = 'No MA_DS_AddRulesCriteriaConfig.RulesCriteriaJSONParseException handled while getting MA_DS_AddRulesCriteriaWrapper instance for a known sObject record!';
    private static final String ASSERT_MSG_UNKNOWN_RULE_CRITERIA_CONFIG_EXCEPTION = 'No MA_DS_AddRulesCriteriaConfig.UnknownRuleCriteriaConfigException handled while getting MA_DS_AddRulesCriteriaWrapper instance for an unknown sObject record!';
    private static final String ASSERT_MSG_GET_RULES_WRAPPER_AURA_HANDLED_EXCEPTION = 'Failed to catch AuraHandledException while getting MA_DS_AddRulesCriteriaWrapper instance for a known sObject record!';
    private static final String ASSERT_MSG_GET_RULES_WRAPPER_UNEXPECTED_EXCEPTION = 'Unexpected exception handled while getting MA_DS_AddRulesCriteriaWrapper instance for a known sObject record!';
    private static final String ASSERT_MSG_NULL_RULES_CRITERIA_JSON = 'Did not expect a null response for the ResponseWrapper.MA_DS_AddRulesCriteriaWrapper.rulesCriteriaJSON for a known sObject record!';
    private static final String ASSERT_MSG_RULES_CRITERIA_FOR_INVALID_RULES_SYNC_STATUS = 'Did not expect to display the Rules Criteria for an invalid Rules Sync Status of a known sObject record!';
    private static final String ASSERT_MSG_AUDIT_FLAGS_JSON_PARSE_EXCEPTION = 'No MA_DS_AddRulesCriteriaConfig.AuditFlagsJSONParseException handled while getting MA_DS_AddRulesCriteriaWrapper instance for a known sObject record!';
    private static final String ASSERT_MSG_NULL_AUDIT_FLAGS_JSON = 'Did not expect a null response for the ResponseWrapper.MA_DS_AddRulesCriteriaWrapper.auditFlagsJSON for a known sObject record!';
    private static final String ASSERT_MSG_RULES_CRITERIA_UPDATE_EXCEPTION = 'No MA_DS_AddRulesCriteriaConfig.RulesCriteriaUpdateException handled while processing MA_DS_AddRulesCriteriaWrapper instance for a known sObject record!';
    private static final String ASSERT_MSG_INVALID_RULES_CRITERIA_QUERY_EXCEPTION = 'No MA_DS_AddRulesCriteriaConfig.InvalidRulesCriteriaQueryException handled while processing MA_DS_AddRulesCriteriaWrapper instance for a known sObject record!';
    private static final String ASSERT_MSG_PROCESS_RULES_WRAPPER_AURA_HANDLED_EXCEPTION = 'Failed to catch AuraHandledException while processing MA_DS_AddRulesCriteriaWrapper instance for a known sObject record!';
    private static final String ASSERT_MSG_PROCESS_RULES_WRAPPER_UNEXPECTED_EXCEPTION = 'Unexpected exception handled while processing MA_DS_AddRulesCriteriaWrapper instance for a known sObject record!';
    private static final String ASSERT_MSG_PROCESS_NULL_RULES_CRITERIA_JSON = 'Did not expect a null value for the MA_DS_Rules_Criteria_JSON__c for a known sObject record!';
    private static final String ASSERT_MSG_PROCESS_NULL_RULES_CRITERIA_QUERY = 'Did not expect a null value for the MA_DS_Rules_Criteria_Query__c for a known sObject record!';
    private static final String ASSERT_MSG_PROCESS_NULL_AUDIT_FLAGS_JSON = 'Did not expect a null value for the MA_DS_Audit_Flags_JSON__c for a known sObject record!';

    private static final Set<MA_DS_TestUtil_Packages.MA_Package> maUSPackages = new Set<MA_DS_TestUtil_Packages.MA_Package> {MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE};
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

        MA_DS_TestUtil_SetupPackages.DataWrapper acqWrapperInstance;

        System.runAs(userMap.get(MA_DS_TestUtil_Users.TestUser.SYSTEM_ADMIN_USER)) {
            MA_DS_TestUtil_SetupPackages.setupMasterPackagesAndTemplatesWithRules(maUSPackages, maUSTemplates);
            acqWrapperInstance = MA_DS_TestUtil_SetupPackages.setupAcquisitionPackagesAndTemplates(maUSPackages, maUSTemplates, acqCompany);
        }

        System.runAs(userMap.get(MA_DS_TestUtil_Users.TestUser.MA_ES_USER)) {
            MA_DS_TestUtil_PackageDistributions.setupPackageDistributionsWithRules(MA_DS_TestUtil_PackageDistributions.getUSDistributions(), acqWrapperInstance.packageMap.get(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE), true);
        }
    }

    @isTest
    public static void shouldHandleRulesCriteriaJSONParseExceptionForPackageDistribution() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_AddRulesCriteria.updateRulesCriteriaJSONToCauseParseException(pkgDistribution, true);

        MA_DS_AddRulesCriteria.ResponseWrapper responseWrapper;
        
        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            responseWrapper = MA_DS_AddRulesCriteria.getRulesWrapper(pkgDistribution.Id, SOBJECT_TYPE_PACKAGE_DISTRIBUTION);
        }
        Test.stopTest();

        Assert.isTrue(responseWrapper.isError, ASSERT_MSG_RULES_CRITERIA_JSON_PARSE_EXCEPTION);
    }

    @isTest
    public static void shouldHandleUnknownRuleCriteriaConfigExceptionForPackageDistribution() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_AddRulesCriteria.ResponseWrapper responseWrapper;

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            responseWrapper = MA_DS_AddRulesCriteria.getRulesWrapper(pkgDistribution.Id, SOBJECT_TYPE_TEMPLATE);
        }
        Test.stopTest();

        Assert.isTrue(responseWrapper.isError, ASSERT_MSG_UNKNOWN_RULE_CRITERIA_CONFIG_EXCEPTION);
    }

    @isTest
    public static void shouldThrowAuraHandledExceptionWhileGettingRulesWrapper() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_PkgDistributionTrigger.updateRulesSyncStatus(pkgDistribution, null, true);

        Boolean exceptionCaught = false;

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            try {
                MA_DS_AddRulesCriteria.getRulesWrapper(pkgDistribution.Id, SOBJECT_TYPE_PACKAGE_DISTRIBUTION);
            }catch(AuraHandledException ex) {
                exceptionCaught = true;
            }
        }
        Test.stopTest();

        Assert.isTrue(exceptionCaught, ASSERT_MSG_GET_RULES_WRAPPER_AURA_HANDLED_EXCEPTION);
    }

    @isTest
    public static void shouldGetRulesWrapperForPackageDistribution() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_AddRulesCriteria.ResponseWrapper responseWrapper;

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            responseWrapper = MA_DS_AddRulesCriteria.getRulesWrapper(pkgDistribution.Id, SOBJECT_TYPE_PACKAGE_DISTRIBUTION);
        }
        Test.stopTest();

        Assert.isFalse(responseWrapper.isError, ASSERT_MSG_GET_RULES_WRAPPER_UNEXPECTED_EXCEPTION);
        Assert.isNotNull(responseWrapper.rulesWrapper.rulesCriteriaJSON, ASSERT_MSG_NULL_RULES_CRITERIA_JSON);
    }

    @isTest
    public static void shouldNotDisplayRulesCriteriaForPackageDistribution() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_PkgDistributionTrigger.updateRulesSyncStatus(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.SYNCING_PACKAGE_RULES, true);

        MA_DS_AddRulesCriteria.ResponseWrapper responseWrapper;

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            responseWrapper = MA_DS_AddRulesCriteria.getRulesWrapper(pkgDistribution.Id, SOBJECT_TYPE_PACKAGE_DISTRIBUTION);
        }
        Test.stopTest();

        Assert.isFalse(responseWrapper.isError, ASSERT_MSG_GET_RULES_WRAPPER_UNEXPECTED_EXCEPTION);
        Assert.isFalse(responseWrapper.rulesWrapper.displayRulesCriteria, ASSERT_MSG_RULES_CRITERIA_FOR_INVALID_RULES_SYNC_STATUS);
    }

    @isTest
    public static void shouldHandleAuditFlagsJSONParseExceptionForInUseTemplate() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_In_Use_Template__c inUseTemplate = MA_DS_TestUtil_InUseTemplates.getInUseTemplate(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Templates.Template.GL_RSU_LETTER, acqCompany, MA_DS_TestUtil_InUseTemplates.InUseTemplateTemplate.ACQUISITION_IN_USE_TEMPLATE);
        
        MA_DS_TestUtil_AddRulesCriteria.updateAuditFlagsJSONToCauseParseException(inUseTemplate, true);
        MA_DS_AddRulesCriteria.ResponseWrapper responseWrapper;
        
        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            responseWrapper = MA_DS_AddRulesCriteria.getRulesWrapper(inUseTemplate.Id, SOBJECT_TYPE_IN_USE_TEMPLATE);
        }
        Test.stopTest();

        Assert.isTrue(responseWrapper.isError, ASSERT_MSG_AUDIT_FLAGS_JSON_PARSE_EXCEPTION);
    }

    @isTest
    public static void shouldGetRulesWrapperForInUseTemplate() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_In_Use_Template__c inUseTemplate = MA_DS_TestUtil_InUseTemplates.getInUseTemplate(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Templates.Template.GL_RSU_LETTER, acqCompany, MA_DS_TestUtil_InUseTemplates.InUseTemplateTemplate.ACQUISITION_IN_USE_TEMPLATE);
        
        MA_DS_AddRulesCriteria.ResponseWrapper responseWrapper;
        
        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            responseWrapper = MA_DS_AddRulesCriteria.getRulesWrapper(inUseTemplate.Id, SOBJECT_TYPE_IN_USE_TEMPLATE);
        }
        Test.stopTest();

        Assert.isFalse(responseWrapper.isError, ASSERT_MSG_GET_RULES_WRAPPER_UNEXPECTED_EXCEPTION);
        Assert.isNotNull(responseWrapper.rulesWrapper.auditFlagsJSON, ASSERT_MSG_NULL_AUDIT_FLAGS_JSON);
    }

    @isTest
    public static void shouldHandleRulesCriteriaUpdateExceptionForPackageDistribution()  {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_AddRulesCriteria.clearRulesCriteria(pkgDistribution, true);
        MA_DS_TestUtil_PkgDistributionTrigger.updateRulesSyncStatus(pkgDistribution, MA_DS_TestUtil_PkgDistributionTrigger.SYNCING_PACKAGE_RULES, true);
        
        MA_DS_AddRulesCriteriaWrapper rulesWrapper = MA_DS_TestUtil_AddRulesCriteria.getRulesCriteriaWrapper(pkgDistribution);
        MA_DS_AddRulesCriteria.ResponseWrapper responseWrapper;

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            responseWrapper = MA_DS_AddRulesCriteria.processRules(pkgDistribution.Id, SOBJECT_TYPE_PACKAGE_DISTRIBUTION, rulesWrapper);
        }
        Test.stopTest();

        Assert.isTrue(responseWrapper.isError, ASSERT_MSG_RULES_CRITERIA_UPDATE_EXCEPTION);
    }

    @isTest
    public static void shouldHandleInvalidRulesCriteriaQueryExceptionForPackageDistribution()  {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_AddRulesCriteria.clearRulesCriteria(pkgDistribution, true);
        
        MA_DS_AddRulesCriteriaWrapper rulesWrapper = MA_DS_TestUtil_AddRulesCriteria.getRulesCriteriaWrapperToCauseQueryException(pkgDistribution);
        MA_DS_AddRulesCriteria.ResponseWrapper responseWrapper;

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            responseWrapper = MA_DS_AddRulesCriteria.processRules(pkgDistribution.Id, SOBJECT_TYPE_PACKAGE_DISTRIBUTION, rulesWrapper);
        }
        Test.stopTest();

        Assert.isTrue(responseWrapper.isError, ASSERT_MSG_INVALID_RULES_CRITERIA_QUERY_EXCEPTION);
    }

    @isTest
    public static void shouldThrowAuraHandledExceptionWhileProcessingRulesWrapper() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_AddRulesCriteria.clearRulesCriteria(pkgDistribution, true);

        MA_DS_AddRulesCriteriaWrapper rulesWrapper = MA_DS_TestUtil_AddRulesCriteria.getRulesCriteriaWrapper(pkgDistribution);

        MA_DS_AddRulesCriteria.ResponseWrapper responseWrapper;
        Boolean exceptionCaught = false;

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            try {
                responseWrapper = MA_DS_AddRulesCriteria.processRules(pkgDistribution.Id, SOBJECT_TYPE_TEMPLATE, rulesWrapper);
            }catch(AuraHandledException ex) {
                exceptionCaught = true;
            }
        }
        Test.stopTest();

        Assert.isTrue(exceptionCaught, ASSERT_MSG_PROCESS_RULES_WRAPPER_AURA_HANDLED_EXCEPTION);
    }

    @isTest
    public static void shouldProcessRulesForUSCaliforniaPackageDistribution()  {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);
        MA_DS_TestUtil_AddRulesCriteria.clearRulesCriteria(pkgDistribution, true);
        
        MA_DS_AddRulesCriteriaWrapper rulesWrapper = MA_DS_TestUtil_AddRulesCriteria.getRulesCriteriaWrapper(pkgDistribution);
        MA_DS_AddRulesCriteria.ResponseWrapper responseWrapper;

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            responseWrapper = MA_DS_AddRulesCriteria.processRules(pkgDistribution.Id, SOBJECT_TYPE_PACKAGE_DISTRIBUTION, rulesWrapper);
        }
        Test.stopTest();
        
        MA_DS_Package_Distribution__c updatedPkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_CALIFORNIA, acqUSPackage);

        Assert.isFalse(responseWrapper.isError, ASSERT_MSG_PROCESS_RULES_WRAPPER_UNEXPECTED_EXCEPTION);
        Assert.isNotNull(updatedPkgDistribution.MA_DS_Rules_Criteria_JSON__c, ASSERT_MSG_PROCESS_NULL_RULES_CRITERIA_JSON);
        Assert.isNotNull(updatedPkgDistribution.MA_DS_Rules_Criteria_Query__c, ASSERT_MSG_PROCESS_NULL_RULES_CRITERIA_QUERY);
    }

    @isTest
    public static void shouldProcessRulesForUSOthersPackageDistribution()  {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_Package__c acqUSPackage = MA_DS_TestUtil_Packages.getPackage(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);

        MA_DS_Package_Distribution__c pkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_OTHERS, acqUSPackage);
        MA_DS_TestUtil_AddRulesCriteria.clearRulesCriteria(pkgDistribution, true);
        
        MA_DS_AddRulesCriteriaWrapper rulesWrapper = MA_DS_TestUtil_AddRulesCriteria.getRulesCriteriaWrapper(pkgDistribution);
        MA_DS_AddRulesCriteria.ResponseWrapper responseWrapper;

        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            responseWrapper = MA_DS_AddRulesCriteria.processRules(pkgDistribution.Id, SOBJECT_TYPE_PACKAGE_DISTRIBUTION, rulesWrapper);
        }
        Test.stopTest();
        
        MA_DS_Package_Distribution__c updatedPkgDistribution = MA_DS_TestUtil_PkgDistributionTrigger.getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution.US_OTHERS, acqUSPackage);

        Assert.isFalse(responseWrapper.isError, ASSERT_MSG_PROCESS_RULES_WRAPPER_UNEXPECTED_EXCEPTION);
        Assert.isNotNull(updatedPkgDistribution.MA_DS_Rules_Criteria_JSON__c, ASSERT_MSG_PROCESS_NULL_RULES_CRITERIA_JSON);
        Assert.isNotNull(updatedPkgDistribution.MA_DS_Rules_Criteria_Query__c, ASSERT_MSG_PROCESS_NULL_RULES_CRITERIA_QUERY);
    }

    @isTest
    public static void shouldProcessRulesForPiiaUSOthersInUseTemplate() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_In_Use_Template__c inUseTemplate = MA_DS_TestUtil_InUseTemplates.getInUseTemplate(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Templates.Template.PIIA_US_OTHERS, acqCompany, MA_DS_TestUtil_InUseTemplates.InUseTemplateTemplate.ACQUISITION_IN_USE_TEMPLATE);
        
        MA_DS_TestUtil_AddRulesCriteria.clearRulesCriteria(inUseTemplate, true);

        MA_DS_AddRulesCriteriaWrapper rulesWrapper = MA_DS_TestUtil_AddRulesCriteria.getRulesCriteriaWrapper(inUseTemplate);
        MA_DS_AddRulesCriteria.ResponseWrapper responseWrapper;
        
        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            responseWrapper = MA_DS_AddRulesCriteria.processRules(inUseTemplate.Id, SOBJECT_TYPE_IN_USE_TEMPLATE, rulesWrapper);
        }
        Test.stopTest();
        
        MA_DS_In_Use_Template__c updatedInUseTemplate = MA_DS_TestUtil_InUseTemplates.getInUseTemplate(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Templates.Template.PIIA_US_OTHERS, acqCompany, MA_DS_TestUtil_InUseTemplates.InUseTemplateTemplate.ACQUISITION_IN_USE_TEMPLATE);

        Assert.isFalse(responseWrapper.isError, ASSERT_MSG_PROCESS_RULES_WRAPPER_UNEXPECTED_EXCEPTION);
        Assert.isNotNull(updatedInUseTemplate.MA_DS_Audit_Flags_JSON__c, ASSERT_MSG_PROCESS_NULL_AUDIT_FLAGS_JSON);
        Assert.isNotNull(updatedInUseTemplate.MA_DS_Rules_Criteria_JSON__c, ASSERT_MSG_PROCESS_NULL_RULES_CRITERIA_JSON);
        Assert.isNotNull(updatedInUseTemplate.MA_DS_Rules_Criteria_Query__c, ASSERT_MSG_PROCESS_NULL_RULES_CRITERIA_QUERY);
    }

    @isTest
    public static void shouldProcessRulesForUSOfferLetterInUseTemplate() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_In_Use_Template__c inUseTemplate = MA_DS_TestUtil_InUseTemplates.getInUseTemplate(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Templates.Template.US_OFFER_LETTER, acqCompany, MA_DS_TestUtil_InUseTemplates.InUseTemplateTemplate.ACQUISITION_IN_USE_TEMPLATE);
        
        MA_DS_TestUtil_AddRulesCriteria.clearRulesCriteria(inUseTemplate, true);

        MA_DS_AddRulesCriteriaWrapper rulesWrapper = MA_DS_TestUtil_AddRulesCriteria.getRulesCriteriaWrapper(inUseTemplate);
        MA_DS_AddRulesCriteria.ResponseWrapper responseWrapper;
        
        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            responseWrapper = MA_DS_AddRulesCriteria.processRules(inUseTemplate.Id, SOBJECT_TYPE_IN_USE_TEMPLATE, rulesWrapper);
        }
        Test.stopTest();
        
        MA_DS_In_Use_Template__c updatedInUseTemplate = MA_DS_TestUtil_InUseTemplates.getInUseTemplate(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Templates.Template.US_OFFER_LETTER, acqCompany, MA_DS_TestUtil_InUseTemplates.InUseTemplateTemplate.ACQUISITION_IN_USE_TEMPLATE);

        Assert.isFalse(responseWrapper.isError, ASSERT_MSG_PROCESS_RULES_WRAPPER_UNEXPECTED_EXCEPTION);
        Assert.isNotNull(updatedInUseTemplate.MA_DS_Audit_Flags_JSON__c, ASSERT_MSG_PROCESS_NULL_AUDIT_FLAGS_JSON);
        Assert.isNotNull(updatedInUseTemplate.MA_DS_Rules_Criteria_JSON__c, ASSERT_MSG_PROCESS_NULL_RULES_CRITERIA_JSON);
        Assert.isNotNull(updatedInUseTemplate.MA_DS_Rules_Criteria_Query__c, ASSERT_MSG_PROCESS_NULL_RULES_CRITERIA_QUERY);
    }

    @isTest
    public static void shouldProcessRulesForNYCPaidSickLeaveInUseTemplate() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_In_Use_Template__c inUseTemplate = MA_DS_TestUtil_InUseTemplates.getInUseTemplate(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Templates.Template.NYC_PAID_SICK_LEAVE_NOTICE, acqCompany, MA_DS_TestUtil_InUseTemplates.InUseTemplateTemplate.ACQUISITION_IN_USE_TEMPLATE);
        
        MA_DS_TestUtil_AddRulesCriteria.clearRulesCriteria(inUseTemplate, true);

        MA_DS_AddRulesCriteriaWrapper rulesWrapper = MA_DS_TestUtil_AddRulesCriteria.getRulesCriteriaWrapper(inUseTemplate);
        MA_DS_AddRulesCriteria.ResponseWrapper responseWrapper;
        
        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            responseWrapper = MA_DS_AddRulesCriteria.processRules(inUseTemplate.Id, SOBJECT_TYPE_IN_USE_TEMPLATE, rulesWrapper);
        }
        Test.stopTest();
        
        MA_DS_In_Use_Template__c updatedInUseTemplate = MA_DS_TestUtil_InUseTemplates.getInUseTemplate(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Templates.Template.NYC_PAID_SICK_LEAVE_NOTICE, acqCompany, MA_DS_TestUtil_InUseTemplates.InUseTemplateTemplate.ACQUISITION_IN_USE_TEMPLATE);

        Assert.isFalse(responseWrapper.isError, ASSERT_MSG_PROCESS_RULES_WRAPPER_UNEXPECTED_EXCEPTION);
        Assert.isNotNull(updatedInUseTemplate.MA_DS_Rules_Criteria_JSON__c, ASSERT_MSG_PROCESS_NULL_RULES_CRITERIA_JSON);
        Assert.isNotNull(updatedInUseTemplate.MA_DS_Rules_Criteria_Query__c, ASSERT_MSG_PROCESS_NULL_RULES_CRITERIA_QUERY);
    }

    @isTest
    public static void shouldProcessRulesForUSHippaNoticeInUseTemplate() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_In_Use_Template__c inUseTemplate = MA_DS_TestUtil_InUseTemplates.getInUseTemplate(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Templates.Template.US_HIPAA_NOTICE, acqCompany, MA_DS_TestUtil_InUseTemplates.InUseTemplateTemplate.ACQUISITION_IN_USE_TEMPLATE);
        
        MA_DS_TestUtil_AddRulesCriteria.clearRulesCriteria(inUseTemplate, true);

        MA_DS_AddRulesCriteriaWrapper rulesWrapper = MA_DS_TestUtil_AddRulesCriteria.getRulesCriteriaWrapper(inUseTemplate);
        MA_DS_AddRulesCriteria.ResponseWrapper responseWrapper;
        
        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            responseWrapper = MA_DS_AddRulesCriteria.processRules(inUseTemplate.Id, SOBJECT_TYPE_IN_USE_TEMPLATE, rulesWrapper);
        }
        Test.stopTest();
        
        MA_DS_In_Use_Template__c updatedInUseTemplate = MA_DS_TestUtil_InUseTemplates.getInUseTemplate(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Templates.Template.US_HIPAA_NOTICE, acqCompany, MA_DS_TestUtil_InUseTemplates.InUseTemplateTemplate.ACQUISITION_IN_USE_TEMPLATE);

        Assert.isFalse(responseWrapper.isError, ASSERT_MSG_PROCESS_RULES_WRAPPER_UNEXPECTED_EXCEPTION);
        Assert.isNotNull(updatedInUseTemplate.MA_DS_Rules_Criteria_JSON__c, ASSERT_MSG_PROCESS_NULL_RULES_CRITERIA_JSON);
        Assert.isNotNull(updatedInUseTemplate.MA_DS_Rules_Criteria_Query__c, ASSERT_MSG_PROCESS_NULL_RULES_CRITERIA_QUERY);
    }

    @isTest
    public static void shouldProcessRulesForGlRSULetterInUseTemplate() {
        Acquisition_Company__c acqCompany = MA_DS_TestUtil_Acquisition.getTestAcquisitionCompany(TEST_IDENTIFIER);
        MA_DS_In_Use_Template__c inUseTemplate = MA_DS_TestUtil_InUseTemplates.getInUseTemplate(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Templates.Template.GL_RSU_LETTER, acqCompany, MA_DS_TestUtil_InUseTemplates.InUseTemplateTemplate.ACQUISITION_IN_USE_TEMPLATE);
        
        MA_DS_TestUtil_AddRulesCriteria.clearRulesCriteria(inUseTemplate, true);

        MA_DS_AddRulesCriteriaWrapper rulesWrapper = MA_DS_TestUtil_AddRulesCriteria.getRulesCriteriaWrapper(inUseTemplate);
        MA_DS_AddRulesCriteria.ResponseWrapper responseWrapper;
        
        Test.startTest();
        System.runAs(MA_DS_TestUtil_Users.getTestUser(MA_DS_TestUtil_Users.TestUser.MA_ES_USER, TEST_IDENTIFIER)) {
            responseWrapper = MA_DS_AddRulesCriteria.processRules(inUseTemplate.Id, SOBJECT_TYPE_IN_USE_TEMPLATE, rulesWrapper);
        }
        Test.stopTest();
        
        MA_DS_In_Use_Template__c updatedInUseTemplate = MA_DS_TestUtil_InUseTemplates.getInUseTemplate(MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE, MA_DS_TestUtil_Templates.Template.GL_RSU_LETTER, acqCompany, MA_DS_TestUtil_InUseTemplates.InUseTemplateTemplate.ACQUISITION_IN_USE_TEMPLATE);

        Assert.isFalse(responseWrapper.isError, ASSERT_MSG_PROCESS_RULES_WRAPPER_UNEXPECTED_EXCEPTION);
        Assert.isNotNull(updatedInUseTemplate.MA_DS_Audit_Flags_JSON__c, ASSERT_MSG_PROCESS_NULL_AUDIT_FLAGS_JSON);
        Assert.isNotNull(updatedInUseTemplate.MA_DS_Rules_Criteria_JSON__c, ASSERT_MSG_PROCESS_NULL_RULES_CRITERIA_JSON);
        Assert.isNotNull(updatedInUseTemplate.MA_DS_Rules_Criteria_Query__c, ASSERT_MSG_PROCESS_NULL_RULES_CRITERIA_QUERY);
    }
}