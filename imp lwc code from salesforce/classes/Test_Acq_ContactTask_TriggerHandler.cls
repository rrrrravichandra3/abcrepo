/**
* Test Class for Acquisition_ContactTask_TriggerHandler
* 
* Version      Date            Author                  Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         05-10-2023      priyanka Kanani         Initial Version
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
@isTest
public class Test_Acq_ContactTask_TriggerHandler {

    @testSetup
    static void setuptestdata(){
        List<Acquisition_Company__c> listCompany = MA_TestUtil.createAcquisitionCompany(1,true);
        List<Acquisition_Contacts__c> listAcqContacts = MA_TestUtil.createAcqContact(1, listCompany[0].Id, true);
        List<Acquisition_Company_Task__c> listCompanytask = MA_TestUtil.createAcquisitionCompanyTask(listCompany[0].Id,1,true);
        List<Acquisition_contact_task__c> listAcqContactTasks = MA_TestUtil.createAcquisitionContactTask(listCompanytask[0].Id, listAcqContacts[0].Id, 5, false);
        for(Integer i = 0; i<listAcqContactTasks.size(); i++){
            listAcqContactTasks[i].subject__c = 'OldTestTask';
        }
        insert listAcqContactTasks;
    } 
    
    public static TestMethod void test_deleteDuplicateTasks(){
        List<Acquisition_contact_task__c> newAcqContactTasks = [SELECT ID, Acquisition_Company_Task__c, Acquisition_Contact__c, Key_Identifier__c  
                                                               	FROM Acquisition_contact_task__c];
        Test.StartTest();
        	Acquisition_ContactTask_TriggerHandler.deleteDuplicateTasks(newAcqContactTasks);
        Test.StopTest();
        Assert.areEqual(1,newAcqContactTasks.size());
    }
}