@isTest
public class ESDJC_ProcessReimbCasesTest {
    @testSetup
    static void setup() {
        //create Contacts,cases,claims
        contact contactForRegion;
        contactForRegion = ESDJC_AssignmentHelper.getContacts(3, 'EMEA - All Countries', 'Paris', 'France', Date.newInstance(2018, 6, 17))[0];
        Test_Wellness_Util.createBulkWellnessCasesWithClaims(contactForRegion,10, 2);
        Test_Wellness_Util.createBulkEducationCasesWithClaims(contactForRegion,10, 2);
        contactForRegion =  ESDJC_AssignmentHelper.getContacts(1,'APAC - All Countries','Hyderabad','India', Date.newInstance(2018, 6, 17))[0];
        Test_Wellness_Util.createBulkWellnessCasesWithClaims(contactForRegion,10, 2);
        Test_Wellness_Util.createBulkEducationCasesWithClaims(contactForRegion,10, 2);
        contactForRegion = ESDJC_AssignmentHelper.getContacts(3, 'Americas - USA', 'San Francisco', 'United States of America', Date.newInstance(2018, 6, 17))[0];
        Test_Wellness_Util.createBulkEducationCasesWithClaims(contactForRegion,10, 2);
        contactForRegion = ESDJC_AssignmentHelper.getContacts(3, 'Americas - Canada', 'Ottawa', 'Canada', Date.newInstance(2018, 6, 17))[0];
        Test_Wellness_Util.createBulkEducationCasesWithClaims(contactForRegion,10, 2);
        contactForRegion = ESDJC_AssignmentHelper.getContacts(3, 'Americas - Latin America', 'Cancun', 'Mexico', Date.newInstance(2018, 6, 17))[0];
        Test_Wellness_Util.createBulkWellnessCasesWithClaims(contactForRegion,10, 2);
        Test_Wellness_Util.createBulkEducationCasesWithClaims(contactForRegion,10, 3);
        contactForRegion = ESDJC_AssignmentHelper.getContacts(3, 'Japan', 'Tokyo', 'Japan', Date.newInstance(2018, 6, 17))[0];
        Test_Wellness_Util.createBulkWellnessCasesWithClaims(contactForRegion,10, 1);
        Test_Wellness_Util.createBulkEducationCasesWithClaims(contactForRegion,10, 2);
       
    }
    /*
     * Postive test case for the bulkclaims 
     */
    @isTest static void BulkTestForAllclaims() {
        Test.setMock(HttpCalloutMock.class, new ESDJC_ReimburIntegrationMockCallout(true,201,'Reimbursement processed successfully',null));
        Test.startTest();
        Id batchId = Database.executeBatch(new ESDJC_ProcessReimbCases_Batch(),200);
        Test.stopTest();
        System.assertEquals(200, [select count() from DJC_Wellness_Reimbursement_Claim__c where Integration_Status__c = 'Closed']);
    }
     /*
     * Neagtive test case for the bulkclaims 
     */
    @isTest static void BulkTestForAllClaimsWithCalloutError() {
        Test.setMock(HttpCalloutMock.class, new ESDJC_ReimburIntegrationMockCallout(false,404,'Callout Error',null));
        Test.startTest();
        Id batchId = Database.executeBatch(new ESDJC_ProcessReimbCases_Batch(),200);
        Test.stopTest();
        System.assertEquals(200, [select count() from DJC_Wellness_Reimbursement_Claim__c]);
    }
     /*
     * Negative test case for the few claims with currency mismatch
     */
    @isTest static void ProcessClaimIdForCurrencyMismatch() {
        List<DJC_Wellness_Reimbursement_Claim__c> claims = [SELECT Id from DJC_Wellness_Reimbursement_Claim__c LIMIT 3];
        List<id> claimids = new List<id>();
        for(DJC_Wellness_Reimbursement_Claim__c claim : claims){
            claimids.add(claim.id);
        }
        Test.setMock(HttpCalloutMock.class, new ESDJC_ReimburIntegrationMockCallout(true,400,'Reimbursement request currency mismatch - Not processed',claimids));
        Test.startTest();
        Id batchId = Database.executeBatch(new ESDJC_ProcessReimbCases_Batch(claimids),200);
        Test.stopTest();
        System.assertEquals(3, [select count() from DJC_Wellness_Reimbursement_Claim__c where Integration_Status__c != 'Closed' and id=:claimids]);
    }
     /*
     * Negative test case for the few claims with duplicate claims
     */
    @isTest static void ProcessClaimIdForDuplicateClaims() {
        List<DJC_Wellness_Reimbursement_Claim__c> claims = [SELECT Id from DJC_Wellness_Reimbursement_Claim__c LIMIT 3];
        List<id> claimids = new List<id>();
        for(DJC_Wellness_Reimbursement_Claim__c claim : claims){
            claimids.add(claim.id);
        }
        Test.setMock(HttpCalloutMock.class, new ESDJC_ReimburIntegrationMockCallout(true,409,'Duplicate reimbursement received - Not processed',claimids));
        Test.startTest();
        Id batchId = Database.executeBatch(new ESDJC_ProcessReimbCases_Batch(claimids),200);
        Test.stopTest();
        System.assertEquals(3, [select count() from DJC_Wellness_Reimbursement_Claim__c where Integration_Status__c != 'Closed' and id=:claimids]);
    }
    
    /*
     * Negative test case for the few claims with update claim fails
     */
    @isTest static void ProcessClaimIdForWellnessClaimsWithDuplicateId() {
        List<DJC_Wellness_Reimbursement_Claim__c> claims = [SELECT Id,DJC_Wellness_Start_Date_of_Activity__c from DJC_Wellness_Reimbursement_Claim__c WHERE DJC_Wellness_Case__r.Type ='Wellness Reimbursement Request' LIMIT 3];
        List<id> claimids = new List<id>();
        for(DJC_Wellness_Reimbursement_Claim__c claim : claims){
            claimids.add(claim.id);
           PF_Logger.log('ESDJC','ERROR','Duplicate reimbursement received - Not processed','409','ESDJC_Reimbursement_Integrations_Service','Employee Engagement','Reimbursement Integration',claim.Id);
        }
        if(!PF_Logger.logs.isEmpty()){
            PF_Logger.createLogs(PF_Logger.logs);
        }
        String errorMessage= System.Label.ReimburseClaimAPIerror;
        List<PF_Debug_Log__c> caseIdFromLogs = [SELECT Id,Record_Id__c,Error_Type__c FROM PF_Debug_Log__c WHERE Error_Type__c=:errorMessage];
        Test.setMock(HttpCalloutMock.class, new ESDJC_ReimburIntegrationMockCallout(true,201,'Reimbursement processed successfully',claimids));
        Test.startTest();
        Id batchId = Database.executeBatch(new ESDJC_ProcessReimbCases_Batch(claimids),200);
        Test.stopTest();
        System.assertEquals(3, [select count() from DJC_Wellness_Reimbursement_Claim__c where Integration_Status__c != 'Closed' and id=:claimids]);
    }

}