public with sharing class TF_SIFTInterviewsIntCtrl extends TF_SIFTInterviewsBaseCtrl {
	
	public TF_SIFTInterviewsIntCtrl(ApexPages.StandardController stdController) {
        
        try {        
    		// Get the "Related Application" and related "SIFT Recruit" fields from the Interview 1, 2 or 3 record
            // Note that regrardless if this is an extension of the Interview 1, 2 o 3 standard contollers  
            // the following fields API names are the same in the 3 objects:
            // - ts2extams__Application__r.SIFT_Recruit__c
            this.recruitId = (Id)stdController.getRecord().getSobject('ts2extams__Application__r').get('SIFT_Recruit__c');
            System.debug('recruitId: ' + recruitId);


        } catch(Exception ex) {
            String msgStr = 'We could not get the Recruit Id.' + ' ' + (ex.getMessage() == null ? '' : ex.getMessage());
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, msgStr);
            ApexPages.addMessage(msg);
        }   
    }
}