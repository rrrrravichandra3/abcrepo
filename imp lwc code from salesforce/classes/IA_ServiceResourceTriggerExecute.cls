public class IA_ServiceResourceTriggerExecute {
    public static void executeTrigger(List<ServiceResource> newList,Map<Id,ServiceResource> oldMap,Map<Id,ServiceResource> newMap){
        if (Trigger.isBefore) {
            IA_ServiceResourceTriggerHandler.updateEndTimes(newList);
            if (Trigger.isUpdate) {
                IA_ServiceResourceTriggerHandler.updateActiveState(newMap,oldMap);
            }
        }
        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                // IA_ServiceResourceTriggerHandler.onAfterInsert(Trigger.newMap);
                IA_InsiderEmailNotifications.sendToProgrammAdmin(newMap, 'Insiders_Volunteer_Profile_Created');
            }
            if (Trigger.isUpdate) {
                IA_ServiceResourceTriggerHandler.onAfterUpdate(newMap, oldMap);
                IA_InsiderEmailNotifications.sendToProgrammAdmin(oldMap, newMap, 'Insiders_Volunteer_Profile_Update');
            }
        }
    }
}