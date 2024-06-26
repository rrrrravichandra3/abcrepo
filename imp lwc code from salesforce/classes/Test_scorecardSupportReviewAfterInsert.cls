@isTest
private class Test_scorecardSupportReviewAfterInsert {
 
	public static testMethod void execute_methods_scorecardSupportReviewAfterInsertZero() {
		 
		GenerateEnvironmentTest.genScorecardSupportReviewAfterInsert();
		  
		Test.startTest();
        
        try {
        	 
            ScorecardSupportReview__c ssreview = GenerateEnvironmentTest.sq1;
                        
            ssreview.ForecastAccuracyRating__c = null;
            ssreview.SalesImpactRating__c = null;
            ssreview.TimeOnPlatformRating__c = null;
            ssreview.ForecastAccuracyWeight__c = null;
            ssreview.SalesImpactWeight__c = null;
            ssreview.TimeOnPlatformWeight__c = null;
            
            ssreview.WeightCS__c = null;
			ssreview.WeightRenewals__c = null;
            ssreview.WeightWMCases__c = null;
            ssreview.WeightWMSMES__c = null;
            ssreview.WeightWMHC__c = null;
            ssreview.WeightWMPA__c = null;
            ssreview.WeightSI__c = null;
            
            update ssreview;
            
            ssreview.WeightCS__c = 0;
			ssreview.WeightRenewals__c = 0;
            ssreview.WeightWMCases__c = 0;
            ssreview.WeightWMSMES__c = 0;
            ssreview.WeightWMHC__c = 0;
            ssreview.WeightWMPA__c = 0;
            ssreview.WeightSI__c = 0;

            ssreview.ForecastAccuracyRating__c = -1;
            ssreview.SalesImpactRating__c = -1;
            ssreview.TimeOnPlatformRating__c = -1;
            
            ssreview.SalesImpactWeight__c = 101;
            ssreview.TimeOnPlatformWeight__c = 0;
            ssreview.ForecastAccuracyWeight__c = 0;
            
            update ssreview;
		} catch (Exception e) {
            System.debug(' ****************** execute_methods_scorecardSupportReviewAfterInsertZero * ');
            System.debug(e.getMessage());
		}
            
        Test.stopTest();
            
	}

	public static testMethod void execute_methods_scorecardSupportReviewAfterInsertOne() {
		
		GenerateEnvironmentTest.genScorecardSupportReviewAfterInsert();
		
		Test.startTest();
            
		try {
            ScorecardSupportReview__c ssreview = GenerateEnvironmentTest.sq1;
                                    
            ssreview.WeightCS__c = 99;
			ssreview.WeightRenewals__c = 2;
            ssreview.WeightWMCases__c = 0;
            ssreview.WeightWMSMES__c = 0;
            ssreview.WeightWMHC__c = 0;
            ssreview.WeightWMPA__c = 0;
            ssreview.WeightSI__c = 0;

            ssreview.ForecastAccuracyRating__c = 6;
            ssreview.SalesImpactRating__c = 6;
            ssreview.TimeOnPlatformRating__c = 6;
            
            ssreview.SalesImpactWeight__c = 97;
            ssreview.TimeOnPlatformWeight__c = 2;
            ssreview.ForecastAccuracyWeight__c = 2;
            
            update ssreview;
            
            ssreview.WeightCS__c = 99;
			ssreview.WeightRenewals__c = 2;
            ssreview.WeightWMCases__c = 0;
            ssreview.WeightWMSMES__c = 0;
            ssreview.WeightWMHC__c = 0;
            ssreview.WeightWMPA__c = 0;
            ssreview.WeightSI__c = 0;

            ssreview.ForecastAccuracyRating__c = 6;
            ssreview.SalesImpactRating__c = 6;
            ssreview.TimeOnPlatformRating__c = 6;
            
            ssreview.SalesImpactWeight__c = 99;
            ssreview.TimeOnPlatformWeight__c = 2;
            ssreview.ForecastAccuracyWeight__c = 0;
            
            update ssreview;

		} catch (Exception e) {
            System.debug(' ****************** execute_methods_scorecardSupportReviewAfterInsertOne * ');
            System.debug(e.getMessage());
		}
            
        Test.stopTest();
            
	}

	public static testMethod void execute_methods_scorecardSupportReviewAfterInsertTwo() {
		
		GenerateEnvironmentTest.genScorecardSupportReviewAfterInsert();
		
		Test.startTest();
		
		try {
            ScorecardSupportReview__c ssreview = GenerateEnvironmentTest.sq1;
                                    
            ssreview.WeightCS__c = 98;
			ssreview.WeightRenewals__c = 1;
            ssreview.WeightWMCases__c = 2;
            ssreview.WeightWMSMES__c = 0;
            ssreview.WeightWMHC__c = 0;
            ssreview.WeightWMPA__c = 0;
            ssreview.WeightSI__c = 0;
            
            update ssreview;

            
            ssreview.WeightCS__c = 97;
			ssreview.WeightRenewals__c = 1;
            ssreview.WeightWMCases__c = 1;
            ssreview.WeightWMSMES__c = 2;
            ssreview.WeightWMHC__c = 0;
            ssreview.WeightWMPA__c = 0;
            ssreview.WeightSI__c = 0;
            
            update ssreview;

            
            ssreview.WeightCS__c = 96;
			ssreview.WeightRenewals__c = 1;
            ssreview.WeightWMCases__c = 1;
            ssreview.WeightWMSMES__c = 1;
            ssreview.WeightWMHC__c = 2;
            ssreview.WeightWMPA__c = 0;
            ssreview.WeightSI__c = 0;
            
            update ssreview;
            
		} catch (Exception e) {
            System.debug(' ****************** execute_methods_scorecardSupportReviewAfterInsertTwo * ');
            System.debug(e.getMessage());
		}
            
        Test.stopTest();
            
	}
	
	public static testMethod void execute_methods_scorecardSupportReviewAfterInsertThree() 
	{
		
		GenerateEnvironmentTest.genScorecardSupportReviewAfterInsert();
		
		Test.startTest();
		
		try {
			ScorecardSupportReview__c ssreview = GenerateEnvironmentTest.sq1;
			
			ssreview.WeightCS__c = 95;
			ssreview.WeightRenewals__c = 1;
	        ssreview.WeightWMCases__c = 1;
	        ssreview.WeightWMSMES__c = 1;
	        ssreview.WeightWMHC__c = 1;
	        ssreview.WeightWMPA__c = 2;
	        ssreview.WeightSI__c = 0;
	            
	        update ssreview;
	            
	        ssreview.WeightCS__c = 94;
			ssreview.WeightRenewals__c = 1;
	        ssreview.WeightWMCases__c = 1;
	        ssreview.WeightWMSMES__c = 1;
	        ssreview.WeightWMHC__c = 1;
	        ssreview.WeightWMPA__c = 1;
	        ssreview.WeightSI__c = 2;
	            
	        update ssreview;
	
	        ssreview.WeightCS__c = 93;
			ssreview.WeightRenewals__c = 1;
	        ssreview.WeightWMCases__c = 1;
	        ssreview.WeightWMSMES__c = 1;
	        ssreview.WeightWMHC__c = 1;
	        ssreview.WeightWMPA__c = 1;
	        ssreview.WeightSI__c = 0;
	        
	        update ssreview;
        
		} catch (Exception e) {
            System.debug(' ****************** execute_methods_scorecardSupportReviewAfterInsertThree * ');
            System.debug(e.getMessage());
		}
            
        Test.stopTest();
        
	}


	public static testMethod void execute_methods_scorecardSupportReviewAfterInsertFour() {
		/*
		GenerateEnvironmentTest.genScorecardSupportReviewAfterInsert();
		
		Test.startTest();
            
            ScorecardSupportReview__c ssreview = GenerateEnvironmentTest.sq1;
            
            try{
            	if (ssreview.FiscalQuarter__c == 'Q1'){
            		ssreview.FiscalQuarter__c = 'Q2';
            	}
            	if (ssreview.FiscalQuarter__c == 'Q2'){
            		ssreview.FiscalQuarter__c = 'Q1';
            	}
            	if (ssreview.FiscalQuarter__c == 'Q3'){
            		ssreview.FiscalQuarter__c = 'Q4';
            	}
            	if (ssreview.FiscalQuarter__c == 'Q4'){
            		ssreview.FiscalQuarter__c = 'Q3';
            	}

            	update ssreview;
            		
			}catch(DmlException e){
				System.debug(' ***************** Could not update ScorecardSupportReview');
            }finally{
            
            }
          
            try{
            	ScorecardSupportReview__c newssreview = new ScorecardSupportReview__c(  Name = 'New sreview',
            																			FiscalQuarter__c = ssreview.FiscalQuarter__c, 
            																			PerformanceReview__c = ssreview.PerformanceReview__c,
            																			Reviewer__c = ssreview.Reviewer__c
            																			);
            	
            	insert newssreview;
            	
			}catch(DmlException e){
				System.debug(' ***************** Could not insert ScorecardSupportReview');
            }finally{
            
            }
            
            Test.stopTest();
            */
	}

}