/**
* @author Apuroop Gadde
* @date 06-26-2017
* @group TriggerDataValidators
* @description Trigger handler to validate trigger data on events for WDR_Application__c 
*/
public with sharing class WDR_ApplicationTriggerDataValidator implements WDR_CommonTriggerHandler{
    /**
    * @description Constructor
    **/
    public WDR_ApplicationTriggerDataValidator() {
    }

    /**
    * @description Method to validate records on before insert event on the WDR_Application__c object
    **/
    public void beforeInsert() {
        if(Trigger.isExecuting && Trigger.new != null) {         
            WDR_CommonTriggerUtils.validateRequiredFields(WDR_Application__c.sObjectType,Trigger.new);    
        }    
    }

    /**
    * @description Method to validate records on after insert event on the WDR_Application__c object
    **/
    public void afterInsert() {
    }

    /**
    * @description Method to validate records on before update event on the WDR_Application__c object
    **/
    public void beforeUpdate(){
        if(Trigger.isExecuting && Trigger.new != null) {         
            WDR_CommonTriggerUtils.validateRequiredFields(WDR_Application__c.sObjectType,Trigger.new);  
        }      
    }

    /**
    * @description Method to validate records on after update event on the WDR_Application__c object
    **/
    public void afterUpdate() {
    }

    /**
    * @description Method to validate records on before delete event on the WDR_Application__c object
    **/
    public void beforeDelete() {
    }

    /**
    * @description Method to validate records on after delete event on the WDR_Application__c object
    **/
    public void afterDelete() {
    }

    /**
    * @description Method to validate records on after undelete event on the WDR_Application__c object
    **/
    public void afterUnDelete() {
    }
}