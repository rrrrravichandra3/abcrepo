/*
 *
 * $Author: Charu Goyal
 * $Date: October 17, 2014
 * $Description: Scheduled Job to send Report of pending New Hires to Auto-provisioning team
 
 ChangeHistory: 
 

*/ 
global with sharing class NHW_AutoProvisioningNotification implements Schedulable {
    
    global NHW_AutoProvisioningNotification(){
    }
 
    global void execute(SchedulableContext SC){
        try{
            sendAutoProvisioningReportEmail();
        }catch(exception ex){ 
           system.debug(LOGGINGLEVEL.INFO,'Generic Exception in the job '+ ex);
           PF_Logger.log('NHW','ERROR',ex.getMessage(),'', ' Error in the NHW_AutoProvisioningNotification' + ex, 'NHW_AutoProvisioningNotification');  
        }finally{
            NHW_Util.insertNHWLogs();
        }
             
    }


    global void sendAutoProvisioningReportEmail(){
        Map<Id,Case> pendingOnboardingCaseList = new Map<Id,Case>();
        Set<Id> noOnBoardingCasePlacementList = new Set<Id>();
        datetime myDateTime = datetime.now();
        EmailTemplate emailTemp = ESDJC_Util.getEmailTemplate('Auto_Provisioning_Notification');
        //W-3433695 - NH Admins are defined by role not queue.
        //List<Contact> adminContacts = NHW_Util.getAdminContactsByQueue('NHW_Autoprovisioning_Admin');
        List<Contact> adminContacts = NHW_Util.getAdminContactsByRole('IT NH Admin'); 
        List<String> toAddresses = new List<String>();
        boolean isSetToAdmin;
        List<NHW_Util.Admin2HiringManager> adminHMComboList = new List<NHW_Util.Admin2HiringManager>();
        for(Contact c:adminContacts){
            toAddresses.add(c.Email);
        }
        
        //Add the admins as delegates for hiring managers for above cases picked for autoprovisioning.
        if(adminHMComboList.size()>0){
            Database.SaveResult[] results = NHW_Util.insertDelegateForAdmins(adminHMComboList);
            String errorDescription = '';
            Boolean sawError = false;
            // Iterate through each returned result
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    sawError = true;
                     errorDescription = errorDescription+ ' The following error(s) have occurred. ';
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        errorDescription= errorDescription + ' ' +err.getStatusCode() + ': ' + err.getMessage()+ ' Fields that affected this error: '+err.getFields();
                    }
                }
            }
            if(sawError){
               system.debug(LOGGINGLEVEL.INFO,' Error in  inserting delegates - '+errorDescription);
               PF_Logger.log('NHW','ERROR',' Error in  inserting delegates ' , '', errorDescription,'NHW_AutoProvisioningNotification');
            }

        }
        
}
    
    
}