/**
* @description       : Apex trigger handler for Acquisition Compensation Criteria
* @author            : Satyam Kumar
* Modifications Log 
* Ver   Date         Author          Modification
* 1.0   18-06-2021   Satyam Kumar   Initial Version
* */
public without sharing class MA_AcquisitionCompCriteriaTriggerHandler {
    
    public void handler(List<Acquisition_Compensation_Task_Criteria__c > newRecords, List<Acquisition_Compensation_Task_Criteria__c> oldRecords, Map<Id, Acquisition_Compensation_Task_Criteria__c> newMap, Map<Id, Acquisition_Compensation_Task_Criteria__c> oldMap, TriggerOperation operation){
        
        switch on operation 
        {
            when BEFORE_INSERT 
            {
                beforeInsert(newRecords, oldRecords, newMap, oldMap);
            }
            when BEFORE_UPDATE 
            {
                beforeUpdate(newRecords, oldRecords, newMap, oldMap);
            }
            when AFTER_INSERT 
            {
                afterInsert(newRecords, oldRecords, newMap, oldMap);
            }
            when AFTER_UPDATE 
            {
                afterUpdate(newRecords, oldRecords, newMap, oldMap);
            }
            when AFTER_DELETE
            {
                afterDelete(newRecords, oldRecords, newMap, oldMap);
            }
        }
        
    }
    
    public void beforeInsert(List<Acquisition_Compensation_Task_Criteria__c> newRecords, List<Acquisition_Compensation_Task_Criteria__c> oldRecords, Map<Id, Acquisition_Compensation_Task_Criteria__c> newMap, Map<Id, Acquisition_Compensation_Task_Criteria__c> oldMap){
        MA_Util.checkForValidOperators(newRecords, 'Acquisition_Compensation__c');
    }
    
    public void beforeUpdate(List<Acquisition_Compensation_Task_Criteria__c> newRecords, List<Acquisition_Compensation_Task_Criteria__c> oldRecords, Map<Id, Acquisition_Compensation_Task_Criteria__c> newMap, Map<Id, Acquisition_Compensation_Task_Criteria__c> oldMap){
         MA_Util.checkForValidOperators(newRecords, 'Acquisition_Compensation__c');
    }
    
    public void afterInsert(List<Acquisition_Compensation_Task_Criteria__c> newRecords, List<Acquisition_Compensation_Task_Criteria__c> oldRecords, Map<Id, Acquisition_Compensation_Task_Criteria__c> newMap, Map<Id, Acquisition_Compensation_Task_Criteria__c> oldMap){
        updateACTask(newRecords, oldMap);
    }
    
    public void afterUpdate(List<Acquisition_Compensation_Task_Criteria__c> newRecords, List<Acquisition_Compensation_Task_Criteria__c> oldRecords, Map<Id, Acquisition_Compensation_Task_Criteria__c> newMap, Map<Id, Acquisition_Compensation_Task_Criteria__c> oldMap){
        updateACTask(newRecords, oldMap);
    }
    
    public void afterDelete(List<Acquisition_Compensation_Task_Criteria__c> newRecords, List<Acquisition_Compensation_Task_Criteria__c> oldRecords, Map<Id, Acquisition_Compensation_Task_Criteria__c> newMap, Map<Id, Acquisition_Compensation_Task_Criteria__c> oldMap){
       updateACTask(oldRecords, oldMap);
    }
    
    public static void updateACTask(List<Acquisition_Compensation_Task_Criteria__c> newRecords, Map<Id, Acquisition_Compensation_Task_Criteria__c> oldMap) {
        Try {
            Set<Id> acqCompanyTaskIds = new Set<Id>();
            List<Acquisition_Company_Task__c> acqCompanyTasksToUpdate = new List<Acquisition_Company_Task__c>();
            for(Acquisition_Compensation_Task_Criteria__c taskCriteria: newRecords) 
            {
                //Update parent Company task on Insert or on delete
                if((Trigger.isInsert || Trigger.isDelete) && !acqCompanyTaskIds.contains(taskCriteria.Acquisition_Company_Task__c)) 
                {
                    acqCompanyTasksToUpdate.add(getCompanyTasktoUpdate(taskCriteria.Acquisition_Company_Task__c));
                    acqCompanyTaskIds.add(taskCriteria.Acquisition_Company_Task__c);
                } 
                //Update parent Company task on Update
                else if((taskCriteria.Field__c != oldMap.get(taskCriteria.Id).Field__c
                         ||taskCriteria.Operator__c != oldMap.get(taskCriteria.Id).Operator__c
                         ||taskCriteria.Value__c != oldMap.get(taskCriteria.Id).Value__c
                         ||taskCriteria.Acquisition_Company_Task__c != oldMap.get(taskCriteria.Id).Acquisition_Company_Task__c) 
                        && !acqCompanyTaskIds.contains(taskCriteria.Acquisition_Company_Task__c))
                {
                    acqCompanyTasksToUpdate.add(getCompanyTasktoUpdate(taskCriteria.Acquisition_Company_Task__c));
                    acqCompanyTaskIds.add(taskCriteria.Acquisition_Company_Task__c);
                }
            }
            
            //Update Parent Company Task
            if(acqCompanyTasksToUpdate != null && !acqCompanyTasksToUpdate.isEmpty()) 
            {
                Database.SaveResult[] taskResultList = Database.update(acqCompanyTasksToUpdate,false);
                for(Integer i=0; i<taskResultList.size();i++)
                {
                    Database.SaveResult result = taskResultList.get(i);
                    if(!result.isSuccess())
                    {
                        PF_Logger.log('MA','ERROR',String.valueOf(result.getErrors()),null,'Error during Company Task record update', 'MA_APCriteriaTriggerHandler');
                    }
                }
            }
            
            //Insert error log for failed records
            if(PF_Logger.logs.size() > 0)
            {
                PF_Logger.createLogs(PF_Logger.logs);
            }
        } 
        catch(Exception e)
        {
            PF_Logger.log('MA','ERROR',e.getMessage(),null,'Error during Acquisition Company Task update. Error Trace : ' + e.getStackTraceString(), 'MA_APCriteriaTriggerHandler');
            PF_Logger.createLogs(PF_Logger.logs);
        }
    }
    
    //Method to return Company task instance with updated Criteria Last Modified Date
    private static Acquisition_Company_Task__c getCompanyTasktoUpdate(Id companyTaskId) {
        return new Acquisition_Company_Task__c(Id = companyTaskId, Criteria_Last_Modified_Date__c  = system.now());
    }
}