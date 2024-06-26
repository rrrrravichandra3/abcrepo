@istest
public class ReimbClaimsRelatedListControllerTest {
	
    @testSetup
    public static void createNewClaims(){
        Case ExpCase = new case();
        ExpCase.Origin = 'Chatter';
        ExpCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Expense Cases').getRecordTypeId();
        insert ExpCase;
        List<DJC_Wellness_Reimbursement_Claim__c> claims = new List<DJC_Wellness_Reimbursement_Claim__c>();
        for(Integer i=0;i<5;i++){
            DJC_Wellness_Reimbursement_Claim__c claim = new DJC_Wellness_Reimbursement_Claim__c();
            claim.DJC_Wellness_Request_Status__c = 'New';
            claim.DJC_Wellness_Case__c = ExpCase.id ;
            claim.DJC_Wellness_Amount_Requested__c =10;
            claims.add(claim);
        }
        insert claims;
        
    }
    public static testmethod void  testApproveClaims(){   
        set<id> claimIds = new set<id>();
        List<DJC_Wellness_Reimbursement_Claim__c> claims = [select id from DJC_Wellness_Reimbursement_Claim__c];
        for(DJC_Wellness_Reimbursement_Claim__c claim:claims){
            claimIds.add(claim.id);
        }
        String ClaimIdStr = JSON.serialize(claimIds);
        ReimbClaimsRelatedListController.approveClaims(ClaimIdStr);
        
        claims = [select id,DJC_Wellness_Request_Status__c from DJC_Wellness_Reimbursement_Claim__c ];
        for(DJC_Wellness_Reimbursement_Claim__c claim:claims){
            system.assertEquals(claim.DJC_Wellness_Request_Status__c, 'Approved');
        }
    }
}