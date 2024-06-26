/**
 * ******************************************** W-12578108 : RULE ENGINE ********************************************
 * 
 * Class to hold MA_DS_AppliedRulesService.AppliedRuleJob implementation to process In Use Template type Applied Rules.
 * Holds MA_DS_AppliedRulesService.AppliedRuleJobFinalizer implementation to provide actions for single / final job completion.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         18/03/2023      Chakshu Malhotra        W-12578108 - Adds logic to process In Use Template type Applied Rules.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_TemplateAppliedRuleSyncService extends MA_DS_AppliedRulesService.AppliedRuleSyncService {
    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initialize the TemplateRuleSync Job with JobParams & JobFinalizer to process In Use Template type Applied Rules.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	                                DESCRIPTION (Data Type Id, Acquisition Company record Id of the Package record)
    * @param    pkgId	                                        DESCRIPTION (Data Type Id, Package record Id of the Package Distribution record)
    * @param    pkgDistributionId	                            DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    originExecMode	                                DESCRIPTION (Data Type MA_DS_AppliedRulesService.ExecutionMode, ExecutionMode enum type)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void initAppliedRuleJob(Id acqCompanyId, Id pkgId, Id pkgDistributionId, MA_DS_AppliedRulesService.ExecutionMode originExecMode) {
        MA_DS_AppliedRulesService.JobParams jobParams = MA_DS_AppliedRulesServiceUtility.getTemplateAppliedRulesParams(acqCompanyId, pkgId, pkgDistributionId, originExecMode);
        MA_DS_AppliedRulesService.JobFinalizer jobFinalizer = new TemplateRuleSyncFinalizer(jobParams);
        this.appliedRuleJob = new TemplateRuleSync(jobParams, jobFinalizer);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initialize the TemplateRuleSync Job with JobParams & JobFinalizer to process In Use Template type Applied Rules.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	                            DESCRIPTION (Data Type Id, Acquisition Company record Id of the Package record)
    * @param    pkgId	                                    DESCRIPTION (Data Type Id, Package record Id of the Package Distribution record)
    * @param    pkgDistributionId	                        DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    originExecMode	                            DESCRIPTION (Data Type MA_DS_AppliedRulesService.ExecutionMode, ExecutionMode enum type)
    * @param    asyncApexJobIds	                            DESCRIPTION (Data Type Set<Id>, AsyncApexJob Ids of the Queueable Jobs that processed Package Distribution type Applied Rules)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void initAppliedRuleJob(Id acqCompanyId, Id pkgId, Id pkgDistributionId, MA_DS_AppliedRulesService.ExecutionMode originExecMode, Set<Id> asyncApexJobIds) {
        MA_DS_AppliedRulesService.JobParams jobParams = MA_DS_AppliedRulesServiceUtility.getTemplateAppliedRulesParams(acqCompanyId, pkgId, pkgDistributionId, originExecMode, asyncApexJobIds);
        MA_DS_AppliedRulesService.JobFinalizer jobFinalizer = new TemplateRuleSyncFinalizer(jobParams);
        this.appliedRuleJob = new TemplateRuleSync(jobParams, jobFinalizer);
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable implementation to Upsert In Use Template type Applied Rules.
    * Recursively self-chains itself to process all eligible Acquisition Contacts based on the Rules Criteria Query & Audit Flags set on each In Use Template. 
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class TemplateRuleSync extends MA_DS_AppliedRulesService.AppliedRuleJob {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the TemplateRuleSync class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the AppliedRuleJob type)
        * @param    jobFinalizer	    DESCRIPTION (Data Type JobFinalizer, JobFinalizer instance for the AppliedRuleJob type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public TemplateRuleSync(JobParams jobParams, JobFinalizer jobFinalizer) {
            super(jobParams, jobFinalizer);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Queueable interface method to find eligible Acquisition Contacts for upserting In Use Template type Applied Rules.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    qContext    DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void execute(QueueableContext qContext) {
            MA_DS_AppliedRulesWrapper.TemplateAppliedRuleParams jobParams = (MA_DS_AppliedRulesWrapper.TemplateAppliedRuleParams)this.jobParams;
            //System.debug('TemplateRuleSync jobParams : ' + JSON.serialize(jobParams));

            Integer currentQuerySize = 0;
            Id asyncApexJobId = qContext.getJobId();
            Boolean matchIUTIndexes = matchIUTIndexes(jobParams.lastIUTIndex, jobParams.currentIUTIndex);
            Boolean isValidIUTIndex = isValidIUTIndex(jobParams.currentIUTIndex, jobParams.inUseTemplateIds.size());

            if(!matchIUTIndexes && isValidIUTIndex) {
                jobParams.lastIUTIndex = jobParams.currentIUTIndex;
                setRulesQueryWrapperWithFlags(jobParams);
            }

            if(isValidIUTIndex) {
                for(Integer currentQueryCount=1; currentQueryCount <= jobParams.maxQueryCount; currentQueryCount++) {
                    List<MA_DS_Applied_Rule__c> pdAppliedRules = getPackageDistributionAppliedRules(jobParams);
                    currentQuerySize = pdAppliedRules.size();
                    
                    Set<Id> acqContactIds = getAppliedRuleAcquisitionContactIds(pdAppliedRules);
                    List<Acquisition_Contacts__c> acqContacts = getEligibleAcquisitionContacts(jobParams, acqContactIds);

                    if(acqContacts.size() > 0) {
                        jobParams.templateRulesAsyncApexJobIds.add(asyncApexJobId);
                        List<MA_DS_Applied_Rule__c> iutAppliedRules = getInUseTemplateAppliedRules(jobParams, acqContacts, asyncApexJobId);
                        MA_DS_TemplateAppliedRuleSyncUtility.bulkUpsertAppliedRules(iutAppliedRules);
                    }

                    jobParams.lastRecordId = (currentQuerySize > 0) ? pdAppliedRules[currentQuerySize - 1].Id : jobParams.lastRecordId;
                    
                    if(currentQuerySize < jobParams.querySizeLimit) {
                        break;
                    }
                }
            }

            this.invokeJobFinalizer(jobParams, isValidIUTIndex, currentQuerySize, jobParams.inUseTemplateIds.size());
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to check if lastIUTIndex matches currentIUTIndex.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    lastIUTIndex            DESCRIPTION (Data type Integer, Index of In Use Template Id processed in previous Job)
        * @param    currentIUTIndex         DESCRIPTION (Data type Integer, Index of In Use Template Id currently being processed)
        * @return   Boolean                 DESCRIPTION (return True if lastIUTIndex matches currentIUTIndex)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Boolean matchIUTIndexes(Integer lastIUTIndex, Integer currentIUTIndex) {
            return lastIUTIndex == currentIUTIndex;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to check if currentIUTIndex is valid.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    currentIUTIndex             DESCRIPTION (Data type Integer, Index of In Use Template Id currently being processed)
        * @param    inUseTemplateIdsCount       DESCRIPTION (Data type Integer, Total number of In Use Templates being processed)
        * @return   Boolean                     DESCRIPTION (return True if currentIUTIndex is valid)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Boolean isValidIUTIndex(Integer currentIUTIndex, Integer inUseTemplateIdsCount) {
            return currentIUTIndex < inUseTemplateIdsCount;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to initialize JobParams with Rules Query & Audit Flags details.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the AppliedRuleJob type)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void setRulesQueryWrapperWithFlags(MA_DS_AppliedRulesWrapper.TemplateAppliedRuleParams jobParams) {
            MA_DS_TemplateAppliedRuleSyncUtility.RulesQueryWithFlagsWrapper wrapperInstance = getRulesQueryWithFlagsWrapper(jobParams);
            jobParams.auditAll = wrapperInstance.auditAll;
            jobParams.rulesQueryWrapper = wrapperInstance.rulesQueryWrapper;
            jobParams.templateDocumentType = wrapperInstance.templateDocumentType;

            jobParams.templateIds.add(wrapperInstance.templateId);
            jobParams.auditFlagsTypeMap.putAll(wrapperInstance.auditFlagsTypeMap);
            jobParams.auditFlagsFieldMap.putAll(wrapperInstance.auditFlagsFieldMap);
            jobParams.auditFlagsSampleSizeMap.putAll(wrapperInstance.auditFlagsSampleSizeMap);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get RulesQueryWithFlagsWrapper containing details of Rules Query & Audit Flags for each In Use Template.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	                        DESCRIPTION (Data Type JobParams, JobParams instance for the AppliedRuleJob type)
        * @return   RulesQueryWithFlagsWrapper          DESCRIPTION (return MA_DS_TemplateAppliedRuleSyncUtility.RulesQueryWithFlagsWrapper instance)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private MA_DS_TemplateAppliedRuleSyncUtility.RulesQueryWithFlagsWrapper getRulesQueryWithFlagsWrapper(MA_DS_AppliedRulesWrapper.TemplateAppliedRuleParams jobParams) {
            Id inUseTemplateId = jobParams.inUseTemplateIds[jobParams.currentIUTIndex];
            return MA_DS_TemplateAppliedRuleSyncUtility.getRulesQueryWithFlagsWrapper(inUseTemplateId, jobParams.acqCompanyId, jobParams.parentSObject, jobParams.childRelationshipMap);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get Package Distribution type Applied Rule records to be used to find eligible Acquisition Contacts for In Use Template type Applied Rules.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	                        DESCRIPTION (Data Type JobParams, JobParams instance for the AppliedRuleJob type)
        * @return   List<MA_DS_Applied_Rule__c>         DESCRIPTION (return Package Distribution type Applied Rule records)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private List<MA_DS_Applied_Rule__c> getPackageDistributionAppliedRules(MA_DS_AppliedRulesWrapper.TemplateAppliedRuleParams jobParams) {
            return MA_DS_TemplateAppliedRuleSyncUtility.getAppliedRules(jobParams.pkgDistributionId, jobParams.packageRulesAsyncApexJobIds, jobParams.lastRecordId, jobParams.querySizeLimit);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get the Acquisition Contact Ids from the Package Distribution type Applied Rule records.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    pdAppliedRules	        DESCRIPTION (Data Type List<MA_DS_Applied_Rule__c>, Package Distribution type Applied Rule records)
        * @return   Set<Id>                 DESCRIPTION (return Set of Acquisition Contact record Ids)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Set<Id> getAppliedRuleAcquisitionContactIds(List<MA_DS_Applied_Rule__c> pdAppliedRules) {
            Set<Id> acqContactIds = new Set<Id>();
            for(MA_DS_Applied_Rule__c appliedRule : pdAppliedRules) {
                acqContactIds.add(appliedRule.MA_DS_Acquisition_Contact__c);
            }
            return acqContactIds;
        }
        
        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get the eligible Acquisition Contacts for upserting In Use Template type Applied Rules.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	                        DESCRIPTION (Data Type JobParams, JobParams instance for the AppliedRuleJob type)
        * @param    acqContactIds	                    DESCRIPTION (Data Type Set<Id>, Set of Acquisition Contact record Ids)
        * @return   List<Acquisition_Contacts__c>       DESCRIPTION (return List of Acquisition Contact records eligible for upserting Applied Rules)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private List<Acquisition_Contacts__c> getEligibleAcquisitionContacts(MA_DS_AppliedRulesWrapper.TemplateAppliedRuleParams jobParams, Set<Id> acqContactIds) {
            return MA_DS_TemplateAppliedRuleSyncUtility.getEligibleAcquisitionContacts(acqContactIds, jobParams.rulesQueryWrapper);
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get the In Use Template type Applied Rules for bulk upsert.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	                    DESCRIPTION (Data Type JobParams, JobParams instance for the AppliedRuleJob type)
        * @param    acqContacts	                    DESCRIPTION (Data Type List<Acquisition_Contacts__c>, List of Acquisition Contact records)
        * @param    asyncApexJobId	                DESCRIPTION (Data Type Id, Current AsyncApexJob Id of the AppliedRuleJob that is processing the Applied Rule records)
        * @return   List<MA_DS_Applied_Rule__c>     DESCRIPTION (return In Use Template type Applied Rules)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private List<MA_DS_Applied_Rule__c> getInUseTemplateAppliedRules(MA_DS_AppliedRulesWrapper.TemplateAppliedRuleParams jobParams, List<Acquisition_Contacts__c> acqContacts, Id asyncApexJobId) {
            List<MA_DS_Applied_Rule__c> appliedRules = new List<MA_DS_Applied_Rule__c>();
            for(Acquisition_Contacts__c acqContact : acqContacts) {
                List<String> appliedAuditFlagKeys = (jobParams.auditFlagsSampleSizeMap.size() > 0) ? getAppliedAuditFlagKeys(jobParams, acqContact) : new List<String>();
                appliedRules.add(getAppliedRule(jobParams.pkgDistributionId, jobParams.templateIds[jobParams.currentIUTIndex], jobParams.templateDocumentType, acqContact.Id, asyncApexJobId, jobParams.auditAll, appliedAuditFlagKeys));
            }
            return appliedRules;
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get the Audit Field Flag Keys to be added to the Applied Rule record.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	                    DESCRIPTION (Data Type JobParams, JobParams instance for the AppliedRuleJob type)
        * @param    acqContact	                    DESCRIPTION (Data Type Acquisition_Contacts__c, Acquisition Contact record)
        * @return   List<String>                    DESCRIPTION (return List of Audit Field Flag Keys)
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private List<String> getAppliedAuditFlagKeys(MA_DS_AppliedRulesWrapper.TemplateAppliedRuleParams jobParams, Acquisition_Contacts__c acqContact) {
            return MA_DS_TemplateAppliedRuleSyncUtility.getAppliedAuditFlagKeys(acqContact, jobParams.parentSObject, jobParams.auditFlagsFieldMap, jobParams.auditFlagsTypeMap, jobParams.auditFlagsSampleSizeMap, jobParams.appliedAuditFlagsMap);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get the In Use Template type Applied Rule for bulk upsert.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    pkgDistributionId	            DESCRIPTION (Data Type Id, Package Distribution record Id)
        * @param    templateId	                    DESCRIPTION (Data Type Id, Template being used by the In Use Template record)
        * @param    templateDocumentType	        DESCRIPTION (Data Type Id, Document type of the Template record)
        * @param    acqContactId	                DESCRIPTION (Data Type Id, Acquisition Contact record)
        * @param    asyncApexJobId	                DESCRIPTION (Data Type Id, Current AsyncApexJob Id of the AppliedRuleJob that is processing the Applied Rule records)
        * @param    auditAll	                    DESCRIPTION (Data Type Boolean, True if Audit All field is checked on the In Use Template record)
        * @param    flaggedFields	                DESCRIPTION (Data Type List<String> , List of Audit Field Flag Keys)
        * @return   MA_DS_Applied_Rule__c           DESCRIPTION (return In Use Template type Applied Rule)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private MA_DS_Applied_Rule__c getAppliedRule(Id pkgDistributionId, Id templateId, String templateDocumentType, Id acqContactId, Id asyncApexJobId, Boolean auditAll, List<String> flaggedFields) {
            return MA_DS_TemplateAppliedRuleSyncUtility.getAppliedRule(pkgDistributionId, templateId, templateDocumentType, acqContactId, asyncApexJobId, auditAll, flaggedFields);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to invoke JobFinalizer action to handle Single Job / Final Job completion.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	            DESCRIPTION (Data Type TemplateAppliedRuleParams, JobParams instance for the TemplateRuleSync job)
        * @param    isValidIUTIndex         DESCRIPTION (Data type Boolean, True if currentIUTIndex is less than total In Use Template Ids)
        * @param    currentQuerySize        DESCRIPTION (Data type Integer, Last Query Size of the Applied Rules retrieved)
        * @param    inUseTemplateIdsCount   DESCRIPTION (Data type Integer, Total number of available In Use Template Ids to process)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void invokeJobFinalizer(MA_DS_AppliedRulesWrapper.TemplateAppliedRuleParams jobParams, Boolean isValidIUTIndex, Integer currentQuerySize, Integer inUseTemplateIdsCount) {
            Boolean isEligibleForNextIUT = (currentQuerySize < jobParams.querySizeLimit);
            Boolean isLastIUTIndex = (jobParams.currentIUTIndex == (inUseTemplateIdsCount - 1));

            if(!isValidIUTIndex || (isEligibleForNextIUT && isLastIUTIndex)) {
                this.jobFinalizer.handleFinalJobCompletion();
            }else if(isValidIUTIndex && isEligibleForNextIUT) {
                jobParams.currentIUTIndex++;
                this.jobFinalizer.handleSingleJobCompletion();
            }else {
                this.jobFinalizer.handleSingleJobCompletion();
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Sub-class of MA_DS_AppliedRulesService.AppliedRuleJobFinalizer to provide JobFinalizer implementation for TemplateRuleSync Queueable job.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class TemplateRuleSyncFinalizer extends MA_DS_AppliedRulesService.AppliedRuleJobFinalizer {
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the TemplateRuleSyncFinalizer class.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	        DESCRIPTION (Data Type JobParams, JobParams instance for the AppliedRuleJobFinalizer type)
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public TemplateRuleSyncFinalizer(MA_DS_AppliedRulesService.JobParams jobParams) {
            super(jobParams);
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on each single job completion, updates In Use Template record with Applied Audit Field Flags, resets the Rules & Audit Flag details in JobParams for the next IUT.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleSingleJobCompletion() {
            MA_DS_AppliedRulesWrapper.TemplateAppliedRuleParams jobParams = (MA_DS_AppliedRulesWrapper.TemplateAppliedRuleParams)this.jobParams;
            
            if(jobParams.lastIUTIndex != jobParams.currentIUTIndex) {
                this.updateInUseTemplate(jobParams, jobParams.currentIUTIndex - 1);
                this.resetJobParams(jobParams);
            }

            TemplateRuleSync appliedRuleJob = new TemplateRuleSync(this.jobParams, new TemplateRuleSyncFinalizer(this.jobParams));
            MA_DS_AppliedRulesService.execute(appliedRuleJob);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to reset the Rules Query Wrapper & Audit Flag details in the JobParams for the next IUT.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	                    DESCRIPTION (Data Type JobParams, JobParams instance for the AppliedRuleJob type)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void resetJobParams(MA_DS_AppliedRulesWrapper.TemplateAppliedRuleParams jobParams) {
            jobParams.auditAll = false;
            jobParams.lastRecordId = null;
            jobParams.rulesQueryWrapper = null;
            jobParams.auditFlagsTypeMap = new Map<String, String>();
            jobParams.appliedAuditFlagsMap = new Map<String, Integer>();
            jobParams.auditFlagsSampleSizeMap = new Map<String, Integer>();
            jobParams.auditFlagsFieldMap = new Map<String, List<String>>();
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to update the IUT with Applied Audit Field Flag & current state of the sync.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	                    DESCRIPTION (Data Type JobParams, JobParams instance for the AppliedRuleJob type)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void updateInUseTemplate(MA_DS_AppliedRulesWrapper.TemplateAppliedRuleParams jobParams, Integer inUseTemplateIdIndex) {
            if(inUseTemplateIdIndex < jobParams.inUseTemplateIds.size()) {
                Id inUseTemplateId = jobParams.inUseTemplateIds[inUseTemplateIdIndex];
                MA_DS_TemplateAppliedRuleSyncUtility.updateInUseTemplate(jobParams.pkgDistributionId, inUseTemplateId, jobParams.appliedAuditFlagsMap);
            }
        }

        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute on final job completion, updates In Use Template record with Applied Audit Field Flags and stores current state of the sync.
        * Method initializes & enqueue the AppliedRuleJob to purge unwanted Applied Rules.
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override void handleFinalJobCompletion() {
            MA_DS_AppliedRulesWrapper.TemplateAppliedRuleParams jobParams = (MA_DS_AppliedRulesWrapper.TemplateAppliedRuleParams)this.jobParams;
            this.updateInUseTemplate(jobParams, jobParams.currentIUTIndex);
            MA_DS_TemplateAppliedRuleSyncUtility.initPurgeAppliedRuleJob(jobParams.pkgDistributionId, jobParams.summaryDocRuleSync, jobParams.packageDocRuleSync, jobParams.originExecJob, jobParams.originExecMode, getAsyncApexJobIds(jobParams), jobParams.templateIds);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to get merge Async Apex Job Ids of ApplieRuleJob that processed Package Distribution Applied Rules as well as In Use Template Applied Rules.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    jobParams	            DESCRIPTION (Data Type JobParams, JobParams instance for the AppliedRuleJob type)
        * @return   Set<Id>                 DESCRIPTION (return Set of Async Apex Job Ids)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Set<Id> getAsyncApexJobIds(MA_DS_AppliedRulesWrapper.TemplateAppliedRuleParams jobParams) {
            Set<Id> asyncApexJobIds = new Set<Id>();
            asyncApexJobIds.addAll(jobParams.packageRulesAsyncApexJobIds);
            asyncApexJobIds.addAll(jobParams.templateRulesAsyncApexJobIds);
            return asyncApexJobIds;
        }
    }
}