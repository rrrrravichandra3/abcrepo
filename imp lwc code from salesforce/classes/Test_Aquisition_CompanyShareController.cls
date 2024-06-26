@isTest(SeeAllData=false)
public class Test_Aquisition_CompanyShareController {
	public static Account acc;

	public static Id accId{
        get{
            if(accId == null){
             Id accRId = [select Id,name  from RecordType where developerName='Candidate' and SobjectType='Account'].Id;
             acc = new Account(Name='Candidates',recordTypeId=accRId);
            insert acc;
            accId = acc.Id;

          }
          return accId;
      }
   }
	@testSetup static void createTestData() {
		List<PermissionSet> maPermsets = [SELECT Id, Name, Label FROM PermissionSet where Name like 'M_A%'];
        
        UserRole dummyRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];       
        Profile profile = [Select Id from Profile where name = 'System Administrator' Limit 1];   
         User sysAdminUser = new User(
            UserRoleId = dummyRole.Id,
            ProfileId = profile.Id,
            Username = 'testsysadminuser77687@test.com',
            Alias = 'test1',
            Email='test@test1.com',
            EmailEncodingKey='UTF-8',
            Firstname='Sys',
            Lastname='Admin User',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        Database.insert(sysAdminUser);
        
		List<User> users = new List<User>();
		Profile emamployeeProfile = [SELECT Id, Name FROM Profile WHERE Name ='Employee'];
		Map<Id, List<User>> permSetToUsers = new Map<Id, List<User>>();
		List<User> usersToInsert = new List<User>();
		for(PermissionSet pset : maPermsets){
			List<User> usersPset = new List<User>();
			String permsetName = pset.Name.replaceAll('_','');
			if(permsetName == 'MAITProvisioning')permsetName = 'MAITPro';
			if(permsetName == 'MAFinance')permsetName = 'MAFin';

			usersPset.add(new User(LastName = MA_TestUtilityValues.COMPANYSHARE_LASTNAME + permsetName+1, 
									ProfileId= emamployeeProfile.Id, 
									Email= MA_TestUtilityValues.COMPANYSHARE_LASTNAME + permsetName+1,
									Username= MA_TestUtilityValues.COMPANYSHARE_LASTNAME + permsetName+1,
									Alias=permsetName.substring(0,4)+1, emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', TimeZoneSidKey='America/Los_Angeles'));
			usersPset.add(new User(LastName = MA_TestUtilityValues.COMPANYSHARE_LASTNAME+permsetName+2, 
									ProfileId= emamployeeProfile.Id, 
									Email= MA_TestUtilityValues.COMPANYSHARE_LASTNAME + permsetName+2,
									UserName= MA_TestUtilityValues.COMPANYSHARE_LASTNAME + permsetName+2,
									Alias=permsetName.substring(0,4)+2, emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', TimeZoneSidKey='America/Los_Angeles'));

			usersPset.add(new User(LastName = MA_TestUtilityValues.COMPANYSHARE_LASTNAME + permsetName+3, 
									ProfileId= emamployeeProfile.Id, 
									Email= MA_TestUtilityValues.COMPANYSHARE_LASTNAME + permsetName+3,
									UserName= MA_TestUtilityValues.COMPANYSHARE_LASTNAME + permsetName+3,
									Alias=permsetName.substring(0,4)+3, emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', TimeZoneSidKey='America/Los_Angeles'));

			usersPset.add(new User(LastName = MA_TestUtilityValues.COMPANYSHARE_LASTNAME + permsetName+4, 
									ProfileId= emamployeeProfile.Id, 
									Email= MA_TestUtilityValues.COMPANYSHARE_LASTNAME + permsetName+4,
									UserName= MA_TestUtilityValues.COMPANYSHARE_LASTNAME + permsetName+4,
									Alias=permsetName.substring(0,4)+4, emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', TimeZoneSidKey='America/Los_Angeles'));

			usersPset.add(new User(LastName = MA_TestUtilityValues.COMPANYSHARE_LASTNAME + permsetName+5, 
									ProfileId= emamployeeProfile.Id, 
									Email= MA_TestUtilityValues.COMPANYSHARE_LASTNAME + permsetName+5,
									UserName= MA_TestUtilityValues.COMPANYSHARE_LASTNAME + permsetName+5,
									Alias=permsetName.substring(0,4)+5, emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', TimeZoneSidKey='America/Los_Angeles'));

			permSetToUsers.put(pset.Id, usersPset);
			usersToInsert.addAll(usersPset);
		}
            insert usersToInsert;
		List<PermissionSetAssignment> psAssignment = new List<PermissionSetAssignment>();
		for(Id pid: permSetToUsers.keySet()){
			for(User usr: permSetToUsers.get(pid)){
				psAssignment.add(new PermissionSetAssignment(AssigneeId=usr.Id, PermissionSetId=pid));
			}
		}
		insert psAssignment;
		System.runAs(sysAdminUser){
			PF_MA_Settings__c pfsetting = new PF_MA_Settings__c(MA_AcquisitionCompensationShare_Size__c = 9000);
			insert pfsetting;
		}


	} 	

	@isTest
	static void testSendEmail() {

		User maESUser = [SELECT Id, Name, Email FROM User WHERE Name LIKE :MA_TestUtilityValues.COMPANYSHARE_LASTNAME + 'MAES1'];
		System.runAs(maESUser){
			Contact cntact = new Contact(FirstName='Test', LastName='Contact', Email= MA_TestUtilityValues.COMPANYSHARE_LASTNAME + 'MAES1' );
        	insert cntact;
			Acquisition_Company__c comp = new Acquisition_Company__c(Name='Testing Script', Status__c='Pre-Diligence');
			insert comp;
			List<Acquisition_Contacts__c > cnts = new List<Acquisition_Contacts__c >();
			for(Integer idx= 0 ; idx < 1000; idx++){
			    cnts.add( new Acquisition_Contacts__c (Name = MA_TestUtilityValues.ACQUISITION_CONTACT_NAME + idx, Acquisition_Company__c=comp.Id, Employee_ID_Target__c = '123456',Email_Address_Target__c ='Testclass'+String.valueOf(idx)+'@test.com'));
			}
			insert cnts;
			//Owner should get access to the record
			List<Acquisition_Company__Share> acq = [SELECT Id, UserORGroupId, UserORGroup.Name, ParentId FROM Acquisition_Company__Share where ParentId =: comp.Id];
			System.assertEquals(acq[0].UserORGroupId, maESUser.Id, 'Owner Should get access to the company record : ' +acq +'  '+ acq[0].UserORGroup.Name);

			Test.startTest();
			ApexPages.StandardController stdController = new ApexPages.StandardController(comp);
			Aquisition_CompanyShareController acquisitionCtrl = new Aquisition_CompanyShareController(stdController);

			System.assertEquals(1, acquisitionCtrl.alreadySharedWith.size(), 'Only user should be in the list');

			System.assertEquals(true, acquisitionCtrl.canUserShareCompany, 'This user should be able to share the company record');

			
			set<id> uniqueUserIds = new set<id>();
			List<PermissionSetAssignment> userPermSetAssignments = [SELECT Id, AssigneeId, Assignee.Name, PermissionSetId 
																	FROM PermissionSetAssignment 
																	WHERE Assignee.IsActive = true 
																	AND PermissionSetId IN :  acquisitionCtrl.maPremSets.values()];
														
			//Grab the unique users.Org has users who are assigned to multiple M&A perm sets
			for( PermissionSetAssignment permSetAssign:userPermSetAssignments){
				uniqueUserIds.add(permSetAssign.AssigneeId);
			}
			System.assertEquals(acquisitionCtrl.availableUsersOptions.size(), uniqueUserIds.size() -1, 'All users except owner should be available to select.');
			System.assertEquals(true, acquisitionCtrl.showSharingWarning, 'Warning message should be shown as Company is in "Pre-Diligence".');
			
			Aquisition_CompanyShareController.sendEmail(uniqueUserIds,comp.Id);
			Test.stopTest();
        }
		
	}

    @isTest
	static void deleteSharing() {
		
		//The below custom setting setup can be removed after talentforce is deprecated.
		//If the below is not added Talentforce trigger contactupdates fails on contact insert.
	

		User maESUser = [SELECT Id, Name, Email FROM User WHERE Name LIKE :MA_TestUtilityValues.COMPANYSHARE_LASTNAME + 'MAES1'];
		System.runAs(maESUser){
			Contact cntact = new Contact(FirstName='Test', LastName='Contact', Email= MA_TestUtilityValues.COMPANYSHARE_LASTNAME + 'MAES1' );
        	insert cntact;
			Acquisition_Company__c comp = new Acquisition_Company__c(Name='Testing Script', Status__c='Pre-Diligence');
			insert comp;
			List<Acquisition_Contacts__c > cnts = new List<Acquisition_Contacts__c >();
			for(Integer idx= 0 ; idx < 100; idx++){
			    cnts.add( new Acquisition_Contacts__c (Name= MA_TestUtilityValues.ACQUISITION_CONTACT_NAME + idx, Acquisition_Company__c=comp.Id, Employee_ID_Target__c = '123456',Email_Address_Target__c ='Testclass'+String.valueOf(idx)+'@test.com'));
			}
			insert cnts;
			//Owner should get access to the record
			List<Acquisition_Company__Share> acq = [SELECT Id, UserORGroupId, UserORGroup.Name, ParentId FROM Acquisition_Company__Share where ParentId =: comp.Id];
			System.assertEquals(acq[0].UserORGroupId, maESUser.Id, 'Owner Should get access to the company record : ' +acq +'  '+ acq[0].UserORGroup.Name);

			Test.startTest();
			ApexPages.StandardController stdController = new ApexPages.StandardController(comp);
			Aquisition_CompanyShareController acquisitionCtrl = new Aquisition_CompanyShareController(stdController);

			System.assertEquals(1, acquisitionCtrl.alreadySharedWith.size(), 'Only user should be in the list');

			System.assertEquals(true, acquisitionCtrl.canUserShareCompany, 'This user should be able to share the company record');

			

			set<id> uniqueUserIds = new set<id>();
			List<PermissionSetAssignment> userPermSetAssignments = [SELECT Id, AssigneeId, Assignee.Name, PermissionSetId 
																	FROM PermissionSetAssignment 
																	WHERE Assignee.IsActive = true 
																	AND PermissionSetId IN :  acquisitionCtrl.maPremSets.values()];
														
			//Grab the unique users.Org has users who are assigned to multiple M&A perm sets
			for( PermissionSetAssignment permSetAssign:userPermSetAssignments){
				uniqueUserIds.add(permSetAssign.AssigneeId);
			}
			System.assertEquals(acquisitionCtrl.availableUsersOptions.size(), uniqueUserIds.size() -1, 'All users except owner should be available to select.');
			System.assertEquals(true, acquisitionCtrl.showSharingWarning, 'Warning message should be shown as Company is in "Pre-Diligence".');

			acquisitionCtrl.searchString = 'Test_Aquisition_CompanyShareController';
			acquisitionCtrl.searchUsers();
			
			List<PermissionSetAssignment> permAssignments = [SELECT AssigneeId, Assignee.Name, Assignee.Email, Id, PermissionSetId, PermissionSet.Name FROM PermissionSetAssignment 
										WHERE Assignee.IsActive = true AND PermissionSetId IN :  acquisitionCtrl.maPremSets.values()
												AND Assignee.Name LIKE '%test_aquisition_companysharecontroller%'];
			System.assertEquals(permAssignments.size() -1, acquisitionCtrl.availableUsersOptions.size(), acquisitionCtrl.availableUsersOptions);
			acquisitionCtrl.selectedUsersOptions =acquisitionCtrl.availableUsersOptions;
			acquisitionCtrl.createSharing();
			
			acquisitionCtrl.returnToCompanyDetails();
			
			User esUser = [SELECT Id, Name from User WHERE LastName = :MA_TestUtilityValues.COMPANYSHARE_LASTNAME + 'MAES2' limit 1];
			User itUser = [SELECT Id, Name from User WHERE LastName = :MA_TestUtilityValues.COMPANYSHARE_LASTNAME + 'MAIT2' limit 1];
			User finUser = [SELECT Id, Name from User WHERE LastName = :MA_TestUtilityValues.COMPANYSHARE_LASTNAME + 'MAFin2' limit 1];
			User itProvisiningUser = [SELECT Id, Name from User WHERE LastName = :MA_TestUtilityValues.COMPANYSHARE_LASTNAME + 'MAITPro2' limit 1];
			User rewsuser = [SELECT Id, Name from User WHERE LastName = :MA_TestUtilityValues.COMPANYSHARE_LASTNAME + 'MAREWS2' limit 1];

			List<Acquisition_Company__Share> companySharing = [SELECT UserORGroupId, ParentId FROM Acquisition_Company__Share where UserORGroupId in (:esUser.Id, :itUser.Id, :finUser.Id, :itProvisiningUser.Id, :rewsuser.Id)];
			acquisitionCtrl.deleteShareUserId = finUser.Id;
			acquisitionCtrl.deleteShae();
            System.assertEquals(0, [SELECT Id from Acquisition_Compensation__Share where UserORGroupId =:finUser.Id].size());
			
			Test.stopTest();
		}
	}

	@isTest
	 static void whoCanShare() {

		
		//The below custom setting setup can be removed after talentforce is deprecated.
		//If the below is not added Talentforce trigger contactupdates fails on contact insert.
		List<sObject> Ts2Setting = Test.loadData(TF2Settings__c.sObjectType, 'Ts2SettingsTest');
        TF2Settings__c ts = [select Employee_Account__c,Recruiting_Account_Id__c from TF2Settings__c limit 1];
		ts.Employee_Account__c = accId;
		ts.Recruiting_Account_Id__c = accId;
		update ts;
        

        ts2__Config__c config = new ts2__Config__c();
        config.Name='Config1';
        config.ts2__ResumeParserEndpointBatch__c = 'https://f.jobscience.com/resumeviewerservice/service.asmx';
        config.ts2__SearchCollectionName__c = '00DS0000003Knwm'; 
        insert config; 

        ts2__Source__c source= new ts2__Source__c(Name='Recruiter Sourced');
        insert source;




		User esUser1 = [SELECT Id, Name, Email FROM User WHERE LastName LIKE :MA_TestUtilityValues.COMPANYSHARE_LASTNAME + 'MAES1'];
		User finUser = [SELECT Id, Name, Email FROM User WHERE LastName LIKE :MA_TestUtilityValues.COMPANYSHARE_LASTNAME + 'MAFin2'];
		User esUser = [SELECT Id, Name, Email FROM User WHERE LastName LIKE :MA_TestUtilityValues.COMPANYSHARE_LASTNAME + 'MAES2'];
		User itUser = [SELECT Id, Name, Email FROM User WHERE LastName LIKE :MA_TestUtilityValues.COMPANYSHARE_LASTNAME + 'MAIT2'];
		User provUser = [SELECT Id, Name, Email FROM User WHERE LastName LIKE :MA_TestUtilityValues.COMPANYSHARE_LASTNAME + 'MAITPro2'];
		User rewsUser = [SELECT Id, Name, Email FROM User WHERE LastName LIKE :MA_TestUtilityValues.COMPANYSHARE_LASTNAME + 'MAREWS2'];

		Acquisition_Company__c comp = new Acquisition_Company__c(Name='Testing Script', Status__c='Pre-Diligence');
		System.runAs(esUser1){
			Contact cntact = new Contact(FirstName='Test', LastName='Contact', Email= MA_TestUtilityValues.COMPANYSHARE_LASTNAME + 'MAES1' );
        	insert cntact;
			insert comp;
			List<Acquisition_Contacts__c > cnts = new List<Acquisition_Contacts__c >();
			for(Integer idx= 0 ; idx < 100; idx++){
			    cnts.add( new Acquisition_Contacts__c (Name= MA_TestUtilityValues.ACQUISITION_CONTACT_NAME + idx, Acquisition_Company__c=comp.Id, Employee_ID_Target__c='123456',Email_Address_Target__c ='Testclass'+String.valueOf(idx)+'@test.com'));
			}
			insert cnts;
			List<Acquisition_Company__Share> companyShares = new List<Acquisition_Company__Share>();
			companyShares.add(new Acquisition_Company__Share(ParentId=comp.Id, RowCause='Manual', AccessLevel='Edit', UserORGroupId=finUser.Id));
			companyShares.add(new Acquisition_Company__Share(ParentId=comp.Id, RowCause='Manual', AccessLevel='Edit', UserORGroupId=esUser.Id));
			companyShares.add(new Acquisition_Company__Share(ParentId=comp.Id, RowCause='Manual', AccessLevel='Edit', UserORGroupId=itUser.Id));
			companyShares.add(new Acquisition_Company__Share(ParentId=comp.Id, RowCause='Manual', AccessLevel='Edit', UserORGroupId=provUser.Id));
			companyShares.add(new Acquisition_Company__Share(ParentId=comp.Id, RowCause='Manual', AccessLevel='Edit', UserORGroupId=rewsUser.Id));
			insert companyShares;
		}
		
		System.runAs(finUser){
			ApexPages.StandardController stdController = new ApexPages.StandardController(comp);
			Aquisition_CompanyShareController acquisitionCtrl = new Aquisition_CompanyShareController(stdController);
			System.assertEquals(false, acquisitionCtrl.canUserShareCompany, 'Finance user should not be able to share');
		}

		System.runAs(esUser){
			ApexPages.StandardController stdController = new ApexPages.StandardController(comp);
			Aquisition_CompanyShareController acquisitionCtrl = new Aquisition_CompanyShareController(stdController);
			System.assertEquals(true, acquisitionCtrl.canUserShareCompany, 'ES User user should not be able to share');
		}

		System.runAs(itUser){
			ApexPages.StandardController stdController = new ApexPages.StandardController(comp);
			Aquisition_CompanyShareController acquisitionCtrl = new Aquisition_CompanyShareController(stdController);
			System.assertEquals(false, acquisitionCtrl.canUserShareCompany, 'MA IT user should not be able to share');
		}
		
		System.runAs(provUser){
			ApexPages.StandardController stdController = new ApexPages.StandardController(comp);
			Aquisition_CompanyShareController acquisitionCtrl = new Aquisition_CompanyShareController(stdController);
			System.assertEquals(false, acquisitionCtrl.canUserShareCompany, 'MAIT Provisioning user should not be able to share');
		}
		
		System.runAs(rewsUser){
			ApexPages.StandardController stdController = new ApexPages.StandardController(comp);
			Aquisition_CompanyShareController acquisitionCtrl = new Aquisition_CompanyShareController(stdController);
			System.assertEquals(false, acquisitionCtrl.canUserShareCompany, 'MA REWS user should not be able to share');
		}
	}
}