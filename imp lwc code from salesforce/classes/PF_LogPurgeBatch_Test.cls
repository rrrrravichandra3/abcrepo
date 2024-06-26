@Istest
public class PF_LogPurgeBatch_Test {
    
    private static final String CRON_EXP = '0 0 8 1/1 * ? *';
    @testSetup
    static void init() {
        PF_Logger.log('Test Application','Test Type', 'Test Error Message', 'Test Error Type', 'Test Desciption', 'Test Component');
        PF_Logger.log('Test Application2','Test Type', 'Test Error Message', 'Test Error Type', 'Test Desciption', 'Test Component');
        PF_Logger.createLogs(PF_Logger.logs);
        List<PF_Debug_Log__c> createdLogs = [SELECT Id FROM PF_Debug_Log__c];
        Test.setCreatedDate(createdLogs[0].Id, Date.today().addyears(-2));
    }
    
    @IsTest
    static void test_Scheduler(){
        List<PF_Debug_Log__c> createdLogs = [SELECT Id,CompositeKey__c FROM PF_Debug_Log__c];
        
        Test.StartTest();
        
        String jobId = System.schedule('Test check', CRON_EXP, new PF_LogPurgeBatch());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        System.assertEquals(CRON_EXP, ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
        
        
    }
    
    @IsTest
    static void test_BatchClass(){
        List<PF_Debug_Log__c> createdLogs = [SELECT Id,CompositeKey__c FROM PF_Debug_Log__c];
        
        Test.StartTest();
            PF_LogPurgeBatch.initiateJob(); 
        Test.stopTest();
        List<PF_Debug_Log__c> afterDelete = [SELECT Id,CompositeKey__c FROM PF_Debug_Log__c];
        Assert.areNotEqual(createdLogs.size(),afterDelete.size(),'Unable to delete the records in batch');
        Assert.areEqual(afterDelete.size(),1,'Batch should delete one record');
        
        
    }
    
    

    
}