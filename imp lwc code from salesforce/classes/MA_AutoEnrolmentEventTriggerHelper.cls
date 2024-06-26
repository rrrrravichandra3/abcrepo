/**
 * W-10449458 / W-10678114 / W-10702588
 * Trigger helper class for MA_AutoEnrolmentEventTriggerHandler
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         24/02/2022      Chakshu Malhotra        Trigger helper logic for MA_AutoEnrolmentEventTriggerHandler.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public class MA_AutoEnrolmentEventTriggerHelper {

    private static Set<String> enrolmentTypes;

    static {
        enrolmentTypes = new Set<String>();
        for(MA_Enrolment_Service_Mapping__mdt serviceMapping : MA_Enrolment_Service_Mapping__mdt.getAll()?.values()) {
            enrolmentTypes.add(serviceMapping.Enrolment_Type__c.toLowerCase());
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to auto-enrol acquistion contacts to various enrolment types.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newAutoEnrolmentEvents  DESCRIPTION (Data type List, List of new Enrolment Platform Event records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void autoEnrolAcquisitionContacts(List<MA_Auto_Enrolment_Event__e> newAutoEnrolmentEvents) {
        Map<String, List<MA_Auto_Enrolment_Event__e>> enrolmentTypeToEventMap = getEnrolmentTypeToEventMap(newAutoEnrolmentEvents);
        autoEnrolAcquisitionContacts(enrolmentTypeToEventMap);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * To create & return mapping of Enrolment Type to new Enrolment Platform Event records.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newAutoEnrolmentEvents  DESCRIPTION (Data type List, List of new Enrolment Platform Event records)
    * @return   Map                     DESCRIPTION (return Map of Enrolment Type to List of Enrolment Platform Event records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<String, List<MA_Auto_Enrolment_Event__e>> getEnrolmentTypeToEventMap(List<MA_Auto_Enrolment_Event__e> newAutoEnrolmentEvents) {
        Map<String, List<MA_Auto_Enrolment_Event__e>> enrolmentTypeToEventMap = new Map<String, List<MA_Auto_Enrolment_Event__e>>();
        
        for(MA_Auto_Enrolment_Event__e newAutoEnrolmentEvent : newAutoEnrolmentEvents) {
            String enrolmentTypeKey = newAutoEnrolmentEvent.Enrolment_Type__c.toLowerCase();
            Boolean containsKey = enrolmentTypeToEventMap.containsKey(enrolmentTypeKey);
            List<MA_Auto_Enrolment_Event__e> enrolmentTypeEvents = containsKey ? enrolmentTypeToEventMap.get(enrolmentTypeKey) : new List<MA_Auto_Enrolment_Event__e>();
            enrolmentTypeEvents.add(newAutoEnrolmentEvent);
            enrolmentTypeToEventMap.put(enrolmentTypeKey, enrolmentTypeEvents);
        }

        return enrolmentTypeToEventMap;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to auto-enrol acquistion contacts by invoking enrolment service implementations as per strategy design.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    enrolmentTypeToEventMap   DESCRIPTION (Data type Map, Map of Enrolment Type to List of Enrolment Platform Event records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void autoEnrolAcquisitionContacts(Map<String, List<MA_Auto_Enrolment_Event__e>> enrolmentTypeToEventMap) {
        for(String enrolmentTypeKey : enrolmentTypeToEventMap.keySet()) {
            if(enrolmentTypes.contains(enrolmentTypeKey)) {
                MA_AutoEnrolment.getEnrolmentStrategy().autoEnrol(enrolmentTypeKey, enrolmentTypeToEventMap.get(enrolmentTypeKey));
            }
        }
    }
}