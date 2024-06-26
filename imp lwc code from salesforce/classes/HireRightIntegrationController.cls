/*
 * RelEng Perforce/RCS Header - Do not remove!
 *
 * $Author: Sudarshan Rao Edupuganti  $
 * $Change:  $
 * $DateTime: 5/25/2011 $
 * $File: HireRightIntegrationController.cls $
 * $Id:  $
 * $Revision:  $
 */
 
/*
 * This class will manage integration with Hire Right.
 * @author Sudarshan Rao Edupuganti
*/
public with sharing class HireRightIntegrationController {
	
	private static final String INTIATE_BI= 'INTIATE_BI';
	private static final String VIEW_BI= 'VIEW_BI';
	private static final String UPDATE_BI= 'UPDATE_BI';
	private static final String NOT_STARTED = 'Not Started';
	private static final String HTTP_STR = 'http';
	public Employment_Application__c employmentApplication{get; private set;}
    public String action {get; private set;}
    public boolean showContinueButton {get; private set;}
    public boolean isTest {get; set;}
    /**
     * constructor
     */
    public HireRightIntegrationController (){
    	Id employmentId = System.currentPageReference().getParameters().get('Id');
    	action = System.currentPageReference().getParameters().get('Action');
    	if (employmentId != null) {
    		this.employmentApplication = [select id,BI_Summary_Status__c from Employment_Application__c Where Id =:employmentId];
    	}
    	this.showContinueButton = false;
    	this.isTest = false;
    }
    
    /**
     * Method to validate the incomming request. To make sure the user has the permission to submit/view back ground information of the candidates.
     */
    public PageReference validateRequest(){
    	
    	if(this.action != null && this.action.equalsIgnoreCase(INTIATE_BI)) {
    		if(this.employmentApplication.BI_Summary_Status__c == '') {
    			this.employmentApplication.BI_Summary_Status__c = NOT_STARTED;
    		}
    		// checking the record status to see if they have already intiated a back ground check.
    		if (this.employmentApplication.BI_Summary_Status__c != NOT_STARTED) {
    			ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, 'A Background Investigation for this applicant has already been initiated.\nSelect Update BI Status or View BI Report instead.'));
    		} else {
    			// checking the user permission to see, if the is authroized to performs this action.
    			BI_User_Permission__c userBIPermission =authenticateUserBIPermission(UserInfo.getUserId());
    			if(userBIPermission == null || !userBIPermission.Intiate__c) {
				    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, 'You are not authorized to perform this action.\nIf you find this message in error, please contact your system administrator.'));
			    } else {
			    	this.showContinueButton = true;
			    	//ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, 'Are you sure? You want to submit the request to Hire Right'));
			    }
    		}
    	} else if(action != null && (action.equalsIgnoreCase(VIEW_BI) || action.equalsIgnoreCase(UPDATE_BI))) {
    		// checking the user permission to see, if he is authroized to performs this action.
			BI_User_Permission__c userBIPermission =authenticateUserBIPermission(UserInfo.getUserId());
			if(userBIPermission == null || !userBIPermission.View__c) {
			    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, 'You are not authorized to perform this action.\nIf you find this message in error, please contact your system administrator.'));
		    } else {
		    	this.showContinueButton = true;
		    }
    		
    	} else {
    		ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Request'));
    	}
    	
    	return null;
    }
    
    /**
     * Method to process the back ground request and redirect to Hire Right Url.
     *  Exception happens during processing of the request , we send to the same page, with a generic error message.
     */
    public PageReference processBackgroundData(){
     	String url = null;
     	String userId = getHRAuthorizedUser(); 
     	// Intiating a back ground check.
     	if(this.action != null && this.action.equalsIgnoreCase(INTIATE_BI)) {
     		url =  HireRightUtility.orderBackGroundCheck((String)this.employmentApplication.Id,userId,isTest);
     		if (url != null && url.contains(HTTP_STR)) {
     		    return forwardTo(url);	
     		}
     	// intiating a request to view the back ground check.	
     	} else if (this.action != null && this.action.equalsIgnoreCase(VIEW_BI)) {
     		url = HireRightUtility.viewBackGroundCheckDetails((String)this.employmentApplication.Id,userId,isTest);
     		if (url != null && url.contains(HTTP_STR)) {
     		    return forwardTo(url);	
     		}
     	// intiating a request to get the screening report.	
     	}  else if (this.action != null && this.action.equalsIgnoreCase(UPDATE_BI)) {
     		this.showContinueButton = false;
     		url = HireRightUtility.getScreeningReportStatus((String)this.employmentApplication.Id,isTest);
     		if (url != null) {
     		    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, 'Your requested is processed  successfully.'));
     		    return null;
     		}
     		 		
     	}
     	ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, 'An error has occurred processing this request.Please contact you System Administrator'));
     	return null;
     }
    
    /**
	 * Method to query the BI user permission object , to get the associated permission object.
	 * @param userId is a String
	 * @return BI_User_Permission__c is a object.
	 */	
	private static BI_User_Permission__c authenticateUserBIPermission(String userid) {
		BI_User_Permission__c userPermission = null; 
		List<BI_User_Permission__c> permissionList = [ Select View__c, User__c, Intiate__c, Id From BI_User_Permission__c where User__c= : userid];
		if (permissionList != null && permissionList.size() > 0) {
			userPermission = permissionList.get(0);
		}
		return userPermission;
	}
	
    /**
	 * Method to get the intergration user that is setup on Hire Right side.
	 * @return String currentUserId.
	 */
	private static String getHRAuthorizedUser() {
		TF2Settings__c configurations = TF2Settings__c.getInstance();
		String currentUserId = null;
		currentUserId = configurations.HR_Authorized_Userids__c;
		
		return currentUserId;
	}
	
	
	/**
	* Create a pageReference from an url in a string
    * @return PageReference
    */
	
	public PageReference forwardTo(String url){
		PageReference page= new Pagereference(url);
		page.setRedirect(true);
		return page;
	}
}