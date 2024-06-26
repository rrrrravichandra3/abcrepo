public with sharing class CandidateAncillaryDetailsECTL extends Pagination {

   public Contact selectedCandidate{get;set;}
   private Set<Id> candidateRelatedIdSet{get;set;}
   public List<AncillaryDetails> completeAncillaryDataList {get; private set;}
   public List<AncillaryDetails> ancillaryDataList {get; private set;}
   public String dataToShow {get; private set;} 
   public boolean isHiringManager{get; private set;}  
   public String pageTitle {get; private set;} 
   
   
    /**
     * Constructor for the class.
     */
    public CandidateAncillaryDetailsECTL() {
         currentPage = 1;
         this.isHiringManager = false;
         this.completeAncillaryDataList = new List<AncillaryDetails>();
         //Candidate on which we have clicked to perform updation.
         String selectedCandidateId =  ApexPages.currentPage().getParameters().get('ID');
         //Start: Pradeep: Security fix (Validate the Id parameter)
 		try
 		{
 			Id cId = selectedCandidateId;
 		}
 		catch(Exception e)
 		{
 			System.debug('Invalid Id parameter');
 			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Invalid ID parameter.'));
 			return;
 		}
     	//End:Pradeep
         dataToShow = ApexPages.currentPage().getParameters().get('DATA_TO_SHOW');
         if(selectedCandidateId!=null) {
         	// retrieving candidate details.
             selectedCandidate = [Select Id,AccountiD ,Email,Name ,Phone from Contact where id =:selectedCandidateId];
         }  
         
         TF2Settings__c configurations = TF2Settings__c.getInstance();
         // checking whether the current user is hiring manager or not, as we don't want to show  all the details to hiring manager.
    	 this.isHiringManager = Utils.isCurrentUserHM(UserInfo.getUserid(), configurations);
         if (!this.isHiringManager) {
         	Set<Id> candidateIdSet = new Set<Id>();
         	if (selectedCandidate.Email != null) {
	         	// retrieving all the candidates with the same email Address.
	         	candidateIdSet = NotesAndAttachmentsUtils.getAllCandidatesGivenEmailAddress(selectedCandidate.Email);
         	}
         	candidateIdSet.add(selectedCandidate.Id);
         	 // retrieving all the related object id's to candidate .
         	 Set<Id> candidateRelatedIdSet = new Set<Id>();
         	 Map<Id,JobInfo> jobMap = new Map<Id,JobInfo>();
        	
        	
	         String actionMessage ='';
	         if (dataToShow != null && dataToShow.trim().length() > 0 && !this.isHiringManager) {
	         	
	         	Map<String,String> objectKeyPrefix = NotesAndAttachmentsUtils.getStageObjectsPrefix();
	         	if (dataToShow.equalsIgnoreCase(Constants.NOTE)) {
	         		 NotesAndAttachmentsUtils.loadAllCandidateRelatedApplications(candidateIdSet,candidateRelatedIdSet,jobMap);
	         		candidateRelatedIdSet.addAll(candidateIdSet);
	         		// retrieving notes
	                for(Note note: NotesAndAttachmentsUtils.getAllNotesRelatedToCandidate(candidateRelatedIdSet)) {
	                	completeAncillaryDataList.add(new AncillaryDetails(note,objectKeyPrefix,jobMap));
	                }
	                actionMessage = 'Notes Details For Candidate ';
	         	} else if (dataToShow.equalsIgnoreCase(Constants.ATTACHMENT)) {
	         		 NotesAndAttachmentsUtils.loadAllCandidateRelatedApplications(candidateIdSet,candidateRelatedIdSet,jobMap);
	         		candidateRelatedIdSet.addAll(candidateIdSet); 
	         		// retrieving attachments.
	         		for(Attachment attachment : NotesAndAttachmentsUtils.getAllAttachmentsRelatedToCandidate(candidateRelatedIdSet)) {
	         			completeAncillaryDataList.add(new AncillaryDetails(attachment,objectKeyPrefix,jobMap));
	         		} 
	         		actionMessage = 'Attachment Details For Candidate ';
	         	} else if (dataToShow.equalsIgnoreCase(Constants.ACTIVITY)) {
	         		 NotesAndAttachmentsUtils.loadAllCandidateRelatedApplications(candidateIdSet,candidateRelatedIdSet,jobMap);
	         		// retrieving all the tasks.
	         		for(Task task: NotesAndAttachmentsUtils.getAllActivitiesRelatedToCandidate(candidateRelatedIdSet, candidateIdSet)){
	         			completeAncillaryDataList.add(new AncillaryDetails(task,objectKeyPrefix,jobMap));
	         		}
	         		actionMessage = 'Activity Details For Candidate ';
	         	} else if (dataToShow.equalsIgnoreCase(Constants.INTERVIEW)) {
	         		// retrieving all the tasks.
	         		for(Interview_Feedback__c interviewFeedBack: NotesAndAttachmentsUtils.getAllInterviewFeedbacksRelatedToCandidate(candidateIdSet)){
	         			completeAncillaryDataList.add(new AncillaryDetails(interviewFeedBack));
	         		}
	         	}
	         }
	         this.pageTitle=actionMessage + 'Name : '+ selectedCandidate.Name+' Email : '+ selectedCandidate.email+' Phone : '+ selectedCandidate.Phone;
         }

         if (completeAncillaryDataList !=null && completeAncillaryDataList.size() > 0) {
             getPaginationNotesData();
         }
    }
      
    /**
     * Method to check if there is any data to display , based on the request type.
     */
    public PageReference checkHasData() {
    	if (this.isHiringManager) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You do not have the level of access necessary to perform the operation you requested. Please contact administrator if access is necessary.'));
    	} else {
	    	if (dataToShow != null && dataToShow.trim().length() > 0) {
	    		if (completeAncillaryDataList == null || completeAncillaryDataList.size() == 0) {
		         	if (dataToShow.equalsIgnoreCase(Constants.NOTE)) {
		                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No notes available to display'));
		         	} else if (dataToShow.equalsIgnoreCase(Constants.ATTACHMENT)) {
		               	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No attachments available to display'));
		   	        } else if (dataToShow.equalsIgnoreCase(Constants.ACTIVITY)) {
		               	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No activites available to display'));
		         	} else if (dataToShow.equalsIgnoreCase(Constants.INTERVIEW)) {
		         		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No interview feedbacks available to display'));
		         	}
	    		}
	         }
    	}
    	return null;
    }
    	
    /**
     * Method to handle the cancel button functionality.
     */
    public PageReference cancel() {
    	return new PageReference(Constants.FORWARD_SLASH+selectedCandidate.Id);
    }
    
    /**
     * Method to load only 25 records a time and do the pagination.
     *
     */
    public override void getPaginationNotesData() {
    	Integer dispRows = 25;
    	Integer recordCount = completeAncillaryDataList.size();
    	ancillaryDataList = new List<AncillaryDetails>();
        Integer modVal = 0; 
        if (recordCount > 0) {
    	    modVal = Math.mod(recordCount, dispRows);
            noOfpages = recordCount / dispRows;
        }
        //---check to see if the records pulled are greater than 25 , to see how many pages we have to display.
        if (modVal > 0) {
            noOfpages++;
        }
        //---Showing at least on page.
        if (noOfpages == 0) {
            noOfpages++;
        }
        if (currentPage > noOfpages) {
         	 currentPage = noOfpages;
        }
        //---Set the Page start and end positions
    	
    	try {
    		Integer startIndex = (currentPage - 1) * dispRows;
    		Integer endIndex = (startIndex+dispRows >= recordCount) ? recordCount : startIndex+dispRows;
    		if ((completeAncillaryDataList != null && completeAncillaryDataList.size() > 0) ) {
	            for (Integer i=startIndex; i<endIndex; i++) {
	            	ancillaryDataList.add(completeAncillaryDataList.get(i));
	            }
    		}
    	} catch (Exception ex) {
    		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(msg);
    	}
    }
    
    public class AncillaryDetails {
    	private Task task;
    	private Note note;
    	private Attachment attachment;
    	private Interview_Feedback__c interviewFeedback;
    	private String source;
    	private String sourceUrl;
    	private String recordUrl;
    	private String jobName;
    	private String jobUrl;
    	private String recruiterName;
    	
    	public Task getTask() {
    		return task;
    	}
    	
    	public Note getNote() {
    		return note;
    	}

    	public Attachment getAttachment() {
    		return attachment;
    	}

    	public String getSource() {
    		return source;
    	}
    	
    	public String getSourceUrl() {
    		return sourceUrl;
    	}
    	
    	public String getRecordUrl() {
    		return recordUrl;
    	}
    	
    	public String getJobName() {
    		return jobName;
    	}
    	
    	public String getJobUrl() {
    		return jobUrl;
    	}
    	
    	public String getRecruiterName() {
    		return recruiterName;
    	}
    	
    	public Interview_Feedback__c getInterviewFeedback() {
    		return interviewFeedback;
    	}
    	
    	public AncillaryDetails(Task task,Map<String,String> objectKeyPrefix,Map<Id,JobInfo> jobMap) {
    		this.task = task;
    		String idPrefix = null;
    		String Id = null;
    		this.jobName ='';
    		this.jobUrl ='';
    		this.recruiterName ='';
    		if (task.whatId != null) {
    			Id = task.Whatid;
    		} else if (task.WhoId != null) {
    			Id = task.WhoId;
    		}
    		if(this.task.description != null && this.task.description.length() > 255) {
    		    this.task.description = this.task.description.substring(0,255);
    		}
    		if(Id != null) {
    			idPrefix = Id.substring(0,3);
    			this.source = objectKeyPrefix.get(idPrefix);
    			this.sourceUrl = URL.getSalesforceBaseUrl().toExternalForm()+Constants.FORWARD_SLASH+Id;
	    		if (jobMap.containsKey(Id)) {
	    			this.jobName = jobMap.get(Id).name;
	    			this.jobUrl=URL.getSalesforceBaseUrl().toExternalForm()+Constants.FORWARD_SLASH+jobMap.get(Id).jobId;
	    			this.recruiterName = jobMap.get(Id).recruiterName;
	    		}
    		}
    		this.recordUrl=URL.getSalesforceBaseUrl().toExternalForm()+Constants.FORWARD_SLASH+this.task.Id;
    	}
    	public AncillaryDetails(Note note,Map<String,String> objectKeyPrefix,Map<Id,JobInfo> jobMap) {
    		this.note = note;
    		String idPrefix = null;
    		String Id = note.ParentId;
    		this.jobName ='';
    		this.jobUrl ='';
    		this.recruiterName ='';
    		if(Id != null) {
    			idPrefix = Id.substring(0,3);
    			this.source = objectKeyPrefix.get(idPrefix);
    			this.sourceUrl = URL.getSalesforceBaseUrl().toExternalForm()+Constants.FORWARD_SLASH+Id;
	    		if (jobMap.containsKey(Id)) {
	    			this.jobName = jobMap.get(Id).name;
	    			this.jobUrl=URL.getSalesforceBaseUrl().toExternalForm()+Constants.FORWARD_SLASH+jobMap.get(Id).jobId;
	    			this.recruiterName = jobMap.get(Id).recruiterName;
	    		}
    			
    		}
    		this.recordUrl=URL.getSalesforceBaseUrl().toExternalForm()+Constants.FORWARD_SLASH+this.note.Id;
    		
    	}
    	
    	public AncillaryDetails(Attachment attachment,Map<String,String> objectKeyPrefix,Map<Id,JobInfo> jobMap) {
    		this.attachment = attachment;
    		String idPrefix = null;
    		String Id = attachment.ParentId;
    		if(Id != null) {
    			idPrefix = Id.substring(0,3);
    			this.source = objectKeyPrefix.get(idPrefix);
    			this.sourceUrl = URL.getSalesforceBaseUrl().toExternalForm()+Constants.FORWARD_SLASH+Id;
	    		if (jobMap.containsKey(Id)) {
	    			this.jobName = jobMap.get(Id).name;
	    			this.jobUrl=URL.getSalesforceBaseUrl().toExternalForm()+Constants.FORWARD_SLASH+jobMap.get(Id).jobId;
	    			this.recruiterName = jobMap.get(Id).recruiterName;
	    		}
    		}
    		
    		
    	}
    	
    	public AncillaryDetails(Interview_Feedback__c interviewFeedback) {
    		
    		
    	}
    	
    	
    }
    
    
}