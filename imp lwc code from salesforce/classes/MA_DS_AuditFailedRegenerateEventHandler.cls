/**
 * W-12578116 & W-12578130
 * Trigger handler for MA_DS_AuditFailedRegenerateEventTrigger
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         30/04/2023      Chakshu Malhotra        Trigger handler logic for MA_DS_AuditFailedRegenerateEventTrigger.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public with sharing class MA_DS_AuditFailedRegenerateEventHandler {
    public static Boolean triggerDisabled = false;

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method invokes the appropriate trigger handler method based on TriggerOperation.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecords 	   	DESCRIPTION (Data type List<MA_DS_Audit_Failed_Regenerate_Event__e>, Trigger.new list)
    * @param    operation 	    DESCRIPTION (Data type TriggerOperation, TriggerOperation enum type)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void handler(List<MA_DS_Audit_Failed_Regenerate_Event__e> newRecords, TriggerOperation operation){
        switch on operation {
            when AFTER_INSERT {
                afterInsert(newRecords);
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method handles after insert logic on MA_DS_Audit_Failed_Regenerate_Event__e records.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecords 	   	DESCRIPTION (Data type List<MA_DS_Audit_Failed_Regenerate_Event__e>, Trigger.new list)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void afterInsert(List<MA_DS_Audit_Failed_Regenerate_Event__e> newRecords) {
        for(MA_DS_Audit_Failed_Regenerate_Event__e newRec : newRecords) {
            MA_DS_AuditFailedRegenerateEventHelper.helperInstance.handleAuditFailureToRegenerate(newRec);
        }
    }   
}