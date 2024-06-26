/**
* @author Apuroop Gadde
* @date 06-26-2017
* @group TriggerDataValidators
* @description Trigger handler to validate trigger data on events for WDR_Candidate__c 
*/
public with sharing class WDR_CandidateTriggerDataValidator implements WDR_CommonTriggerHandler{    
    /**
    * @description Constructor
    **/
    public WDR_CandidateTriggerDataValidator() {

    }

    /**
    * @description Method to validate records before insert event on the WDR_Candidate__c object
    **/
    public void beforeInsert() {
        if(Trigger.isExecuting && Trigger.new != null) {  
            WDR_CommonTriggerUtils.validateRequiredFields(WDR_Candidate__c.sObjectType,Trigger.new); 
        }       
    }

    /**
    * @description Method to validate records after insert event on the WDR_Candidate__c object
    **/
    public void afterInsert() {
    }

    /**
    * @description Method to validate records before update event on the WDR_Candidate__c object
    **/
    public void beforeUpdate(){
        if(Trigger.isExecuting && Trigger.new != null) {         
            WDR_CommonTriggerUtils.validateRequiredFields(WDR_Candidate__c.sObjectType,Trigger.new);
        }        
    }

    /**
    * @description Method to validate records after update event on the WDR_Candidate__c object
    **/
    public void afterUpdate() {
    }

    /**
    * @description Method to validate records before delete event on the WDR_Candidate__c object
    **/
    public void beforeDelete() {
    }

    /**
    * @description Method to validate records after delete event on the WDR_Candidate__c object
    **/
    public void afterDelete() {
    }

    /**
    * @description Method to validate recordsafter undelete event on the WDR_Candidate__c object
    **/
    public void afterUnDelete() {
    }

}