@isTest(SeeAllData= false)
private class Test_Acquisition_Compensation_Trigger {
	@testSetup static void createTestUsers() {
		PermissionSet finPermset = [SELECT Id, Name, Label FROM PermissionSet where Name like 'M_A_Fin%'];
		Profile emamployeeProfile = [SELECT Id, Name FROM Profile WHERE Name ='Employee'];

		User FINUser = new User(LastName ='M&AFINTest', 
									ProfileId= emamployeeProfile.Id, 
									Email='Test_Aquisition_CompensationShare@salesfore.com',
									Username='Test_Aquisition_CompensationShare@salesfore.com',
									Alias='AFINTest', emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', TimeZoneSidKey='America/Los_Angeles');
		insert FINUser;
        System.runAs(FINUser){
            PermissionSetAssignment permAssign = new PermissionSetAssignment(AssigneeId=FINUser.Id, PermissionSetId=finPermset.id);
		insert permAssign;
        }
		


	}
	// Single Record actions
	@isTest static void testSuccessfulCompensationUpdate() {

		User FINUser = [select id from user where lastname = 'M&AFINTest'];
		Acquisition_Company__c company = new Acquisition_Company__c(Name='Test Company');
		insert company;
		System.assertNotEquals(null, company.Id, 'Company creation failed.');

		//Share company with FIN user
		Acquisition_Company__Share companyShare = new Acquisition_Company__Share(ParentId = company.Id, UserOrGroupId=FINUser.id, AccessLevel='Edit', RowCause='Can_Share__c');
		insert companyShare;

		Acquisition_Contacts__c aContact = new Acquisition_Contacts__c(Acquisition_Company__c = company.Id, Name='Contact Legal Name', Employee_ID_Target__c='ef34567');
		insert aContact;
		System.assertNotEquals(null, aContact.Id, 'Contact creation failed.');
		List<Acquisition_Provisioning__c> autoCreatedProvisions = [SELECT Id, Name, Acquisition_Contact__c, Offer_Status__c 
																	FROM Acquisition_Provisioning__c WHERE Acquisition_Contact__c =: aContact.Id];
		System.assertEquals(1, autoCreatedProvisions.size(), 'There should be one Provisioning record.');

		List<Acquisition_Compensation__c> autoCreatedCompenesations = [SELECT Id, Name, Acquisition_Contact__c, Status__c FROM Acquisition_Compensation__c WHERE Acquisition_Contact__c =: aContact.Id];
		System.assertEquals(1, autoCreatedCompenesations.size(), 'There should be one Compensation record.');
		List<Acquisition_Compensation__Share> compensationShareRecs  = [select parentid from Acquisition_Compensation__Share where parentid= :autoCreatedCompenesations[0].id];
		System.assertEquals(2, compensationShareRecs.size(),'Expecting compensation to be shared to two users - the owner and FIN user');


		System.assertEquals(autoCreatedProvisions[0].Offer_Status__c, autoCreatedCompenesations[0].Status__c, 'Compensation Status and Provisioning offer status should match.');
		

		autoCreatedCompenesations[0].Status__c= 'Pre-Approval';
		update autoCreatedCompenesations;
		List<Acquisition_Provisioning__c> autoCreatedProvisionsAfterUpdate = [SELECT Id, Name, Acquisition_Contact__c, Offer_Status__c 
																	FROM Acquisition_Provisioning__c WHERE Acquisition_Contact__c =: aContact.Id];
		System.assertEquals(autoCreatedProvisionsAfterUpdate[0].Offer_Status__c, autoCreatedCompenesations[0].Status__c, 'Compensation Status and Provisioning offer status should match.');
	}
	
	//Bulk Records actions
	@isTest static void testBulkCompensationUpdate() {
		User FINUser = [select id from user where lastname = 'M&AFINTest'];

		Acquisition_Company__c company = new Acquisition_Company__c(Name='Test Company');
		insert company;
		System.assertNotEquals(null, company.Id, 'Company creation failed.');


		//Share company with FIN user
		Acquisition_Company__Share companyShare = new Acquisition_Company__Share(ParentId = company.Id, UserOrGroupId=FINUser.id, AccessLevel='Edit', RowCause='Can_Share__c');
		insert companyShare;

		List<Acquisition_Contacts__c> aContacts200 = new List<Acquisition_Contacts__c>();
		for(Integer idx = 0; idx < 200; idx++){
			aContacts200.add(new Acquisition_Contacts__c(Acquisition_Company__c = company.Id, Name='Contact Legal Name'+ idx, Employee_ID_Target__c='fs23456'));
		}
		insert aContacts200;
		List<Acquisition_Provisioning__c> autoCreatedProvisions = [SELECT Id, Name, Acquisition_Contact__c, Offer_Status__c 
																	FROM Acquisition_Provisioning__c];
		System.assertEquals(200, autoCreatedProvisions.size(), 'There should be one Provisioning record.');

		List<Acquisition_Compensation__c> autoCreatedCompenesations = [SELECT Id, Name, Acquisition_Contact__c, Status__c FROM Acquisition_Compensation__c];
		System.assertEquals(200, autoCreatedCompenesations.size(), 'There should be one Compensation record.');

		List<Acquisition_Compensation__Share> compensationShareRecs  = [select parentid from Acquisition_Compensation__Share where parentid in :autoCreatedCompenesations];
		System.assertEquals(400, compensationShareRecs.size(),'Expecting compensation to be shared to two users - the owner and FIN user');

		for(Integer idx = 0; idx < 190; idx++){
			autoCreatedCompenesations[idx].Status__c= 'Pre-Approval';
		}
		update autoCreatedCompenesations;
		
		List<Acquisition_Contacts__c> queriedContacts = [SELECT Id, Name, (SELECT Id, Name, Offer_Status__c from Acquisition_Provisioning__r), 
															(SELECT Id, Name, Status__c from Acquisition_Compensation__r) from Acquisition_Contacts__c];

		for(Acquisition_Contacts__c aContact : queriedContacts){
			System.assertEquals(1, aContact.Acquisition_Provisioning__r.size(), 'Each Contact should have one provision.');
			System.assertEquals(1, aContact.Acquisition_Compensation__r.size(), 'Each Contact should have one Compensation.');

			System.assertEquals(aContact.Acquisition_Compensation__r[0].Status__c, aContact.Acquisition_Provisioning__r[0].Offer_Status__c, 'Provision Offer status and Compensation status should match for each contact.');
		}
		
	}
	
}