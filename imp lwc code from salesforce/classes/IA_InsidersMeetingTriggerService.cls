public class IA_InsidersMeetingTriggerService {
    public static void executeTrigger(List<ServiceAppointment> newList,Map<Id,ServiceAppointment> oldMap){
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                IA_InsidersMeetingTriggerHandler.onBeforeInsert(newList);
            }
            if (Trigger.isUpdate) {
                IA_InsidersMeetingTriggerHandler.onBeforeUpdate(oldMap, newList);
            }
        }
        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                IA_InsidersMeetingTriggerHandler.onAfterInsert(newList);
            }
            if (Trigger.isUpdate) {
                IA_InsidersMeetingTriggerHandler.onAfterUpdate(oldMap, newList);
            }
        }
    }
}