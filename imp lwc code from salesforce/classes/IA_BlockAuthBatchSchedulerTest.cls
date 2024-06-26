/**
 * @author Vinod Chokkula
 * @date 12/17/2020
 *
 * @description Test Class for IA_BlockAuthBatchScheduler
 *
 *
 */
@isTest
public  class IA_BlockAuthBatchSchedulerTest {
    private static final String MSG_EXPECTING_BATCH_TO_BE_CREATED = 'Expecting valid batch Id';
    @istest
    static void scheduleTestMethod() {        
        test.starttest();
        IA_BlockAuthBatchScheduler sc = new IA_BlockAuthBatchScheduler();   
        String chron = '0 0 23 * * ?';        
        String batchId = system.schedule('Test Sched', chron, sc);
        System.AssertNotEquals(batchId, null, MSG_EXPECTING_BATCH_TO_BE_CREATED);
        test.stopTest();
    }
    
}