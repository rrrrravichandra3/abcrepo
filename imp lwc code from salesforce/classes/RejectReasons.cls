/**
*	Depending on the 'Application' stage, this class returns the appropiate list of 'Reject Reasons' to the recruiters.
* 	In order to enforce the Picklist entries by Record type, it uses the actual 'Reject Reason' fields of the related records (like ts2__Offer__c.ts2__Reject_Reason__c, etc) instead of the of using
* 	a list of Schema.PicklistEntrys
*
*	@author	Angel Abrego
*  	@date	4/9/2015 
*/
public without sharing class RejectReasons {

    private final String controllerPropertyName;
    private final ts2__Application__c application;  
    
    public ts2__Offer__c                offerRecord 		{get; set;}
    public ts2__Interview__c            interviewRecord 	{get; set;}
    public ts2extams__Custom_stage_1__c customStage1Record  {get; set;}
    public ts2extams__Custom_stage_2__c customStage2Record  {get; set;}
    public ts2extams__Custom_stage_3__c customStage3Record  {get; set;}
    public ts2extams__Custom_stage_4__c customStage4Record  {get; set;}
    public ts2__Submittal__c            submittalRecord 	{get; set;}
    public ts2__Application__c          applicationRecord   {get; set;}
    
    /**
    *	Constructor 
    *  
    *	@author	Angel Abrego
    *  	@date	4/9/2015 
    * 	@param controllerPropertyName Name of the object reference (the variable that holds an instance of this class). Needed for Visualforce data binding.
    *   @param application 'Application' record. It provides the context to retrieve the appropiate application 'Stage' and child records ('Offer, Sumbittal', etc)
    */     
    public RejectReasons(String controllerPropertyName, ts2__Application__c application) {   
        this.controllerPropertyName = controllerPropertyName;
        this.application = application;
    }
    
    /**
    *	Returns the the 'Reject Reasons' field that corresponds to the 'Application' stage. 
    *  
    *	@author	Angel Abrego
    *  	@date	4/9/2015 
    *   @return	'Reject Reasons' field
    */
    public Component.Apex.InputField getRejectReasonsField() {   
         
        Component.Apex.InputField inputField = new Component.Apex.InputField();
       	inputField.required = true; 
         
        //Maps the application 'Stage' with the right child record and 'Reject Reason field.
        // Constants.OFFER_STAGE 	 					===>  ts2__Offer__c.ts2__Reject_Reason__c
        // Constants.INTERVIEW_STAGE 					===>  ts2__Interview__c.ts2__Reject_Reason__c
        // Constants.HIRING_MANAGER_SUBMITTAL_STAGE		===>  ts2extams__Custom_stage_1__c.ts2extams__Reject_Reason__c
        // Constants.INTERVIEW1_STAGE					===>  ts2extams__Custom_stage_2__c.ts2extams__Reject_Reason__c
        // Constants.INTERVIEW2_STAGE					===>  ts2extams__Custom_stage_3__c.ts2extams__Reject_Reason__c
        // Constants.INTERVIEW3_STAGE					===>  ts2extams__Custom_stage_4__c.ts2extams__Reject_Reason__c
       	// Constants.SUBMITTAL_STAGE					===>  ts2__Submittal__c.ts2__Reject_Reason__c
        // Constants.APPLICATION_STAGE 					===>  ts2__Application__c.ts2__Reject_Reason__c
        
        if (application.ts2__Stage__c == Constants.OFFER_STAGE) {
            List<ts2__Offer__c> lofferRecords = [select Id, ts2__Reject_Reason__c from ts2__Offer__c where ts2__Related_Application__c = :application.Id order by LastModifiedDate desc limit 1];
            if (lofferRecords.size() > 0) { 
            	offerRecord = lofferRecords[0];             
            	inputField.value = offerRecord.ts2__Reject_Reason__c;
            	inputField.expressions.value = '{!' + this.controllerPropertyName + '.offerRecord.ts2__Reject_Reason__c}';
            } 
            
        } else if (application.ts2__Stage__c == Constants.INTERVIEW_STAGE) {
            List<ts2__Interview__c> linterviewRecords = [select Id, ts2__Reject_Reason__c from ts2__Interview__c where ts2__Related_Application__c = :application.Id order by LastModifiedDate desc limit 1];
            if (linterviewRecords.size() > 0) { 
            	interviewRecord = linterviewRecords[0];             
            	inputField.value = interviewRecord.ts2__Reject_Reason__c;
            	inputField.expressions.value = '{!' + this.controllerPropertyName + '.interviewRecord.ts2__Reject_Reason__c}';
            } 
        
        } else if (application.ts2__Stage__c == Constants.HIRING_MANAGER_SUBMITTAL_STAGE) {
           	List<ts2extams__Custom_stage_1__c> lcustomStage1Records = [select Id, ts2extams__Reject_Reason__c from ts2extams__Custom_stage_1__c where ts2extams__Application__c = :application.Id order by LastModifiedDate desc limit 1];
            if (lcustomStage1Records.size() > 0) { 
            	customStage1Record = lcustomStage1Records[0];             
            	inputField.value = customStage1Record.ts2extams__Reject_Reason__c;
            	inputField.expressions.value = '{!' + this.controllerPropertyName + '.customStage1Record.ts2extams__Reject_Reason__c}';
            }
            
        } else if (application.ts2__Stage__c == Constants.INTERVIEW1_STAGE) {
            List<ts2extams__Custom_stage_2__c> lcustomStage2Records = [select Id, ts2extams__Reject_Reason__c from ts2extams__Custom_stage_2__c where ts2extams__Application__c = :application.Id order by LastModifiedDate desc limit 1];
            if (lcustomStage2Records.size() > 0) { 
            	customStage2Record = lcustomStage2Records[0];             
            	inputField.value = customStage2Record.ts2extams__Reject_Reason__c;
            	inputField.expressions.value = '{!' + this.controllerPropertyName + '.customStage2Record.ts2extams__Reject_Reason__c}';
            }
        } else if (application.ts2__Stage__c == Constants.INTERVIEW2_STAGE) {
            List<ts2extams__Custom_stage_3__c> lcustomStage3Records = [select Id, ts2extams__Reject_Reason__c from ts2extams__Custom_stage_3__c where ts2extams__Application__c = :application.Id order by LastModifiedDate desc limit 1];
            if (lcustomStage3Records.size() > 0) { 
            	customStage3Record = lcustomStage3Records[0];             
            	inputField.value = customStage3Record.ts2extams__Reject_Reason__c;
            	inputField.expressions.value = '{!' + this.controllerPropertyName + '.customStage3Record.ts2extams__Reject_Reason__c}';
            }
            
        } else if (application.ts2__Stage__c == Constants.INTERVIEW3_STAGE) {
            List<ts2extams__Custom_stage_4__c> lcustomStage4Records = [select Id, ts2extams__Reject_Reason__c from ts2extams__Custom_stage_4__c where ts2extams__Application__c = :application.Id order by LastModifiedDate desc limit 1];
            if (lcustomStage4Records.size() > 0) { 
            	customStage4Record = lcustomStage4Records[0];             
            	inputField.value = customStage4Record.ts2extams__Reject_Reason__c;
            	inputField.expressions.value = '{!' + this.controllerPropertyName + '.customStage4Record.ts2extams__Reject_Reason__c}';
            }
            
        } else if (application.ts2__Stage__c == Constants.SUBMITTAL_STAGE) {
            List<ts2__Submittal__c> lsubmittalRecords = [select Id, ts2__Reject_Reason__c from ts2__Submittal__c where ts2__Related_Application__c = :application.Id order by LastModifiedDate desc limit 1];
            if (lsubmittalRecords.size() > 0) { 
            	submittalRecord = lsubmittalRecords[0];             
            	inputField.value = submittalRecord.ts2__Reject_Reason__c;
            	inputField.expressions.value = '{!' + this.controllerPropertyName + '.submittalRecord.ts2__Reject_Reason__c}';
            }                
        
        } else if (application.ts2__Stage__c == Constants.APPLICATION_STAGE || application.ts2__Stage__c == 'RejectSelectedCandidate' || application.ts2__Stage__c == 'StatusSelectedCandidate') {      
            applicationRecord = new ts2__Application__c(Id = application.Id);             
            inputField.value = applicationRecord.ts2__Reject_Reason__c;
            inputField.expressions.value = '{!' + this.controllerPropertyName + '.applicationRecord.ts2__Reject_Reason__c}';
        } else {
        	
        	return inputField;
        }

		//If not able to do a data binding because of a related record was not found Throw an exception.
    	if (inputField.expressions.value == null){
    		throw new MoveCandidateUtils.MoveCandidateUtilsException(Label.TF_MoveCandidateException_RejectReasons_NoRecordFound);
    	}

        return inputField;   
    }
    
    /**
    *	Returns the the 'Reject Reason' selected by the user.
    *  
    *	@author	Angel Abrego
    *  	@date	4/9/2015 
    *   @return	An string with actual reason selected. Something like: 'Candidate Declines Offer - Location' , 'Candidate Declines Offer - Counter Offer - Pay', etc.
    * 	@see MoveCandidateUtils.cls RejectReasons.getRejectReasonsField() method.
    */
    public String getSelectedReason() {
        String selectedReason;
        
        if (application.ts2__Stage__c == Constants.OFFER_STAGE) {
            selectedReason = offerRecord.ts2__Reject_Reason__c; 
        } else if (application.ts2__Stage__c == Constants.INTERVIEW_STAGE) {
            selectedReason = interviewRecord.ts2__Reject_Reason__c;         
        } else if (application.ts2__Stage__c == Constants.HIRING_MANAGER_SUBMITTAL_STAGE) {
            selectedReason = customStage1record.ts2extams__Reject_Reason__c; 
        } else if (application.ts2__Stage__c == Constants.INTERVIEW1_STAGE) {
            selectedReason = customStage2record.ts2extams__Reject_Reason__c; 
        } else if (application.ts2__Stage__c == Constants.INTERVIEW2_STAGE) {
            selectedReason = customStage3record.ts2extams__Reject_Reason__c; 
        } else if (application.ts2__Stage__c == Constants.INTERVIEW3_STAGE) {
            selectedReason = customStage4record.ts2extams__Reject_Reason__c; 
        } else if (application.ts2__Stage__c == Constants.SUBMITTAL_STAGE) {
            selectedReason = submittalRecord.ts2__Reject_Reason__c; 
        } else if (application.ts2__Stage__c == Constants.APPLICATION_STAGE || application.ts2__Stage__c == 'RejectSelectedCandidate' || application.ts2__Stage__c == 'StatusSelectedCandidate') {      
            selectedReason = applicationRecord.ts2__Reject_Reason__c; 
        } else {
        	throw new MoveCandidateUtils.MoveCandidateUtilsException(Label.TF_MoveCandidateException_RejectReasons_Mapping);
        }
          
        return selectedReason;
    }   
}