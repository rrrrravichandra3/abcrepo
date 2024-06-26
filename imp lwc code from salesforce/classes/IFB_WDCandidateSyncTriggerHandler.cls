/**
* @author Apuroop Gadde
* @date 06-22-2017
* @group TriggerHandlers
* @description Trigger handler for the WDR_Candidate object that handles the trigger events on Integration sync from the SIFT side 
*/
public with sharing class IFB_WDCandidateSyncTriggerHandler implements WDR_CommonTriggerHandler{
    /**
    * @description Constructor for the class
    **/
    public IFB_WDCandidateSyncTriggerHandler() {
    }

    /**
    * @description Method to propogate changes to SIFT objects on the before insert event of the WDR_Candidate object 
    **/
    public void beforeInsert() {

    }

    /**
    * @description Method to propogate changes to SIFT objects on the after insert event of the WDR_Candidate object 
    **/
    public void afterInsert() {

    }

    /**
    * @description Method to propogate changes to SIFT objects on the before update event of the WDR_Candidate object 
    **/
    public void beforeUpdate(){
    }

    /**
    * @description Method to propogate changes to SIFT objects on the after update event of the WDR_Candidate object 
    **/
    public void afterUpdate() {
        kickOffRelatedRecruitsUpdate();
    }

    /**
    * @description Method to propogate changes to SIFT objects on the before delete event of the WDR_Candidate object 
    **/
    public void beforeDelete() {
    }

    /**
    * @description Method to propogate changes to SIFT objects on the after delete event of the WDR_Candidate object 
    **/
    public void afterDelete() {
        kickOffRelatedRecruitsUpdate();
    }

    /**
    * @description Method to propogate changes to SIFT objects on the after undelete event of the WDR_Candidate object 
    **/
    public void afterUnDelete() {

    }

    /**
    * @description Method to kickoff the update of related recruits update.
    **/
    public void kickOffRelatedRecruitsUpdate() {
        Set<Id> uniqueApplicationIds = new Set<Id>();
        List<Id> idsOfCandidateswithRecruitFieldsChange = IFB_WDUtils.getIdsOfSObjectswithFieldsChange(Trigger.newMap,Trigger.oldMap,
                                                                WDR_Candidate__c.sObjectType,IFB_Interview_Candidate__c.sObjectType);          
        List<WDR_Application__c> relatedApplications = [SELECT Id FROM WDR_Application__c WHERE Candidate__c IN :idsOfCandidateswithRecruitFieldsChange
                                                        AND Candidate_Stage__c NOT IN :IFB_WDUtils.getValuesForCustomSetting('WDR_Rejected_Offer_Status__c')
                                                        AND Candidate_Stage__c NOT IN :IFB_WDUtils.getValuesForCustomSetting('WDR_Rejected_Candidate_Stages__c')];
                                                        
        for(WDR_Application__c relatedApp : relatedApplications) {
            uniqueApplicationIds.add(relatedApp.Id);
        }
        if(uniqueApplicationIds.size() != 0) {
            System.enqueueJob(new IFB_WDApplicationToSIFTRecruit(uniqueApplicationIds,WDR_Candidate__c.sObjectType));        
        }
    }
}