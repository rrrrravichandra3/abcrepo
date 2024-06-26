/**
* @author Anchana Rajamathe
* @date 07-12-2017
* @group NHW
* @description This scheduled job does the below
* 1.Identify job Applications in placement stage which 
*    - Do not have provisoning case or have prov cases in new status 
*    - And new hire start date in following week. 
* 2.Send Autoprov notification email to Auto-provisioning team - IT NH Admin role.
* 2.Add them as delegates to respective hiring managers.
* 3.Update Auto prov flag on job Application.
* 
* Scheduled run : Weekly Thursday Noon.
*/
global with sharing class NHW_WDRAutoprovisioningNotification implements Schedulable {
    
    global NHW_WDRAutoprovisioningNotification(){
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

        Set<Id> noOnBoardingCasePlacementList = new Set<Id>();
        datetime currDttime = datetime.now();
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
        //QueueSObject queue = [SELECT SobjectType,QueueId,Id,Queue.DeveloperName FROM QueueSobject where SObjectType = 'Case' and Queue.DeveloperName = 'NHW_Autoprovisioning_Admin'];
        //Select placements with NHW cases having SD in the next week. Job runs on Thursday.
        //If the placements have either  provisioning case in status 'New' or no provisioning case - pick it up for autoprovisioning.

        
        Map<Id, List<Case>> pendingOnboardingCaseList = NHW_Util.getPendingCasesForAutoprovisioning(currDttime);
        
        if(!pendingOnboardingCaseList.keyset().isEmpty()){
        
           for(Id JobAppId : pendingOnboardingCaseList.keyset()){
            
             if(!pendingOnboardingCaseList.get(JobAppId).isEmpty()){
        
                for(Case c: pendingOnboardingCaseList.get(JobAppId)){
                
                  for(Contact con : adminContacts){
                         if(c.contactId!=null){
                          adminHMComboList.add(new NHW_Util.Admin2HiringManager(c.contactId,con.Id,String.valueOf(con.Id)+String.valueOf(c.contactId)));
                          system.debug('*****adminHMComboList' + adminHMComboList);
                         }
                    }                   
                }
                
                }
        
            }
        }
        
        system.debug(LOGGINGLEVEL.INFO,'Pending Job App ids:'+pendingOnboardingCaseList.keyset());
        system.debug(LOGGINGLEVEL.INFO,'adminHMComboList:'+adminHMComboList);
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
        //Send notification and update flag on job Application.
        if(pendingOnboardingCaseList.size() > 0){
            List<WDR_Application__c> updateAutoProvisioningCheckboxJobApp= new List<WDR_Application__c>();
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setTemplateId(emailTemp.Id);
            mail.setSaveAsActivity(false);
            mail.setTargetObjectId(adminContacts[0].Id);
            for(OrgWideEmailAddress owa : [select id,Address,displayName from OrgWideEmailAddress]){
              if(owa.displayName.contains('New Hire Wizard Team'))
                  mail.setOrgWideEmailAddressId(owa.id);
            }       
            system.debug(logginglevel.INFO,'******mail ' + mail);
                    
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            mailList.add(mail);
            
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mailList);
            if (!results.get(0).isSuccess()) {
                system.debug(LOGGINGLEVEL.INFO,'Inside email unsuccessful');
                System.StatusCode statusCode = results.get(0).getErrors()[0].getStatusCode();
                String errorMessage = results.get(0).getErrors()[0].getMessage();
                PF_Logger.log('NHW','ERROR',' Error in  sending Autoprovisioning notification', '', '' + errorMessage , 'NHW_AutoProvisioningNotification');
            }

            for(WDR_Application__c JobApp:[select Id,Auto_Provisioning_Email_Sent__c  from WDR_Application__c where Id in:pendingOnboardingCaseList.keySet()]){
                system.debug(LOGGINGLEVEL.INFO,'InsideAutoprovUpdate Job App');
                JobApp.Auto_Provisioning_Email_Sent__c  = true;
                updateAutoProvisioningCheckboxJobApp.add(JobApp);
            }
                
            system.debug(LOGGINGLEVEL.INFO,'Job Apps for update provision checkbox '+updateAutoProvisioningCheckboxJobApp);

            
            if(updateAutoProvisioningCheckboxJobApp.size()>0 && WDR_Application__c.sObjectType.getDescribe().isUpdateable()){
                try{
                    Database.update(updateAutoProvisioningCheckboxJobApp, false);
                } 
                catch(Exception ex){
                    system.debug(LOGGINGLEVEL.INFO,' Error in the updating Auto_Provisioning_Email_Sent__c '+ex);
                    PF_Logger.log('NHW','ERROR',ex.getMEssage(),ex.getTypeName(), ex.getLineNumber()+' Error in the updating Auto_Provisioning_Email_Sent__c flag for JOB Apps ' + updateAutoProvisioningCheckboxJobApp, 'NHW_WDRAutoProvisioningNotification');  
                }
            }
        }
    }  
}