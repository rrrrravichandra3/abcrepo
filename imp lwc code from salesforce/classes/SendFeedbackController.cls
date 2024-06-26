public with sharing class SendFeedbackController {

    private Id InterviewId;    
    private List<Interview_Feedback__c> iflist = new List<Interview_Feedback__c>();
    private List<Sobject> InterviewSobject = new List<Sobject>();
    public boolean noRecordsSent;
    public boolean RecordsSent;
    public String envelopeId {get;set;}
    public Integer isSendCount;
    private String objectAPIName {get; set;}
    public String qry {get; set;}
    public List<SObject> dynamic { get; set; }
    public boolean validateInterview { get; set; }
    public boolean showDateError { get; set;}
    public boolean showTemplateError { get; set; }
    public boolean showStatusError { get; set; }
    public boolean showUserError { get; set; }
    
    public SendFeedbackController(){
    	Date d = System.today();   
    	noRecordsSent = false;
    	RecordsSent = false;
    	validateInterview = false;
    	showDateError = false;
    	showTemplateError = false;
    	showStatusError = false;
    	showUserError = false;
        InterviewId = String.escapeSingleQuotes( ApexPages.currentPage().getParameters().get('Id') );
		objectAPIName = InterviewId.getSObjectType().getDescribe().getName();
		qry = 'select Id, Interview_Date__c, Interview_Feedback_Template__c, Interview_Status__c from ' + objectAPIName + ' where Id = : InterviewId and Interview_Feedback_Template__c != null and Interview_Status__c = \'Active\' and Interviewer_1__c != null and Interview_Date__c != null';
		dynamic = Database.query( qry );        
        
        if ( dynamic.size() == 1 )
        	validateInterview = true;

        if ( validateInterview ) {
	        try {
				
	            iflist = [	select Id, Sent_Status__c, DocuSign_Current_Status__c, Candidate__r.Name, Docusign_Template_ID__c, Interviewer_User__r.FirstName, Interviewer_User__r.LastName, Interview_1__r.Interview_Date__c, Interviewer_User__r.Email, Interview_2__r.Interview_Date__c, Interview_3__r.Interview_Date__c  from 
	            			Interview_Feedback__c where ( Interview_1__c =: InterviewId or Interview_2__c =: InterviewId or Interview_3__c =: InterviewId ) and Sent_Status__c != true and DocuSign_Current_Status__c != 'Completed' and Interview_Status__c = 'Active' and Legacy__c != true ];
	            
		            if ( iflist.size() == 0 )
		            	noRecordsSent = true;
		            else
		            	RecordsSent = true;

	        }  catch (Exception ex) {
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You have encountered an unexpected error! Please contact a System Administrator.'));
	        }
        } else {
        	
			qry = 'select Id, Interview_Date__c, Interview_Feedback_Template__c, Interview_Status__c, Interviewer_1__c from ' + objectAPIName + ' where Id = : InterviewId ';
			dynamic = Database.query( qry );        
        	        	
        	if ( dynamic[0].get('Interview_Feedback_Template__c') == null  )
        		showTemplateError = true;
        	if ( dynamic[0].get('Interview_Status__c') != 'Active'  )
        		showStatusError = true;	
        	if ( dynamic[0].get('Interview_Date__c')  == null )
        		showDateError = true;
			if ( dynamic[0].get('Interviewer_1__c') == null  )    
				showUserError = true;
        }  
             
    }

	public PageReference Back(){
		return new PageReference('/'+ InterviewId ); 
	}

	public Integer getIsSendCount(){
		return isSendCount;
	}

	public boolean getNoRecordsSent(){
		return noRecordsSent;
	}

	public boolean getRecordsSent(){
		return RecordsSent;
	}

	public String FeedbackEmailBlubwithName( String candidateName ){
		String 	s = 'Please find your interview feedback form for '+ String.escapeSingleQuotes (candidateName) +' by clicking the link below. Review and electronically complete all fields of the feedback form within 24-48 hours of the interview.';
				s += '<br/> <br/>';
				s += 'Once you have completed your interview feedback, it is not required for you to create a DocuSign account.  Please direct any questions regarding candidate feedback to your Recruiter. Direct any general DocuSign user questions to your Recruiting Coordinator.';
				s += '<br/> <br/>';
				s += 'Thank you for your feedback!';
				s += '<br/> <br/>';
				s += 'Salesforce.com Recruiting'; 

		return s;
	}
		
    public esdsext.DocuSignAPI.Recipient getCandiddateRecipient( Interview_Feedback__c feedback ) {
            esdsext.DocuSignAPI.Recipient candidate = new esdsext.DocuSignAPI.Recipient();

            candidate.ID = 1;
            candidate.Type_x = 'Signer';
            candidate.RoutingOrder = 1;
            candidate.Email = feedback.Interviewer_User__r.Email; 
            candidate.UserName = feedback.Interviewer_User__r.FirstName + ' ' + feedback.Interviewer_User__r.LastName;
            candidate.RoleName = 'Signer';
            candidate.RequireIDLookup = false;      
            candidate.RoleName = 'Interviewer';

        return candidate;
    }
    
    public esdsext.DocuSignAPI.ArrayOfRecipient1 getSigners( Interview_Feedback__c feedback ) {
        
        
        esdsext.DocuSignAPI.ArrayOfRecipient1 signers = new esdsext.DocuSignAPI.ArrayOfRecipient1();
        signers.Recipient = new esdsext.DocuSignAPI.Recipient[1];
        signers.Recipient[0] = getCandiddateRecipient( feedback );

        
        return signers;
    }
        

    public esdsext.DocuSignAPI.TemplateReference getTemplate(String templateId, Interview_Feedback__c feedback ) {
        if(templateId == null){
            return null;
        }

        esdsext.DocuSignAPI.TemplateReference ndaTemplate = new esdsext.DocuSignAPI.TemplateReference();
        ndaTemplate.Template = templateId;
        ndaTemplate.TemplateLocation = 'Server';
        
        esdsext.DocuSignAPI.ArrayOfRecipient1 signers = getSigners(feedback);
        
        esdsext.DocuSignAPI.Recipient candiddateRecipient = getCandiddateRecipient(feedback);
        esdsext.DocuSignAPI.TemplateReferenceRoleAssignment candiddteRoleAssignment = new esdsext.DocuSignAPI.TemplateReferenceRoleAssignment();
        candiddteRoleAssignment.RoleName = candiddateRecipient.RoleName;
        candiddteRoleAssignment.RecipientID = candiddateRecipient.ID;

        
        ndaTemplate.RoleAssignments = new esdsext.DocuSignAPI.ArrayOfTemplateReferenceRoleAssignment();
        ndaTemplate.RoleAssignments.RoleAssignment = new esdsext.DocuSignAPI.TemplateReferenceRoleAssignment[3];
        ndaTemplate.RoleAssignments.RoleAssignment[0] = candiddteRoleAssignment;
        
        esdsext.DocuSignAPI.TemplateReferenceFieldDataDataValue candidateName = new esdsext.DocuSignAPI.TemplateReferenceFieldDataDataValue();
        candidateName.TabLabel = 'Candidate Full Name';
        candidateName.Value = feedback.Candidate__r.Name;

        esdsext.DocuSignAPI.TemplateReferenceFieldDataDataValue jobTitle = new esdsext.DocuSignAPI.TemplateReferenceFieldDataDataValue();
        jobTitle.TabLabel = 'Business Title';

        esdsext.DocuSignAPI.TemplateReferenceFieldDataDataValue interviewDate = new esdsext.DocuSignAPI.TemplateReferenceFieldDataDataValue();
        interviewDate.TabLabel = 'Feedback - Interview Date';
        interviewDate.Value = '';
        if ( feedback.Interview_1__r.Interview_Date__c != null){
            DateTime Dt1 = DateTime.valueOf(feedback.Interview_1__r.Interview_Date__c +' 00:00:00');
            interviewDate.Value = Dt1.format('MMMM dd, yyyy');            
        }
        if ( feedback.Interview_2__r.Interview_Date__c != null){
            DateTime Dt1 = DateTime.valueOf(feedback.Interview_2__r.Interview_Date__c +' 00:00:00');
            interviewDate.Value = Dt1.format('MMMM dd, yyyy');            
        }
        if ( feedback.Interview_3__r.Interview_Date__c != null){
            DateTime Dt1 = DateTime.valueOf(feedback.Interview_3__r.Interview_Date__c +' 00:00:00');
            interviewDate.Value = Dt1.format('MMMM dd, yyyy');            
        }                   

        ndaTemplate.FieldData = new esdsext.DocuSignAPI.TemplateReferenceFieldData();
        ndaTemplate.FieldData.DataValues = new esdsext.DocuSignAPI.ArrayOfTemplateReferenceFieldDataDataValue();
        ndaTemplate.FieldData.DataValues.DataValue = new esdsext.DocuSignAPI.TemplateReferenceFieldDataDataValue[3];
        ndaTemplate.FieldData.DataValues.DataValue[0] = candidateName;
        ndaTemplate.FieldData.DataValues.DataValue[1] = jobTitle;
        ndaTemplate.FieldData.DataValues.DataValue[2] = interviewDate;
                
        return ndaTemplate;
    }


    public esdsext.DocuSignAPI.TemplateReference getFeedbackTemplate( String templateId, Interview_Feedback__c feedback  ) {
        esdsext.DocuSignAPI.TemplateReference template = null;

		template = getTemplate( templateId, feedback );

        return template;
    }

    
	public String SendInterviewFeedback( Interview_Feedback__c feedback, String templateId ){

        esdsext.DocuSignAPI.EnvelopeInformation envelope = new esdsext.DocuSignAPI.EnvelopeInformation();
        envelope.Subject = 'Action Required: Interview Feedback for ' + feedback.Candidate__r.Name + ' - ' + dynamic[0].get('Interview_Feedback_Template__c') ;    	
		envelope.EmailBlurb = FeedbackEmailBlubwithName ( feedback.Candidate__r.Name );
        esdsext.DocuSignAPI.ArrayOfTemplateReference templateReferences = new esdsext.DocuSignAPI.ArrayOfTemplateReference();
        
        List<esdsext.DocuSignAPI.TemplateReference> templates2Send = new List<esdsext.DocuSignAPI.TemplateReference>();    


		templates2Send.add( getFeedbackTemplate( templateId, feedback ) );
	
	

        templateReferences.TemplateReference = new  esdsext.DocuSignAPI.TemplateReference[templates2Send.size()];
        Integer count = 0;
        for(esdsext.DocuSignAPI.TemplateReference template :templates2Send ){
            templateReferences.TemplateReference[count] = template;
            count++;
        }

        envelope.CustomFields = new esdsext.DocuSignAPI.ArrayOfCustomField();
        envelope.CustomFields.CustomField = new esdsext.DocuSignAPI.CustomField[2];
        
        esdsext.DocuSignAPI.CustomField myCustomField4 = new esdsext.DocuSignAPI.CustomField();
        myCustomField4.Name = 'DSFSSourceObjectId';
        myCustomField4.Value = feedback.Id+'~Interview_Feedback__c';
        myCustomField4.Show = 'False';
        myCustomField4.Required = 'False';
        myCustomField4.CustomFieldType = 'Text';
        envelope.CustomFields.CustomField[0] = myCustomField4;

        envelopeId = esdsext.SendToDocuSignController.sendOfferWithTemplates(templateReferences, getSigners(feedback), envelope);    

		return envelopeId;
	}
        
    public void init() {	
    	
    	Map<String, Offer_Template__c> FeedbackMap = Utils.getFeedbackTemplatesMapByEID();
		List<Interview_Feedback__c> SentFeedbackList = new List<Interview_Feedback__c>();
		isSendCount = 0;
		//system.debug ( ' feedback map '+ FeedbackMap );

        if ( iflist.size() != 0 && iflist != null ){        
            for ( Interview_Feedback__c i : iflist ){
            	String tempId = null;
            	
                tempId = SendInterviewFeedback(i, FeedbackMap.get( i.Docusign_Template_ID__c.toUpperCase() ).Template_ID__c );
                
                if ( tempId != null ){
                	SentFeedbackList.add( i );
                	isSendCount++;
                	i.Sent_Status__c = true;
                }
            }
            
            update SentFeedbackList;
        }
    }

}