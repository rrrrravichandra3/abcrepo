/*
 * RelEng Perforce/RCS Header - Do not remove!
 *
 * $Author: ndesai $
 * $Change: 7959542 $
 * $DateTime: 2013/06/10 12:34:28 $
 * $File: //it/applications/peopleforce/prod/src/classes/ExitInterviewController.cls $
 * $Id: //it/applications/peopleforce/prod/src/classes/ExitInterviewController.cls#8 $
 * $Revision: #8 $
 */
 
/*
 * This class will manage all CRUD operation for ExitInterview Object
 * @author Joaquin Arcardini
*/
public with sharing class ExitInterviewController 
{
	private exitInterview__c exitInterview;
	private Id interviewId;
	private Employee employeeInner = new Employee();
	private ExitInterviewComment__c exitInterviewComment;
	private ExitInterviewCommentContinue__c exitInterviewCommentContinue;
	private User currentUser;
	private User employee;
	private V2MOM__c mostRecentV2MOM;
	private PerformanceReview__c mostRecentReview;
	private PerformanceReview review;
	private Boolean errorDate;
	private Boolean hasV2MOM;
	private String leavingReason;
	public String leavingReasonJap{get;set;}
	private string declined='Declined to Participate';
	PerformanceAccessUtil paccess;

	public class CustomException extends Exception {} // This needs to be refactored into external class as soon
	 
	//Constructor   
	public ExitInterviewController()
	{
		interViewId = System.currentPageReference().getParameters().get('id');
		
		List<ExitInterview__c> exitInterviews = [select Id, Name, HavePersonalV2MOM__c, Compensation__c, BenefitsNotAsGood__c, Benefits__c, CanFedbackBeeShared__c, CareerDevelopmentOpportunities__c, 
						  CompensationNotGoodAs__c, Compensattion__c, CultureAtSalesforce__c, CurrentManager__c, 
						  Employee__c, Employee__r.Manager__c, ExpectationsNotClosed__c, Expectations__c, FrequencyMeetings__c,
						  HireDate__c, HowYouHeardOportunity__c, ItemsNotRankedAsFive__c, LeavingReasonOther__c, LeavingReason__c,
						  ManagerCommunicateDepartmentV2MOM__c, ManagerDoneDifferently__c, ManagerPerformanceExpectations__c,
						  ManagersInterestSupport__c, MoraleOnYourTeam__c, NewCompanyName__c, NewRole__c, OnboardingExperience__c, 
						  OverallWorkExperience__c, PerformanceMeasured__c, PositionOffer__c, ReceivePerformanceReview__c, 
						  RegularOneToOneWithManager__c, RoleContributedCompany__c, SalesforceStrengthsAndWeaknesse__c, 
						  SomethingToShare__c, TerminationDate__c, ThinkLeaving__c, ValueAndEffectiveness__c, WhatWasDiscussed__c,
						  UnderstandRoleContributed__c, WhereAreYouGoing__c, LeavingInformationComment__c, SalesforceFeedBackComment__c,
						  ManagerAndTeamFeedBackComment__c,OverallFeedback__c,  Status__c, LastModifiedBy.Name, CreatedBy.Name, CreatedBy.Id
						  , CreatedDate, LastModifiedDate, LastModifiedBy.Id, CreatedById from ExitInterview__c Where Id =: interViewId ];
		 
						  
		if (exitInterviews.size() == 0)
		{
			throw new CustomException('You do not have access to this exit interview');
		}
		else
		{
			exitInterview = exitInterviews[0];
		}
		
		leavingReason = exitInterview.LeavingReason__c;
		leavingReasonJap=translateLeavingReason(leavingReason);
		//employee = [select Id, Name, Start_Date__c, Manager__r.Name, Title, Department, EmployeeNumber From User Where Id =: exitInterview.Employee__c ];
		employee = [select Id, Name, Start_Date__c, Manager__r.Name, Title, Cost_Center__c, EmployeeNumber From User Where Id =: exitInterview.Employee__c ];
						  
		employeeInner.setName(employee.Name);
		
		//if (employee.Department != null && employee.Department != '')
		if (employee.Cost_Center__c != null && employee.Cost_Center__c != '')
		{
			//employeeInner.setDepartmentName(employee.Department);
			employeeInner.setDepartmentName(employee.Cost_Center__c);
		}
		else
		{
			employeeInner.setDepartmentName('-');
		}
		
		
		if (employee.Manager__r.Name != null)
		{
			employeeInner.setManager(employee.Manager__r.Name);
		}
		else
		{
			employeeInner.setManager('-');	
		}
		
		if (employee.Title != null)
		{
			employeeInner.setJobTitle(employee.Title);	
		}
		else
		{
			employeeInner.setJobTitle('-');
		}
		
		employeeInner.setEmployeeId(employee.Id);
		 
		if (employee.Start_Date__c != null)
		{
			Date hireDate = employee.Start_Date__c;
			employeeInner.setHireDate(hireDate.Month() + '/' + hireDate.Day() + '/' + hireDate.year());
			
		}
		else
		{
			employeeInner.setHireDate('-');	
		}
		
		if (exitInterview.TerminationDate__c != null)
		{
			Date terminationDate = exitInterview.TerminationDate__c;

			employeeInner.setTerminationDate(terminationDate.Month() + '/' + terminationDate.Day() + '/' + terminationDate.Year());	
		}
		else
		{
			employeeInner.setTerminationDate('-');
		}
		if (employee.EmployeeNumber != null && employee.EmployeeNumber != '' )
		{
			employeeInner.setEmployeeNumber(employee.EmployeeNumber);
		}
		else
		{
			employeeInner.setEmployeeNumber('-');	
		}
		
		List<ExitInterviewComment__c> comments = [select Id, Name, BenefitsNotAsGood__c, Benefits__c, CanFedbackBeeShared__c, CareerDevelopmentOpportunities__c, 
						  CompensationNotGoodAs__c, Compensation__c, CultureAtSalesforce__c, ExpectationsNotClosed__c, Expectations__c, FrequencyMeetings__c,
						  HowYouHeardOportunity__c, ItemsNotRankedAsFive__c,
						  ManagerCommunicateDepartmentV2MOM__c, ManagerDoneDifferently__c, ManagerPerformanceExpectations__c,
						  ManagersInterestSupport__c, MoraleOnYourTeam__c, OnboardingExperience__c, 
						  OverallWorkExperience__c, PerformanceMeasured__c, PositionOffer__c, ReceivePerformanceReview__c, 
						  RegularOneToOneWithManager__c, RoleContributedCompany__c, LeavingReason__c
						  from ExitInterviewComment__c Where ExitInterview__c =: interViewId  limit 1];
						  
		List<ExitInterviewCommentContinue__c> commentsContinue = [select Id, HavePersonalV2MOM__c, SalesforceStrengthsAndWeaknesse__c, 
						  SomethingToShare__c, ThinkLeaving__c, ValueAndEffectiveness__c, WhatWasDiscussed__c,
						  UnderstandRoleContributed__c, WhereAreYouGoing__c  from ExitInterviewCommentContinue__c Where ExitInterview__c =: interViewId limit 1];
						  
		if (comments.size() > 0)
		{
			exitInterviewComment = comments[0];
		}
		else
		{
			exitInterviewComment= new 	ExitInterviewComment__c();
			if(Schema.sObjectType.ExitInterviewComment__c.fields.ExitInterview__c.isUpdateable()){
				exitInterviewComment.ExitInterview__c = exitInterview.Id;
			} else {
    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Exit interview comment not saved due to security violation'));
			}
		}
		
		if (commentsContinue.size() > 0)
		{
			exitInterviewCommentContinue = commentsContinue[0];
		}
		else
		{
			exitInterviewCommentContinue = new 	ExitInterviewCommentContinue__c();
			if(Schema.sObjectType.ExitInterviewCommentContinue__c.fields.ExitInterview__c.isUpdateable()){
				exitInterviewCommentContinue.ExitInterview__c = exitInterview.Id;
			} else {
    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Exit interview comment not saved due to security violation'));
			}
		}
		
		currentUser = [Select Id, Profile.Name, Start_Date__c, Title From User Where id =: userInfo.getUserId()];
		
		List<V2MOM__c> v2moms = [select Id, Effective_Date__c, Status__c, V2MOM_Type__c from V2MOM__c Where OwnerId =: employee.Id order by createdDate desc limit 1];
		List<PerformanceReview__c> performanceReviews = [select Id, PerformanceReviewPeriod__r.Effective_Date__c, PerformanceReviewPeriod__r.V2MOM_Type__c, ReviewRating__c, ReviewRating__r.OverallRating__c  From PerformanceReview__c where employee__c =: employee.Id and Status__c = 'Complete' order by createdDate desc limit  1];
		
		if (v2moms.size() > 0)
		{
			hasV2MOM = true;
			mostRecentV2MOM = v2moms[0];	
		}
		else
		{
			hasV2MOM = false;
			mostRecentV2MOM = new V2MOM__c();
		}
		
		if (performanceReviews.size() > 0)
		{
			mostRecentReview = performanceReviews[0];
			review = new PerformanceReview(mostRecentReview);
		}
		else
		{
			mostRecentReview = new PerformanceReview__c(); 	
			review = new PerformanceReview(mostRecentReview);
		}
	}

	public Boolean getIsV2MOMPresent()
	{
		return hasV2MOM;	
	} 
	//function to set the status as declined to participate from the 'declined to participate button'
	public pageReference declinedToParticipate(){
		if(Schema.sObjectType.exitInterview__c.fields.Status__c.isUpdateable() && Schema.sObjectType.exitInterview__c.fields.Status__c.isCreateable()){
			exitInterview.Status__c=declined;
			upsert exitInterview;
		} else {
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Action aborted due to security violation'));
		}
		return new Pagereference('/apex/exitInterview?id='+interViewId);
	}
	//returns whether or not the declined to complete button should be rendered
	public boolean getShowDeclined(){
		boolean result=false;
		if (currentUser.Profile.Name=='Employee Success Representative'||currentUser.profile.id=='00e70000000wFI3'||currentUser.profile.Name=='ES Admin'||currentUser.profile.Name=='systemadministrator'){
			if(exitInterview.Status__c!=declined &&exitInterview.status__c!='Completed'){
				result=true;
			}
		}
		return result;
		//return true;
	}
	public PerformanceReview getReview()
	{
		return review;	
	}
	
	public V2MOM__c getMostRecentV2MOM()
	{
		return mostRecentV2MOM;	
	}
	
	public String getExitInterviewDate()
	{
		if (exitInterView.TerminationDate__c != null)
		{
			return exitInterView.TerminationDate__c.format();
		}
		return '-';
	}
	
	public PerformanceReview__c getMostRecentReview()
	{
		return mostRecentReview;
	}
	
	public User getEmployeeObject()
	{
		return employee;	
	}
	
	public User getCurrentUser()
	{
		return currentUser;
	}
	
	public ExitInterviewComment__c getInterviewComment()
	{
		return exitInterviewComment;
	}
	
	public void setInterviewComment(ExitInterviewComment__c value)
	{
		exitInterviewComment = value;
	}
	
	public ExitInterviewCommentContinue__c getInterviewCommentContinue()
	{
		return exitInterviewCommentContinue;
	} 
	
	public void setInterviewCommentContinue(ExitInterviewCommentContinue__c value)
	{
		exitInterviewCommentContinue = value;
	}
	
	public String getStatus()
	{
		return exitInterview.Status__c;
	}
	
	public Boolean getErrorDate()
	{
		return errorDate;
	}
	public void setErrorDate(Boolean value)
	{
		errorDate = value;
	}
	
	public String getLeavingReason()
	{
		if (leavingReason != null)
		{
			List<String> leavingReasons = leavingReason.split(';');
			String leavingReasonToRet = '';
			Boolean firstTime = true;
			for (String s : leavingReasons )
			{
				if (firstTime)
				{
					firstTime = false;
					leavingReasonToRet = s;
				}
				else
				{
					leavingReasonToRet = s + '; ' + leavingReasonToRet; 
				}
			}
		
				return leavingReasonToRet;
		}
		else
		{
			return '';
		}
	}
	
	public void setLeavingReason(String value)
	{
		leavingReason = value;
	}
	
	/**
	* Save exit interview object and submit
    * @return Boolean true if employee can edit or not it he can't
    */
	public Boolean getShowEditField()
	{
		if ((exitInterview.Status__c == 'Not completed')&& currentUser.Id == exitInterview.Employee__c)
		{
			return true;
		} 
		if ((exitInterview.Status__c == 'Not completed')&& getIsESR())
		{
			return true;	
		}
		if (exitInterview.Status__c==declined){
			return false;
		}
		return false;
	}
	
	/**
	* Return  true if exit interview is in complete Status
	* @Return Boolean
	*/
	public Boolean getIsComplete()
	{
		return exitInterview.Status__c == 'Completed';
		
	}
	public Boolean getHasDeclined(){
		return exitInterview.Status__c==declined;
	}
	
	/**
	* Return  true if the current user is sys admin profile
	* @Return Boolean
	*/
	public Boolean getIsSysAdmin()
	{
		return paccess.getIsOnlySysAdminProfile();
	}
	
	/**
	* Return  true if the current user is the employee of this interview
	* @Return Boolean
	*/
	public Boolean getIsEmployee()
	{
		return (currentUser.Id == ExitInterview.Employee__c);
	}
	
	/**
	* Return  true if the no information section is shown
	* @Return Boolean
	*/
	public Boolean getShowNoInformation()
	{
		if (getIsEmployee() && ExitInterview.Status__c == 'Completed' ) return true;
		return false;
	}
	
	/**
	* Return  true if the exit interview is in complete status
	* @Return Boolean
	*/
	public Boolean getIsInCompleteStatus()
	{
		return  ExitInterview.Status__c == 'Completed';
	}
	
	/**
	* Return  true if the current user is the ESR
	* @Return Boolean
	*/
	public Boolean getIsESR()
	{
		if (currentUser.Profile.id == PerformanceAccessUtil.getSystem_Administrator_Id() || currentUser.Profile.Name=='systemadministrator') return true;
		if (currentUser.Title == 'ES Representative (ESR)') return true;
		if (currentUser.Profile.Name == 'ES Admin') return true;
		if (currentUser.Profile.Name == 'ESR') return true;
		if (currentUser.Profile.Name == 'Employee Success Representative') return true;
		if (currentUser.Profile.Name == 'Employee Success/Business Partner') return true;
		
		return false;
		//return true;
		
	}
	
	/**
	* Return if the current user has access to comment
	* @Return Boolean user has the access to comment
	*/
	public Boolean getShowESRComment()
	{
		if (exitInterview.Status__c != 'Completed') return false;
		if (userInfo.getUserId() == exitInterview.Employee__c ) return false;
		return true;
	}
	
	/**
	* Save exit interview object and 
    * @return PageReference page with saved information
    */
	public void saveAndSubmit()
	{
		if (checkTerminationDate())
		{
			if(Schema.sObjectType.exitInterview__c.fields.Status__c.isUpdateable() &&
				Schema.sObjectType.exitInterview__c.fields.LeavingReason__c.isUpdateable()){
				exitInterview.Status__c = 'Completed';
				exitInterview.LeavingReason__c = leavingReason;
				leavingReasonJap=translateLeavingReason(leavingReason);
			} else {
    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Action aborted due to security violation'));
			}
			if(Schema.sObjectType.exitInterview__c.isUpdateable() ){
				update exitInterview;
			} else {
    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Action aborted due to security violation'));
			}
		exitInterview = [select Id, Name, HavePersonalV2MOM__c, Compensation__c, BenefitsNotAsGood__c, Benefits__c, CanFedbackBeeShared__c, CareerDevelopmentOpportunities__c, 
						  CompensationNotGoodAs__c, Compensattion__c, CultureAtSalesforce__c, CurrentManager__c, 
						  Employee__c, Employee__r.Manager__c, ExpectationsNotClosed__c, Expectations__c, FrequencyMeetings__c,
						  HireDate__c, HowYouHeardOportunity__c, ItemsNotRankedAsFive__c, LeavingReasonOther__c, LeavingReason__c, 
						  ManagerCommunicateDepartmentV2MOM__c, ManagerDoneDifferently__c, ManagerPerformanceExpectations__c,
						  ManagersInterestSupport__c, MoraleOnYourTeam__c, NewCompanyName__c, NewRole__c, OnboardingExperience__c, 
						  OverallWorkExperience__c, PerformanceMeasured__c, PositionOffer__c, ReceivePerformanceReview__c, 
						  RegularOneToOneWithManager__c, RoleContributedCompany__c, SalesforceStrengthsAndWeaknesse__c, 
						  SomethingToShare__c, TerminationDate__c, ThinkLeaving__c, ValueAndEffectiveness__c, WhatWasDiscussed__c,
						  UnderstandRoleContributed__c, WhereAreYouGoing__c, LeavingInformationComment__c, SalesforceFeedBackComment__c,
						  ManagerAndTeamFeedBackComment__c,OverallFeedback__c,  Status__c, LastModifiedBy.Name, CreatedBy.Name, CreatedBy.Id
						  , CreatedDate, LastModifiedDate, LastModifiedBy.Id, CreatedById from ExitInterview__c Where Id =: interViewId ];
						  
		//employee = [select Id, Name, Start_Date__c, Manager__r.Name, Title, Department From User Where Id =: exitInterview.Employee__c ];
		employee = [select Id, Name, Start_Date__c, Manager__r.Name, Title, Cost_Center__c From User Where Id =: exitInterview.Employee__c ];
		}
		
	}
	
	/**
	* Save exit interview object.
    * @return PageReference page with saved information
    */
	public void saveAndFinishLater()
	{
		if (checkTerminationDate() && Schema.sObjectType.exitInterview__c.fields.LeavingReason__c.isUpdateable())
		{
			exitInterview.LeavingReason__c = leavingReason;
			leavingReasonJap=translateLeavingReason(leavingReason);
		
			update exitInterview;
		} else {
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Action aborted due to security violation'));
		}
	}
	private String translateLeavingReason(String leavingReason){
		string translated='';
		if(leavingReason!=''&&leavingReason!=null){
			translated = leavingReason;
			translated = translated.replace('Better opportunity', 'より良い機会');
			translated = translated.replace('Job burnout', '仕事に燃え尽きた');
			translated = translated.replace('Working Conditions', '仕事状況');
			translated = translated.replace('Job content', '仕事内容');
			translated = translated.replace('Personal reasons', '個人的な理由');
			translated = translated.replace('Relocation', '移転');
			translated = translated.replace('Returning to school', '学校へ戻る');
			translated = translated.replace('Compensation', '報酬');
			translated = translated.replace('Career Development', 'キャリアを磨く');
			translated = translated.replace('Other', 'その他');
			translated = translated.replace('Management/Leadership', '経営層/リーダーシップ');
		}
		return translated;
	}
	
	/**
	* Save exit interview comment for ESR
    * @return PageReference page with saved information
    */
	public void save()
	{	
	 if (checkTerminationDate())
		{
		PageReference retPage = Page.ExitInterview;
		retPage.getParameters().put('id', System.currentPageReference().getParameters().get('id'));
		retPage.setRedirect(true);
		if(ExitInterviewComment__c.SObjectType.getDescribe().isCreateable()&& ExitInterviewComment__c.SObjectType.getDescribe().isUpdateable() &&
		   ExitInterviewCommentContinue__c.SObjectType.getDescribe().isCreateable() && ExitInterviewCommentContinue__c.SObjectType.getDescribe().isUpdateable() && 
		   ExitInterview__c.SObjectType.getDescribe().isCreateable() && ExitInterview__c.SObjectType.getDescribe().isUpdateable()){
				upsert(exitInterview);
				upsert(exitInterviewComment);
				upsert(exitInterviewCommentContinue);   	
		   } else {
    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Action aborted due to security violation'));
			}
		
		}
	}
	
	/**
	* Return true if the Regular one to one manager is Yes
	* @Return Boolean
	*/
	public Boolean getIsShowMangerOneToOne()
	{
		if (exitInterView.RegularOneToOneWithManager__c != 'Yes')
		{
			return false;	
		}
		
		if (! getShowEditField())
		{
			return true; 		
		}
		
		return false;
	}
	
	/**
	* Return true if the leaving other reason field is populated
	* @Return Boolean
	*/
	public Boolean getIsShowLeavingOhter()
	{
		
		if ((exitInterView.LeavingReasonOther__c == '') || (exitInterView.LeavingReasonOther__c == null))
		{
			return false;
		}
		if (! getShowEditField())
		{
			return true; 		
		}
		
		return false;
	}
	
	/**
	* Save exit interview comment for ESR and send back to employee.
    * @return PageReference page with saved information
    */
	public void saveSendBackToEmployee()
	{	
		if (checkTerminationDate())
		{
			if(Schema.sObjectType.exitInterview__c.fields.Status__c.isUpdateable()){
				exitInterview.Status__c = 'Not Completed';
				update exitInterview;
			} else {
    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Action aborted due to security violation'));
			}
		if(ExitInterviewComment__c.SObjectType.getDescribe().isCreateable() && ExitInterviewComment__c.SObjectType.getDescribe().isUpdateable() &&
		   ExitInterviewCommentContinue__c.SObjectType.getDescribe().isCreateable() && ExitInterviewCommentContinue__c.SObjectType.getDescribe().isUpdateable()){
				upsert(exitInterviewComment);
				upsert(exitInterviewCommentContinue);
		}else {
    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Action aborted due to security violation.'));
		}	
		exitInterview = [select Id, Name, HavePersonalV2MOM__c, Compensation__c, BenefitsNotAsGood__c, Benefits__c, CanFedbackBeeShared__c, CareerDevelopmentOpportunities__c, 
						  CompensationNotGoodAs__c, Compensattion__c, CultureAtSalesforce__c, CurrentManager__c, 
						  Employee__c, Employee__r.Manager__c, ExpectationsNotClosed__c, Expectations__c, FrequencyMeetings__c,
						  HireDate__c, HowYouHeardOportunity__c, ItemsNotRankedAsFive__c, LeavingReasonOther__c, LeavingReason__c,
						  ManagerCommunicateDepartmentV2MOM__c, ManagerDoneDifferently__c, ManagerPerformanceExpectations__c,
						  ManagersInterestSupport__c, MoraleOnYourTeam__c, NewCompanyName__c, NewRole__c, OnboardingExperience__c, 
						  OverallWorkExperience__c, PerformanceMeasured__c, PositionOffer__c, ReceivePerformanceReview__c, 
						  RegularOneToOneWithManager__c, RoleContributedCompany__c, SalesforceStrengthsAndWeaknesse__c, 
						  SomethingToShare__c, TerminationDate__c, ThinkLeaving__c, ValueAndEffectiveness__c, WhatWasDiscussed__c,
						  UnderstandRoleContributed__c, WhereAreYouGoing__c, LeavingInformationComment__c, SalesforceFeedBackComment__c,
						  ManagerAndTeamFeedBackComment__c,OverallFeedback__c,  Status__c, LastModifiedBy.Name, CreatedBy.Name, CreatedBy.Id
						  , CreatedDate, LastModifiedDate, LastModifiedBy.Id, CreatedById from ExitInterview__c Where Id =: interViewId ];
						  
		leavingReason = exitInterview.LeavingReason__c;
		leavingReasonJap = translateLeavingReason(leavingReason);
		//employee = [select Id, Name, Start_Date__c, Manager__r.Name, Title, Department From User Where Id =: exitInterview.Employee__c ];
		employee = [select Id, Name, Start_Date__c, Manager__r.Name, Title, Cost_Center__c From User Where Id =: exitInterview.Employee__c ];
		}
	}
	
	//Get the exit interview passed by parameters
	public ExitInterview__c getExitInterview()
	{
		return exitInterview;
	}
	
	//Return employee basic information
	public Employee getEmployee()
	{
		return employeeInner;
	}
	
	/**
	* Return true if leaving information field is null
    * @return Boolean
    */
	public Boolean getIsLeavingInformationNull()
	{
		return exitInterview.LeavingReason__c == null;
	}
	
	/**
	* Return true if leaving information other field is null
    * @return Boolean
    */
	public Boolean getIsLeavingInformationOtherNull()
	{
		return exitInterview.LeavingReasonOther__c == null;
	}
	
	/**
	* Return true if think leaving information field is null
    * @return Boolean
    */
	public Boolean getIsThinkLeavingNull()
	{
		return exitInterview.ThinkLeaving__c == null;
	}
	
	/**
	* Return true if company name field is null
    * @return Boolean
    */
	public Boolean getIsCompanyNameNull()
	{
		return exitInterview.NewCompanyName__c == null;
	}
	
	/**
	* Return true if new role field is null
    * @return Boolean
    */
	public Boolean getIsNewRoleNull()
	{
		return exitInterview.NewRole__c == null;
	}
	
	/**
	* Return true if how you hear oportunity role field is null
    * @return Boolean
    */
	public Boolean getIsHowYouHeardOportunityNull()
	{
		return exitInterview.HowYouHeardOportunity__c == null;
	}
	
	/**
	* Return true if how you hear oportunity role field is null
    * @return Boolean
    */
	public Boolean getIsPositionOfferNull()
	{
		return exitInterview.PositionOffer__c == null;
	}
	
	/**
	* Return true if benefits not good as field is null
    * @return Boolean
    */
	public Boolean getIsBenefitsNotGoodNull()
	{
		return exitInterview.BenefitsNotAsGood__c == null;
	}
	
	/**
	* Return true if compesentation field is null
    * @return Boolean
    */
	public Boolean getIsCompensationNull()
	{
		return exitInterview.Compensattion__c == null;
	}
	
	/**
	* Return true if compesentation not good field is null
    * @return Boolean
    */
	public Boolean getIsCompensationNotGoodAsNull()
	{
		return exitInterview.CompensationNotGoodAs__c == null;
	}
	
	/**
	* Return true if expectation field is null
    * @return Boolean
    */
	public Boolean getIsExpectationNull()
	{
		return exitInterview.Expectations__c == null;
	}
	
	/**
	* Return true if expectation not closed field is null
    * @return Boolean
    */
	public Boolean getIsExpectationNotClosedNull()
	{
		return exitInterview.ExpectationsNotClosed__c== null;
	}
	
	/**
	* Return true if benefits field is null
    * @return Boolean
    */
	public Boolean getIsBenefitsNull()
	{
		return exitInterview.Benefits__c == null;
	}
	
	/**
	* Return true if manager set performance expectation field is null
    * @return Boolean
    */
	public Boolean getIsManagerPerformanceExpectationsNull()
	{
		return exitInterview.ManagerPerformanceExpectations__c == null;
	}
	
	/** 
	* Return true if performance measured filed is null
    * @return Boolean
    */
	public Boolean getIsPerformanceMeasuredNull()
	{
		return exitInterview.PerformanceMeasured__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsReceivePerformanceReviewNull()
	{
		return exitInterview.ReceivePerformanceReview__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsRegularOneToOneWithManager()
	{
		return exitInterview.RegularOneToOneWithManager__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsOnBoardingExperienceNull()
	{
		return exitInterview.OnboardingExperience__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsCurrentManagerNull()
	{
		return exitInterview.CurrentManager__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsManagersInterestSupportNull()
	{
		return exitInterview.ManagersInterestSupport__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsCareerDevelopmentOpportunitiesNull()
	{
		return exitInterview.CareerDevelopmentOpportunities__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsCultureAtSalesforceNull()
	{
		return exitInterview.CultureAtSalesforce__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsMoraleOnYourTeamNull()
	{
		return exitInterview.MoraleOnYourTeam__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsItemsNotRankedAsFiveNull()
	{
		return exitInterview.ItemsNotRankedAsFive__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsManagerDoneDifferentlyNull()
	{
		return exitInterview.ManagerDoneDifferently__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsManagerCommunicateDepartmentV2MOMNull()
	{
		return exitInterview.ManagerCommunicateDepartmentV2MOM__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsUnderstandRoleContributedNull()
	{
		return exitInterview.UnderstandRoleContributed__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsRoleContributedCompanyNull()
	{
		return exitInterview.RoleContributedCompany__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsHavePersonalV2MOMNull()
	{
		return exitInterview.HavePersonalV2MOM__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsSalesforceStrengthsAndWeaknesseNull()
	{
		return exitInterview.SalesforceStrengthsAndWeaknesse__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsOverallWorkExperienceNull()
	{
		return exitInterview.OverallWorkExperience__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsSomethingToShareNull()
	{
		return exitInterview.SomethingToShare__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsCommentLeavingReasonNull()
	{
		return exitInterviewComment.LeavingReason__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsCanFedbackBeeSharedNull()
	{
		return exitInterview.CanFedbackBeeShared__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsCommentContinueThinkLeavingNull()
	{
		return exitInterviewCommentContinue.ThinkLeaving__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsCommentPositionOfferNull()
	{
		return exitInterviewComment.PositionOffer__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsExpectationsNotClosedNull()
	{
		return exitInterviewComment.ExpectationsNotClosed__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsComentManagerPerformanceExpectationsNull()
	{
		return exitInterviewComment.ManagerPerformanceExpectations__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsComentPerformanceMeasuredNull()
	{
		return exitInterviewComment.PerformanceMeasured__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsComentReceivePerformanceReviewNull()
	{
		return exitInterviewComment.ReceivePerformanceReview__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsComentRegularOneToOneWithManagerNull()
	{
		return exitInterviewComment.RegularOneToOneWithManager__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsComentItemsNotRankedAsFiveNull()
	{
		return exitInterviewComment.ItemsNotRankedAsFive__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsComentManagerDoneDifferentlyNull()
	{
		return exitInterviewComment.ManagerDoneDifferently__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsComentManagerCommunicateDepartmentV2MOMNull()
	{
		return exitInterviewComment.ManagerCommunicateDepartmentV2MOM__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsComentUnderstandRoleContributedNull()
	{
		return exitInterviewCommentContinue.UnderstandRoleContributed__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsComentUnderstandRoleContributedCompanyNull()
	{
		return exitInterviewComment.RoleContributedCompany__c == null;
	}
	
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsComentHavePersonalV2MOMNull()
	{
		return exitInterviewCommentContinue.HavePersonalV2MOM__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsCommentSalesforceStrengthsAndWeaknesseNull()
	{
		return exitInterviewCommentContinue.SalesforceStrengthsAndWeaknesse__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsCommentOverallWorkExperienceNull()
	{
		return exitInterviewComment.OverallWorkExperience__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsCommentSomethingToShareNull()
	{
		return exitInterviewCommentContinue.SomethingToShare__c == null;
	}
	
	/**
	* Return true if receive performance review filed is null
    * @return Boolean
    */
	public Boolean getIsCommentCanFedbackBeeSharedNull()
	{
		return exitInterviewComment.CanFedbackBeeShared__c == null;
	}
	
	/**
	* Delete and return to the list page of exit interview objects
    * @return PageReference
    */
	public PageReference DeleteExitInterview()
	{
		delete exitInterview;
		
		PageReference retPage = Page.SendExitInterview;
		retPage.setRedirect(true);
		
		return retPage;
	}
	
	/**
	* This return to the list of the exit interviex
	* @Return PageReference to the exit interview list page
	*/
	public PageReference CancelExitInterview()
	{
		PageReference retPage = Page.SendExitInterview;
		retPage.setRedirect(true);
		
		return retPage;
	}
	
	/**
	* This return true if the employee had entered some information
	* @Return Boolean
	*/
	public Boolean getIsInformationEntered()
	{
		if (exitInterView.Benefits__c != null) return true;
		if (exitInterView.BenefitsNotAsGood__c != null) return true;
		if (exitInterView.CanFedbackBeeShared__c != null) return true;
		if (exitInterView.CareerDevelopmentOpportunities__c != null) return true;		
		if (exitInterView.Compensation__c != null) return true;
		if (exitInterView.CompensationNotGoodAs__c != null) return true;
		if (exitInterView.Compensattion__c != null) return true;
		if (exitInterView.CultureAtSalesforce__c != null) return true;
		if (exitInterView.CurrentManager__c != null) return true;
		if (exitInterView.CanFedbackBeeShared__c != null) return true;
		if (exitInterView.CareerDevelopmentOpportunities__c != null) return true;
		if (exitInterView.Expectations__c != null) return true;
		if (exitInterView.ExpectationsNotClosed__c != null) return true;
		if (exitInterView.FrequencyMeetings__c != null) return true;
		if (exitInterView.HavePersonalV2MOM__c != null) return true;
		if (exitInterView.HowYouHeardOportunity__c != null) return true;
		if (exitInterView.ItemsNotRankedAsFive__c != null) return true;
		if (exitInterView.LeavingReason__c != null) return true;
		if (exitInterView.LeavingReasonOther__c != null) return true;
		if (exitInterView.ManagerCommunicateDepartmentV2MOM__c != null) return true;
		if (exitInterView.ManagerDoneDifferently__c != null) return true;
		if (exitInterView.ManagerPerformanceExpectations__c != null) return true;
		if (exitInterView.ManagersInterestSupport__c!= null) return true;
		if (exitInterView.MoraleOnYourTeam__c!= null) return true;
		if (exitInterView.NewCompanyName__c!= null) return true;
		if (exitInterView.NewRole__c!= null) return true;
		if (exitInterView.OnboardingExperience__c!= null) return true;
		if (exitInterView.OverallWorkExperience__c!= null) return true;
		if (exitInterView.PerformanceMeasured__c!= null) return true;
		if (exitInterView.PositionOffer__c!= null) return true;
		if (exitInterView.ReceivePerformanceReview__c!= null) return true;
		if (exitInterView.RegularOneToOneWithManager__c!= null) return true;
		if (exitInterView.RoleContributedCompany__c!= null) return true;
		if (exitInterView.SalesforceStrengthsAndWeaknesse__c!= null) return true;
		if (exitInterView.SomethingToShare__c!= null) return true;
		if (exitInterView.ThinkLeaving__c!= null) return true;
		if (exitInterView.UnderstandRoleContributed__c!= null) return true;
		if (exitInterView.ValueAndEffectiveness__c!= null) return true;
		if (exitInterView.WhatWasDiscussed__c!= null) return true;
		if (exitInterView.WhereAreYouGoing__c!= null) return true;
		
		return false;
	}
	
	//Inner class to keep las performance review information
	public class PerformanceReview
	{
		private String performanceInformation;
		private String fiscalYear;
		private PerformanceReview__c performanceRev;
		
		public PerformanceReview(PerformanceReview__c performanceReview)
		{
			if (performanceReview.Id != null)
			{
				performanceRev = performanceReview;
				String scorecard = '';
				String v2momType = performanceReview.PerformanceReviewPeriod__r.V2MOM_Type__c;
				fiscalYear =  performanceReview.PerformanceReviewPeriod__r.Effective_Date__c;
				String scorecardQuarter = '';
				Integer rating;
				if(performanceReview.ReviewRating__r.OverallRating__c==null){
					rating=0;
				}
				else{
					rating =  performanceReview.ReviewRating__r.OverallRating__c.intValue();
				}
				String ratingLabel = PAMUtil.getRatingLabel(rating);
				
				if (v2momType != null)
				{
					if (v2momType.indexOf('Q1') != -1)
					{
						scorecardQuarter = 'Q1/Q2';
					}
					else
					{
						if (v2momType.indexOf('Q3') != -1)
						{
							scorecardQuarter = 'Q3/Q4';	
						}
					}
				}
				
				
				performanceInformation = ' - Rating ' + ratingLabel ;
			}
			else
			{
				performanceInformation = ' - ';
			}
		}
		
		public String getPerformanceInformation()
		{
			return performanceInformation;
		} 
		
		public String getFiscalYear()
		{
			return fiscalYear;
		}
		
		public PerformanceReview__c getPerformanceReview()
		{
			return performanceRev;
		}
	}
	
	public Boolean getIsSysAdminEsbpEsAdminESR()
	{
		if (currentUser.Profile.id == PerformanceAccessUtil.getSystem_Administrator_Id() || currentUser.Profile.Name=='systemadministrator'||currentUser.Profile.Name == 'ES Admin' || currentUser.Profile.Name == 'ESR' || currentUser.Profile.Name == 'Employee Success/Business Partner' )
		{
			return true;
		}
		 
		return false;
	}
	
	/**
	* Check if the termination date is grater than the hire date
	* @Return Boolean
	*/
	public Boolean checkTerminationDate()
	{
		if ( exitInterview.TerminationDate__c < employee.Start_Date__c)
		{
			errorDate = true;
			return false;
		}
		errorDate = false;
		return true;
	}
	
	/**
	* Check if the termination date is null
	* @Return Boolean
	*/
	public Boolean getIsTerminationDateNull()
	{
		return exitInterview.TerminationDate__c == null;
	}
	
	public String getCreatedDate()
	{
		return ExitInterview.CreatedDate.format();	
	}
	
	public String getLastModifiedDate()
	{
		return ExitInterview.LastModifiedDate.format();	
	}
	
	//Inner class to keep employee main information together
	public class Employee
	{
		private String manager;
		private String name;
		private String terminationDate;
		private String hireDate;
		private String jobTitle;
		private String departmentName;
		private Id employeeId;
		private String employeeNumber;
		
		public String getManager()
		{
			return manager;
		}
		
		public void setEmployeeId(Id value)
		{
			employeeId = value;
		}
		
		public Id getEmployeeId()
		{
			return employeeId;
		}
		
		public void setManager(String value)
		{
			manager = value;
		}
		
		public String getName()
		{
			return name;
		}
		
		public void setName(String value)
		{
			name = value;
		}
		
		public String getTerminationDate()
		{
			return  terminationDate;
		}
		
		public void setTerminationDate(String value)
		{
			terminationDate = value;
		}

		public String getHireDate()
		{
			return hireDate;
		}
		
		public void setHireDate(String value)
		{
			hireDate = value;
		}
		
		public String getJobTitle()
		{
			return jobTitle;		
		}
		
		public void setJobTitle(String value)
		{
			jobTitle = value;	
			
		}
		
		public String getDepartmentName()
		{
			return departmentName;
		}
		
		public void setDepartmentName(String value)
		{
			departmentName = value;		
		}
		public String getEmployeeNumber()
		{
			return employeeNumber;
		}
		public void setEmployeeNumber(String value)
		{
			employeeNumber = value;
		}
	}
}