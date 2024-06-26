public with sharing class TF_SIFTInterviewsAppCtrl extends TF_SIFTInterviewsBaseCtrl {

    public TF_SIFTInterviewsAppCtrl(ApexPages.StandardController stdController) {
        
        try {        
    
            this.recruitId = (Id)stdController.getRecord().get('SIFT_Recruit__c');
            System.debug('recruitId: ' + recruitId);

        } catch(Exception ex) {
            String msgStr = 'We could not get the Recruit Id.' + ' ' + (ex.getMessage() == null ? '' : ex.getMessage());
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, msgStr);
            ApexPages.addMessage(msg);
        }   
    }
}