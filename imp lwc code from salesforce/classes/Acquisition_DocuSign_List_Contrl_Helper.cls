public with sharing class Acquisition_DocuSign_List_Contrl_Helper{

    public String envelopeId = 'Not Sent Yet';
    public Acquisition_Offer__c acquisitionOffer = new Acquisition_Offer__c();

    public String processAcquisitionOffer(Acquisition_Offer__c currentAcqOffer){

                this.acquisitionOffer = currentAcqOffer;

                //enter all the criterias which stops docusign 
                if(
                    acquisitionOffer.Office_Country__c == null 
                    ||
                    acquisitionOffer.Employee_Personal_Email__c == null
                    ||
                    acquisitionOffer.Last_Name_Legal__c == null
                    ||
                    acquisitionOffer.First_Name_Legal__c == null
                    ||
                    ((acquisitionOffer.Current_DocuSign__c!=null) && (Label.Acquisition_List_Skip_Statuses).contains(acquisitionOffer.Current_DocuSign__c))
                  ){
                    return null;
                } 

                try{

                        esdsext.DocuSignAPI.EnvelopeInformation envelope = new esdsext.DocuSignAPI.EnvelopeInformation();

                        esdsext.DocuSignAPI.ArrayOfTemplateReference templateReferences = new   esdsext.DocuSignAPI.ArrayOfTemplateReference();
                        List<esdsext.DocuSignAPI.TemplateReference> templates2Send = new List<esdsext.DocuSignAPI.TemplateReference>();

                        DocuSignAcquisitionBaseCountry docusign = Acquisition_Docusign_Util.getDocusignObject(this.acquisitionOffer);

                        if(docusign == null) {return null;}

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
                        myCustomField.Value = this.acquisitionOffer.Id +'~Acquisition_Offer__c';
                        myCustomField.Show = 'False';
                        myCustomField.Required = 'False';
                        myCustomField.CustomFieldType = 'Text';
                        envelope.CustomFields.CustomField[0] = myCustomField;
                        envelopeId = esdsext.SendToDocuSignController.sendOfferWithTemplates(templateReferences, getSigners(), envelope);

            
                        return envelopeId;
                }
                catch(Exception e){
                       return null;
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
                acqRecipient.ID = 1;
                acqRecipient.Type_x = 'Signer';
                acqRecipient.RoutingOrder = 1;
                acqRecipient.Email = this.acquisitionOffer.Employee_Personal_Email__c;
                acqRecipient.UserName = this.acquisitionOffer.First_Name_Legal__c + ' ' + this.acquisitionOffer.Last_Name_Legal__c;
                acqRecipient.RoleName = 'Docusign Signer';
                acqRecipient.RequireIDLookup = false; 
                return acqRecipient;     
            
        
    }

}