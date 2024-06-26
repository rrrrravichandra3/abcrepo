public class IFB_SIFTInterviewPostFeedbackNotifCtrlr {

	
	

	/*
		1.WD Job Application determines whether notifications should be send to internal or external recruiters.
		2.It is determined from interview as follows.
			i.Get Candidate Ids from incoming Interviews.
			ii.Build Candidate to Interview map.
			iii.Grab Job Apps of Candidates and build JobAppToCandidate map.
			iv.use ii and iii to get interview for given job app.
		3.If the candidate is internal and at least one internal recruiter exists on WD Job App, send email & chatter
		  notifications to internal recruiter(s).
		4.If the candidate is internal and no internal recruiter exists on WD Job App, send email & chatter
		  notifications to external recruiter(s).
		5.If the candidate is not internal and at least one external recruiter exists on WD Job App, send email & chatter
		  notifications to external recruiter(s).
	*/

	@InvocableMethod
	public static void sendNotifications(List<IFB_Interview__c> siftInterviews){
		if(siftInterviews != null){
			List<Id> siftIntwIds = new List<Id>();
			Set<Id> candidateIds = new Set<Id>();
			List<Id> jobAppIds = new List<Id>();
			Map<Id, List<IFB_Interview__c>> candToIntwMap = new Map<Id, List<IFB_Interview__c>>();
			Map<Id, IFB_Interview_Candidate__c> jobApptoCandidateMap = new Map<Id, IFB_Interview_Candidate__c>();
			Map<Id, WDR_Application__c> jobAppMap = new Map<Id, WDR_Application__c>();

			/* Iterate over all sift interviews & retrieve candidate ids */
			for(IFB_Interview__c siftIntw : siftInterviews){
				siftIntwIds.add(siftIntw.Id);
				candidateIds.add(siftIntw.Candidate__c);
			}

			/* Retrieve all wd job application ids & build candToIntwMap, jobApptoCandidateMap */
			for(IFB_Interview_Candidate__c candidate : [Select Id, Job_Application_WDR__c, (select Id, Name, Candidate__c, Candidate__r.Name, Interviewer__r.Name from Interview_Assessments__r where Id in : siftIntwIds) from IFB_Interview_Candidate__c where Id in : candidateIds]){
				List<IFB_Interview__c> siftInterviewsOfCandidate = candidate.Interview_Assessments__r;
				candToIntwMap.put(candidate.Id, siftInterviewsOfCandidate);
				jobAppIds.add(candidate.Job_Application_WDR__c);
				jobApptoCandidateMap.put(candidate.Job_Application_WDR__c, candidate);
			}
			
			/* Retrieve all wd job applications */
			for(WDR_Application__c jobApp : [Select Id, Internal_Candidate__c, Job__r.Internal_Recruiter_1__c, Job__r.Internal_Recruiter_2__c, Job__r.External_Recruiter_1__c, Job__r.External_Recruiter_2__c from WDR_Application__c where Id in : jobAppIds]){
				jobAppMap.put(jobApp.Id, jobApp);
			}
			
			for(Id jobAppId : jobAppMap.keySet()){
				List<Id> toUserIds = new List<Id>();
				List<IFB_Interview__c> siftInterviewsOfCandidate = candToIntwMap.get(jobApptoCandidateMap.get(jobAppId).Id);
				
				for(IFB_Interview__c siftInterview : siftInterviewsOfCandidate){
					/* If the candidate is internal for job application */
					if(jobAppMap.get(jobAppId).Internal_Candidate__c == true){
						Id intRectr1UserId = jobAppMap.get(jobAppId).Job__r.Internal_Recruiter_1__c;
						Id intRectr2UserId = jobAppMap.get(jobAppId).Job__r.Internal_Recruiter_2__c;

						if(intRectr1UserId != null){ toUserIds.add(intRectr1UserId); }
						if(intRectr2UserId != null){ toUserIds.add(intRectr2UserId); }

						if(toUserIds.size() > 0){
							sendEmail(toUserIds, siftInterview); //Send email to recruiters
							//createChatterPosts(toUserIds, siftInterview); //Create chatter posts for recruiters
						}
						else{
							Id extRectr1UserId = jobAppMap.get(jobAppId).Job__r.External_Recruiter_1__c;
							Id extRectr2UserId = jobAppMap.get(jobAppId).Job__r.External_Recruiter_2__c;

							if(extRectr1UserId != null){ toUserIds.add(extRectr1UserId); }
							if(extRectr2UserId != null){ toUserIds.add(extRectr2UserId); }

							if(toUserIds.size() > 0){
								sendEmail(toUserIds, siftInterview); //Send email to recruiters
								//createChatterPosts(toUserIds, siftInterview); //Create chatter posts for recruiters
							}
						}
					}
					else {
						Id extRectr1UserId = jobAppMap.get(jobAppId).Job__r.External_Recruiter_1__c;
						Id extRectr2UserId = jobAppMap.get(jobAppId).Job__r.External_Recruiter_2__c;

						if(extRectr1UserId != null){ toUserIds.add(extRectr1UserId); }
						if(extRectr2UserId != null){ toUserIds.add(extRectr2UserId); }

						if(toUserIds.size() > 0){
							sendEmail(toUserIds, siftInterview); //Send email to recruiters
							//createChatterPosts(toUserIds, siftInterview); //Create chatter posts for recruiters
						}
					}
				}
			}
		}
	}

	private static void sendEmail(List<Id> toUserIds, IFB_Interview__c siftIntw){
		for(Id userId : toUserIds){
			/* Create a SingleEmailMessage object to send email to recruiter */
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setTargetObjectId(userId);
			mail.setSubject('Feedback has been submitted');
			String body = 'Hello,\nInterview Feedback for '+siftIntw.Candidate__r.Name+' has been submitted. Please click the link below to review the feedback: \n'+System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + siftIntw.Id+'\n\nThank You!';
			mail.setPlainTextBody(body);
			mail.setSaveAsActivity(false);
			Messaging.sendEmail(new Messaging.Email[] { mail } );
		}
	}

	/* Commenting this part as Recruiter no long need chatter posts per W-7867862- Turn off automated chatter messages for SIFT
	    private static void createChatterPosts(List<Id> toUserIds, IFB_Interview__c siftIntw){
		for(Id userId : toUserIds){
			/* Create a FeedItemInput object for chatter post with @mention
			ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
			ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
			ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
			ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();

			messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
			textSegmentInput.text = 'Interview submitted\n';
			messageBodyInput.messageSegments.add(textSegmentInput);
			mentionSegmentInput.id = userId;
			messageBodyInput.messageSegments.add(mentionSegmentInput);
			feedItemInput.subjectId = siftIntw.Candidate__c;
			feedItemInput.body = messageBodyInput;

			ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, feedItemInput);
		}
	}
*/
}