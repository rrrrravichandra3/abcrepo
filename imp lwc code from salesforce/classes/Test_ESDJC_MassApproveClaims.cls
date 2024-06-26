@isTest

public class Test_ESDJC_MassApproveClaims {    
    private static testmethod void testMassApprovalClaims(){
        Case wellnessCase = Test_Wellness_Util.createAPACWellnessCase();
        DJC_Wellness_Reimbursement_Claim__c claim1 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                                                               Test_Wellness_Util.buildFieldsForClaim(System.today().addDays(-1), 'Submitted', 'Fitness', 'INR', 100,null), true);
        DJC_Wellness_Reimbursement_Claim__c claim2 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                                                               Test_Wellness_Util.buildFieldsForClaim(System.today().addDays(-1), 'Submitted', 'Fitness', 'INR', 100,null), true);
        DJC_Wellness_Reimbursement_Claim__c claim3 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                                                               Test_Wellness_Util.buildFieldsForClaim(System.today().addDays(-1), 'Submitted', 'Fitness', 'INR', 100,null), true);
        

        Test.startTest();
        wellnessCase.status='Approved';
        update wellnessCase;
        Test.stopTest();
        Case newCase = [select DJC_Reimbursement_Case_Approved_On__c from case where id = :wellnessCase.id]; 
        System.assert(newCase.DJC_Reimbursement_Case_Approved_On__c != null);
        System.assertEquals(System.now().day(),newCase.DJC_Reimbursement_Case_Approved_On__c.day());
        System.assertEquals(System.now().month(),newCase.DJC_Reimbursement_Case_Approved_On__c.month());
        System.assertEquals(System.now().year(),newCase.DJC_Reimbursement_Case_Approved_On__c.year());
        //assert that all related claims status should set to "Approved"
        for (DJC_Wellness_Reimbursement_Claim__c claim : [select DJC_Wellness_Request_Status__c from DJC_Wellness_Reimbursement_Claim__c where id in : new Set<Id>{claim1.Id,claim2.Id,claim3.Id}]) {

            System.assertEquals('Approved',claim.DJC_Wellness_Request_Status__c);

        }
    }

    private static testmethod void testErrorOnCaseWhenClaimIsRejected(){
        Case wellnessCase = Test_Wellness_Util.createAPACWellnessCase();
        DJC_Wellness_Reimbursement_Claim__c claim1 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                                                               Test_Wellness_Util.buildFieldsForClaim(System.today().addDays(-1), 'Submitted', 'Fitness', 'INR', 100,null), true);
        DJC_Wellness_Reimbursement_Claim__c claim2 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                                                               Test_Wellness_Util.buildFieldsForClaim(System.today().addDays(-1), 'Rejected', 'Fitness', 'INR', 100,null), true);
        DJC_Wellness_Reimbursement_Claim__c claim3 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                                                               Test_Wellness_Util.buildFieldsForClaim(System.today().addDays(-1), 'Submitted', 'Fitness', 'INR', 100,null), true);
        

        Test.startTest();
        wellnessCase.status='Approved';
        try{
            update wellnessCase;
            } catch (DmlException e){
                System.assert(e.getMessage().contains(System.Label.DJC_Wellness_Set_Partial_Payment));
            }
        Test.stopTest();
        //for above claims, make sure none of the claims got approved.. 
        for (DJC_Wellness_Reimbursement_Claim__c claim : [select DJC_Wellness_Request_Status__c from DJC_Wellness_Reimbursement_Claim__c where id in : new Set<Id>{claim1.Id,claim2.Id,claim3.Id}]) {

            System.assert(claim.DJC_Wellness_Request_Status__c!='Approved');

        }
    }
}