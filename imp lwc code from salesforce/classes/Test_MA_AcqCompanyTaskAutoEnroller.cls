@IsTest(SeeAllData=false)
public class Test_MA_AcqCompanyTaskAutoEnroller {
    private Static String maESName = 'taskAutoController';
    
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
            List<Acquisition_Company__c> listCompany = MA_TestUtil.createAcquisitionCompany(2,true);
            List<Account> listAccount = MA_TestUtil.createAccount(1, listCompany[0].Id, true);
            
            List<Acquisition_Contacts__c> listAcqContacts = MA_TestUtil.createAcqContact(2, listCompany[0].Id, false);
            listAcqContacts[0].Name = maESName;
            insert listAcqContacts;
            listContact = MA_TestUtil.createContact(2, listAccount[0].Id, listAcqContacts[0].Id, true);
            
            List<Acquisition_Company_Task__c> listCompanytask = MA_TestUtil.createAcquisitionCompanyTask(listCompany[0].Id,2,false);
            listCompanytask[0].Process_Status__c = MA_TestUtilityValues.STATUS_NEW;
            listCompanytask[0].Subject__c = maESName;
            listCompanytask[0].Last_Processed_Date__c = System.Today();
            listCompanytask[1].Subject__c = maESName+1;
            listCompanytask[1].Last_Processed_Date__c = System.Today();
            insert listCompanytask;
            
            List<Acquisition_Company_Task__c> listCompany2task = MA_TestUtil.createAcquisitionCompanyTask(listCompany[1].Id,1,false);
            listCompany2task[0].Process_Status__c = MA_TestUtilityValues.STATUS_NEW;
            listCompany2task[0].Subject__c = maESName+2;
            listCompany2task[0].Last_Processed_Date__c = System.Today();
            insert listCompany2task;
        }
        List<User> portalUsers = MA_TestUtil.createPortalUser(1, userProfile.Id, role.Id, listContact[0].Id, false);
        portalUsers[0].IsActive = true;
        insert portalUsers;
    }
    
    public static testMethod void test_enqueueCompanyScannerJob(){
        List<Acquisition_Company_Task__c> listComptask = [SELECT Id, Acquisition_Company__c, Subject__c, Status__c, Active__c, Process_Status__c, Last_Processed_Date__c 
                                                          FROM Acquisition_Company_Task__c 
                                                          WHERE Subject__c =:maESName OR Subject__c =:maESName+1];
        Acquisition_Contacts__c acqContact = [SELECT Id, Name, Background_Check__c 
                                              FROM Acquisition_Contacts__c 
                                              WHERE Name =:maESName limit 1];
        
        acqContact.Background_Check__c = 'In Process';
        List<MA_Auto_Enrolment_Event__e> testEvents = new List<MA_Auto_Enrolment_Event__e>();
        
        Test.StartTest();
        update acqContact;
        
        try{
            MA_AcqCompanyTaskAutoEnroller.testJobEnqueued = true;
            new MA_AcqCompanyTaskEnrolmentService().autoEnrol(testEvents);
        }catch(Exception e){
            System.debug(e);
        }
        Test.StopTest();
        
        List<Acquisition_Company_Task__c> acqComtask = [SELECT ID, Status__c, Process_Status__c from Acquisition_Company_Task__c WHERE Id=:listComptask[0].Id];
        Assert.areEqual('Changes Pending', acqComtask[0].Process_Status__c); 
        
    }
    public Static testMethod void test_enqueueTaskAutoEnrollerJob(){
        List<Acquisition_Company_Task__c> listComptask = [SELECT Id, Acquisition_Company__c, Subject__c, Status__c, Active__c, Process_Status__c, Last_Processed_Date__c 
                                                          FROM Acquisition_Company_Task__c 
                                                          WHERE Subject__c =:maESName OR Subject__c =:maESName+1];
        Acquisition_Contacts__c acqContact = [SELECT Id, Name, Background_Check__c 
                                              FROM Acquisition_Contacts__c 
                                              WHERE Name =:maESName limit 1];
        List<MA_Auto_Enrolment_Event__e> testEvents = new List<MA_Auto_Enrolment_Event__e>();
        Test.StartTest();
        MA_Auto_Enrolment_Event__e ee = new MA_Auto_Enrolment_Event__e(
            Acquisition_Contact_Ids__c = acqContact.Id,
            Enrolment_Type__c = 'AC_Task',
            Acquisition_Company_Id__c = listComptask[0].Acquisition_Company__c);
        testEvents.add(ee);
        EventBus.publish(testEvents);
        try{
            MA_AcqCompanyTaskAutoEnroller.testJobEnqueued = true;
            Map<Id, Set<String>> compIdToContactIdsMap = new Map<Id, Set<String>>{
                listComptask[0].Acquisition_Company__c => new Set<String>{acqContact.Id}};
                    
            List<AggregateResult> companyIdToTaskCountAggList = getCompanyIdToTaskCountAggList(compIdToContactIdsMap.keySet());
            MA_AcqCompanyTaskEnrolWrapper.AutoEnrolStateful statefulInstance = getTaskAutoEnrolStatefulInstance(companyIdToTaskCountAggList, compIdToContactIdsMap);
            MA_AcqCompanyTaskAutoEnroller.enqueueTaskAutoEnrollerJob(statefulInstance);
            
        }catch(Exception e){
            System.debug(e);
        }
        Test.StopTest();
        List<Acquisition_Contact_Task__c> acqContask = [SELECT ID, Status__c,Subject__c from Acquisition_Contact_Task__c WHERE Subject__c =:maESName OR Subject__c =:maESName+1];
       	Assert.isNotNull(acqContask.size()); 
    }
    public Static testMethod void test_enqueueTaskAutoEnrollerAllJob(){
        List<Acquisition_Company_Task__c> listComptask = [SELECT Id, Acquisition_Company__c, Subject__c, Status__c, Active__c, Process_Status__c, Last_Processed_Date__c 
                                                          FROM Acquisition_Company_Task__c 
                                                          WHERE Subject__c =:maESName+2];
        Acquisition_Contacts__c acqContact = [SELECT Id, Name, Background_Check__c 
                                              FROM Acquisition_Contacts__c 
                                              WHERE Name =:maESName limit 1];
        List<MA_Auto_Enrolment_Event__e> testEvents = new List<MA_Auto_Enrolment_Event__e>();
        Test.StartTest();
        MA_Auto_Enrolment_Event__e ee = new MA_Auto_Enrolment_Event__e(
            Acquisition_Contact_Ids__c = acqContact.Id,
            Enrolment_Type__c = 'AC_Task',
            Acquisition_Company_Id__c = listComptask[0].Acquisition_Company__c);
        testEvents.add(ee);
        EventBus.publish(testEvents);
        try{
            MA_AcqCompanyTaskAutoEnroller.testJobEnqueued = true;
            Map<Id, Set<String>> compIdToContactIdsMap = new Map<Id, Set<String>>{
                listComptask[0].Acquisition_Company__c => new Set<String>{acqContact.Id}};
                    
                    List<AggregateResult> companyIdToTaskCountAggList = getCompanyIdToTaskCountAggList(compIdToContactIdsMap.keySet());
            MA_AcqCompanyTaskEnrolWrapper.AutoEnrolStateful statefulInstance = getTaskAutoEnrolStatefulInstance(companyIdToTaskCountAggList, compIdToContactIdsMap);
            MA_AcqCompanyTaskAutoEnroller.enqueueTaskAutoEnrollerJob(statefulInstance);
            
        }catch(Exception e){
            System.debug(e);
        }
        Test.StopTest();
        List<Acquisition_Contact_Task__c> acqContask = [SELECT ID, Status__c,Subject__c from Acquisition_Contact_Task__c WHERE Acquisition_Company_Task__c=:listComptask[0].Id];
        Assert.areEqual('taskAutoController2', acqContask[0].Subject__c); 
    }
    
    private static List<AggregateResult> getCompanyIdToTaskCountAggList(Set<Id> acqCompanyIds) {
        return [SELECT Acquisition_Company__c, COUNT(Id) taskCount 
                FROM Acquisition_Company_Task__c 
                WHERE Last_Processed_Date__c != null AND
                Acquisition_Company__c IN :acqCompanyIds 
                GROUP BY Acquisition_Company__c
                HAVING COUNT(Id) > 0];
    }
    private static MA_AcqCompanyTaskEnrolWrapper.AutoEnrolStateful getTaskAutoEnrolStatefulInstance(List<AggregateResult> companyIdToTaskCountAggList, Map<Id, Set<String>> compIdToContactIdsMap) {
        List<MA_AcqCompanyTaskEnrolWrapper.AutoEnrolTaskWrapper> taskWrapperList = new List<MA_AcqCompanyTaskEnrolWrapper.AutoEnrolTaskWrapper>();
        
        for(AggregateResult companyIdToTaskCountAgg : companyIdToTaskCountAggList) {
            MA_AcqCompanyTaskEnrolWrapper.AutoEnrolTaskWrapper taskWrapper = new MA_AcqCompanyTaskEnrolWrapper.AutoEnrolTaskWrapper();
            taskWrapper.currentCount = 0;
            taskWrapper.totalCompanyTasks = (Integer)companyIdToTaskCountAgg.get('taskCount');
            taskWrapper.companyId = (Id)companyIdToTaskCountAgg.get('Acquisition_Company__c');
            taskWrapper.acqContactIds = compIdToContactIdsMap.get(taskWrapper.companyId);
            taskWrapper.companyTasks = MA_AcqCompanyTaskEnrollerHelper.getCompanyTasks((Id)companyIdToTaskCountAgg.get('Acquisition_Company__c'));
            taskWrapperList.add(taskWrapper);
        }
        
        return getTaskAutoEnrolStatefulInstance(taskWrapperList);
    }
    private static MA_AcqCompanyTaskEnrolWrapper.AutoEnrolStateful getTaskAutoEnrolStatefulInstance(List<MA_AcqCompanyTaskEnrolWrapper.AutoEnrolTaskWrapper> taskWrapperList) {
        MA_AcqCompanyTaskEnrolWrapper.AutoEnrolStateful statefulInstance = new MA_AcqCompanyTaskEnrolWrapper.AutoEnrolStateful();
        statefulInstance.currentCount = 0;
        statefulInstance.taskWrapperList = taskWrapperList;
        statefulInstance.totalCompanies = taskWrapperList.size();
        return statefulInstance;
    }
}