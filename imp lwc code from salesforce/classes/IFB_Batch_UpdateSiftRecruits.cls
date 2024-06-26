/*
*  @Author : Kshitiz Srivastava
*  W-4666152 - SIFT Refactoring
*  This batch job is to be run once for April A release
*  After refactoring, Recruit Object has two new lookup fields SIFT_Group__c and SIFT_Position__c which need to be populated based on existing value of fields Group__c and Position__c
*
*/
global class IFB_Batch_UpdateSiftRecruits implements Database.Batchable<sObject>, Database.Stateful{
    
    //Set<String> failedRecruitUpdates = new Set<String>();
    Map<String,String> failedRecruitUpdates = new Map<String,String>();
    Integer successfulUpdateCount = 0;
    Map<String,Id> groupNameToIdMap = new Map<String,Id>();
    Map<String,Id> positionNameToIdMap = new Map<String,Id>();

    global IFB_Batch_UpdateSiftRecruits(){
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
        String queryString = 'Select Id,Group__c,SIFT_Group__c,Position__c,SIFT_Position__c from IFB_Interview_Candidate__c where SIFT_Group__c = null OR SIFT_Position__c = null';
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext BC, List<IFB_Interview_Candidate__c> scope){
        List<IFB_Interview_Candidate__c> recruitsToBeUpdaed = new List<IFB_Interview_Candidate__c>();

        for(IFB_Interview_Candidate__c currRecruit : scope){
            //handle error scenarios
            //if orginial group or position picklist field is empty
            if(String.isBlank(currRecruit.Group__c) || String.isBlank(currRecruit.Position__c)){
                failedRecruitUpdates.put(String.ValueOf(currRecruit.Id),'Group or Position picklist field is Empty');
                continue;
            }
            //if group picklist is populated, but cant find a SIFT Group record
            if(!groupNameToIdMap.containsKey(currRecruit.Group__c)){
                failedRecruitUpdates.put(String.ValueOf(currRecruit.Id),'Cannot find a SIFT Group record with Name '+ currRecruit.Group__c);
                continue;
            }
            //group and position, both picklist populated, but cannot find SIFT Position record
            if(!positionNameToIdMap.containsKey(currRecruit.Position__c + currRecruit.Group__c)){
                failedRecruitUpdates.put(String.ValueOf(currRecruit.Id),'Cannot find a SIFT Position record for Positon '+currRecruit.Position__c);
                continue;
            }
            //no errors. Proceed with update
            currRecruit.SIFT_Group__c = groupNameToIdMap.get(currRecruit.Group__c);
            currRecruit.SIFT_Position__c = positionNameToIdMap.get(currRecruit.Position__c + currRecruit.Group__c);
            recruitsToBeUpdaed.add(currRecruit);
        }

        Database.SaveResult[] updateResult = Database.Update(recruitsToBeUpdaed,false);

        for(Integer i=0;i<updateResult.size();i++){
            if(updateResult.get(i).isSuccess()){
                successfulUpdateCount ++;
            }else{
                String recruitId = String.ValueOf((scope.get(i)).Id);
                String errorMessage = '';
                for(Database.Error err : updateResult.get(i).getErrors()){
                    errorMessage = errorMessage + ' | ' + err.getMessage();
                }
                failedRecruitUpdates.put(recruitId,errorMessage);
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
        mail.setSenderDisplayName('SIFT Recruits Update Batch');
        mail.setSubject('Batch IFB_Batch_UpdateSiftRecruits results');

        String message = successfulUpdateCount + ' SIFT Recruit Records updated successfully';
        if(!failedRecruitUpdates.isEmpty()){
            message = message + '\nFollowing Recruit Records Failed to Update :\n';
            for(String recId : failedRecruitUpdates.keySet()){
                message = message +'\n'+recId +' - '+failedRecruitUpdates.get(recId);
            }
        }
        mail.setPlainTextBody(message);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
    }

}