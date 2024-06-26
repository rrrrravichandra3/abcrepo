/**
 * W-10702588
 * EnrolmentService implementation to auto-enrol acquisition contacts to acquisition company tasks.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         24/02/2022      Chakshu Malhotra        Holds Queueable chaining logic to auto-enrol (upsert / delete AC Child Tasks) acquisition contacts to acquisition company tasks.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public class MA_AcqCompanyTaskEnrolmentService implements MA_AutoEnrolment.EnrolmentService {

    public MA_AcqCompanyTaskEnrolmentService() {
        // default constructor : for dynamic instance creation in MA_AutoEnrolment
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method inititates the auto-enrolment of the acquisition contacts to acquisition company tasks.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    autoEnrolmentEvents 	   DESCRIPTION (Data type List, List of Auto Enrolment Platform Event records)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void autoEnrol(List<MA_Auto_Enrolment_Event__e> autoEnrolmentEvents) {
        Map<Id, Set<String>> compIdToContactIdsMap = getCompanyIdToContactIdsMap(autoEnrolmentEvents);
        List<AggregateResult> companyIdToTaskCountAggList = getCompanyIdToTaskCountAggList(compIdToContactIdsMap.keySet());
        MA_AcqCompanyTaskEnrolWrapper.AutoEnrolStateful statefulInstance = getTaskAutoEnrolStatefulInstance(companyIdToTaskCountAggList, compIdToContactIdsMap);
        
        if(statefulInstance.totalCompanies > 0) {
            MA_AcqCompanyTaskEnroller.getTaskEnrollerStrategy().execute(statefulInstance, MA_AcqCompanyTaskEnroller.TASK_EXECUTION_MODE.AUTO_ENROL);
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
    * Method to get aggregate result list based on Acquisition Company Id to count of acquisition company tasks.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyIds 	   	    DESCRIPTION (Data type Set<Id>, Set of Acquisition Company Ids)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<AggregateResult> getCompanyIdToTaskCountAggList(Set<Id> acqCompanyIds) {
        return [SELECT Acquisition_Company__c, COUNT(Id) taskCount 
                FROM Acquisition_Company_Task__c 
                WHERE Last_Processed_Date__c != null AND
                Acquisition_Company__c IN :acqCompanyIds 
                GROUP BY Acquisition_Company__c
                HAVING COUNT(Id) > 0];
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create instance of AutoEnrolStateful wrapper based on company to task count aggregated result & Acquisition Contact Ids.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    companyIdToTaskCountAggList     DESCRIPTION (Data type List<AggregateResult>, Company Id to Task count aggregate result list)
    * @param    compIdToContactIdsMap 	   	    DESCRIPTION (Data type Map<Id, Set<String>>, Company Id to Acq Contact Ids Map)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static MA_AcqCompanyTaskEnrolWrapper.AutoEnrolStateful getTaskAutoEnrolStatefulInstance(List<AggregateResult> companyIdToTaskCountAggList, Map<Id, Set<String>> compIdToContactIdsMap) {
        List<MA_AcqCompanyTaskEnrolWrapper.AutoEnrolTaskWrapper> taskWrapperList = new List<MA_AcqCompanyTaskEnrolWrapper.AutoEnrolTaskWrapper>();
		system.debug('companyIdToTaskCountAggList***. '+companyIdToTaskCountAggList);
        for(AggregateResult companyIdToTaskCountAgg : companyIdToTaskCountAggList) {
            MA_AcqCompanyTaskEnrolWrapper.AutoEnrolTaskWrapper taskWrapper = new MA_AcqCompanyTaskEnrolWrapper.AutoEnrolTaskWrapper();
            taskWrapper.currentCount = 0;
            taskWrapper.totalCompanyTasks = (Integer)companyIdToTaskCountAgg.get('taskCount');
            taskWrapper.companyId = (Id)companyIdToTaskCountAgg.get('Acquisition_Company__c');
            taskWrapper.acqContactIds = compIdToContactIdsMap.get(taskWrapper.companyId);
            taskWrapperList.add(taskWrapper);
        }

        return getTaskAutoEnrolStatefulInstance(taskWrapperList);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create instance of AutoEnrolStateful wrapper based on List of MA_AcqCompanyTaskEnrolWrapper.AutoEnrolTaskWrapper type.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    taskWrapperList     DESCRIPTION (Data type List, List of MA_AcqCompanyTaskEnrolWrapper.AutoEnrolTaskWrapper type)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static MA_AcqCompanyTaskEnrolWrapper.AutoEnrolStateful getTaskAutoEnrolStatefulInstance(List<MA_AcqCompanyTaskEnrolWrapper.AutoEnrolTaskWrapper> taskWrapperList) {
        MA_AcqCompanyTaskEnrolWrapper.AutoEnrolStateful statefulInstance = new MA_AcqCompanyTaskEnrolWrapper.AutoEnrolStateful();
        statefulInstance.currentCount = 0;
        statefulInstance.taskWrapperList = taskWrapperList;
        statefulInstance.totalCompanies = taskWrapperList.size();
        return statefulInstance;
    }
}