/**
* @description       : Apex trigger handler for Acquisition Company Task
* @author            : Satyam Kumar
* Modifications Log 
* Ver   Date         Author          	Modification
* 1.0   09-06-2021   Satyam Kumar   	Initial Version
* 2.0	07-12-2021   Ashutosh Belwal	Deprecate Description Field
* */
public without sharing class MA_ACTaskTriggerHandler {
    
    public void handler(List<Acquisition_Company_Task__c> newTasks, Map<Id, Acquisition_Company_Task__c> oldTaskMap, TriggerOperation operation) {
        switch on operation {
            when BEFORE_INSERT {
                beforeInsert(newTasks);
            }when BEFORE_UPDATE {
                beforeUpdate(newTasks, oldTaskMap);
            }when BEFORE_DELETE {
                beforeDelete(oldTaskMap);
            }
        }
    }
    
    private void beforeInsert(List<Acquisition_Company_Task__c> newTasks){
        MA_ACTaskTriggerHelper.handleBeforeInsert(newTasks);
    }
    
    private void beforeUpdate(List<Acquisition_Company_Task__c> newTasks, Map<Id, Acquisition_Company_Task__c> oldTaskMap){
        MA_ACTaskTriggerHelper.handleBeforeUpdate(newTasks, oldTaskMap);
    }
    
    private void beforeDelete(Map<Id, Acquisition_Company_Task__c> oldTaskMap){
        MA_ACTaskTriggerHelper.handleBeforeDelete(oldTaskMap);
    }
}