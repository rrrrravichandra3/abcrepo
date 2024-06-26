@isTest(SeeAllData=false)
public class DJC_Wellness_Claim_TriggerHandlerTest {
    
    //Test APAC Wellness claims *under* Quarterly Limits
    private static testmethod void testAPACClaimUnderLimit() {        
        Case wellnessCase = Test_Wellness_Util.createAPACWellnessCase();
        Test.startTest();        
        
        DJC_Wellness_Reimbursement_Claim__c claim1 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                                                               Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 6, 17), 'Submitted', 'Fitness', 'INR', 100,null), true);
        
        DJC_Wellness_Reimbursement_Claim__c claim2 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                                                               Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 6, 17), 'Submitted', 'Fitness', 'INR', 100,null), true);


        DJC_Wellness_Reimbursement_Claim__c claim3 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                                                               Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 6, 17), 'Submitted', 'Fitness', 'INR', 100,null), true);
        
        Test.stopTest();
        List<DJC_Wellness_Reimbursement_Claim__c> claims = [select DJC_Wellness_Claim_Quarter__c, DJC_Wellness_Claim_Fiscal_Year_Start__c
                                                            from DJC_Wellness_Reimbursement_Claim__c];
        for (DJC_Wellness_Reimbursement_Claim__c claim : claims) {
            if (claim.id == claim1.id) {
                system.assertEquals('Q2 - 2015', claim.DJC_Wellness_Claim_Quarter__c);
                system.assertEquals('02 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);               
            }
            if (claim.id == claim2.id) {
                system.assertEquals('Q2 - 2015', claim.DJC_Wellness_Claim_Quarter__c);
                system.assertEquals('02 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);                               
            }
            if (claim.id == claim3.id) {
                system.assertEquals('Q2 - 2015', claim.DJC_Wellness_Claim_Quarter__c);                               
                system.assertEquals('02 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);               
            }        
        }        
    }
    
    //Test APAC Wellness claims *over* Quarterly Limits
    private static testmethod void testAPACClaimOverLimit() {
        Case wellnessCase = Test_Wellness_Util.createAPACWellnessCase();
        Test.startTest();
        DJC_Wellness_Reimbursement_Claim__c claim1 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2016, 9, 2), 'Submitted', 'Fitness', 'INR', 100,null), true);
        
        DJC_Wellness_Reimbursement_Claim__c claim2 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2016, 9, 2), 'Submitted', 'Fitness', 'INR', 100,null), true);

        try{
            DJC_Wellness_Reimbursement_Claim__c claim3 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                                 Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2016, 9, 2), 'Submitted', 'Fitness', 'INR', (Test_Wellness_Util.getApacWellnessLimit('Q3 - 2016') + 10.0).doubleValue(), null), true);
        } catch (Exception ex) {
            system.assert(ex.getMessage().contains('Claim amount is over the'));
        }                
        Test.stopTest();
        
        List<DJC_Wellness_Reimbursement_Claim__c> claims = [select DJC_Wellness_Claim_Quarter__c, DJC_Wellness_Claim_Fiscal_Year_Start__c
                                                            from DJC_Wellness_Reimbursement_Claim__c];
        
        System.assertEquals(2, claims.size());
        for (DJC_Wellness_Reimbursement_Claim__c claim : claims) {
            if (claim.id == claim1.id) {
                system.assertEquals('Q3 - 2016', claim.DJC_Wellness_Claim_Quarter__c);
                system.assertEquals('02 - 2016', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);               
            }
            if (claim.id == claim2.id) {
                system.assertEquals('Q3 - 2016', claim.DJC_Wellness_Claim_Quarter__c);
                system.assertEquals('02 - 2016', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);                               
            }
        }
    }
    
    //Test APAC Wellness claims *over* Quarterly Limits in bulk
    private static testmethod void testAPACClaimOverLimitInBulk() {
        Case wellnessCase = Test_Wellness_Util.createAPACWellnessCase();
        List<DJC_Wellness_Reimbursement_Claim__c> claims = new List<DJC_Wellness_Reimbursement_Claim__c>();
        Test.startTest();        
        DJC_Wellness_Reimbursement_Claim__c claim1 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 6, 17), 'Submitted', 'Fitness', 'INR', 100,null), false);  
        claims.add(claim1);
       
        DJC_Wellness_Reimbursement_Claim__c claim2 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 6, 17), 'Submitted', 'Fitness', 'INR', 100,null), false);  
        
        claims.add(claim2);
        
        DJC_Wellness_Reimbursement_Claim__c claim3 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 6, 17), 'Submitted', 'Fitness', 'INR', (Test_Wellness_Util.getApacWellnessLimit('Q3 - 2016') + 10.0).doubleValue(),null), false);  
        
        claims.add(claim3);
        try {
            Database.SaveResult[] result = Database.insert(claims);
        } catch (Exception ex) {
            system.assert(ex.getMessage().contains('Claim amount is over'));
        }                
        Test.stopTest();
        
        List<DJC_Wellness_Reimbursement_Claim__c> allClaims = [select DJC_Wellness_Claim_Quarter__c, DJC_Wellness_Claim_Fiscal_Year_Start__c
                                                               from DJC_Wellness_Reimbursement_Claim__c];
        System.assert(allClaims.isEmpty());      
    }
    
    
    //Test APAC Wellness claims *under* Quarterly Limits. First add records then update
    private static testmethod void testAPACClaimUnderLimitAddThenUpdate() {        
        Case wellnessCase = Test_Wellness_Util.createAPACWellnessCase();
        Test.startTest();
        DJC_Wellness_Reimbursement_Claim__c claim1 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 6, 17), 'Submitted', 'Fitness', 'INR', 100,null), true);  
        
        DJC_Wellness_Reimbursement_Claim__c claim2 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 6, 17), 'Submitted', 'Fitness', 'INR', 100,null), true);  
         
        DJC_Wellness_Reimbursement_Claim__c claim3 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 6, 17), 'Submitted', 'Fitness', 'INR', 50,null), true);  
        
        Test.stopTest();
        List<DJC_Wellness_Reimbursement_Claim__c> claims = [select DJC_Wellness_Claim_Quarter__c, DJC_Wellness_Claim_Fiscal_Year_Start__c
                                                            from DJC_Wellness_Reimbursement_Claim__c];
        for (DJC_Wellness_Reimbursement_Claim__c claim : claims) {
            if (claim.id == claim1.id) {
                system.assertEquals('Q2 - 2015', claim.DJC_Wellness_Claim_Quarter__c);
                system.assertEquals('02 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);               
            }
            if (claim.id == claim2.id) {
                system.assertEquals('Q2 - 2015', claim.DJC_Wellness_Claim_Quarter__c);
                system.assertEquals('02 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);                               
            }
            if (claim.id == claim3.id) {
                system.assertEquals('Q2 - 2015', claim.DJC_Wellness_Claim_Quarter__c);                               
                system.assertEquals('02 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);               
            }
            
        }
        claim3.DJC_Wellness_Amount_Requested__c = 100;
        update claim3;
        System.assertEquals(300, claim1.DJC_Wellness_Amount_Requested__c + claim2.DJC_Wellness_Amount_Requested__c +claim3.DJC_Wellness_Amount_Requested__c);
    }
    
    //Test APAC Wellness claims *over* Quarterly Limits. First add records then update
    private static testmethod void testAPACClaimOverLimitAddThenUpdate(){        
        Case wellnessCase = Test_Wellness_Util.createAPACWellnessCase();
        Test.startTest();
        DJC_Wellness_Reimbursement_Claim__c claim1 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 6, 17), 'Submitted', 'Fitness', 'INR', 100,null), true);  
        
        DJC_Wellness_Reimbursement_Claim__c claim2 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 6, 17), 'Submitted', 'Fitness', 'INR', 100,null), true);  
               
        DJC_Wellness_Reimbursement_Claim__c claim3 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 6, 17), 'Submitted', 'Fitness', 'INR', 50,null), true);  

        Test.stopTest();
        List<DJC_Wellness_Reimbursement_Claim__c> claims = [select DJC_Wellness_Claim_Quarter__c, DJC_Wellness_Claim_Fiscal_Year_Start__c
                                                            from DJC_Wellness_Reimbursement_Claim__c];
        for (DJC_Wellness_Reimbursement_Claim__c claim : claims) {
            if (claim.id == claim1.id) {
                system.assertEquals('Q2 - 2015', claim.DJC_Wellness_Claim_Quarter__c);
                system.assertEquals('02 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);               
            }
            if (claim.id == claim2.id) {
                system.assertEquals('Q2 - 2015', claim.DJC_Wellness_Claim_Quarter__c);
                system.assertEquals('02 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);                               
            }
            if (claim.id == claim3.id) {
                system.assertEquals('Q2 - 2015', claim.DJC_Wellness_Claim_Quarter__c);                               
                system.assertEquals('02 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);               
            }
            
        }
        claim3.DJC_Wellness_Amount_Requested__c = 200;
        try {
            update claim3;
        } catch (Exception ex) {
            system.assert(ex.getMessage().contains('Claim amount is over'));
        }           
    }
    
    //Test APAC Wellness claims *under* Quaterly Limits. First add records then update for different quarters
    private static testmethod void testAPACClaimUnderLimitAddThenUpdateForDifferentQuarters(){        
        Case wellnessCase = Test_Wellness_Util.createAPACWellnessCase();
        Test.startTest();
        DJC_Wellness_Reimbursement_Claim__c claim1 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 4, 17), 'Submitted', 'Fitness', 'INR', 300,null), true); //Q1
        
        DJC_Wellness_Reimbursement_Claim__c claim2 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 6, 17), 'Submitted', 'Fitness', 'INR', 300,null), true); //Q2
        
        DJC_Wellness_Reimbursement_Claim__c claim3 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 10, 17), 'Submitted', 'Fitness', 'INR', 200,null), true);  //Q3
                
        DJC_Wellness_Reimbursement_Claim__c claim4 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2016, 1, 17), 'Submitted', 'Fitness', 'INR', 300,null), true);  //Q4
        
        Test.stopTest();
        List<DJC_Wellness_Reimbursement_Claim__c> claims = [select DJC_Wellness_Claim_Quarter__c, DJC_Wellness_Claim_Fiscal_Year_Start__c,
                                                            DJC_Wellness_Amount_Requested__c from DJC_Wellness_Reimbursement_Claim__c];
        for (DJC_Wellness_Reimbursement_Claim__c claim : claims) {
            if (claim.id == claim1.id) {
                system.assertEquals('Q1 - 2015', claim.DJC_Wellness_Claim_Quarter__c);
                system.assertEquals('02 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);               
                system.assertEquals(300, claim.DJC_Wellness_Amount_Requested__c);               
            }
            if (claim.id == claim2.id) {
                system.assertEquals('Q2 - 2015', claim.DJC_Wellness_Claim_Quarter__c);
                system.assertEquals('02 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);     
                system.assertEquals(300, claim.DJC_Wellness_Amount_Requested__c);               
            }
            if (claim.id == claim3.id) {
                system.assertEquals('Q3 - 2015', claim.DJC_Wellness_Claim_Quarter__c);                               
                system.assertEquals('02 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);        
                system.assertEquals(200, claim.DJC_Wellness_Amount_Requested__c);               
            }
            if (claim.id == claim4.id) {
                system.assertEquals('Q4 - 2015', claim.DJC_Wellness_Claim_Quarter__c);                               
                system.assertEquals('02 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);        
                system.assertEquals(300, claim.DJC_Wellness_Amount_Requested__c);               
            }
            
            
        }
        claim3.DJC_Wellness_Amount_Requested__c = 100;
        update claim3;
        System.assertEquals(1000, claim1.DJC_Wellness_Amount_Requested__c + claim2.DJC_Wellness_Amount_Requested__c +claim3.DJC_Wellness_Amount_Requested__c+claim4.DJC_Wellness_Amount_Requested__c);
        
        DJC_Wellness_Reimbursement_Claim__c claim5 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 9, 25), 'Submitted', 'Fitness', 'INR', 200,null), true); //Q3  
        
        System.assertEquals(1200, claim1.DJC_Wellness_Amount_Requested__c + claim2.DJC_Wellness_Amount_Requested__c +claim3.DJC_Wellness_Amount_Requested__c+claim4.DJC_Wellness_Amount_Requested__c+claim5.DJC_Wellness_Amount_Requested__c);
    }
    
    //Test APAC Wellness claims *under* Quaterly Limits. First add records then update for different quarters
    private static testmethod void testAPACClaimUnderLimitForMultiplecurrencies(){        
        Case wellnessCase = Test_Wellness_Util.createAPACWellnessCase();
        Test.startTest();
        DJC_Wellness_Reimbursement_Claim__c claim1 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 4, 17), 'Submitted', 'Fitness', 'INR', 300,null), true);  //Q1        
        
        DJC_Wellness_Reimbursement_Claim__c claim2 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 6, 17), 'Submitted', 'Fitness', 'EUR', 3,null), true);  //Q2

        DJC_Wellness_Reimbursement_Claim__c claim3 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 10, 17), 'Submitted', 'Fitness', 'JPY', 200,null), true);  //Q3
        
        DJC_Wellness_Reimbursement_Claim__c claim4 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2016, 1, 17), 'Submitted', 'Fitness', 'HKD', 5,null), true); //Q4
                
        Test.stopTest();
        List<DJC_Wellness_Reimbursement_Claim__c> claims = [select DJC_Wellness_Claim_Quarter__c, DJC_Wellness_Claim_Fiscal_Year_Start__c,
                                                            DJC_Wellness_Amount_Requested__c, CurrencyIsoCode from DJC_Wellness_Reimbursement_Claim__c];
        for (DJC_Wellness_Reimbursement_Claim__c claim : claims) {
            if (claim.id == claim1.id) {
                system.assertEquals('Q1 - 2015', claim.DJC_Wellness_Claim_Quarter__c);
                system.assertEquals('02 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);               
                system.assertEquals(300, claim.DJC_Wellness_Amount_Requested__c);          
                system.assertEquals('INR', claim.CurrencyIsoCode);
            }
            if (claim.id == claim2.id) {
                system.assertEquals('Q2 - 2015', claim.DJC_Wellness_Claim_Quarter__c);
                system.assertEquals('02 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);     
                system.assertEquals(3, claim.DJC_Wellness_Amount_Requested__c);               
                system.assertEquals('EUR', claim.CurrencyIsoCode);
            }
            if (claim.id == claim3.id) {
                system.assertEquals('Q3 - 2015', claim.DJC_Wellness_Claim_Quarter__c);                               
                system.assertEquals('02 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);        
                system.assertEquals(200, claim.DJC_Wellness_Amount_Requested__c);               
                system.assertEquals('JPY', claim.CurrencyIsoCode);
            }
            if (claim.id == claim4.id) {
                system.assertEquals('Q4 - 2015', claim.DJC_Wellness_Claim_Quarter__c);                               
                system.assertEquals('02 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);        
                system.assertEquals(5, claim.DJC_Wellness_Amount_Requested__c);               
                system.assertEquals('HKD', claim.CurrencyIsoCode);
            }                      
        }

        DJC_Wellness_Reimbursement_Claim__c claim5 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 6, 17), 'Submitted', 'Fitness', 'JPY', 500,null), false);        
        try {
            insert claim5;    
        } catch (Exception e) {
            system.assert(e.getMessage().contains('Claim amount is over'));
        }   
    }
    
    /*APAC health reimbursement test cases*/
    
    //Test APAC health claims *under* annual Limits. First add records then update
    private static testmethod void testAPACHealthClaimUnderLimitAddThenUpdate(){        
        Case wellnessCase = Test_Wellness_Util.createAPACHealthCase();
        Test.startTest();
        DJC_Wellness_Reimbursement_Claim__c claim1 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 2, 19), 'Submitted', 'Fitness', 'INR', 100,null), true);  
        
        DJC_Wellness_Reimbursement_Claim__c claim2 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 6, 17), 'Submitted', 'Fitness', 'INR', 100,null), true);  
        
        DJC_Wellness_Reimbursement_Claim__c claim3 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 9, 17), 'Submitted', 'Fitness', 'INR', 800,null), true);  
        

        Test.stopTest();
        List<DJC_Wellness_Reimbursement_Claim__c> claims = [select DJC_Wellness_Claim_Quarter__c, DJC_Wellness_Claim_Fiscal_Year_Start__c,
                                                            DJC_Wellness_Amount_Requested__c
                                                            from DJC_Wellness_Reimbursement_Claim__c];
        for (DJC_Wellness_Reimbursement_Claim__c claim : claims) {
            if (claim.id == claim1.id) {
                system.assertEquals('Q1 - 2015', claim.DJC_Wellness_Claim_Quarter__c);
                system.assertEquals('02 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);               
                system.assertEquals(100, claim.DJC_Wellness_Amount_Requested__c);               
            }
            if (claim.id == claim2.id) {
                system.assertEquals('Q2 - 2015', claim.DJC_Wellness_Claim_Quarter__c);
                system.assertEquals('02 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);     
                system.assertEquals(100, claim.DJC_Wellness_Amount_Requested__c);               
            }
            if (claim.id == claim3.id) {
                system.assertEquals('Q3 - 2015', claim.DJC_Wellness_Claim_Quarter__c);                               
                system.assertEquals('02 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);       
                system.assertEquals(800, claim.DJC_Wellness_Amount_Requested__c);               
            }
            
        }
        claim3.DJC_Wellness_Amount_Requested__c = 100;
        update claim3;
        System.assertEquals(300, claim1.DJC_Wellness_Amount_Requested__c + claim2.DJC_Wellness_Amount_Requested__c +claim3.DJC_Wellness_Amount_Requested__c);
    }
    
    //Test APAC health claims *over* annual Limits. First add records then update
    private static testmethod void testAPACHealthClaimOverLimitAddThenUpdate(){        
        Case wellnessCase = Test_Wellness_Util.createAPACHealthCase();
        Test.startTest();
        
        DJC_Wellness_Reimbursement_Claim__c claim1 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2016, 2, 19), 'Submitted', 'Fitness', 'INR', 100,null), true);  
        
        DJC_Wellness_Reimbursement_Claim__c claim2 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2016, 6, 17), 'Submitted', 'Fitness', 'INR', 100,null), true);  
                                
        DJC_Wellness_Reimbursement_Claim__c claim3 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2016, 9, 2), 'Submitted', 'Fitness', 'INR', Test_Wellness_Util.getApacHealthLimit('02 - 2016').doubleValue() - 200 ,null), true);
        Test.stopTest();

        claim3.DJC_Wellness_Amount_Requested__c = Test_Wellness_Util.getApacHealthLimit('02 - 2016').doubleValue() + 200;
        
        try{
            update claim3;
        } catch (Exception e) {
            system.assert(e.getMessage().contains('Claim amount is over'));
        }
        List<DJC_Wellness_Reimbursement_Claim__c> claims = [select DJC_Wellness_Claim_Quarter__c, DJC_Wellness_Claim_Fiscal_Year_Start__c,
                                                            DJC_Wellness_Amount_Requested__c
                                                            from DJC_Wellness_Reimbursement_Claim__c];
        for (DJC_Wellness_Reimbursement_Claim__c claim : claims) {
            if (claim.id == claim1.id) {
                system.assertEquals('Q1 - 2016', claim.DJC_Wellness_Claim_Quarter__c);
                system.assertEquals('02 - 2016', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);               
                system.assertEquals(100, claim.DJC_Wellness_Amount_Requested__c);               
            }
            if (claim.id == claim2.id) {
                system.assertEquals('Q2 - 2016', claim.DJC_Wellness_Claim_Quarter__c);
                system.assertEquals('02 - 2016', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);     
                system.assertEquals(100, claim.DJC_Wellness_Amount_Requested__c);               
            }
            if (claim.id == claim3.id) {
                system.assertEquals('Q3 - 2016', claim.DJC_Wellness_Claim_Quarter__c);                               
                system.assertEquals('02 - 2016', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);       
                system.assertEquals(Test_Wellness_Util.getApacHealthLimit('02 - 2016').doubleValue() - 200, claim.DJC_Wellness_Amount_Requested__c);               
            }   
        }
    }
    
    
    //Test APAC health claims *under* annual Limits. First add records then update for different years
    private static testmethod void testAPACHealthClaimOverLimitAddThenUpdateForMultipleYears(){        
        Case wellnessCase = Test_Wellness_Util.createAPACHealthCase();
        Test.startTest();        
        DJC_Wellness_Reimbursement_Claim__c claim1 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2013, 2, 19), 'Submitted', 'Fitness', 'INR', 1000,null), true);  

        DJC_Wellness_Reimbursement_Claim__c claim2 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2014, 6, 17), 'Submitted', 'Fitness', 'INR', 1000,null), true);  
                
        DJC_Wellness_Reimbursement_Claim__c claim3 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 9, 17), 'Submitted', 'Fitness', 'INR', 1200,null), true);  
        
        Test.stopTest();
        
        DJC_Wellness_Reimbursement_Claim__c claim4 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 4, 17), 'Submitted', 'Fitness', 'INR', 1,null), false);                  
        try{
            insert claim4;     
        } catch (Exception e) {
            system.assert(e.getMessage().contains('Claim amount is over'));
        }
        List<DJC_Wellness_Reimbursement_Claim__c> claims = [select DJC_Wellness_Claim_Quarter__c, DJC_Wellness_Claim_Fiscal_Year_Start__c,
                                                            DJC_Wellness_Amount_Requested__c
                                                            from DJC_Wellness_Reimbursement_Claim__c];
        for (DJC_Wellness_Reimbursement_Claim__c claim : claims) {
            if (claim.id == claim1.id) {
                system.assertEquals('Q1 - 2013', claim.DJC_Wellness_Claim_Quarter__c);
                system.assertEquals('02 - 2013', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);               
                system.assertEquals(1000, claim.DJC_Wellness_Amount_Requested__c);               
            }
            if (claim.id == claim2.id) {
                system.assertEquals('Q2 - 2014', claim.DJC_Wellness_Claim_Quarter__c);
                system.assertEquals('02 - 2014', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);     
                system.assertEquals(1000, claim.DJC_Wellness_Amount_Requested__c);               
            }
            if (claim.id == claim3.id) {
                system.assertEquals('Q3 - 2015', claim.DJC_Wellness_Claim_Quarter__c);                               
                system.assertEquals('02 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);
                system.assertEquals(1200, claim.DJC_Wellness_Amount_Requested__c);               
            }            
        }
    }
    
    /* EMEA Wellness and Health Reimbursement claims*/
    
    //Test EMEA Wellness claims *under* Quaterly Limits
    private static testmethod void testEMEAClaimUnderLimit(){        
        Case wellnessCase = Test_Wellness_Util.createEMEAWellnessCase();
        Test.startTest();
        DJC_Wellness_Reimbursement_Claim__c claim1 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 6, 17), 'Submitted', 'Fitness', 'EUR', 100,null), true);  
                
        DJC_Wellness_Reimbursement_Claim__c claim2 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 6, 17), 'Submitted', 'Fitness', 'EUR', 100,null), true);  
        
        DJC_Wellness_Reimbursement_Claim__c claim3 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 6, 17), 'Submitted', 'Fitness', 'EUR', 50,null), true);          
        Test.stopTest();
        List<DJC_Wellness_Reimbursement_Claim__c> claims = [select DJC_Wellness_Claim_Quarter__c, DJC_Wellness_Claim_Fiscal_Year_Start__c,
                                                            DJC_Wellness_Amount_Requested__c
                                                            from DJC_Wellness_Reimbursement_Claim__c];
        for (DJC_Wellness_Reimbursement_Claim__c claim : claims) {
            if (claim.id == claim1.id) {
                system.assertEquals('Q2 - 2015', claim.DJC_Wellness_Claim_Quarter__c);
                system.assertEquals('01 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);        
                system.assertEquals(100, claim.DJC_Wellness_Amount_Requested__c);        
            }
            if (claim.id == claim2.id) {
                system.assertEquals('Q2 - 2015', claim.DJC_Wellness_Claim_Quarter__c);
                system.assertEquals('01 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);                               
                system.assertEquals(100, claim.DJC_Wellness_Amount_Requested__c);        
            }
            if (claim.id == claim3.id) {
                system.assertEquals('Q2 - 2015', claim.DJC_Wellness_Claim_Quarter__c);                               
                system.assertEquals('01 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);               
                system.assertEquals(50, claim.DJC_Wellness_Amount_Requested__c);        
            }
            
        }        
    }
    
    //Test EMEA Wellness claims *over* Quarterly Limits
    private static testmethod void testEMEAClaimOverLimit() {
        Case wellnessCase = Test_Wellness_Util.createEMEAWellnessCase();
        Test.startTest();
        DJC_Wellness_Reimbursement_Claim__c claim1 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 6, 17), 'Submitted', 'Fitness', 'EUR', 100,null), true);  

        DJC_Wellness_Reimbursement_Claim__c claim2 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 6, 17), 'Submitted', 'Fitness', 'EUR', 100,null), true);  

        DJC_Wellness_Reimbursement_Claim__c claim3 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 6, 17), 'Submitted', 'Fitness', 'EUR', 400,null), false);  
        
        try {
            Database.SaveResult result = Database.insert(claim3);
        } catch (Exception ex) {
            system.assert(ex.getMessage().contains('Claim amount is over'));
        }                
        Test.stopTest();
        
        List<DJC_Wellness_Reimbursement_Claim__c> claims = [select DJC_Wellness_Claim_Quarter__c, DJC_Wellness_Claim_Fiscal_Year_Start__c,
                                                            DJC_Wellness_Amount_Requested__c
                                                            from DJC_Wellness_Reimbursement_Claim__c];
        System.assert(claims.size() == 2);      
        for (DJC_Wellness_Reimbursement_Claim__c claim : claims) {
            if (claim.id == claim1.id) {
                system.assertEquals('Q2 - 2015', claim.DJC_Wellness_Claim_Quarter__c);
                system.assertEquals('01 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);   
                system.assertEquals(100, claim.DJC_Wellness_Amount_Requested__c);        
            }
            if (claim.id == claim2.id) {
                system.assertEquals('Q2 - 2015', claim.DJC_Wellness_Claim_Quarter__c);
                system.assertEquals('01 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);                               
                system.assertEquals(100, claim.DJC_Wellness_Amount_Requested__c);        
            }
        }
    }
    
    //Test EMEA Wellness claims *over* Quarterly Limits in bulk
    private static testmethod void testEMEAClaimOverLimitInBulk() {
        Case wellnessCase = Test_Wellness_Util.createEMEAWellnessCase();
        List<DJC_Wellness_Reimbursement_Claim__c> claims = new List<DJC_Wellness_Reimbursement_Claim__c>();
        Test.startTest();        
        DJC_Wellness_Reimbursement_Claim__c claim1 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 6, 17), 'Submitted', 'Fitness', 'EUR', 100,null), false);  
        claims.add(claim1);
        
        DJC_Wellness_Reimbursement_Claim__c claim2 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 6, 17), 'Submitted', 'Fitness', 'EUR', 100,null), false);  
        claims.add(claim2);
        
        DJC_Wellness_Reimbursement_Claim__c claim3 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 6, 17), 'Submitted', 'Fitness', 'EUR', 400,null), false);  

        claims.add(claim3);
        try {
            Database.SaveResult[] result = Database.insert(claims);
        } catch (Exception ex) {
            system.assert(ex.getMessage().contains('Claim amount is over'));
        }                
        Test.stopTest();
        
        List<DJC_Wellness_Reimbursement_Claim__c> allClaims = [select DJC_Wellness_Claim_Quarter__c, DJC_Wellness_Claim_Fiscal_Year_Start__c
                                                               from DJC_Wellness_Reimbursement_Claim__c];
        System.assert(allClaims.isEmpty());      
    }
    
    
    //Test EMEA Wellness claims *under* Quarterly Limits. First add records then update
    private static testmethod void testEMEAClaimUnderLimitAddThenUpdate(){        
        Case wellnessCase = Test_Wellness_Util.createEMEAWellnessCase();
        Test.startTest();
        DJC_Wellness_Reimbursement_Claim__c claim1 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 9, 17), 'Submitted', 'Fitness', 'EUR', 100,null), true);  
        
        DJC_Wellness_Reimbursement_Claim__c claim2 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 9, 17), 'Submitted', 'Fitness', 'EUR', 100,null), true);  

        DJC_Wellness_Reimbursement_Claim__c claim3 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 9, 17), 'Submitted', 'Fitness', 'EUR', 40,null), true);  

        Test.stopTest();
        List<DJC_Wellness_Reimbursement_Claim__c> claims = [select DJC_Wellness_Claim_Quarter__c, DJC_Wellness_Claim_Fiscal_Year_Start__c
                                                            from DJC_Wellness_Reimbursement_Claim__c];
        for (DJC_Wellness_Reimbursement_Claim__c claim : claims) {
            if (claim.id == claim1.id) {
                system.assertEquals('Q3 - 2015', claim.DJC_Wellness_Claim_Quarter__c);
                system.assertEquals('01 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);               
            }
            if (claim.id == claim2.id) {
                system.assertEquals('Q3 - 2015', claim.DJC_Wellness_Claim_Quarter__c);
                system.assertEquals('01 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);                               
            }
            if (claim.id == claim3.id) {
                system.assertEquals('Q3 - 2015', claim.DJC_Wellness_Claim_Quarter__c);                               
                system.assertEquals('01 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);               
            }
            
        }
        claim3.DJC_Wellness_Amount_Requested__c = 50;
        update claim3;
        System.assertEquals(250, claim1.DJC_Wellness_Amount_Requested__c + claim2.DJC_Wellness_Amount_Requested__c +claim3.DJC_Wellness_Amount_Requested__c);
    }
    
    //Test EMEA Wellness claims *over* Quarterly Limits. First add records then update
    private static testmethod void testEMEAClaimOverLimitAddThenUpdate(){        
        Case wellnessCase = Test_Wellness_Util.createEMEAWellnessCase();
        Test.startTest();
        DJC_Wellness_Reimbursement_Claim__c claim1 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 10, 17), 'Submitted', 'Fitness', 'EUR', 100,null), true);  
        
        DJC_Wellness_Reimbursement_Claim__c claim2 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 11, 17), 'Submitted', 'Fitness', 'EUR', 100,null), true);  
        
        DJC_Wellness_Reimbursement_Claim__c claim3 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 12, 17), 'Submitted', 'Fitness', 'EUR', 50,null), true);  

        Test.stopTest();
        List<DJC_Wellness_Reimbursement_Claim__c> claims = [select DJC_Wellness_Claim_Quarter__c, DJC_Wellness_Claim_Fiscal_Year_Start__c
                                                            from DJC_Wellness_Reimbursement_Claim__c];
        for (DJC_Wellness_Reimbursement_Claim__c claim : claims) {
            if (claim.id == claim1.id) {
                system.assertEquals('Q4 - 2015', claim.DJC_Wellness_Claim_Quarter__c);
                system.assertEquals('01 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);               
            }
            if (claim.id == claim2.id) {
                system.assertEquals('Q4 - 2015', claim.DJC_Wellness_Claim_Quarter__c);
                system.assertEquals('01 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);                               
            }
            if (claim.id == claim3.id) {
                system.assertEquals('Q4 - 2015', claim.DJC_Wellness_Claim_Quarter__c);                               
                system.assertEquals('01 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);               
            }
            
        }
        claim3.DJC_Wellness_Amount_Requested__c = 200;
        try {
            update claim3;
        } catch (Exception ex) {
            system.assert(ex.getMessage().contains('Claim amount is over'));
        }           
    }
    
    //Test EMEA Wellness claims *under* Quaterly Limits. First add records then update for different quarters
    private static testmethod void testEMEAClaimUnderLimitAddThenUpdateForDifferentQuarters(){        
        Case wellnessCase = Test_Wellness_Util.createEMEAWellnessCase();
        Test.startTest();
        DJC_Wellness_Reimbursement_Claim__c claim1 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 3, 17), 'Submitted', 'Fitness', 'EUR', 250,null), true); //Q1
        
        DJC_Wellness_Reimbursement_Claim__c claim2 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 6, 17), 'Submitted', 'Fitness', 'EUR', 250,null), true);  //Q2

        DJC_Wellness_Reimbursement_Claim__c claim3 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 9, 17), 'Submitted', 'Fitness', 'EUR', 200,null), true);  //Q3


        DJC_Wellness_Reimbursement_Claim__c claim4 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 11, 17), 'Submitted', 'Fitness', 'EUR', 250,null), true);  //Q4
                
        Test.stopTest();
        List<DJC_Wellness_Reimbursement_Claim__c> claims = [select DJC_Wellness_Claim_Quarter__c, DJC_Wellness_Claim_Fiscal_Year_Start__c,
                                                            DJC_Wellness_Amount_Requested__c from DJC_Wellness_Reimbursement_Claim__c];
        for (DJC_Wellness_Reimbursement_Claim__c claim : claims) {
            if (claim.id == claim1.id) {
                system.assertEquals('Q1 - 2015', claim.DJC_Wellness_Claim_Quarter__c);
                system.assertEquals('01 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);               
                system.assertEquals(250, claim.DJC_Wellness_Amount_Requested__c);               
            }
            if (claim.id == claim2.id) {
                system.assertEquals('Q2 - 2015', claim.DJC_Wellness_Claim_Quarter__c);
                system.assertEquals('01 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);     
                system.assertEquals(250, claim.DJC_Wellness_Amount_Requested__c);               
            }
            if (claim.id == claim3.id) {
                system.assertEquals('Q3 - 2015', claim.DJC_Wellness_Claim_Quarter__c);                               
                system.assertEquals('01 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);        
                system.assertEquals(200, claim.DJC_Wellness_Amount_Requested__c);               
            }
            if (claim.id == claim4.id) {
                system.assertEquals('Q4 - 2015', claim.DJC_Wellness_Claim_Quarter__c);                               
                system.assertEquals('01 - 2015', claim.DJC_Wellness_Claim_Fiscal_Year_Start__c);        
                system.assertEquals(250, claim.DJC_Wellness_Amount_Requested__c);               
            }
            
            
        }
        claim3.DJC_Wellness_Amount_Requested__c = 100;
        update claim3;
        System.assertEquals(850, claim1.DJC_Wellness_Amount_Requested__c + claim2.DJC_Wellness_Amount_Requested__c +claim3.DJC_Wellness_Amount_Requested__c+claim4.DJC_Wellness_Amount_Requested__c);
        
        DJC_Wellness_Reimbursement_Claim__c claim5 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                             Test_Wellness_Util.buildFieldsForClaim(Date.newInstance(2015, 9, 25), 'Submitted', 'Fitness', 'EUR', 140,null), true); //Q3  
        
        System.assertEquals(990, claim1.DJC_Wellness_Amount_Requested__c + claim2.DJC_Wellness_Amount_Requested__c +claim3.DJC_Wellness_Amount_Requested__c+claim4.DJC_Wellness_Amount_Requested__c+claim5.DJC_Wellness_Amount_Requested__c);
    }
}