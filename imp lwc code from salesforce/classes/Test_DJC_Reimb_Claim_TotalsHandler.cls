@isTest(SeeAllData = false)
public with sharing class Test_DJC_Reimb_Claim_TotalsHandler {
	//W-353351 Removing totals logic from the  DJC_Reimbursement_Total_Claimed__c object and calculating on the fly.
	/*
	static testMethod void testTotalsCalculatedWhenClaimCreated(){

        Case wellnessCase = Test_Wellness_Util.createEMEAWellnessCase();
        
        wellnessCase = [SELECT CreatedDate,type,division__c, ContactId FROM Case WHERE Id = :wellnessCase.Id];
        
		Test.startTest();
        
        Date createdDate = Date.newInstance(wellnessCase.CreatedDate.year(), wellnessCase.CreatedDate.month(), wellnessCase.CreatedDate.day());
        
		DJC_Wellness_Reimbursement_Claim__c claim1 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                                                               Test_Wellness_Util.buildFieldsForClaim(createdDate, 'Submitted', 'Fitness', 'EUR', 5,null), true);

		DJC_Wellness_Reimbursement_Claim__c claim2 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                                                               Test_Wellness_Util.buildFieldsForClaim(createdDate, 'Submitted', 'Fitness', 'EUR', 2,null), true);

		DJC_Wellness_Reimbursement_Claim__c claim3 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                                                               Test_Wellness_Util.buildFieldsForClaim(createdDate, 'Approved', 'Fitness', 'EUR', 8,null), true);

		DJC_Wellness_Reimbursement_Claim__c claim4 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                                                               Test_Wellness_Util.buildFieldsForClaim(createdDate, 'Approved', 'Fitness', 'EUR', 3,null), true);
		Test.stopTest();

        DJC_QuarterTimeRangeManager timeRangeManager = new DJC_QuarterTimeRangeManager(DJC_Region.EMEA);
        
        String currentPeriod = timeRangeManager.getCurrentTimeRange(createdDate);
        String previousPeriod = timeRangeManager.getPreviousTimeRange(createdDate);
        
		List<DJC_Reimbursement_Total_Claimed__c> totals = [SELECT Period__c, Policy__c, Status__c, Amount__c FROM DJC_Reimbursement_Total_Claimed__c];

		Boolean currentPeriodSubmitted = false, currentPeriodApproved = false, lastPeriodSubmitted = false, lastPeriodApproved = false;

        System.assertEquals(4, totals.size());
        
		for(DJC_Reimbursement_Total_Claimed__c total : totals){
			
			if(total.Status__c == 'Submitted'){

				if(total.Period__c == currentPeriod){
					System.assertEquals(7.0, total.Amount__c);
					currentPeriodSubmitted = true;
				}else if(total.Period__c == previousPeriod){
					System.assertEquals(0.0, total.Amount__c);
					lastPeriodSubmitted = true;
				}

			}
			else if(total.Status__c == 'Approved'){

				if(total.Period__c == currentPeriod){
					System.assertEquals(11.0, total.Amount__c);
					currentPeriodApproved = true;
				}else if(total.Period__c == previousPeriod){
					System.assertEquals(0.0, total.Amount__c);
					lastPeriodApproved = true;
				}

			}

		}

		System.assert(currentPeriodApproved && currentPeriodSubmitted && lastPeriodApproved && lastPeriodSubmitted);

	}

	static testMethod void testTotalsCalculatedWhenClaimUpdated(){

        Case wellnessCase = Test_Wellness_Util.createEMEAWellnessCase();
        
        wellnessCase = [SELECT CreatedDate,type,division__c, ContactId FROM Case WHERE Id = :wellnessCase.Id];
        
		Test.startTest();
        
        Date createdDate = Date.newInstance(wellnessCase.CreatedDate.year(), wellnessCase.CreatedDate.month(), wellnessCase.CreatedDate.day());
        
		DJC_Wellness_Reimbursement_Claim__c claim1 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                                                               Test_Wellness_Util.buildFieldsForClaim(createdDate, 'Submitted', 'Fitness', 'EUR', 5,null), true);

		DJC_Wellness_Reimbursement_Claim__c claim2 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                                                               Test_Wellness_Util.buildFieldsForClaim(createdDate, 'Submitted', 'Fitness', 'EUR', 2,null), true);

		claim2.DJC_Wellness_Amount_Requested__c = 9;
		UPDATE claim2;
        
		Test.stopTest();

        DJC_QuarterTimeRangeManager timeRangeManager = new DJC_QuarterTimeRangeManager(DJC_Region.EMEA);
        
        String currentPeriod = timeRangeManager.getCurrentTimeRange(createdDate);
        String previousPeriod = timeRangeManager.getPreviousTimeRange(createdDate);
        
		List<DJC_Reimbursement_Total_Claimed__c> totals = [SELECT Period__c, Policy__c, Status__c, Amount__c FROM DJC_Reimbursement_Total_Claimed__c];

		Boolean currentPeriodSubmitted = false, lastPeriodSubmitted = false;

        System.assertEquals(4, totals.size());
        
		for(DJC_Reimbursement_Total_Claimed__c total : totals){
			
			if(total.Status__c == 'Submitted'){

				if(total.Period__c == currentPeriod){
					System.assertEquals(14.0, total.Amount__c);
					currentPeriodSubmitted = true;
				}else if(total.Period__c == previousPeriod){
					System.assertEquals(0.0, total.Amount__c);
					lastPeriodSubmitted = true;
				}

			}
		}

		System.assert(currentPeriodSubmitted && lastPeriodSubmitted);

	} 

	static testMethod void testTotalsCalculatedWhenClaimDeleted(){

        Case wellnessCase = Test_Wellness_Util.createEMEAWellnessCase();
        
        wellnessCase = [SELECT CreatedDate,type,division__c, ContactId FROM Case WHERE Id = :wellnessCase.Id];
        
		Test.startTest();
        
        Date createdDate = Date.newInstance(wellnessCase.CreatedDate.year(), wellnessCase.CreatedDate.month(), wellnessCase.CreatedDate.day());
        
		DJC_Wellness_Reimbursement_Claim__c claim1 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                                                               Test_Wellness_Util.buildFieldsForClaim(createdDate, 'Submitted', 'Fitness', 'EUR', 5,null), true);

		DJC_Wellness_Reimbursement_Claim__c claim2 = Test_Wellness_Util.createWellnessClaim(wellnessCase, 
                                                               Test_Wellness_Util.buildFieldsForClaim(createdDate, 'Submitted', 'Fitness', 'EUR', 2,null), true);

		DELETE claim2;
        
		Test.stopTest();

        DJC_QuarterTimeRangeManager timeRangeManager = new DJC_QuarterTimeRangeManager(DJC_Region.EMEA);
        
        String currentPeriod = timeRangeManager.getCurrentTimeRange(createdDate);
        String previousPeriod = timeRangeManager.getPreviousTimeRange(createdDate);
        
		List<DJC_Reimbursement_Total_Claimed__c> totals = [SELECT Period__c, Policy__c, Status__c, Amount__c FROM DJC_Reimbursement_Total_Claimed__c];

		Boolean currentPeriodSubmitted = false, lastPeriodSubmitted = false;

        System.assertEquals(4, totals.size());
        
		for(DJC_Reimbursement_Total_Claimed__c total : totals){
			
			if(total.Status__c == 'Submitted'){

				if(total.Period__c == currentPeriod){
					System.assertEquals(5.0, total.Amount__c);
					currentPeriodSubmitted = true;
				}else if(total.Period__c == previousPeriod){
					System.assertEquals(0.0, total.Amount__c);
					lastPeriodSubmitted = true;
				}

			}
		}

		System.assert(currentPeriodSubmitted && lastPeriodSubmitted);

	}
 */
}