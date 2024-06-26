@isTest
private class Test_V2MOMSharingController {

	
	public static testMethod void execute_methods_V2MOMSharingController() {
		GenerateEnvironmentTest3.genScorecardMetricEducation();
		   
		Test.startTest();
		try {
			Test.setCurrentPageReference(new PageReference('Page.V2MOMEdit'));
			  
		 	
			List<V2MOM__c> v2momList = new List<V2MOM__c>{GenerateEnvironmentTest3.v2momIndividualQ1Q2Sup};
			List<User> users = new List<User>{	GenerateEnvironmentTest3.pcommStandard ,
												GenerateEnvironmentTest3.esadminStandard ,
												GenerateEnvironmentTest3.ceoStandard ,
												GenerateEnvironmentTest3.esbpStandard ,
												GenerateEnvironmentTest3.employeeStandard }; 
			
			if (v2momList.size() > 0 ) 
			{
				
				V2MOMSharingController controller = new V2MOMSharingController();
				
				System.currentPageReference().getParameters().put('id', v2momList[0].Id );
				String usersToAdd = '';
				Boolean firstTime = true;
				for (User u : users)
				{
					if (firstTime)
					{
						usersToAdd = u.Name + '-' + u.Id;
						firstTime = false;	
					}
					else
					{
						usersToAdd = usersToAdd + ';' +  u.Name + '-' + u.Id;
					}
					
				}
				
				System.debug('Theusertoadd ' + usersToAdd);
				
				controller.setV2momId( v2momList[0].Id );
				controller.getV2momId();
				controller.getv2momObject();
				
				controller.getUsers();
				
				
				
				controller.setUserToAdd('');
				
				controller.getUserToAdd();
				controller.getCurrentSearchTerm();
				controller.setCurrentSearchTerm('Mario');
				controller.SearchForUsers();
				
				
				
				controller.setUsersToAdd(usersToAdd);
				controller.getV2momShare();
				
				controller.getUsersToAdd();
				controller.getReadOnlyAccess();
				controller.setReadOnlyAccess(true);
				
				
				controller.AddUserToShare();
				
				
				controller.AddUserToShare();
				controller.IsUserObject(UserInfo.getUserId());
				
				controller.SaveShareWith();
				
				controller.setV2momShare('share');
				
				V2MOM__c newV2MOM = new V2MOM__c();
				newV2MOM.Share_With__c = 'My Management Hierarchy';
				
				controller.setv2momObject(new V2MOM__c());
				controller.getUser();
				
			}
		} catch (Exception e) {
            System.debug(' ****************** execute_methods_V2MOMSharingController * ');
            System.debug(e.getMessage());
		}
		
		Test.stopTest();
		
	}
}