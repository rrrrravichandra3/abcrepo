public with sharing class IFB_CaptureFeedbackLtngBtnController {

	@AuraEnabled
	public static CaptureFeedbackAndCancelInteriviewVisibility getButtonsVisibility(String interviewId){
        List<IFB_Interview__c> interview = [SELECT Interviewer__c, Interviewer2__c, Interviewer3__c, Interviewer4__c, Interviewer5__c, Status__c, Locked__c FROM IFB_Interview__c WHERE Id =: interviewId];
        Boolean userIsInterviewer;
        
        if(interview.size() == 1){
            if (interview[0].Interviewer__c  == UserInfo.getUserId() ||
                interview[0].Interviewer2__c == UserInfo.getUserId() ||
                interview[0].Interviewer3__c == UserInfo.getUserId() ||
                interview[0].Interviewer4__c == UserInfo.getUserId() ||
                interview[0].Interviewer5__c == UserInfo.getUserId()) {
                userIsInterviewer = true;
            } else {
                userIsInterviewer = false;
            }
            Boolean iscaptureBtnVisible = (userIsInterviewer || SIFT_Settings__c.getInstance().Capture_Feedback_Override__c) && (interview[0].Status__c == 'New' || interview[0].Status__c == 'Feedback in progress') && !interview[0].Locked__c;
            List<CustomPermission> cancelIntCustPerm = [select Id, DeveloperName from CustomPermission where DeveloperName = 'SIFT_Cancel_Interview'];
            List<SetupEntityAccess> setupEntities = [SELECT SetupEntityId FROM SetupEntityAccess WHERE SetupEntityId =: cancelIntCustPerm[0].Id AND ParentId IN (SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId())];
            Boolean iscancelBtnVisible = (setupEntities.size()>0 && interview[0].Status__c != 'Incomplete' && interview[0].Status__c != 'Interview Cancelled');
            Boolean isSIFTIntUncompleted = (interview[0].Locked__c && interview[0].Status__c == 'Incomplete');
            Boolean isSIFTIntCancelled = (interview[0].Locked__c && interview[0].Status__c == 'Interview Cancelled');

            return new CaptureFeedbackAndCancelInteriviewVisibility(iscaptureBtnVisible, iscancelBtnVisible, isSIFTIntUncompleted, isSIFTIntCancelled);
        }
        else{
            return null;
        }
    }

    @AuraEnabled
    public static Boolean cancelSIFTInterview(String interviewId) {
        try {

            if (IFB_AccessibilityUtils.checkFLS('IFB_Interview__c',
                    IFB_AccessibilityUtils.PermissionType.UPDATEABLE,
                    new List<String> {'Status__c', 'Locked__c'})) {
                List<IFB_Interview__c> interview = [SELECT Status__c, Locked__c FROM IFB_Interview__c WHERE Id =: interviewId];
                interview[0].Status__c = 'Interview Cancelled';
                interview[0].Locked__c = true;
                Boolean isCancelled = false;
                update interview;
                isCancelled = true;
                return isCancelled;
            } else {
                throw new PF_SecurityCheckException(Label.SIFT_Exception_Update_IFB_Interview);
            }           

        } catch (DMLException ex) {
            throw new AuraHandledException(ex.getDmlMessage(0));
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public class CaptureFeedbackAndCancelInteriviewVisibility{
        @AuraEnabled
        public Boolean isCaptureFeedbackButtonVisible;
        @AuraEnabled
        public Boolean isCancelInterviewButtonVisible;
        @AuraEnabled
        public Boolean isSIFTInterviewUncompleted;
        @AuraEnabled
        public Boolean isSIFTInterviewCancelled;

        public CaptureFeedbackAndCancelInteriviewVisibility(Boolean isCaptureFeedbackButtonVisible, Boolean isCancelInterviewButtonVisible, Boolean isSIFTInterviewUncompleted, Boolean isSIFTInterviewCancelled){
            this.isCaptureFeedbackButtonVisible = isCaptureFeedbackButtonVisible;
            this.isCancelInterviewButtonVisible = isCancelInterviewButtonVisible;
            this.isSIFTInterviewUncompleted = isSIFTInterviewUncompleted;
            this.isSIFTInterviewCancelled = isSIFTInterviewCancelled;
        }
    }

	public IFB_CaptureFeedbackLtngBtnController() {
	}

}