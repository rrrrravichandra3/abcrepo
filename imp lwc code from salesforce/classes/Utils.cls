public without sharing class Utils {
    
    private static final String CHATTER_MSG='submitted <CANDIDATE_NAME> for the <JOB_TITLE> opening. You can review the application <URL>/<APPLICATION_ID>';
    private static final String CANDIDATE_NAME='<CANDIDATE_NAME>';
    private static final String JOB_TITLE='<JOB_TITLE>';
    private static final String APPLICATION_ID='<APPLICATION_ID>';
    private static final String URL_STR='<URL>';
    private static final String CANDIDATE_REJECTED_OFFER='Candidate Rejected Offer';
    private static final String CANDIDATE_WITHDREW_INTEREST='Candidate Withdrew Interest';
    private static final String INACTIVE_STATUS='Inactive';
    private static final Map<String, Schema.SObjectType> globalDescribe;    
    private static final String COMMA =','; 
    private static final String DOT ='.'; 
    private static final String SWF_FILE_EXTENTION ='.swf'; 
    
    public static Map<String,Set<Id>> fieldNameToJobIDsmap = new Map<String,Set<Id>>();
    public static Boolean run = true;
    //Added by Pradeep
    public static Boolean DOCUSIGN_UPDATE_FLAG = true; // flag to avoid recursion on docu sign recepient trigger.
    private static Map<String, Offer_Template__c> offerTemplatesMapByEID = new Map<String, Offer_Template__c>();
    private static Map<String, Offer_Template__c> offerTemplatesMapByName = new Map<String, Offer_Template__c>();
    private static String currentUserProfileName = null;

     //static block to cache the globalDescribe
    static {
    	globalDescribe = Schema.getGlobalDescribe();
    }
    public static Boolean runOnce() {
        if (run) {
            run = false;
            return true;
        } else {
            return run; 
        }
    }

    public static Boolean isOfferUpdateCausedByJobUpdate = false;
        
    public static String getCurrentUserProfileName() {
        if( String.isBlank(currentUserProfileName) == true) {
            Profile profile = [select Name from profile where id = :userinfo.getProfileId() LIMIT 1];
            currentUserProfileName = profile.Name;
        }
        return currentUserProfileName;
    }
    
    /**
     * Tests specified new and old records for changes in specified set of fields.
     * @param field is a string.
     * @param oldRecord is a SObject.
     * @param newRecord is a SObject.
     * @return boolean.
     */
    public static Boolean hasChanges(String field, SObject oldRecord, SObject newRecord) {
        if (oldRecord == null) {
            return true;
        }
        return (oldRecord.get(field) != newRecord.get(field));
    } 

    /**
     * Tests specified new and old records for changes in specified set of fields for Job Req After Update trigger.
     * @param field is a string.
     * @param oldRecord is a SObject.
     * @param newRecord is a SObject.
     * @return boolean.
     */
    public static Boolean jobHasChanges(String field, SObject oldRecord, SObject newRecord) {
        if (oldRecord == null) {
            return true;
        }
         if(oldRecord.get(field) != newRecord.get(field)){
            if(!(fieldNameToJobIDsmap.containsKey(field))){
                fieldNameToJobIDsmap.put(field,new Set<Id>());
            }
            (fieldNameToJobIDsmap.get(field)).add(newRecord.Id);
         }
        return (oldRecord.get(field) != newRecord.get(field));
    } 

    /**
    * Checks if for the current record, only a specific field changed, and nothing else was updated
    * @param field is a string
    * @return boolean
    */
    public static Boolean onlyGivenFieldChanged(String field, SObject newRecord){
        if(!(fieldNameToJobIDsmap.containsKey(field))){ return false;}
        else{
            boolean onlyThisFieldChanged = true;
            for(String currField : fieldNameToJobIDsmap.keySet()){

                if(currField == field){
                    onlyThisFieldChanged = onlyThisFieldChanged && (fieldNameToJobIDsmap.get(currField).contains(newRecord.Id));
                }
                else{
                    onlyThisFieldChanged = onlyThisFieldChanged && !(fieldNameToJobIDsmap.get(currField).contains(newRecord.Id));
                }

            }
            return onlyThisFieldChanged;
        }
    }


    
     /**
     * Computes the token of a candidate's resume
     * @param candidate the ID of the candidate.
     * @param resume the ID of the resume.
     * @return a unique token for this resume and candidate combination.
     */
    public static String getResumeToken(Id candidate, Id resume) {
        //$ a bit of salt
        return getShaHash('$' + candidate + resume);
    } 

     /**
     * Returns the SHA1 hash of a supplied string
     * @param src the input string.
     * @return The SHA hash of the input string.
     */
    public static String getShaHash(String src) {
        Blob inp = Blob.valueOf(src);
        Blob enc = Crypto.generateDigest('SHA1', inp); 
        return  EncodingUtil.convertToHex(enc); 
    } 
    
    /**
     * Create the sharing records for the hiring managers on the candidates.
     * @param jobAndManagerMap is a Map.
     * @param hiringManager is  a Id.
     */
     
     /*
    public static void creatingSharingOnCandidatesForHM(Map<Id,Id> jobAndManagerMap) {

    }
    */
    
    
   /**
    * pupulating the contact share object with the appropriate values.
    * @param hiringManager is a Id.
    * @param candidateId is a Id.
    * @return contactShare.
    */
    /*
    public static ContactShare createContactShare(Id hiringManager,Id candidateId) {
        ContactShare contactShare = new ContactShare(UserOrGroupId = hiringManager,
                                                     ContactAccessLevel = 'Read',
                                                     //RowCause=Schema.ContactShare.RowCause.Manual,
                                                      ContactId = candidateId);
                                                      
        return  contactShare;                                             
    } 
    */
    /**
     * Method to delete the candidate sharing for the old manager.
     * @param jobRequisition
     */
     /*
    public static void deleteCandidateSharingForOldManager(Map<Id,Id> jobAndOldHiringManagerMap) {
        
        
        
    }    
    */
  
    /**
     * Method to get the job count based on the hiring manage and the candidates.
     * @param managerId is Id.
     * @param candidateIdSet is Set.
     * @return candidateJobCntMap is a map.
     */
     /*
    private static Map<Id,Integer> getJobCountByHMAndCandidate(Id managerId,Set<Id> candidateIdSet) {
        
    }
    */
    
    /**
     * Creating the manual sharing rules as the job requisition is associated with a candidate.
     * Sharing rules are created on the candidate for hiring manager, so the hiring manager looking a the job req could see the 
     * candidates as they are not visible to HM by default due to private sharing model.
     * @param applicationAndjobCandidateMap is a map.
     */
     /*
    public static void shareCandidateWithHMOnAppCreation(Map<Id,Map<Id,Id>> applicationAndjobCandidateMap) {
       
    }
    */
    /**
     * Method checks if the job req is already shared with users or not and then create the manual sahring on 
     * the reqs for hiring managers, finance business partners and recruiters.
     * @param jobAndManagerIdMap is a map.
     */
    public static void createJobSharingRecords(Map<Id,Set<Id>> jobAndManagerIdMap) {
       
        
    }
    
    /**
     * Method to get the all the sharing records for the given job ids set.
     * @param jobIdSet is a set.
     * @return sharedRecordsByJobMap is a map.
     */
    private static Map<Id, Set<Id>> getAlreadySharedRecords(Set<Id> jobIdSet) {
       return null;
    }
    
    /**
     * Utility mathod to populate the job id and the manager Id to a map.
     * @param jobId is Id.
     * @param userId is Id.
     * @param jobAndManagerIdMap is a map.
     */ 
    public static void addJobAndManagerIdToMap(Id jobId , Id userId , Map<Id, Set<Id>> jobAndManagerIdMap) {
        if (!jobAndManagerIdMap.containsKey(jobId)) {
            jobAndManagerIdMap.put(jobId, new Set<Id>());
        }
        jobAndManagerIdMap.get(jobId).add(userId);
    }
    
   
    
    /**
     * Method to share the contact with the Hiring manager on Job requisition , when the candidate is associated to an application .
     * @param candidateMap is a Map.
     */
     /*
    public static void reCreateCandidateShareOnOwnerChange(Map<Id,Contact> candidateMap) {
       
        
    }
    */
    
    /*
    private static Map<Id,Set<Id>> getCurrentContactSharing(Map<Id,Contact> candidateMap) {
        Map<Id,Set<Id>> contactShareMap = new Map<Id,Set<Id>>();
        for(ContactShare contactShare :[select id,UserOrGroupId, contactId from ContactShare where contactId IN :candidateMap.keySet()]) {
            if (!contactShareMap.containsKey(contactShare.UserOrGroupId)) {
                contactShareMap.put(contactShare.UserOrGroupId, new Set<Id>());
            }
            contactShareMap.get(contactShare.UserOrGroupId).add(contactShare.contactId);
        }
        return contactShareMap;
    }
    */
    
    /**
     * Method to create the candidate secure info object when a new candidate is created.
     * @param candidateIdSet is a set.
     */
    @future
    public static void createCandidateSecureInfoPlaceHolder(Set<Id> candidateIdSet) {
        
        List<Candidate_Secure_Info__c> candidateSecureInfoList = new List<Candidate_Secure_Info__c>();
        List<Lead> LeadList = [ select Id, ConvertedContactId from Lead where ConvertedContactId in : candidateIdSet ];
        Map<Id, Id> CandidateLeadMap = new Map<Id, Id>();

        //to ensure ENTITY_IS_DELETED is not erroring out ( unit test work around )
        Map<Id, Contact> CandidateMap = new Map<Id, Contact>( [select Id from contact where Id in : candidateIdSet ] );

        for ( Lead l : LeadList ){
            CandidateLeadMap.put( l.ConvertedContactId , l.id );            
        }

        for(Id candidateId : candidateIdSet) {
            if ( CandidateLeadMap.get( candidateId ) == null && CandidateMap.containsKey(candidateId) )
                candidateSecureInfoList.add(new Candidate_Secure_Info__c(Candidate__c =candidateId));
        }
        if (candidateSecureInfoList.size() > 0) {
            insert candidateSecureInfoList;
        }
    }
    public static boolean isNumber(String value) {
        boolean isNumber = true;
        try {
            Integer.valueOf(value);
        } catch (Exception ex) {
            isNumber= false;
        }
        return isNumber;
    }    
    
   
    
    

	public static void UpdateAppInsertReferral( Map<Id, Endorsement__c> AppEndorsement, Set<Id> endorseIdSet ){
		
		

	}    
	
	public static void ManualShareEndorsement( List<Endorsement__c> EndorsedShared ){

		List<Endorsement__Share> endorseList = new List<Endorsement__Share>();
		
		for ( Endorsement__c endorse : EndorsedShared  ){
			Endorsement__Share endorseShare = new Endorsement__Share ( UserOrGroupId = endorse.Endorser__c, AccessLevel = 'Edit', ParentId = endorse.Id );
			endorseList.add( endorseShare );				
		}
		
		upsert endorseList;		
		
	}
	
	public static void removeManualEndorseSharing(Set<Id> endorseSet){

		List<Endorsement__Share> ManualShared = [ select Id from Endorsement__Share where ParentId IN : endorseSet and ROWCAUSE ='Manual'];

		delete ManualShared;	
	}
	
	public static Id getEmployeeReferralSource(){
		Id ActiveSourceId;

		return ActiveSourceId;
		
	}
	
	
    /**
     * Method to load the candidate resume onto the application , if the resume has been updated.
     * @param contactMap is a Map.
     */
    public static void updateResumeOnCandidateApplication(Map<Id,Contact> contactMap){
        
         
    } 
    
    /**
     * Method to load the candidate resume onto the application , if the resume has been updated.
     * @param contactMap is a Map.
     */    
    public static void updateResumeOnCandidateOffer(Map<Id,Contact> contactMap){ 
       
    }
    
    /**
     * Method to check if the offer is standard offer or not. If it standard offer we than populate the approval chain based on the
     * role hierarchy. If it is not standard offer those offer approvals are built using the configurations and aprroval list is hardcoded.
     * @param department is a TF2_Department__c.
     * @param configuration is a TF2Settings__c.
     * @return standardOffer is a boolean
     */
    public static boolean isStandardOffer(TF2_Department__c department , TF2Settings__c configuration) {
        boolean standardOffer = true;
    
        //if (configuration.NO_RH_For_Functional_Group__c != null && configuration.NO_RH_For_Functional_Group__c.equalsIgnoreCase(department.ECOMM_Level_3__c)) {
        if (configuration.NO_RH_For_Functional_Group__c != null ) {
            for(String functionalGrp : configuration.NO_RH_For_Functional_Group__c.split(COMMA)) {
                if (functionalGrp.equalsIgnoreCase(department.ECOMM_Level_3__c)) {
                    standardOffer = false;
                    break;
                }
            }
        }
        
        if (standardOffer) {
            String departmentNumber = department.Department_Number__c;
            if(departmentNumber != null && configuration.SE_Departments__c != null && departmentNumber.length() > 0 && departmentNumber.length() == 5) {
                departmentNumber = departmentNumber.substring(2,5);

                for(String departmentNo : configuration.SE_Departments__c.split(COMMA)) {
                    if (departmentNo.equals(departmentNumber)) {
                        standardOffer = false;
                        break;
                    }
                }
            }
        }

        return standardOffer;
    }
    
    /**
     * Utility method to check the grade level on the offer and the configurations match.
     * @param gradeLevel is a String.
     * @param configGradeLevel is a string(Has mutliple grade levels separated by a delimmiter).
     * @return gradeLevelMatch is a boolean.
     */
    public static boolean isGradeLevelMatch(String gradeLevel,String configGradeLevel) {
        boolean gradeLevelMatch = false;
        if (configGradeLevel != null && configGradeLevel.trim().length() > 0) {
            for(String grdLevel : configGradeLevel.split(COMMA)) {
                if(grdLevel.equals(gradeLevel)) {
                    gradeLevelMatch = true;
                    break;
                }
            }
        }
        
        return gradeLevelMatch;
        
    } 
    
    /**
     * Method to get the candidate details given the candidate Id's.
     * @param candidateJobIdMap is a map.
     * @return contactDetailsMap is a map.
     */
    private static Map<Id,Contact> getContactDetailsMap(Map<Id, Id> candidateJobIdMap) {
        Map<Id,Contact> contactDetailsMap = new Map<Id,Contact>([select Id,Name,email, phone from Contact where Id IN : candidateJobIdMap.keySet()]);
        return contactDetailsMap;
    }
    
    /**
     * Method to retrieve the chatter groups based on the names provided.
     * @param groupNameSet is a set
     * @return groupDetailsMap is a map.
     */
    private static Map<String, CollaborationGroup> getChatterGroupDetails(Set<String> groupNameSet) {
        Map<String, CollaborationGroup> groupDetailsMap = new  Map<String, CollaborationGroup>();
        if (groupNameSet.size() > 0) {
            groupDetailsMap = new  Map<String, CollaborationGroup>();
            for(CollaborationGroup groupInfo : [select id,name from CollaborationGroup where Name IN : groupNameSet]) {
                groupDetailsMap.put(groupInfo.name, groupInfo);
            }
        }
        return groupDetailsMap;
    }
    
    /**
     * Method to retrieve the candidate resumes so that we could post it to the chatter, given the candidate id's.
     * @param candidateJobIdMap is a map.
     * @return candidateAttachmentMap is a map.
     */
    private static Map<Id, Attachment> getCandidateResumes(Map<Id, Id> candidateJobIdMap) {
         Map<Id, Attachment> candidateAttachmentMap = new Map<Id, Attachment>();
         for (Attachment attachmentInfo : [SELECT Id, Name, ParentId,Body FROM Attachment WHERE ParentId  IN : candidateJobIdMap.keySet() and Name like 'Resume%']) {
            if(!candidateAttachmentMap.containsKey(attachmentInfo.ParentId) && isNonSWFFile(attachmentInfo.Name)){
                candidateAttachmentMap.put(attachmentInfo.ParentId, attachmentInfo);
            }
         }
         return candidateAttachmentMap;
    }
    
    
    /**
     * Method to check if the attachment is a swf file or not.
     * @param filename is a string.
     * @return isNonSWFFile is a boolean. 
     */
    public static boolean isNonSWFFile(String fileName) {
        boolean isNonSWFFile = false;
        if (fileName != null) {
            String fileExtension = fileName.substring(fileName.lastIndexOf(DOT),fileName.length());
            if(fileExtension != null && !fileExtension.equalsIgnoreCase(SWF_FILE_EXTENTION)) {
                isNonSWFFile = true;
            }
        }
        
        return isNonSWFFile;
    }    

    /**
     * Method to post a resume onto the chatter group specified on the Job Req.
     * @param candidateJobIdMap is a map.
     * @param submittalMap is a map.
     */ 
    public static void createChatterPostOnHMSubmittals(Map<Id, Id> candidateJobIdMap,Map<Id, ts2extams__Custom_stage_1__c> submittalMap) {
        
    }    
    /**
     * Method to populate the chatter post.
     * @param groupId is a string.
     * @param postBody is a string.
     * @param attachmentInfo is a Attachment.
     * @return post is a FeedItem.
     */
    private static FeedItem getFeedItem(Id groupId,String postBody,Attachment attachmentInfo) {
        FeedItem  post = new FeedItem();  
        post.ParentId = groupId;   
        post.Body=postBody;  
        post.ContentData = attachmentInfo.body;  
        post.ContentFileName = attachmentInfo.name;
        return post;
    }

   /**
    * Get a list of approvals requires with the user's action
    * @param User Id
    */
    public static List<ProcessInstanceWorkitem> getMyApprovals ( Id UserId ){
        
        List<ProcessInstanceWorkitem> approvals = new List<ProcessInstanceWorkitem>();
        
        approvals = [Select ProcessInstance.Id, ProcessInstance.TargetObject.Name, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Type, ProcessInstance.LastModifiedDate, ProcessInstance.LastModifiedById, ProcessInstance.LastModifiedBy.Name, Id From ProcessInstanceWorkitem where ActorId =: UserId ];
 
        return approvals;
    }

	public static List<Endorsement__c> getMyEndorsements ( Id UserId ){
		
		list<Endorsement__c> endorsements = new list<Endorsement__c>();
		
        endorsements = [select Id, Name, Candidate__c, Endorser__c, Job_Requisition__c, Status__c  from Endorsement__c where Endorser__c =: UserId and Status__c = 'Pending' ];
		
		return endorsements;
		
	}

   /**
    * Get a list of candidate referrals made by the user with a supplied email address
    * @param email The email address of the logged in user
    * @param startTime For filtering by time - start time
    * @param endTime or filtering by time - end time
    * @param maxRows The max number of rows to be returned
    */
    public static List<ReferralInfo> getMyReferrals(String email, DateTime startTime, DateTime endTime, Integer maxRows) {

        List<ReferralInfo> referralInfos = new List<ReferralInfo>();
        return referralInfos;
    }
        
    
    
    public static ApexPages.StandardSetController getPaginatedJobs(String location, String category,String division,String country,String businessunit,Integer maxRows, Integer displayRows) {
        return getPaginatedJobs(location,category,division,country,businessunit,null,null,maxRows,displayRows);
    }
    
    /**
    * Get a paginated list of jobs by location and category
    * @param location The The location of the job req
    * @param category Job category
    * @param maxRows The max number of rows to be returned
    */
    public static ApexPages.StandardSetController getPaginatedJobs(String location, String category,String division,String country,String businessunit,String sortField,String sortOrder ,Integer maxRows, Integer displayRows) {
        ApexPages.StandardSetController paginator = null;

        return paginator;
    }     
    
    /**
    * Get a paginated list of jobs by location and category in JobInfo object list
    * @param location The The location of the job req
    * @param category Job category
    * @param maxRows The max number of rows to be returned
    */
    public static List<JobInfo> getJobsByLocationByCategory(ApexPages.StandardSetController paginator,String jobDetailsPartialURL) {
        
        List<SObject> sobjects = paginator.getRecords();
        List<JobInfo> jobInfos = new List<JobInfo>();

        return jobInfos;
    }
     
    
    
    /**
     * Method to match the department with the list of departments separated with a comma in a string.
     */
     
    private static boolean isDepartmentMatched(String departments, String departmentNumber) {
        boolean isDepartmentMatched =  false;
        if (departments != null && departments.length() > 0 &&
            departmentNumber != null && departmentNumber.length() > 0) {
            //String departmentNo =departmentNumber.substring(2,5);
            String departmentNo =departmentNumber;
             for(String department : departments.split(COMMA)) {
                 if (departmentNo.equals(department)) {
                     isDepartmentMatched = true;
                     break;
                 }
             }
        }
         return isDepartmentMatched;
    }
    
    public static boolean isCorpSalesDepartment(String departments,String departmentNumber) {
        return isDepartmentMatched(departments,departmentNumber);
    }
    
    public static boolean isWorldWideSalesDepartment(String departments,String departmentNumber) {
        return isDepartmentMatched(departments,departmentNumber);
    } 
    public static boolean isCorpOrFieldSalesManagersDepartment(String departments,String departmentNumber) {
        return isDepartmentMatched(departments,departmentNumber);
    }  
    public static boolean isSalesStratergyOrProductivityDepartment(String departments,String departmentNumber) {
        return isDepartmentMatched(departments,departmentNumber);
    } 
    public static boolean isSROrEBRDepartment(String departments,String departmentNumber) {
        return isDepartmentMatched(departments,departmentNumber);
    }  
    
    public static void loadManagersData(Set<Id>hiringManagerIds,Map<Id, User>managerMap,Map<Id, User> fifthLevelManagerMap){
        Set<Id> fourthLevelManagerIds = new Set<Id>();
        for (User curUser : [select id, Name,level_1__c,PCOMM__c, Manager__r.Manager__c,Manager__r.Title,Manager__r.Manager__r.Manager__c,Manager__r.Manager__r.Title,Manager__r.Manager__r.Manager__r.Manager__c,Manager__r.Manager__r.Manager__r.Title,Manager__r.Manager__r.Manager__r.Manager__r.Title from User where Id IN : hiringManagerIds]) {
            managerMap.put(curUser.Id, curUser);
            if(curUser.Manager__r.Manager__r.Manager__r.Manager__c != null){
                fourthLevelManagerIds.add(curUser.Manager__r.Manager__r.Manager__r.Manager__c);
            }
        }
        for (User curUser : [select id, Name,level_1__c,PCOMM__c, Manager__r.Manager__c,Manager__r.Title,Manager__r.Manager__r.Manager__c,Manager__r.Manager__r.Title,Manager__r.Manager__r.Manager__r.Manager__c,Manager__r.Manager__r.Manager__r.Title,Manager__r.Manager__r.Manager__r.Manager__r.Title from User where Id IN : fourthLevelManagerIds]) {
            fifthLevelManagerMap.put(curUser.Id, curUser);
        }
    }  
    
    /**
    * method to check if the current approver is the last approver in the role heierachy.
    * @param currentApproverId is a ID.
    * @param approverList is a List.
    */
   private static boolean isApproverMatched(Id currentApproverId, List<User> approverList) {
       boolean isMatched = false;
       for(User approver : approverList) {
           if (currentApproverId == approver.Id) {
               isMatched = true;
               break;   
           }    
       }
       
      return isMatched;     
   }    
    
    
    /**
     * Method to determine if the current user who is accessing the candidate details is hiring manager or not.
     * @param userId is id.
     * @param configurations is TF2Settings__c.
     * @return currentuserHM is a boolean.
     */
    public static boolean isCurrentUserHM(Id userId,TF2Settings__c configurations) {
        boolean currentuserHM = true;

        if (userId !=  null) {
            Set<Id> permissionSetId = new Set<Id>();
            for(PermissionSetAssignment assignment : [SELECT PermissionSetId FROM PermissionSetAssignment where AssigneeId =: userId]) {
                permissionSetId.add(assignment.PermissionSetId);
            }
            if (permissionSetId.size() > 0) {
                Set<String> permissionSetName = new Set<String>();

                if (configurations.Access_To_Candidate_Data_Permset_Name__c != null) {
                    for (String permSetName : configurations.Access_To_Candidate_Data_Permset_Name__c.split(Constants.COMMA)) {
                        permissionSetName.add(permSetName);
                    }

                    boolean isMatched = false;
                    for(PermissionSet permissionSet : [SELECT Id,Name,Label FROM PermissionSet where Id IN : permissionSetId]) {

                        for(String permSetName : permissionSetName) {
                            if (permissionSet.Label.equalsIgnoreCase(permSetName)) {
                                currentuserHM = false;
                                break;
                            }
                        }
                    }
                 } else {
                     currentuserHM = false;
                 }
            } else {
                currentuserHM = false;
            }
        
        }

        return currentuserHM;
    }  
    
   
    
     /**
     * Getting the Divisiion picklist values and validate with the division provided by the user.
     * @param divisionName is a string.
     * @return pickListDivisionName is a string.
     */
    public static String checkDivisionExists(String divisionName){
        String pickListDivisionName = null;

        List<DynamicValue__c> lst_dynamicValues= DynamicValue__c.getAll().values();
        List<String> lst_divisionEntries = new List<String>();

        for (DynamicValue__c value : lst_dynamicValues) {
            if (value.Type__c == 'Division') {
                lst_divisionEntries.add(value.Name);
            }
        }

        lst_divisionEntries.sort();
        


            for( String divName : lst_divisionEntries ){
                if(divName.equalsIgnoreCase(divisionName)){
                    pickListDivisionName = divName;
                    break;
                }                
            }

        
        return pickListDivisionName;
    } 
     /**
     * Getting the Job category picklist values and validate with the category provided by the user.
     * @param job category name is a string.
     * @return pickListDivisionName is a string.
     */
    public static Boolean checkJobCategoryExists(String categoryName){
       
        return false;
    }       
    
    public static Boolean checkBusinessUnitExists(String businessunit ){
    	list<Business_Unit__c> bu = [ select Id from Business_Unit__c where Active__c = true and Name =: businessunit];
    	
    	if ( bu.size() == 1 ){
    		return true;
    	}
    	return false;
    }
    /**
     * Method to load the job requistions details onto the offer object, when ever job requisistion is updated.
     *@param jobIdSet is a set.
     */
    public static void loadJobDetailsOntoOffers(Set<Id> jobIdSet, List<Id> jobIdsToUpdateOffers) {
        
    }
    
    /**
     * Utility method to format the currency values.
     *@param currencyMultiplier is a decimal.
     *@param value is a decimal
     */
    public static String formatCurrencyValues(Decimal currencyMultiplier , Decimal value) {
        String formattedValue ='';
        if (currencyMultiplier != 1) {
            Decimal multiplieValue = currencyMultiplier * value;
            multiplieValue = multiplieValue.setScale(2);
            formattedValue = multiplieValue.format();
            if (formattedValue != null) {
                if (formattedValue.indexOf(Constants.DOT) != -1) {
                   String noOfDigits = formattedValue.substring(formattedValue.indexOf(Constants.DOT)+1, formattedValue.length());
                   if (noOfDigits.length() == 1) {
                       formattedValue = formattedValue + '0';   
                   }
                }
            }
            formattedValue = '(USD '+ formattedValue +')';
        }
        return formattedValue;
    }
    
   
    
     public static boolean checkEmailAddress(String email) {
        boolean isValidEmail = true;
        if (email != null) {
            String tempEmail = 'Etest'+ string.valueof(UserInfo.getOrganizationId()).substring(10)+'@salesforce.com';
            String tempEmail1 = 'test'+ string.valueof(UserInfo.getOrganizationId()).substring(10)+'@salesforce.com';
            String domain = email.substring(email.indexOf('@')+1, email.length());
            if (domain.equalsIgnoreCase('salesforce.com')) {
                if (tempEmail.equalsIgnoreCase(email)) {
                    isValidEmail = false;
                } else if(tempEmail1.equalsIgnoreCase(email)) {
                    isValidEmail = false;
                } else  {
                    String tempEmail2 = '';
                    for (Integer i=0; i<200; i++) {
                        tempEmail2 = '';
                        tempEmail2 = 'up' + i + tempEmail1;
                        if(tempEmail2.equalsIgnoreCase(email)) {
                            isValidEmail = false;
                            break;
                        } 
                    }
                }
            }
        }
        
        return isValidEmail;
    }
    
    /**
     * Method to load the business unit mappings based on the division.
     *@param divisionSet is a set.
     *@param businessUnitMappings is a map.
     *@param mappedDivisionSet is a set.
     */
    private static Map<Id,Business_Unit_Mapping__c> getBusinessUnitMappingsData(String divisionName) {
        List<Business_Unit_Mapping__c> bums = [Select id,name,Business_Unit__c,Division__c from Business_Unit_Mapping__c Where Division__c =: divisionName];
        Map<Id,Business_Unit_Mapping__c> bumappings = new Map<Id,Business_Unit_Mapping__c>();
        for(Business_Unit_Mapping__c bum : bums){
            bumappings.put(bum.Business_Unit__c, bum);
        }
        return bumappings;
    }
    
    /**
     * Method to build the in clause.
     * @param ids is a set.
     * @return is a string.
     */
    public static String buildInExpression(Set<Id> ids) {
        String rids = '(';
        for (Id id : ids) {
            rids += ('\'' + id + '\',');
        }
        return rids.substring(0,rids.length() - 1) + ')';
    }
    
    /**
     * Method to build the in clause.
     * @param ids is a set.
     * @return is a string.
     */
    public static String buildInExpression(List<String> dataList) {
        String dataString = '(';
        for (String data : dataList) {
            dataString += ('\'' + String.escapeSingleQuotes(data) + '\',');
        }
        return dataString.substring(0,dataString.length() - 1) + ')';
    }
    

    public static void resetOfferTemplates() {
        offerTemplatesMapByEID = new Map<String, Offer_Template__c>();
        offerTemplatesMapByName = new Map<String, Offer_Template__c>();
    }

    public static Map<String, Offer_Template__c> getFeedbackTemplatesMapByEID(){
        if(offerTemplatesMapByEID.size() == 0){
            String key = '';
            for(Offer_Template__c template : [SELECT Id,Name,External_ID__c,Template_ID__c  FROM Offer_Template__c WHERE Template_ID__c != null And Country_ISO_Code__c = 'Feedback' ]){
                offerTemplatesMapByEID.put(template.External_ID__c, template);
            }
        }
        return offerTemplatesMapByEID;    	
    }
    
    public static Map<String, Offer_Template__c> getOfferTemplatesMapByEID(String country) {
        if(offerTemplatesMapByEID.size() == 0){
            String key = '';
            for(Offer_Template__c template : [SELECT Id,Name,External_ID__c,Template_ID__c,Country_ISO_Code__c  FROM Offer_Template__c WHERE Template_ID__c != null And ( Country_ISO_Code__c= :country or Country_ISO_Code__c='ALL')]){
                
                key = template.Country_ISO_Code__c + template.External_ID__c;
                key = key.toLowerCase();
                offerTemplatesMapByEID.put(key, template);
            }
        }
        return offerTemplatesMapByEID;
    }
    public static Map<String, Offer_Template__c> getOfferTemplatesMapByName(String country) {
        if(offerTemplatesMapByName.size() == 0){
            String key = '';
            for(Offer_Template__c template : [SELECT Id,Name,External_ID__c,Template_ID__c,Country_ISO_Code__c  FROM Offer_Template__c WHERE Template_ID__c != null And ( Country_ISO_Code__c= :country or Country_ISO_Code__c='ALL')]){
                key = template.Country_ISO_Code__c + template.name;
                key = key.toLowerCase();
                offerTemplatesMapByName.put(key, template);
            }
        }
        return offerTemplatesMapByName;
    }
    
    public static Id PipelineId( String str ){
		
			return null;    	
    }

	public static void LoadJobLocationToPipeline ( Map<Id, String> JobLocation, List<Id> jobIdList ){
		
	}
    
     
    
    /**
    /**
    *This is a future method to update the latest stage field on Job Req.
    *This along with the code in the application trigger can be removed when 
    *the current stage issue is fixed in the managed package
    *@param applicationIDList: list of application Ids that is updated or create
    **/
    @future   
	public static void updateLatestStageFieldAsFuture(List<Id> applicationIdList){
		
	
	}	

	
    //To help backfill the AMS2 custom stage Id back into application record
    public static void UpdateRecordIdtoAMSObject( Map<Id,Id> ApplicationMap, List<Id> applicationList ){
    
		      
    
    }
    
   /*
   *Methods to get recruiter and hiringmanager related to job that is attached to the interview
   *@param recruiterIdList: list of recruiter Ids
   *@param hmIdList: list of hiringmanager ids
   *@param interviewIdList: list of of the interview objects
   *return void 
   */
    public static void addRecruiterAndHmToSet(Set<Id> hmSet,Set<Id> interviewIdSet, Set<Id> ownerIdSet){
    	
    	
    	
    }
   
    /*
   *Methods to share interviewfeedback with hiring manager and recruiter
   *@param recruiterIdList: list of recruiter Ids
   *@param hmIdList: list of hiringmanager ids
   *@param interviewFDBIdList: list of interview feedback id
   *return void 
   */ 
   public static void deleteInterviewFeedBackShare(Set<Id> hmIdSet, Set<Id> interviewFDBIdList){
   	List<Interview_Feedback__Share> intFDBShareList = new List<Interview_Feedback__Share>();
  	List<Id> userId = new List<Id>();
  	userId.addAll(hmIdSet);
   	intFDBShareList =[select id from Interview_Feedback__Share where ParentId in:interviewFDBIdList and UserOrGroupId in:userId];
   	
   	if(intFDBShareList.size()>0){
   		delete intFDBShareList;
   	}   	   	
   }
   /*
   *Methods to share interviewfeedback with hiring manager and recruiter
   *@param recruiterIdSet: list of recruiter Ids
   *@param hmIdSet: list of hiringmanager ids
   *@param interviewFDBIdSet: list of interview feedback id
   *return void 
   */ 
   public static void shareInterviewFeedBack(Set<Id> hmIdSet, Set<Id> interviewFDBIdSet){
   	List<Interview_Feedback__Share> intFDBShareList = new List<Interview_Feedback__Share>();
   	for(Id hmId:hmIdSet){
   		for(Id intFDBid:interviewFDBIdSet){
   			intFDBShareList.add(createInterviewFDBObject(intFDBid,hmId));	
   			
   		}   		
   	}
   	
   	if(intFDBShareList.size()>0){
   		insert intFDBShareList;	
   	}
   	
   	
   }
   
   /*
   *Methods to create an interview feedback share object
   *@param feedbackId: id of the interview feedback that has to be shared
   *@param userId: user with which the interview feedback object has to be shared
   *return interview feedback share object 
   */
   public static Interview_Feedback__Share createInterviewFDBObject(Id feedbackId , Id userId) {
        Interview_Feedback__Share feedbackShare = new Interview_Feedback__Share(UserOrGroupId = userId,
                                                                 AccessLevel = 'Read',
                                                                 ParentId = feedbackId);                                                                 
        return feedbackShare;                                                         
    }
    
   /*Method to popluate interview feedback and ownerId of the interview feedback if any for a list of Job
   *@param jobIdList: list of job
   *@param interviewFDBIdSet: set of interview feedback
   *@param ownerIdSet: set of owner id of interview feedback
   */
    public static void populateInterviewFDBForJob(List<Id> jobIdList,Set<Id> interviewFDBIdSet,Set<Id> ownerIdSet){
    	List<Id> interview1IdList = new List<Id>();
    	for (ts2extams__Custom_stage_2__c interview1 : [select id from ts2extams__Custom_stage_2__c where ts2extams__Job__c in:jobIdList]){
    		interview1IdList.add(interview1.id);
    	}    	
    	List<Id> interview2IdList = new List<Id>();
    	for (ts2extams__Custom_stage_3__c interview2 : [select id from ts2extams__Custom_stage_3__c where ts2extams__Job__c in:jobIdList]){
    		interview2IdList.add(interview2.id);
    	}    	
    	List<Id> interview3IdList = new List<Id>();
    	for (ts2extams__Custom_stage_4__c interview3 : [select id from ts2extams__Custom_stage_4__c where ts2extams__Job__c in:jobIdList]){
    		interview3IdList.add(interview3.id);
    	}   	
    	for (Interview_Feedback__c interviewFDB : [select id,Owner.Id from Interview_Feedback__c where Interview_1__c in:interview1IdList or Interview_2__c in:interview2IdList or Interview_3__c in:interview3IdList]){
    		interviewFDBIdSet.add(interviewFDB.id);
    		ownerIdSet.add(interviewFDB.Owner.Id);
    	}
    	
    }
    
   /*Method to fetch any of the interview objects from a list of jobId 
   *@param objectAPIName: name of any of the 3 interview object
   *@param jobIdList: list containing the jobReq id
   *return: void 
   */
    public static List<SObject> getInterviewRecordfromJobReq(String objectAPIName, Set<Id> jobIdList){
	   		String idString = '(\'';
			for (Id thisId : jobIdList) {
	    		idString += thisId + '\',\'';
			}
			idString = idString.substring(0,idString.length()-2); //removing ' from the end
			idString += ')';  
	   		String soqlQuery='select id,Hiring_Manager__c,Primary_Recruiter__c,Recruiting_Coordinator__c,Internal_Recruiter__c,ts2extams__Job__c from '+objectAPIName+ ' where ts2extams__Job__c IN '+idString;
	   		
	   		return Database.query(soqlQuery);
   }

   /*Method to output japan nda wording into a VF for japan
   *@param none
   *return: string from the form item 
   */
   public static String locateFirstElementFromForm(){ 

    JSForms__Form__c form;
    JSForms__Item__c item;

    try { 

        form = [ select Id from JSForms__Form__c where JSForms__Title__c = '秘密保持契約' limit 1 ];
        
        if ( form != null )
            item = [ select Id, JSForms__TextHtml_Content__c from JSForms__Item__c where JSForms__Form__c =: form.Id and JSForms__Order__c = 0.0];
    } catch ( Exception ex ){

            return null;        
    }
    return item.JSForms__TextHtml_Content__c != null ? item.JSForms__TextHtml_Content__c : null;
	}
   
   


/**
    * Story W-3246956 Execute a before update of Job Req object
    * and check validation on Plan Start Date Of Job Req object to see if any Placemenrrecord in sync status with workday.
    **/
    public static Map<Id,Id> checkValidationPlanStartDate(Set<Id> jobReqIds) {
    
        Map<Id,Id> jobReqIdMap = new Map<Id,Id>();
      
        
        return jobReqIdMap;
        
    }

    private static Set<Id> sysAdminProfileIds = new Set<Id>();
    private static Boolean profilesCached = false;
    private static Set<String> sysAdminProfileNames = new Set<String>{'System Administrator', 'systemadministrator'}; 

    private static void getSysAdminProfiles(){
        if(!profilesCached){
            sysAdminProfileIds = (new Map<Id, Profile>([Select Id from Profile where Name IN :sysAdminProfileNames])).keySet();
            profilesCached = true;
        }
    }

    public static Boolean isUserSysAdmin(Id currUserProfileId){
        getSysAdminProfiles();
        if(sysAdminProfileIds.contains(currUserProfileId)){return true;}
        else {return false;}
    }

    // Returns a dynamic SOQL statement for the whole object, includes only creatable fields
    public static string getCreatableFieldsSOQL(String objectName, String whereClause){
         
        String selects = '';
        
        if (whereClause == null || whereClause == ''){ return null; }
         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
         
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
         
    }
}