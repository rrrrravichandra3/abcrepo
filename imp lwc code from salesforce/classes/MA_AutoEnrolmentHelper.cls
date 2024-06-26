/**
 * W-10449458 / W-10678114 / W-10702588
 * Class to filter acquisition contacts & create MA_Auto_Enrolment_Event__e records for each Enrolment Type.
 * 
 * Version      Date            Author                  Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         24/02/2022      Chakshu Malhotra        Provides logic to create MA_Auto_Enrolment_Event__e records for each Enrolment Type.
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_AutoEnrolmentHelper {

    public enum EnrolmentSource {CONTACT_UPDATE, PROVISIONING_UPDATE, COMPENSATION_UPDATE, USER_CREATION}

    private static final String DISABLE_AUTO_ENROLMENT_PERMISSION = Label.MA_DS_Disable_Auto_Enrolment_Permission;
    
    private static final String ENROLMENT_TYPE_AC_TASK = Label.MA_Enrolment_Type_AC_Task;
    private static final String ENROLMENT_TYPE_COMMUNITY_EVENT = Label.MA_Enrolment_Type_Community_Event;
    private static final String ENROLMENT_TYPE_COMMUNITY_VIDEO = Label.MA_Enrolment_Type_Community_Video;
    private static final String ENROLMENT_TYPE_DATA_CATEGORY_PERM_SET = Label.MA_Enrolment_Type_Data_Category_Perm_Set;
    private static final List<String> ACTIVE_ACQUISITION_COMPANY_STATUS = Label.MA_Event_Active_Company_Status.split(';');

    private static Boolean autoEnrolOnContactUpdate = false;
    private static Boolean autoEnrolOnProvisioningUpdate = false;
    private static Boolean autoEnrolOnCompensationUpdate = false;
    private static Boolean autoEnrolOnWayfinderUserCreation = false;

    private static Set<Id> enrolledAcqContactIds = new Set<Id>();
    public static Boolean DISABLED_AUTO_ENROLMENT_FRAMEWORK = false;

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to publish all enrolment type platform events.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqContactMap       DESCRIPTION (Data type Map, New record map of acquisition contacts)
    * @param    enrolmentSource     DESCRIPTION (Data type MA_AutoEnrolmentHelper.EnrolmentSource, Source of auto-enrolment)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void publishAutoEnrolmentPlatformEvents(Map<Id, Acquisition_Contacts__c> acqContactMap, MA_AutoEnrolmentHelper.EnrolmentSource enrolmentSource) {
        if(!DISABLED_AUTO_ENROLMENT_FRAMEWORK && !FeatureManagement.checkPermission(DISABLE_AUTO_ENROLMENT_PERMISSION)) {
            List<MA_Auto_Enrolment_Event__e> enrolmentEvents = new List<MA_Auto_Enrolment_Event__e>();
            Map<Id, Acquisition_Contacts__c> activeAcqContactMap = getActiveAndUniqueAcquisitionContactsMap(acqContactMap, enrolmentSource);

            if(!activeAcqContactMap.isEmpty()) {
                Map<Id, String> companyIdToAcqContactsMap = getCompanyIdToAcquisitionContactsMap(activeAcqContactMap.values());
                enrolmentEvents.addAll(getAutoEnrolmentEvents(companyIdToAcqContactsMap));
            }        

            if(!enrolmentEvents.isEmpty()) {
                EventBus.publish(enrolmentEvents);
            }
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * W-10449458 : Method to get active Acquisition Contact records.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqContactMap 	    DESCRIPTION (Data type Map<Id, Acquisition_Contacts__c>, Map of new Acquisition Contact records)
    * @param    enrolmentSource     DESCRIPTION (Data type MA_AutoEnrolmentHelper.EnrolmentSource, Source of auto-enrolment)
    * @return   Map                 DESCRIPTION (return Map of active Acquisition Contact Id to Acquisition Contact record)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<Id, Acquisition_Contacts__c> getActiveAndUniqueAcquisitionContactsMap(Map<Id, Acquisition_Contacts__c> acqContactMap, MA_AutoEnrolmentHelper.EnrolmentSource enrolmentSource) {
        Boolean isUserCreation = (enrolmentSource == MA_AutoEnrolmentHelper.EnrolmentSource.USER_CREATION);
        return isUserCreation ? acqContactMap : getActiveAndUniqueAcquisitionContactsMap(acqContactMap);
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * W-10449458 : Method to get active Acquisition Contact records.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqContactMap       DESCRIPTION (Data type Map<Id, Acquisition_Contacts__c>, Map of new Acquisition Contact records)
    * @return   Map                 DESCRIPTION (return Map of active Acquisition Contact Id to Acquisition Contact record)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<Id, Acquisition_Contacts__c> getActiveAndUniqueAcquisitionContactsMap(Map<Id, Acquisition_Contacts__c> acqContactMap) {
        Map<Id, Acquisition_Contacts__c> activeAcqContactMap = new Map<Id, Acquisition_Contacts__c>();
        
        for(User activeUser : [SELECT Id, Contact.Acquisition_Contacts__c, Contact.Acquisition_Contacts__r.Acquisition_Company__r.Status__c 
                               FROM User 
                               WHERE IsActive = true AND 
                               ContactId != null AND
                               Contact.Acquisition_Contacts__c IN :acqContactMap.keySet()]) {
                                   
                                   if(ACTIVE_ACQUISITION_COMPANY_STATUS.contains(activeUser.Contact.Acquisition_Contacts__r.Acquisition_Company__r.Status__c)){
                                       Id activeAcqContactId = activeUser.Contact.Acquisition_Contacts__c;
                                       if(!enrolledAcqContactIds.contains(activeAcqContactId)) {
                                           activeAcqContactMap.put(activeAcqContactId, acqContactMap.get(activeAcqContactId));
                                       }
                                   }
                                   
                               }
        
        return activeAcqContactMap;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create Map of acquisition company Id to semi-colon separated string of acquisition contact Ids.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqContacts 	  DESCRIPTION (Data type List<Acquisition_Contacts__c>, List of acquisition contact records)
    * @return   Map<Id, String>   DESCRIPTION (return Map of company Id to semi-colon separated string of acquisition contact Ids)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<Id, String> getCompanyIdToAcquisitionContactsMap(List<Acquisition_Contacts__c> acqContacts) {
        Map<Id, String> companyIdToAcqContactsMap = new Map<Id, String>();
        for(Acquisition_Contacts__c acqContact : acqContacts) {
            enrolledAcqContactIds.add(acqContact.Id);
            Boolean containsKey = companyIdToAcqContactsMap.containsKey(acqContact.Acquisition_Company__c);
            String acqContactStr = containsKey ? companyIdToAcqContactsMap.get(acqContact.Acquisition_Company__c) : '';
            acqContactStr += String.isBlank(acqContactStr) ? String.valueOf(acqContact.Id) : (';' + String.valueOf(acqContact.Id));
            companyIdToAcqContactsMap.put(acqContact.Acquisition_Company__c, acqContactStr);
        }
        return companyIdToAcqContactsMap;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create & return community event type enrolment events based on valid acquisition contacts.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    companyIdToAcqContactsMap       DESCRIPTION (Data type Map, Map of company Id to semi-colon separated string of acquisition contact Ids)
    * @return   List                            DESCRIPTION (return List of MA_Auto_Enrolment_Event__e)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<MA_Auto_Enrolment_Event__e> getAutoEnrolmentEvents(Map<Id, String> companyIdToAcqContactsMap) {
        List<MA_Auto_Enrolment_Event__e> enrolmentEvents = new List<MA_Auto_Enrolment_Event__e>();

        for(Id acqCompanyId : companyIdToAcqContactsMap.keySet()) {
            enrolmentEvents.add(getCommunityEventTypeEvent(acqCompanyId, companyIdToAcqContactsMap.get(acqCompanyId)));
            enrolmentEvents.add(getCompanyChildTaksTypeEvent(acqCompanyId, companyIdToAcqContactsMap.get(acqCompanyId)));
            enrolmentEvents.add(getDataCategoryPermSetTypeEvent(acqCompanyId, companyIdToAcqContactsMap.get(acqCompanyId)));
            enrolmentEvents.add(getCommunityUsersToVideoShareTypeEvent(acqCompanyId, companyIdToAcqContactsMap.get(acqCompanyId)));
        }

        return enrolmentEvents;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create & return Community Event type enrolment event.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId                    DESCRIPTION (Data type Id, Acquisition Company Id)
    * @param    acqContactIds                   DESCRIPTION (Data type String, Semi-colon separated string of acquisition contact Ids)
    * @return   MA_Auto_Enrolment_Event__e      DESCRIPTION (return instance of MA_Auto_Enrolment_Event__e)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static MA_Auto_Enrolment_Event__e getCommunityEventTypeEvent(Id acqCompanyId, String acqContactIds) {
        MA_Auto_Enrolment_Event__e enrolmentEvent = new MA_Auto_Enrolment_Event__e();
        enrolmentEvent.Acquisition_Company_Id__c = acqCompanyId;
        enrolmentEvent.Acquisition_Contact_Ids__c = acqContactIds;
        enrolmentEvent.Enrolment_Type__c = ENROLMENT_TYPE_COMMUNITY_EVENT;
        return enrolmentEvent;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * W-10702588 : Method to create & return AC Child Task type enrolment event.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId                    DESCRIPTION (Data type Id, Acquisition Company Id)
    * @param    acqContactIds                   DESCRIPTION (Data type String, Semi-colon separated string of acquisition contact Ids)
    * @return   MA_Auto_Enrolment_Event__e      DESCRIPTION (return instance of MA_Auto_Enrolment_Event__e)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static MA_Auto_Enrolment_Event__e getCompanyChildTaksTypeEvent(Id acqCompanyId, String acqContactIds) {
        MA_Auto_Enrolment_Event__e enrolmentEvent = new MA_Auto_Enrolment_Event__e();
        enrolmentEvent.Acquisition_Company_Id__c = acqCompanyId;
        enrolmentEvent.Acquisition_Contact_Ids__c = acqContactIds;
        enrolmentEvent.Enrolment_Type__c = ENROLMENT_TYPE_AC_TASK;
        return enrolmentEvent;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * W-10678114 : Method to create & return Data Category Perm Set type enrolment event.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId                    DESCRIPTION (Data type Id, Acquisition Company Id)
    * @param    acqContactIds                   DESCRIPTION (Data type String, Semi-colon separated string of acquisition contact Ids)
    * @return   MA_Auto_Enrolment_Event__e      DESCRIPTION (return instance of MA_Auto_Enrolment_Event__e)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static MA_Auto_Enrolment_Event__e getDataCategoryPermSetTypeEvent(Id acqCompanyId, String acqContactIds) {
        MA_Auto_Enrolment_Event__e enrolmentEvent = new MA_Auto_Enrolment_Event__e();
        enrolmentEvent.Acquisition_Company_Id__c = acqCompanyId;
        enrolmentEvent.Acquisition_Contact_Ids__c = acqContactIds;
        enrolmentEvent.Enrolment_Type__c = ENROLMENT_TYPE_DATA_CATEGORY_PERM_SET;
        return enrolmentEvent;
    }
    
    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * W-10678114 : Method to create & return CommunityUsersforVideoSharing type enrolment event.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId                    DESCRIPTION (Data type Id, Acquisition Company Id)
    * @param    acqContactIds                   DESCRIPTION (Data type String, Semi-colon separated string of acquisition contact Ids)
    * @return   MA_Auto_Enrolment_Event__e      DESCRIPTION (return instance of MA_Auto_Enrolment_Event__e)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static MA_Auto_Enrolment_Event__e getCommunityUsersToVideoShareTypeEvent(Id acqCompanyId, String acqContactIds) {
        MA_Auto_Enrolment_Event__e enrolmentEvent = new MA_Auto_Enrolment_Event__e();
        enrolmentEvent.Acquisition_Company_Id__c = acqCompanyId;
        enrolmentEvent.Acquisition_Contact_Ids__c = acqContactIds;
        enrolmentEvent.Enrolment_Type__c = ENROLMENT_TYPE_COMMUNITY_VIDEO;
        return enrolmentEvent;
    }
}