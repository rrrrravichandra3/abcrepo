/**
 * W-10449458
 * EnrolmentService implementation to auto-enrol acquisition contacts to community events.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         24/02/2022      Chakshu Malhotra        Executes Queueable chaining logic to auto-enrol (upsert / delete attendees) acquisition contacts to community events.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public class MA_CommunityEventEnrolmentService implements MA_AutoEnrolment.EnrolmentService {
    
    public MA_CommunityEventEnrolmentService() {
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
        Map<Id, Set<String>> compIdToContactIdsMap = getCompanyIdToContactIdsMap(autoEnrolmentEvents);
        List<AggregateResult> companyToEventCountAggList = getCompanyIdToEventCountAggList(compIdToContactIdsMap.keySet());
        MA_CommunityEventAutoEnroller.StatefulQueueable statefulInstance = getEventAutoEnrolStatefulInstance(companyToEventCountAggList, compIdToContactIdsMap);
        
        if(statefulInstance.totalCompanies > 0) {
            MA_CommunityEventAutoEnroller.execute(statefulInstance);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method fetch Map of acquisition company Id to Set of acquisition contact Ids.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    autoEnrolmentEvents 	   DESCRIPTION (Data type List, List of Auto Enrolment Platform Event records)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<Id, Set<String>> getCompanyIdToContactIdsMap(List<MA_Auto_Enrolment_Event__e> autoEnrolmentEvents) {
        Map<Id, Set<String>> compIdToContactIdsMap = new Map<Id, Set<String>>();

        for(MA_Auto_Enrolment_Event__e autoEnrolmentEvent : autoEnrolmentEvents) {
            String acqContactIdsStr = autoEnrolmentEvent.Acquisition_Contact_Ids__c;
            Id acqCompanyId = Id.valueOf(autoEnrolmentEvent.Acquisition_Company_Id__c);

            Set<String> acqContactIds = compIdToContactIdsMap.containsKey(acqCompanyId) ? compIdToContactIdsMap.get(acqCompanyId) : new Set<String>();
            
            if(String.isNotBlank(acqContactIdsStr)) {
                acqContactIds.addAll(acqContactIdsStr.split(';'));
            }

            compIdToContactIdsMap.put(acqCompanyId, acqContactIds);
        }

        return compIdToContactIdsMap;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get aggregate result list based on Acquisition Company Id to count of community events.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyIds 	   	    DESCRIPTION (Data type Set<Id>, Set of Acquisition Company Ids)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @TestVisible
    private static List<AggregateResult> getCompanyIdToEventCountAggList(Set<Id> acqCompanyIds) {
        return [SELECT Acquisition_Company__c, COUNT(Id) eventCount 
                FROM MA_Community_Events__c 
                WHERE Last_Processed_Date__c != null AND
                Acquisition_Company__c IN :acqCompanyIds 
                GROUP BY Acquisition_Company__c
                HAVING COUNT(Id) > 0];
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create instance of StatefulQueueable wrapper based on company to event count aggregated result & Acquisition Contact Ids.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    companyToEventCountAggList 	 DESCRIPTION (Data type List<AggregateResult>, Company Id to Event count aggregate result list)
    * @param    compIdToContactIdsMap 	   	 DESCRIPTION (Data type Map<Id, Set<String>>, Company Id to Acq Contact Ids Map)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @TestVisible
    private static MA_CommunityEventAutoEnroller.StatefulQueueable getEventAutoEnrolStatefulInstance(List<AggregateResult> companyToEventCountAggList, Map<Id, Set<String>> compIdToContactIdsMap) {
        List<MA_CommunityEventAutoEnroller.AutoEnrolEventWrapper> eventWrapperList = new List<MA_CommunityEventAutoEnroller.AutoEnrolEventWrapper>();
        
        for(AggregateResult companyToEventCountAgg : companyToEventCountAggList) {
            MA_CommunityEventAutoEnroller.AutoEnrolEventWrapper eventWrapper = new MA_CommunityEventAutoEnroller.AutoEnrolEventWrapper();
            eventWrapper.currentCount = 0;
            eventWrapper.totalEvents = (Integer)companyToEventCountAgg.get('eventCount');
            eventWrapper.companyId = (Id)companyToEventCountAgg.get('Acquisition_Company__c');
            eventWrapper.acqContactIds = compIdToContactIdsMap.get(eventWrapper.companyId);
            eventWrapperList.add(eventWrapper);
        }

        return getEventAutoEnrolStatefulInstance(eventWrapperList);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create instance of StatefulQueueable wrapper based on List of MA_CommunityEventAutoEnroller.AutoEnrolEventWrapper type.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    eventWrapperList     DESCRIPTION (Data type List, List of MA_CommunityEventAutoEnroller.AutoEnrolEventWrapper type)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @TestVisible
    private static MA_CommunityEventAutoEnroller.StatefulQueueable getEventAutoEnrolStatefulInstance(List<MA_CommunityEventAutoEnroller.AutoEnrolEventWrapper> eventWrapperList) {
        MA_CommunityEventAutoEnroller.StatefulQueueable statefulInstance = new MA_CommunityEventAutoEnroller.StatefulQueueable();
        statefulInstance.currentCount = 0;
        statefulInstance.eventWrapperList = eventWrapperList;
        statefulInstance.totalCompanies = eventWrapperList.size();
        return statefulInstance;
    }
}