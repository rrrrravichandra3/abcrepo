public with sharing class IFB_InterviewOverrideNewController {    

	private final IFB_Interview__c interview;
    private static final String metadatabaseURL;
     private static final String metadataInterviewObjectPrefix;
     private static final String metadataInterviewObjectId;
     private static final String intvDefaultRecTypeId;
    
    /**
     * metadatabaseURL: This is the salesforce.com base url of the org. E.g. (.pfdev): 'https://dreamjobcentral--pfdev.cs1.my.salesforce.com/
     * metadataInterviewObjectPrefix: This the 3 letter object prefix of the IFB_Interview__c object. E.g (.pfdev): 'a4a'
     * metadataInterviewCandidateFieldId: This is the salesforce.com field Id of the IFB_Interview__c.Candidate__c field. Eg. (.pfdev): 'CF00NS0000001QQWB'
     * metadataInterviewObjectId: This is the salesforce.com Id field of the IFB_Interview__c object.  Eg. (.pfdev): '01IS00000001TEB'
     */

    static {
        metadatabaseURL = IFB_SIFT_Settings_List__c.getInstance('SIFT').Base_URL__c;
        metadataInterviewObjectPrefix = IFB_ObjectDescribe.getObjectPrefix('IFB_Interview__c');
        metadataInterviewObjectId = IFB_SIFT_Settings_List__c.getInstance('SIFT').Interview_Object_Id__c;
        intvDefaultRecTypeId = String.ValueOf(Schema.SObjectType.IFB_Interview__c.getRecordTypeInfosByName().get('Default').getRecordTypeId());
    }

    public IFB_InterviewOverrideNewController(ApexPages.StandardController stdController) {
        this.interview = (IFB_Interview__c) stdController.getRecord();
    }

    // User should use the 'New SIFT Interview' button on the 'WD Job Application' record
    // If you have the right permissions (sys admins) you can still use the standard page layout to create the SIFT Interview
    public ApexPages.PageReference redirectToUserToMessage() {
        ApexPages.PageReference pageToRedirectTo = Page.IFB_StandardNewSIFTInterviewRedirect;

        if (SIFT_Settings__c.getInstance().Allow_New_SIFT_Interview_standard_action__c == 'YES') {
            //give them standard blank page
            String standardNewInterviewPage = '/'+metadataInterviewObjectPrefix+'/e?%2F'+metadataInterviewObjectPrefix+'%2Fo&RecordType='+intvDefaultRecTypeId+'&ent='+metadataInterviewObjectId;
            pageToRedirectTo = new PageReference(standardNewInterviewPage);
            pageToRedirectTo.getParameters().put('nooverride','1');
        }

        return pageToRedirectTo;
    }
}