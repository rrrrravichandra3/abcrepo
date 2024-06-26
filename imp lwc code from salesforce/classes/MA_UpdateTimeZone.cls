/**
* @description       : Batch apex to update User timezone based on Acquisition Contact timezone
* @author            : Satyam Kumar
* Modifications Log 
* Ver   Date            Author                  Modification
* 1.0   20-07-2021      Satyam Kumar            Initial Version
* 2.0   15-11-2021      Chakshu Malhotra        W-10149711 : Commented batch scheduling to decommission in future releases
*/
global without sharing class MA_UpdateTimeZone implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String acTaskQuery = 'Select Id,TimeZoneSidKey, Contact.Acquisition_Contacts__c, Contact.Acquisition_Contacts__r.Time_Zone__c From User Where Contact.Acquisition_Contacts__r.Time_Zone__c != null AND Contact.Acquisition_Contacts__r.User_Time_Zone_Updated__c = False';
        return Database.getQueryLocator(acTaskQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<User> scope){
        try 
        {
            List<User> userToUpdateList = new List<User>();
            List<Acquisition_Contacts__c> acqContactToUpdateList = new List<Acquisition_Contacts__c>();
            //Poplulate timezone 
            for(User u: scope) {
                if(u.TimeZoneSidKey != u.Contact.Acquisition_Contacts__r.Time_Zone__c) {
                    u.TimeZoneSidKey = u.Contact.Acquisition_Contacts__r.Time_Zone__c;
                    userToUpdateList.add(u);
                }
                acqContactToUpdateList.add(new Acquisition_Contacts__c(Id = u.Contact.Acquisition_Contacts__c, User_Time_Zone_Updated__c = true));
            }
            
            //Update User
            if(userToUpdateList != null && !userToUpdateList.isEmpty()) {
                Database.SaveResult[] userResultList = Database.update(userToUpdateList,false);
                for(Integer i=0; i<userResultList.size();i++)
                {
                    Database.SaveResult result = userResultList.get(i);
                    if(!result.isSuccess()) {
                        PF_Logger.log('MA','ERROR',String.valueOf(result.getErrors()),null,'Error during User Timezone update', 'MA_UpateUserTimeZone');
                    } 
                }
            }
            
            //Update Acquisition Contact
            if(acqContactToUpdateList != null && !acqContactToUpdateList.isEmpty()) {
                Database.SaveResult[] acqContacttList = Database.update(acqContactToUpdateList,false);
                for(Integer i=0; i<acqContacttList.size();i++)
                {
                    Database.SaveResult result = acqContacttList.get(i);
                    if(!result.isSuccess()) {
                        PF_Logger.log('MA','ERROR',String.valueOf(result.getErrors()),null,'Error during Acquisition contact update', 'MA_UpateUserTimeZone');
                    }
                }
            }
        } catch(Exception e)
        {
            PF_Logger.log('MA','ERROR',e.getMessage(),null,'Error during update. Error Trace : ' + e.getStackTraceString(), 'MA_UpdateTimeZone');
            PF_Logger.createLogs(PF_Logger.logs);
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        // W-10149711 : The batch will soon be decommissioned as the timezone details will now be updated as part of JIT provisioning of SSO users.
        // Only manual execution of batch is allowed for now in case of failure of timezone update through JIT provisioning. 
        // If successful, the batch will be removed in future releases.
        //system.scheduleBatch(New MA_UpdateTimeZone(),'MA_UpdateTimeZone ' + DateTime.now().getTime(),15, 200);
    } 
    
}