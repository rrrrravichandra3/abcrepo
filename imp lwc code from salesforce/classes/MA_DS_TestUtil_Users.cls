/**
 * Test Utility class to setup Users along with required Permission Set assignments.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         30/11/2023      Chakshu Malhotra        Adds utility methods to setup Users along with required Permission Set assignments. 
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
@isTest
public class MA_DS_TestUtil_Users {

    public enum TestUser {MA_ES_USER, DS_CLM_API_USER, SYSTEM_ADMIN_USER}
    
    private static final String MA_ES_USER_PROFILE = 'Employee';
    private static final String DS_CLM_API_USER_PROFILE = 'API Vendor - Docusign CLM';
    private static final String SYSTEM_ADMIN_USER_PROFILE = 'System Administrator';

    private static final String MA_ES_USER_ALIAS = 'maesuser';
    private static final String DS_CLM_API_USER_ALIAS = 'apiuser';
    private static final String SYSTEM_ADMIN_USER_ALIAS = 'sysuser';

    private static final String MA_ES_USER_PREFIX = 'maEs';
    private static final String DS_CLM_API_USER_PREFIX = 'dsClmApi';
    private static final String SYSTEM_ADMIN_USER_PREFIX = 'sysAdmin';

    private static final String EMAIL_SUFFIX = '@test.salesforce.com';
    private static final String USERNAME_SUFFIX = '@test.peopleforce.com';

    private static final String API_USER_LOGIN_POLICY = 'Never Expires';
    private static final String API_USER_TEAM_DL_EMAIL = 'test-team-dl@salesforce.com';

    private static final String MA_ES_PERM_SET = 'M_A_ES';
    private static final String MA_ES_DS_CLM_PERM_SET = 'MA_ES_Docusign_CLM';
    private static final String MA_DS_CLM_API_PERM_SET = 'MA_Docusign_CLM_API';
    private static final String MA_DS_CLM_ADMIN_PERM_SET = 'MA_Docusign_CLM_Admin';

    private static final String CUSTOM_PERM_DS_MASTER_TEMPLATE_CRUD = 'MA_Docusign_Master_Template_CRUD';
    private static final String CUSTOM_PERM_DS_ACQ_TEMPLATE_CRUD = 'MA_Docusign_Acquisition_Template_CRUD';
    private static final String CUSTOM_PERM_DS_DISABLE_AUTO_ENROLMENT = 'MA_Docusign_Disable_Auto_Enrolment';
    private static final String CUSTOM_PERM_DS_BGC_TEMPLATE_CRUD = 'MA_Docusign_Background_Check_Template_CRUD';

    private static Map<TestUser, Id> testUserProfileIdMap {
        get {
            if(testUserProfileIdMap == null) {
                testUserProfileIdMap = new Map<TestUser, Id>();
                for(Profile userProfile : [SELECT Id, Name FROM Profile WHERE Name IN :profileNameToTestUserTypeMap.keySet()]) {
                    testUserProfileIdMap.put(profileNameToTestUserTypeMap.get(userProfile.Name), userProfile.Id);
                }
            }
            return testUserProfileIdMap;
        }set;
    }

    private static Map<String, TestUser> profileNameToTestUserTypeMap {
        get {
            if(profileNameToTestUserTypeMap == null) {
                profileNameToTestUserTypeMap = new Map<String, TestUser> {
                    MA_ES_USER_PROFILE => TestUser.MA_ES_USER,
                    DS_CLM_API_USER_PROFILE => TestUser.DS_CLM_API_USER,
                    SYSTEM_ADMIN_USER_PROFILE => TestUser.SYSTEM_ADMIN_USER
                };
            }
            return profileNameToTestUserTypeMap;
        }set;
    }

    private static Map<TestUser, String> testUserTypeToAliasMap {
        get {
            if(testUserTypeToAliasMap == null) {
                testUserTypeToAliasMap = new Map<TestUser, String> {
                    TestUser.MA_ES_USER => MA_ES_USER_ALIAS,
                    TestUser.DS_CLM_API_USER => DS_CLM_API_USER_ALIAS,
                    TestUser.SYSTEM_ADMIN_USER => SYSTEM_ADMIN_USER_ALIAS
                };
            }
            return testUserTypeToAliasMap;
        }set;
    }

    private static Map<TestUser, String> testUserTypeToPrefixMap {
        get {
            if(testUserTypeToPrefixMap == null) {
                testUserTypeToPrefixMap = new Map<TestUser, String> {
                    TestUser.MA_ES_USER => MA_ES_USER_PREFIX,
                    TestUser.DS_CLM_API_USER => DS_CLM_API_USER_PREFIX,
                    TestUser.SYSTEM_ADMIN_USER => SYSTEM_ADMIN_USER_PREFIX
                };
            }
            return testUserTypeToPrefixMap;
        }set;
    }

    private static Map<String, Id> permissionSetMap {
        get {
            if(permissionSetMap == null) {
                Set<String> permSets = new Set<String> {MA_ES_PERM_SET, MA_ES_DS_CLM_PERM_SET, MA_DS_CLM_API_PERM_SET, MA_DS_CLM_ADMIN_PERM_SET};

                permissionSetMap = new Map<String, Id>();

                for(PermissionSet permSet : [SELECT Id, Name FROM PermissionSet WHERE Name IN :permSets]) {
                    permissionSetMap.put(permSet.Name, permSet.Id);
                }
            }
            return permissionSetMap;
        }set;
    }

    private static Map<String, TestUser> permSetToTestUserTypeMap {
        get {
            if(permSetToTestUserTypeMap == null) {
                permSetToTestUserTypeMap = new Map<String, TestUser> {
                    MA_ES_PERM_SET => TestUser.MA_ES_USER,
                    MA_ES_DS_CLM_PERM_SET => TestUser.MA_ES_USER,
                    MA_DS_CLM_API_PERM_SET => TestUser.DS_CLM_API_USER,
                    MA_DS_CLM_ADMIN_PERM_SET => TestUser.SYSTEM_ADMIN_USER
                };
            }
            return permSetToTestUserTypeMap;
        }set;
    }

    private static Map<String, Id> customPermissionMap {
        get {
            if(customPermissionMap == null) {
                Set<String> customPerms = new Set<String> {CUSTOM_PERM_DS_MASTER_TEMPLATE_CRUD, CUSTOM_PERM_DS_ACQ_TEMPLATE_CRUD, CUSTOM_PERM_DS_BGC_TEMPLATE_CRUD, CUSTOM_PERM_DS_DISABLE_AUTO_ENROLMENT};

                customPermissionMap = new Map<String, Id>();

                for(CustomPermission customPerm : [SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName IN :customPerms]) {
                    customPermissionMap.put(customPerm.DeveloperName, customPerm.Id);
                }
            }
            return customPermissionMap;
        }set;
    }

    private static Map<String, Set<String>> permSetToCustomPermissionMap {
        get {
            if(permSetToCustomPermissionMap == null) {
                permSetToCustomPermissionMap = new Map<String, Set<String>> {
                    MA_ES_PERM_SET => new Set<String>(),
                    MA_ES_DS_CLM_PERM_SET => new Set<String> {CUSTOM_PERM_DS_BGC_TEMPLATE_CRUD},
                    MA_DS_CLM_API_PERM_SET => new Set<String> {CUSTOM_PERM_DS_MASTER_TEMPLATE_CRUD, CUSTOM_PERM_DS_ACQ_TEMPLATE_CRUD, CUSTOM_PERM_DS_BGC_TEMPLATE_CRUD, CUSTOM_PERM_DS_DISABLE_AUTO_ENROLMENT},
                    MA_DS_CLM_ADMIN_PERM_SET => new Set<String> {CUSTOM_PERM_DS_MASTER_TEMPLATE_CRUD, CUSTOM_PERM_DS_ACQ_TEMPLATE_CRUD, CUSTOM_PERM_DS_BGC_TEMPLATE_CRUD}
                };
            }
            return permSetToCustomPermissionMap;
        }set;
    }

    public static Map<TestUser, User> setupTestUsers(String testIdentifier) {
        Map<TestUser, User> testUserMap = new Map<TestUser, User>();

        for(TestUser testUserType : testUserProfileIdMap.keySet()) {
            User testUser = new User();
            testUser.LocaleSidKey='en_US';
            testUser.EmailEncodingKey='UTF-8';
            testUser.LanguageLocaleKey='en_US';
        	testUser.TimeZoneSidKey='America/Chicago';
            testUser.Alias = testUserTypeToAliasMap.get(testUserType);
            testUser.ProfileId = testUserProfileIdMap.get(testUserType);
            testUser.LastName = testUserTypeToPrefixMap.get(testUserType) + ' ' + testIdentifier;
            testUser.Email = testUserTypeToPrefixMap.get(testUserType) + '.' + testIdentifier + EMAIL_SUFFIX;
            testUser.Username = testUserTypeToPrefixMap.get(testUserType) + '.' + testIdentifier + USERNAME_SUFFIX;

            if(testUserType == MA_DS_TestUtil_Users.TestUser.DS_CLM_API_USER) {
                testUser.API_User__c = true;
                testUser.Login_Policy__c = API_USER_LOGIN_POLICY;
                testUser.Team_DL_Email__c = API_USER_TEAM_DL_EMAIL;
            }

            testUserMap.put(testUserType, testUser);
        }

        insert testUserMap.values();
        return testUserMap;
    }

    public static void activatePermissions(Map<TestUser, User> testUserMap) {
        List<PermissionSetAssignment> permissions = new List<PermissionSetAssignment>();

        for(String permSetName : permissionSetMap.keySet()) {
            Id permissionSetId = permissionSetMap.get(permSetName);
            Id assigneeId = testUserMap.get(permSetToTestUserTypeMap.get(permSetName)).Id;
            permissions.add(new PermissionSetAssignment(AssigneeId = assigneeId, PermissionSetId = permissionSetId));
        }

        insert permissions;
    }

    public static Map<TestUser, User> getTestUsers(String testIdentifier) {
        Map<TestUser, User> testUserMap = new Map<TestUser, User>();

        for(User testUser : [SELECT Id, Profile.Name FROM User WHERE Username IN :getUsernames(testIdentifier)]) {
            testUserMap.put(profileNameToTestUserTypeMap.get(testUser.Profile.Name), testUser);
        }

        return testUserMap;
    }

    private static Set<String> getUsernames(String testIdentifier) {
        Set<String> usernames = new Set<String>();

        for(TestUser testUserType : testUserTypeToPrefixMap.keySet()) {
            usernames.add(testUserTypeToPrefixMap.get(testUserType) + '.' + testIdentifier + USERNAME_SUFFIX);
        }

        return usernames;
    }

    public static User getTestUser(TestUser testUserType, String testIdentifier) {
        String testUsername =  testUserTypeToPrefixMap.get(testUserType) + '.' + testIdentifier + USERNAME_SUFFIX;
        return [SELECT Id FROM User WHERE Username = :testUsername LIMIT 1];
    }
}