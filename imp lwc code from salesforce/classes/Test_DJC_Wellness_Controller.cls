@isTest
public class Test_DJC_Wellness_Controller {
    public static testMethod void testWellness() {
        /*Test_Wellness_Util.init();
        ESDJC_TestUtil.createSSOIdSetting();
        User portalUser = ESDJC_TestUtil.getPortalUser('India','APAC - All Countries');
        user currentUser = [select id from user where id =:UserInfo.getUserId() ];
        system.runAs(currentUser){
            ESDJC_TestUtil.assignPermission(portalUser.id,'ES_DJC_Employee_APAC');
        }
        DJC_Wellness_Provider__c apacProvider;        
        system.runAs(portalUser){
            PageReference pageRef = Page.DJC_ES_Requests;
            Test.setCurrentPage(pageRef);                                      
            DJC_Wellness_Controller controller = new DJC_Wellness_Controller();
            system.assertEquals('Wellness',controller.wellnessPolicy[0].policyText);
            system.assertEquals(Test_Wellness_Util.apacQtrWellness.id,controller.wellnessPolicy[0].policyId);
            system.assertEquals(Test_Wellness_Util.wellnessCategory.id,controller.wellnessPolicy[0].categoryId);                        
            controller.claimPolicyid = Test_Wellness_Util.apacQtrWellness.id;
            controller.headermsg = 'Wellness Reimbursement Request';
            controller.claimPolicyText = 'Wellness';
            controller.claimPolicyCategoryid = Test_Wellness_Util.wellnessCategory.id;
            controller.TypeParam = 'WellnessReq';
            controller.setType();
            System.assertEquals(true, controller.claimingForWellness);
            System.assertEquals(Test_Wellness_Util.APAC_CURRENCY, controller.newCase.currencyISOCode);
            System.assert(controller.currentPolicy.id == Test_Wellness_Util.apacQtrWellness.id);
            System.assertEquals(DJC_Region.APAC, controller.region);
            System.assertEquals(0, controller.claimsForCurrentQuarter);
            System.assertEquals(0, controller.claimsForPreviousQuarter);
            System.assertEquals(Test_Wellness_Util.APAC_QTR_LIMIT_WELLNESS, controller.balanceForCurrentQuarter);
            System.assertEquals(Test_Wellness_Util.APAC_QTR_LIMIT_WELLNESS, controller.balanceForPreviousQuarter);
            System.assertEquals(true, controller.canViewAgreement);
            System.assertEquals(controller, controller.controller);
            
            apacProvider = new DJC_Wellness_Provider__c();
            apacProvider.DJC_Contact__c = portalUser.contactid;
            apacProvider.Name = '24x7 Fitness';
            insert apacProvider;
                        
            controller.visibleIndex = 0;
            controller.addMore();
            controller.addProvider();
            System.assert(true, controller.displayProviderPopUp);
            controller.hideProvider();
            controller.Claims[0].claim.currencyISOCode = Test_Wellness_Util.APAC_CURRENCY;
            controller.Claims[0].claim.DJC_Wellness_Activity__c = 'Gym 1';
            controller.Claims[0].claim.DJC_Wellness_Provider__c = apacProvider.id;
            controller.Claims[0].claim.DJC_Wellness_Start_Date_of_Activity__c = System.today();
            controller.Claims[0].claim.DJC_Wellness_Amount_Requested__c = 100;
            controller.Claims[0].attachmentBlob = Blob.valueOf('Test Receipt');
            controller.Claims[0].fileName = 'Receipt 1';
            
            controller.visibleIndex = 1;
            controller.addMore();
            controller.Claims[1].claim.currencyISOCode = Test_Wellness_Util.APAC_CURRENCY;
            controller.Claims[1].claim.DJC_Wellness_Activity__c = 'Gym 2';
            controller.Claims[1].claim.DJC_Wellness_Provider__c = apacProvider.id;
            controller.Claims[1].claim.DJC_Wellness_Start_Date_of_Activity__c = System.today();
            controller.Claims[1].claim.DJC_Wellness_Amount_Requested__c = 100;
            controller.Claims[1].attachmentBlob = Blob.valueOf('Test Receipt2');
            controller.Claims[1].fileName = 'Receipt 2';
            controller.doSave();
            pageRef = Page.DJC_ES_Requests;
            pageRef.getParameters().put('caseId', controller.newCase.id);
            pageRef.getParameters().put('editMode', '1');
            Test.setCurrentPage(pageRef);
            controller = new DJC_Wellness_Controller();
            System.assertEquals(0, controller.claimsForCurrentQuarter);
            System.assertEquals(Test_Wellness_Util.APAC_QTR_LIMIT_WELLNESS, controller.BalanceForCurrentQuarter);
            System.assertEquals(null, controller.newCase.Tier__c); //Tier is assigned on submit
        }
        
        List<DJC_Wellness_Reimbursement_Claim__c> claims = [select DJC_wellness_Case__r.id,DJC_wellness_Case__r.Status,
                                                            DJC_Wellness_Case__r.Origin,DJC_Wellness_Case__r.Recordtype.Name,
                                                            DJC_Wellness_Amount_Requested__c, CurrencyISOCode,
                                                            DJC_Wellness_Activity__c, DJC_Wellness_Provider__r.id,
                                                            DJC_wellness_Case__r.CurrencyISOCode,
                                                            DJC_wellness_Case__r.DJC_Wellness_Health_Policy__r.id, 
                                                            DJC_wellness_Case__r.DJC_Wellness_Category__r.id,
                                                            DJC_wellness_Case__r.Type, DJC_wellness_Case__r.ES_DJC_Topic__c 
                                                            from DJC_Wellness_Reimbursement_Claim__c];
        Decimal total = 0;
        for (DJC_Wellness_Reimbursement_Claim__c claim : claims) {            
            decimal claimAmount = 0;
            if (claim.CurrencyIsoCode != Test_Wellness_Util.APAC_CURRENCY) {
                claimAmount = DJC_Wellness_Util.getConvertedCurrency(claim, Test_Wellness_Util.APAC_CURRENCY);
            } else {
                claimAmount = claim.DJC_Wellness_Amount_Requested__c;
            }
            total += claimAmount;
            System.assertEquals('Saved', claim.DJC_Wellness_Case__r.status);
            System.assertEquals(Test_Wellness_Util.apacQtrWellness.id, claim.DJC_wellness_Case__r.DJC_Wellness_Health_Policy__r.id);
            System.assertEquals(Test_Wellness_Util.APAC_CURRENCY, claim.CurrencyISOCode);
            System.assertEquals(Test_Wellness_Util.APAC_CURRENCY, claim.DJC_wellness_Case__r.CurrencyISOCode);
            System.assertEquals(Test_Wellness_Util.wellnessCategory.id, claim.DJC_wellness_Case__r.DJC_Wellness_Category__r.id);
            System.assertEquals('Wellness Reimbursement Request', claim.DJC_wellness_Case__r.Type);
            System.assertEquals('Wellness', claim.DJC_wellness_Case__r.ES_DJC_Topic__c);            
            System.assertEquals(apacProvider.id, claim.DJC_Wellness_Provider__r.id);
            System.assertEquals('All Expense Cases', claim.DJC_Wellness_Case__r.Recordtype.Name);
            System.assertEquals('Employee Success - Web', claim.DJC_Wellness_Case__r.Origin);
        }
        System.assertEquals(200, total);      */                 
    }
    
    public static testMethod void testHealth() {
       /* Test_Wellness_Util.init();
        ESDJC_TestUtil.createSSOIdSetting();
        User portalUser = ESDJC_TestUtil.getPortalUser('France','EMEA - All Countries');
        user currentUser = [select id from user where id =:UserInfo.getUserId() ];
        system.runAs(currentUser){
            ESDJC_TestUtil.assignPermission(portalUser.id,'ES_DJC_Employee_EMEA');
        }
        DJC_Wellness_Provider__c emeaProvider;        
        system.runAs(portalUser){            
            PageReference pageRef = Page.DJC_ES_Requests;
            Test.setCurrentPage(pageRef);                                      
            DJC_Wellness_Controller controller = new DJC_Wellness_Controller();
            system.assertEquals('vision/TCM',controller.healthPolicy[0].policyText);
            system.assertEquals(Test_Wellness_Util.emeaQtrHealthVision.id,controller.healthPolicy[0].policyId);
            system.assertEquals(Test_Wellness_Util.healthVisionCategory.id,controller.healthPolicy[0].categoryId);
            controller.claimPolicyid = Test_Wellness_Util.emeaQtrHealthVision.id;
            controller.headermsg = 'vision/TCM Reimbursement Request';
            controller.claimPolicyText = 'vision/TCM';
            controller.claimPolicyCategoryid = Test_Wellness_Util.healthVisionCategory.id;
            controller.TypeParam = 'HealthReq';
            controller.setType();
            System.assertEquals(false, controller.claimingForWellness);
            System.assertEquals(Test_Wellness_Util.EMEA_CURRENCY, controller.newCase.currencyISOCode);
            System.assert(controller.currentPolicy.id == Test_Wellness_Util.emeaQtrHealthVision.id);
            System.assertEquals(DJC_Region.EMEA, controller.region);
            System.assertEquals(0, controller.claimsForCurrentFiscalYear);
            System.assertEquals(0, controller.claimsForPreviousFiscalYear);
            System.assertEquals(Test_Wellness_Util.EMEA_ANNUAL_LIMIT_HEALTH, controller.balanceForCurrentFiscalYear);
            System.assertEquals(Test_Wellness_Util.EMEA_ANNUAL_LIMIT_HEALTH, controller.balanceForPreviousFiscalYear);
            System.assertEquals(true, controller.canViewAgreement);
            
            emeaProvider = new DJC_Wellness_Provider__c();
            emeaProvider.DJC_Contact__c = portalUser.contactid;
            emeaProvider.Name = '24x7 Fitness';
            insert emeaProvider;
            controller.renderClaim[0] = true;            
            controller.Claims[0].claim.currencyISOCode = Test_Wellness_Util.EMEA_CURRENCY;
            controller.Claims[0].claim.DJC_Wellness_Activity__c = 'Gym 1';
            controller.Claims[0].claim.DJC_Wellness_Provider__c = emeaProvider.id;
            controller.Claims[0].claim.DJC_Wellness_Start_Date_of_Activity__c = System.today();
            controller.Claims[0].claim.DJC_Wellness_Amount_Requested__c = 100;
            controller.Claims[0].attachmentBlob = Blob.valueOf('Test Receipt');
            controller.Claims[0].fileName = 'Receipt 1';
            
            controller.renderClaim[1] = true;
            controller.Claims[1].claim.currencyISOCode = Test_Wellness_Util.EMEA_CURRENCY;
            controller.Claims[1].claim.DJC_Wellness_Activity__c = 'Gym 2';
            controller.Claims[1].claim.DJC_Wellness_Provider__c = emeaProvider.id;
            controller.Claims[1].claim.DJC_Wellness_Start_Date_of_Activity__c = System.today();
            controller.Claims[1].claim.DJC_Wellness_Amount_Requested__c = 100;
            controller.Claims[1].attachmentBlob = Blob.valueOf('Test Receipt2');
            controller.Claims[1].fileName = 'Receipt 2';
            controller.tandc = true;
            controller.doSubmit();
            pageRef = Page.DJC_ES_Requests;
            pageRef.getParameters().put('caseId', controller.newCase.id);
            pageRef.getParameters().put('editMode', '1');
            Test.setCurrentPage(pageRef); 
            controller = new DJC_Wellness_Controller();
            System.assertEquals(200, controller.claimsForCurrentFiscalYear);
            System.assertEquals(Test_Wellness_Util.EMEA_ANNUAL_LIMIT_HEALTH - 200, controller.BalanceForCurrentFiscalYear);   
            System.assertEquals('Tier 2', controller.newCase.Tier__c);
        }
        
        List<DJC_Wellness_Reimbursement_Claim__c> claims = [select DJC_wellness_Case__r.id,DJC_wellness_Case__r.Status,
                                                            DJC_Wellness_Case__r.Origin,DJC_Wellness_Case__r.Recordtype.Name,
                                                            DJC_Wellness_Amount_Requested__c, CurrencyISOCode,
                                                            DJC_Wellness_Activity__c, DJC_Wellness_Provider__r.id,
                                                            DJC_wellness_Case__r.CurrencyISOCode,
                                                            DJC_wellness_Case__r.DJC_Wellness_Health_Policy__r.id, 
                                                            DJC_wellness_Case__r.DJC_Wellness_Category__r.id,
                                                            DJC_wellness_Case__r.Type, DJC_wellness_Case__r.ES_DJC_Topic__c 
                                                            from DJC_Wellness_Reimbursement_Claim__c];
        Decimal total = 0;
        for (DJC_Wellness_Reimbursement_Claim__c claim : claims) {
            system.debug('claimprint '+claim);
            decimal claimAmount = 0;
            if (claim.CurrencyIsoCode != Test_Wellness_Util.EMEA_CURRENCY) {
                claimAmount = DJC_Wellness_Util.getConvertedCurrency(claim, Test_Wellness_Util.EMEA_CURRENCY);
            } else {
                claimAmount = claim.DJC_Wellness_Amount_Requested__c;
            }
            total += claimAmount;
            System.assertEquals('Submitted', claim.DJC_Wellness_Case__r.status);
            System.assertEquals(Test_Wellness_Util.emeaQtrHealthVision.id, claim.DJC_wellness_Case__r.DJC_Wellness_Health_Policy__r.id);
            System.assertEquals(Test_Wellness_Util.EMEA_CURRENCY, claim.CurrencyISOCode);
            System.assertEquals(Test_Wellness_Util.EMEA_CURRENCY, claim.DJC_wellness_Case__r.CurrencyISOCode);
            System.assertEquals(Test_Wellness_Util.healthVisionCategory.id, claim.DJC_wellness_Case__r.DJC_Wellness_Category__r.id);
            System.assertEquals('Wellness Reimbursement Request', claim.DJC_wellness_Case__r.Type);
            System.assertEquals('vision/TCM', claim.DJC_wellness_Case__r.ES_DJC_Topic__c);            
            System.assertEquals(emeaProvider.id, claim.DJC_Wellness_Provider__r.id); 
            System.assertEquals('All Expense Cases', claim.DJC_Wellness_Case__r.Recordtype.Name);
            System.assertEquals('Employee Success - Web', claim.DJC_Wellness_Case__r.Origin);
        }               
        System.assertEquals(200, total); */         
    }
    
 /*   public static testMethod void testWellnessAttestationEMEA() {
        Test_Wellness_Util.init();
        testWellnessAttestation('France', 'EMEA - All Countries', true, System.Label.DJC_Wellness_Agreement_EMEA);
    }

    public static testMethod void testWellnessAttestationAPAC() {
        Test_Wellness_Util.init();
        testWellnessAttestation('India', 'APAC - All Countries', true, System.Label.DJC_Wellness_Agreement_APAC);
    }

    public static testMethod void testWellnessSKoreaCurrencyRoundUp() {
        Test_Wellness_Util.init();
        ESDJC_TestUtil.createSSOIdSetting();
        User portalUser = ESDJC_TestUtil.getPortalUser('Korea, Republic of','APAC - All Countries');
        user currentUser = [select id from user where id =:UserInfo.getUserId() ];
        system.runAs(currentUser){
            ESDJC_TestUtil.assignPermission(portalUser.id,'ES_DJC_Employee_APAC');
        }
        DJC_Wellness_Provider__c koreaProvider;        
        system.runAs(portalUser){
            PageReference pageRef = Page.DJC_ES_Requests;
            Test.setCurrentPage(pageRef);                                      
            DJC_Wellness_Controller controller = new DJC_Wellness_Controller();
            controller.claimPolicyid = Test_Wellness_Util.koreaQtrWellness.id;
            controller.headermsg = 'Wellness Reimbursement Request';
            controller.claimPolicyText = 'Wellness';
            controller.claimPolicyCategoryid = Test_Wellness_Util.wellnessCategory.id;
            controller.TypeParam = 'WellnessReq';
            controller.setType();
            koreaProvider = new DJC_Wellness_Provider__c();
            koreaProvider.DJC_Contact__c = portalUser.contactid;
            koreaProvider.Name = '24x7 Fitness';
            insert koreaProvider;
                        
            controller.visibleIndex = 0;
            controller.addMore();
            controller.addProvider();
            controller.hideProvider();
            controller.Claims[0].claim.currencyISOCode = 'TWD';
            controller.Claims[0].claim.DJC_Wellness_Activity__c = 'Gym 1';
            controller.Claims[0].claim.DJC_Wellness_Provider__c = koreaProvider.id;
            controller.Claims[0].claim.DJC_Wellness_Start_Date_of_Activity__c = System.today();
            controller.Claims[0].claim.DJC_Wellness_Amount_Requested__c = 10.23;
            controller.Claims[0].attachmentBlob = Blob.valueOf('Test Receipt');
            controller.Claims[0].fileName = 'Receipt 1';
            controller.tandc = true;
            controller.doSubmit();
        }
        
        List<DJC_Wellness_Reimbursement_Claim__c> claims = [select DJC_wellness_Case__r.id,DJC_wellness_Case__r.Status, 
                                                            DJC_Wellness_Amount_Requested__c, CurrencyISOCode,
                                                            DJC_Wellness_Activity__c, DJC_Wellness_Provider__r.id,
                                                            DJC_wellness_Case__r.CurrencyISOCode,
                                                            DJC_wellness_Case__r.DJC_Wellness_Health_Policy__r.id, 
                                                            DJC_wellness_Case__r.DJC_Wellness_Category__r.id,
                                                            DJC_wellness_Case__r.Type, DJC_wellness_Case__r.ES_DJC_Topic__c 
                                                            from DJC_Wellness_Reimbursement_Claim__c];
        Decimal convertedAmt = 0; 
        Decimal claimAmount = 0;
        for (DJC_Wellness_Reimbursement_Claim__c claim : claims) {            
            claimAmount = DJC_Wellness_Util.getConvertedCurrency(claim, 'KRW');
            convertedAmt = Math.ceil(10.23 * Test_Wellness_Util.currencyTypeConversionRateForDefaultCurrency('KRW') / Test_Wellness_Util.currencyTypeConversionRateForClaim('TWD'));
        }
        System.assertEquals(claimAmount, convertedAmt);                       
    }

    public static void testWellnessAttestation(string country, string division, boolean canViewAgreementExpected, string agreementExpected){
        ESDJC_TestUtil.createSSOIdSetting();
        User portalUser = ESDJC_TestUtil.getPortalUser(country, division);
        user currentUser = [select id from user where id =:UserInfo.getUserId() ];
        system.runAs(currentUser){
            ESDJC_TestUtil.assignPermission(portalUser.id,'ES_DJC_Employee_EMEA');
        }
        DJC_Wellness_Provider__c emeaProvider;        
        system.runAs(portalUser){            
            PageReference pageRef = Page.DJC_ES_Requests;
            Test.setCurrentPage(pageRef);                                      
            DJC_Wellness_Controller controller = new DJC_Wellness_Controller();
            system.assertEquals(canViewAgreementExpected, controller.canViewAgreement);
            system.assertEquals(agreementExpected, controller.wellnessAgreement);
        }
    }*/
    
}