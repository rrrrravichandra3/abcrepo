@IsTest
public class MA_TaskEmailReminderBatchScheduler_Test {

    @isTest
    static void executeTaskEmailReminderBatchSchedulerTest() {
        Test.startTest();
            String cronExp = '0 0 8 1/1 * ? *';
            String jobId = MA_TaskEmailReminderBatchScheduler.schedule();
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(cronExp, ct.CronExpression, 'CRON expression should be the same.');
            System.assertEquals(0, ct.TimesTriggered);
           // System.assertEquals(String.valueOf(System.today()).substringBefore(' ') + ' 08:00:00', String.valueOf(ct.NextFireTime), 'Scheduler should execute at 8am daily.');
        Test.stopTest();
    }
}