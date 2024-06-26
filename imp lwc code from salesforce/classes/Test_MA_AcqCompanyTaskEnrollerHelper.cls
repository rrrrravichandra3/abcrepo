@isTest(SeeAllData=false)
public class Test_MA_AcqCompanyTaskEnrollerHelper {
    private Static String maESName = 'taskEnrollerHelper';
    @testSetup 
    static void setupCompanytaskData() {
        UserRole esrole = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_ESROLE_NAME);
        profile esuserProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_EMPLOYEE_PROFILE);
        List<User> maUser = MA_TestUtil.createESUser(1, esuserProfile.Id, esrole.Id, true, maESName);
        
        PermissionSet maESPS = [SELECT Id FROM PermissionSet WHERE Name = :MA_TestUtilityValues.MA_ES_PERMSET LIMIT 1];
        MA_TestUtil.createPermissionsetAssignment(maESPS.Id, maUser[0].Id, true);
        
        UserRole role = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_CUSTOMER_USERROLE_NAME);
        profile userProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_COMMUNITY_PORTAL_PROFILE);
        List<Contact> listContact = new List<Contact>();
        
        System.runAs(maUser[0]){
            List<Acquisition_Company__c> listCompany = MA_TestUtil.createAcquisitionCompany(1,true);
            List<Account> listAccount = MA_TestUtil.createAccount(1, listCompany[0].Id, true);
            
            List<Acquisition_Contacts__c> listAcqContacts = MA_TestUtil.createAcqContact(2, listCompany[0].Id, false);
            listAcqContacts[0].Name = maESName;
            listAcqContacts[0].Background_Check__c = 'In Process';
            insert listAcqContacts;
            listContact = MA_TestUtil.createContact(1, listAccount[0].Id, listAcqContacts[0].Id, true);
            
            List<Acquisition_Company_Task__c> listCompanytask = MA_TestUtil.createAcquisitionCompanyTask(listCompany[0].Id,1,false);
            listCompanytask[0].Process_Status__c = MA_TestUtilityValues.STATUS_NEW;
            listCompanytask[0].Subject__c = maESName;
            insert listCompanytask;
        }
        List<User> portalUsers = MA_TestUtil.createPortalUser(1, userProfile.Id, role.Id, listContact[0].Id, false);
        portalUsers[0].IsActive = true;
        insert portalUsers;
    }
    
    public static testMethod void test_getContactTasksWithNotMeetingCriteria(){
        List<Acquisition_Company_Task__c> listComptask = [SELECT Id, Acquisition_Company__c, Subject__c, Status__c, Active__c, Process_Status__c 
                                                          FROM Acquisition_Company_Task__c 
                                                          WHERE Subject__c =:maESName];
        Test.StartTest();
        MA_AcqCompanyTaskEnrollerHelper.getContactTasksWithNotMeetingCriteria(listComptask[0],null,200);
        Test.StopTest();
        
    }
    
    public static testMethod void test_getContactListFirstBatch(){
        List<Acquisition_Company_Task__c> listComptask = [SELECT Id, Acquisition_Company__c, Subject__c, Status__c, Active__c, Process_Status__c 
                                                          FROM Acquisition_Company_Task__c 
                                                          WHERE Subject__c =:maESName];
        Test.StartTest();
        MA_AcqCompanyTaskEnrollerHelper.getContactListFirstBatch(listComptask[0],200);
        Test.StopTest();
        
    }
    public static testMethod void test_queryMoreContactList(){
        List<Acquisition_Company_Task__c> listComptask = [SELECT Id, Acquisition_Company__c, Subject__c, Status__c, Active__c, Process_Status__c 
                                                          FROM Acquisition_Company_Task__c 
                                                          WHERE Subject__c =:maESName];
        Test.StartTest();
        MA_AcqCompanyTaskEnrollerHelper.queryMoreContactList(listComptask[0],null,200);
        Test.StopTest();
        
    }
    public static testMethod void test_getContactList(){
        List<Acquisition_Company_Task__c> listComptask = [SELECT Id, Acquisition_Company__c, Subject__c, Status__c, Active__c, Process_Status__c 
                                                          FROM Acquisition_Company_Task__c 
                                                          WHERE Subject__c =:maESName];
        List<Acquisition_Contacts__c> listAcqContact = [SELECT Id, Name, Background_Check__c 
                                                        FROM Acquisition_Contacts__c 
                                                        WHERE Name =:maESName];
        Set<String> acqconIds = new Set<String>{listAcqContact[0].Id};
        Test.StartTest();
        MA_AcqCompanyTaskEnrollerHelper.getContactList(listComptask[0],acqconIds);
        Test.StopTest();
        
    }
    
}