public with sharing class IFB_SIFTRecruitProvider {
	public WDR_Application__c wdApp {get; set;}

	public IFB_SIFTRecruitProvider(Id wdrApplicationId) {
	
		List<WDR_Application__c> applications = [ SELECT Id, 
													Candidate__r.First_Name__c, 
													Candidate__r.Last_Name__c, 
													Candidate__r.Mailing_City__c, 
                                        			Candidate__r.Mailing_State__c,
                                        			Candidate__r.Email__c, 
                                        			Candidate__r.Phone__c, 
                                        			SIFT_Recruiter_Intro__c, 
                                        			SIFT_Group__c,
                                                    SIFT_Group_Lookup__c,
                                                    SIFT_Group_Lookup__r.Name,
                                        			SIFT_Position__c,
                                                    SIFT_Position_Lookup__c,
                                                    SIFT_Position_Lookup__r.Name, 
                                        			SIFT_Years_of_Experience__c, 
                                        			Candidate_Stage__c, 
                                                    Application_Step__c,
                                        			Start_Date__c, 
                                        			Job__r.Region__c,
                                        			Job__r.Target_Hire_Date__c,
                                        			Job__r.Hiring_Manager__c,
                                                    Internal_Candidate__c,
                                        			Job__r.External_Recruiter_1__c,
                                                    Job__r.External_Recruiter_2__c,
                                                    Job__r.Internal_Recruiter_1__c,
                                                    Job__r.Internal_Recruiter_2__c,
                                        			Is_this_a_SIFT_Interview__c 
                                        			FROM WDR_Application__c 
                                        			WHERE Id = :wdrApplicationId];
        
        if (applications.size() > 0) {
        	this.wdApp = applications[0];
        } 
	}


	// Taking as an input the id of the "WD Job Application" record,
	// generate a new "SIFT Recruit" record.
	public IFB_Interview_Candidate__c generateNewRecruit() {
		IFB_Interview_Candidate__c recruit = new IFB_Interview_Candidate__c();
		
		if (this.wdApp == null) return recruit;

        recruit.Job_Application_WDR__c = wdApp.Id;
        recruit.Last_WDR_Sync__c = DateTime.now();

        //Information coming from the related 'WD Candidate' record.
        recruit.First_Name__c = this.wdApp.Candidate__r.First_Name__c;
        recruit.Last_Name__c = this.wdApp.Candidate__r.Last_Name__c;
        recruit.City__c = this.wdApp.Candidate__r.Mailing_City__c;
        recruit.State__c = this.wdApp.Candidate__r.Mailing_State__c;
        recruit.Email__c = this.wdApp.Candidate__r.Email__c;
        recruit.Phone__c = this.wdApp.Candidate__r.Phone__c;
             
        //Information coming from the related 'WD Job Application' record.
        recruit.Recruiter_Intro__c = this.wdApp.SIFT_Recruiter_Intro__c;
        recruit.SIFT_Group__c = this.wdApp.SIFT_Group_Lookup__c;
        recruit.SIFT_Position__c = this.wdApp.SIFT_Position_Lookup__c;
        recruit.Years_of_Experience__c = this.wdApp.SIFT_Years_of_Experience__c;
     
        recruit.Rejected__c = (IFB_WDUtils.getValuesForCustomSetting('WDR_Rejected_Candidate_Stages__c')
                                                    .contains(wdApp.Candidate_Stage__c) ? true : false);                           
        recruit.Accepted_Offer__c = (IFB_WDUtils.getValuesForCustomSetting('WDR_Accepted_Offer_Status__c')
                                                    .contains(wdApp.Candidate_Stage__c) ? true : false); 
        recruit.Rejected_Offer__c = (IFB_WDUtils.getValuesForCustomSetting('WDR_Rejected_Offer_Status__c')
                                                    .contains(wdApp.Candidate_Stage__c) ? true : false);         
        
        if (IFB_WDUtils.getValuesForCustomSetting('Post_Placement_Candidate_Stages__c').contains(wdApp.Candidate_Stage__c) == true) {
            recruit.Hire_Date__c = this.wdApp.Start_Date__c; 
        }

        //Information coming from the related 'WD Job Requisition' record.
        recruit.Region__c = this.wdApp.Job__r.Region__c;
        recruit.Projected_Start_Date__c = this.wdApp.Job__r.Target_Hire_Date__c;

		return recruit;
	}
}