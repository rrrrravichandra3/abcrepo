/**
 * W-11054257
 * Helper class to fetch data categories & enrol community users to community videos by sharing video records 
 * with targetted public groups.
 * 
 * Version      Date            Author                  Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         05-05-2022      Chakshu Malhotra        Holds Queueable chaining logic to enrol or remove community users from company wide or targeted content.
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_ContentEnroller {
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to create & pass serialized state of content enrolment across recursively chained queueable jobs.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    class ContentEnrolStateful {
        private Queueable nextJob {get; set;}
        private List<User> eligibleUsers {get; set;}
        private Integer totalEligibleUsers {get; set;}
        private Integer totalRecordsQueried {get; set;}
        private Integer queryThresholdLimit {get; set;}
        private Id lastEligibleUserRecordId {get; set;}
        private Id companyContentSharingGroupId {get; set;}
        private Set<String> contentPermissionFields {get; set;}
        private Map<String, Id> fieldNameToGroupIdMap {get; set;}
        private Map<Id, Acquisition_Company__c> companyMap {get; set;}
    }

    private static ContentEnrolStateful statefulInstance;

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create & return instance of ContentEnrolStateful.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   ContentEnrolStateful       DESCRIPTION (return instance of ContentEnrolStateful)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static ContentEnrolStateful getContentEnrolStateful() {
        if(statefulInstance == null) {
            statefulInstance = new ContentEnrolStateful();
            statefulInstance.nextJob = null;
            statefulInstance.totalEligibleUsers = 0;
            statefulInstance.totalRecordsQueried = 0;
            statefulInstance.queryThresholdLimit = 100;
            statefulInstance.lastEligibleUserRecordId = null;
            statefulInstance.companyContentSharingGroupId = null;
            statefulInstance.eligibleUsers = new List<User>();
            statefulInstance.contentPermissionFields = new Set<String>();
            statefulInstance.fieldNameToGroupIdMap = new Map<String, Id>();
            statefulInstance.companyMap = new Map<Id, Acquisition_Company__c>();
        }
        return statefulInstance;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initialize instance of ContentEnrolStateful.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    company                         DESCRIPTION (Data type Acquisition_Company__c, Acquisition Company record)
    * @param    companyContentSharingGroupId    DESCRIPTION (Data type String, Public group Id for company content sharing)
    * @param    company                         DESCRIPTION (Data type List, List of MA_Knowledge_Article_Permissions__c records)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void initContentEnrolment(Acquisition_Company__c company, String companyContentSharingGroupId, List<MA_Knowledge_Article_Permissions__c> contentPermissions) {
        ContentEnrolStateful statefulInstance = getContentEnrolStateful();
        statefulInstance.companyMap.put(company.Id, company);
        statefulInstance.companyContentSharingGroupId = Id.valueOf(companyContentSharingGroupId);
        statefulInstance.contentPermissionFields.addAll(MA_ContentEnrolmentHelper.getContentPermissionFields());
        statefulInstance.fieldNameToGroupIdMap.putAll(MA_ContentEnrolmentHelper.getFieldNameToGroupIdMap(contentPermissions));
        statefulInstance.totalEligibleUsers = MA_ContentEnrolmentHelper.getEligibleUserCount(statefulInstance.companyMap.keySet());
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to process content enrolment; enqueues EnrolUsers job.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    nextJob        DESCRIPTION (Data type Queueable, Next Job (MA Messaging) to be executed upon completion of processing)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void processContentEnrolment(Queueable nextJob) {
        ContentEnrolStateful statefulInstance = getContentEnrolStateful();
        statefulInstance.nextJob = nextJob;
        system.debug('statefulInstance***  '+statefulInstance);
        enqueueEnrolUsersJob(statefulInstance);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to enqueue EnrolUsers job to process content enrolment.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    statefulInstance        DESCRIPTION (Data type ContentEnrolStateful, Serialized state of queueable job)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void enqueueEnrolUsersJob(ContentEnrolStateful statefulInstance) {
        enqueueJob(new EnrolUsers(statefulInstance, EnrolUsersFinalizer.class));
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to enqueue the queueable job if it's within governor limits.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    asyncJob        DESCRIPTION (Data type Queueable, Queueable job instance)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void enqueueJob(Queueable asyncJob) {
       /* if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
            System.enqueueJob(asyncJob);
        }*/
        MA_QueueableUtil.execute(asyncJob);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable implementation to fetch eligible users of an acquisition company and enrols them for company content (video sharing).
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    class EnrolUsers implements Queueable {
        private ContentEnrolStateful jobParams;
        private Type queueableFinalizerImpl;

        private EnrolUsers(ContentEnrolStateful jobParams, Type queueableFinalizerImpl) {
            this.jobParams = jobParams;
            this.queueableFinalizerImpl = queueableFinalizerImpl;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Queueable interface method to create GroupMember records to enrol eligible users to company content (video sharing).
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    qContext    DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void execute(QueueableContext qContext) {
            Set<Id> companyIds = jobParams.companyMap.keySet();

            jobParams.eligibleUsers.addAll(MA_ContentEnrolmentHelper.getEligibleUsers(companyIds, jobParams.contentPermissionFields, jobParams.lastEligibleUserRecordId, jobParams.queryThresholdLimit));
            jobParams.totalRecordsQueried += jobParams.eligibleUsers.size();

            List<GroupMember> enrolledGroupMembers = new List<GroupMember>();
			system.debug('eligibleUsers***. '+jobParams.eligibleUsers);
            for(User eligibleUser : jobParams.eligibleUsers) {
                enrolledGroupMembers.addAll(MA_ContentEnrolmentHelper.getEnrolledGroupMembers(eligibleUser, jobParams.companyContentSharingGroupId, jobParams.fieldNameToGroupIdMap));
            }

            if(!enrolledGroupMembers.isEmpty()) {
                MA_ContentEnrolmentHelper.bulkUpsertEnrolledGroupMembers(enrolledGroupMembers);
            }

            QueueableFinalizer queueableFinalizer = (QueueableFinalizer)queueableFinalizerImpl.newInstance();

            if(jobParams.totalRecordsQueried < jobParams.totalEligibleUsers && !jobParams.eligibleUsers.isEmpty()) {
                queueableFinalizer.handleSingleJobCompletion(jobParams);
            }else {
                queueableFinalizer.handleAllJobsCompletion(jobParams);
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Interface to attach final action to queuable execution for each chained job as well as completion of all chained jobs.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private interface QueueableFinalizer {
        void handleAllJobsCompletion(ContentEnrolStateful jobParams);
        void handleSingleJobCompletion(ContentEnrolStateful jobParams);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Abstract class to provide QueueableFinalizer implementation & common logic for its sub-classes.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private abstract class AbstractQueueableFinalizer implements QueueableFinalizer {
        public abstract void handleAllJobsCompletion(ContentEnrolStateful jobParams);
        public abstract void handleSingleJobCompletion(ContentEnrolStateful jobParams);

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to reset some parameters before re-enqueuing the job.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams    DESCRIPTION (Data type StatefulQueueable, Serialized state of queueable job)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        protected void resetJobParams(ContentEnrolStateful jobParams) {
            if(!jobParams.eligibleUsers.isEmpty()) {
                jobParams.lastEligibleUserRecordId = jobParams.eligibleUsers[jobParams.eligibleUsers.size() - 1].Id;
                jobParams.eligibleUsers.clear();
            }
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to enqueue Next Job (may need to enqueue the source job instance with different parameters) upon completion of all jobs.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams    DESCRIPTION (Data type StatefulQueueable, Serialized state of queueable job)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        protected void enqueueNextJob(ContentEnrolStateful jobParams) {
            if(jobParams.nextJob != null) {
                MA_ContentEnroller.enqueueJob(jobParams.nextJob);
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Sub-class of AbstractQueueableFinalizer to provide QueueableFinalizer implementation for EnrolUsersFinalizer queueable job.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class EnrolUsersFinalizer extends AbstractQueueableFinalizer {
        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on each single job completion; enqueues a EnrolUsers job to process content enrolment for eligible users.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams    DESCRIPTION (Data type Stateful, Serialized state of queueable job)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleSingleJobCompletion(ContentEnrolStateful jobParams) {
            super.resetJobParams(jobParams);
            MA_ContentEnroller.enqueueEnrolUsersJob(jobParams);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on all jobs completion.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams    DESCRIPTION (Data type Stateful, Serialized state of queueable job)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleAllJobsCompletion(ContentEnrolStateful jobParams) {
            super.enqueueNextJob(jobParams);
        }
    }
}