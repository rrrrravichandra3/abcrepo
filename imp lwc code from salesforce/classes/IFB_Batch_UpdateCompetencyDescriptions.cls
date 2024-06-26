/*
* 
*  @Author : Kshitiz Srivastava
*  W-4666152 - SIFT Refactoring
*  This batch job is to be run once for April A release
*  After refactoring, competency description (IFB_Competency_Description__c) object's field Interview_Record_Type__c, Group__c and Position__c are to be replaced by lookup fields SIFT_Interview_Type_Lookup__c, SIFT_Group_Lookup__c, SIFT_Position_Lookup__c
*
*/
global class IFB_Batch_UpdateCompetencyDescriptions implements Database.Batchable<sObject>, Database.Stateful{
    
    Integer successfulUpdateCount = 0;
    Map<String, String> recordTypeDevNameToLabel = new Map<String, String>();
    Map<String, Id> siftIntvTypeNameToIdMap = new Map<String, Id>();
    Map<Id, String> sitfIntvTypeIdToGroupMap = new Map<Id,String>();
    Map<String, Id> siftGroupNameToIdMap = new Map<String, Id>();
    Map<String, Id> positionNameToIdMap = new Map<String, Id>();
    Map<String, String> failedUpdates = new Map<String, String>();

    global IFB_Batch_UpdateCompetencyDescriptions(){
        //get the record types of SIFT Interviews
        List<RecordType> intvRecordTypes = [select Id, Name, DeveloperName from RecordType where SObjectType = 'IFB_Interview__c'];
        for(RecordType rt : intvRecordTypes){
            recordTypeDevNameToLabel.put(rt.DeveloperName, rt.Name);
        }
        //get records of SIFT Interview Types
        List<SIFT_Interview_Type__c> intvTypes = [Select Id, Name, SIFT_Group__c, SIFT_Group__r.Name from SIFT_Interview_Type__c];
        for(SIFT_Interview_Type__c si : intvTypes){
            siftIntvTypeNameToIdMap.put(si.Name, si.Id);
            sitfIntvTypeIdToGroupMap.put(si.Id, si.SIFT_Group__r.Name);
        }
        //get records of SIFT Groups
        List<SIFT_Group__c> siftGroups = [Select Id, Name from SIFT_Group__c];
        for(SIFT_Group__c sg : siftGroups){
            siftGroupNameToIdMap.put(sg.Name, sg.Id);
        }
        //get records of SIFT Position
        List<SIFT_Position__c> siftPositions = [Select Id, Name, SIFT_Group__c, SIFT_Group__r.Name from SIFT_Position__c];
        for(SIFT_Position__c sp : siftPositions){
            positionNameToIdMap.put(sp.Name + sp.SIFT_Group__r.Name,sp.Id);
        }

    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        String queryString = 'Select Id, Interview_Record_Type__c, SIFT_Interview_Type_Lookup__c, Group__c, SIFT_Group_Lookup__c, Position__c, SIFT_Position_Lookup__c from IFB_Competency_Description__c';
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext BC, List<IFB_Competency_Description__c> scope){
        List<IFB_Competency_Description__c> competencyDescToBeUpdated = new List<IFB_Competency_Description__c>();

        for(IFB_Competency_Description__c currentDesc : scope){
            //update Interview Type Lookup field
            if(!String.isBlank(currentDesc.Interview_Record_Type__c)){
                if(!recordTypeDevNameToLabel.containsKey(currentDesc.Interview_Record_Type__c)){
                    failedUpdates.put(String.ValueOf(currentDesc.Id),'Cannot find Corresponding Interview Record Type');
                    continue;
                }
                String intvTypeName = recordTypeDevNameToLabel.get(currentDesc.Interview_Record_Type__c);
                if(!siftIntvTypeNameToIdMap.containsKey(intvTypeName)){
                    failedUpdates.put(String.ValueOf(currentDesc.Id),'Cannot find a SIFT Interview Type with name '+intvTypeName);
                    continue;
                }
                currentDesc.SIFT_Interview_Type_Lookup__c = siftIntvTypeNameToIdMap.get(intvTypeName);
            }
            //update SIFT Group Lookup field
            if(!String.isBlank(currentDesc.Group__c)){
                if(!siftGroupNameToIdMap.containsKey(currentDesc.Group__c)){
                    failedUpdates.put(String.ValueOf(currentDesc.Id),'Cannot find SIFT Group record with Name '+currentDesc.Group__c);
                    continue;
                }
                currentDesc.SIFT_Group_Lookup__c = siftGroupNameToIdMap.get(currentDesc.Group__c);
            }
            //update SIFT Position
            if(!String.isBlank(currentDesc.Position__c)){
                //if position is populated, atleast group or interview type must be populated/evaluated
                String positionName = currentDesc.Position__c;
                if(currentDesc.SIFT_Interview_Type_Lookup__c == null &&  String.isBlank(currentDesc.Group__c)){
                    failedUpdates.put(String.ValueOf(currentDesc.Id),'Cannot determine Position because atleast group or interview type must be present');
                    continue;
                }
                //get group name from group field or from InterviewType.
                String groupName;
                if(!String.isBlank(currentDesc.Group__c)){
                    groupName = currentDesc.Group__c;
                }else{
                    groupName = sitfIntvTypeIdToGroupMap.get(currentDesc.SIFT_Interview_Type_Lookup__c); 
                }
                currentDesc.SIFT_Position_Lookup__c = positionNameToIdMap.get(positionName+groupName);
            }
            competencyDescToBeUpdated.add(currentDesc);
        }

        Database.SaveResult[] updateResult = Database.Update(competencyDescToBeUpdated,false);

        for(Integer i=0;i<updateResult.size();i++){
            if(updateResult.get(i).isSuccess()){
                successfulUpdateCount ++;
            }else{
                String failedCompDescName = String.ValueOf((scope.get(i)).Id);
                String errorMessage = '';
                for(Database.Error err : updateResult.get(i).getErrors()){
                    errorMessage = errorMessage + ' | ' + err.getMessage();
                }
                failedUpdates.put(failedCompDescName,errorMessage);
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
        mail.setSenderDisplayName('SIFT Competency Description Update Batch');
        mail.setSubject('Batch IFB_Batch_UpdateCompetencyDescriptions results');

        String message = successfulUpdateCount + ' SIFT Competency Description Records updated successfully';
        if(!failedUpdates.isEmpty()){
            message = message + '\nFollowing ' + failedUpdates.size() +' Competency Description Records Failed to Update :\n';
            for(String compDescName : failedUpdates.keySet()){
                message = message +'\n'+compDescName + ' : '+failedUpdates.get(compDescName);
            }
        }
        mail.setPlainTextBody(message);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
    }

}