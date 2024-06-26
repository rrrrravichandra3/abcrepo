@isTest
// Test Class to test the Interview Share Recalculation
private class IFB_InterviewShareRecalculationTest {

    @testSetup static void setup() {
        // Create the users first
        IFB_RecruitingTestDataFactory.createUser('Interviewer', 1);
        User interviewUser = [SELECT Id FROM User WHERE UserName='INT0@recruitingapp2.com'];
        // Validate the user was created
        System.assertNotEquals(null, interviewUser);
    }

    static testmethod void IFB_InterviewShareRecalculationTest() {   
        Id batchId;  
        User interviewUser = [SELECT Id FROM User WHERE UserName='INT0@recruitingapp2.com'];   
        IFB_Interview_Candidate__c ic = new IFB_Interview_Candidate__c(First_Name__c='Candidate0', Last_Name__c='Recruit0',
                                                                Region__c='AMER', Zone__c='AMER East',City__c ='New York', State__c='N/A');
        insert ic;
        Id iRecordTypeId = Schema.getGlobalDescribe().get('IFB_Interview__c').getDescribe().getRecordTypeInfosByName().get('Technical Interview').getRecordTypeId();
        
        IFB_Interview__c interview = new IFB_Interview__c(Candidate__c= ic.Id, RecordTypeId=iRecordTypeId,Interviewer__c=interviewUser.Id);
        insert interview;
        
        Test.startTest();
        IFB_InterviewShareRecalculation isr = new IFB_InterviewShareRecalculation();
        batchId = Database.executeBatch(isr);
        Test.stopTest();
        
        System.assertNotEquals(batchId, null);
        AsyncApexJob a = [Select Id, Status, NumberOfErrors from AsyncApexJob where Id = : batchId]; 
        System.assertEquals(a.Status, 'Completed'); 
        // Query job sharing records.
        List<IFB_Interview__Share> cShrs = [SELECT Id, UserOrGroupId, AccessLevel, RowCause FROM IFB_Interview__Share WHERE ParentId = :interview.Id AND UserOrGroupId= :interviewUser.Id];
        System.assertEquals(cShrs.size(), 1);
        System.assertEquals(cShrs[0].AccessLevel, 'Edit');
        System.assertEquals(cShrs[0].RowCause, Schema.IFB_Interview__Share.RowCause.Interviewer__c);
        System.assertEquals(cShrs[0].UserOrGroupId, interviewUser.Id);
    }
    
}