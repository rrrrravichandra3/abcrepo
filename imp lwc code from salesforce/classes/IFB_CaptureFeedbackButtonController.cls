public with sharing class IFB_CaptureFeedbackButtonController {

    public final IFB_Interview__c interview{get; private set;}
    public String cancelInterviewExceptionMessage {get; set;}
    
    public Boolean isCaptureFeedbackButtonVisible{
        get{
            
            if(isCaptureFeedbackButtonVisible == null){

                Boolean userIsInterviewer;
                
                if (interview.Interviewer__c  == UserInfo.getUserId() ||
                    interview.Interviewer2__c == UserInfo.getUserId() ||
                    interview.Interviewer3__c == UserInfo.getUserId() ||
                    interview.Interviewer4__c == UserInfo.getUserId() ||
                    interview.Interviewer5__c == UserInfo.getUserId()) {
                    userIsInterviewer = true;
                } else {
                    userIsInterviewer = false;
                }

                isCaptureFeedbackButtonVisible = (userIsInterviewer || SIFT_Settings__c.getInstance().Capture_Feedback_Override__c) && (interview.Status__c == 'New' || interview.Status__c == 'Feedback in progress')
                    && !interview.Locked__c;
            }
            
            return isCaptureFeedbackButtonVisible;
        }
        private set;
    }
    
    public String captureFeedbackURL{
        get{
            if(captureFeedbackURL == null){
                captureFeedbackURL = 'window.top.location=\'/apex/IFB_CaptureFeedbackLightning?id=' + interview.Id + '\'';
            }
            return captureFeedbackURL;
        }
        private set;
    }


    // Updates the 'SIFT Inteview' record so it is marked as cancelled.
    // In case of an exception, we set the 'cancelInterviewExceptionMessage' property
    // that is used in the client side to pop-up an message (alert) to the user
    public PageReference cancelInterview() {
        try {
             
            if (IFB_AccessibilityUtils.checkFLS('IFB_Interview__c',
                    IFB_AccessibilityUtils.PermissionType.UPDATEABLE,
                    new List<String> {'Status__c', 'Locked__c'})) {
                this.interview.Status__c = 'Interview Cancelled';
                this.interview.Locked__c = true;
                update this.interview; 
            } else {
                throw new PF_SecurityCheckException(Label.SIFT_Exception_Update_IFB_Interview);
            }           

        } catch (DMLException ex) {
            this.cancelInterviewExceptionMessage = ex.getDmlMessage(0);
        } catch (Exception ex) {
            this.cancelInterviewExceptionMessage = ex.getMessage();
        }
        
        return null;
    }
    
    public IFB_CaptureFeedbackButtonController(ApexPages.StandardController stdController){
        interview = [SELECT Interviewer__c, Interviewer2__c, Interviewer3__c, Interviewer4__c, Interviewer5__c,
                    Status__c, Locked__c FROM IFB_Interview__c WHERE Id = :((IFB_Interview__c)stdController.getRecord()).Id];
    }
    
}