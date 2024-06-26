@isTest
public with sharing class Test_ESDJC_CaseTierMapping {
	
	static testMethod void testEscalateCaseCreatedFromPortal() {
		User sysAdm = ESDJC_TestUtil.getSysAdminUser();
		
		User portalUser = null;
		System.runAs(sysAdm) {
			init();
			
			portalUser = ESDJC_TestUtil.getPortalUser('US', 'Americas - USA');
			
			String caseId = null;
			
			Test.startTest();
			// insert case as portal user
			System.runAs(portalUser) {
				Case c = new Case(ContactId=portalUser.ContactId, Subject='Test Private Question', Type='Benefits', Description='Test Description', Status='New', Origin='Chatter Answers', Tier__c='Tier 1');
				//Set dml options to use assignment rules
				Database.DMLOptions dmo = new Database.DMLOptions();
				dmo.assignmentRuleHeader.useDefaultRule= true;
				c.setOptions(dmo);
				insert c;
				caseId = c.Id;
			}
			
			System.assert(caseId != null);
			
			//Get inserted cases 
			Case refreshedCase = [select OwnerId, Tier__c from Case where Id=:caseId];
			
			//Assert tier - default tier is tier 1
			System.assertEquals('Tier 1', refreshedCase.Tier__c);
			
			//Verify owner is a queue
			System.assert(refreshedCase.OwnerId != null);
			System.assert(((String)refreshedCase.OwnerId).startsWith('00G'));
			
			String oldOwnerId = refreshedCase.OwnerId;
			
			//Escalate Benefits case
			refreshedCase.Tier__c = 'Tier 2';
			update refreshedCase;
			
			//Refresh the case again
			refreshedCase = [select OwnerId, Tier__c from Case where Id=:caseId];
			
			//Assert new owner is not same as old owner and tier is updated to tier2
			System.assertEquals('Tier 2', refreshedCase.Tier__c);
			System.assert(refreshedCase.OwnerId != oldOwnerId);
			
			Test.stopTest();
		}
	}
	
	static testMethod void testTierChangeOnOwnerChange() {
		User sysAdm = ESDJC_TestUtil.getSysAdminUser();
		
		User portalUser = null;
		User esUser = null;
		
		System.runAs(sysAdm) {
			init();
			
			portalUser = ESDJC_TestUtil.getPortalUser('US', 'Americas - USA');
			
			//create ES user
			esUser = ESDJC_TestUtil.createStandardUser('Employee Success Representative', 'ES Benefits Manager Amer', 'US', 'Americas - USA');
			ESDJC_TestUtil.assignPermission(esUser.Id, 'ES_DJC_Specialist');
			
			//Assert es user role
			System.assertEquals('ES Benefits Manager Amer', [select UserRole.Name from User where Id=:esUser.Id].UserRole.Name);
			
			String caseId = null;
			
			Test.startTest();
			
			// insert case as portal user
			System.runAs(portalUser) {
				Case c = new Case(ContactId=portalUser.ContactId, Subject='Test Private Question', Type='Benefits', Description='Test Description', Status='New', Origin='Chatter Answers', Tier__c='Tier 1');
				//Set dml options to use assignment rules
				Database.DMLOptions dmo = new Database.DMLOptions();
				dmo.assignmentRuleHeader.useDefaultRule= true;
				c.setOptions(dmo);
				insert c;
				caseId = c.Id;
			}
			
			//Assert case tier
			Case refreshedCase = [select OwnerId, Tier__c, Status, ES_DJC_Case_Escalated_By__c from Case where Id=:caseId];
			
			System.assertEquals('Tier 1', refreshedCase.Tier__c);
			
			//Verify owner is a queue
			System.assert(refreshedCase.OwnerId != null);
			System.assert(((String)refreshedCase.OwnerId).startsWith('00G'));
			
			//Assert if case status is New
			System.assertEquals('New', refreshedCase.Status);
			
			System.assert(refreshedCase.ES_DJC_Case_Escalated_By__c == null);
			
			//Change owner to es user
			refreshedCase.OwnerId = esUser.Id;
			
			//update case
			update refreshedCase;
			
			//Refresh case again
			refreshedCase = [select OwnerId, Tier__c, Status, ES_DJC_Case_Escalated_By__c from Case where Id=:caseId];
			
			//Assert new owner is es user
			System.assertEquals(esUser.Id, refreshedCase.OwnerId);
			
			//Assert case tier
			System.assertEquals('Tier 2', refreshedCase.Tier__c);
			
			//Assert if case status is Escalated
			System.assertEquals('Escalated', refreshedCase.Status);
			
			//Assert Case Escalated By is not null
			System.assert(refreshedCase.ES_DJC_Case_Escalated_By__c != null);
			
			Test.stopTest();
		}
	}
	
	static testMethod void testReassignToUserWithSameTier() {
		User sysAdm = ESDJC_TestUtil.getSysAdminUser();
		
		User portalUser = null;
		User esUser = null;
		
		System.runAs(sysAdm) {
			init();
			
			portalUser = ESDJC_TestUtil.getPortalUser('US', 'Americas - USA');
			
			//create ES user
			esUser = ESDJC_TestUtil.createStandardUser('Employee Success Representative', 'ES Specialist Manager Amer', 'US', 'Americas - USA');
			ESDJC_TestUtil.assignPermission(esUser.Id, 'ES_DJC_Specialist');
			
			//Assert es user role
			System.assertEquals('ES Specialist Manager Amer', [select UserRole.Name from User where Id=:esUser.Id].UserRole.Name);
			
			String caseId = null;
			
			Test.startTest();
			
			// insert case as portal user
			System.runAs(portalUser) {
				Case c = new Case(ContactId=portalUser.ContactId, Subject='Test Private Question', Type='Benefits', Description='Test Description', Status='New', Origin='Chatter Answers', Tier__c='Tier 1');
				//Set dml options to use assignment rules
				Database.DMLOptions dmo = new Database.DMLOptions();
				dmo.assignmentRuleHeader.useDefaultRule= true;
				c.setOptions(dmo);
				insert c;
				caseId = c.Id;
			}
			
			//Assert case tier
			Case refreshedCase = [select OwnerId, Tier__c, Status, ES_DJC_Case_Escalated_By__c from Case where Id=:caseId];
			
			System.assertEquals('Tier 1', refreshedCase.Tier__c);
			
			//Verify owner is a queue
			System.assert(refreshedCase.OwnerId != null);
			System.assert(((String)refreshedCase.OwnerId).startsWith('00G'));
			
			//Assert if case status is New
			System.assertEquals('New', refreshedCase.Status);
			
			System.assert(refreshedCase.ES_DJC_Case_Escalated_By__c == null);
			
			//Change owner to es user
			refreshedCase.OwnerId = esUser.Id;
			
			//update case
			update refreshedCase;
			
			//Refresh case again
			refreshedCase = [select OwnerId, Tier__c, Status, ES_DJC_Case_Escalated_By__c from Case where Id=:caseId];
			
			//Assert new owner is es user
			System.assertEquals(esUser.Id, refreshedCase.OwnerId);
			
			//Assert case tier - Case Tier will remain same
			System.assertEquals('Tier 1', refreshedCase.Tier__c);
			
			//Assert if case status is still New. Reassigning across same tier is not escalation
			System.assertEquals('New', refreshedCase.Status);
			
			//Assert Case Escalated By is still null
			System.assert(refreshedCase.ES_DJC_Case_Escalated_By__c == null);
			
			Test.stopTest();
		}
	}
	
	static testMethod void testReassignToUserInALesserTier() {
		User sysAdm = ESDJC_TestUtil.getSysAdminUser();
		
		User portalUser = null;
		User esUser1 = null;
		User esUser2 = null;
		
		System.runAs(sysAdm) {
			init();
			
			portalUser = ESDJC_TestUtil.getPortalUser('US', 'Americas - USA');
			
			//create ES user
			esUser1 = ESDJC_TestUtil.createStandardUser('Employee Success Representative', 'ES Specialist Manager Amer', 'US', 'Americas - USA', '1');
			ESDJC_TestUtil.assignPermission(esUser1.Id, 'ES_DJC_Specialist');
			
			//Assert es user1 role
			System.assertEquals('ES Specialist Manager Amer', [select UserRole.Name from User where Id=:esUser1.Id].UserRole.Name);
			
			esUser2 = ESDJC_TestUtil.createStandardUser('Employee Success Representative', 'ES Benefits Manager Amer', 'US', 'Americas - USA', '2');
			ESDJC_TestUtil.assignPermission(esUser2.Id, 'ES_DJC_Specialist');
			
			//Assert es user2 role
			System.assertEquals('ES Benefits Manager Amer', [select UserRole.Name from User where Id=:esUser2.Id].UserRole.Name);

			String caseId = null;
			
			Test.startTest();
			
			// insert case as portal user
			System.runAs(portalUser) {
				Case c = new Case(ContactId=portalUser.ContactId, Subject='Test Private Question', Type='Benefits', Description='Test Description', Status='New', Origin='Chatter Answers', Tier__c='Tier 1');
				//Set dml options to use assignment rules
				Database.DMLOptions dmo = new Database.DMLOptions();
				dmo.assignmentRuleHeader.useDefaultRule= true;
				c.setOptions(dmo);
				insert c;
				caseId = c.Id;
			}
			
			//Assert case tier
			Case refreshedCase = [select OwnerId, Tier__c, Status, ES_DJC_Case_Escalated_By__c from Case where Id=:caseId];
			
			System.assertEquals('Tier 1', refreshedCase.Tier__c);
			
			//Verify owner is a queue
			System.assert(refreshedCase.OwnerId != null);
			System.assert(((String)refreshedCase.OwnerId).startsWith('00G'));
			
			//Assert if case status is New
			System.assertEquals('New', refreshedCase.Status);
			
			System.assert(refreshedCase.ES_DJC_Case_Escalated_By__c == null);
			
			//Change owner to es user with a higher tier
			refreshedCase.OwnerId = esUser2.Id;
			
			//update case
			update refreshedCase;
			
			//Refresh case again
			refreshedCase = [select OwnerId, Tier__c, Status, ES_DJC_Case_Escalated_By__c from Case where Id=:caseId];
			
			//Assert new owner is es user2
			System.assertEquals(esUser2.Id, refreshedCase.OwnerId);
			
			//Assert case tier 
			System.assertEquals('Tier 2', refreshedCase.Tier__c);
			
			//Assert if case status is Escalated as case is reassigned to a higher tier owner
			System.assertEquals('Escalated', refreshedCase.Status);
			
			//Assert Case Escalated By is not null
			System.assert(refreshedCase.ES_DJC_Case_Escalated_By__c != null);
			
			//update case status to In Progress
			refreshedCase.Status = 'In Progress';
			update refreshedCase;
			
			//Assert refreshed case status
			refreshedCase = [select OwnerId, Tier__c, Status, ES_DJC_Case_Escalated_By__c from Case where Id=:caseId];
			
			System.assertEquals('In Progress', refreshedCase.Status);
			
			//Assert other fields
			System.assertEquals('Tier 2', refreshedCase.Tier__c);
			System.assertEquals(esUser2.Id, refreshedCase.OwnerId);
			
			//Update case owner to esuser1 (user with a lesser tier - tier 1)
			refreshedCase.OwnerId = esUser1.Id;
			update refreshedCase;
			
			//Refresh case. Case status should remain In Progress and Tier should be Tier 1
			refreshedCase = [select OwnerId, Tier__c, Status, ES_DJC_Case_Escalated_By__c from Case where Id=:caseId];
			
			System.assertEquals(esUser1.Id, refreshedCase.OwnerId);
			System.assertEquals('Tier 1', refreshedCase.Tier__c);
			System.assertEquals('In Progress', refreshedCase.Status);
			
			Test.stopTest();
		}
	}
	
	static testMethod void testCaseCreationByOwnerInAHigherTier() {
		User sysAdm = ESDJC_TestUtil.getSysAdminUser();
		
		User esUser = null;
		
		System.runAs(sysAdm) {
			init();
			
			//create ES user
			esUser = ESDJC_TestUtil.createStandardUser('Employee Success Representative', 'ES Benefits Manager Amer', 'US', 'Americas - USA');
			ESDJC_TestUtil.assignPermission(esUser.Id, 'ES_DJC_Specialist');
			
			//Assert es user role
			System.assertEquals('ES Benefits Manager Amer', [select UserRole.Name from User where Id=:esUser.Id].UserRole.Name);

			String caseId = null;
			
			Test.startTest();
			
			System.runAs(esUser) {
				ID ProfileID = [ Select id from Profile where name = 'Customer Portal Manager Custom'].id;
		        Account A1 = new Account(Name = 'Test Account');
		        insert A1;
		        
		        Contact C1 = new Contact( AccountID = A1.id, FirstName = 'Test', LastName = 'User',ES_DJC_Contact_Country__c = 'US', Division__c = 'Americas - USA',
		        email = 'test-user@fakemail.com',RecordTypeId=[select id,name from RecordType where sObjectType='Contact' and Name='Employee'].Id );
		        insert C1;
				Case c = new Case(ContactId=C1.Id, Subject='Test Private Question', Type='Benefits', Description='Test Description', Status='New', Origin='Chatter Answers', Tier__c='Tier 1');
				insert c;
				caseId = c.Id;
			}
			
			//Refresh case
			Case refreshedCase = [select Tier__c, OwnerId, Status from Case where Id=:caseId];
			
			//Assert case fields
			System.assertEquals(esUser.Id, refreshedCase.OwnerId);
			System.assertEquals('Tier 2', refreshedCase.Tier__c);
			System.assertEquals('New', refreshedCase.Status);
			
			Test.stopTest();
		}
	}
	
	private static void init(){
		ESDJC_Settings__c setting = new ESDJC_Settings__c();
		setting.Run_trigger__c = true;
		setting.Site_URL__c = '/site/url';
		setting.Portal_User_Profile_Id__c = '00e70000000xEB1';
		setting.Concierge_API_User_Profile_Id__c = '00en0000000HgEa';
		setting.djc_Helpdesk_API_User__c = '00570000002SpX4AAK';
		insert setting;
		REWS_Setting__c rewsSetting = new REWS_Setting__c();
		rewsSetting.Mail_services_queue_Id__c = '00Gn0000000JH8YEAW';
		rewsSetting.Case_Package_Delivery_Record_Type__c = '00Gn0000000JH8YEAW';
		insert  rewsSetting;
	}
}