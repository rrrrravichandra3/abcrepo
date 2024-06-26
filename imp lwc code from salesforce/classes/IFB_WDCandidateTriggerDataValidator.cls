/**
* @author Apuroop Gadde
* @date 08-21-2017
* @group TriggerHandlers
* @description Trigger validator for the WDR_Candidate object that handles the validations on integration or user actions from the SIFT side 
*/
public with sharing class IFB_WDCandidateTriggerDataValidator implements WDR_CommonTriggerHandler{
 /**
    * @description Constructor for the class
    **/
    public IFB_WDCandidateTriggerDataValidator() {
    
    }

    /**
    * @description Method to validate integration or user made changes on the before insert event of the WDR_Candidate object 
    **/
    public void beforeInsert() {

    }

    /**
    * @description Method to validate integration or user made changes on the after insert event of the WDR_Candidate object 
    **/
    public void afterInsert() {
    }

    /**
    * @description Method to validate integration or user made changes on the before update event of the WDR_Candidate object  
    **/
    public void beforeUpdate(){

    }

    /**
    * @description Method to validate integration or user made changes on the after update event of the WDR_Candidate object  
    **/
    public void afterUpdate() {
    }

    /**
    * @description Method to validate integration or user made changes on the before delete event of the WDR_Candidate object 
    **/
    public void beforeDelete() {

    }

    /**
    * @description Method to validate integration or user made changes on the after delete event of the WDR_Candidate object 
    **/
    public void afterDelete() {
        
    }

    /**
    * @description Method to validate integration or user made changes on the after undelete event of the WDR_Candidate object  
    **/
    public void afterUnDelete() {
    
    }

}