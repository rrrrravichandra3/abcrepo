/*
*  @Author : Kshitiz Srivastava
*  W-4666152 - SIFT Refactoring
*  This batch job is to be run once for April A release
*  After refactoring, WD Job Application Object has two new lookup fields SIFT_Group_Lookup__c and SIFT_Position_Lookup__c which need to be populated based on existing value of fields SIFT_Group__c and SIFT_Position__c
*
*/ 
global class IFB_Batch_UpdateWDJobApplications implements Database.Batchable<sObject>, Database.Stateful{
    
    //Set<String> failedRecruitUpdates = new Set<String>();
    Map<String,String> failedApplications = new Map<String,String>();
    Integer successfulUpdateCount = 0;
    Map<String,Id> groupNameToIdMap = new Map<String,Id>();
    Map<String,Id> positionNameToIdMap = new Map<String,Id>();

    global IFB_Batch_UpdateWDJobApplications(){
        //get all existing reocrds of object SIFT_Group__c
        List<SIFT_Group__c> existingSIFTGroupRecords = [Select Id, Name from SIFT_Group__c];
        for(SIFT_Group__c siftGroup : existingSIFTGroupRecords){
            groupNameToIdMap.put(siftGroup.Name, siftGroup.Id);
        }
        //get all existing records of object SIFT_Position__c
        //even though position names seems to be unique, we take precaution of using position + group name as key to identifying position record
        List<SIFT_Position__c> existingSIFTPositionRecords = [Select Id, Name, SIFT_Group__r.Name from SIFT_Position__c];
        for(SIFT_Position__c pos : existingSIFTPositionRecords){
            positionNameToIdMap.put(pos.Name+pos.SIFT_Group__r.Name,pos.Id);
        }

    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        String queryString = 'Select Id,SIFT_Group__c,SIFT_Position__c, SIFT_Group_Lookup__c, SIFT_Position_Lookup__c from WDR_Application__c where SIFT_Group_Lookup__c = null OR  SIFT_Position_Lookup__c = null';
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext BC, List<WDR_Application__c> scope){
        List<WDR_Application__c> jobAppsToBeUpdated = new List<WDR_Application__c>();

        for(WDR_Application__c currApp : scope){
            //handle error scenarios
            //if original group and position fields are blank
            if(String.isBlank(currApp.SIFT_Group__c) || String.isBlank(currApp.SIFT_Position__c)){
                failedApplications.put(String.ValueOf(currApp.Id), 'Group or Position Picklist Value is Empty on the Record');
                continue;
            }
            //group field is populated, but cant find a SIFT Group record
            if(!groupNameToIdMap.containsKey(currApp.SIFT_Group__c)){
                failedApplications.put(String.ValueOf(currApp.Id),'Group '+ currApp.SIFT_Group__c + ' did not match with any existing record of SIFT Group object');
                continue;
            }
            //Position and group fields are populated, but cant find a corresponding SIFT Position record
            if(!positionNameToIdMap.containsKey(currApp.SIFT_Position__c+currApp.SIFT_Group__c)){
                failedApplications.put(String.ValueOf(currApp.Id),'Position '+ currApp.SIFT_Position__c + ' did not match with any existing record of SIFT Position object');
                continue;
            }
            //all errors handle. Proceed with update
            currApp.SIFT_Group_Lookup__c = groupNameToIdMap.get(currApp.SIFT_Group__c);
            currApp.SIFT_Position_Lookup__c = positionNameToIdMap.get(currApp.SIFT_Position__c+currApp.SIFT_Group__c);
            jobAppsToBeUpdated.add(currApp);
        }

        Database.SaveResult[] updateResult = Database.Update(jobAppsToBeUpdated,false);

        for(Integer i=0;i<updateResult.size();i++){
            if(updateResult.get(i).isSuccess()){
                successfulUpdateCount ++;
            }else{
                String jobAppId = String.ValueOf((scope.get(i)).Id);
                String errorMessage = '';
                for(Database.Error err : updateResult.get(i).getErrors()){
                    errorMessage = errorMessage + ' | ' + err.getMessage();
                }
                failedApplications.put(jobAppId,errorMessage);
            }
        }
    }

    global void finish(Database.BatchableContext BC){
        //list of recipients for email
        List<String> emailIds = new List<String>();
        emailIds.add('ksrivastava@salesforce.com');
        //get the emails stored in custom setting
        String emailIdsFromCustomSetting = IFB_SIFT_Settings_List__c.getInstance('SIFT').IFB_WD_Integration_Downstream_Err_Emails__c;
        if(!String.isEmpty(emailIdsFromCustomSetting)){
            emailIds.addAll(emailIdsFromCustomSetting.split(','));
        }

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(emailIds);
        mail.setSenderDisplayName('WD Job App Update Batch');
        mail.setSubject('Batch IFB_Batch_UpdateWDJobApplications results');

        String message = successfulUpdateCount + ' WD Job Application Records updated successfully';
        if(!failedApplications.isEmpty()){
            message = message + '\nFollowing WD Job Application Records Failed to Update :\n';
            for(String recId : failedApplications.keySet()){
                message = message +'\n'+recId +' - '+failedApplications.get(recId);
            }
        }
        mail.setPlainTextBody(message);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
    }

}