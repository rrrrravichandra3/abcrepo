public class Acquisition_Contacts_Trigger_Handler {
    
    public static Boolean triggerDisabled = false;
    public static Boolean IS_MA_WORKER_ID_SYNC_ACTIVE = false;

    private static final String OVERRIDE_DUPLICATE_EMAIL_CHECK_PERMISSION = Label.MA_Override_Duplicate_Email_Check_Permission;
    
    private static final String STATUS_CANCELLED = Label.MA_Contact_Status_Cancelled;
    private static final String DUPLICATE_CONTACT_ERROR_MSG = Label.MA_DuplicateContactError;
    private static final String ACQ_CONTACT_AFTER_UPDATE_TRIGGER_HANDLER = Label.MA_DS_Acquisition_Contact_After_Update_Trigger_Handler;

    public interface TriggerActionHandler {
        void handleAfterUpdate(List<Acquisition_Contacts__c> newRecords, Map<Id, Acquisition_Contacts__c> oldMap);
    }

    private class AcquisitionContact {
        private String targetEmail;
        private String personalEmail;
        private Acquisition_Contacts__c acqContact;

        public AcquisitionContact(Acquisition_Contacts__c acqContact) {
            this.acqContact = acqContact;
            this.targetEmail = acqContact.Email_Address_Target__c ?? '';
            this.personalEmail = acqContact.Personal_Email_Address__c ?? '';
        }

        public Acquisition_Contacts__c getAcqContact() {
            return acqContact;
        }

        public Boolean equals(Object obj) {
            Boolean isEquals = false;
    
            if(obj instanceof AcquisitionContact) {
                AcquisitionContact acqContactObj = (AcquisitionContact) obj;
                Boolean isAcqCompanyMatch = (acqContact.Acquisition_Company__c == acqContactObj.acqContact.Acquisition_Company__c);
                Boolean isTargetEmailMatch = (String.isNotBlank(targetEmail) && (targetEmail.equalsIgnoreCase(acqContactObj.targetEmail) || targetEmail.equalsIgnoreCase(acqContactObj.personalEmail)));
                Boolean isPersonalEmailMatch = (String.isNotBlank(personalEmail) && (personalEmail.equalsIgnoreCase(acqContactObj.personalEmail) || personalEmail.equalsIgnoreCase(acqContactObj.targetEmail)));
                isEquals = isAcqCompanyMatch && (isTargetEmailMatch || isPersonalEmailMatch);
            }
    
            return isEquals;
        }

        public Integer hashCode() {
            return System.hashCode(acqContact.Acquisition_Company__c) + System.hashCode(targetEmail) + System.hashCode(personalEmail);
        }
    }

    public static void handleBeforeTrigger(TriggerOperation operationType, List<Acquisition_Contacts__c> newRecords, Map<Id, Acquisition_Contacts__c> oldMap) {
        for(Acquisition_Contacts__c newRecord : newRecords) {
            updateMuleExtId(newRecord);
            checkDuplicateAcqContact(newRecord, oldMap?.get(newRecord.Id));

            switch on operationType {
                when BEFORE_INSERT {
                    updateCountryDivision(newRecord);
                }when BEFORE_UPDATE {
                    updateCountryDivision(newRecord, oldMap.get(newRecord.Id));
                    updateBusinessTitle(newRecord, oldMap.get(newRecord.Id));
                }
            }
        }

        if(operationType == TriggerOperation.BEFORE_INSERT || operationType == TriggerOperation.BEFORE_UPDATE) {
            if(emailAddresses.size() > 0 && !FeatureManagement.checkPermission(OVERRIDE_DUPLICATE_EMAIL_CHECK_PERMISSION)) {
                addErrorIfDuplicateAcqContacts(oldMap?.keySet());
            }
        }
    }

    private static Set<String> emailAddresses = new Set<String>();
    private static List<AcquisitionContact> acqContacts = new List<AcquisitionContact>();
    private static List<Acquisition_Contacts__c> duplicateAcqContacts = new List<Acquisition_Contacts__c>();

    private static Map<Id, Acquisition_Company__c> acqCompanyMap {
        get {
            if(acqCompanyMap == null) {
                acqCompanyMap = new Map<Id, Acquisition_Company__c>([SELECT Id, Name FROM Acquisition_Company__c WHERE Id IN :acqCompanyIds]);
            }
            return acqCompanyMap;
        }set;
    }

    private static Set<Id> acqCompanyIds {
        get {
            if(acqCompanyIds == null) {
                acqCompanyIds = new Set<Id>();
                for(Acquisition_Contacts__c newRecord : (List<Acquisition_Contacts__c>)Trigger.new) {
                    acqCompanyIds.add(newRecord.Acquisition_Company__c);
                }
            }
            return acqCompanyIds;
        }set;
    }

    private static Map<String, MA_WD_Country_Loc_Mapping__mdt> wdCountryLocationMap {
        get {
            if(wdCountryLocationMap == null) {
                wdCountryLocationMap = new Map<String, MA_WD_Country_Loc_Mapping__mdt>();
                
                for(MA_WD_Country_Loc_Mapping__mdt wdCountryLocationMapping : MA_WD_Country_Loc_Mapping__mdt.getAll()?.values()) {
                    wdCountryLocationMap.put(wdCountryLocationMapping.WD_Country__c, wdCountryLocationMapping);
                }
            }
            return wdCountryLocationMap;
        }set;
    }

    private static Map<Id, Acquisition_Compensation__c> acqCompensationMap {
        get {
            if(acqCompensationMap == null) {
                acqCompensationMap = new Map<Id, Acquisition_Compensation__c>();
                for (Acquisition_Compensation__c acqCompensation : [SELECT Id, Posting_Title__c, Acquisition_Contact__c 
                                                                    FROM Acquisition_Compensation__c 
                                                                    WHERE Acquisition_Contact__c IN :Trigger.newMap.keySet()]) {
                    acqCompensationMap.put(acqCompensation.Acquisition_Contact__c, acqCompensation);
                }
            }
            return acqCompensationMap;
        }set;
    }

    private static void updateMuleExtId(Acquisition_Contacts__c newRecord) {
        if(newRecord.MuleExtId__c == null) {
            newRecord.MuleExtId__c = newRecord.Employee_ID_Target__c + ':' + acqCompanyMap.get(newRecord.Acquisition_Company__c)?.Name;
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * @author - Srikanth Chennoju
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * W-14226204 (12/10/2023) : Method to populate Division and Country based on Workday Location
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecord          (Data type Acquisition_Contacts__c, Acquisition Contact record from Trigger.new)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateCountryDivision(Acquisition_Contacts__c newRecord) {
        if(newRecord.Workday_Location__c != null && wdCountryLocationMap.containsKey(newRecord.Workday_Location__c)) {
            newRecord.Division__c = wdCountryLocationMap.get(newRecord.Workday_Location__c).Division__c;
            newRecord.Office_Address_Country__c = wdCountryLocationMap.get(newRecord.Workday_Location__c).Country__c;
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * @author - Srikanth Chennoju
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * W-14226204 (12/10/2023) : BEFORE_UPDATE - Method to populate Division and Country based on Workday Location
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecord          (Data type Acquisition_Contacts__c, Acquisition Contact record from Trigger.new)
    * @param    oldRecord          (Data type Acquisition_Contacts__c, Acquisition Contact record from Trigger.oldMap)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateCountryDivision(Acquisition_Contacts__c newRecord, Acquisition_Contacts__c oldRecord) {
        if(newRecord.Workday_Location__c != oldRecord.Workday_Location__c) {
            updateCountryDivision(newRecord);
        }
    }

    private static void checkDuplicateAcqContact(Acquisition_Contacts__c newRecord, Acquisition_Contacts__c oldRecord) {
        if(isEmailUpdated(newRecord, oldRecord)) {
            addEmailAddresses(newRecord);

            if(getAcquisitionContactIndex(newRecord, true) > -1) {
                duplicateAcqContacts.add(newRecord);
            }
        }
    }

    private static Boolean isEmailUpdated(Acquisition_Contacts__c newRecord, Acquisition_Contacts__c oldRecord) {
        return newRecord.Email_Address_Target__c != oldRecord?.Email_Address_Target__c || newRecord.Personal_Email_Address__c != oldRecord?.Personal_Email_Address__c;
    }

    private static void addEmailAddresses(Acquisition_Contacts__c newRecord) {
        emailAddresses.add(newRecord.Email_Address_Target__c);
        emailAddresses.add(newRecord.Personal_Email_Address__c);
    }

    private static Integer getAcquisitionContactIndex(Acquisition_Contacts__c newRecord, Boolean addToList) {
        AcquisitionContact acqContact = new AcquisitionContact(newRecord);
        Integer acqContactIndex = acqContacts.indexOf(acqContact);

        if(addToList) {
            acqContacts.add(acqContact);
        }
        return acqContactIndex;
    }
    
    private static void addErrorIfDuplicateAcqContacts(Set<Id> recordIds) {
        emailAddresses.remove(null);

        for(Acquisition_Contacts__c acqContact : [SELECT Id, Email_Address_Target__c, Personal_Email_Address__c, Acquisition_Company__c 
                                                  FROM Acquisition_Contacts__c 
                                                  WHERE Id NOT IN :recordIds AND
                                                  Acquisition_Company__c IN :acqCompanyIds AND
                                                  (Email_Address_Target__c IN :emailAddresses OR Personal_Email_Address__c IN :emailAddresses)]) {
            Integer acqContactIndex = getAcquisitionContactIndex(acqContact, false);

            if(acqContactIndex > -1) {
                duplicateAcqContacts.add(acqContacts.get(acqContactIndex).getAcqContact());
            }
        }

        for(Acquisition_Contacts__c duplicateAcqContact : duplicateAcqContacts) {
            duplicateAcqContact.addError(DUPLICATE_CONTACT_ERROR_MSG);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * @author - Priyanka Kanani
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * W-14284082 (17/10/2023) : Method to update business title to Posting title from Acquisition Compensation if field is empty.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecord          (Data type Acquisition_Contacts__c, Acquisition Contact record from Trigger.new)
    * @param    oldRecord          (Data type Acquisition_Contacts__c, Acquisition Contact record from Trigger.oldMap)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateBusinessTitle(Acquisition_Contacts__c newRecord, Acquisition_Contacts__c oldRecord) {
        if(String.isBlank(newRecord.Business_Title__c) && newRecord.Business_Title__c != oldRecord.Business_Title__c) {
            newRecord.Business_Title__c = acqCompensationMap.get(newRecord.Id)?.Posting_Title__c;
        }
    }
    
    //This method is called after insert to create dependent objects (Provisioning and Compensation)
    public static void createDependentObjects(Map<Id, Acquisition_Contacts__c> acquistionContactsMap){
        List<Acquisition_Provisioning__c> provisionRecordsToCreate = new List<Acquisition_Provisioning__c>();
        List<Acquisition_Compensation__c> compensationRecordsToCreate = new List<Acquisition_Compensation__c>();
        for(Acquisition_Contacts__c acquistionContact : acquistionContactsMap.values()){
            provisionRecordsToCreate.add(new Acquisition_Provisioning__c(Acquisition_Contact__c = acquistionContact.Id, Rehire_Former_Worker__c = acquistionContact.Rehire_Former_Worker__c
                                                                        ));
            compensationRecordsToCreate.add(new Acquisition_Compensation__c(Acquisition_Contact__c = acquistionContact.Id,MuleExtId__c = acquistionContact.MuleExtId__c));
        }
        //MA_Util.autoProvisioningCompensationCreationFlag = true;
        //Create provisionings for new contacts
        boolean provisioningRecordsCreationSuccessful = true;
        if(!provisionRecordsToCreate.isEmpty()){
            Acquisition_Provisioning_TriggerHandler.insertedAsDependent = true;
            List<Database.SaveResult> saveResults = Database.insert(provisionRecordsToCreate, true);
            for(Integer idx = 0; idx < provisionRecordsToCreate.size(); idx++){
                if(!saveResults[idx].isSuccess()){
                    provisioningRecordsCreationSuccessful = false;
                    Id failedContactId = provisionRecordsToCreate.get(idx).Acquisition_Contact__c;
                    String message = '';
                    for(Database.Error error: saveResults[idx].getErrors()){
                        message += error.getMessage();
                    }
                    acquistionContactsMap.get(failedContactId).addError(message);
                }
            }
        }
        // Only create offers for contacts if provisionings creation is successful
        if(!compensationRecordsToCreate.isEmpty() && provisioningRecordsCreationSuccessful){
            Acquisition_Compensation_TriggerHandler.insertedAsDependent = true;
            List<Database.SaveResult> saveResults = Database.insert(compensationRecordsToCreate, true);
            for(Integer idx = 0; idx < provisionRecordsToCreate.size(); idx++){
                if(!saveResults[idx].isSuccess()){
                    Id failedContactId = provisionRecordsToCreate.get(idx).Acquisition_Contact__c;
                    String message = '';
                    for(Database.Error error: saveResults[idx].getErrors()){
                        message += error.getMessage();
                    }
                    acquistionContactsMap.get(failedContactId).addError(message);
                }
            }
        }
        //MA_Util.autoProvisioningCompensationCreationFlag = false;
    }
    
    public static void updateRehireOnProvisionUpdate(Map<Id, Acquisition_Contacts__c> newContactMap, Map<Id, Acquisition_Contacts__c> oldContactMap){
        Map<Id, Acquisition_Contacts__c> contactsThatNeedUpdateProvision = new Map<Id, Acquisition_Contacts__c>();
        for(Id cid: newContactMap.keySet()){
            if(newContactMap.get(cid).Rehire_Former_Worker__c != oldContactMap.get(cid).Rehire_Former_Worker__c){
                contactsThatNeedUpdateProvision.put(cid, newContactMap.get(cid));
            }
        }
        if(!contactsThatNeedUpdateProvision.isEmpty()){
            List<Acquisition_Provisioning__c> provisions = [SELECT Id, Name, Rehire_Former_Worker__c, Acquisition_Contact__c, Acquisition_Contact__r.Rehire_Former_Worker__c FROM Acquisition_Provisioning__c WHERE Acquisition_Contact__c IN : contactsThatNeedUpdateProvision.keySet()];
            List<Acquisition_Provisioning__c> provisionsThatNeedUpdate = new List<Acquisition_Provisioning__c>();
            for(Acquisition_Provisioning__c provision: provisions){
                if(provision.Rehire_Former_Worker__c != provision.Acquisition_Contact__r.Rehire_Former_Worker__c){
                    provision.Rehire_Former_Worker__c = provision.Acquisition_Contact__r.Rehire_Former_Worker__c;
                    provisionsThatNeedUpdate.add(provision);
                }
            }
            if(!provisionsThatNeedUpdate.isEmpty()){
                List<Database.SaveResult> provisionUpdateResult = Database.update(provisionsThatNeedUpdate);
                for(Integer idx = 0; idx < provisionUpdateResult.size(); idx++){
                    if(!provisionUpdateResult[idx].isSuccess()){
                        Id failedContactId = provisionsThatNeedUpdate.get(idx).Acquisition_Contact__c;
                        String message = '';
                        for(Database.Error error: provisionUpdateResult[idx].getErrors()){
                            message += error.getMessage();
                        }
                        newContactMap.get(failedContactId).addError(message);
                    }
                }
            }
        }
    }
    
    public static void updateEmail(Map<Id, Acquisition_Contacts__c> newAcqConMap, Map<Id, Acquisition_Contacts__c> oldAcqConMap){
        List<Contact> contactsToUpdate = new List<Contact>();
        List<User> usersToUpdate = new List<User>();
        Map<String,String> emailMap = new Map<String,String>();
        List<User> userRecs = new List<User>();
        List<Id> contactRecs = new List<Id>();
        for(Acquisition_Contacts__c acqContact : newAcqConMap.values()) {
            if(acqContact.Email_Address_Target__c != oldAcqConMap.get(acqContact.Id).Email_Address_Target__c) {
                emailMap.put(oldAcqConMap.get(acqContact.Id).Email_Address_Target__c,newAcqConMap.get(acqContact.Id).Email_Address_Target__c);
            }
        }
        if(!emailMap.isEmpty()){
            userRecs = [Select FederationIdentifier,Email, ContactId From User Where Email IN :emailMap.keySet()
                        AND ContactId != Null AND UserType != 'Standard'];
        }
        
        if(userRecs.size() != 0) {
            for(User usr:userRecs){
                usr.Email = emailMap.get(usr.Email);
                usr.FederationIdentifier = emailMap.get(usr.FederationIdentifier);
                usersToUpdate.add(usr);
                contactRecs.add(usr.ContactId);
            }
        }
        
        if(contactRecs.size()>0){
            for(Contact c:[Select Email From Contact Where Id =:contactRecs ]){
                c.Email = emailMap.get(c.Email);
                contactsToUpdate.add(c);
            }
        }
        
        if(usersToUpdate.size() != 0 && contactsToUpdate.size() != 0) {
            update contactsToUpdate;
            update usersToUpdate;
        }   
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * @author - Chakshu Malhotra (24/02/2022)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * W-10449458 / W-10678114 / W-10702588 : Method to publish Auto Enrolment Platform Events for each enrolment type.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newAcqContactMap 	 (Data type Map<Id, Acquisition_Contacts__c>, Map of new Acquisition Contact records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void publishAutoEnrolmentEvents(Map<Id, Acquisition_Contacts__c> newAcqContactMap) {
        MA_AutoEnrolmentHelper.publishAutoEnrolmentPlatformEvents(newAcqContactMap, MA_AutoEnrolmentHelper.EnrolmentSource.CONTACT_UPDATE);
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * @author - Chakshu Malhotra
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * W-10995661 (21/04/2022) : Method to toggle activation of Wayfinder Users based on Contact Status & Community Access.
    * W-11019082 (07/07/2022) : Method to update Wayfinder User's Timezone in case of any update on Time Zone in Acquisition Contact record.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newAcqContacts       (Data type List<Acquisition_Contacts__c>, List of new Acquisition Contact records)
    * @param    oldAcqContactMap 	 (Data type Map<Id, Acquisition_Contacts__c>, Trigger.oldMap of Acquisition Contact records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void updateWayfinderUsers(List<Acquisition_Contacts__c> newAcqContacts, Map<Id, Acquisition_Contacts__c> oldAcqContactMap) {
        Map<Id, String> userTimeZoneMap = new Map<Id, String>();
        Map<Id, Boolean> userActivationMap = new Map<Id, Boolean>();
        
        for(Acquisition_Contacts__c acqContact : newAcqContacts) {
            Boolean isActiveNow = isActiveContact(acqContact);
            Boolean isActivePrior = isActiveContact(oldAcqContactMap.get(acqContact.Id));
            
            if(isActiveNow && !isActivePrior) {
                userActivationMap.put(acqContact.Id, true);
            }else if(!isActiveNow && isActivePrior) {
                userActivationMap.put(acqContact.Id, false);
            }
            
            if(isTimezoneUpdated(acqContact, oldAcqContactMap.get(acqContact.Id))) {
                userTimeZoneMap.put(acqContact.Id, acqContact.Time_Zone__c);
            }
        }
        
        if(userTimeZoneMap.size() > 0 || userActivationMap.size() > 0) {
            updateWayfinderUsers(userTimeZoneMap, userActivationMap);
        }
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * @author - Chakshu Malhotra
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * W-11019082 (07/07/2022) : Method to check if the value of TimeZone is updated on Acquisition Contact record.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newAcqContact       (Data type Acquisition_Contacts__c, Acquisition Contact record in Trigger.new)
    * @param    oldAcqContact       (Data type Acquisition_Contacts__c, Acquisition Contact record in Trigger.oldMap)
    * @return   Boolean             DESCRIPTION (return true if the acquisition contact record is updated with new TimeZone value)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isTimezoneUpdated(Acquisition_Contacts__c newAcqContact, Acquisition_Contacts__c oldAcqContact) {
        return (newAcqContact.Time_Zone__c != null && newAcqContact.Time_Zone__c != oldAcqContact.Time_Zone__c);
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * @author - Chakshu Malhotra
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * W-10995661 (21/04/2022) : Method to check the current activation status of Acquisition Contact record.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqContact      (Data type Acquisition_Contacts__c, Acquisition Contact record)
    * @return   Boolean         DESCRIPTION (return true if the acquisition contact record is active)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isActiveContact(Acquisition_Contacts__c acqContact) {
        return (acqContact.Contact_Status__c != STATUS_CANCELLED && !acqContact.Remove_Community_Access__c);
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * @author - Chakshu Malhotra
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * W-10995661 (21/04/2022) : Future method to toggle IsActive value of Wayfinder user.
    * W-11019082 (07/07/2022) : Updates User Timezone if any changes made to TimeZone field in Acquisition Contact record.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    userTimeZoneMap         (Data type Map<Id, String>, Map of Acquisition Contact Id to Time Zone Sid Key)
    * @param    userActivationMap       (Data type Map<Id, Boolean>, Map of Acquisition Contact Id to activation status)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @future
    public static void updateWayfinderUsers(Map<Id, String> userTimeZoneMap, Map<Id, Boolean> userActivationMap) {
        Set<Id> acqIds = new Set<Id>(userTimeZoneMap.keySet());
        acqIds.addAll(userActivationMap.keySet());
        
        List<User> wayfinderUsers = [SELECT Id, IsActive, TimeZoneSidKey, Contact.Acquisition_Contacts__c 
                                     FROM User 
                                     WHERE Contact.Acquisition_Contacts__c IN :acqIds];
        
        for(User wayfinderUser : wayfinderUsers) {
            Id acqId = wayfinderUser.Contact.Acquisition_Contacts__c;
            
            if(userTimeZoneMap.containsKey(acqId)) {
                wayfinderUser.TimeZoneSidKey = userTimeZoneMap.get(acqId);
            }
            
            if(Schema.sObjectType.User.fields.IsActive.isUpdateable() && userActivationMap.containsKey(acqId)) {
                wayfinderUser.IsActive = userActivationMap.get(acqId);
            }
        }
        
        if(wayfinderUsers.size() > 0) {
            Database.SaveResult[] srList = Database.update(wayfinderUsers, false);
            MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(srList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * @author - Chakshu Malhotra
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * W-15173914 (12/03/2024) : Method to handle after update trigger logic on Acquisition Contact records; created to dynamically instantiate & execute handler logic if handler class exists.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecords          (Data type List<Acquisition_Contacts__c>, List of new Acquisition Contact records)
    * @param    oldMap 	            (Data type Map<Id, Acquisition_Contacts__c>, Trigger.oldMap of Acquisition Contact records)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void handleAfterUpdate(List<Acquisition_Contacts__c> newRecords, Map<Id, Acquisition_Contacts__c> oldMap) {
        TriggerActionHandler handlerInstance = (TriggerActionHandler)Type.forName(ACQ_CONTACT_AFTER_UPDATE_TRIGGER_HANDLER)?.newInstance();
        handlerInstance?.handleAfterUpdate(newRecords, oldMap);
    }
}