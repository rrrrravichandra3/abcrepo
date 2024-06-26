/**
* @author Apuroop Gadde
* @date 08-21-2017
* @group TriggerHandlers
* @description Trigger validator for the WDR_Job object that handles the validations on integration or user actions from the SIFT side 
*/
public with sharing class IFB_WDJobTriggerDataValidator implements WDR_CommonTriggerHandler{
 /**
    * @description Constructor for the class
    **/
    public IFB_WDJobTriggerDataValidator() {
    
    }

    /**
    * @description Method to validate user made changes on the before insert event of the WDR_Job object 
    **/
    public void beforeInsert() {

    }

    /**
    * @description Method to validate user made changes on the after insert event of the WDR_Job object 
    **/
    public void afterInsert() {
    }

    /**
    * @description Method to validate user made changes on the before update event of the WDR_Job object  
    **/
    public void beforeUpdate() {
        system.debug('Inside IFB_WDJobTriggerDataValidator');
        if(Trigger.isExecuting && Trigger.new != null) { 
            restricGroupPostionModification(Trigger.new, Trigger.oldMap);
        }  
    }

    /**
    * @description Method to validate user made changes on the after update event of the WDR_Job object 
    **/
    public void afterUpdate() {
    }

    /**
    * @description Method to validate user made changes on the before delete event of the WDR_Job object  
    **/
    public void beforeDelete() {

    }

    /**
    * @description Method to validate user made changes on the after delete event of the WDR_Job object 
    **/
    public void afterDelete() {
        
    }

    /**
    * @description Method to validate user made changes on the after undelete event of the WDR_Job object 
    **/
    public void afterUnDelete() {
    
    }
    
     /**
    * @description Method to validate group or position is not changed by non sysadmins when there are interviews created for the 
    * associated recruit.
    **/
    private static void restricGroupPostionModification(List<WDR_Job__c> newList, Map<Id,sobject> oldMap){
        //Bypass system admin profiles/permsets
        if(!FeatureManagement.checkPermission('IFB_WD_Allow_Group_and_Position_Modification')){
            Set<Id> modifiedJobIdsSet = new Set<Id>();
            Set<Id> affectedJobIdsSet = new Set<Id>();
            List<String> PreInterviewStages = new List<String>{'Screen', 'Technical Assessment','Assessment'};
            
            for(WDR_Job__c newJob : newList) {
                
                WDR_Job__c oldJob = (WDR_Job__c)oldMap.get(newJob.Id);
                
                if((oldJob.SIFT_Group__c != Null && newJob.SIFT_Group__c !=  oldJob.SIFT_Group__c) || (oldJob.SIFT_Position__c != Null && newJob.SIFT_Position__c !=  oldJob.SIFT_Position__c)) {
                    modifiedJobIdsSet.add(newJob.Id);
                }
            }
            
            for(WDR_Application__c jobApp: [Select Job__c From WDR_Application__c 
                                            where Job__c IN: modifiedJobIdsSet AND Candidate_Stage__c NOT IN: PreInterviewStages
                                            AND SIFT_Group_Lookup__c != Null AND SIFT_Position_Lookup__c != Null]) {
                affectedJobIdsSet.add(jobApp.Job__c);
            }
            
            for(WDR_Job__c newJob : newList) {
                if(affectedJobIdsSet.contains(newJob.Id)) {
                    newJob.addError(System.Label.IFB_WD_GroupOrPositionChangeError);
                }
            }
        }
    }

}