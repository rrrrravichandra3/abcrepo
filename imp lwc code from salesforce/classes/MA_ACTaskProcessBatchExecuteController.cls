/**
* @description       : Apex controller for MA_ACTaskProcessBatchExecute
* @author            : Satyam Kumar
* Modifications Log 
* Ver   Date         Author          Modification
* 1.0   22-06-2021   Satyam Kumar   Initial Version
* */
public class MA_ACTaskProcessBatchExecuteController {

    //Method to call MA_ACTaskProcessBatch
    @AuraEnabled
    public static Boolean callTaskProcessBatch(Id recId){
        Boolean isActive = [Select Active__c from Acquisition_Company_Task__c where Id =: recId].Active__c;
        if(isActive) {
            MA_ACTaskProcessBatch batch = new MA_ACTaskProcessBatch();
            Database.executeBatch(batch, Integer.valueOf(MA_Util.getTaskManagementSettings().ACTaskProcessBatch_Size__c));
             return true;
        } else {
            return false;
        }
    }
}