public with sharing class Modify_Trigger_Context_Util {

        //given the context of Trigger.oldMap and Trigger.newMap, it removes the elememnts specified in parameter recordsToBeRemoved
        //returns an instance of wrapper class modifiedUpdateTriggerVariables which has updated version of triiger.oldMap and trigger.newMap
        public static modifiedUpdateTriggerVariables removeRecordsFromUpdateTriggerVariables(Map<Id, sObject> oldRecordsMap, Map<Id, sObject> newRecordsMap, Set<Id> recordsToBeRemoved){
            Map<Id, sObject> modifiedOldRecordsMap = new Map<Id, sObject>();
            Map<Id, sObject> modifiedNewRecordsMap = new Map<Id, sObject>();

            for(sObject currOldRecord : oldRecordsMap.values()){
                    sObject currNewRecord = newRecordsMap.get(currOldRecord.Id);
                    if((recordsToBeRemoved.contains(currOldRecord.Id)) || (currNewRecord == null)){
                            continue;
                    }
                    modifiedOldRecordsMap.put(currOldRecord.Id, currOldRecord);
                    modifiedNewRecordsMap.put(currNewRecord.Id, currNewRecord);
            }
            return new modifiedUpdateTriggerVariables(modifiedOldRecordsMap, modifiedNewRecordsMap);
        }

        //given the context of Trigger.oldMap and Trigger.newMap, it retains only the elememnts specified in parameter recordsToBeRetained
        //returns an instance of wrapper class modifiedUpdateTriggerVariables which has updated version of triiger.oldMap and trigger.newMap
        public static modifiedUpdateTriggerVariables retainRecordsFromUpdateTriggerVariables(Map<Id, sObject> oldRecordsMap, Map<Id, sObject> newRecordsMap, Set<Id> recordsToBeRetained){
                Map<Id, sObject> modifiedOldRecordsMap = new Map<Id, sObject>();
                Map<Id, sObject> modifiedNewRecordsMap = new Map<Id, sObject>();

                for(sObject currOldRecord : oldRecordsMap.values()){
                        sObject currNewRecord = newRecordsMap.get(currOldRecord.Id);
                        if((!(recordsToBeRetained.contains(currOldRecord.Id))) || (currNewRecord == null)){
                                continue;
                        }
                        modifiedOldRecordsMap.put(currOldRecord.Id, currOldRecord);
                        modifiedNewRecordsMap.put(currNewRecord.Id, currNewRecord);
                }
                return new modifiedUpdateTriggerVariables(modifiedOldRecordsMap, modifiedNewRecordsMap);
        }
    
    //wraper class to for storing updating versions of trigger.oldMap and trigger.newMap
        public class modifiedUpdateTriggerVariables{
                public Map<Id, sObject> modifiedOldRecordsMap;
                public Map<Id, sObject> modifiedNewRecordsMap;

                public modifiedUpdateTriggerVariables(Map<Id, sObject> modifiedOldRecordsMap,Map<Id, sObject> modifiedNewRecordsMap){
                        this.modifiedOldRecordsMap = modifiedOldRecordsMap;
                        this.modifiedNewRecordsMap = modifiedNewRecordsMap;
                }
        }
}