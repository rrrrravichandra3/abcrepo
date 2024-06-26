public class IA_JULY_B_BatchUpdateSRWithCountry implements Database.Batchable<sObject>, Database.Stateful {
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String queryString = 'SELECT Id, Work_Time_Zone__c, Country__c, Slot_1_Day__c, Slot_2_Day__c, Slot_1_Start_Time__c, Slot_2_Start_Time__c ' + 'FROM ServiceResource';

        return Database.getQueryLocator(queryString);
    }

    public void execute(Database.BatchableContext BC, List<ServiceResource> scope) {
        List<ServiceResource> updatedData = new List<ServiceResource>();

        for (ServiceResource sr : scope) {
            if (!(sr.Slot_1_Day__c == sr.Slot_2_Day__c && sr.Slot_1_Start_Time__c == sr.Slot_2_Start_Time__c) && !String.isBlank(sr.Work_Time_Zone__c) && String.isBlank(sr.Country__c)) {
                if (sr.Work_Time_Zone__c.contains('Australia')) {
                    sr.Country__c = 'Australia';
                } else if (sr.Work_Time_Zone__c.contains('Dublin')) {
                    sr.Country__c = 'Ireland';
                } else if (sr.Work_Time_Zone__c.contains('London')) {
                    sr.Country__c = 'United Kingdom';
                } else if (sr.Work_Time_Zone__c.contains('Vancouver')) {
                    sr.Country__c = 'Canada';
                } else if (sr.Work_Time_Zone__c.contains('Paris')) {
                    sr.Country__c = 'France';
                } else if (sr.Work_Time_Zone__c.contains('Berlin')) {
                    sr.Country__c = 'Germany';
                } else if (sr.Work_Time_Zone__c.contains('Madrid')) {
                    sr.Country__c = 'Spain';
                } else if (sr.Work_Time_Zone__c.contains('Jerusalem')) {
                    sr.Country__c = 'Israel';
                } else if (sr.Work_Time_Zone__c.contains('Zurich')) {
                    sr.Country__c = 'Switzerland';
                } else {
                    sr.Country__c = 'United States of America';
                }
                updatedData.add(sr);
            }
        }

        Database.update(updatedData, false);
    }

    public void finish(Database.BatchableContext BC) {
    }
}