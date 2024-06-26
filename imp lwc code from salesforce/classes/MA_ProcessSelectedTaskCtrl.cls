/**
* @description       : Controller class for MA_ProcessSelectedTask VF page
* @author            : Ashutosh Belwal
* Modifications Log 
* Ver   Date         Author            Modification
* 1.0   10-01-2022   Ashutosh Belwal   Initial Version
* 1.1   11-01-2023   Priyanka kanani   Test.isRunningTest() check added for batch chaining
**/
public class MA_ProcessSelectedTaskCtrl {
    Set<Id> selectedTaskIds{get;set;}
    public Boolean showProcessButton{get;set;}
    public List<Acquisition_Company_Task__c> selectedCompanyTasks{get;set;}
    private ApexPages.StandardSetController pageController;
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Constructor to get selected Tasks from list view
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public MA_ProcessSelectedTaskCtrl(ApexPages.StandardSetController stdCtrl){
        pageController = stdCtrl;
        selectedTaskIds = new Set<Id>();
        Map<Id, Acquisition_Company_Task__c> mapACTask = new Map<Id, Acquisition_Company_Task__c>([SELECT Id, Name, Status__c , Subject__c, Due_Date__c
                                                                                                   FROM Acquisition_Company_Task__c 
                                                                                                   WHERE Id IN: stdCtrl.getSelected()]);
        
        selectedCompanyTasks = mapACTask.values();
        selectedTaskIds = mapACTask.keySet();
        showProcessButton = selectedTaskIds.size() > 0?true:false;
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to execute batch only for selected tasks on conirmation from UI
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void executeBatchClass(){
        MA_AcqCompanyTaskEnrolWrapper.TaskEnrollerConfig batchConfig = MA_AcqCompanyTaskEnrollerHelper.getBatchConfig();
        MA_AcqCompanyTaskProcessor batchJob = new MA_AcqCompanyTaskProcessor(batchConfig, selectedTaskIds);
        if(!Test.isRunningTest()){
            Database.executeBatch(batchJob, batchConfig.batchSize);
        }
        showProcessButton = false;
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to navigate back to the list view on click of back button
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public PageReference back(){
        PageReference cancel = pageController.cancel();
        return cancel;
    }
    
}