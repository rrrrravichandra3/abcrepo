/**
 * W-10995807, W-11054257
 * EnrolmentService implementation to auto-enrol wayfinder community users to company / targetted video content.
 * 
 * Version      Date            Author                  Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         28/04/2022      Priyanka Kanani         Executes Queueable logic to auto-enrol (upsert / delete GroupMember) community users to company / targetted video content.
 * v2.0         10/05/2022      Chakshu Malhotra        Updates the enrolment service class to call MA_ContentAutoEnroller to execute auto enrolment for company / targetted video content.
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public class MA_CommunityVideoEnrolmentService implements MA_AutoEnrolment.EnrolmentService {

    private static final String CONTACT_STATUS_CANCELLED = Label.MA_Contact_Status_Cancelled;

    public MA_CommunityVideoEnrolmentService() {
         // default constructor : for dynamic instance creation in MA_AutoEnrolment
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method inititates the auto-enrolment of the acquisition contacts to community events.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    autoEnrolmentEvents 	   DESCRIPTION (Data type List, List of Auto Enrolment Platform Event records)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void autoEnrol(List<MA_Auto_Enrolment_Event__e> autoEnrolmentEvents) {
        Set<Id> acqCompanyIds = new Set<Id>();
        Set<String> acqContactIds = getAcqContactIds(acqCompanyIds, autoEnrolmentEvents);
        MA_ContentAutoEnroller.ContentEnrolStateful statefulInstance = getContentAutoEnrolStatefulInstance(acqCompanyIds, acqContactIds);
        MA_ContentAutoEnroller.execute(statefulInstance);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get set of AcquisitionContactIds From autoEnrolmentEvents
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyIds 	   	    DESCRIPTION (Data type Set<Id>, Set of Acquisition Company record Ids)
    * @param    autoEnrolmentEvents     DESCRIPTION (Data type List<MA_Auto_Enrolment_Event__e>, List of MA_Auto_Enrolment_Event__e)
    * @return   Set<String>             DESCRIPTION (return Set of Acquisition Company record Ids)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Set<String> getAcqContactIds(Set<Id> acqCompanyIds, List<MA_Auto_Enrolment_Event__e> autoEnrolmentEvents) {
        Set<String> acqContactIds = new Set<String>();

        for(MA_Auto_Enrolment_Event__e autoEnrolmentEvent : autoEnrolmentEvents) {
            String acqContactIdsStr = autoEnrolmentEvent.Acquisition_Contact_Ids__c;
            if(String.isNotBlank(acqContactIdsStr)) {
                acqContactIds.addAll(acqContactIdsStr.split(';'));
                acqCompanyIds.add(Id.valueOf(autoEnrolmentEvent.Acquisition_Company_Id__c));
            }
        }

        return acqContactIds;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create instance of ContentEnrolStateful wrapper based on set of Acquisition Company Ids & Acquisition Contact Ids.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyIds 	                                DESCRIPTION (Data type Set<Id>, Set of Acquisition Company Ids)
    * @param    acqContactIds                                   DESCRIPTION (Data type Set<Id>, Set of Acquisition Contact Ids)
    * @return   MA_ContentAutoEnroller.ContentEnrolStateful     DESCRIPTION (return instance of MA_ContentAutoEnroller.ContentEnrolStateful)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static MA_ContentAutoEnroller.ContentEnrolStateful getContentAutoEnrolStatefulInstance(Set<Id> acqCompanyIds, Set<String> acqContactIds) {
        MA_ContentAutoEnroller.ContentEnrolStateful statefulInstance = new MA_ContentAutoEnroller.ContentEnrolStateful();
        statefulInstance.acqContactIds = acqContactIds;
        statefulInstance.currentGroupIdIndex = 0;
        statefulInstance.contentPermissionFields = MA_ContentEnrolmentHelper.getContentPermissionFields();

        Set<Id> contentPublicGroupIds = MA_ContentEnrolmentHelper.getCompanyContentPublicGroupIds(acqCompanyIds);
        statefulInstance.groupIdToFieldNameMap = MA_ContentEnrolmentHelper.getGroupIdToFieldNameMap(acqCompanyIds);
        
        contentPublicGroupIds.addAll(statefulInstance.groupIdToFieldNameMap.keySet());
        statefulInstance.groupIds = new List<Id>(contentPublicGroupIds);

        return statefulInstance;
    }
}