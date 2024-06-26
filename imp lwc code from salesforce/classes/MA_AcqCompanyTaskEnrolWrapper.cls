/**
 * W-10702588
 * Class to hold wrapper classes to hold details of MA_Auto_Enrolment_Event__e records & serialized state of task enrolment detail.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         24/02/2022      Chakshu Malhotra        Holds wrapper classes to hold details of MA_Auto_Enrolment_Event__e records & serialized state of task enrolment detail
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public class MA_AcqCompanyTaskEnrolWrapper {

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold batch configuration.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class TaskEnrollerConfig {
        public Id batchJobId {get; set;}
        public Integer batchSize {get; set;}
        public Integer dmlQueueableSize {get; set;}
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to create & pass serialized state of task enrolment detail across recursively instantiated queueable jobs.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class SelectEnrolStateful {
        public Integer curentDmlCount {get; set;}
        public Integer totalRecordCount {get; set;}
        public Set<Id> upsertAsyncJobIds {get; set;}
        public Integer totalRecordsQueried {get; set;}
        public TaskEnrollerConfig batchConfig {get; set;}
        public Acquisition_Company_Task__c task {get; set;}
        public List<Acquisition_Contacts__c> eligibleContactList {get; set;}
        public List<Acquisition_Contact_Task__c> deleteRecordList {get; set;}
        public MA_AcqCompanyTaskEnrollerHelper.DeleteContactTasks deleteContactTasks {get; set;}
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to create & pass serialized state of task enrolment detail across recursively instantiated queueable jobs.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class AutoEnrolStateful {
        public Integer currentCount {get; set;}
        public Integer totalCompanies {get; set;}
        public List<AutoEnrolTaskWrapper> taskWrapperList {get; set;}
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold details of MA_Auto_Enrolment_Event__e records.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class AutoEnrolTaskWrapper {
        public Id companyId {get; set;}
        public Integer currentCount {get; set;}
        public Integer totalCompanyTasks {get; set;}
        public Set<String> acqContactIds {get; set;}
        public List<Acquisition_Company_Task__c> companyTasks {get; set;}
    }
}