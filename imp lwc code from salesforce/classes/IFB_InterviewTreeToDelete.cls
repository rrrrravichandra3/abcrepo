public with sharing class IFB_InterviewTreeToDelete {
	
	public Id interview {get; set;}
 	public Id recruit {get; set;} 
 	public Set<Id> questions {get; set;}
 	public IFB_InterviewOpsWos.ApexSharingReason sharingReason {get; set;}
 	public Set<Id> usersOrGroup  {get; set;}

	public IFB_InterviewTreeToDelete(Id interview,
									 Id recruit, 
									 Set<Id> questions, 
									 IFB_InterviewOpsWos.ApexSharingReason sharingReason,
									 Set<Id> usersOrGroup) {
		this.interview = interview;
		this.recruit = recruit;
		this.questions = questions;
		this.sharingReason = sharingReason;
		this.usersOrGroup = usersOrGroup;
	}

	public static List<IFB_InterviewTreeToDelete> listOfTrees= new List<IFB_InterviewTreeToDelete>();
	public static Set<Id> interviewScope = new Set<Id>();
	public static Set<Id> recruitScope = new Set<Id>();
	public static Set<Id> questionsScope = new Set<Id>();
	public static Set<String> sharingReasonStringsScope = new Set<String>();
	public static Set<Id> userOrGroupIdsScope = new Set<Id>();
	public static Set<Id> interviewersScope = new Set<Id>();
	public static Set<Id> hiringManagerScope = new Set<Id>();

	public static void addInterviewTree(Id interview,
								   Id recruit, 
								   Set<Id> questions, 
								   IFB_InterviewOpsWos.ApexSharingReason sharingReason,
								   Set<Id> usersOrGroup) {

		listOfTrees.add(new IFB_InterviewTreeToDelete(interview, recruit, questions, sharingReason, usersOrGroup));
		interviewScope.add(interview);
		recruitScope.add(recruit);
		if(questions != null) {
			questionsScope.addAll(questions);	
		}
		if (sharingReason == IFB_InterviewOpsWos.ApexSharingReason.INTERVIEWER) {
			sharingReasonStringsScope.add('Interviewer__c');
			interviewersScope.addAll(usersOrGroup);
		} else if (sharingReason == IFB_InterviewOpsWos.ApexSharingReason.HIRING_MANAGER) {
			sharingReasonStringsScope.add('Hiring_Manager__c');
			hiringManagerScope.addAll(usersOrGroup);
		} else if (sharingReason == IFB_InterviewOpsWos.ApexSharingReason.PANEL_INTERVIEWER) {
			sharingReasonStringsScope.add('Panel_Interviewer__c');
		} else if (sharingReason == IFB_InterviewOpsWos.ApexSharingReason.HIRING_ORGANIZATION){
			sharingReasonStringsScope.add('Hiring_Organization__c');
		}

		userOrGroupIdsScope.addAll(usersOrGroup);	
	}
}