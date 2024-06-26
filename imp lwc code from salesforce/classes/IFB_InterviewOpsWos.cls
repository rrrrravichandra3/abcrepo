public without sharing class IFB_InterviewOpsWos {
	
	public static final String GROUP_DEVELOPER_NAME_CSG_API = 'CSG_API';
	public static final String INTERVIEW_STATUS_FEEDBACK_SUBMITTED = 'Feedback Submitted';
	public enum ApexSharingReason { INTERVIEWER, HIRING_MANAGER, HIRING_ORGANIZATION, PANEL_INTERVIEWER, CSG_API }
	
	public static Id CSGGroupId;
	public static Map<Id, Set<Id>> interviewsByRecruit;
	public static Map<Id, Map<Id, Set<Id>>> interviewsByUserOrGroupIdByRecruit;
	public static Map<Id, Set<Id>> interviewQuestionsByRecruit;
	public static Map<Id, Set<Id>> submittedInterviewsByRecruit;
	public static Map<Id, Set<Id>> submittedInterviewQuestionsByRecruit;
	public static Map<Id, Set<Id>> submittedInterviewersByRecruit;
	public static Map<Id, Map<Id, Map<String,List<IFB_Interview__share>>>> interviewSharesByRowCauseByByUserOrGroupIdByInterview;
	public static Map<Id, Map<Id, Map<String,List<IFB_Interview_Candidate__share>>>> recruitSharesByRowCauseByByUserOrGroupIdByRecruit;
	public static Map<Id, Map<Id, Map<String,List<IFB_Interview_Question__share>>>> questionSharesByRowCauseByByUserOrGroupIdByRecruit;
	public static Map<Id, Map<Id, Set<Id>>> questionsByInterviewByInterviewer;
	public static Map<Id, Map<Id, Set<Id>>> questionsByInterviewByHiringManager;

	// Removes from the collection all the sharing records that reference inactive users.
	public List<IFB_Interview__share> removeInactiveUsersInterviewShares(List<IFB_Interview__share> interviewShares) {
		List<IFB_Interview__share> sharesActiveUsersOnly = new List<IFB_Interview__share>();
		for (IFB_Interview__share share : interviewShares) {
			// If 'CSG API' public group, we include it
			if (share.UserOrGroupId == this.getCSGGroupId()) {
				sharesActiveUsersOnly.add(share);
			}

			// If not 'CSG API' public group share, we only add the share if we found a User record and the user is Active
			else if (IFB_UserOpsWos.getUser(new Set<Id> {share.UserOrGroupId}).containsKey(share.UserOrGroupId) == true) {
				if(IFB_UserOpsWos.getUser(new Set<Id> {share.UserOrGroupId}).get(share.UserOrGroupId).isActive == true) {
					sharesActiveUsersOnly.add(share);
				}
			}
		}
		return sharesActiveUsersOnly;
	}

	// Removes from the collection all the sharing records that reference inactive users.
	public List<IFB_Interview_Candidate__share> removeInactiveUsersRecruitShares(List<IFB_Interview_Candidate__share> recruitShares) {
		List<IFB_Interview_Candidate__share> sharesActiveUsersOnly = new List<IFB_Interview_Candidate__share>();
		for (IFB_Interview_Candidate__share share : recruitShares) {
			// If 'CSG API' public group, we include it
			if (share.UserOrGroupId == this.getCSGGroupId()) {
				sharesActiveUsersOnly.add(share);
			}

			// If not 'CSG API' public group share, we only add the share if we found a User record and the user is Active
			else if (IFB_UserOpsWos.getUser(new Set<Id> {share.UserOrGroupId}).containsKey(share.UserOrGroupId) == true) {
				if(IFB_UserOpsWos.getUser(new Set<Id> {share.UserOrGroupId}).get(share.UserOrGroupId).isActive == true) {
					sharesActiveUsersOnly.add(share);
				}
			}
		}
		return sharesActiveUsersOnly;
	}

	// Removes from the collection all the sharing records that reference inactive users.
	public List<IFB_Interview_Question__share> removeInactiveUsersQuestionShares(List<IFB_Interview_Question__share> questionShares) {
		List<IFB_Interview_Question__share> sharesActiveUsersOnly = new List<IFB_Interview_Question__share>();
		for (IFB_Interview_Question__share share : questionShares) {
			// If 'CSG API' public group, we include it
			if (share.UserOrGroupId == this.getCSGGroupId()) {
				sharesActiveUsersOnly.add(share);
			}

			// If not 'CSG API' public group share, we only add the share if we found a User record and the user is Active
			else if (IFB_UserOpsWos.getUser(new Set<Id> {share.UserOrGroupId}).containsKey(share.UserOrGroupId) == true) {
				if(IFB_UserOpsWos.getUser(new Set<Id> {share.UserOrGroupId}).get(share.UserOrGroupId).isActive == true) {
					sharesActiveUsersOnly.add(share);
				}
			}
		}
		return sharesActiveUsersOnly;
	}

	public Set<Id> getSharingUsersScope(List<IFB_Interview__share> interviewShares,
										List<IFB_Interview_Candidate__share> recruitShares,
										List<IFB_Interview_Question__share> questionShares) {

		Set<Id> sharingUsersScope = new Set<Id>();

		// We need to query if the Users that we are referencing in the sharing records
		// are active or not. To avoid multiple queries to the User object we define an
		// scope to query.
		for (IFB_Interview__share share : interviewShares) {
			sharingUsersScope.add(share.UserOrGroupId);
		}
		for (IFB_Interview_Candidate__share share : recruitShares) {
			sharingUsersScope.add(share.UserOrGroupId);
		}
		for (IFB_Interview_Question__share share : questionShares) {
			sharingUsersScope.add(share.UserOrGroupId);
		}

		// If the 'CSG API' public group is there, we remove it. We are only concerned
		// about record sharing to User records, no public groups.
		sharingUsersScope.remove(this.getCSGGroupId());

		return sharingUsersScope;
	}

	public Id getCSGGroupId() {
		if (CSGGroupId == null) {
			List<Group> CSGGroup = [select Id from Group
									where DeveloperName = :GROUP_DEVELOPER_NAME_CSG_API
									limit 1];
			if (CSGGroup.size() > 0) {
				CSGGroupId = CSGGroup[0].Id;
			} else {
				throw new IFB_InterviewTreeSharingException('Could not find the CSG API public group to share the record. ' + ' ' + GROUP_DEVELOPER_NAME_CSG_API);
			}
		}
		return CSGGroupId;
	}

	// Insert permission set assignments (in the future)
	// Only inserts the PermissionSetAssigments that are needed
	public static void insertPermissionSetAssignmentsInFuture(Id permissionSetId, Set<Id> assignees) {
		Set<Id> assigneesThatDoNoHaveItYet = new Set<Id>();

		Map<Id, IFB_UserOpsWos.IFB_UserInfo> mapUserInfo = IFB_UserOpsWos.getUserInfo(assignees);
		for(Id userId : assignees) {

			if (permissionSetId == IFB_Metadata_PermissionSet.getPermissionSet(IFB_Metadata_PermissionSet.Option.SIFT_INTERVIEWER).Id) {
				if(mapUserInfo.get(userId) != null && mapUserInfo.get(userId).itHasInterviewerPermissionSet != null && mapUserInfo.get(userId).itHasInterviewerPermissionSet == false) {
					assigneesThatDoNoHaveItYet.add(userId);
				}
			} else if (permissionSetId == IFB_Metadata_PermissionSet.getPermissionSet(IFB_Metadata_PermissionSet.Option.SIFT_HIRING_ORGANIZATION).Id) {
				if(mapUserInfo.get(userId) != null && mapUserInfo.get(userId).itHasHiringOrganizationPermissionSet != null && mapUserInfo.get(userId).itHasHiringOrganizationPermissionSet == false) {
					assigneesThatDoNoHaveItYet.add(userId); 
				}
			}
		} 
		
		// Make the future call only if needed (there are permission set assingments that are mission.)
		if (assigneesThatDoNoHaveItYet.size() > 0) {
			futureInsertPermissionSetAssignments(permissionSetId, assigneesThatDoNoHaveItYet);	
		}
	}

	// Insert permission set assignments (in the future). This this the actual @future method.
	// Please not on the restrictions of future methods perameter types: only primitive typs or collections of primitive types.
	@future
	public static void futureInsertPermissionSetAssignments(Id permissionSetId, Set<Id> assignees) {
		List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();

		for (Id assigneeId : assignees) {
			permissionSetAssignments.add(new PermissionSetAssignment(PermissionSetId = permissionSetId,  AssigneeId = assigneeId));
		}
		insert permissionSetAssignments;
	}

	// INTERVIEW, QUESTIONS AND INTERVIEWERS - MAPS
	// For each of these maps:
	// If the map hasn't been initialized yet, we create it for the recruits indicated as a parameter.
	// If the map has been initialized already, we confirm that the recruits passed as a parameter are included, if not we update the cache.
	// To avoid multiple queries, the first time that you call this methods include all the recruits that you'll be using in the transaction	
	public Map<Id, Set<Id>> getInterviewsByRecruit(Set<Id> recruits, Set<Id> interviewers, Set<Id> hiringManagers) {
		if (interviewsByRecruit == null) {
			this.queryInterviewsQuestionsAndInterviewers(recruits, interviewers, hiringManagers, true);
		} else if (interviewsByRecruit.keySet().containsAll(recruits) == false) {
			this.queryInterviewsQuestionsAndInterviewers(recruits, interviewers, hiringManagers, false);
		}
		return interviewsByRecruit;
	}

	public Map<Id, Map<Id, Set<Id>>> getInterviewsByUserOrGroupIdByRecruit(Set<Id> recruits, Set<Id> interviewers, Set<Id> hiringManagers) {
		if (interviewsByUserOrGroupIdByRecruit == null) {
			this.queryInterviewsQuestionsAndInterviewers(recruits, interviewers, hiringManagers, true);
		} else if (interviewsByUserOrGroupIdByRecruit.keySet().containsAll(recruits) == false) {
			this.queryInterviewsQuestionsAndInterviewers(recruits, interviewers, hiringManagers, false);
		}
		return interviewsByUserOrGroupIdByRecruit;
	}

	public Map<Id, Set<Id>> getInterviewQuestionsByRecruit(Set<Id> recruits, Set<Id> interviewers, Set<Id> hiringManagers) {
		if (interviewQuestionsByRecruit == null) {
			this.queryInterviewsQuestionsAndInterviewers(recruits, interviewers, hiringManagers, true);
		} else if (interviewQuestionsByRecruit.keySet().containsAll(recruits) == false) {
			this.queryInterviewsQuestionsAndInterviewers(recruits, interviewers, hiringManagers, false);
		}
		return interviewQuestionsByRecruit;
	}

	public Map<Id, Set<Id>> getSubmittedInterviewsByRecruit(Set<Id> recruits, Set<Id> interviewers, Set<Id> hiringManagers) {
		if (submittedInterviewsByRecruit == null) {
			this.queryInterviewsQuestionsAndInterviewers(recruits, interviewers, hiringManagers, true);
		} else if (submittedInterviewsByRecruit.keySet().containsAll(recruits) == false) {
			this.queryInterviewsQuestionsAndInterviewers(recruits, interviewers, hiringManagers, false);
		}
		return submittedInterviewsByRecruit;
	}

	public Map<Id, Set<Id>> getSubmittedInterviewQuestionsByRecruit(Set<Id> recruits, Set<Id> interviewers, Set<Id> hiringManagers) {
		if (submittedInterviewQuestionsByRecruit == null) {
			this.queryInterviewsQuestionsAndInterviewers(recruits, interviewers, hiringManagers, true);
		} else if (submittedInterviewQuestionsByRecruit.keySet().containsAll(recruits) == false) {
			this.queryInterviewsQuestionsAndInterviewers(recruits, interviewers, hiringManagers, false);
		}
		return submittedInterviewQuestionsByRecruit;
	}

	public Map<Id, Set<Id>> getSubmittedInterviewersByRecruit(Set<Id> recruits, Set<Id> interviewers, Set<Id> hiringManagers) {
		if (submittedInterviewersByRecruit == null) {
			this.queryInterviewsQuestionsAndInterviewers(recruits, interviewers, hiringManagers, true);
		} else if (submittedInterviewersByRecruit.keySet().containsAll(recruits) == false) {
			this.queryInterviewsQuestionsAndInterviewers(recruits, interviewers, hiringManagers, false);
		}
		return submittedInterviewersByRecruit;
	}

	public void queryInterviewsQuestionsAndInterviewers(Set<Id> recruits, 
														Set<Id> interviewers, 
														Set<Id> hiringManagers,
														Boolean resetCache) {
		
		// By default, cache is reset
		if (resetCache == null || resetCache == true) {
			interviewsByRecruit = new Map<Id, Set<Id>>();
			interviewsByUserOrGroupIdByRecruit = new Map<Id, Map<Id, Set<Id>>>();
			interviewQuestionsByRecruit = new Map<Id, Set<Id>>();
			submittedInterviewsByRecruit = new Map<Id, Set<Id>>();
			submittedInterviewQuestionsByRecruit = new Map<Id, Set<Id>>();
			submittedInterviewersByRecruit = new Map<Id, Set<Id>>();
		}
		
		//Making sure we don't query Interviews without a Recruit (if any)
		Set<Id> recruitsWithOutNulls = new Set<Id>();
		for (Id recruitId : recruits) {
			if (recruitId != null) {
				recruitsWithOutNulls.add(recruitId);
			}
		}
		recruits.clear();
		recruits.addAll(recruitsWithOutNulls);

		// QUERY TO CACHE. Depending the parameters we pass to this function is the criteria.
		String queryBase = 'select Id, '  + 
						 	'Candidate__c, ' +
							'Hiring_Manager__c, ' + 
							'Interviewer__c, ' + 
							'Interviewer2__c, ' + 
							'Interviewer3__c, ' +
							'Interviewer4__c, ' +
							'Interviewer5__c, ' +
							'Group__c, ' +
							'Interview_Type__r.SIFT_Group__r.Name, ' +
							'Status__c, ' +
							'(select Interview_Question__c ' +
							'	from Interview_Questions__r ' +
							')  ' +
							'from IFB_Interview__c ';
		
		String queryWhereStatement = ' where ';
		List<String> conditions = new List<String>();
		if (recruits != null && recruits.size() > 0) {
			conditions.add(' Candidate__c in :recruits ');
		} 
		if (interviewers != null && interviewers.size() > 0) {
			conditions.add(' Interviewer__c in :interviewers or ' +
							'Interviewer2__c in :interviewers or ' +
							'Interviewer3__c in :interviewers or ' +
							'Interviewer4__c in :interviewers or ' +
							'Interviewer5__c in :interviewers ');
		}
		if (hiringManagers != null && hiringManagers.size() > 0) {
			conditions.add(' Hiring_Manager__c in :hiringManagers ');
		}


		if (conditions.size() > 0) {
			queryWhereStatement = queryWhereStatement + ' ' + conditions[0];
			if (conditions.size() >= 2) {
				queryWhereStatement = queryWhereStatement + ' or ' + conditions[1];
			}
			if (conditions.size() == 3) {
				queryWhereStatement = queryWhereStatement + ' or ' + conditions[2];
			}
		} else {
			throw new IFB_InterviewTreeSharingException('Can not query and cache data if all parameters are null or empty');
		}

		String queryStatement = queryBase + ' ' + queryWhereStatement;
		for (IFB_Interview__c interview : Database.query(queryStatement)) {

			// -- INTERVIEW
			// Map all interviews, by Recruit
			if (interviewsByRecruit.containsKey(interview.Candidate__c) == false) {
				interviewsByRecruit.put(interview.Candidate__c, new Set<Id>());
			}
			interviewsByRecruit.get(interview.Candidate__c).add(interview.Id);

			// ---
			// Map all interviews, by UserOrGroupId, by Recruit
			if (interviewsByUserOrGroupIdByRecruit.containsKey(interview.Candidate__c) == false) {
				interviewsByUserOrGroupIdByRecruit.put(interview.Candidate__c, new Map<Id, Set<Id>>());
			}

			// ~ Interviewer
			if (interview.Interviewer__c != null) {
				if (interviewsByUserOrGroupIdByRecruit.get(interview.Candidate__c).containsKey(interview.Interviewer__c) == false) {
					interviewsByUserOrGroupIdByRecruit.get(interview.Candidate__c).put(interview.Interviewer__c, new Set<Id>()); 
				}
				interviewsByUserOrGroupIdByRecruit.get(interview.Candidate__c).get(interview.Interviewer__c).add(interview.Id);
			}

			// ~ Interviewer 2
			if (interview.Interviewer2__c != null) {
				if (interviewsByUserOrGroupIdByRecruit.get(interview.Candidate__c).containsKey(interview.Interviewer2__c) == false) {
					interviewsByUserOrGroupIdByRecruit.get(interview.Candidate__c).put(interview.Interviewer2__c, new Set<Id>()); 
				}
				interviewsByUserOrGroupIdByRecruit.get(interview.Candidate__c).get(interview.Interviewer2__c).add(interview.Id);
			}

			// ~ Interviewer 3	
			if (interview.Interviewer3__c != null) {
				if (interviewsByUserOrGroupIdByRecruit.get(interview.Candidate__c).containsKey(interview.Interviewer3__c) == false) {
					interviewsByUserOrGroupIdByRecruit.get(interview.Candidate__c).put(interview.Interviewer3__c, new Set<Id>()); 
				}
				interviewsByUserOrGroupIdByRecruit.get(interview.Candidate__c).get(interview.Interviewer3__c).add(interview.Id);
			}

			// ~ Interviewer 4
			if (interview.Interviewer4__c != null) {
				if (interviewsByUserOrGroupIdByRecruit.get(interview.Candidate__c).containsKey(interview.Interviewer4__c) == false) {
					interviewsByUserOrGroupIdByRecruit.get(interview.Candidate__c).put(interview.Interviewer4__c, new Set<Id>()); 
				}
				interviewsByUserOrGroupIdByRecruit.get(interview.Candidate__c).get(interview.Interviewer4__c).add(interview.Id);
			}

			// ~ Interviewer 5
			if (interview.Interviewer5__c != null) {
				if (interviewsByUserOrGroupIdByRecruit.get(interview.Candidate__c).containsKey(interview.Interviewer5__c) == false) {
					interviewsByUserOrGroupIdByRecruit.get(interview.Candidate__c).put(interview.Interviewer5__c, new Set<Id>()); 
				}
				interviewsByUserOrGroupIdByRecruit.get(interview.Candidate__c).get(interview.Interviewer5__c).add(interview.Id);
			}

			// ~ Hiring Manager
			if (interview.Hiring_Manager__c != null) {
				if (interviewsByUserOrGroupIdByRecruit.get(interview.Candidate__c).containsKey(interview.Hiring_Manager__c) == false) {
					interviewsByUserOrGroupIdByRecruit.get(interview.Candidate__c).put(interview.Hiring_Manager__c, new Set<Id>()); 
				}
				interviewsByUserOrGroupIdByRecruit.get(interview.Candidate__c).get(interview.Hiring_Manager__c).add(interview.Id);
			}

			// ~ CSG API
			if (interview.Interview_Type__r.SIFT_Group__r.Name == GROUP_DEVELOPER_NAME_CSG_API) {
				if (interviewsByUserOrGroupIdByRecruit.get(interview.Candidate__c).containsKey(getCSGGroupId()) == false) {
					interviewsByUserOrGroupIdByRecruit.get(interview.Candidate__c).put(getCSGGroupId(), new Set<Id>()); 
				}
				interviewsByUserOrGroupIdByRecruit.get(interview.Candidate__c).get(getCSGGroupId()).add(interview.Id);
			}
			// ---

			// -- INTERVIEW QUESTIONS
			// Map all the questions used in interviews, by recruit
			if (interviewQuestionsByRecruit.containsKey(interview.Candidate__c) == false) {
				interviewQuestionsByRecruit.put(interview.Candidate__c, new Set<Id>());
			}
			for (IFB_Interview_Evaluation__c evaluation : interview.Interview_Questions__r) {
				interviewQuestionsByRecruit.get(interview.Candidate__c).add(evaluation.Interview_Question__c);
			}

			if (interview.Status__c == INTERVIEW_STATUS_FEEDBACK_SUBMITTED) {
				// -- INTERVIEW (SUBMITTED)
				// Map all 'Feedback submitted' interviews, by recruit
				if (submittedInterviewsByRecruit.containsKey(interview.Candidate__c) == false) {
					submittedInterviewsByRecruit.put(interview.Candidate__c, new Set<Id>());
				}
				submittedInterviewsByRecruit.get(interview.Candidate__c).add(interview.Id);

				// -- INTERVIEW QUESTIONS (SUBMITTED)
				// Map all the questions used in 'Feedback Submitted' interviews, by recruit
				if (submittedInterviewQuestionsByRecruit.containsKey(interview.Candidate__c) == false) {
					submittedInterviewQuestionsByRecruit.put(interview.Candidate__c, new Set<Id>());
				}
				for (IFB_Interview_Evaluation__c evaluation : interview.Interview_Questions__r) {
					submittedInterviewQuestionsByRecruit.get(interview.Candidate__c).add(evaluation.Interview_Question__c);
				}

				// -- INTERVIEWERS (SUBMITTED)
				if (submittedInterviewersByRecruit.containsKey(interview.Candidate__c) == false) {
					submittedInterviewersByRecruit.put(interview.Candidate__c, new Set<Id>());
				}
				
				if (interview.Interviewer__c != null) {
					submittedInterviewersByRecruit.get(interview.Candidate__c).add(interview.Interviewer__c);
				}
				if (interview.Interviewer2__c != null) {
					submittedInterviewersByRecruit.get(interview.Candidate__c).add(interview.Interviewer2__c);
				}
				if (interview.Interviewer3__c != null) {
					submittedInterviewersByRecruit.get(interview.Candidate__c).add(interview.Interviewer3__c);
				}
				if (interview.Interviewer4__c != null) {
					submittedInterviewersByRecruit.get(interview.Candidate__c).add(interview.Interviewer4__c);
				}
				if (interview.Interviewer5__c != null) {
					submittedInterviewersByRecruit.get(interview.Candidate__c).add(interview.Interviewer5__c);
				}		
			}	
		}
	}

	public Map<Id, Map<Id, Map<String,List<IFB_Interview__share>>>> getInterviewSharesByRowCauseByByUserOrGroupIdByInterview(
																		Set<Id> interviews,
																		Set<Id> userOrGroupIds,
																		Set<String> rowCauses, 
																		Boolean resetCache) {
		// By default, cache is reset
		if (resetCache == null || resetCache == true) {
			interviewSharesByRowCauseByByUserOrGroupIdByInterview = null;
		}

		if (resetCache == false || interviewSharesByRowCauseByByUserOrGroupIdByInterview == null) {
			
			if (interviewSharesByRowCauseByByUserOrGroupIdByInterview == null) {
				interviewSharesByRowCauseByByUserOrGroupIdByInterview = new Map<Id, Map<Id, Map<String,List<IFB_Interview__share>>>>();	
			}

			for (IFB_Interview__share interviewShare : [select Id, ParentId, UserOrGroupId, RowCause from IFB_Interview__share
				 											where ParentId in :interviews
				 											and UserOrGroupId in :userOrGroupIds
				 											and RowCause in :rowCauses]) {	 
			 	// Initialize 'Interview' level grouping
				if (interviewSharesByRowCauseByByUserOrGroupIdByInterview.containsKey(interviewShare.ParentId) == false) {
					interviewSharesByRowCauseByByUserOrGroupIdByInterview.put(interviewShare.ParentId, new Map<Id, Map<String,List<IFB_Interview__share>>>());
				}

				// Initialize 'UserOrGroupId' level grouping
				if (interviewSharesByRowCauseByByUserOrGroupIdByInterview.get(interviewShare.ParentId).containsKey(interviewShare.UserOrGroupId) == false) {
					interviewSharesByRowCauseByByUserOrGroupIdByInterview.get(interviewShare.ParentId).put(interviewShare.UserOrGroupId, new Map<String,List<IFB_Interview__share>>());
				}

				// Initialize 'RowCause' level grouping
				if (interviewSharesByRowCauseByByUserOrGroupIdByInterview.get(interviewShare.ParentId).get(interviewShare.UserOrGroupId).containsKey(interviewShare.RowCause) == false) {
					interviewSharesByRowCauseByByUserOrGroupIdByInterview.get(interviewShare.ParentId).get(interviewShare.UserOrGroupId).put(interviewShare.RowCause , new List<IFB_Interview__share>());
				}

				interviewSharesByRowCauseByByUserOrGroupIdByInterview.get(interviewShare.ParentId).get(interviewShare.UserOrGroupId).get(interviewShare.RowCause).add(interviewShare);
			 }
			 

		}
		return interviewSharesByRowCauseByByUserOrGroupIdByInterview;
	}

	public Map<Id, Map<Id, Map<String,List<IFB_Interview_Candidate__share>>>> getRecruitSharesByRowCauseByByUserOrGroupIdByRecruit(Set<Id> recruits,
																																	Set<Id> userOrGroupIds,
																																	Set<String> rowCauses, 
																																	Boolean resetCache) {
		// By default, cache is reset
		if (resetCache == null || resetCache == true) {
			recruitSharesByRowCauseByByUserOrGroupIdByRecruit = null;
		}

		if (resetCache == false || recruitSharesByRowCauseByByUserOrGroupIdByRecruit == null) {
			
			if (recruitSharesByRowCauseByByUserOrGroupIdByRecruit == null) {
				recruitSharesByRowCauseByByUserOrGroupIdByRecruit = new Map<Id, Map<Id, Map<String,List<IFB_Interview_Candidate__share>>>>();	
			}
				 
			for (IFB_Interview_Candidate__share recruitShare : [select Id, ParentId, UserOrGroupId, RowCause from IFB_Interview_Candidate__share	 															
 															where ParentId in :recruits
 															and UserOrGroupId in :userOrGroupIds
 															and RowCause in :rowCauses]) {
			 			 
			 	// Initialize 'Recruit' level grouping
				if (recruitSharesByRowCauseByByUserOrGroupIdByRecruit.containsKey(recruitShare.ParentId) == false) {
					recruitSharesByRowCauseByByUserOrGroupIdByRecruit.put(recruitShare.ParentId, new Map<Id, Map<String,List<IFB_Interview_Candidate__share>>>());
				}

				// Initialize 'UserOrGroupId' level grouping
				if (recruitSharesByRowCauseByByUserOrGroupIdByRecruit.get(recruitShare.ParentId).containsKey(recruitShare.UserOrGroupId) == false) {
					recruitSharesByRowCauseByByUserOrGroupIdByRecruit.get(recruitShare.ParentId).put(recruitShare.UserOrGroupId, new Map<String,List<IFB_Interview_Candidate__share>>());
				}

				// Initialize 'RowCause' level grouping
				if (recruitSharesByRowCauseByByUserOrGroupIdByRecruit.get(recruitShare.ParentId).get(recruitShare.UserOrGroupId).containsKey(recruitShare.RowCause) == false) {
					recruitSharesByRowCauseByByUserOrGroupIdByRecruit.get(recruitShare.ParentId).get(recruitShare.UserOrGroupId).put(recruitShare.RowCause , new List<IFB_Interview_Candidate__share>());
				}

				recruitSharesByRowCauseByByUserOrGroupIdByRecruit.get(recruitShare.ParentId).get(recruitShare.UserOrGroupId).get(recruitShare.RowCause).add(recruitShare);
			 }

		}
		return recruitSharesByRowCauseByByUserOrGroupIdByRecruit;

	}


	public Map<Id, Map<Id, Map<String,List<IFB_Interview_Question__share>>>> getQuestionSharesByRowCauseByByUserOrGroupIdByRecruit(Set<Id> questions,
																																	Set<Id> userOrGroupIds,
																																	Set<String> rowCauses, 
																																	Boolean resetCache) {
		// By default, cache is reset
		if (resetCache == null || resetCache == true) {
			questionSharesByRowCauseByByUserOrGroupIdByRecruit = null;
		}

		if (resetCache == false || questionSharesByRowCauseByByUserOrGroupIdByRecruit == null) {
			
			if (questionSharesByRowCauseByByUserOrGroupIdByRecruit == null) {
				questionSharesByRowCauseByByUserOrGroupIdByRecruit = new Map<Id, Map<Id, Map<String,List<IFB_Interview_Question__share>>>>();	
			}
				 
			for (IFB_Interview_Question__share questionShare : [select Id, ParentId, UserOrGroupId, RowCause from IFB_Interview_Question__share
				 													where ParentId in :questions
				 													and UserOrGroupId in :userOrGroupIds
				 													and RowCause in :rowCauses]) {
			 			 
			 	// Initialize 'Recruit' level grouping
				if (questionSharesByRowCauseByByUserOrGroupIdByRecruit.containsKey(questionShare.ParentId) == false) {
					questionSharesByRowCauseByByUserOrGroupIdByRecruit.put(questionShare.ParentId, new Map<Id, Map<String,List<IFB_Interview_Question__share>>>());
				}

				// Initialize 'UserOrGroupId' level grouping
				if (questionSharesByRowCauseByByUserOrGroupIdByRecruit.get(questionShare.ParentId).containsKey(questionShare.UserOrGroupId) == false) {
					questionSharesByRowCauseByByUserOrGroupIdByRecruit.get(questionShare.ParentId).put(questionShare.UserOrGroupId, new Map<String,List<IFB_Interview_Question__share>>());
				}

				// Initialize 'RowCause' level grouping
				if (questionSharesByRowCauseByByUserOrGroupIdByRecruit.get(questionShare.ParentId).get(questionShare.UserOrGroupId).containsKey(questionShare.RowCause) == false) {
					questionSharesByRowCauseByByUserOrGroupIdByRecruit.get(questionShare.ParentId).get(questionShare.UserOrGroupId).put(questionShare.RowCause , new List<IFB_Interview_Question__share>());
				}

				questionSharesByRowCauseByByUserOrGroupIdByRecruit.get(questionShare.ParentId).get(questionShare.UserOrGroupId).get(questionShare.RowCause).add(questionShare);
			 }

		}
		return questionSharesByRowCauseByByUserOrGroupIdByRecruit;
	}

	public Map<Id,Map<Id, Set<Id>>> getQuestionsByInterviewByInterviewer(Set<Id> interviewers, Boolean resetCache) {
		
		// By default, cache is reset
		if (resetCache == null || resetCache == true) {
			questionsByInterviewByInterviewer = null;
		}

		if (resetCache == false || questionsByInterviewByInterviewer == null) {
			
			if (questionsByInterviewByInterviewer == null) {
				questionsByInterviewByInterviewer = new Map<Id,Map<Id, Set<Id>>>();	
			}

			for (IFB_Interview_Evaluation__c evaluation :[select Interview_Question__c,
															Interview__c,
															Interview__r.Interviewer__c, 
															Interview__r.Interviewer2__c,
															Interview__r.Interviewer3__c,
															Interview__r.Interviewer4__c,
															Interview__r.Interviewer5__c,
															Interview__r.Hiring_Manager__c
															from IFB_Interview_Evaluation__c
															where Interview__r.Interviewer__c in :interviewers
																or Interview__r.Interviewer2__c in :interviewers
																or Interview__r.Interviewer3__c in :interviewers
																or Interview__r.Interviewer4__c in :interviewers
																or Interview__r.Interviewer5__c in :interviewers]) {

				if (evaluation.Interview__c != null) {
					// ~ Interviewer
					if (evaluation.Interview__r.Interviewer__c != null) {
						if (questionsByInterviewByInterviewer.containsKey(evaluation.Interview__r.Interviewer__c) == false) {
							questionsByInterviewByInterviewer.put(evaluation.Interview__r.Interviewer__c, new Map<Id,Set<Id>>());
						}
						if (questionsByInterviewByInterviewer.get(evaluation.Interview__r.Interviewer__c).containsKey(evaluation.Interview__c) == false) {
							questionsByInterviewByInterviewer.get(evaluation.Interview__r.Interviewer__c).put(evaluation.Interview__c, new Set<Id>());
						}
						questionsByInterviewByInterviewer.get(evaluation.Interview__r.Interviewer__c).get(evaluation.Interview__c).add(evaluation.Interview_Question__c);
					}

					// ~ Interviewer 2
					if (evaluation.Interview__r.Interviewer2__c != null) {
						if (questionsByInterviewByInterviewer.containsKey(evaluation.Interview__r.Interviewer2__c) == false) {
							questionsByInterviewByInterviewer.put(evaluation.Interview__r.Interviewer2__c, new Map<Id,Set<Id>>());
						}
						if (questionsByInterviewByInterviewer.get(evaluation.Interview__r.Interviewer2__c).containsKey(evaluation.Interview__c) == false) {
							questionsByInterviewByInterviewer.get(evaluation.Interview__r.Interviewer2__c).put(evaluation.Interview__c, new Set<Id>());
						}
						questionsByInterviewByInterviewer.get(evaluation.Interview__r.Interviewer2__c).get(evaluation.Interview__c).add(evaluation.Interview_Question__c);
					}

					// ~ Interviewer 3
					if (evaluation.Interview__r.Interviewer__c != null) {
						if (questionsByInterviewByInterviewer.containsKey(evaluation.Interview__r.Interviewer3__c) == false) {
							questionsByInterviewByInterviewer.put(evaluation.Interview__r.Interviewer3__c, new Map<Id,Set<Id>>());
						}
						if (questionsByInterviewByInterviewer.get(evaluation.Interview__r.Interviewer3__c).containsKey(evaluation.Interview__c) == false) {
							questionsByInterviewByInterviewer.get(evaluation.Interview__r.Interviewer3__c).put(evaluation.Interview__c, new Set<Id>());
						}
						questionsByInterviewByInterviewer.get(evaluation.Interview__r.Interviewer3__c).get(evaluation.Interview__c).add(evaluation.Interview_Question__c);
					}

					// ~ Interviewer 4
					if (evaluation.Interview__r.Interviewer__c != null) {
						if (questionsByInterviewByInterviewer.containsKey(evaluation.Interview__r.Interviewer4__c) == false) {
							questionsByInterviewByInterviewer.put(evaluation.Interview__r.Interviewer4__c, new Map<Id,Set<Id>>());
						}
						if (questionsByInterviewByInterviewer.get(evaluation.Interview__r.Interviewer4__c).containsKey(evaluation.Interview__c) == false) {
							questionsByInterviewByInterviewer.get(evaluation.Interview__r.Interviewer4__c).put(evaluation.Interview__c, new Set<Id>());
						}
						questionsByInterviewByInterviewer.get(evaluation.Interview__r.Interviewer4__c).get(evaluation.Interview__c).add(evaluation.Interview_Question__c);
					}

					// ~ Interviewer 5
					if (evaluation.Interview__r.Interviewer__c != null) {
						if (questionsByInterviewByInterviewer.containsKey(evaluation.Interview__r.Interviewer5__c) == false) {
							questionsByInterviewByInterviewer.put(evaluation.Interview__r.Interviewer5__c, new Map<Id,Set<Id>>());
						}
						if (questionsByInterviewByInterviewer.get(evaluation.Interview__r.Interviewer5__c).containsKey(evaluation.Interview__c) == false) {
							questionsByInterviewByInterviewer.get(evaluation.Interview__r.Interviewer5__c).put(evaluation.Interview__c, new Set<Id>());
						}
						questionsByInterviewByInterviewer.get(evaluation.Interview__r.Interviewer5__c).get(evaluation.Interview__c).add(evaluation.Interview_Question__c);
					}
				}
			}
		}

		return questionsByInterviewByInterviewer;
	}

	public Map<Id,Map<Id, Set<Id>>> getQuestionsByInterviewByHiringManager(Set<Id> hiringManagers, Boolean resetCache) {
		
		// By default, cache is reset
		if (resetCache == null || resetCache == true) {
			questionsByInterviewByHiringManager = null;
		}

		if (resetCache == false || questionsByInterviewByHiringManager == null) {
			
			if (questionsByInterviewByHiringManager == null) {
				questionsByInterviewByHiringManager = new Map<Id,Map<Id, Set<Id>>>();	
			}

			for (IFB_Interview_Evaluation__c evaluation :[select Interview_Question__c,
															Interview__c,
															Interview__r.Hiring_Manager__c
															from IFB_Interview_Evaluation__c
															where Interview__r.Hiring_Manager__c in :hiringManagers]) {

				if (evaluation.Interview__c != null) {

					// ~ Hiring Manager
					if (evaluation.Interview__r.Hiring_Manager__c != null) {
						if (questionsByInterviewByInterviewer.containsKey(evaluation.Interview__r.Hiring_Manager__c) == false) {
							questionsByInterviewByInterviewer.put(evaluation.Interview__r.Hiring_Manager__c, new Map<Id,Set<Id>>());
						}
						if (questionsByInterviewByInterviewer.get(evaluation.Interview__r.Hiring_Manager__c).containsKey(evaluation.Interview__c) == false) {
							questionsByInterviewByInterviewer.get(evaluation.Interview__r.Hiring_Manager__c).put(evaluation.Interview__c, new Set<Id>());
						}
						questionsByInterviewByInterviewer.get(evaluation.Interview__r.Hiring_Manager__c).get(evaluation.Interview__c).add(evaluation.Interview_Question__c);
					}
				}
			}
		}

		return questionsByInterviewByHiringManager;
	}


	public void addInterviewTreeShares(Id interviewId,
										Id recruitId,
										Set<Id> questions, 
										ApexSharingReason sharingReason,
										Set<Id> usersOrGroups, 
										Set<IFB_Interview__share> interviewShares,
										Set<IFB_Interview_Candidate__share> recruitShares,
										Set<IFB_Interview_Question__share> questionShares) {  
		if (interviewShares == null) {
			interviewShares = new Set<IFB_Interview__share>(); 
		}

		if (recruitShares == null) {
			recruitShares = new Set<IFB_Interview_Candidate__share>();
		}

		if (questionShares == null) {
			questionShares = new Set<IFB_Interview_Question__share>();
		}

		if (usersOrGroups != null) {
			for (Id userOrGroupId : usersOrGroups) {

				//Generate shares for the 'Interview' object
				IFB_Interview__share interviewShare = new IFB_Interview__share();
				interviewShare.UserOrGroupId = userOrGroupId; 
				interviewShare.ParentId = interviewId;		

				if (sharingReason == ApexSharingReason.INTERVIEWER) {			
					interviewShare.RowCause = Schema.IFB_Interview__share.RowCause.Interviewer__c;
					interviewShare.AccessLevel = 'Edit';
				} else if (sharingReason == ApexSharingReason.HIRING_MANAGER) {
					interviewShare.RowCause = Schema.IFB_Interview__share.RowCause.Hiring_Manager__c;
					interviewShare.AccessLevel = 'Read';
				} else if (sharingReason == ApexSharingReason.HIRING_ORGANIZATION) {
					interviewShare.RowCause = Schema.IFB_Interview__share.RowCause.Hiring_Organization__c;
					interviewShare.AccessLevel = 'Read';
				} else if (sharingReason == ApexSharingReason.PANEL_INTERVIEWER) {
					interviewShare.RowCause = Schema.IFB_Interview__share.RowCause.Panel_Interviewer__c;
					interviewShare.AccessLevel = 'Read';
				}  else {
					throw new IFB_InterviewTreeSharingException('Sharing Reason is not supported. ' + ' ' + sharingReason.name());
				}
				
				interviewShares.add(interviewShare);

				//Generate shares for the 'Recruit' object
				IFB_Interview_Candidate__share recruitShare = new IFB_Interview_Candidate__share();
				recruitShare.UserOrGroupId = userOrGroupId;
				recruitShare.ParentId = recruitId;
			 			
				if (sharingReason == ApexSharingReason.INTERVIEWER) {			
					recruitShare.RowCause = Schema.IFB_Interview_Candidate__share.RowCause.Interviewer__c;
					recruitShare.AccessLevel = 'Read';
				} else if (sharingReason == ApexSharingReason.HIRING_MANAGER) {
					recruitShare.RowCause = Schema.IFB_Interview_Candidate__share.RowCause.Hiring_Manager__c;
					recruitShare.AccessLevel = 'Read';
				} else if (sharingReason == ApexSharingReason.HIRING_ORGANIZATION) {
					recruitShare.RowCause = Schema.IFB_Interview_Candidate__share.RowCause.Hiring_Organization__c;
					recruitShare.AccessLevel = 'Read';
				} else if (sharingReason == ApexSharingReason.PANEL_INTERVIEWER) {
					recruitShare.RowCause = Schema.IFB_Interview_Candidate__share.RowCause.Panel_Interviewer__c;
					recruitShare.AccessLevel = 'Read';
				}  else {
					throw new IFB_InterviewTreeSharingException('Sharing reason is not supported: ' + sharingReason.name());
				}

				recruitShares.add(recruitShare);
				
				if (questions != null) {
					//Generate shares for the 'Questions' object		
					for (Id questionId : questions) {
						IFB_Interview_Question__share questionShare = new IFB_Interview_Question__share();
						questionShare.UserOrGroupId = userOrGroupId;
						questionShare.ParentId = questionId;

						if (sharingReason == ApexSharingReason.INTERVIEWER) {			
							questionShare.RowCause = Schema.IFB_Interview_Question__share.RowCause.Interviewer__c;
							questionShare.AccessLevel = 'Read';
						} else if (sharingReason == ApexSharingReason.HIRING_MANAGER) {
							questionShare.RowCause = Schema.IFB_Interview_Question__share.RowCause.Hiring_Manager__c;
							questionShare.AccessLevel = 'Read';
						} else if (sharingReason == ApexSharingReason.HIRING_ORGANIZATION) {
							questionShare.RowCause = Schema.IFB_Interview_Question__share.RowCause.Hiring_Organization__c;
							questionShare.AccessLevel = 'Read';
						} else if (sharingReason == ApexSharingReason.PANEL_INTERVIEWER) {
							questionShare.RowCause = Schema.IFB_Interview_Question__share.RowCause.Panel_Interviewer__c;
							questionShare.AccessLevel = 'Read';
						}  else {
							throw new IFB_InterviewTreeSharingException('Sharing reason is not supported: ' + sharingReason.name());
						}

						questionShares.add(questionShare);
					}
				}	
						
			}
		}
	}


	public void recalculatePanelInterviewerShares(Id recruitId,
										Set<Id> recruitInterviews, 
										Set<Id> recruitQuestions,
										Set<Id> recruitSubmittedInterviews, 
										Set<Id> recruitSubmittedQuestions, 
										Set<Id>	recruitSubmittedInterviewers, 
										Set<IFB_Interview__share> interviewSharesToAdd,
										Set<IFB_Interview_Candidate__share> recruitSharesToAdd,
										Set<IFB_Interview_Question__share> questionSharesToAdd,
										Set<IFB_Interview__share> interviewSharesToDelete,
										Set<IFB_Interview_Candidate__share> recruitSharesToDelete,
										Set<IFB_Interview_Question__share> questionSharesToDelete) { 

		// -- REMOVE EXISTING PANEL INTERVIEWER SHARING
		// We are going to recalculate it for the given recruit, we we need to start clean.

		// -- Remove Interview
		// Remove all the 'Panel Interviewer' sharing of all the Interviews of the Recruit
		List<IFB_Interview__share> interviewSharesToDeleteList =
			[select Id from IFB_Interview__share 
			 where RowCause = 'Panel_Interviewer__c'
			 and ParentId in :recruitInterviews];

		interviewSharesToDelete.addAll(interviewSharesToDeleteList);

		// -- Remove Recruit
		List<IFB_Interview_Candidate__share> recruitSharesToDeleteList =
			[select Id from IFB_Interview_Candidate__share 
			 where RowCause = 'Panel_Interviewer__c'
			 and ParentId = :recruitId];

		recruitSharesToDelete.addAll(recruitSharesToDeleteList);

		// -- ADD PANEL INTERVIEWER SHARING
		// Adding sharing records as needed
		if (recruitSubmittedInterviews != null) {
			for (Id interviewId : recruitSubmittedInterviews) {
				this.addInterviewTreeShares(interviewId,
											recruitId, 
											recruitSubmittedQuestions, 
											IFB_InterviewOpsWos.ApexSharingReason.PANEL_INTERVIEWER, 
											recruitSubmittedInterviewers, 
											interviewSharesToAdd,
											recruitSharesToAdd, 
											questionSharesToAdd);
			}
		}
	}

	public void removeInterviewTreeShares(Id interviewId,
										Id recruitId,
										Set<Id> questions,
										ApexSharingReason sharingReason,
										Set<Id> userOrGroupIds, 
										Set<IFB_Interview__share> interviewSharesToDelete,
										Set<IFB_Interview_Candidate__share> recruitSharesToDelete,
										Set<IFB_Interview_Question__share> questionSharesToDelete,
										Set<Id> interviewsScope,
										Set<Id> recruitsScope,
										Set<Id> questionsScope,
										Set<String> sharingReasonStringsScope,
										Set<Id> userOrGroupIdsScope, 
										Set<Id> interviewersScope,
										Set<Id> hiringManagerScope) {

		if (interviewSharesToDelete == null) {
			interviewSharesToDelete = new Set<IFB_Interview__share>(); 
		}

		if (recruitSharesToDelete == null) {
			recruitSharesToDelete = new Set<IFB_Interview_Candidate__share>();
		}

		if (questionSharesToDelete == null) {
			questionSharesToDelete = new Set<IFB_Interview_Question__share>();
		}

		String sharingReasonString;
		if (sharingReason == ApexSharingReason.INTERVIEWER) {
			sharingReasonString = 'Interviewer__c';
		} else if (sharingReason == ApexSharingReason.HIRING_MANAGER) {
			sharingReasonString = 'Hiring_Manager__c';
		} else if (sharingReason == ApexSharingReason.HIRING_ORGANIZATION) {
			sharingReasonString = 'Hiring_Organization__c';
		} else if (sharingReason == ApexSharingReason.CSG_API) {
			sharingReasonString = 'CSG_API';
		} else {
			throw new IFB_InterviewTreeSharingException('Sharing Reason is not supported. ' + ' ' + sharingReason.name());
		}

		// --- INTERVIEW ---
		// Remove access to the Interview record.
		if (userOrGroupIds == null) {
			userOrGroupIds = new Set<Id>();
		}

		Map<Id, Map<Id, Map<String,List<IFB_Interview__share>>>> usersMapping = getInterviewSharesByRowCauseByByUserOrGroupIdByInterview(interviewsScope, userOrGroupIdsScope, sharingReasonStringsScope, false);
                                            
		for (Id userOrGroupId : userOrGroupIds) {

            if(usersMapping.containsKey(interviewId) && usersMapping.get(interviewId).containsKey(userOrGroupId)
               && usersMapping.get(interviewId).get(userOrGroupId).containsKey(sharingReasonString)){
             
				interviewSharesToDelete.addAll(usersMapping
					.get(interviewId)
					.get(userOrGroupId)
					.get(sharingReasonString)
				);
            }
		}

		// --- RECRUIT --
		// Only if the Interviewer doesn't have any other Interview with the Recruiter, 
		// then we remove the access to the Recruit record.
		// To mimimize complexity  Hiring Organization sharing of Recruit is not removed.
		if (sharingReason != ApexSharingReason.HIRING_ORGANIZATION) {
			for (Id userOrGroupId : userOrGroupIds) {

				Set<Id> interviewsWithRecruit;
				if (getInterviewsByUserOrGroupIdByRecruit(recruitsScope, interviewersScope, hiringManagerScope)
												.get(recruitId)
													.containsKey(userOrGroupId)) {


					interviewsWithRecruit = getInterviewsByUserOrGroupIdByRecruit(recruitsScope, interviewersScope, hiringManagerScope)
													.get(recruitId)
													.get(userOrGroupId);

					// From the list of all the interviews that the userOrGroupId has with the recruit, 
					// we remove remove the interview that the userOrGroupId should not have access any more.
					
					interviewsWithRecruit.remove(interviewId);
				}

				// If the userOrGroupId doesn't have any other interviews with the recruit, then we can remove
				// the access to the recruit record.
				if (interviewsWithRecruit == null || interviewsWithRecruit.size() == 0) {
                    
                    Map<Id, Map<Id, Map<String,List<IFB_Interview_Candidate__share>>>> sharesMap = getRecruitSharesByRowCauseByByUserOrGroupIdByRecruit(recruitsScope, userOrGroupIdsScope, sharingReasonStringsScope, false);
                    
                    if(sharesMap.containsKey(recruitId) && sharesMap.get(recruitId).containsKey(userOrGroupId)
                       && sharesMap.get(recruitId).get(userOrGroupId).containsKey(sharingReasonString)){
                           recruitSharesToDelete.addAll(sharesMap.get(recruitId).get(userOrGroupId).get(sharingReasonString));
                       }
				}
			}
		}

		// --- QUESTIONS ---
		// Get all the questions that this Interviewer has access to (except for the ones in this interview
		// To mimimize complexity  Hiring Organization sharing of Questions is not removed.
		
		//if ((sharingReason != ApexSharingReason.HIRING_ORGANIZATION) && (sharingReason == ApexSharingReason.INTERVIEWER || sharingReason == ApexSharingReason.HIRING_MANAGER)) {
		// To avoid the following exception 'System.LimitException: Apex CPU time limit exceeded' we have disabled the "Interview Questions" unsharing.
		// Interviewers don't have access to the "Interview Questions" tab anyways so they won't be able to see the records directly (although technically they have access to the records)
		if (false) {
			for (Id userOrGroupId : userOrGroupIds) {
				Set<Id> otherInterviews = new Set<Id>();
				Set<Id> questionsUsedInOtherInterviews = new Set<Id>();
				if (sharingReason == ApexSharingReason.INTERVIEWER) {
					
					if (getQuestionsByInterviewByInterviewer(userOrGroupIdsScope, false)
							.containsKey(userOrGroupId)) {
						
						// We get all the interviews of the interviewer, and then we remove the current interview from the list.
						otherInterviews.addAll(
							getQuestionsByInterviewByInterviewer(userOrGroupIdsScope, false)
								.get(userOrGroupId).keySet()
						);

						otherInterviews.remove(interviewId);

						for (Id otherInterviewId : otherInterviews) {
							if (getQuestionsByInterviewByInterviewer(userOrGroupIdsScope, false)
									.get(userOrGroupId)
									.containsKey(otherInterviewId)) {

								questionsUsedInOtherInterviews.addAll(
																	
									getQuestionsByInterviewByInterviewer(userOrGroupIdsScope, false)
										.get(userOrGroupId)
										.get(otherInterviewId)
								);
							}
						}
					}

				} else if (sharingReason == ApexSharingReason.HIRING_MANAGER) {
					
					if (getQuestionsByInterviewByInterviewer(userOrGroupIdsScope, false)
							.containsKey(userOrGroupId)) {

						// We get all the interviews of the Hiring Manager, and then we remove the current interview from the list.
						otherInterviews.addAll(
							getQuestionsByInterviewByHiringManager(userOrGroupIdsScope, false)
								.get(userOrGroupId).keySet()

						);
						otherInterviews.remove(interviewId);

						for (Id otherInterviewId : otherInterviews) {
							if (getQuestionsByInterviewByHiringManager(userOrGroupIdsScope, false)
									.get(userOrGroupId)
									.containsKey(otherInterviewId)) {

								questionsUsedInOtherInterviews.addAll(
								
									getQuestionsByInterviewByHiringManager(userOrGroupIdsScope, false)
										.get(userOrGroupId)
										.get(otherInterviewId)
								);
							}			
						}
					}	
				}

				Set<Id> questionsToRemoveAccess = new Set<Id>();
				if (questions != null) {
					for (Id questionId : questions) {
						if (questionsUsedInOtherInterviews.contains(questionId) == false) {
							questionsToRemoveAccess.add(questionId);
						}
					}
				}		

				if (getQuestionSharesByRowCauseByByUserOrGroupIdByRecruit(questionsScope, userOrGroupIdsScope, sharingReasonStringsScope, false)
						.containsKey(recruitId)) {
					if (getQuestionSharesByRowCauseByByUserOrGroupIdByRecruit(questionsScope, userOrGroupIdsScope, sharingReasonStringsScope, false)
							.get(recruitId)
							.containsKey(userOrGroupId)) {

							questionSharesToDelete.addAll(
							getQuestionSharesByRowCauseByByUserOrGroupIdByRecruit(questionsScope, userOrGroupIdsScope, sharingReasonStringsScope, false)
								.get(recruitId)
								.get(userOrGroupId)
								.get(sharingReasonString)
						);
					}
				}
				
			}
		}	
	}

	public void getNewAnOldInterviewers(IFB_Interview__c newInterview, IFB_Interview__c oldInterview, Set<Id> newInterviewers, Set<Id> oldInterviewers) {
		
		if (newInterviewers == null) {
			newInterviewers = new Set<Id>();
		}

		if (oldInterviewers == null) {
			oldInterviewers = new Set<Id>();
		}

		// Interviewer
		if (newInterview.Interviewer__c != oldInterview.Interviewer__c) {
			if (newInterview.Interviewer__c != null) {					
				newInterviewers.add(newInterview.Interviewer__c);
			}
			if (oldInterview.Interviewer__c != null) {					
				oldInterviewers.add(oldInterview.Interviewer__c);
			}
		}
		// Interviewer 2
		if (newInterview.Interviewer2__c != oldInterview.Interviewer2__c) {
			if (newInterview.Interviewer2__c != null) {					
				newInterviewers.add(newInterview.Interviewer2__c);
			}
			if (oldInterview.Interviewer2__c != null) {					
				oldInterviewers.add(oldInterview.Interviewer2__c);
			}
		}
		// Interviewer 3
		if (newInterview.Interviewer3__c != oldInterview.Interviewer3__c) {
			if (newInterview.Interviewer3__c != null) {					
				newInterviewers.add(newInterview.Interviewer3__c);
			}
			if (oldInterview.Interviewer3__c != null) {					
				oldInterviewers.add(oldInterview.Interviewer3__c);
			}
		}
		// Interviewer 4
		if (newInterview.Interviewer4__c != oldInterview.Interviewer4__c) {
			if (newInterview.Interviewer4__c != null) {					
				newInterviewers.add(newInterview.Interviewer4__c);
			}
			if (oldInterview.Interviewer4__c != null) {					
				oldInterviewers.add(oldInterview.Interviewer4__c);
			}
		}
		// Interviewer 5
		if (newInterview.Interviewer5__c != oldInterview.Interviewer5__c) {
			if (newInterview.Interviewer5__c != null) {					
				newInterviewers.add(newInterview.Interviewer5__c);
			}
			if (oldInterview.Interviewer5__c != null) {					
				oldInterviewers.add(oldInterview.Interviewer5__c);
			}
		}

		// Considering the case that the Interviewer was removed in one of the field but added in other:
		// If an interviewer is part of the 'new' list, it shouldn't be part of the 'old' list

		Set<Id> oldInterviewersThatShowedUpAsNewAsWell = new Set<Id>();
		for (Id interviewerId : oldInterviewers) {
			if (newInterviewers.contains(interviewerId)) {
				oldInterviewersThatShowedUpAsNewAsWell.add(interviewerId);
			}
		}
		oldInterviewers.removeAll(oldInterviewersThatShowedUpAsNewAsWell);
	}

//------------------------------------------------------------------------------------
	public IFB_InterviewUtils utils;
	public IFB_InterviewUtilsWos utilsWos;

	public IFB_InterviewOpsWos() {
	
	}
	public IFB_InterviewOpsWos(IFB_InterviewUtils utils, IFB_InterviewUtilsWos utilsWos) {
		this.utils = utils;
		this.utilsWos = utilsWos;	
	}

	public List<IFB_Interview__Share> unshareInterviewInterviewerEdit(List<IFB_Interview__c> interviews) {
		
		List<IFB_Interview__Share> interviewShares = [select Id from IFB_Interview__Share
                                           		where ParentId in :interviews
                                           		and AccessLevel = 'Edit' 
                                           		and RowCause = :Schema.IFB_Interview__Share.RowCause.Interviewer__c];
        return interviewShares;             
	}

	public List<IFB_Interview__Share> unshareInterviewInterviewerRead(List<IFB_Interview__c> interviews) {
		
		List<IFB_Interview__Share> interviewShares = [select Id from IFB_Interview__Share
                                           		where ParentId in :interviews
                                           		and AccessLevel = 'Read'
                                           		and RowCause = :Schema.IFB_Interview__Share.RowCause.Feedback_Submitted__c];
                  
        return interviewShares;
	}

	public List<IFB_Interview__Share> unshareInterviewOtherInterviewerRead(List<IFB_Interview__c> interviews) {
		
		List<IFB_Interview__Share> interviewShares = [select Id from IFB_Interview__Share
                                           		where ParentId in :interviews
                                           		and AccessLevel = 'Read'
                                           		and RowCause = :Schema.IFB_Interview__Share.RowCause.Panel_Interviewer__c];
        return interviewShares;             
	}

	public List<IFB_Interview_Candidate__Share> unshareInterviewCandidateInterviewerRead(Set<Id> recruits) {
		
		List<IFB_Interview_Candidate__Share> interviewCandidateShare = [select Id from IFB_Interview_Candidate__Share
                                           		where ParentId in :recruits
                                           		and AccessLevel = 'Read'
                                           		and RowCause = :Schema.IFB_Interview_Candidate__Share.RowCause.Interviewer__c];
        return interviewCandidateShare;             
	}

	public void insertInterviewShares(List<IFB_Interview__Share> interviewShares) {
		insert interviewShares;
	}

	public void deleteInterviewShares(List<IFB_Interview__Share> interviewShares) {
		delete interviewShares;
	}

	public void insertInterviewCandidateShares(List<IFB_Interview_Candidate__Share> interviewCandidateShares) {
		insert interviewCandidateShares;
	}

	public void deleteInterviewCandidateShares(List<IFB_Interview_Candidate__Share> interviewCandidateShares) {
		delete interviewCandidateShares;
	}

	
}