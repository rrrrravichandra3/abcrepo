public without sharing class Acquisition_Provisioning_TriggerHandler {

	public static Boolean insertedAsDependent = false;
	
	public static void updateRehireFlagOnContactOnInsert(Map<Id, Acquisition_Provisioning__c> newProvisionMap){
		// Skip this logic if this is invoked by process of creating Provisioning on Contact Creation
		Map<Id, Acquisition_Provisioning__c> contactToProvision = new Map<Id, Acquisition_Provisioning__c>();
		List<Acquisition_Contacts__c> contactsNeedUpdate = new List<Acquisition_Contacts__c>();
		for(Id pid: newProvisionMap.keySet()){
			contactToProvision.put(newProvisionMap.get(pid).Acquisition_Contact__c, newProvisionMap.get(pid));
			contactsNeedUpdate.add(new Acquisition_Contacts__c(Id = newProvisionMap.get(pid).Acquisition_Contact__c, Rehire_Former_Worker__c = newProvisionMap.get(pid).Rehire_Former_Worker__c, Salesforce_Email_Address__c = newProvisionMap.get(pid).Salesforce_Email_Address__c));			
		}
		if(!contactsNeedUpdate.isEmpty()){
			updateContacts(contactsNeedUpdate, contactToProvision);
		}
	}

	public static void updateRehireFlagOnContactOnUpdate(Map<Id, Acquisition_Provisioning__c> newProvisionMap, 
												 Map<Id, Acquisition_Provisioning__c> oldProvisionMap){
		Map<Id, Acquisition_Provisioning__c> contactToProvision = new Map<Id, Acquisition_Provisioning__c>();
		List<Acquisition_Contacts__c> contactsNeedUpdate = new List<Acquisition_Contacts__c>();
		for(Id pid: newProvisionMap.keySet()){
			if(newProvisionMap.get(pid).Rehire_Former_Worker__c != oldProvisionMap.get(pid).Rehire_Former_Worker__c){
				contactToProvision.put(newProvisionMap.get(pid).Acquisition_Contact__c, newProvisionMap.get(pid));
				if (newProvisionMap.get(pid).Salesforce_Email_Address__c != oldProvisionMap.get(pid).Salesforce_Email_Address__c) {
					contactsNeedUpdate.add(new Acquisition_Contacts__c(Id = newProvisionMap.get(pid).Acquisition_Contact__c, Rehire_Former_Worker__c = newProvisionMap.get(pid).Rehire_Former_Worker__c, Salesforce_Email_Address__c = newProvisionMap.get(pid).Salesforce_Email_Address__c));
				} else {
                    
					contactsNeedUpdate.add(new Acquisition_Contacts__c(Id = newProvisionMap.get(pid).Acquisition_Contact__c, Rehire_Former_Worker__c = newProvisionMap.get(pid).Rehire_Former_Worker__c));
                    
				}
			} else if (newProvisionMap.get(pid).Salesforce_Email_Address__c != oldProvisionMap.get(pid).Salesforce_Email_Address__c) {
				contactsNeedUpdate.add(new Acquisition_Contacts__c(Id = newProvisionMap.get(pid).Acquisition_Contact__c, Salesforce_Email_Address__c = newProvisionMap.get(pid).Salesforce_Email_Address__c));
			}
		}
		if(!contactsNeedUpdate.isEmpty()){
			updateContacts(contactsNeedUpdate, contactToProvision);
		}
	}

	public static void updateContacts(List<Acquisition_Contacts__c> contacts, Map<Id, Acquisition_Provisioning__c> provisionsMap){
		List<Database.SaveResult> contactUpdateSaveResult = Database.update(contacts);
		for(Integer idx = 0; idx < contactUpdateSaveResult.size(); idx++){
            if(!contactUpdateSaveResult[idx].isSuccess()){
                Id failedContactId = contacts.get(idx).Id;
                String message = '';
                for(Database.Error error: contactUpdateSaveResult[idx].getErrors()){
                    message += error.getMessage();
                }
                provisionsMap.get(failedContactId).addError(message);
            }
        }
	}

	/**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * @author - Chakshu Malhotra (24/02/2022)
	* ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
	* W-10449458 / W-10678114 / W-10702588 : Method to publish Auto Enrolment Platform Events for each enrolment type.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newAcqProvMap 	 DESCRIPTION (Data type Map<Id, Acquisition_Provisioning__c>, Map of new Acquisition Provisioning records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
	public static void publishAutoEnrolmentEvents(Map<Id, Acquisition_Provisioning__c> newAcqProvMap) {
		Map<Id, Acquisition_Contacts__c> newAcqContactMap = getNewAcquisitionContactMap(newAcqProvMap);
        MA_AutoEnrolmentHelper.publishAutoEnrolmentPlatformEvents(newAcqContactMap, MA_AutoEnrolmentHelper.EnrolmentSource.PROVISIONING_UPDATE);
    }

	/**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * @author - Chakshu Malhotra (24/02/2022)
	* ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * W-10449458 / W-10678114 / W-10702588 : Method to get Acquisition Contact records based on record Ids.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqContactIds 	 DESCRIPTION (Data type Set<Id>, Set of Acquisition Contact record Ids)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
	private static Map<Id, Acquisition_Contacts__c> getNewAcquisitionContactMap(Map<Id, Acquisition_Provisioning__c> newAcqProvMap) {
		Set<Id> acqContactIds = getNewAcquisitionContactIds(newAcqProvMap);
		return new Map<Id, Acquisition_Contacts__c>([SELECT Id, Acquisition_Company__c 
													 FROM Acquisition_Contacts__c 
													 WHERE Id IN :acqContactIds]);
	}

	/**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * @author - Chakshu Malhotra (24/02/2022)
	* ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
	* W-10449458 / W-10678114 / W-10702588 : Method to get Acquisition Contacts Ids from Provisioning records.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newAcqProvMap 	 DESCRIPTION (Data type Map<Id, Acquisition_Provisioning__c>, Map of new Acquisition Provisioning records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
	private static Set<Id> getNewAcquisitionContactIds(Map<Id, Acquisition_Provisioning__c> newAcqProvMap) {
		Set<Id> acqContactIds = new Set<Id>();
		for(Id provKey : newAcqProvMap.keySet()) {
			acqContactIds.add(newAcqProvMap.get(provKey)?.Acquisition_Contact__c);
		}
		return acqContactIds;
	}
}