public with sharing class Acquisition_Offer_Docusign_Controller{

    private Acquisition_Offer__c acquisitionOffer;
    public string acquisitionOfferId {get;set;}
    public string envelopeId{get;set;}
    private Boolean showBackButton = false;
    private Boolean showSendAgainButton = false;
    private Boolean sendAgainAction = false;

    public static String EMPTY_ACQUISITION_ID = Label.Acquisition_Missing_Id_Error;
    public static String EMPTY_ACQUISITION = Label.Acquisition_No_Acq_Offer_Error;
    public static final String ALREADY_SENT = Label.Acquisition_Already_Sent_Error;
    public static final String COMPLETED_ACQUISITION = Label.Acquisition_Completed_Status_Error;
    public static final String EMPTY_RECIPIENT_EMAIL = Label.Acquisition_Email_Missing_Error;
    public static final String WRONG_COUNTRY = Label.Acquisition_Wrong_Country_Error;
    public static final String EMPTY_COUNTRY = Label.Acquisition_Country_Blank_Error;
    public static final String EMPTY_USERNAME = Label.Acquisition_Name_Missing_Error;
    public static final String DEFAULT_ERROR_MESSAGE = Label.Acquisition_Default_Error_Message;

    
    /*********************************************************************************************************************************************/
    
    public Acquisition_Offer_Docusign_Controller(ApexPages.StandardController stdController) {
        this.acquisitionOfferId = stdController.getId();
        init();
    }


    /*********************************************************************************************************************************************/

    public void init(){
        envelopeId = 'Not Sent Yet';
        if(isValidAcquisitionOffer()){
            sendWithTemplates();
          
        }
    }

    /*********************************************************************************************************************************************/
     

     public Boolean isValidAcquisitionOffer(){
        
        showBackButton = true;
        // add multiple if conditions to to validations. return false if any error condition is met  
            String query = Acquisition_Docusign_Util.getQueryFields();
            this.acquisitionOffer = Database.query(query + 'where Id = :acquisitionOfferId limit 1');
            if(acquisitionOffer == null){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, EMPTY_ACQUISITION));
            showBackButton = false;
            showSendAgainButton = false;
            return false;
        }

        //check for any other error condition (missing fields) and display proper error
        if(acquisitionOffer.Office_Country__c == null 
           ||
           acquisitionOffer.Employee_Personal_Email__c == null
           ||
           acquisitionOffer.Last_Name_Legal__c == null
           ||
           acquisitionOffer.First_Name_Legal__c == null
          ){
            if(acquisitionOffer.Office_Country__c == null) {ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, EMPTY_COUNTRY));}
            if(acquisitionOffer.Employee_Personal_Email__c == null) {ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, EMPTY_RECIPIENT_EMAIL));}
            if((acquisitionOffer.Last_Name_Legal__c == null) || (acquisitionOffer.First_Name_Legal__c == null)) {ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, EMPTY_USERNAME));}
            showBackButton = true;
            showSendAgainButton = false;
            return false;
        }

        
        if  ((acquisitionOffer.Current_DocuSign__c!=null) && (acquisitionOffer.Current_DocuSign__c.equalsIgnoreCase('Completed'))) {
            if(sendAgainAction == false){
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, COMPLETED_ACQUISITION));
                showSendAgainButton = true;
                showBackButton = true;
                return false;
            }
            else{
                showSendAgainButton = false;
                showBackButton = true;
                return true;
            }
            
        }else if((acquisitionOffer.Current_DocuSign__c!=null) && (acquisitionOffer.Current_DocuSign__c.equalsIgnoreCase('Sent') || acquisitionOffer.Current_DocuSign__c.equalsIgnoreCase('Delivered'))) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ALREADY_SENT));
            showSendAgainButton = false;
            showBackButton = true;
            return false;
        }

        return true;
    }

    /*********************************************************************************************************************************************/

    public PageReference backToAcquisition(){
        return new PageReference('/'+acquisitionOfferId);
    }

    /*********************************************************************************************************************************************/

    public void sendAgain(){
        sendAgainAction = true;
        showSendAgainButton = false;
        init();
    }

    /*********************************************************************************************************************************************/

    public Boolean getshowBackButton(){
        return showBackButton;
    }

    /*********************************************************************************************************************************************/

    public Boolean getShowSendAgainButton(){
        return showSendAgainButton;
    }

    /*********************************************************************************************************************************************/
    
    public void sendWithTemplates(){
        
        try{
        esdsext.DocuSignAPI.EnvelopeInformation envelope = new esdsext.DocuSignAPI.EnvelopeInformation();
        

        

        esdsext.DocuSignAPI.ArrayOfTemplateReference templateReferences = new   esdsext.DocuSignAPI.ArrayOfTemplateReference();
        List<esdsext.DocuSignAPI.TemplateReference> templates2Send = new List<esdsext.DocuSignAPI.TemplateReference>();
        
        DocuSignAcquisitionBaseCountry docusign = Acquisition_Docusign_Util.getDocusignObject(this.acquisitionOffer);

        if(docusign == null){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, WRONG_COUNTRY));
            return;
        }

        
        templates2Send = docusign.collectAllTemplates();
        

        templateReferences.TemplateReference = new  esdsext.DocuSignAPI.TemplateReference[templates2Send.size()];
        Integer count = 0;
        for(esdsext.DocuSignAPI.TemplateReference template :templates2Send ){
            templateReferences.TemplateReference[count] = template;
            count++;
        }
        
        envelope.Subject = docusign.getSubject();
        envelope.EmailBlurb = docusign.getEmailBlurb();

        envelope.CustomFields = new esdsext.DocuSignAPI.ArrayOfCustomField();
        envelope.CustomFields.CustomField = new esdsext.DocuSignAPI.CustomField[2];
        
        esdsext.DocuSignAPI.CustomField myCustomField = new esdsext.DocuSignAPI.CustomField();
        myCustomField.Name = 'DSFSSourceObjectId';
        myCustomField.Value = acquisitionOfferId+'~Acquisition_Offer__c';
        myCustomField.Show = 'False';
        myCustomField.Required = 'False';
        myCustomField.CustomFieldType = 'Text';
        envelope.CustomFields.CustomField[0] = myCustomField;
        envelopeId = esdsext.SendToDocuSignController.sendOfferWithTemplates(templateReferences, getSigners(), envelope);
        }
        catch(Exception e){
            String exceptionErrorMessage = e.getMessage();
            String displayMessage = DEFAULT_ERROR_MESSAGE+'\r\n'+exceptionErrorMessage;
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, displayMessage));
        }        
    }
    

    public esdsext.DocuSignAPI.ArrayOfRecipient1 getSigners() {
        
        
        esdsext.DocuSignAPI.ArrayOfRecipient1 signers = new esdsext.DocuSignAPI.ArrayOfRecipient1();
        signers.Recipient = new esdsext.DocuSignAPI.Recipient[1];
        signers.Recipient[0] = getAcqRecipient();
        return signers;
    }

    public esdsext.DocuSignAPI.Recipient getAcqRecipient() {
            esdsext.DocuSignAPI.Recipient acqRecipient = new esdsext.DocuSignAPI.Recipient();
            if(acquisitionOffer.Employee_Personal_Email__c == null){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, EMPTY_RECIPIENT_EMAIL));
            return null;
        } else {
            acqRecipient.ID = 1;
            acqRecipient.Type_x = 'Signer';
            acqRecipient.RoutingOrder = 1;
            acqRecipient.Email = acquisitionOffer.Employee_Personal_Email__c;
            acqRecipient.UserName = acquisitionOffer.First_Name_Legal__c + ' ' + acquisitionOffer.Last_Name_Legal__c;
            acqRecipient.RoleName = 'Docusign Signer';
            acqRecipient.RequireIDLookup = false;      
        }
        return acqRecipient;
    }
}