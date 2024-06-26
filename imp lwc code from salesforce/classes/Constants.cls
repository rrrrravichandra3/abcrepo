public without sharing class Constants {
    
    public static final String COMMA =',';
    public static final String NONE = '--None--';
    public static final String APPLICATION_STAGES ='Application,Submittal,Interview,Offer,Placement';
    public static final String REJECT_OPERATION ='REJECT';
    public static final String MOVE_OPERATION = 'MOVE';
    public static final String REJECTED_STATUS ='Rejected';
    public static final String NEW_STATUS ='New';
    public static final String ACCEPTED_STATUS ='Accepted';
    public static final String INTERVIEW_STAGE='Interview';
    //Added by Pradeep
    public static final String INTERVIEW1_STAGE='Custom_stage_2';
    public static final String INTERVIEW2_STAGE='Custom_stage_3';
    public static final String INTERVIEW3_STAGE='Custom_stage_4';
    public static final String HIRING_MANAGER_SUBMITTAL_STAGE='Custom_stage_1';
    
    public static final String OFFER_STAGE='Offer';
    public static final String SUBMITTAL_STAGE='Submittal';
    public static final String APPLICATION_STAGE='Application';
    public static final String PLACEMENT_STAGE='Placement';
    public static final String EMAIL ='Email';
    public static final String MERGE_FIELD_OPEN_IDENTIFIER='\\{!'; 
    public static final String MERGE_FIELD_CLOSE_IDENTIFIER='}';
    public static final String DOT ='.';
    public static final String EMPTY_STR =' ';
    public static final String AMS_STAGE_OBJECT_NAMES='';
    public static final String CANDIDATE_TABLE_NAME='Contact';
    public static final String JOB_TABLE_NAME='';
    public static final String APPLICATION_TABLE_NAME='';
    public static final String REFERENCE_TYPE ='REFERENCE';
    public static final String FIELD_IDENTIFIER ='__c';
    public static final String RELATIONSHIP_IDENTIFIER ='__r';
    public static final String SALES ='sales';
    public static final String SEMI_COLON =';';
    public static final String FORWARD_SLASH ='/';
    public static final String NOTE='Note';
    public static final String ATTACHMENT ='Attachment';
    public static final String ACTIVITY ='Activity';
    public static final String CDATA_OPEN_TAG='<!\\[CDATA\\[';
    public static final String CDATA_CLOSE_TAG=']]>';
    public static final String CANDIDATE_SECURE_INFO_TABLE_NAME='Candidate_Secure_Info__c';
    public static final String USER_TABLE_NAME ='User';
    public static final String CANDIDATE ='Candidate';
    public static final String INTERVIEW ='Interview';

    //Picklist values on Job req
    public static final String REGION_AMER = 'AMER';
    public static final String BUSINESS_SITE_COUNTRY_US = 'United States';
    public static final String EMPLOYMENT_TYPE_INTERN = 'Intern';
    public static final String TIME_TYPE_FULLTIME = 'Full Time';
    public static final String TIME_TYPE_PARTTIME = 'Part Time';
    ////////////////////////////////////////////////////////////

    public static final String KOKUA = 'Kokua';
    public static final String KOKUA_EXEC = 'Kokua Exec';

	public static final String USEmailBlub = 'Congratulations on your employment offer with <a href="http://www.salesforce.com">salesforce.com</a>! We are thrilled you have chosen to join us. ' + 
							'In order to get you off on the right foot, please make sure you read and follow the directions in these documents so that you can hit the ground running ' +
							'on your first day of work.<br/><br/>Please find your offer in the link below.  Once you have received the eight character, case sensitive offer access ' +
							'code from your Recruiter, review and electronically sign all documents prior to the offer expiration date. Save and print your agreement as needed.' +
							'<br/><br/>You will receive an email from SterlingBackCheck with instructions to initiate your background check.  For information about ' +
							'<a href="http://www.salesforce.com">salesforce.com</a> employee benefits, please visit our <a href="http://getsalesforcebenefits.com/">Get Salesforce ' +
							'Benefits Website</a>.<br/><br/>Please direct any questions regarding your offer to your Recruiter.<br/><br/>Best regards,<br/>salesforce.com Recruiting';
							
	public static final String EMEAEmailBlub= 'Congratulations on your employment offer with <a href="http://www.salesforce.com">salesforce.com</a>!'+
								  '<br/><br/>Please review your offer in the link below.'+
							      'Complete and electronically sign all documents prior to the offer expiration date.  The button to click to confirm your signing and submit your signed contract back '+
							      'to us is only visible once you sign every required document. You will receive a confirmation email once submitted. You can save and print your employment agreement as needed.'+
								  '<br/><br/>You will receive an email from SterlingBackCheck with instructions to initiate your background check.  For information about salesforce.com employee benefits, please refer '+ 
								  'to the benefit summary in your offer packet.'+
								  '<br/><br/>Please direct any questions regarding your offer to your Recruiter.';		

	public static final String CANADAEmailBlub= 'Congratulations on your employment offer with <a href="http://www.salesforce.com">Salesforce</a>!<br/><br/>'+
									'Please review your offer documents by clicking the link below and entering the unique eight digit access code'+
									' given to you by your recruiter.<br/><br/>Complete and electronically sign all documents prior to the offer expiration'+
									' date. The confirm signing tab to submit your signed packet back is visible once you electronically sign every'+
									' document requiring a signature. You will receive a confirmation email once submitted. You can save and print'+
									' your employment agreement as needed.<br/><br/>You will receive an email from SterlingBackCheck with instructions'+
									' to initiate your background check. Please take action immediately as your background investigation must be in'+
									' progress before your first day of employment at Salesforce. Please note that if you do not initiate your background'+
									' investigation before your start date, your start date will be delayed.<br/><br/>For information regarding our' +
									' Salesforce employee benefits, please view the <a href="http://www.getsalesforcebenefits.com/ca">Get Salesforce Benefits</a>'+
									' webpage.<br/><br/>Please direct any questions regarding your offer to your Recruiter.<br/><br/>Thank you,<br/>Salesforce Recruiting';
}