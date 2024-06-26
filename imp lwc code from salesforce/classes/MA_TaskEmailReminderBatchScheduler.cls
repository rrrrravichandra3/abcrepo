/**
 * @description       : Schedulable apex to schedule execution of MA_TaskEmailReminderBatch class based on criteria
 * @author            : Sergey Mihalyuk
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   20-06-2021   Sergey Mihalyuk   Initial Version
**/
global class MA_TaskEmailReminderBatchScheduler implements Schedulable {

    public static String cronExp = '0 0 8 1/1 * ? *'; //every day at 8 AM

    global static String schedule() {
        return System.schedule('MA_TaskEmailReminderBatch', cronExp, new MA_TaskEmailReminderBatchScheduler());
    }

    global void execute(SchedulableContext sc) {
        Id batchJobId = Database.executeBatch(new MA_TaskEmailReminderBatch(), 200);
    }
}