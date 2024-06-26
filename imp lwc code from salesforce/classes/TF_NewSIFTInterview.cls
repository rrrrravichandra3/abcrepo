public with sharing class TF_NewSIFTInterview {

    public final Id applicationId {get; set;}
    public final Id talentforceInterviewId {get; set;}

    // This Controller Extension should be used by Visualforce Pages that have the following standard controllers:
    // - ts2extams__Custom_Stage_1__c (Interview 1)
    // - ts2extams__Custom_Stage_2__c (Interview 2)
    // - ts2extams__Custom_Stage_3__c (Interview 3)

    public TF_NewSIFTInterview(ApexPages.StandardController stdController) {
        
        try {        
            
            // Get the "Related Application" field from the Interview 1, 2 or 3 record.
            // Note that regrardless if this is an extension of the Interview 1, 2 o 3 standard contollers (), 
            // the following fields API names are the same in the 3 objects:
            // - ts2extams__Application__c
            // - ts2extams__Contact__r
            // - ts2extams__Job__r
            this.talentforceInterviewId = stdController.getId();
            this.applicationId = (Id)stdController.getRecord().get('ts2extams__Application__c');

        } catch(Exception ex) {
            String msgStr = 'We could not find the Application record.' + ' ' + (ex.getMessage() == null ? '' : ex.getMessage());
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, msgStr);
            ApexPages.addMessage(msg);
        }   
    }


    public boolean getDoIHaveAccessToNewSIFTInterviewOperation() {
        return (Schema.sObjectType.IFB_Interview__c.isCreateable() && Schema.sObjectType.IFB_Interview__c.isUpdateable());
    }

    public PageReference handleInterviewCreation() {
        PageReference redirectPage = null;
        
        return redirectPage;
    }

}