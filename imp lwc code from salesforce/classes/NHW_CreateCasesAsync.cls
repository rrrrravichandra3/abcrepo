@SuppressWarnings(
    'PMD.CognitiveComplexity'
)
public class NHW_CreateCasesAsync implements Queueable{
    list<case> validPreboardingCases = new list<case>();
    list<contact> candidateContacts = new list<contact>();
    Map<Id, WDR_Application__c> mJobAppIdToNewJobAppRdyforPreboarding = new Map<Id, WDR_Application__c>();
    public NHW_CreateCasesAsync(list<case> validPreboardingCases){
            this.validPreboardingCases = validPreboardingCases;
    }
    public NHW_CreateCasesAsync(Map<Id, WDR_Application__c> mJobAppIdToNewJobAppRdyforPreboarding){
        this.mJobAppIdToNewJobAppRdyforPreboarding = mJobAppIdToNewJobAppRdyforPreboarding;
    }
    public void execute(QueueableContext context) {
        //segregating the two codes entirely, even though they ahve similar logic, so that deprecating becomes easy later.
        //executePreCEMCILogic method can be deleted after cemci goes live, along with NHW_Util.populateCandidateContacts
        if (!mJobAppIdToNewJobAppRdyforPreboarding.isEmpty()) {
            performValidationsBeforePreboardingCase(context);
        } else {
            executePostCEMCILogic(context);
        }              
    }


    /*
    * method to perform validations
    * This method effectively replaces validation rules 
    */
    private void performValidationsBeforePreboardingCase(QueueableContext context){
        String ErrorType = 'Error while creating Job Application in NHW_CreateCasesAsync';
        String ErrorMessagePrefix = 'Error message is : ';
        //Basic check to see if Job req and candidate lookups are filled in 
        for(Id currentJobAppId : mJobAppIdToNewJobAppRdyforPreboarding.keySet()){
            WDR_Application__c currentJobApp = mJobAppIdToNewJobAppRdyforPreboarding.get(currentJobAppId);
            if(currentJobApp.Candidate__c == null){
                String Description = ErrorMessagePrefix + 'Unable to create Preboarding Case.' + '\n'
                                   + 'Job App record Id ' + currentJobAppId;
                String ErrorMessage = ErrorMessagePrefix + 'Candidate missing on the Job App.';
                //PF_Logger.log('NHW','ERROR',ErrorMessage,ErrorType,Description,'NHW_CreateCasesAsync');
                EventBus.publish(
                    new PF_Logging_Channel__e(
                    ApplicationName__c = 'NHW',
                    LogLevel__c = 'Error',
                    //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                    ErrorType__c = ErrorType,
                    Stack_Trace__c = 'NHW_CreateCasesAsync',
                    Message__c = ErrorMessage,
                    Error__c = Description
                    )
                );
                mJobAppIdToNewJobAppRdyforPreboarding.remove(currentJobAppId);
                continue;
            }
            if(currentJobApp.Job__c == null){
                String Description = ErrorMessagePrefix + 'Unable to create Preboarding Case.' + '\n'
                                   + 'Job App record Id ' + currentJobAppId;
                String ErrorMessage = ErrorMessagePrefix + 'Job Requisition missing on the Job App.';
                //PF_Logger.log('NHW','ERROR',ErrorMessage,ErrorType,Description,'NHW_CreateCasesAsync');
                EventBus.publish(
                new PF_Logging_Channel__e(
                ApplicationName__c = 'NHW',
                LogLevel__c = 'Error',
                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                ErrorType__c = ErrorType,
                Stack_Trace__c = 'NHW_CreateCasesAsync',
                Message__c = ErrorMessage,
                Error__c = Description
                )
            );
                mJobAppIdToNewJobAppRdyforPreboarding.remove(currentJobAppId);
                continue;
            }
        }
        if(mJobAppIdToNewJobAppRdyforPreboarding.isEmpty()){return;}
        //Perform query from database to get job req and candidate related fields
        Map<Id, WDR_Application__c> jobAppsWihRelatedLookups = new Map<Id, WDR_Application__c>([Select Id,Candidate__c,Job__c,Candidate_Stage__c,Internal_Candidate__c,Offer_Type__c, Business_Site__c, Business_Site__r.City__c, Candidate__r.Mailing_City__c,Candidate__r.Mailing_Country__c,Candidate__r.Mailing_Postal_Code__c,Candidate__r.Mailing_Street__c, Job__r.Job_Code__c,Job__r.Employment_Type__c,Job__r.Company__c,Job__r.Business_Unit__c,Job__r.Department__c,Job__r.Region__c,Job__r.Hiring_Manager__c,Job__r.Req_Creation_Reason__c, Start_Date__c from WDR_Application__c where Id in :mJobAppIdToNewJobAppRdyforPreboarding.keySet()]);

        //perform validation rules
        Onboarding_Setting__c settings = Onboarding_Setting__c.getOrgDefaults();
        List<AggregateResult> results = [SELECT count(Id) FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = 'PF_Exclude_Validation_Rule'];
        Boolean isPfExcludeValidationRuleAssigned = (Integer) results[0].get('expr0') == 1 ? true : false;
        String profileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
        for(Id currentJobAppId : mJobAppIdToNewJobAppRdyforPreboarding.keySet()){
            WDR_Application__c oldJobAppwithRelatedFields = jobAppsWihRelatedLookups.get(currentJobAppId);
            
            //perform validation rule NHW_Required_fields_For_Placement
            NHW_WDRJobApplication_ApexValidations.NHW_WDRJobApplication_ApexValidations_Results candidateFieldCheckResult = NHW_WDRJobApplication_ApexValidations.requiredCandidateFieldsForPlacementCheck(oldJobAppwithRelatedFields, settings);
            if(candidateFieldCheckResult.result == FALSE){
                String Description = ErrorMessagePrefix + 'Required fields are missing for the Candidate. ' + '\n'
                                   + 'Candidate record Id ' + oldJobAppwithRelatedFields.Candidate__c;
                String ErrorMessage = ErrorMessagePrefix + candidateFieldCheckResult.errorMessage;
                //PF_Logger.log('NHW','ERROR',ErrorMessage,ErrorType,Description,'NHW_CreateCasesAsync');
                EventBus.publish(
                new PF_Logging_Channel__e(
                ApplicationName__c = 'NHW',
                LogLevel__c = 'Error',
                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                ErrorType__c = ErrorType,
                Stack_Trace__c = 'NHW_CreateCasesAsync',
                Message__c = ErrorMessage,
                Error__c = Description
                )
            );
                mJobAppIdToNewJobAppRdyforPreboarding.remove(currentJobAppId);
                continue;
            }
            
            //perform validation rule NHW_Required_Fields_From_Job_Req
            NHW_WDRJobApplication_ApexValidations.NHW_WDRJobApplication_ApexValidations_Results jobReqFieldCheckResult = NHW_WDRJobApplication_ApexValidations.requiredJobReqFieldsForPlacementCheck(oldJobAppwithRelatedFields,settings);
            if(jobReqFieldCheckResult.result == FALSE){
                String Description = ErrorMessagePrefix + 'Required fields are missing for the WD Job Requisition. ' + '\n'
                                   + 'WD Job Requisition record Id ' + oldJobAppwithRelatedFields.Job__c;
                String ErrorMessage = ErrorMessagePrefix + jobReqFieldCheckResult.errorMessage;
                //PF_Logger.log('NHW','ERROR',ErrorMessage,ErrorType,Description,'NHW_CreateCasesAsync');
                EventBus.publish(
                new PF_Logging_Channel__e(
                ApplicationName__c = 'NHW',
                LogLevel__c = 'Error',
                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                ErrorType__c = ErrorType,
                Stack_Trace__c = 'NHW_CreateCasesAsync',
                Message__c = ErrorMessage,
                Error__c = Description
                )
            );
                mJobAppIdToNewJobAppRdyforPreboarding.remove(currentJobAppId);
                continue;
            }

            //perform validation rule Business_Site_Required_For_Placement
            NHW_WDRJobApplication_ApexValidations.NHW_WDRJobApplication_ApexValidations_Results businessSiteFieldCheckResult = NHW_WDRJobApplication_ApexValidations.requiredBusinessSiteRequiredForPlacementCheck(mJobAppIdToNewJobAppRdyforPreboarding.get(currentJobAppId),isPfExcludeValidationRuleAssigned);
            if(businessSiteFieldCheckResult.result == FALSE){
                String Description = ErrorMessagePrefix + 'Required fields are missing for the WD Job Application. ' + '\n'
                                   + 'WD Job Application record Id ' + oldJobAppwithRelatedFields.Id;
                String ErrorMessage = ErrorMessagePrefix + businessSiteFieldCheckResult.errorMessage;
                //PF_Logger.log('NHW','ERROR',ErrorMessage,ErrorType,Description,'NHW_CreateCasesAsync');
                EventBus.publish(
                    new PF_Logging_Channel__e(
                    ApplicationName__c = 'NHW',
                    LogLevel__c = 'Error',
                    //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                    ErrorType__c = ErrorType,
                    Stack_Trace__c = 'NHW_CreateCasesAsync',
                    Message__c = ErrorMessage,
                    Error__c = Description
                    )
                );
                mJobAppIdToNewJobAppRdyforPreboarding.remove(currentJobAppId);
                continue;
            }

            //perform validation rule Start_Date in before update context
            NHW_WDRJobApplication_ApexValidations.NHW_WDRJobApplication_ApexValidations_Results startDateFieldCheckResult = NHW_WDRJobApplication_ApexValidations.requiredStartDateForPlacementCheck(oldJobAppwithRelatedFields, isPfExcludeValidationRuleAssigned, profileName);
            if(startDateFieldCheckResult.result == FALSE){
                String Description = ErrorMessagePrefix + 'Required fields are missing for the WD Job Application. ' + '\n'
                                    + 'WD Job Application record Id ' + currentJobAppId;
                String ErrorMessage = ErrorMessagePrefix + startDateFieldCheckResult.errorMessage;
                //PF_Logger.log('NHW','ERROR',ErrorMessage,ErrorType,Description,'NHW_CreateCasesAsync');
                EventBus.publish(
                    new PF_Logging_Channel__e(
                    ApplicationName__c = 'NHW',
                    LogLevel__c = 'Error',
                    //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                    ErrorType__c = ErrorType,
                    Stack_Trace__c = 'NHW_CreateCasesAsync',
                    Message__c = ErrorMessage,
                    Error__c = Description
                    )
                );
                mJobAppIdToNewJobAppRdyforPreboarding.remove(currentJobAppId);
                continue;
            }
        }
        //now spawn teh preboarding cases
        if(!mJobAppIdToNewJobAppRdyforPreboarding.isEmpty()){
            validPreboardingCases = NHW_Util.populatePreboardingCases(mJobAppIdToNewJobAppRdyforPreboarding.keySet());
            if(validPreboardingCases.size()>0){
                //Async queueable apex to insert the preboarding cases.
                executePostCEMCILogic(context);

            }                       
        }

        NHW_Util.insertNHWLogs(); 
    }

    private void executePostCEMCILogic(QueueableContext context){
        Set<Id> jobAppIds = new Set<Id>();
        Set<Id> jobAppsWithExistingCases = new Set<Id>(); 

        String ErrorType = 'Error while creating pre-boarding tickets in NHW_CreateCasesAsync';
        String ErrorMessagePrefix = 'Error message is : ';
        //PF Debug Log for cases without Contact. Fail the case creation
        for(Case c: validPreboardingCases){
            if(c.NHW_Employee__c == null || (!String.valueOf(c.NHW_Employee__c ).startsWith('003'))){
                String Description = ErrorMessagePrefix + 'No Contact record for the case' + '\n'
                                   + 'Related Job Application id ' + c.NHW_Job_Application__c;
                String ErrorMessage = ErrorMessagePrefix+'No Contact record for the case';
                //PF_Logger.log('NHW','ERROR',ErrorMessage,ErrorType,Description,'NHW_CreateCasesAsync');
                EventBus.publish(
                    new PF_Logging_Channel__e(
                    ApplicationName__c = 'NHW',
                    LogLevel__c = 'Error',
                    //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                    ErrorType__c = ErrorType,
                    Stack_Trace__c = 'NHW_CreateCasesAsync',
                    Message__c = ErrorMessage,
                    Error__c = Description
                    )
                );
            }
            jobAppIds.add(c.NHW_Job_Application__c);
        }
        //remainder of the logic is same as preCEMCILogic
        for(WDR_Application__c application : [select Id,
                                            (select id,NHW_Job_Application__c from cases__r 
                                            where origin ='NHW' and recordTypeId= :NHW_Util.getnhwPreBoardCaseRecordTypeId()
                                            and Status != 'Closed - Cancelled')
                                            from WDR_Application__c
                                            where id in :jobAppIds]){
                
            if(application.cases__r != NULL && application.cases__r.size()>0){

                jobAppsWithExistingCases.add(application.Id);

            }
        }
        List<Case> preboardingCasesToInsert = new list<case>();
        for(case c:validPreboardingCases){
            if(c.NHW_Employee__c == null){
                continue;//PF Logger already logged.
            }else if(jobAppsWithExistingCases.contains(c.NHW_Job_Application__c)){
                continue;
            }else if(c.Manager_Name__c == null){
                String Description = ErrorMessagePrefix + 'Manager contact not available.Please check portal user for hiring manager.'  + '\n'
                                     + ' Status code  : ' + 'N/A' + '\n'
                                     + ' Fields errored : ' + 'NH_Manager__c' + '\n'
                                     + ' Related Job Application id ' + c.NHW_Job_Application__c + '\n'
                                     + ' Preboarding Case generated ' + c + '\n'
                                     + ' Scheduled job id  ' + context.getJobID();
                String ErrorMessage = ErrorMessagePrefix + 'Manager contact not available.Please check portal user for hiring manager.'  ;
                //PF_Logger.log('NHW','ERROR',ErrorMessage,ErrorType,Description,'NHW_CreateCasesAsync');
                EventBus.publish(
                    new PF_Logging_Channel__e(
                    ApplicationName__c = 'NHW',
                    LogLevel__c = 'Error',
                    //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                    ErrorType__c = ErrorType,
                    Stack_Trace__c = 'NHW_CreateCasesAsync',
                    Message__c = ErrorMessage,
                    Error__c = Description
                    )
                );    
                continue;         
            }else{
                preboardingCasesToInsert.add(c);
            }
        }
        Database.SaveResult[] srList = Database.insert(preboardingCasesToInsert,false);
        Integer i = 0;
        for(Database.SaveResult sr:srList){

            if(!sr.isSuccess()){
              for(Database.Error err : sr.getErrors()){
                  String Description = ErrorMessagePrefix + err.getMessage()  + '\n'
                                     + ' Status code  : ' + err.getStatusCode() + '\n'
                                     + ' Fields errored : ' + err.getFields() + '\n'
                                     + ' Related Job Application id ' + preboardingCasesToInsert[i].NHW_Job_Application__c + '\n'
                                     + ' Preboarding Case generated ' + preboardingCasesToInsert[i] + '\n'
                                     + ' Scheduled job id  ' + context.getJobID();
                  String ErrorMessage = ErrorMessagePrefix + err.getMessage() ;
                            //PF_Logger.log('NHW','ERROR',ErrorMessage,ErrorType,Description,'NHW_CreateCasesAsync');
                            EventBus.publish(
                                new PF_Logging_Channel__e(
                                ApplicationName__c = 'NHW',
                                LogLevel__c = 'Error',
                                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                                ErrorType__c = ErrorType,
                                Stack_Trace__c = 'NHW_CreateCasesAsync',
                                Message__c = ErrorMessage,
                                Error__c = Description
                                )
                            );    
              }
            } 
            i = i+1;
        }
        NHW_Util.insertNHWLogs(); 

    }
}