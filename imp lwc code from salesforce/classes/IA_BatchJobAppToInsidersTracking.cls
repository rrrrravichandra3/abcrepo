/*
 * @description : Batch job to Insiders Tracking
 * @params : bc batchableContext,scope List<WDR_Application__c>
*/
public class IA_BatchJobAppToInsidersTracking implements Database.Batchable<sObject>, Database.Stateful {
	public Database.QueryLocator start(Database.BatchableContext bc) {
        String queryString = 'SELECT Id, Candidate__r.Invitation_Email_Sent__c ' +
            				 'FROM WDR_Application__c ' +
            				 'WHERE Candidate__r.Invitation_Email_Sent__c = true';
        
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext bc, List<WDR_Application__c> scope) {
        //get IA_CheckFLS class name
        String checkFLSClass = IA_Util.InsiderConfigDefaultRec.FLSCheckClassName__c;
        Type t = Type.forName(checkFLSClass);
        if(((IA_FLSCheckInterface)t.newInstance()).canUpdateObject('Insiders_Tracking__c') && ((IA_FLSCheckInterface)t.newInstance()).canReadObject('Insiders_Tracking__c') && ((IA_FLSCheckInterface)t.newInstance()).canCreateObject('Insiders_Tracking__c')){
            
                List<Insiders_Tracking__c> newData = new List<Insiders_Tracking__c>();
                for (WDR_Application__c jobApp : scope) {
                    Insiders_Tracking__c newInsidersTrackingRecord = new Insiders_Tracking__c();
                    newInsidersTrackingRecord.Invitation_Email_Sent__c = true;
                    newInsidersTrackingRecord.Recruiter_Email_Sent__c = true;
                    newInsidersTrackingRecord.Reminder_Email_Sent__c = true;
                    newInsidersTrackingRecord.WD_Job_Application__c  = jobApp.Id;
                    newData.add(newInsidersTrackingRecord);
                } 
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, newData);

            if(!securityDecision.getRecords().isEmpty()){
                insert securityDecision.getRecords();
            }
            //insert newData; 
        }      
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('Batch job finished successfully.');
    }
}