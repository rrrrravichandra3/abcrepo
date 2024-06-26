/**
 * @description       : Batch Scheduler job to count the number of appointments for a Service Resource in a month 
 * @author            : skolagani@salesforce.com
 * @last modified on  : 02-10-2021
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   02-03-2021   Sri Kolagani                         Batch job creation
**/
public with sharing class IA_UpdateNumberOfApptsBatchScheduler  implements Schedulable {
    public void execute(SchedulableContext SC) {
        database.executebatch(new IA_UpdateNumberOfAppointmentsBatch());
    }
}