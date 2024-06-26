public with sharing class IFB_InterviewTriggerHandler {
	//Trigger context variables
	List<IFB_Interview__c> newList;
	Map<Id, IFB_Interview__c> oldMap; 

	//State variables
	public IFB_InterviewUtils utils;
	public IFB_InterviewUtilsWos utilsWos;
	public IFB_InterviewOps ops;
	public IFB_InterviewOpsWos opsWos;
	public IFB_InterviewHandler handler;

	public IFB_InterviewTriggerOpsWos triggerOpsWos;
	public IFB_InterviewRecruitDates recruitDates;
	public IFB_InterviewCreateInProgress interviewCreateInProgress;

	public static IFB_RecruitInterviewRollup recruitInterviewRollup;

	static {
		recruitInterviewRollup = new IFB_RecruitInterviewRollup();
	}
	
	public IFB_InterviewTriggerHandler(List<IFB_Interview__c> newList, Map<Id, IFB_Interview__c> oldMap) {
		this.newList = newList;
		this.oldMap = oldMap;
		
		this.utils = new IFB_InterviewUtils();
		this.utilsWos = new IFB_InterviewUtilsWos();
		this.ops = new IFB_InterviewOps(this.utils, this.utilsWos);
		this.opsWos = new IFB_InterviewOpsWos(this.utils, this.utilsWos);
		this.handler = new IFB_InterviewHandler(this.ops, this.opsWos);

		this.triggerOpsWos = new IFB_InterviewTriggerOpsWos();
		this.recruitDates = new IFB_InterviewRecruitDates(recruitInterviewRollup);
		this.interviewCreateInProgress = new IFB_InterviewCreateInProgress(recruitInterviewRollup);
	}

	public void beforeInsert() {
		this.handler.onInsertUpdateInterview(this.newList, this.oldMap);
	}

	public void beforeUpdate() {
		this.handler.onInsertUpdateInterview(this.newList, this.oldMap);
		this.interviewCreateInProgress.clearOutInProgressInterview(this.newList, true);	
	}

	public void afterInsert() {
		this.triggerOpsWos.afterInsertInterviewSharing(newList);
		this.recruitDates.updateDatesOnRecruit(this.newList);
	}

	public void afterUpdate() {
		this.triggerOpsWos.afterUpdateInterviewSharing(newList, oldMap);
		this.recruitDates.updateDatesOnRecruit(this.newList);

		// Update the Recruit object
		recruitInterviewRollup.updateRecruits();
	}

	public void afterUndelete() {
		this.handler.segregateRecordsByStatus(this.newList, this.oldMap);
		this.handler.handleStatusToNew();
		this.handler.handlesStatusToFeedbackSubmitted();
		
		this.handler.deleteInterviewShares();	
		this.handler.insertInterviewShares();
		this.handler.deleteInterviewCandidateShares();	
		this.handler.insertInterviewCandidateShares();
	}

}