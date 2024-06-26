/**
 * @description       : Batch Scheduler Test job to count the number of appointments for a Service Resource in a month 
 * @author            : skolagani@salesforce.com
 * @last modified on  : 03-15-2021
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   02-03-2021   Sri Kolagani                         Batch job creation
**/
@isTest
public class IA_UpdateNumberOfApptsBatchSchedulerTest {
    @isTest
    static void scheduleTestMethodforAppts() {        
        test.starttest();
        Set<String> objectFields = Schema.SObjectType.ServiceResource.fields.getMap().keySet();
        if(objectFields.contains('Number_Of_Meetings_This_Month__c'.toLowerCase())) {
            IA_UpdateNumberOfApptsBatchScheduler sc = new IA_UpdateNumberOfApptsBatchScheduler();   
            String chron = '0 0 23 * * ?';        
            system.schedule('Test Sched',chron,sc);
            test.stopTest();
        }
    } 
}