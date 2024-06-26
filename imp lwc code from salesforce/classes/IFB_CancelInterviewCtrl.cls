public with sharing class IFB_CancelInterviewCtrl {

	private static final String STATUS_INTERVIEW_CANCELLED = 'Interview Cancelled';

    private final IFB_Interview__c interview;
    private final ApexPages.StandardController stdController;

    public IFB_CancelInterviewCtrl(ApexPages.StandardController stdController) {
        this.stdController = stdController;
        this.interview = (IFB_Interview__c)this.stdController.getRecord();
    }

    public PageReference cancelInterview() {
        PageReference redirectToPage;

        try {
            this.interview.Status__c = STATUS_INTERVIEW_CANCELLED;
            this.interview.Locked__c = true;
            update this.interview;
            redirectToPage = this.stdController.view();
            // Update has been successful, redirect the user to the detail page of the interview.

        } catch (DmlException ex) {     
            // Update failed, we add the error to the page, and don't redirect the user anywhere.
            String msgStr = Label.SIFT_Cancel_Interview_DML_Exception + ' ' + (ex.getDmlMessage(0) == null ? '' : ex.getDmlMessage(0));
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, msgStr);
            ApexPages.addMessage(msg);
            redirectToPage = null;

        } catch (Exception ex) {
            // Other than the DML operation failed. Display message to the user. Don't redirect the user anywhere.
            String msgStr = Label.SIFT_Cancel_Interview_General_Exception + ' ' + (ex.getMessage() == null ? '' : ex.getMessage());
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, msgStr);
            ApexPages.addMessage(msg);
            redirectToPage = null;
        } 

        return redirectToPage;
    }
}