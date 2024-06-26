/**
* @author Apuroop Gadde
* @date 08-21-2017
* @group TriggerHandlers
* @description Trigger validator for the WDR_Application object that handles the validations on integration or user actions from the SIFT side 
*/
public with sharing class IFB_WDApplicationTriggerDataValidator implements WDR_CommonTriggerHandler{
 /**
    * @description Constructor for the class
    **/
    public IFB_WDApplicationTriggerDataValidator() {
    
    }

    /**
    * @description Method to validate integration or user made changes on the before insert event of the WDR_Application object 
    **/
    public void beforeInsert() {

    }

    /**
    * @description Method to validate integration or user made changes on the after insert event of the WDR_Application object 
    **/
    public void afterInsert() {
    }

    /**
    * @description Method to validate integration or user made changes on the before update event of the WDR_Application object  
    **/
    public void beforeUpdate(){
        //validateChangesInGroupOrPosition();
    }

    /**
    * @description Method to validate integration or user made changes on the after update event of the WDR_Application object  
    **/
    public void afterUpdate() {
    }

    /**
    * @description Method to validate integration or user made changes on the before delete event of the WDR_Application object 
    **/
    public void beforeDelete() {

    }

    /**
    * @description Method to validate integration or user made changes on the after delete event of the WDR_Application object 
    **/
    public void afterDelete() {
        
    }

    /**
    * @description Method to validate integration or user made changes on the after undelete event of the WDR_Application object  
    **/
    public void afterUnDelete() {
    
    }

    /**
    * @description Method to validate group or position is not changed by non sysadmins when there are interviews created for the 
    * associated recruit.
    **/
    /*
    private void validateChangesInGroupOrPosition() {
        Set<Id> appIdsWithGroupOrPositionChanges = new Set<Id>();
        for(Id appId : Trigger.newMap.keySet()) {
            if(Trigger.newMap.get(appId).get('SIFT_Group_Lookup__c') != Trigger.oldMap.get(appId).get('SIFT_Group_Lookup__c') || 
                  Trigger.newMap.get(appId).get('SIFT_Position_Lookup__c') != Trigger.oldMap.get(appId).get('SIFT_Position_Lookup__c')) {
                appIdsWithGroupOrPositionChanges.add(appId);
            }
        }
        //Make sure the changes are not being made by Sysadmins
        if(appIdsWithGroupOrPositionChanges.size() != 0) {
            if(SIFT_Settings__c.getInstance() != null && SIFT_Settings__c.getInstance().Allow_Changes_in_SIFT_Group_and_Position__c == true) {
                return;
            }
        }

        List<IFB_Interview__c> listOfRelatedInterviewsForApps = [SELECT Id,Candidate__r.Job_Application_WDR__c FROM IFB_Interview__c 
                                                                 WHERE Candidate__r.Job_Application_WDR__c IN :appIdsWithGroupOrPositionChanges];
        for(IFB_Interview__c interview : listOfRelatedInterviewsForApps) {
            if(appIdsWithGroupOrPositionChanges.contains(interview.Candidate__r.Job_Application_WDR__c) == true) {
                Trigger.newMap.get(interview.Candidate__r.Job_Application_WDR__c).addError(System.Label.IFB_WD_GroupOrPositionChangeError);
                appIdsWithGroupOrPositionChanges.remove(interview.Candidate__r.Job_Application_WDR__c);
            }
        }
    }*/

}