public with sharing class Acquisition_Compensation_TriggerHandler {

    public static Boolean triggerDisabled = false;
    public static Boolean insertedAsDependent = false;
    
    private static Map<Id, Acquisition_Contacts__c> newAcqContactMap;

    private static final String EXECUTIVE_JOB_CODE_PATTERN = '^([a-zA-Z0-9]+)(?<=([PC][1][1-3]))$';
    private static final String NON_EXECUTIVE_JOB_CODE_PATTERN = '^([a-zA-Z0-9]+)(?<=([PC]([0][1-9]|(10))))$';
    private static final String DUPLICATE_COMP_ERROR_MSG = Label.MA_DuplicateCompensationError;

    //Copies status from Compensation to Provisioning Offer Status
    public static void copyOfferStatusToProvisionOnInsert(Map<Id, Acquisition_Compensation__c> newCompensationsMap){
        //if(!MA_Util.autoProvisioningCompensationCreationFlag){
            updateProvisioningStatus(newCompensationsMap);
        //}
    }

    //Copies status from Compensation to Provisioning Offer Status
    public static void copyOfferStatusToProvisionOnUpdate(Map<Id, Acquisition_Compensation__c> newCompensationsMap, Map<Id, Acquisition_Compensation__c> oldCompensationsMap){
        Map<Id, Acquisition_Compensation__c> statusUpdatedCompensations = new Map<Id, Acquisition_Compensation__c>();
        for(Id compId : newCompensationsMap.keySet()){
            if(newCompensationsMap.get(compId).Status__c != oldCompensationsMap.get(compId).Status__c ){
                statusUpdatedCompensations.put(compId, newCompensationsMap.get(compId));
            }
        }
        if(!statusUpdatedCompensations.isEmpty()){
            updateProvisioningStatus(statusUpdatedCompensations);
        }
    }

    private static List<M_A_Preboarding_Setting__mdt> settings{
        get{
            if(settings == null) settings = [SELECT Access_Level__c, Compensation_Access__c, DeveloperName, Label, 
                                                Rank__c, Type__c, Can_Share__c FROM M_A_Preboarding_Setting__mdt 
                                                WHERE Type__c = 'Access' ORDER BY Rank__c ASC];
            return settings;
        }
        set;
    }

    public static void updateSharingOfCompensation(Map<Id, Acquisition_Compensation__c> newCompensationsMap) {
        Set<String> compensationAccessPermSets = new Set<String>();
        for(M_A_Preboarding_Setting__mdt setting: settings){
            if(setting.Compensation_Access__c == true){
                compensationAccessPermSets.add(setting.DeveloperName);
            }
        }
        
        Set<Id> newAcqCompensationIds = newCompensationsMap.keySet();
        Set<Id> newAcqCompanyIds = new Set<Id>();
        Set<Id> userIdsWithCompanyShare = new Set<Id>();
        Set<Id> userIdsWithCompanyShareAndCompensationPerms = new Set<Id>();
        List<Acquisition_Compensation__Share> AcquisitionCompensationShares = new List<Acquisition_Compensation__Share>();
        map<string,list<Acquisition_Company__Share>> mCompanyWithCompanyShareUsers= new map<string,list<Acquisition_Company__Share>>();

        List<Acquisition_Compensation__c> acqComps = [SELECT Id,Acquisition_Contact__r.Acquisition_Company__c FROM Acquisition_Compensation__c WHERE Id IN:newAcqCompensationIds];
        for(Acquisition_Compensation__c ac : acqComps){
            newAcqCompanyIds.add(ac.Acquisition_Contact__r.Acquisition_Company__c);
        }
        List<Acquisition_Company__Share> allAcqCompanySharings = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Acquisition_Company__Share WHERE ParentId IN:newAcqCompanyIds];
        //Get List of users with whom the company is shared and also group them by company.
        for(Acquisition_Company__Share companyShare: allAcqCompanySharings){
            userIdsWithCompanyShare.add(companyShare.UserOrGroupId);
            String AqcCompId = companyShare.ParentId;
            if(mCompanyWithCompanyShareUsers.containsKey(AqcCompId)){
                mCompanyWithCompanyShareUsers.get(AqcCompId).add(companyShare);
            }else{
                mCompanyWithCompanyShareUsers.put(AqcCompId,new list<Acquisition_Company__Share>{companyShare});
            }
        }
        //Get List of users with whom company is shared who also have compensation permsets
        List<PermissionSetAssignment> userPermSetsWithCompanyShareAndCompensationPerms = [SELECT AssigneeId, PermissionSetId, PermissionSet.Name FROM PermissionSetAssignment 
                                                                           WHERE PermissionSet.Name IN:compensationAccessPermSets AND AssigneeId in :userIdsWithCompanyShare];
        //Same user will have multiple comp perm set assignments .As long as the user is having access to any comp perm set in the list, we grab the unique userid.
        for(PermissionSetAssignment userPermSetWithCompanyShareAndCompensationPerms:userPermSetsWithCompanyShareAndCompensationPerms){
            userIdsWithCompanyShareAndCompensationPerms.add(userPermSetWithCompanyShareAndCompensationPerms.AssigneeId);
        }
        //For given compensation record if the respective company is shared with user who has compensation perms - Create Compensation Share record.
        for(Acquisition_Compensation__c ac : acqComps) {
            List<Acquisition_Company__Share> acqCompanySharings = new List<Acquisition_Company__Share>();
            String AqcCompanyId =ac.Acquisition_Contact__r.Acquisition_Company__c;
            if(mCompanyWithCompanyShareUsers.containsKey(AqcCompanyId)){
                acqCompanySharings = mCompanyWithCompanyShareUsers.get(AqcCompanyId);
            }
            //Changes for Compensation Sharing 
            for(Acquisition_Company__Share acqCompShare : acqCompanySharings) {
                if(userIdsWithCompanyShareAndCompensationPerms.contains(acqCompShare.UserOrGroupId) ){
                   //&& acqCompShare.UserOrGroupId != UserInfo.getUserId()) {
                    Acquisition_Compensation__Share acqCompensationShare = new Acquisition_Compensation__Share();
                    acqCompensationShare.ParentId = ac.Id;
                    acqCompensationShare.UserOrGroupId = acqCompShare.UserOrGroupId;
                    acqCompensationShare.AccessLevel =  (acqCompShare.AccessLevel == 'All') ?  'Edit': acqCompShare.AccessLevel;
                   // acqCompensationShare.AccessLevel = acqCompShare.AccessLevel;
                    acqCompensationShare.RowCause = Schema.Acquisition_Compensation__Share.RowCause.Manual;
                    AcquisitionCompensationShares.add(acqCompensationShare);
                }
            }
        }
        
        try {
            if(AcquisitionCompensationShares.size()>0){
                Database.SaveResult[] AcquisitionCompensationShareInsertResult = Database.insert(AcquisitionCompensationShares, false);
                System.debug('AcquisitionCompensationShareInsertResult '+AcquisitionCompensationShareInsertResult   );
            }
        }
        catch(DmlException exp) {
            System.debug('The following DML exception occured: '+exp.getMessage());
        }
        catch(Exception exp) {
            System.debug('The following exception occured: '+exp.getMessage());
        }
    }

    public static void updateProvisioningStatus(Map<Id, Acquisition_Compensation__c> updateNeededComp){
        Map<Id, Acquisition_Compensation__c> contactToComp = new Map<Id, Acquisition_Compensation__c>(); 
        for(Acquisition_Compensation__c comp: updateNeededComp.values()){
            contactToComp.put(comp.Acquisition_Contact__c, comp);
        }
        if(!contactToComp.isEmpty()){
            //Query Contact with provisions to update the Offer Status using Contact
            List<Acquisition_Contacts__c> acquisitionContacts = [SELECT Id, Name, 
                                                    (SELECT Id, Offer_Status__c, Acquisition_Contact__c FROM Acquisition_Provisioning__r) 
                                                    FROM Acquisition_Contacts__c WHERE Id IN :contactToComp.keySet()];
            //Collect all provisions that need update offer status
            List<Acquisition_Provisioning__c> provisionForOfferStatusUpdate = new List<Acquisition_Provisioning__c>();
            for(Acquisition_Contacts__c acquisitionContact: acquisitionContacts){
                if(acquisitionContact.Acquisition_Provisioning__r.size() > 1){
                    contactToComp.get(acquisitionContact.Id).addError('Related Contact has more than one provisioning records.');
                }else if(acquisitionContact.Acquisition_Provisioning__r == null || acquisitionContact.Acquisition_Provisioning__r.size() == 0){
                    contactToComp.get(acquisitionContact.Id).addError('Related Contact has more than one provisioning records.');
                }else{
                    for(Acquisition_Provisioning__c provision: acquisitionContact.Acquisition_Provisioning__r){
                        String compStatus = contactToComp.get(acquisitionContact.Id).Status__c;
                        if(provision.Offer_Status__c != compStatus){
                            provision.Offer_Status__c = compStatus;
                            provisionForOfferStatusUpdate.add(provision);
                        }
                    }
                }
            }
            if(!provisionForOfferStatusUpdate.isEmpty()){
                //MA_Util.offerStatusUpdateInProcessFlag = true;
                List<Database.SaveResult> provisioningsUpdateSaveResult = Database.update(provisionForOfferStatusUpdate);
                //MA_Util.offerStatusUpdateInProcessFlag = false;
                for(Integer idx = 0; idx < provisioningsUpdateSaveResult.size(); idx++){
                    if(!provisioningsUpdateSaveResult[idx].isSuccess()){
                        Id failedContactId = provisionForOfferStatusUpdate.get(idx).Acquisition_Contact__c;
                        String message = '';
                        for(Database.Error error: provisioningsUpdateSaveResult[idx].getErrors()){
                            message += error.getMessage();
                        }
                        contactToComp.get(failedContactId).addError(message);
                    }
                }
            }
        }
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * @author - Chakshu Malhotra (24/02/2022)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * W-10449458 / W-10678114 / W-10702588 : Method to publish Auto Enrolment Platform Events for each enrolment type.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newAcqCompMap    DESCRIPTION (Data type Map<Id, Acquisition_Compensation__c>, Map of new Acquisition Compensation records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void publishAutoEnrolmentEvents(Map<Id, Acquisition_Compensation__c> newAcqCompMap) {
        Map<Id, Acquisition_Contacts__c> acqContactMap = getNewAcquisitionContactMap(newAcqCompMap);
        MA_AutoEnrolmentHelper.publishAutoEnrolmentPlatformEvents(acqContactMap, MA_AutoEnrolmentHelper.EnrolmentSource.COMPENSATION_UPDATE);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * @author - Chakshu Malhotra (24/02/2022)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * W-10449458 / W-10678114 / W-10702588 : Method to get Acquisition Contact records based on record Ids.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqContactIds    DESCRIPTION (Data type Set<Id>, Set of Acquisition Contact record Ids)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<Id, Acquisition_Contacts__c> getNewAcquisitionContactMap(Map<Id, Acquisition_Compensation__c> newAcqCompMap) {
        if(newAcqContactMap == null) {
            Set<Id> acqContactIds = getNewAcquisitionContactIds(newAcqCompMap);
            newAcqContactMap = new Map<Id, Acquisition_Contacts__c>([SELECT Id, Acquisition_Company__c, Executive__c, Business_Title__c, Pay_Rate_Type__c
                                                                     FROM Acquisition_Contacts__c 
                                                                     WHERE Id IN :acqContactIds]);
        }
        return newAcqContactMap;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * @author - Chakshu Malhotra (24/02/2022)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * W-10449458 / W-10678114 / W-10702588 : Method to get Acquisition Contacts Ids from Compensation records.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newAcqCompMap    DESCRIPTION (Data type Map<Id, Acquisition_Compensation__c>, Map of new Acquisition Compensation records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Set<Id> getNewAcquisitionContactIds(Map<Id, Acquisition_Compensation__c> newAcqCompMap) {
        Set<Id> acqContactIds = new Set<Id>();
        for(Id compKey : newAcqCompMap.keySet()) {
            acqContactIds.add(newAcqCompMap.get(compKey)?.Acquisition_Contact__c);
        }
        return acqContactIds;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * @author - Priyanka Kanani (09/08/2023)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * Methode to Set executive on Acquisition Contact
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    jobCode              DESCRIPTION (Data type String, Strig Value of JobCode )
    * @param    isJobCodeBlank       DESCRIPTION (Data type SObject, Acquisition Contact record)
    * @param    updatedAcqContacts   DESCRIPTION (Data type List<SObject>, List of Acquisition Contact record Ids)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void setExecutiveOnAcqContact(String jobCode, Acquisition_Contacts__c acqContact, List<Acquisition_Contacts__c> updatedAcqContacts){
        Boolean isExecutivePrior = acqContact.Executive__c;
        Boolean isJobCodeBlank = String.isBlank(jobCode);

        if(isJobCodeBlank && isExecutivePrior) {
            acqContact.Executive__c = false;
        }else if(!isJobCodeBlank && !isExecutivePrior && Pattern.compile(EXECUTIVE_JOB_CODE_PATTERN).matcher(jobCode).find()) {
            acqContact.Executive__c = true;
        }else if(!isJobCodeBlank && isExecutivePrior && Pattern.compile(NON_EXECUTIVE_JOB_CODE_PATTERN).matcher(jobCode).find()) {
            acqContact.Executive__c = false;
        }
        if(isExecutivePrior != acqContact.Executive__c) {
            updatedAcqContacts.add(acqContact);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * @author - Priyanka Kanani (10/06/2023)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * Methode to Process Job code Change on Acquisition Contact
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    isJobCodeChanged     DESCRIPTION (Data type Boolean, Boolean to check job code change )
    * @param    jobCode              DESCRIPTION (Data type String, Job code value)
    * @param    acqContact           DESCRIPTION (Data type SObject, Acquisition Contact record to update)
    * @param    updatedAcqContacts   DESCRIPTION (Data type List<SObject>, List of Acquisition Contact record Ids to be updated)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void processJobCode(boolean isJobCodeChanged, String jobCode, Acquisition_Contacts__c acqContact, List<Acquisition_Contacts__c> updatedAcqContacts) {
        if (isJobCodeChanged) {
            setExecutiveOnAcqContact(jobCode, acqContact, updatedAcqContacts);
        }
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * @author - Priyanka Kanani (10/06/2023)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * Methode to Set Business Title on Acquisition Contact
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqContact           DESCRIPTION (Data type SObject, Acquisition Contact record)
    * @param    postingTitle         DESCRIPTION (Data type String, Strig Value of Posting Title )
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void processBusinessTitle(Acquisition_Contacts__c acqContact, String postingTitle) {
        // Business Title should auto-populate from Acquisition Compensation Posting Title Field if the Business Title fields are empty
        //Only upddate business title field when It's not null
        if (String.isBlank(acqContact.Business_Title__c) && !String.isBlank(postingTitle)) {
            acqContact.Business_Title__c = postingTitle;
        }
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * @author - Chakshu Malhotra (21/04/2022), Priyanka Kanani(09/08/2023)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * W-10995661 : Method to set Executive field on Acquisition Contact record on change of Job Code in compensation.
    * W-13871347 : Modified Methode to set Businesstitle and PayRateType on Acquisition Contact record on change of JobProfileTitle and PayRateType in compensation.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    isNew           DESCRIPTION (Data type Boolean, value of Trigger.isInsert)
    * @param    newAcqCompMap   DESCRIPTION (Data type Map<Id, Acquisition_Compensation__c>, Map of new Acquisition Compensation records)
    * @param    oldAcqCompMap   DESCRIPTION (Data type Map<Id, Acquisition_Compensation__c>, Map of old Acquisition Compensation records)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void updateFieldsOnAcqContact(Boolean isNew, Map<Id, Acquisition_Compensation__c> newAcqCompMap, Map<Id, Acquisition_Compensation__c> oldAcqCompMap) {
        List<Acquisition_Contacts__c> updatedAcqContacts = new List<Acquisition_Contacts__c>();
        Map<Id, Acquisition_Contacts__c> acqContactMap = getNewAcquisitionContactMap(newAcqCompMap);
    
        for (Id acqCompId : newAcqCompMap.keySet()) {
            processAcquisitionCompensation(acqCompId, isNew, oldAcqCompMap, newAcqCompMap, updatedAcqContacts, acqContactMap);
        }
    
        if (updatedAcqContacts.size() > 0) {
            Database.update(updatedAcqContacts, false);
        }
    }
    
    private static void processAcquisitionCompensation(Id acqCompId, Boolean isNew, Map<Id, Acquisition_Compensation__c> oldAcqCompMap, Map<Id, Acquisition_Compensation__c> newAcqCompMap, List<Acquisition_Contacts__c> updatedAcqContacts, Map<Id, Acquisition_Contacts__c> acqContactMap) {
        Acquisition_Compensation__c newAcqComp = newAcqCompMap.get(acqCompId);
        Id acqContactId = newAcqComp.Acquisition_Contact__c;
    
        if (acqContactId != null && acqContactMap.containsKey(acqContactId)) {
            Acquisition_Contacts__c acqContact = acqContactMap.get(acqContactId);
    
            boolean isJobCodeChanged = isNew || (oldAcqCompMap != null && newAcqComp.Job_Code__c != oldAcqCompMap.get(acqCompId).Job_Code__c);
            boolean isPayRateChanged = isNew || (oldAcqCompMap != null && newAcqComp.Pay_Rate_Type__c != oldAcqCompMap.get(acqCompId).Pay_Rate_Type__c);
    
            processJobCode(isJobCodeChanged, newAcqComp.Job_Code__c, acqContact, updatedAcqContacts);
            processBusinessTitle(acqContact, newAcqComp.Posting_Title__c);
    
            if (isPayRateChanged) {
                acqContact.Pay_Rate_Type__c = String.isBlank(newAcqComp.Pay_Rate_Type__c) ? '' : newAcqComp.Pay_Rate_Type__c;
            }
    
            if (!updatedAcqContacts.contains(acqContact)) {
                updatedAcqContacts.add(acqContact);
            }
        }
    }

    private static Set<Id> acqContactWithDuplicateCompRecords {
        get {
            if(acqContactWithDuplicateCompRecords == null) {
                acqContactWithDuplicateCompRecords = new Set<Id>();
            }
            return acqContactWithDuplicateCompRecords;
        }set;
    }

    private static Set<Id> acqContactIds {
        get {
            if(acqContactIds == null) {
                acqContactIds = new Set<Id>();

                for(Acquisition_Compensation__c newRecord : (List<Acquisition_Compensation__c>)Trigger.new) {
                    if(acqContactIds.contains(newRecord.Acquisition_Contact__c)) {
                        acqContactWithDuplicateCompRecords.add(newRecord.Acquisition_Contact__c);
                    }
                    acqContactIds.add(newRecord.Acquisition_Contact__c);
                }
            }
            return acqContactIds;
        }set;
    }

    private static Map<Id, Acquisition_Contacts__c> acqContactMap {
        get {
            if(acqContactMap == null) {
                acqContactMap = new Map<Id, Acquisition_Contacts__c>([SELECT Id, MuleExtId__c FROM Acquisition_Contacts__c WHERE Id IN :acqContactIds]);
            }
            return acqContactMap;
        }set;
    }

    private static Map<Id, Set<Id>> acqContactIdToCompIdsMap {
        get {
            if(acqContactIdToCompIdsMap == null) {
                acqContactIdToCompIdsMap = new Map<Id, Set<Id>>();
                
                for(Acquisition_Compensation__c acqComp : [SELECT Id, Acquisition_Contact__c FROM Acquisition_Compensation__c WHERE Acquisition_Contact__c IN :acqContactIds]) {
                    Set<Id> acqCompIds = acqContactIdToCompIdsMap.containsKey(acqComp.Acquisition_Contact__c) ? acqContactIdToCompIdsMap.get(acqComp.Acquisition_Contact__c) : new Set<Id>();
                    acqCompIds.add(acqComp.Id);
                    acqContactIdToCompIdsMap.put(acqComp.Acquisition_Contact__c, acqCompIds);
                }
            }
            return acqContactIdToCompIdsMap;
        }set;
    }

    public static void handleBeforeTrigger(Boolean isInsert, List<Acquisition_Compensation__c> newRecords) {
        for(Acquisition_Compensation__c newRecord : newRecords) {
            updateMuleExtId(newRecord);
            setDefaultPostingTitle(newRecord);
            setDefaultPositionTitle(newRecord);
            addErrorIfDuplicate(isInsert, newRecord);
        }
    }

    private static void updateMuleExtId(Acquisition_Compensation__c newRecord) {
        if(newRecord.MuleExtId__c == null && acqContactMap.containskey(newRecord.Acquisition_Contact__c)){
            newRecord.MuleExtId__c = acqContactMap.get(newRecord.Acquisition_Contact__c).MuleExtId__c;
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * @author - Ashutosh Belwal (21/04/2022)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * W-12663830 : To set default values on update/insert of Acqisition Compensation
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newAcqCompLst   DESCRIPTION (Data type List<Acquisition_Compensation__c>, List of new Acquisition Compensation records)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void setDefaultPostingTitle(Acquisition_Compensation__c newRecord) {
        if(String.isBlank(newRecord.Posting_Title__c) && String.isNotBlank(newRecord.Position_Title__c)){
            newRecord.Posting_Title__c = newRecord.Position_Title__c;
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * @author - Ashutosh Belwal (21/04/2022)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * W-12663830 : To set default values on update/insert of Acqisition Compensation
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newAcqCompLst   DESCRIPTION (Data type List<Acquisition_Compensation__c>, List of new Acquisition Compensation records)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void setDefaultPositionTitle(Acquisition_Compensation__c newRecord) {
        if(String.isBlank(newRecord.Position_Title__c) && String.isNotBlank(newRecord.Job_Profile_Title__c)){
            newRecord.Position_Title__c = newRecord.Job_Profile_Title__c;
        }
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * @author - Priyanka Kanani (11/01/2024)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * W-14791250 : Method to check duplicate Compenstion recod with same Acquisition Contacts
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newAcqCompMap    DESCRIPTION (Data type List<Acquisition_Compensation__c>, List of new Acquisition Compensation records)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void addErrorIfDuplicate(Boolean isInsert, Acquisition_Compensation__c newRecord) {
        Integer totalAcqComp = acqContactIdToCompIdsMap.containsKey(newRecord.Acquisition_Contact__c) ? acqContactIdToCompIdsMap.get(newRecord.Acquisition_Contact__c).size() : 0;
        Boolean isDuplicate = acqContactWithDuplicateCompRecords.contains(newRecord.Acquisition_Contact__c) ||
                              (totalAcqComp > 0 && (isInsert || totalAcqComp > 1 || !acqContactIdToCompIdsMap.get(newRecord.Acquisition_Contact__c).contains(newRecord.Id)));
        if(isDuplicate) {
            newRecord.addError(DUPLICATE_COMP_ERROR_MSG);
        }
    }
}