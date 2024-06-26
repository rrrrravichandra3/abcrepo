public without sharing class IFB_InterviewTriggerOpsWos {

	public void afterInsertInterviewSharing(List<IFB_Interview__c> newInterviews) {
 
		IFB_InterviewOpsWos opsWos =  new IFB_InterviewOpsWos();

		Set<IFB_Interview__share> interviewSharesToAdd = new Set<IFB_Interview__share>();
		Set<IFB_Interview_Candidate__share> recruitSharesToAdd  = new Set<IFB_Interview_Candidate__share>();
		Set<IFB_Interview_Question__share> questionSharesToAdd  = new Set<IFB_Interview_Question__share>();
		Set<IFB_Interview__share> interviewSharesToDelete = new Set<IFB_Interview__share>();
		Set<IFB_Interview_Candidate__share> recruitSharesToDelete = new Set<IFB_Interview_Candidate__share>();
		Set<IFB_Interview_Question__share> questionSharesToDelete = new Set<IFB_Interview_Question__share>();
		Set<Id> permissionSetAssignmentsInterviewer = new Set<Id>();
		Set<Id> permissionSetAssignmentsHiringOrganization = new Set<Id>();

		Map<Id, Set<Id>> questionsByInterview = new Map<Id, Set<Id>>();
		for (IFB_Interview_Evaluation__c evaluation : [ select Interview__c, Interview_Question__c 
														from IFB_Interview_Evaluation__c
														where Interview__c in :newInterviews]) {
			
			if (questionsByInterview.containsKey(evaluation.Interview__c) == false) {
				questionsByInterview.put(evaluation.Interview__c, new Set<Id>());
			}
			questionsByInterview.get(evaluation.Interview__c).add(evaluation.Interview_Question__c);
		}

		Set<Id> recruitsToRecalculatePanelInterviewerSharing = new Set<Id>();

		// We get the hiring organization: all the managers above the hiring managers. 
		Set<Id> hiringManagers = new Set<Id>();
		Map<Id, Set<Id>> hiringOrganizationByHiringManager = new Map<Id, Set<Id>>();
		for (IFB_Interview__c interview : newInterviews) {
			if (interview.Hiring_Manager__c != null) {
				hiringManagers.add(interview.Hiring_Manager__c);
			}
			
		}
		hiringOrganizationByHiringManager = IFB_UserHierarchy.getManagersIdsByUserId(hiringManagers);

		for (IFB_Interview__c interview : newInterviews) {

			Set<Id> interviewers = new set<Id>();
			if (interview.Interviewer__c != null) {
				interviewers.add(interview.Interviewer__c);
				permissionSetAssignmentsInterviewer.add(interview.Interviewer__c);
			}

			if (interview.Interviewer2__c != null) {
				interviewers.add(interview.Interviewer2__c);
				permissionSetAssignmentsInterviewer.add(interview.Interviewer2__c);
			}

			if (interview.Interviewer3__c != null) {
				interviewers.add(interview.Interviewer3__c);
				permissionSetAssignmentsInterviewer.add(interview.Interviewer3__c);
			}

			if (interview.Interviewer4__c != null) {
				interviewers.add(interview.Interviewer4__c);
				permissionSetAssignmentsInterviewer.add(interview.Interviewer4__c);
			}

			if (interview.Interviewer5__c != null) {
				interviewers.add(interview.Interviewer5__c);
				permissionSetAssignmentsInterviewer.add(interview.Interviewer5__c);
			}

			opsWos.addInterviewTreeShares(interview.Id,
									interview.Candidate__c, 
									questionsByInterview.get(interview.Id), 
									IFB_InterviewOpsWos.ApexSharingReason.INTERVIEWER, 
									interviewers, 
									interviewSharesToAdd ,
									recruitSharesToAdd , 
									questionSharesToAdd );

			
			if (interview.Hiring_Manager__c != null) {

				opsWos.addInterviewTreeShares(interview.Id,
									interview.Candidate__c, 
									questionsByInterview.get(interview.Id), 
									IFB_InterviewOpsWos.ApexSharingReason.HIRING_MANAGER, 
									new Set<Id>{interview.Hiring_Manager__c}, 
									interviewSharesToAdd ,
									recruitSharesToAdd , 
									questionSharesToAdd );

				permissionSetAssignmentsHiringOrganization.add(interview.Hiring_Manager__c);

				opsWos.addInterviewTreeShares(interview.Id,
									interview.Candidate__c, 
									questionsByInterview.get(interview.Id), 
									IFB_InterviewOpsWos.ApexSharingReason.HIRING_ORGANIZATION, 
									hiringOrganizationByHiringManager.get(interview.Hiring_Manager__c), 
									interviewSharesToAdd ,
									recruitSharesToAdd , 
									questionSharesToAdd );

				for (Id managerId : hiringOrganizationByHiringManager.get(interview.Hiring_Manager__c)) {
					permissionSetAssignmentsHiringOrganization.add(managerId);
				}
				
				
			}

			if (interview.Status__c == IFB_InterviewOpsWos.INTERVIEW_STATUS_FEEDBACK_SUBMITTED) {			
				if (interview.Candidate__c != null) {
					recruitsToRecalculatePanelInterviewerSharing.add(interview.Candidate__c);
				} else {
					throw new IFB_InterviewTreeSharingException('Can not recalculate Panel Interviewer Sharing if Recruit is empty' + ' ' +interview);
				}		
			}			
		}

		for (Id recruitId : recruitsToRecalculatePanelInterviewerSharing) {
			opsWos.recalculatePanelInterviewerShares(recruitId,
													opsWos.getInterviewsByRecruit(recruitsToRecalculatePanelInterviewerSharing, null, null).get(recruitId),
													opsWos.getInterviewQuestionsByRecruit(recruitsToRecalculatePanelInterviewerSharing, null, null).get(recruitId),
													opsWos.getSubmittedInterviewsByRecruit(recruitsToRecalculatePanelInterviewerSharing, null, null).get(recruitId),
													opsWos.getSubmittedInterviewQuestionsByRecruit(recruitsToRecalculatePanelInterviewerSharing, null, null).get(recruitId),
													opsWos.getSubmittedInterviewersByRecruit(recruitsToRecalculatePanelInterviewerSharing, null, null).get(recruitId),
													interviewSharesToAdd,
													recruitSharesToAdd, 
													questionSharesToAdd,
													interviewSharesToDelete,
													recruitSharesToDelete, 
													questionSharesToDelete);
		}
		

		List<IFB_Interview__share> interviewSharesToAddList = new List<IFB_Interview__share>(interviewSharesToAdd);
		List<IFB_Interview_Candidate__share> recruitSharesToAddList = new List<IFB_Interview_Candidate__share>(recruitSharesToAdd);
		List<IFB_Interview_Question__share> questionSharesToAddList = new List<IFB_Interview_Question__share>(questionSharesToAdd);
		List<IFB_Interview__share> interviewSharesToDeleteList = new List<IFB_Interview__share>(interviewSharesToDelete);
		List<IFB_Interview_Candidate__share> recruitSharesToDeleteList = new List<IFB_Interview_Candidate__share>(recruitSharesToDelete);
		List<IFB_Interview_Question__share> questionSharesToDeleteList = new List<IFB_Interview_Question__share>(questionSharesToDelete);
		

		delete interviewSharesToDeleteList;
		delete recruitSharesToDeleteList;
		delete questionSharesToDeleteList;

		// For all the users referenced in the sharing records to be inserted we get the information if they are active or not.
		Set<Id> sharingUsersScope;
		sharingUsersScope = opsWos.getSharingUsersScope(interviewSharesToAddList, recruitSharesToAddList, questionSharesToAddList);
		IFB_UserOpsWos.getUser(sharingUsersScope);

		// We only try to insert sharing records that do not involve inactive users. 
		// As a platform constraint, you can not share a record to an inactive user.
		insert opsWos.removeInactiveUsersInterviewShares(interviewSharesToAddList);
		insert opsWos.removeInactiveUsersRecruitShares(recruitSharesToAddList);
		insert opsWos.removeInactiveUsersQuestionShares(questionSharesToAddList);

		IFB_InterviewOpsWos.insertPermissionSetAssignmentsInFuture(IFB_Metadata_PermissionSet.getPermissionSet(IFB_Metadata_PermissionSet.Option.SIFT_INTERVIEWER).Id, permissionSetAssignmentsInterviewer);
		IFB_InterviewOpsWos.insertPermissionSetAssignmentsInFuture(IFB_Metadata_PermissionSet.getPermissionSet(IFB_Metadata_PermissionSet.Option.SIFT_HIRING_ORGANIZATION).Id, permissionSetAssignmentsHiringOrganization);
		
	}

	public void afterUpdateInterviewSharing(List<IFB_Interview__c> newInterviews, Map<Id, IFB_Interview__c> oldInterviewsMap) {

		IFB_InterviewOpsWos opsWos =  new IFB_InterviewOpsWos();

		Set<IFB_Interview__share> interviewSharesToAdd = new Set<IFB_Interview__share>();
		Set<IFB_Interview_Candidate__share> recruitSharesToAdd  = new Set<IFB_Interview_Candidate__share>();
		Set<IFB_Interview_Question__share> questionSharesToAdd = new Set<IFB_Interview_Question__share>();
		Set<IFB_Interview__share> interviewSharesToDelete = new Set<IFB_Interview__share>();
		Set<IFB_Interview_Candidate__share> recruitSharesToDelete = new Set<IFB_Interview_Candidate__share>();
		Set<IFB_Interview_Question__share> questionSharesToDelete = new Set<IFB_Interview_Question__share>();
		Set<Id> permissionSetAssignmentsInterviewer = new Set<Id>();
		Set<Id> permissionSetAssignmentsHiringOrganization = new Set<Id>();

		Map<Id, Set<Id>> questionsByInterview = new Map<Id, Set<Id>>();
		for (IFB_Interview_Evaluation__c evaluation : [ select Interview__c, Interview_Question__c 
														from IFB_Interview_Evaluation__c
														where Interview__c in :newInterviews]) {
			
			if (questionsByInterview.containsKey(evaluation.Interview__c) == false) {
				questionsByInterview.put(evaluation.Interview__c, new Set<Id>());
			}
			questionsByInterview.get(evaluation.Interview__c).add(evaluation.Interview_Question__c);
		}

		Set<Id> recruitsToRecalculatePanelInterviewerSharing = new Set<Id>();

		// We get the hiring organization: all the managers above the hiring managers. 
		Set<Id> hiringManagers = new Set<Id>();
		Map<Id, Set<Id>> hiringOrganizationByHiringManager = new Map<Id, Set<Id>>();
		for (IFB_Interview__c interview : newInterviews) {
			if (interview.Hiring_Manager__c != null) {
				hiringManagers.add(interview.Hiring_Manager__c);	
			}
			if (oldInterviewsMap.get(interview.Id).Hiring_Manager__c != null) {
				hiringManagers.add(oldInterviewsMap.get(interview.Id).Hiring_Manager__c);	
			}
		}
		hiringOrganizationByHiringManager = IFB_UserHierarchy.getManagersIdsByUserId(hiringManagers);

		for (IFB_Interview__c newInterview : newInterviews) {
			IFB_Interview__c oldInterview= oldInterviewsMap.get(newInterview.Id);

			// -- INTERVIEWER
			// If the Interviewers of this Interview changed, remove old Interviewer's access and add new Interviewer's access
			Set<Id> newInterviewers = new Set<Id>();
			Set<Id> oldInterviewers = new Set<Id>();
			opsWos.getNewAnOldInterviewers(newInterview, oldInterview, newInterviewers, oldInterviewers);

			if ((newInterviewers.size() > 0) || (newInterview.Candidate__c != oldInterview.Candidate__c)) {
				opsWos.addInterviewTreeShares(newInterview.Id,
									newInterview.Candidate__c, 
									questionsByInterview.get(newInterview.Id), 
									IFB_InterviewOpsWos.ApexSharingReason.INTERVIEWER, 
									newInterviewers, 
									interviewSharesToAdd,
									recruitSharesToAdd, 
									questionSharesToAdd);

				permissionSetAssignmentsInterviewer.addAll(newInterviewers);
			}
			
			if ((oldInterviewers.size() > 0) || (newInterview.Candidate__c != oldInterview.Candidate__c)) {
				
				IFB_InterviewTreeToDelete.addInterviewTree(oldInterview.Id,
														   oldInterview.Candidate__c,
														   questionsByInterview.get(oldInterview.Id),
														   IFB_InterviewOpsWos.ApexSharingReason.INTERVIEWER,
														   oldInterviewers);
			}

			// -- HIRING MANAGER
			// If the Hiring Manager changed, then remove old Hiring Manager's access and add new Hiring Manager's access
			if ((newInterview.Hiring_Manager__c != oldInterview.Hiring_Manager__c) || (newInterview.Candidate__c != oldInterview.Candidate__c)) {
				if (newInterview.Hiring_Manager__c != null) {
					opsWos.addInterviewTreeShares(newInterview.Id,
									newInterview.Candidate__c, 
									questionsByInterview.get(newInterview.Id), 
									IFB_InterviewOpsWos.ApexSharingReason.HIRING_MANAGER, 
									new Set<Id>{newInterview.Hiring_Manager__c}, 
									interviewSharesToAdd,
									recruitSharesToAdd, 
									questionSharesToAdd);

					permissionSetAssignmentsHiringOrganization.add(newInterview.Hiring_Manager__c);

					opsWos.addInterviewTreeShares(newInterview.Id,
									newInterview.Candidate__c, 
									questionsByInterview.get(newInterview.Id), 
									IFB_InterviewOpsWos.ApexSharingReason.HIRING_ORGANIZATION, 
									hiringOrganizationByHiringManager.get(newInterview.Hiring_Manager__c), 
									interviewSharesToAdd ,
									recruitSharesToAdd , 
									questionSharesToAdd );

					for (Id managerId : hiringOrganizationByHiringManager.get(newInterview.Hiring_Manager__c)) {
						permissionSetAssignmentsHiringOrganization.add(managerId);
					}

				}

				if (oldInterview.Hiring_Manager__c != null) {
					
					IFB_InterviewTreeToDelete.addInterviewTree(oldInterview.Id,
														   oldInterview.Candidate__c,
														   questionsByInterview.get(oldInterview.Id),
														   IFB_InterviewOpsWos.ApexSharingReason.HIRING_MANAGER,
														   new Set<Id>{oldInterview.Hiring_Manager__c});

					IFB_InterviewTreeToDelete.addInterviewTree(oldInterview.Id,
														   oldInterview.Candidate__c,
														   questionsByInterview.get(oldInterview.Id),
														   IFB_InterviewOpsWos.ApexSharingReason.HIRING_ORGANIZATION,
														   hiringOrganizationByHiringManager.get(oldInterview.Hiring_Manager__c));
				}
			}

			// -- PANEL INTERVIEW
			// -- If there is change on the Interview Status that involves the 'Feedback Sumitted' status we need to recalculate the 'Panel Interview' sharing
			if ((newInterview.Status__c != oldInterview.Status__c) || (newInterview.Candidate__c != oldInterview.Candidate__c)) {
				if (newInterview.Status__c == IFB_InterviewOpsWos.INTERVIEW_STATUS_FEEDBACK_SUBMITTED
					|| oldInterview.Status__c == IFB_InterviewOpsWos.INTERVIEW_STATUS_FEEDBACK_SUBMITTED) {
					
					recruitsToRecalculatePanelInterviewerSharing.add(newInterview.Candidate__c);

					if (newInterview.Candidate__c != oldInterview.Candidate__c) {
						recruitsToRecalculatePanelInterviewerSharing.add(oldInterview.Candidate__c);
					}					
				}
			}
			 
		}

		for (IFB_InterviewTreeToDelete treeToDelete : IFB_InterviewTreeToDelete.listOfTrees) {
			opsWos.removeInterviewTreeShares(treeToDelete.interview,
									treeToDelete.recruit, 
									treeToDelete.questions, 
									treeToDelete.sharingReason, 
									treeToDelete.usersOrGroup, 
									interviewSharesToDelete,
									recruitSharesToDelete, 
									questionSharesToDelete,
									IFB_InterviewTreeToDelete.interviewScope,
									IFB_InterviewTreeToDelete.recruitScope,
									IFB_InterviewTreeToDelete.questionsScope,
									IFB_InterviewTreeToDelete.sharingReasonStringsScope,
									IFB_InterviewTreeToDelete.userOrGroupIdsScope,
									IFB_InterviewTreeToDelete.interviewersScope,
									IFB_InterviewTreeToDelete.hiringManagerScope);
		}


		for (Id recruitId : recruitsToRecalculatePanelInterviewerSharing) {
			opsWos.recalculatePanelInterviewerShares(recruitId,
													opsWos.getInterviewsByRecruit(recruitsToRecalculatePanelInterviewerSharing, null, null).get(recruitId),
													opsWos.getInterviewQuestionsByRecruit(recruitsToRecalculatePanelInterviewerSharing, null, null).get(recruitId),
													opsWos.getSubmittedInterviewsByRecruit(recruitsToRecalculatePanelInterviewerSharing, null, null).get(recruitId),
													opsWos.getSubmittedInterviewQuestionsByRecruit(recruitsToRecalculatePanelInterviewerSharing, null, null).get(recruitId),
													opsWos.getSubmittedInterviewersByRecruit(recruitsToRecalculatePanelInterviewerSharing, null, null).get(recruitId),
													interviewSharesToAdd,
													recruitSharesToAdd, 
													questionSharesToAdd,
													interviewSharesToDelete,
													recruitSharesToDelete, 
													questionSharesToDelete);
		}

		List<IFB_Interview__share> interviewSharesToAddList = new List<IFB_Interview__share>(interviewSharesToAdd);
		List<IFB_Interview_Candidate__share> recruitSharesToAddList = new List<IFB_Interview_Candidate__share>(recruitSharesToAdd);
		List<IFB_Interview_Question__share> questionSharesToAddList = new List<IFB_Interview_Question__share>(questionSharesToAdd);
		List<IFB_Interview__share> interviewSharesToDeleteList = new List<IFB_Interview__share>(interviewSharesToDelete);
		List<IFB_Interview_Candidate__share> recruitSharesToDeleteList = new List<IFB_Interview_Candidate__share>(recruitSharesToDelete);
		List<IFB_Interview_Question__share> questionSharesToDeleteList = new List<IFB_Interview_Question__share>(questionSharesToDelete);

		delete interviewSharesToDeleteList;
		delete recruitSharesToDeleteList;

		// For all the users referenced in the sharing records to be inserted we get the information if they are active or not.
		Set<Id> sharingUsersScope;
		sharingUsersScope = opsWos.getSharingUsersScope(interviewSharesToAddList, recruitSharesToAddList, questionSharesToAddList);
		IFB_UserOpsWos.getUser(sharingUsersScope);

		// We only try to insert sharing records that do not involve inactive users. 
		// As a platform constraint, you can not share a record to an inactive user.
		insert opsWos.removeInactiveUsersInterviewShares(interviewSharesToAddList);
		insert opsWos.removeInactiveUsersRecruitShares(recruitSharesToAddList);
		insert opsWos.removeInactiveUsersQuestionShares(questionSharesToAddList);

		IFB_InterviewOpsWos.insertPermissionSetAssignmentsInFuture(IFB_Metadata_PermissionSet.getPermissionSet(IFB_Metadata_PermissionSet.Option.SIFT_INTERVIEWER).Id, permissionSetAssignmentsInterviewer);
		IFB_InterviewOpsWos.insertPermissionSetAssignmentsInFuture(IFB_Metadata_PermissionSet.getPermissionSet(IFB_Metadata_PermissionSet.Option.SIFT_HIRING_ORGANIZATION).Id, permissionSetAssignmentsHiringOrganization);


	}
}