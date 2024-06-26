@isTest
private class TestPF_scorecardAfterTrig_Unit {
	
	public static testMethod void execute_methods_scorecardAfterTrig() {
		     
		Test.startTest();
		try {
			
			Scorecard__c scs;
			Scorecard__c sc;
			
			sc = new Scorecard__c(  Name = 'New sc test code coverage',
									Department__c = 'Consulting',
									Type__c = 'Utilization Target',
									EffectiveDate__c = 'FY08',
									AccountablePerson__c = UserInfo.getUserId(),
									Priority__c = 1,
									Rating__c = 1,
									Weight__c = 1
									);
			
			insert sc;
	
			scs = [select s.Id, s.Name, s.Department__c, s.Type__c, s.Description__c from Scorecard__c s 
							where (s.Name = 'New sc test code coverage')
								and (s.Department__c = 'Consulting')
								and (s.Type__c = 'Utilization Target')];
			
			System.debug(' ********************** Id ' + scs.Id + '  ');
			scs.Description__c = 'desc for code coverage';
			
			update scs;
			
			delete scs;
		} catch (Exception e) {
            System.debug(' ****************** execute_methods_scorecardAfterTrig * ');
            System.debug(e.getMessage());
		}

		Test.stopTest();
	
	}	
}