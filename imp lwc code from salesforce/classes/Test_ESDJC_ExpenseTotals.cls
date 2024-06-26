@isTest
public with sharing class Test_ESDJC_ExpenseTotals {
    public  static map<string,decimal> mCurrencyToConvRate = new map<string,decimal>();

    //Read all MDTs
    //Get exchangerate 
    static{
        List<CurrencyType> currTypes = [SELECT ConversionRate,DecimalPlaces,IsActive,
                                                       IsCorporate,IsoCode FROM CurrencyType where IsActive = true];
        for(CurrencyType curr:currTypes){
            mCurrencyToConvRate.put(curr.IsoCode,curr.ConversionRate);
        }
        Test_Wellness_Util.init();

    }
	
    static  testmethod void testWellnessClaimTotalsForEligibleRegions(){

        //Create 3 cases for we with 2 claim(default/nondefault) each for wellness eligible region.
        system.assert(mCurrencyToConvRate.size()>0);
        List<Case> Edcases = new List<Case>();
        Case APACWellnesscase = Test_Wellness_Util.createWellnessCaseByRegion('APAC - All Countries');
        Case EMEAWellnesscase = Test_Wellness_Util.createWellnessCaseByRegion('EMEA - All Countries');
        Case LatinWellnesscase = Test_Wellness_Util.createWellnessCaseByRegion('Americas - Latin America');

        Edcases.add(APACWellnesscase);
        Edcases.add(EMEAWellnesscase);
        Edcases.add(LatinWellnesscase);
        insert Edcases;

        list<DJC_Wellness_Reimbursement_Claim__c> claims = new list<DJC_Wellness_Reimbursement_Claim__c>();
        DJC_Wellness_Reimbursement_Claim__c APACDefClaim = Test_Wellness_Util.createWellnessClaim(APACWellnesscase,Test_Wellness_Util.buildFieldsForClaim(system.today() ,'Approved','Fitness','INR',1,null),false);      
        DJC_Wellness_Reimbursement_Claim__c APACNonDefClaim = Test_Wellness_Util.createWellnessClaim(APACWellnesscase,Test_Wellness_Util.buildFieldsForClaim(system.today() ,'Approved','Fitness','EUR',1,null),false);      
        DJC_Wellness_Reimbursement_Claim__c EMEADefClaim = Test_Wellness_Util.createWellnessClaim(EMEAWellnesscase,Test_Wellness_Util.buildFieldsForClaim(system.today() ,'Approved','Fitness','EUR',1,null),false);      
        DJC_Wellness_Reimbursement_Claim__c EMEANonDefClaim = Test_Wellness_Util.createWellnessClaim(EMEAWellnesscase,Test_Wellness_Util.buildFieldsForClaim(system.today() ,'Approved','Fitness','INR',1,null),false);      
        DJC_Wellness_Reimbursement_Claim__c LatinDefClaim = Test_Wellness_Util.createWellnessClaim(LatinWellnesscase,Test_Wellness_Util.buildFieldsForClaim(system.today() ,'Approved','Fitness','MXN',1,null),false);      
        DJC_Wellness_Reimbursement_Claim__c LatinNonDefClaim = Test_Wellness_Util.createWellnessClaim(LatinWellnesscase,Test_Wellness_Util.buildFieldsForClaim(system.today() ,'Approved','Fitness','EUR',1,null),false);      
        claims.add(APACDefClaim);
        claims.add(APACNonDefClaim);
        claims.add(EMEADefClaim);
        claims.add(EMEANonDefClaim);
        claims.add(LatinDefClaim);
        claims.add(LatinNonDefClaim);
        insert claims;



        ApexPages.StandardController sc1 = new ApexPages.StandardController(APACWellnesscase);
        DJC_ExpenseTotalsController ctrller1 = new DJC_ExpenseTotalsController(sc1);
        validateClaims(ctrller1.ClaimDetailList,APACNonDefClaim);

        ApexPages.StandardController sc2 = new ApexPages.StandardController(EMEAWellnesscase);
        DJC_ExpenseTotalsController ctrller2 = new DJC_ExpenseTotalsController(sc2);
        validateClaims(ctrller2.ClaimDetailList,EMEANonDefClaim);

        ApexPages.StandardController sc3 = new ApexPages.StandardController(LatinWellnesscase);
        DJC_ExpenseTotalsController ctrller3 = new DJC_ExpenseTotalsController(sc3);
        validateClaims(ctrller3.ClaimDetailList,LatinNonDefClaim);
    }
    
    static  testmethod void testEducationClaimTotalsForEligibleRegions(){

        //Create 3 cases for we with 2 claim(default/nondefault) each for wellness eligible region.
        system.assert(mCurrencyToConvRate.size()>0);
        List<Case> Edcases = new List<Case>();
        Case APACEdcase = Test_Wellness_Util.createEdcaseByRegion('APAC - All Countries');
        Case EMEAEdcase = Test_Wellness_Util.createEdcaseByRegion('EMEA - All Countries');
        Case LatinEdcase = Test_Wellness_Util.createEdcaseByRegion('Americas - Latin America');
        Case USEdcase = Test_Wellness_Util.createEdcaseByRegion('Americas - USA');
        Case CanadaEdcase = Test_Wellness_Util.createEdcaseByRegion('Americas - Canada');

        Edcases.add(APACEdcase);
        Edcases.add(EMEAEdcase);
        Edcases.add(LatinEdcase);
        Edcases.add(USEdcase);
        Edcases.add(CanadaEdcase);
        insert Edcases;

        list<DJC_Wellness_Reimbursement_Claim__c> claims = new list<DJC_Wellness_Reimbursement_Claim__c>();
        DJC_Wellness_Reimbursement_Claim__c APACDefClaim = Test_Wellness_Util.createWellnessClaim(APACEdcase,Test_Wellness_Util.buildFieldsForClaim(null ,'Approved','Fitness','INR',1,System.Today()),false);      
        DJC_Wellness_Reimbursement_Claim__c APACNonDefClaim = Test_Wellness_Util.createWellnessClaim(APACEdcase,Test_Wellness_Util.buildFieldsForClaim(null ,'Approved','Fitness','EUR',1,System.Today()),false);      
        DJC_Wellness_Reimbursement_Claim__c EMEADefClaim = Test_Wellness_Util.createWellnessClaim(EMEAEdcase,Test_Wellness_Util.buildFieldsForClaim(null ,'Approved','Fitness','EUR',1,System.Today()),false);      
        DJC_Wellness_Reimbursement_Claim__c EMEANonDefClaim = Test_Wellness_Util.createWellnessClaim(EMEAEdcase,Test_Wellness_Util.buildFieldsForClaim(null ,'Approved','Fitness','INR',1,System.Today()),false);      
        DJC_Wellness_Reimbursement_Claim__c LatinDefClaim = Test_Wellness_Util.createWellnessClaim(LatinEdcase,Test_Wellness_Util.buildFieldsForClaim(null ,'Approved','Fitness','MXN',1,System.Today()),false);      
        DJC_Wellness_Reimbursement_Claim__c LatinNonDefClaim = Test_Wellness_Util.createWellnessClaim(LatinEdcase,Test_Wellness_Util.buildFieldsForClaim(null ,'Approved','Fitness','EUR',1,System.Today()),false);       
        DJC_Wellness_Reimbursement_Claim__c USDefClaim =Test_Wellness_Util.createWellnessClaim(USEdcase,Test_Wellness_Util.buildFieldsForClaim(null ,'Approved','Fitness','USD',1,System.Today()),false);      
        DJC_Wellness_Reimbursement_Claim__c USNonDefClaim = Test_Wellness_Util.createWellnessClaim(USEdcase,Test_Wellness_Util.buildFieldsForClaim(null ,'Approved','Fitness','EUR',1,System.Today()),false);        
        DJC_Wellness_Reimbursement_Claim__c CanadaDefClaim = Test_Wellness_Util.createWellnessClaim(CanadaEdcase,Test_Wellness_Util.buildFieldsForClaim(null ,'Approved','Fitness','CAD',1,System.Today()),false);      
        DJC_Wellness_Reimbursement_Claim__c CanadaNonDefClaim = Test_Wellness_Util.createWellnessClaim(CanadaEdcase,Test_Wellness_Util.buildFieldsForClaim(null ,'Approved','Fitness','EUR',1,System.Today()),false);      
        
        claims.add(APACDefClaim);
        claims.add(APACNonDefClaim);
        claims.add(EMEADefClaim);
        claims.add(EMEANonDefClaim);
        claims.add(LatinDefClaim);
        claims.add(LatinNonDefClaim);        
        claims.add(USDefClaim);
        claims.add(USNonDefClaim);        
        claims.add(CanadaDefClaim);
        claims.add(CanadaNonDefClaim);
        insert claims;



        ApexPages.StandardController sc1 = new ApexPages.StandardController(APACEdcase);
        DJC_ExpenseTotalsController ctrller1 = new DJC_ExpenseTotalsController(sc1);
        validateClaims(ctrller1.ClaimDetailList,APACNonDefClaim);

        ApexPages.StandardController sc2 = new ApexPages.StandardController(EMEAEdcase);
        DJC_ExpenseTotalsController ctrller2 = new DJC_ExpenseTotalsController(sc2);
        validateClaims(ctrller2.ClaimDetailList,EMEANonDefClaim);

        ApexPages.StandardController sc3 = new ApexPages.StandardController(LatinEdcase);
        DJC_ExpenseTotalsController ctrller3 = new DJC_ExpenseTotalsController(sc3);
        validateClaims(ctrller3.ClaimDetailList,LatinNonDefClaim);        
        
        ApexPages.StandardController sc4 = new ApexPages.StandardController(USEdcase);
        DJC_ExpenseTotalsController ctrller4 = new DJC_ExpenseTotalsController(sc4);
        validateClaims(ctrller4.ClaimDetailList,USNonDefClaim);

        ApexPages.StandardController sc5 = new ApexPages.StandardController(CanadaEdcase);
        DJC_ExpenseTotalsController ctrller5 = new DJC_ExpenseTotalsController(sc5);
        validateClaims(ctrller5.ClaimDetailList,CanadaNonDefClaim);


    }
    public static void validateClaims(list<DJC_ExpenseTotalsController.ClaimDetail> ClaimDetailList,DJC_Wellness_Reimbursement_Claim__c nonDefClaim){
                
        for (DJC_ExpenseTotalsController.claimDetail det:ClaimDetailList){   
            
            if(det.status == 'Approved'){
                
                system.debug(LOGGINGLEVEL.INFO,mCurrencyToConvRate.get(det.PolicyCurrencyISO));
                system.debug(LOGGINGLEVEL.INFO,mCurrencyToConvRate.get(nonDefClaim.CurrencyISOCode));
               
                Decimal ExpectedTotal = 1+  (mCurrencyToConvRate.get(det.PolicyCurrencyISO) / mCurrencyToConvRate.get(nonDefClaim.CurrencyISOCode)).setScale(2, System.roundingMode.HALF_EVEN) ;
                System.AssertEquals(det.Total ,ExpectedTotal);
                break;//First claim Detail rec is for the latest quarter.
            } 
        }
    }
}