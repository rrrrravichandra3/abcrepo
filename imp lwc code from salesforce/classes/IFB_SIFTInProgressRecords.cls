/* 
 * Note about NOT using the 'with sharing' keyworkd:
 * Users don't have access to delete "SIFT Interview" records, but we want to be
 * able to delete records in this class.
 *
 * When users create "SIFT Interviews" from Talenforce the system creates the record 
 * in the backend, and display the "Edit" page to the user. If user clicks on "Cancel"
 * we use th TF_SIFTInterviewCancel page in cancelURL query string paramenter, so
 * this code is executed and the record gets deleted. "Recruit" record is also deleted
 * if it was created as part of the process.
 *
 */ 
public class IFB_SIFTInProgressRecords {
	
	/* 
	 * Deletes the in progress "SIFT Interview" record. Confirms that it is an "in progress" record.
	 */
	public void deleteInProgressSIFTInterview(Id siftInterviewId, Boolean deleteInProgressRecruit){

		// Only the creator and owner of the record can delete the "SIFT Interview"
		List<IFB_Interview__c> siftInterviews = [select Id, CreatedDate, LastModifiedDate, 
													 Candidate__c,
													 Candidate__r.CreatedDate,
													 Candidate__r.LastModifiedDate,
													 Candidate__r.Create_in_progress__c,
													 Create_in_progress__c
													 from IFB_Interview__c
													 where Id = :siftInterviewId
													 and CreatedById = :UserInfo.getUserId()
													 and OwnerId = :UserInfo.getUserId()
													 and Create_in_progress__c = true
													 limit 1];
		if (siftInterviews.size() > 0) {
			Long editTimeDifference; 
			Boolean recordHasNotBeenEdited;
			Long minutesSinceRecordCreation;
			Boolean recordWasRecentlyCreated;

			// As a security measure, apart from the "Create in progress" flag, we also check that the "SIFT Interview":
			// 1) Has not been modified since its creation
			// 2) It's been created recently 
			IFB_Interview__c interview = siftInterviews[0];
			editTimeDifference = (interview.LastModifiedDate.getTime() - interview.CreatedDate.getTime());
			recordHasNotBeenEdited = (editTimeDifference == 0);
			minutesSinceRecordCreation = (((DateTime.now().getTime() - interview.CreatedDate.getTime())/1000)/60);
			recordWasRecentlyCreated = (minutesSinceRecordCreation <= 1440);

			if (recordHasNotBeenEdited && recordWasRecentlyCreated) {
				delete interview;

				if (deleteInProgressRecruit == true) {
					//Now, we see if we need to delete the "Recruit" record.
					IFB_Interview_Candidate__c recruit = siftInterviews[0].Candidate__r;

					// Only if the "Recruit" has been marked as to in progress.
					if (recruit.Create_in_progress__c) {
						// As a security measure, apart from the "Create in progress" flag, we also check that the "SIFT Recruit"
						// Has been created recently 
						
						minutesSinceRecordCreation = (((DateTime.now().getTime() - recruit.CreatedDate.getTime())/1000)/60);
						recordWasRecentlyCreated = (minutesSinceRecordCreation <= 1440);

						if (recordWasRecentlyCreated) {
							List<IFB_Interview__c> recruitInterviews = [select Id from IFB_Interview__c 
																		where Candidate__c = : recruit.Id];

							// We confirm that the recruit doesn't have any interviews, before deleting.
							if (recruitInterviews.size() == 0) {
								delete recruit;
							}
						}
					}
				}		
			}
		}
	}

	/* 
	 * Deletes the in progress "SIFT Recruit" record. Confirms that it is an "in progress" record.
	 */
	public void deleteInProgressSIFTRecruit(Id siftRecruitId) {

		// Only yhe creator and owner of the record can delete the "SIFT Interview"
		List<IFB_Interview_Candidate__c> siftRecruits = [select Id, CreatedDate, LastModifiedDate, 
											Create_in_progress__c
											from IFB_Interview_Candidate__c
											where Id = :siftRecruitId
											and CreatedById = :UserInfo.getUserId()
											and OwnerId = :UserInfo.getUserId()
											and Create_in_progress__c = true
											limit 1];
		if (siftRecruits.size() > 0) {
			IFB_Interview_Candidate__c recruit = siftRecruits[0];

			// As a security measure, apart from the "Create in progress" flag, we also check that the "SIFT Recruit":
			// 1) Has not been modified since its creation
			// 2) It's been created recently 
			Long editTimeDifference = (recruit.LastModifiedDate.getTime() - recruit.CreatedDate.getTime());
			Boolean recordHasNotBeenEdited = (editTimeDifference == 0);
			Long minutesSinceRecordCreation = (((DateTime.now().getTime() - recruit.CreatedDate.getTime())/1000)/60);
			Boolean recordWasRecentlyCreated = (minutesSinceRecordCreation <= 1440);

			if (recordHasNotBeenEdited && recordWasRecentlyCreated) {
				List<IFB_Interview__c> recruitInterviews = [select Id from IFB_Interview__c 
															where Candidate__c = : recruit.Id];

				// We confirm that the recruit doesn't have any interviews, before deleting.
				if (recruitInterviews.size() == 0) {
					delete recruit;
				}
			}		
		}
	}
}