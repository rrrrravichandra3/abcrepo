/**
* @description       : Batch apex to process AC Task and call MA_CreateContactTaskBatch to create, delete Acquisition Contact tasks from Company task based on criteria
* @author            : Satyam Kumar
* Modifications Log 
* Ver   Date         Author           Modification
* 1.0   14-06-2021   Satyam Kumar     Initial Version
* 2.0   11-01-2022   Ashuotosh Belwal Changes for executing the batch for selected Company tasks	
* */
global without sharing class MA_ACTaskProcessBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    //Map to store Company Task ID and Company task record
    public Map<Id,Acquisition_Company_Task__c> companyTaskMap = new Map<Id,Acquisition_Company_Task__c>();
    //Map to store Company Task ID and Contact query
    public Map<Id,String> acquisitionContactQueries = new Map<Id,String>();
    //Map to store Comapny Id and crresposnding Contact ID and related Contact task record map
    Map<Id,Map<Id,Acquisition_Contact_Task__c>> companyExistingContactTaskMap = new Map<Id,Map<Id,Acquisition_Contact_Task__c>>();
    public MA_TaskManagementSettings__c taskManagementSettings = MA_Util.getTaskManagementSettings();
    private Set<Id> comapnyTaskIds;
    
    public MA_ACTaskProcessBatch(Set<Id> comapnyTaskIds){
        this.comapnyTaskIds = comapnyTaskIds;
    }
    
    public MA_ACTaskProcessBatch(){
        
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        List<String> allowedStatus = taskManagementSettings.Active_Company_Status__c.trim().split(',');
        Datetime batchLastRunDate = taskManagementSettings.Task_Batch_Last_Run_Date__c;
        
       String acTaskQuery = 'SELECT Id, Acquisition_Company__c, Description__c, Due_Date__c, Priority__c, Status__c, Subject__c, Category__c, Required__c, Task_Context__c, '
                            +'(SELECT Id, Field__c, Value__c, Operator__c, Acquisition_Company_Task__c FROM Acquisition_Company_Task_Criterias__r),'
                            +'(SELECT Id, Field__c, Value__c, Operator__c, Acquisition_Company_Task__c FROM Acquisition_Provisioning_Criterias__r),'
                            +'(SELECT Id, Field__c, Value__c, Operator__c, Acquisition_Company_Task__c FROM Acquisition_Compensation_Criterias__r),'
                            +'(SELECT Id, Acquisition_Contact__c FROM Acquisition_Contact_Tasks__r)'
                            +'FROM Acquisition_Company_Task__c Where Acquisition_Company__r.Status__c IN: allowedStatus AND Criteria_Last_Modified_Date__c >: batchLastRunDate AND Active__c = true';
        if(comapnyTaskIds?.size() > 0){
            acTaskQuery += ' AND Id IN:comapnyTaskIds';
        }
        return Database.getQueryLocator(acTaskQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<Acquisition_Company_Task__c> scope){
        try 
        {
            //Set to store Company ID
            Set<Id> companyIds = new Set<Id>();
            //Map to store Contact ID and related Contact task record for the current company task
            Map<Id,Acquisition_Contact_Task__c> existingAcqContactTaskMap = new Map<Id,Acquisition_Contact_Task__c>();
            
            //Loop over Acquistion Company task and populate the set and map variables
            for(Acquisition_Company_Task__c acqCompanyTask: scope) 
            {
                //reset value of existingAcqContactTaskMap
                existingAcqContactTaskMap = new Map<Id,Acquisition_Contact_Task__c>();
                companyIds.add(acqCompanyTask.Acquisition_Company__c);
                companyTaskMap.put(acqCompanyTask.Id, acqCompanyTask);
                acquisitionContactQueries.put(acqCompanyTask.Id, MA_TaskCriteriaParser.getQuery(acqCompanyTask.Acquisition_Company__c, acqCompanyTask.Acquisition_Company_Task_Criterias__r,acqCompanyTask.Acquisition_Provisioning_Criterias__r, acqCompanyTask.Acquisition_Compensation_Criterias__r));
                //Loop over child contact task and populate Map of Contact Id and Contact Task
                //Add try catch to avoid Aggregate query has too many rows for direct assignment and invalid query locator exception when there are more child records
                Try{
                    for(Acquisition_Contact_Task__c acqContactTask : acqCompanyTask.Acquisition_Contact_Tasks__r) {
                        existingAcqContactTaskMap.put(acqContactTask.Acquisition_Contact__c, acqContactTask);
                    }
                } Catch(Exception ex)
                {
                    if(existingAcqContactTaskMap.isEmpty() && acqCompanyTask.Acquisition_Contact_Tasks__r != null) {
                        for(Acquisition_Contact_Task__c acqContactTask : acqCompanyTask.Acquisition_Contact_Tasks__r) {
                            existingAcqContactTaskMap.put(acqContactTask.Acquisition_Contact__c, acqContactTask);
                        }
                    }
                }
                
                if(!existingAcqContactTaskMap.isEmpty()) {
                    companyExistingContactTaskMap.put(acqCompanyTask.Id, existingAcqContactTaskMap);
                }
            }
            
        } catch(Exception e)
        {
            PF_Logger.log('MA','ERROR',e.getMessage(),null,'Error during batch processing on Acquisition_Contact_Task__c. Error Trace : ' + e.getStackTraceString(), 'MA_ACTaskProcessBatch');
            PF_Logger.createLogs(PF_Logger.logs);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
		for(Id acTaskId: acquisitionContactQueries.KeySet()) 
        {
            if(String.isNotBlank(acquisitionContactQueries.get(acTaskId))) 
            {
                //If condiion to handle exception when there is no existing Contact task for the Company task
                if(companyExistingContactTaskMap.containsKey(acTaskId)) 
                {
                    MA_CreateContactTaskBatch batch = new MA_CreateContactTaskBatch(companyTaskMap.get(acTaskId), acquisitionContactQueries.get(acTaskId), companyExistingContactTaskMap.get(acTaskId));
                    database.executeBatch(batch,Integer.valueOf(taskManagementSettings.MA_CreateContactTaskBatch_Size__c));
                } 
                else 
                {
                    MA_CreateContactTaskBatch batch = new MA_CreateContactTaskBatch(companyTaskMap.get(acTaskId), acquisitionContactQueries.get(acTaskId), null);
                    database.executeBatch(batch,Integer.valueOf(taskManagementSettings.MA_CreateContactTaskBatch_Size__c));
                }
            }
        }
    } 
    
}