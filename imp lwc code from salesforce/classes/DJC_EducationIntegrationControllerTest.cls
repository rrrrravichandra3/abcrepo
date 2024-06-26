@isTest(seeAllData = false)
public class DJC_EducationIntegrationControllerTest {
    private static date olddate = system.today().addmonths(-2);
    private static string lastRunDate = EncodingUtil.urlEncode(olddate.year()+'-'+olddate.month()+'-'+olddate.day()+' 00:00:00', 'UTF-8');     
    private static Case APACCase;
    private static Case EMEACase;
    static {
        //setUp();
    }
    private static testmethod void testIntegrationForAPAC() {
        setUp();
        Test.startTest();
        /*APACCase.Division__c =  'APAC - All Countries';
        update APACCase;*/
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/GetEDReimbursementClaims/APAC/';  
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;        
        DJC_EducationIntegrationController.ResponseHandler results = DJC_EducationIntegrationController.getAllReimbursementClaims();        
        System.debug('service_response**** '+results.educationClaims);
        System.debug('APAC size'+ results.educationClaims.size());
        System.assertEquals('Success', results.status);   
        System.assertEquals(2, results.educationClaims.size());
        
        Map<Id, DJC_Wellness_Reimbursement_Claim__c> claims = new Map<Id,DJC_Wellness_Reimbursement_Claim__c>([SELECT CurrencyIsoCode, DJC_Wellness_Amount_Requested__c FROM DJC_Wellness_Reimbursement_Claim__c WHERE DJC_Wellness_Case__r.Id = :APACCase.Id]);
        
        for(DJC_EducationIntegrationController.Claim claim:results.educationClaims){
          assertClaim(APACCase.CurrencyIsoCode, claims.get(claim.claimId), claim);
        }
        
        System.debug('service_response '+results.educationClaims);
        Test.stopTest();        
        validateCaseStatus('Extracted for Payment', APACCase);
        validateCaseStatus('Approved', EMEACase);
    }
    
        private static testmethod void testNoReimbForFoundationAPAC() {        
  
            Case Foundationcase = Test_Wellness_Util.createAPACEdCaseForFoundationContact();
            Case APACEdcase = Test_Wellness_Util.createEdCaseByRegion('APAC - All Countries');
            list<case> cases = new list<case>{Foundationcase,APACEdcase};
            insert cases;
            Test.setCreatedDate(APACEdcase.id,system.today().addmonths(-1));//Create for current month
            Test.setCreatedDate(Foundationcase.id,system.today().addmonths(-1));//Create for current month
            Test_Wellness_Util.createWellnessClaim(APACEdcase,Test_Wellness_Util.buildFieldsForClaim(null,'Approved','Education',APACEdcase.CurrencyIsoCode,1,system.today() ),true);      
            Test_Wellness_Util.createWellnessClaim(Foundationcase,Test_Wellness_Util.buildFieldsForClaim(null,'Approved','Education',Foundationcase.CurrencyIsoCode,1,system.today() ),true);      
            
            Test.startTest();//To Avoid SOQL limits    
                RestRequest req = new RestRequest();  
                RestResponse res = new RestResponse();   
                req.requestURI = '/GetEDReimbursementClaims/APAC/';   
                req.httpMethod = 'GET';
                RestContext.request = req;
                RestContext.response = res;    
        
                
                Map<Id, DJC_Wellness_Reimbursement_Claim__c> claims = new Map<Id,DJC_Wellness_Reimbursement_Claim__c>([SELECT CurrencyIsoCode, DJC_Wellness_Amount_Requested__c 
                                                                                                                    FROM DJC_Wellness_Reimbursement_Claim__c 
                                                                                                                    WHERE DJC_Wellness_Case__r.type = 'Education Reimbursement Request'
                                                                                                                    and DJC_Wellness_Case__r.Division__c = 'APAC - All Countries'
                                                                                                                    and DJC_Wellness_Case__r.status = 'Approved'
                                                                                                                    ]); 
                System.assertEquals(2, claims.size(),'Inclusive of Foundation claims - We have created 2 - 1 Foundation And 1 Non-Foundation');
        
                DJC_EducationIntegrationController.ResponseHandler results = DJC_EducationIntegrationController.getAllReimbursementClaims();        
                System.debug('service_response**** '+results.educationClaims);
                
                System.assertEquals('Success', results.status,results);   
                System.assertNotEquals(2, results.educationClaims.size(),results.educationClaims.size());//Should not be 4 - as Foundation employes are xcluded and NOT picked by Integration.
            Test.stopTest();        

        validateCaseStatus('Extracted for Payment', APACEdcase);//Expecting non-foundation cases to be extracted for payment
    } 
    
    private static void assertClaim(String expectedCountryCurrency, DJC_Wellness_Reimbursement_Claim__c claim, DJC_EducationIntegrationController.Claim resultClaim){
    System.assertEquals(expectedCountryCurrency, resultClaim.countryCurrency);
        System.assertEquals(Test_Wellness_Util.convertValueToCurrency(claim.CurrencyIsoCode, expectedCountryCurrency, claim.DJC_Wellness_Amount_Requested__c, 2), resultClaim.convertedAmount);        
    }
    
    private static testmethod void testIntegrationForEMEA() {
        setup();
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/GetEDReimbursementClaims/EMEA/';  
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;        
        DJC_EducationIntegrationController.ResponseHandler results = DJC_EducationIntegrationController.getAllReimbursementClaims();        
        System.assertEquals('Success', results.status);
        System.assertEquals(4, results.educationClaims.size());
        
    Map<Id, DJC_Wellness_Reimbursement_Claim__c> claims = new Map<Id,DJC_Wellness_Reimbursement_Claim__c>([SELECT CurrencyIsoCode, DJC_Wellness_Amount_Requested__c FROM DJC_Wellness_Reimbursement_Claim__c WHERE DJC_Wellness_Case__r.Id = :EMEACase.Id]);
        
        for(DJC_EducationIntegrationController.Claim claim:results.educationClaims){
          assertClaim(EMEACase.CurrencyIsoCode, claims.get(claim.claimId), claim);
        }

        Test.stopTest();        
        validateCaseStatus('Extracted for Payment', EMEACase);
        validateCaseStatus('Approved', APACCase);
    }

    private static testmethod void testIntegrationForEMEAWithDate() {
        setup();
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/GetEDReimbursementClaims/EMEA/'+lastRunDate;  
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;        
        DJC_EducationIntegrationController.ResponseHandler results = DJC_EducationIntegrationController.getAllReimbursementClaims();        
        System.assertEquals('Success', results.status);
        System.assertEquals(4, results.educationClaims.size());        
        Test.stopTest();        
        validateCaseStatus('Extracted for Payment', EMEACase);
        validateCaseStatus('Approved', APACCase);
    }        
    
    private static testmethod void testInvalidRequest() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/GetEDReimbursementClaims/AMER/';  
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;        
        DJC_EducationIntegrationController.ResponseHandler results = DJC_EducationIntegrationController.getAllReimbursementClaims();        
        System.assertEquals(DJC_EducationIntegrationController.ENDPOINT_ERROR, results.status);        
        Test.stopTest();                
        validateCaseStatus('Approved');
    }
    public static testmethod void testBeyondCutoffNotPicked(){
        Test_Wellness_Util.init();
        Case APACEdcase = Test_Wellness_Util.createEdCaseByRegion('APAC - All Countries');
        insert APACEdcase;
        Test.setCreatedDate(APACEdcase.id,system.now());//Create for current month
        Test_Wellness_Util.createWellnessClaim(APACEdcase,Test_Wellness_Util.buildFieldsForClaim(null,'Approved','Education',APACEdcase.CurrencyIsoCode,1,system.today() ),true);      
        
        list<case> expenseCasesCreated = [select id,createddate,status,Division__c,(select id,DJC_Wellness_Request_Status__c from Wellness_Reimbursement_Claims__r 
                                                                                    where DJC_Wellness_Request_Status__c='Approved')
                                            from case where  status = 'Approved'];
        system.assert(expenseCasesCreated!= null && expenseCasesCreated.size()==1);
        system.assert(expenseCasesCreated[0].Wellness_Reimbursement_Claims__r.size()>0);

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/GetEDReimbursementClaims/APAC/';  
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;        
        DJC_EducationIntegrationController.ResponseHandler results = DJC_EducationIntegrationController.getAllReimbursementClaims();        
        System.assertEquals('Success', results.status);
        System.assertEquals(0, results.educationClaims.size());     

        validateCaseStatus('Approved');//Expecting current month's cases not to be picked.
         
    }
    public static testmethod void testCutoffBoundariesAllregions(){
            
            Test_Wellness_Util.init();
            ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance(); 
            system.assertEquals(settings.DJC_WD_Cutoff_Date_DD__c,1,'The cutoff GMT Assumes first of month');

            DateTime cutOffGMT = DateTime.newInstanceGMT(system.today().tostartofmonth(), Time.newInstance(0, 0, 0, 0)); 
            //Map of Division to cutoff
            Map<String,datetime> mDivToCutoff = new map<String,datetime>();

            DJC_Division APACDiv   =  DJC_Division.getDivisionByName('APAC - All Countries');
            DJC_Division EMEADiv   =  DJC_Division.getDivisionByName('EMEA - All Countries');
            DJC_Division JapanDiv  =  DJC_Division.getDivisionByName('Japan');
            DJC_Division AMERDiv   =  DJC_Division.getDivisionByName('Americas - USA');
            DJC_Division CanadaDiv =  DJC_Division.getDivisionByName('Americas - Canada');
            DJC_Division LatinDiv  =  DJC_Division.getDivisionByName('Americas - Latin America');

            //Create list of cases
            mDivToCutoff.put('APAC - All Countries',cutOffGMT.addhours( APACDiv.getDivTzOffsetForGMTDatetime(cutOffGMT) * -1 ));
            mDivToCutoff.put('EMEA - All Countries',cutOffGMT.addhours( EMEADiv.getDivTzOffsetForGMTDatetime(cutOffGMT) * -1 ));
            mDivToCutoff.put('Japan',cutOffGMT.addhours( JapanDiv.getDivTzOffsetForGMTDatetime(cutOffGMT) * -1 ));
            mDivToCutoff.put('Americas - USA',cutOffGMT.addhours( AMERDiv.getDivTzOffsetForGMTDatetime(cutOffGMT) * -1 ));
            mDivToCutoff.put('Americas - Canada',cutOffGMT.addhours( CanadaDiv.getDivTzOffsetForGMTDatetime(cutOffGMT) * -1 ));
            mDivToCutoff.put('Americas - Latin America',cutOffGMT.addhours( LatinDiv.getDivTzOffsetForGMTDatetime(cutOffGMT) * -1 ));          

            Case APACEdcase = Test_Wellness_Util.createEdCaseByRegion('APAC - All Countries');
            Case EMEAEdcase = Test_Wellness_Util.createEdCaseByRegion('EMEA - All Countries');
           // Case JapanEdcase = Test_Wellness_Util.createEdCaseByRegionDate('Japan');
            Case AMerEdcase = Test_Wellness_Util.createEdCaseByRegion('Americas - USA');
            Case CanadaEdcase = Test_Wellness_Util.createEdCaseByRegion('Americas - Canada');
            Case LatinEdcase = Test_Wellness_Util.createEdCaseByRegion('Americas - Latin America');
            list<case> expenseCases = new list<case>{ APACEdcase,EMEAEdcase,AMerEdcase,CanadaEdcase,LatinEdcase};

            insert expenseCases;
            
			list<DJC_Wellness_Reimbursement_Claim__c> claims = new list<DJC_Wellness_Reimbursement_Claim__c>();
            for(Case c:expenseCases){
                DateTime cutoff = mDivToCutoff.get(c.Division__c);
                System.assertNotEquals(cutoff,null,'Expecting cutoff populated for '+c.Division__c); 
                Test.setCreatedDate(c.id,mDivToCutoff.get(c.Division__c));
                claims.add(Test_Wellness_Util.createWellnessClaim(c,Test_Wellness_Util.buildFieldsForClaim(null,'Approved','Education',c.CurrencyIsoCode,1,cutoff.date() ),false));      
            }
            insert claims;
         
            Test.startTest();
            list<case> expenseCasesCreated = [select id,createddate,status,Division__c,(select id,DJC_Wellness_Request_Status__c from Wellness_Reimbursement_Claims__r 
                                                                                        where DJC_Wellness_Request_Status__c='Approved')
                                              from case where   status = 'Approved'];
            system.assert(expenseCasesCreated!= null && expenseCasesCreated.size()==5);
            system.assert(expenseCasesCreated[0].Wellness_Reimbursement_Claims__r.size()>0);
            for(Case c:expenseCasesCreated){
             system.assertEquals(c.createddate , mDivToCutoff.get(c.division__c));
            }
            list<string> restURLRegionParams = new list<string>{'APAC','EMEA','Americas','Americas-Canada','Americas-LatinAmerica'};

            for(String region : restURLRegionParams ){
                RestRequest req = new RestRequest(); 
                RestResponse res = new RestResponse();        
                req.requestURI = '/GetEDReimbursementClaims/'+ region +'/';  
                req.httpMethod = 'GET';
                RestContext.request = req;
                RestContext.response = res;        
                DJC_EducationIntegrationController.ResponseHandler results = DJC_EducationIntegrationController.getAllReimbursementClaims();        
                System.assertEquals('Success', results.status);
                System.assertEquals(1, results.educationClaims.size());   
            }
     
            Test.stopTest();        
            validateCaseStatus('Extracted for Payment');
    }  
        
    private static void setUp() {
        APACCase = Test_Wellness_Util.createAPACEduCase();
        EMEACase = Test_Wellness_Util.createEMEAEduCase();
        Test.setCreatedDate(apacCase.id,system.today().addmonths(-1));
        Test.setCreatedDate(EMEACase.id,system.today().addmonths(-1));

        DJC_Wellness_Reimbursement_Claim__c apacClaim1 = createEdClaim(APACCase, 'INR', 1);        
        DJC_Wellness_Reimbursement_Claim__c apacClaim2 = createEdClaim(APACCase, 'USD', 1);
        DJC_Wellness_Reimbursement_Claim__c emeaClaim1 = createEdClaim(EMEACase, 'USD', 1);        
        DJC_Wellness_Reimbursement_Claim__c emeaClaim2 = createEdClaim(EMEACase, 'USD', 1);
        DJC_Wellness_Reimbursement_Claim__c emeaClaim3 = createEdClaim(EMEACase, 'EUR', 1);
        DJC_Wellness_Reimbursement_Claim__c emeaClaim4 = createEdClaim(EMEACase, 'EUR', 1);
        emeaClaim4.DJC_Education_Taxable__c = true;
        List<DJC_Wellness_Reimbursement_Claim__c> claims = new List<DJC_Wellness_Reimbursement_Claim__c> {apacclaim1, apacclaim2, emeaclaim1, emeaclaim2, emeaClaim3,emeaClaim4};
        insert claims;
        apacCase.status = 'Approved';
        emeaCase.status = 'Approved';
        List<Case> cases = new List<Case>{apacCase, emeaCase};
        update cases;
    } 
    
    private static DJC_Wellness_Reimbursement_Claim__c createClaim(Case wellnessCase, String claimCurrencyIsoCode, Double amountRequested) {
        return Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                                                      Test_Wellness_Util.buildFieldsForClaim(System.today(), 'Submitted', 'Fitness', claimCurrencyIsoCode, amountRequested,null), false);
    }
    
    private static DJC_Wellness_Reimbursement_Claim__c createEdClaim(Case wellnessCase, String claimCurrencyIsoCode, Double amountRequested) {
        return Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                                                      Test_Wellness_Util.buildFieldsForClaim(null, 'Submitted', 'Education', claimCurrencyIsoCode, amountRequested , System.today()), false);
    }
    
    private static void validateCaseStatus(String status) {
        for (Case c : [select status from case]) {
            system.assertEquals(status, c.status);
        }
    }

    private static void validateCaseStatus(String status, Case wellnessCase) {
        for (Case c : [select status from case where id = :wellnessCase.id]) {
            system.assertEquals(status, c.status);
        }
    }
}