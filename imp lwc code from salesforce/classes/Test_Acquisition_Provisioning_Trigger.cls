@isTest
private class Test_Acquisition_Provisioning_Trigger {
	
	//Bulk Records actions
	@isTest static void testBulkProvisioningUpdate() {
		Acquisition_Company__c company = new Acquisition_Company__c(Name='Test Company');
		insert company;
		System.assertNotEquals(null, company.Id, 'Company creation failed.');
		List<Acquisition_Contacts__c> aContacts200 = new List<Acquisition_Contacts__c>();
		for(Integer idx = 0; idx < 200; idx++){
			aContacts200.add(new Acquisition_Contacts__c(Acquisition_Company__c = company.Id, Name='Contact Legal Name'+ idx, Employee_ID_Target__c = '123456' + String.valueOf(idx),Email_Address_Target__c ='TestBulkUpdate'+String.valueOf(idx)+'@test.com'
                                                        ,Personal_Email_Address__c  ='PersonalTestBulkUpdate'+String.valueOf(idx)+'@test.com'));
		}
		insert aContacts200;
        Map<Id, Acquisition_Provisioning__c> provisionCreated = new Map<Id, Acquisition_Provisioning__c>([SELECT Id, Name, Acquisition_Contact__c, Offer_Status__c, Rehire_Former_Worker__c,Salesforce_Email_Address__c
                                                                                                    FROM Acquisition_Provisioning__c]);
		System.assertEquals(200, provisionCreated.KeySet().size(), 'There should be one Provisioning record.');
        
        Test.StartTest();
        Acquisition_Provisioning_TriggerHandler.updateRehireFlagOnContactOnInsert(provisionCreated);
        Test.StopTest();

		List<Acquisition_Compensation__c> autoCreatedCompenesations = [SELECT Id, Name, Acquisition_Contact__c, Status__c FROM Acquisition_Compensation__c];
		System.assertEquals(200, autoCreatedCompenesations.size(), 'There should be one Compensation record.');

		List<Acquisition_Contacts__c> queriedContacts = [SELECT Id, Name, Rehire_Former_Worker__c FROM Acquisition_Contacts__c];

		for(Integer idx = 0; idx < 190; idx++){
			provisionCreated.values()[idx].Rehire_Former_Worker__c= true;
		}
		update provisionCreated.values();
		
		List<Acquisition_Provisioning__c> queriedProvisionAfterRehireUpdate = [SELECT Id, Name, Rehire_Former_Worker__c, Acquisition_Contact__r.Rehire_Former_Worker__c, 
																				Acquisition_Contact__c FROM Acquisition_Provisioning__c];

		for(Acquisition_Provisioning__c aProvision : queriedProvisionAfterRehireUpdate){
			System.assertEquals(aProvision.Rehire_Former_Worker__c, aProvision.Acquisition_Contact__r.Rehire_Former_Worker__c, 'Rehire/Former worker flag should match between Contact and Provision');
		}
	}
	
	@isTest static void testBulkProvisioningEmailUpdate() {
		Acquisition_Company__c company = new Acquisition_Company__c(Name='Test Company');
		insert company;
		System.assertNotEquals(null, company.Id, 'Company creation failed.');
		List<Acquisition_Contacts__c> aContacts200 = new List<Acquisition_Contacts__c>();
		for(Integer idx = 0; idx < 200; idx++){
			aContacts200.add(new Acquisition_Contacts__c(Acquisition_Company__c = company.Id, Name='Contact Legal Name'+ idx, Employee_ID_Target__c = '123456' + String.valueOf(idx),Email_Address_Target__c ='TestEmailUpdate'+String.valueOf(idx)+'@test.com',
                                                         Personal_Email_Address__c  ='PersonalEmailTest'+String.valueOf(idx)+'@test.com'));
		}
		insert aContacts200;
		List<Acquisition_Provisioning__c> autoCreatedProvisions = [SELECT Id, Name, Acquisition_Contact__c, Offer_Status__c, Rehire_Former_Worker__c, Salesforce_Email_Address__c,
																	Acquisition_Contact__r.Salesforce_Email_Address__c FROM Acquisition_Provisioning__c];
		System.assertEquals(200, autoCreatedProvisions.size(), 'There should be one Provisioning record.');
		for(Acquisition_Provisioning__c aProvision : autoCreatedProvisions){
			System.assertEquals(aProvision.Salesforce_Email_Address__c, aProvision.Acquisition_Contact__r.Salesforce_Email_Address__c, 'Salesforce Email Address should match between Contact and Provision');
		}

		for(Integer idx = 0; idx < 190; idx++){
			autoCreatedProvisions[idx].Salesforce_Email_Address__c = 'test' + String.valueOf(idx) + '@email.invalid';
		}
		update autoCreatedProvisions;
		
		List<Acquisition_Provisioning__c> queriedProvisionAfterEmailUpdate = [SELECT Id, Name, Rehire_Former_Worker__c, Acquisition_Contact__r.Rehire_Former_Worker__c, 
																				Acquisition_Contact__c, Salesforce_Email_Address__c, Acquisition_Contact__r.Salesforce_Email_Address__c FROM Acquisition_Provisioning__c];

		for(Acquisition_Provisioning__c aProvision : queriedProvisionAfterEmailUpdate){
			System.assertEquals(aProvision.Salesforce_Email_Address__c, aProvision.Acquisition_Contact__r.Salesforce_Email_Address__c, 'Salesforce Email Address should match between Contact and Provision');
		}
	}

}