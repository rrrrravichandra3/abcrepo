/**
 * W-10995807, W-11054257
 * Abstract class to auto-enrol or remove community users from events using Queueable chaining logic.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         05-05-2022      Chakshu Malhotra        Holds Queueable chaining logic to auto-enrol or remove community users from company wide or targeted content.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_ContentAutoEnroller {
    @TestVisible private static Boolean testJobEnqueued = false;
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to create & pass serialized state of content enrolment across recursively chained queueable jobs.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class ContentEnrolStateful {
        public List<Id> groupIds {get; set;}
        public Set<String> acqContactIds {get; set;}
        public Integer currentGroupIdIndex {get; set;}
        public Set<String> contentPermissionFields {get; set;}
        public Map<Id, String> groupIdToFieldNameMap {get; set;}
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to enqueue EnrolUsers job to process content enrolment.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    statefulInstance        DESCRIPTION (Data type ContentEnrolStateful, Serialized state of queueable job)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void execute(ContentEnrolStateful statefulInstance) {
        if(statefulInstance.currentGroupIdIndex < statefulInstance.groupIds.size()) {
            enqueueJob(new EnrolUsers(statefulInstance, EnrolUsersFinalizer.class));
        }
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
        if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
            System.enqueueJob(asyncJob);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable implementation to fetch eligible users of an acquisition company and auto-enrols them for company & targeted content.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    class EnrolUsers implements Queueable {
        private ContentEnrolStateful jobParams;
        private Type queueableFinalizerImpl;

        private List<GroupMember> purgedGroupMembers;
        private List<GroupMember> enrolledGroupMembers;

        private EnrolUsers() {
            this.purgedGroupMembers = new List<GroupMember>();
            this.enrolledGroupMembers = new List<GroupMember>();
        }

        private EnrolUsers(ContentEnrolStateful jobParams, Type queueableFinalizerImpl) {
            this();
            this.jobParams = jobParams;
            this.queueableFinalizerImpl = queueableFinalizerImpl;
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Queueable interface method to create GroupMember records to auto-enrol eligible users to company content.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    qContext    DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void execute(QueueableContext qContext) {
            Id currentGroupId = jobParams.groupIds[jobParams.currentGroupIdIndex];
            Map<Id, User> eligibleUserMap = MA_ContentEnrolmentHelper.getEligibleUserMap(jobParams.acqContactIds, jobParams.contentPermissionFields);
            Map<String, GroupMember> compositeKeyToGroupMemberMap = MA_ContentEnrolmentHelper.getCompositeKeyToGroupMemberMap(currentGroupId, eligibleUserMap.keySet());

            for(User eligibleUser : eligibleUserMap.values()) {
                setEnrolledAndPurgedGroupMembers(currentGroupId, eligibleUser, compositeKeyToGroupMemberMap);
            }

            processEnrolledAndPurgedGroupMembers();
            jobParams.currentGroupIdIndex++;

            QueueableFinalizer queueableFinalizer = (QueueableFinalizer)queueableFinalizerImpl.newInstance();

            if(jobParams.currentGroupIdIndex < jobParams.groupIds.size()) {
                queueableFinalizer.handleSingleJobCompletion(jobParams);
            }
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to add new enrollees in enrolledGroupMembers list and adds the ones eligible to disenroll in purgedGroupMembers list.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    groupId                         DESCRIPTION (Data type Id, Public Group Id in process)
        * @param    eligibleUser                    DESCRIPTION (Data type User, User record to check the eligibility)
        * @param    compositeKeyToGroupMemberMap    DESCRIPTION (Data type Map, Map of public group Id to Field API Name)
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void setEnrolledAndPurgedGroupMembers(Id groupId, User eligibleUser, Map<String, GroupMember> compositeKeyToGroupMemberMap) {
            String compositeKey = String.valueOf(groupId) + String.valueOf(eligibleUser.Id);
            Boolean containsCompositeKey = compositeKeyToGroupMemberMap.containsKey(compositeKey);

            if(MA_ContentEnrolmentHelper.isNewAutoEnrollee(containsCompositeKey, groupId, eligibleUser, jobParams.groupIdToFieldNameMap)) {
                enrolledGroupMembers.add(MA_ContentEnrolmentHelper.getEnrolledGroupMember(eligibleUser.Id, groupId));
            }else if(MA_ContentEnrolmentHelper.isEligibleToDisenroll(containsCompositeKey, groupId, eligibleUser, jobParams.groupIdToFieldNameMap)) {
                purgedGroupMembers.add(compositeKeyToGroupMemberMap.get(compositeKey));
            }
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to bulk upsert new enrollees in enrolledGroupMembers list and bulk deletes the ones in purgedGroupMembers list.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void processEnrolledAndPurgedGroupMembers() {
            if(!enrolledGroupMembers.isEmpty()) {
                MA_ContentEnrolmentHelper.bulkUpsertEnrolledGroupMembers(enrolledGroupMembers);
            }

            if(!purgedGroupMembers.isEmpty()) {
                MA_ContentEnrolmentHelper.bulkDeleteEnrolledGroupMembers(purgedGroupMembers);
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
            if(!testJobEnqueued){
                MA_ContentAutoEnroller.execute(jobParams);
            }
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
            // TODO : handles logic on completion of all jobs
        }
    }
}