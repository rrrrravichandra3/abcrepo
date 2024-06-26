/**
 * W-10449458 / W-10678114 / W-10702588
 * Trigger handler for MA_AutoEnrolmentEventTrigger
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         24/02/2022      Chakshu Malhotra        Trigger handler logic for MA_AutoEnrolmentEventTrigger.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public class MA_AutoEnrolmentEventTriggerHandler {
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method invokes the appropriate trigger handler method based on TriggerOperation.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecords 	   	DESCRIPTION (Data type List<MA_Auto_Enrolment_Event__e>, Trigger.new list)
    * @param    operation 	    DESCRIPTION (Data type TriggerOperation, TriggerOperation enum type)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void handler(List<MA_Auto_Enrolment_Event__e> newRecords, TriggerOperation operation){
        switch on operation {
            when AFTER_INSERT {
                afterInsert(newRecords);
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method handles after insert logic on MA_Auto_Enrolment_Event__e records.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecords 	   	DESCRIPTION (Data type List<MA_Auto_Enrolment_Event__e>, Trigger.new list)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void afterInsert(List<MA_Auto_Enrolment_Event__e> newRecords) {
        MA_AutoEnrolmentEventTriggerHelper.autoEnrolAcquisitionContacts(newRecords);
    }
}