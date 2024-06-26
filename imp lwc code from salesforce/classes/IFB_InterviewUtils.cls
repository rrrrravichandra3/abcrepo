public with sharing class IFB_InterviewUtils {
  
    public static boolean isInterviewAccessible(){
        return IFB_AccessibilityUtils.checkFLS('IFB_Interview__c', IFB_AccessibilityUtils.PermissionType.ACCESSIBLE,
                                           new List<String> {'Name','Candidate__c','Interviewer__c','Interviewer2__c','Interviewer3__c',
                                               'Interviewer4__c','Interviewer5__c','Interview_Format__c','No_Show__c',
                                               'Scheduled_Interview_Date__c', 'Actual_Interview_Date__c', 'Recommendation__c','Comments__c', 'Status__c', 'Locked__c'})
          && IFB_AccessibilityUtils.checkFLS('IFB_Interview_Candidate__c', IFB_AccessibilityUtils.PermissionType.ACCESSIBLE,
                                           new List<String> {'Name','Email__c','City__c','State__c'})
          && IFB_AccessibilityUtils.checkFLS('User', IFB_AccessibilityUtils.PermissionType.ACCESSIBLE,
                                           new List<String> {'Name'});
    }
    
    public static boolean isInterviewUpdateable(){
        return IFB_AccessibilityUtils.checkFLS('IFB_Interview__c', IFB_AccessibilityUtils.PermissionType.UPDATEABLE,
                                               new List<String> {'Actual_Interview_Date__c','No_Show__c','Recommendation__c','Comments__c','Overall_Interview_Score__c'
                                                   });
    }
    
    public static boolean isEvaluationUpdateable(){
        return IFB_AccessibilityUtils.checkFLS('IFB_Interview_Evaluation__c', IFB_AccessibilityUtils.PermissionType.UPDATEABLE,
                                           new List<String> {'Comments__c','Score__c','Skipped__c'});
    }
    
    public static boolean isQuestionAccessible(){
        return IFB_AccessibilityUtils.checkFLS('IFB_Interview_Question__c', IFB_AccessibilityUtils.PermissionType.ACCESSIBLE,
                                           new List<String> {'Active__c','Competency__c','Question__c', 'Rating1_Definition__c',
                                               'Rating2_Definition__c', 'Rating3_Definition__c', 'Rating4_Definition__c'});
    }

    //method to populate recruiter info 
    //enhancement to have the query in the util class, if params are changing
    public static Id getRecruiterforInterview(boolean internalCandidate,Id internalRecruiter1,Id internalRecruiter2,Id externalRecruiter1,Id externalRecruiter2){
		
		if(internalCandidate){
			    if(internalRecruiter1!=null) return internalRecruiter1;
				else if(internalRecruiter2!=null) return internalRecruiter2;
				else if(externalRecruiter1!=null) return externalRecruiter1;
                else if(externalRecruiter2!=null) return externalRecruiter2;
                else return null;
			}
			else {
				if(externalRecruiter1!=null) return externalRecruiter1;
				else if(externalRecruiter2!=null) return externalRecruiter2;
				else if(internalRecruiter1!=null) return internalRecruiter1;
                else if(internalRecruiter2!=null) return internalRecruiter2;
                else return null;
			}
		}
		
}