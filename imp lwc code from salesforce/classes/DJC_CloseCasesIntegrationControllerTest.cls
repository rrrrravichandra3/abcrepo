@isTest
public class DJC_CloseCasesIntegrationControllerTest{

    private static Case APACCase;
    private static Case EMEACase;
    static {
        setUp();        
    }

   
    private static testmethod void testCaseClosedStatusEducation() {
        Test.startTest();
         APACCase.status = 'Extracted For Payment';
         update APACCase;
        List<case> cases = [select id, status from case 
                            where status ='Extracted for Payment' 
                            and type ='Education Reimbursement Request'];
        system.assertEquals(cases.size(), 1);
        List<String> caseIdsFromWD=new List<String>();
        for(Case a : cases){
            caseIdsFromWD.add(string.valueof(a.id));
        }
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/CloseReimbursementCases/';  
        req.httpMethod = 'Post';
        RestContext.request = req;
        RestContext.response = res;        
        String results = DJC_CloseCasesIntegrationController.getcloseReimbursementClaims(caseIdsFromWD);
       
        System.assertEquals('{"result":"Success"}', results);     
        Test.stopTest();        
        
        validateCaseStatus('Closed',APACCase);
       
        
    }
        private static testmethod void testCaseClosedStatusWellness() {
        Test.startTest();
         EMEACase.status = 'Extracted For Payment';
         update EMEACase;
        List<case> cases = [select id, status from case 
                            where status ='Extracted for Payment' 
                            and type ='Wellness Reimbursement Request'];
                
         system.assertEquals(cases.size(), 1);

        List<String> caseIdsFromWD=new List<String>();
        for(Case a : cases){
            caseIdsFromWD.add(string.valueof(a.id));
        }
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/CloseReimbursementCases/';  
        req.httpMethod = 'Post';
        RestContext.request = req;
        RestContext.response = res;        
        String results = DJC_CloseCasesIntegrationController.getcloseReimbursementClaims(caseIdsFromWD);
       
        System.assertEquals('{"result":"Success"}', results);     
        Test.stopTest();        
        
        validateCaseStatus('Closed',EMEACase);
       
        
    }
    private static void validateCaseStatus(String status, Case wellnessCase) {
        for (Case c : [select status from case where id = :wellnessCase.id]) {
            system.assertEquals(status, c.status);
        }
    } 
            
    private static void setUp() {
        APACCase = Test_Wellness_Util.createAPACEducationCaseForClose();
        EMEACase = Test_Wellness_Util.createEMEAWellnessCaseForClose();

        DJC_Wellness_Reimbursement_Claim__c apacClaim= Test_Wellness_Util.createWellnessClaim(APACCase, 
                                                         Test_Wellness_Util.buildFieldsForClaim(null, 'Submitted', 'Education', 'INR', 1 , System.today()), false);    
        DJC_Wellness_Reimbursement_Claim__c emeaClaim = Test_Wellness_Util.createWellnessClaim(EMEACase, 
                                                      Test_Wellness_Util.buildFieldsForClaim(System.today(), 'Submitted', 'Fitness', 'EUR', 1,null), false);        

        List<DJC_Wellness_Reimbursement_Claim__c> claims = new List<DJC_Wellness_Reimbursement_Claim__c> {apacclaim, emeaclaim};
        insert claims;
        apacCase.status = 'Approved';
        emeaCase.status = 'Approved';
        List<Case> cases = new List<Case>{apacCase, emeaCase};
        update cases;

    }
   }