/**
 * @author Anchana Rajamathe
 * @date 06-26-2017
 * @group NHW
 * @description This class implements WDR_CommonTriggerHandler interface for NHW  specific logic as follows
 * 1.Populate Do Not Send NHW & NHW_Create_Preboarding_Case__c flags
 * 2.Create Preboarding case
 * 3.Create Candidate Contact
 */
@SuppressWarnings('PMD.CognitiveComplexity')
public without sharing class NHW_WDRJobApplicationTriggerHandler implements WDR_CommonTriggerHandler {
  public static Id NHWPreboardingRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('New_Hire_Process')
    .getRecordTypeId();
  public static map<id, WDR_Application__c> mJobAppsWithPreboardingFlagset = new Map<id, WDR_Application__c>();
  public static map<id, Boolean> mIncomingJobAppIdToHasPreboardingCase {
    get {
      //without sharing is needed on class, so that below query returns all the cases, regardless of current user
      if (mIncomingJobAppIdToHasPreboardingCase == null || mIncomingJobAppIdToHasPreboardingCase.size() == 0) {
        mIncomingJobAppIdToHasPreboardingCase = new Map<id, Boolean>();
        List<WDR_Application__c> JobApps = [
          SELECT
            Id,
            Start_Date__c,
            (
              SELECT Id, NHW_Job_Application__c
              FROM Cases__r
              WHERE
                origin = 'NHW'
                AND recordTypeId = :NHW_Util.getnhwPreBoardCaseRecordTypeId()
                AND Status != 'Closed - Cancelled'
            )
          FROM WDR_Application__c
          WHERE Id IN :Trigger.new
        ];
        for (WDR_Application__c JobApp : JobApps) {
          if (JobApp.cases__r.size() > 0) {
            mIncomingJobAppIdToHasPreboardingCase.put(JobApp.id, true);
          } else {
            mIncomingJobAppIdToHasPreboardingCase.put(JobApp.id, false);
          }
        }

        //Filter out WD Job apps which have candidate stage as declined or rejected
        if (Trigger.isUpdate) {
          Map<Id, WDR_Application__c> oldJobApplications = (Map<Id, WDR_Application__c>) Trigger.oldMap;
          for (WDR_Application__c jobApp : (List<WDR_Application__c>) Trigger.new) {
            if (
              (NHW_Util.CloseCancelStages.contains(jobApp.Candidate_Stage__c)) &&
              (NHW_Util.CloseCancelStages.contains(oldJobApplications.get(jobApp.Id).Candidate_Stage__c))
            ) {
              mIncomingJobAppIdToHasPreboardingCase.put(jobApp.id, true);
            }
          }
        }
      }
      system.debug(
        LoggingLevel.INFO,
        'mIncomingJobAppIdToHasPreboardingCase in getter -' + mIncomingJobAppIdToHasPreboardingCase
      );
      return mIncomingJobAppIdToHasPreboardingCase;
    }
    set;
  }
  public static map<id, Boolean> jobAppsWithRescindHire {
    get {
      if (jobAppsWithRescindHire == null || jobAppsWithRescindHire.size() == 0) {
        jobAppsWithRescindHire = new Map<id, Boolean>();

        if (Trigger.isUpdate) {
          Map<Id, WDR_Application__c> oldJobApplications = (Map<Id, WDR_Application__c>) Trigger.oldMap;

          for (WDR_Application__c jobApp : (List<WDR_Application__c>) Trigger.new) {
            //Verify that we don't have a null stage coming in the old or new values
            if (jobApp.Candidate_Stage__c == null || oldJobApplications.get(jobApp.Id).Candidate_Stage__c == null) {
              continue;
            }

            // W-10159232 Is the application currently in a Final Stage (Placement,Rejected,Declined by Candidate) and moves to a value not in Final Stage.
            if (
              (jobApp.Candidate_Stage__c != oldJobApplications.get(jobApp.Id).Candidate_Stage__c) &&
              (!NHW_Util.FinalStages.contains(jobApp.Candidate_Stage__c)) &&
              (NHW_Util.FinalStages.contains(oldJobApplications.get(jobApp.Id).Candidate_Stage__c))
            ) {
              jobAppsWithRescindHire.put(jobApp.Id, true);
            } else {
              jobAppsWithRescindHire.put(jobApp.Id, false);
            }
          }
        }
      }
      return jobAppsWithRescindHire;
    }
    set;
  }
  /**
   * @description Interface method for handling before insert method.
   *
   **/
  public void beforeInsert() {
    setValidateDoNotSendNHW();
    validatePreboardingFlag();
  }

  /**
   * @description Interface method for handling after insert method.
   *
   **/
  public void afterInsert() {
    Map<Id, WDR_Application__c> mJobAppIdToNewJobAppRdyforPreboarding = new Map<Id, WDR_Application__c>();

    for (WDR_Application__c JobApp : (List<WDR_Application__c>) Trigger.New) {
      if (!JobApp.Do_Not_Send_NHW__c && JobApp.NHW_Create_Preboarding_Case__c == true) {
        mJobAppIdToNewJobAppRdyforPreboarding.put(JobApp.Id, JobApp);
      }
    }

    //before creating preboparding cases, perform some validations.
    //If a job app fails the validation, add error to the record and remove it from the map mJobAppIdToNewJobAppRdyforPreboarding
    if (!mJobAppIdToNewJobAppRdyforPreboarding.isEmpty() && !System.isBatch()) {
      Id jobId = System.enqueueJob(new NHW_CreateCasesAsync(mJobAppIdToNewJobAppRdyforPreboarding));
      System.debug(LOGGINGLEVEL.INFO, 'Validate Job Apps Async jobId -' + jobId);
    }
  }

  /**
   * @description Interface method for handling before update method.
   * //Populate do not send and do Validations on preboarding & do not send NHW flags
   **/
  public void beforeUpdate() {
    for (WDR_Application__c jobApp : (List<WDR_Application__c>) Trigger.new) {
      Boolean isRescindHire = false;

      if (jobAppsWithRescindHire != null && !jobAppsWithRescindHire.isEmpty()) {
        isRescindHire = jobAppsWithRescindHire.get(JobApp.id);
      }

      if (isRescindHire) {
        jobApp.NHW_Create_Preboarding_Case__c = false;
        jobApp.Auto_Provisioning_Email_Sent__c = false;
      }
    }
    setValidateDoNotSendNHW();
    validatePreboardingFlag();
  }

  /**
   * @description Interface method for handling after update method.
   *  Based on appropriate transtion of preboarding flag invoke async preboarding create process.
   **/
  public void afterUpdate() {
    Map<Id, WDR_Application__c> mJobAppIdToNewJobAppRdyforPreboarding = new Map<Id, WDR_Application__c>();

    //Following loop modified for detail log for story W-5394695 Oct B release
    for (WDR_Application__c JobApp : (List<WDR_Application__c>) Trigger.New) {
      Boolean doNotSendNHWChecked = JobApp.Do_Not_Send_NHW__c;
      Boolean doNotSendNHWChanged = (JobApp.Do_Not_Send_NHW__c !=
      Trigger.oldMap.get(JobApp.id).get('Do_Not_Send_NHW__c'));
      Boolean createPreBrdgChecked = (JobApp.NHW_Create_Preboarding_Case__c == true);
      Boolean alreadyHasPreBrdgCases = (mIncomingJobAppIdToHasPreboardingCase.get(JobApp.id) == true);
      Boolean firstCheck =
        (!doNotSendNHWChecked) &&
        (!doNotSendNHWChanged) &&
        (createPreBrdgChecked) &&
        (!alreadyHasPreBrdgCases);
      Boolean secondCheck = (!doNotSendNHWChecked) && (doNotSendNHWChanged) && (createPreBrdgChecked);
      Boolean isRescindHire = false;
      if (
        //If Do Not Send NHW is not updated and it is False - And Preboarding Flag is updated to True.
        firstCheck || secondCheck //Assuming we will block Do Not Send updation to false if case exists - If it is updated to false and we are in window we should spawn case
      ) {
        mJobAppIdToNewJobAppRdyforPreboarding.put(JobApp.Id, JobApp);
        //create debug log
        //use errorMessage field to store Job App Name.
        String errorMessage = JobApp.Name;
        //use description to store details, as it has more characters available
        String description = '';
        if (firstCheck) {
          description = 'First check passed. \n';
        } else if (secondCheck) {
          description = 'Second check passed. \n';
        }
        description = description + 'doNotSendNHWChecked=' + doNotSendNHWChecked + '\n';
        description = description + 'doNotSendNHWChanged=' + doNotSendNHWChanged + '\n';
        description = description + 'createPreBrdgChecked=' + createPreBrdgChecked + '\n';
        description = description + 'alreadyHasPreBrdgCases=' + alreadyHasPreBrdgCases + '\n';
        //PF_Logger.log('NHW', 'INFO', errorMessage, 'Create Preboarding Case', description, 'APEX TRIGGER');
        EventBus.publish(
                        new PF_Logging_Channel__e(
                                ApplicationName__c = 'NHW',
                                LogLevel__c = 'INFO',
                                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                                ErrorType__c = 'INFO',
                                Stack_Trace__c = 'NHW_WDRJobApplicationTriggerHandler',
                                Message__c = errorMessage,
                                Error__c = description
                                )
                        );
      }
    }

    //before creating preboparding cases, perform some validations.
    //If a job app fails the validation, add error to the record and remove it from the map mJobAppIdToNewJobAppRdyforPreboarding
    if (!mJobAppIdToNewJobAppRdyforPreboarding.isEmpty()) {
      Id jobId = System.enqueueJob(new NHW_CreateCasesAsync(mJobAppIdToNewJobAppRdyforPreboarding));
      System.debug(LOGGINGLEVEL.INFO, 'Validate Job Apps Async jobId -' + jobId);
    }

    updateCasesOnJobApplicationFieldsUpdate();
    mIncomingJobAppIdToHasPreboardingCase.clear();
    jobAppsWithRescindHire.clear();
  }

  public void setValidateDoNotSendNHW() {
    // ES Next changes - Replace offer type (WD Job App) with Job Req Reason (WD Job)

    Map<Id, WDR_Application__c> oldJobApplicationMap = (Map<Id, WDR_Application__c>) Trigger.oldMap;
    Set<Id> jobReqIds = new Set<Id>();
    Map<Id, String> relatedJrReasons = new Map<Id, String>();

    //Set of WD Jobs
    for (WDR_Application__c jbAppId : (List<WDR_Application__c>) Trigger.new) {
      jobReqIds.add(jbAppId.Job__c);
    }

    // Get Req creation reason from WD Job
    for (WDR_Job__c Jobs : [SELECT Id, Req_Creation_Reason__c FROM WDR_Job__c WHERE Id IN :jobReqIds]) {
      if (Jobs.Req_Creation_Reason__c != null) {
        relatedJrReasons.put(Jobs.Id, Jobs.Req_Creation_Reason__c);
      }
    }

    for (WDR_Application__c JobApp : (list<WDR_Application__c>) Trigger.new) {
      //Check if the update operation is NOT on the Do Not Send NHW flag - as we are allowing manual override.
      /*  if((Trigger.isUpdate //And any relevant fields  for deriving do not send NHW is changing.
               && (JobApp.Do_Not_Send_NHW__c == Trigger.oldmap.get(JobApp.id).get('Do_Not_Send_NHW__c'))
               && ((JobApp.Offer_Type__c != Trigger.oldmap.get(JobApp.id).get('Offer_Type__c'))
                   || (JobApp.Internal_Candidate__c != Trigger.oldmap.get(JobApp.id).get('Internal_Candidate__c')))
               )||
               (Trigger.isInsert
               && (JobApp.Do_Not_Send_NHW__c == false)
               ) 
              )  */

      //ES Next Changes : offer type & Job req reason check

      if (
        (Trigger.isUpdate &&
        (JobApp.Do_Not_Send_NHW__c == Trigger.oldmap.get(JobApp.id).get('Do_Not_Send_NHW__c')) &&
        (JobApp.Job__c != Trigger.oldmap.get(JobApp.id).get('Job__c') ||
        JobApp.Internal_Candidate__c != Trigger.oldmap.get(JobApp.id).get('Internal_Candidate__c') ||
        JobApp.Offer_Type__c != Trigger.oldmap.get(JobApp.id).get('Offer_Type__c'))) ||
        (Trigger.isInsert && (JobApp.Do_Not_Send_NHW__c == false))
      ) {
        if (
          (relatedJrReasons != null &&
          relatedJrReasons.containsKey(jobApp.Job__c) &&
          NHW_Util.NHWJobCreationReasonstoExclude.contains(relatedJrReasons.get(JobApp.Job__c))) ||
          JobApp.Internal_Candidate__c == true ||
          NHW_Util.NHWOfferTypestoExclude.contains(JobApp.Offer_Type__c)
        ) {
          JobApp.Do_Not_Send_NHW__c = true;
        } else {
          JobApp.Do_Not_Send_NHW__c = false;
        }
      }
      //IF Do not send is getting updated Manually/or due to derived fields updates & - Preboarding Flag is set(case exists)
      /*     W-10217652 - Removing Validations that would prevent data from coming in from WD,
                    WD is Source of Truth so we should let these changes come in.
              if((Trigger.isUpdate
                      && (JobApp.Do_Not_Send_NHW__c != Trigger.oldmap.get(JobApp.id).get('Do_Not_Send_NHW__c'))
                      && (JobApp.Do_Not_Send_NHW__c == TRUE && JobApp.NHW_Create_Preboarding_Case__c == TRUE)
                    )){
                        JobApp.addError(System.Label.NHW_Uncheck_Pre_Boarding_Flag_Error);
               }
              */
    }
  }

  public void validatePreboardingFlag() {
    for (WDR_Application__c JobApp : (list<WDR_Application__c>) Trigger.new) {
      Boolean isRescindHire = false;

      if (jobAppsWithRescindHire != null && !jobAppsWithRescindHire.isEmpty()) {
        isRescindHire = jobAppsWithRescindHire.get(JobApp.id);
      }
      /*
                W-10217652 - Remove these validations as the potentially prevent failures from EI.
                //Check if some process is updating/inserting such that below state occurs  - Preboarding Flag true but SD greater then preboarding Window
                if(JobApp.NHW_Create_Preboarding_Case__c == TRUE
                  && JobApp.Start_Date__c != null && (System.today().daysBetween(JobApp.Start_Date__c)>NHW_Util.LAST_N_DAYS)){
                    JobApp.addError(System.Label.NHW_Error_When_StartDate_is_GRT_window);
                    continue;
                }

             */
      //Check if some process is updating/inserting such that below state occurs  - Preboarding Flag true but placement has not happened.
      if (
        JobApp.NHW_Create_Preboarding_Case__c == true &&
        !NHW_Util.preboardingStages.contains(JobApp.Candidate_Stage__c) &&
        !NHW_Util.CloseCancelStages.contains(JobApp.Candidate_Stage__c) &&
        !isRescindHire
      ) {
        JobApp.addError(System.Label.Preboarding_Flag_manual_update_before_placement);
        continue;
      }

      //Check if Preboarding Flag is manually set when there is Do Not Send exists.
      if (
        (Trigger.isUpdate &&
        JobApp.NHW_Create_Preboarding_Case__c == true &&
        Trigger.oldMap.get(JobApp.id).get('NHW_Create_Preboarding_Case__c') == false &&
        JobApp.Do_Not_Send_NHW__c == true) ||
        (Trigger.isInsert &&
        JobApp.NHW_Create_Preboarding_Case__c == true &&
        JobApp.Do_Not_Send_NHW__c == true)
      ) {
        JobApp.addError(System.Label.Preboarding_Flag_manual_update_for_Do_Not_Send_NHW);
        continue;
      }
      //Check if some process is resetting the preboarding flag  after cases are spawned.
      if (
        (Trigger.isUpdate) &&
        ((JobApp.NHW_Create_Preboarding_Case__c == false &&
        Trigger.oldMap.get(JobApp.id).get('NHW_Create_Preboarding_Case__c') == true) &&
        (mIncomingJobAppIdToHasPreboardingCase.get(JobApp.Id) == true && !isRescindHire))
      ) {
        JobApp.addError(System.Label.NHW_Uncheck_Pre_Boarding_Flag_Error);
      }
    }
  }
  public void validateExistingCases(set<id> jobAppIds) {
    //MAP<ID,BOOLEAN>
  }
  public static void updateCasesOnJobApplicationFieldsUpdate() {
    Map<Id, WDR_Application__c> oldJobApplication = (Map<Id, WDR_Application__c>) Trigger.oldMap;
    Map<Id, WDR_Application__c> newJobApplication = (Map<Id, WDR_Application__c>) Trigger.newMap;
    Set<Id> jobapplicationsNeedPropagation = new Set<Id>();
    Set<Id> canceledJobApplications = new Set<Id>();
    Set<Id> jobAppIdsWithRescindHire = new Set<Id>();
    for (Id jbAppId : newJobApplication.keySet()) {
      if (
        newJobApplication.get(jbAppId).Business_Site__c != oldJobApplication.get(jbAppId).Business_Site__c ||
        newJobApplication.get(jbAppId).Start_Date__c != oldJobApplication.get(jbAppId).Start_Date__c ||
        (newJobApplication.get(jbAppId).Candidate_Stage__c != oldJobApplication.get(jbAppId).Candidate_Stage__c &&
        NHW_Util.CloseCancelStages.contains(newJobApplication.get(jbAppId).Candidate_Stage__c)) ||
        (jobAppsWithRescindHire.containsKey(jbAppId) && jobAppsWithRescindHire.get(jbAppId)) ||
        (newJobApplication.get(jbAppId).Do_Not_Send_NHW__c == true &&
        oldJobApplication.get(jbAppId).Do_Not_Send_NHW__c == false &&
        mIncomingJobAppIdToHasPreboardingCase.containsKey(jbAppId))
      ) {
        jobapplicationsNeedPropagation.add(jbAppId);
      }
      if (
        newJobApplication.get(jbAppId).Candidate_Stage__c != oldJobApplication.get(jbAppId).Candidate_Stage__c &&
        NHW_Util.CloseCancelStages.contains(newJobApplication.get(jbAppId).Candidate_Stage__c)
      ) {
        canceledJobApplications.add(jbAppId);
      }
      if (
        newJobApplication.get(jbAppId).Do_Not_Send_NHW__c == true &&
        oldJobApplication.get(jbAppId).Do_Not_Send_NHW__c == false &&
        mIncomingJobAppIdToHasPreboardingCase.containsKey(jbAppId)
      ) {
        canceledJobApplications.add(jbAppId);
      }
      if ((jobAppsWithRescindHire.containsKey(jbAppId) && jobAppsWithRescindHire.get(jbAppId))) {
        jobAppIdsWithRescindHire.add(jbAppId);
      }
    }

    if (!jobapplicationsNeedPropagation.isEmpty()) {
      NHW_Util.updateJobApplicationsRelatedCases(
        jobapplicationsNeedPropagation,
        canceledJobApplications,
        jobAppIdsWithRescindHire
      );
    }
  }

  /**
   * @description Interface method for handling before delete method.
   *
   **/
  public void beforeDelete() {
  }

  /**
   * @description Interface method for handling after delete method.
   *
   **/
  public void afterDelete() {
  }

  /**
   * @description Interface method for handling after undelete method.
   *
   **/
  public void afterUnDelete() {
  }
}