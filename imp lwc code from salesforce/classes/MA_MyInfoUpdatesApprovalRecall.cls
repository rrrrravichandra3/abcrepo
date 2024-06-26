/**
 * Created by Satyam on 04/05/21.
 * This apex class is invoked from MA My Info Update Process flow to recall the approval process
 */

global class MA_MyInfoUpdatesApprovalRecall
{
   @InvocableMethod
    webservice static void recallApproval(List<Id> recId)   
    {       
        List<ProcessInstanceWorkitem> piwi = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: recId limit 1];
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setAction('Removed');       
        req.setWorkitemId(piwi.get(0).Id);
   
        Approval.process(req,false);
    }
}