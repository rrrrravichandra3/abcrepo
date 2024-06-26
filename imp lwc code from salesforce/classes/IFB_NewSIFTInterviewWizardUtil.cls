/**
* @author Apuroop Gadde
* @date 07-09-2017
* @group ControllerUtils
* @description Utils class for methods used in new SIFTInterviewWizard Controller 
*/
public with sharing class IFB_NewSIFTInterviewWizardUtil {
	/**
	* @description This method is used to get the list of different types of interview formats.
	* @return List of interview formats.
	**/
	public static List<IFB_SelectOption> getInterviewFormats() {
		List<IFB_SelectOption> interviewFormats = new List<IFB_SelectOption>();
		Schema.DescribeFieldResult fieldResult = IFB_Interview__c.Interview_Format__c.getDescribe();
		List<Schema.PicklistEntry> pickListEntries = fieldResult.getPicklistValues();
		for(Schema.PicklistEntry plEntry : pickListEntries) {
			IFB_SelectOption interviewFormat = new IFB_SelectOption(plEntry.getLabel(),plEntry.getLabel());
			interviewFormats.add(interviewFormat);
		}
		return interviewFormats;
	}

	/**
	* @description This method returns the Interview types pertaining to the incoming sift group
	* @param siftGroup A string that contains the sift group whose record types need to be returned.
	* @return A list of record types pertaining to the input sift group.
	**/
	public static List<IFB_SelectOption> getIntrvwTypeForMatchingGroupAndPosition(String siftGroup){
		List<IFB_SelectOption> interviewTypes = new List<IFB_SelectOption>();
		if(String.isEmpty(siftGroup) == false){
			List<SIFT_Interview_Type__c> intvTypes = [Select Id, Name from SIFT_Interview_Type__c where SIFT_Group__r.Name = :siftGroup AND Active__c=true];
			for(SIFT_Interview_Type__c currentIntvType : intvTypes){
				interviewTypes.add(new IFB_SelectOption(currentIntvType.Id, currentIntvType.Name));
			}
		}
		return interviewTypes;
	}

	/**
	* @description This method returns the interviews for the incoming recruit Id.
	* @param recruitId Id fo the recruit whose interviews need to be returned.
	* @return A list of interviews that are related to the input recruit Id.
	**/
	public static List<IFB_Interview__c> getInterviewsForRecruit(Id recruitId) {
		return [SELECT Name,Interviewer__r.Name, Interviewer__r.Id, Interview_Format__c, Scheduled_Interview_Date_only__c,
					   Status__c, Interview_Type__r.Name FROM IFB_Interview__c WHERE Candidate__c = :recruitId];		
	}

	/**
	* @description Returns fields from WD Job Application that are needed for the new sift interview wizard.
	* @param wdJobApplicationId Id of the WD Job application whose fields need to be returned.
	* @return A WD Job application record that pertains to the input Id.
	**/
	public static WDR_Application__c getWDJobApplication(Id wdJobApplicationId) {
		List<WDR_Application__c> application = [SELECT SIFT_Group__c, SIFT_Group_Lookup__r.Name,Internal_Candidate__c, Job__r.Hiring_Manager__c, Job__r.External_Recruiter_1__c,Job__r.External_Recruiter_2__c,Job__r.Internal_Recruiter_1__c,Job__r.Internal_Recruiter_2__c,Is_this_a_SIFT_Interview__c,Candidate_Stage__c,Application_Step__c
												FROM WDR_Application__c where Id = :wdJobApplicationId];
		if(application.size() != 0) {
			return application.get(0);
		}
		return null;
	}

	/**
	* @description This method is used to get the list of all the supported time zones
	* @return List of time zones
	**/
	public static List<IFB_SelectOption> getTimeZones() {
		List<IFB_SelectOption> timeZones = new List<IFB_SelectOption>();
		Schema.DescribeFieldResult fieldResult = IFB_Interview__c.Time_Zone__c.getDescribe();
		List<Schema.PicklistEntry> pickListEntries = fieldResult.getPicklistValues();
		for(Schema.PicklistEntry plEntry : pickListEntries) {
			IFB_SelectOption timeZone = new IFB_SelectOption(plEntry.getValue(),plEntry.getLabel());
			timeZones.add(timeZone);
		}
		return timeZones;
	}

	/**
	* @description This method is used to get the list of possible interview start times
	* @return List of interview start times
	**/
	public static List<IFB_SelectOption> getInterviewStartTimes() {
		List<IFB_SelectOption> interviewStartTimes = new List<IFB_SelectOption>();
		Schema.DescribeFieldResult fieldResult = IFB_Interview__c.Interview_Start_Time__c.getDescribe();
		List<Schema.PicklistEntry> pickListEntries = fieldResult.getPicklistValues();
		for(Schema.PicklistEntry plEntry : pickListEntries) {
			IFB_SelectOption interviewStartTime = new IFB_SelectOption(plEntry.getValue(),plEntry.getLabel());
			interviewStartTimes.add(interviewStartTime);
		}
		return interviewStartTimes;
	}	
}