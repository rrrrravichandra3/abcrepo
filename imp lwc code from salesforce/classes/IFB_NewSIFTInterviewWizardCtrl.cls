/**
* @author Angel Abrego
* @date 07-09-2017
* @group Controller Class
* @description Controller class for for creating new SIFT Interview from WD job application
*/
public with sharing class IFB_NewSIFTInterviewWizardCtrl {
	private static WDR_Application__c wdApp;

	public class IFB_NewSIFTInterviewWizardCtrlInitialResources {
        
        @AuraEnabled public List<sObject> existingRecruits;
        @AuraEnabled public IFB_Interview_Candidate__c newRecruit;
        @AuraEnabled public IFB_Interview__c interview;
        @AuraEnabled public List<IFB_SelectOption> interviewTypes;
        @AuraEnabled public List<IFB_SelectOption> interviewFormats;
        @AuraEnabled public List<IFB_SelectOption> timeZones;
        @AuraEnabled public List<IFB_SelectOption> interviewStartTimes;
        @AuraEnabled public List<IFB_Interview__c> createdInterviews;
        
        public IFB_NewSIFTInterviewWizardCtrlInitialResources(
        				 List<sObject> existingRecruits,
        				 IFB_Interview_Candidate__c newRecruit,
        				 IFB_Interview__c interview,
        				 List<IFB_SelectOption> interviewTypes,
                         List<IFB_SelectOption> interviewFormats,
                         List<IFB_SelectOption> timeZones,
                         List<IFB_SelectOption> interviewStartTimes,
                         List<IFB_Interview__c> createdInterviews){
                             
            this.existingRecruits = existingRecruits;
            this.newRecruit = newRecruit;
            this.interview = interview;
            this.interviewTypes = interviewTypes;
            this.timeZones = timeZones;
            this.interviewStartTimes = interviewStartTimes;
            this.interviewFormats = interviewFormats;
            this.createdInterviews = createdInterviews;
        }
        
    }

    //TODO: We define Ids as String data types, so we allow empty or null values. But, we need to validate that in case that
    // 	    they are not empty they are actual "Id" values.
	/**
	* @description Method that returns all the details that are needed to initialize a new SIFT interview wizard page.
	* @param recruitId Id of the recruit whose interviews are to be created.
	* @param wdrApplicationId Id of the related WD Job Application.
	* @param recruitRepointingOnly a boolean which determines if this is only a repointing of recruit or creating of interviews.
	* @param siftGroup The group to which the WD Job application belongs to.
	* @return Object containing all the details that are needed to initialize the new SIFT interview wizard page.
	**/
	@AuraEnabled
	public static IFB_NewSIFTInterviewWizardCtrlInitialResources getInitialResources(String recruitId, String wdrApplicationId,
																						boolean recruitRepointingOnly) {
		// Instantiate a 'SIFT Interview' record
		IFB_Interview__c interview = new IFB_Interview__c();
		IFB_Interview_Candidate__c newRecruit;
		List<IFB_Interview__c> createdInterviewsForRecruit;
		List<IFB_SelectOption> interviewTypeOptions;

		if (String.isEmpty(recruitId) == false) {
			interview.Candidate__c = recruitId;	
			createdInterviewsForRecruit = IFB_NewSIFTInterviewWizardUtil.getInterviewsForRecruit(recruitId);
			wdApp = IFB_NewSIFTInterviewWizardUtil.getWDJobApplication(wdrApplicationId);
			
		} else if (String.isEmpty(wdrApplicationId) == false) {
			IFB_SIFTRecruitProvider recruitProvider = new IFB_SIFTRecruitProvider(wdrApplicationId);
			wdApp = recruitProvider.wdApp;

			//Create a new 'SIFT Recruit' record instance (in memory) from the 'WD Job Application' record id.
			newRecruit = recruitProvider.generateNewRecruit();
			
			createdInterviewsForRecruit = new List<IFB_Interview__c>();
		
		} else {
			throw new AuraHandledException(System.Label.IFB_NewSIFTIntWiz_UnknownError);
		}
		List<IFB_SelectOption> interviewFormats = IFB_NewSIFTInterviewWizardUtil.getInterviewFormats();
		List<IFB_SelectOption> timeZones = IFB_NewSIFTInterviewWizardUtil.getTimeZones();
		List<IFB_SelectOption> interviewStartTimes = IFB_NewSIFTInterviewWizardUtil.getInterviewStartTimes();
		
		// Get the 'SIFT Interview' Record Types for appropriate group and postion
		if(wdApp != null) {
			interviewTypeOptions = IFB_NewSIFTInterviewWizardUtil.getIntrvwTypeForMatchingGroupAndPosition(wdApp.SIFT_Group_Lookup__r.Name);
			interview.Hiring_Manager__c = wdApp.Job__r.Hiring_Manager__c;
			interview.Recruiter__c = IFB_InterviewUtils.getRecruiterforInterview(wdApp.Internal_Candidate__c,wdApp.job__r.Internal_Recruiter_1__c,wdApp.job__r.Internal_Recruiter_2__c,wdApp.job__r.External_Recruiter_1__c,wdApp.job__r.External_Recruiter_2__c);
			interview.Application_Step__c = wdApp.Application_Step__c;
			interview.Candidate_Stage__c = wdApp.Candidate_Stage__c;			
		}																																								
		// return an instance of the 'initial resources' wrapper class
		return new IFB_NewSIFTInterviewWizardCtrlInitialResources(
			new List<sObject>(),
			newRecruit,
			interview,
			interviewTypeOptions,
			interviewFormats,
			timeZones,
			interviewStartTimes,
			createdInterviewsForRecruit
		);
	}

	/**
	* @description Method to created interviews for the incoming interviewers
	* @param wdrApplicationId Id of the related WD Job Application.
	* @param selectedExistingRecruit Id of the selected recruit which is already existing in TF
	* @param newRecruit Recruit object if a new recruit is being created
	* @param interview A shell of an IFB_Interview__c which is cloned to create interviews 
	* @param interviewers List of users whose interviews need to be created.
	* @return List of all the interviews that are created.
	**/
	@AuraEnabled
	public static List<IFB_Interview__c> createSIFTInterviews(String wdrApplicationId, String selectedExistingRecruit, IFB_Interview_Candidate__c newRecruit, IFB_Interview__c interview, List<User> interviewers) {
		List<IFB_Interview__c> interviewsWithFields = new List<IFB_Interview__c>();
		SavePoint savePointAtBeginning = Database.setSavePoint();
		Id defaultRecordTypeId = Schema.SObjectType.IFB_Interview__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
		interview.RecordTypeId = defaultRecordTypeId;
		WDR_Application__c  wdrApplication;
		if (String.isEmpty(selectedExistingRecruit) == false) {
			interview.Candidate__c = selectedExistingRecruit;
			// Linking an existing 'SIFT Recruit' with the 'WD Job Application' record
			wdrApplication = new WDR_Application__c(Id = wdrApplicationId);
			wdrApplication.SIFT_Recruit__c = selectedExistingRecruit;

		} else if (newRecruit != null) {
			try {
				insert newRecruit;
				interview.Candidate__c = newRecruit.Id;
			}
			catch(Exception e) {
				Database.rollBack(savePointAtBeginning);
				throw new AuraHandledException(System.Label.IFB_NewSIFTIntWiz_ErrorNewRecruitCreate + e.getMessage());
			}

			// Linking thew new 'SIFT Recruit' with the 'WD Job Application' record
			wdrApplication = new WDR_Application__c(Id = newRecruit.Job_Application_WDR__c);
			wdrApplication.SIFT_Recruit__c = newRecruit.Id;
			
		}

		// Linke the new Recruit OR the existing Recruit to the current 'WD Job Application record'	
		if (wdrApplication != null) {
			try {
				update wdrApplication;	
			}
			catch(Exception e) {
				Database.rollBack(savePointAtBeginning);
				throw new AuraHandledException(System.Label.IFB_NewSIFTIntWiz_ErrorJobAppUpdate + e.getMessage());
			}
		}
		List<IFB_Interview__c> interviews = new List<IFB_Interview__c>();
		for (User interviewer : interviewers) {
			IFB_Interview__c interviewerSpecificInterview = interview.clone(false, true, false, false);
			interviewerSpecificInterview.Interviewer__c = interviewer.Id;
			interviews.add(interviewerSpecificInterview);
		}

		try {
			insert interviews;
		}
		catch(Exception e) {
			Database.rollBack(savePointAtBeginning);
			throw new AuraHandledException(System.Label.IFB_NewSIFTIntWiz_ErrorNewInterviewCreate + e.getMessage());
		}
		Map<Id,IFB_Interview__c> interviewsMap = new Map<Id,IFB_Interview__c>();
		interviewsMap.putAll(interviews);
		interviewsWithFields = [SELECT Name,Interviewer__r.Name, Interviewer__r.Id, Interview_Format__c, Scheduled_Interview_Date_only__c, Candidate__c, 
								Status__c, RecordTypeName__c, Interview_Type__r.Name FROM IFB_Interview__c WHERE Id in :interviewsMap.keySet()];
		return interviewsWithFields;
	}

	/**
	* @description This method saves the existing TF SIFT recruit onto the incoming WD Job Application
	* @param wdrApplicationId Id of the related WD Job Application.
	* @param selectedExistingRecruit Id of the selected recruit which is already existing in TF
	**/
	@AuraEnabled
	public static void saveSIFTRecruitMapping(String wdrApplicationId, String selectedExistingRecruit) {
		
		WDR_Application__c  wdrApplication = new WDR_Application__c(Id = wdrApplicationId);
		wdrApplication.SIFT_Recruit__c = selectedExistingRecruit;
		try {
			update wdrApplication;
		}
		catch(Exception e) {
			throw new AuraHandledException(System.Label.IFB_NewSIFTIntWiz_ErrorJobAppUpdate + e.getMessage());
		}

	
	}

	/**
	* @description Method to query Users based on the the input searchTerm.
	* @param searchTerm String that needs to be queried for.
	* @return Returns a list of users whose name contains the searchTerm.
	**/
	@AuraEnabled
	public static List<User> searchInterviewer(String searchTerm) {
		searchTerm = '%' + searchTerm + '%';
		List<User> searchResults = [SELECT Id, Name, Email FROM User WHERE UserType = 'Standard' AND
									IsActive = true AND Name LIKE :searchTerm AND Is_Employee__c = true LIMIT 5];
		return searchResults;
	}

	/**
	* @description Returns the Interviews that are related to the incoming recruit.
	* @param selectedExistingRecruit Recruit Id whose interviews need to be returned.
	* @return List of interviews that are related to the incoming recruit.
	**/
	@AuraEnabled
	public static List<IFB_Interview__c> getExistingInterviewsForRecruit(String selectedExistingRecruit) {
		return IFB_NewSIFTInterviewWizardUtil.getInterviewsForRecruit((Id)selectedExistingRecruit);
	}
}