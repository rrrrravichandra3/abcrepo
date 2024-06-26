public abstract with sharing class DocuSignAcquisitionBaseCountry{

    protected Acquisition_Offer__c acquisitionOffer;

    protected List<esdsext.DocusignAPI.TemplateReferenceFieldDataDataValue> dataValueList = new List<esdsext.DocusignAPI.TemplateReferenceFieldDataDataValue>();
    protected List<esdsext.DocusignAPI.TemplateReference> templateList = new List<esdsext.DocusignAPI.TemplateReference>();

    static Map<String, String> templateCodeToIdMap = new Map<String,String>();

    static{
        List<Acquisition_Offer_Template__c> allAcqTemplates = [Select Country_ISO_Code__c, External_ID__c, Template_ID__c from Acquisition_Offer_Template__c];
        for(Acquisition_Offer_Template__c currentTemplate : allAcqTemplates){
            String uniqueId = currentTemplate.External_ID__c + currentTemplate.Country_ISO_Code__c;
            templateCodeToIdMap.put(uniqueId, currentTemplate.Template_ID__c);
        }
    }

    
    /* Controllers call this method after initializing a country specific docusign*/
    public void setAcquisitionOffer(Acquisition_Offer__c acq){
        this.acquisitionOffer = acq;
        addTagsToDataValue();
    }



    public void addTagsToDataValue(){

        //Add all the tags used in templates. Make sure to query them in controller
        
        //Date fields     
        addDateDataValueList('Candidate Continuous Service Date',this.acquisitionOffer.Continuous_Service_Date__c);
        addDateDataValueList('Planned Start Date',this.acquisitionOffer.Hire_Date__c);
        addDateDataValueList('Planned End Date',this.acquisitionOffer.Planned_End_Date__c);
        addDateDataValueList('Offer Date',this.acquisitionOffer.Offer_Date__c);
        addDateDataValueList('Offer Expiration Date',this.acquisitionOffer.Offer_Expiration_Date__c);
        addDateDataValueList('Probation Start Date',this.acquisitionOffer.Probation_Start_Date__c);
        addDateDataValueList('Probation End Date',this.acquisitionOffer.Probation_End_Date__c);

        //Currency fields
        addCurrencyDataValueList('Acq Employee Salary',this.acquisitionOffer.Base_Salary__c);
        addCurrencyDataValueList('Acq Employee RSU',this.acquisitionOffer.RSU_Amount__c);
        addCurrencyDataValueList('Target Variable Amount',this.acquisitionOffer.Target_Variable_Amount__c);
        addCurrencyDataValueList('Draw Amount',this.acquisitionOffer.Draw_Amount__c);
        addCurrencyDataValueList('Sign on Bonus',this.acquisitionOffer.Sign_On_Bonus__c);
        addCurrencyDataValueList('Acq Employee Sign On Bonus',this.acquisitionOffer.Sign_On_Bonus__c);
        addCurrencyDataValueList('On Target Earning',this.acquisitionOffer.On_Target_Earnings__c);
        addCurrencyDataValueList('Acq Employee OT',this.acquisitionOffer.Overtime_OT__c);
        addCurrencyDataValueList('Acq Employee DT',this.acquisitionOffer.Double_TIme_DT__c);
        addCurrencyDataValueList('Acq Employee Stock',this.acquisitionOffer.Stock_Grant_Amount__c);
        addCurrencyDataValueList('Acq Employee Hourly Rate',this.acquisitionOffer.Hourly_Rate__c);
        addCurrencyDataValueList('Acq Employee Non-Exempt Salary',this.acquisitionOffer.Acq_Non_Exempt_Salary__c);
        addCurrencyDataValueList('Acq Employee Car Amount',this.acquisitionOffer.Car_Allowance_Amount__c);
        addCurrencyDataValueList('Acq Employee Relocation',this.acquisitionOffer.Relocation_Allowance__c);
        
        //Percentage fields
        addPercentDataValueList('Acq Employee Bonus Target %',this.acquisitionOffer.Bonus_Target__c);

    }

    /***********  Methods to format currency, date and percent fields **************/

    public void addDateDataValueList(String tagName, Date dateValue){
        if(dateValue == null){
            return;
        }
        esdsext.DocuSignAPI.TemplateReferenceFieldDataDataValue dataValue = new esdsext.DocuSignAPI.TemplateReferenceFieldDataDataValue();
        dataValue.TabLabel = tagName;
        dataValue.Value = '';
        //call override method to format the date
        dataValue.Value = getFormattedDate(dateValue);
        //add the tag to the envelope
        dataValueList.add(dataValue);
    }

    public void addCurrencyDataValueList(String tagName, Decimal currencyValue){
        if(currencyValue == null){
            return;
        }
        esdsext.DocuSignAPI.TemplateReferenceFieldDataDataValue dataValue = new esdsext.DocuSignAPI.TemplateReferenceFieldDataDataValue();
        dataValue.TabLabel = tagName;
        dataValue.Value = '';
        //call override method to format the date
        dataValue.Value = getFormattedCurrency(currencyValue);
        //add the tag to the envelope
        dataValueList.add(dataValue);
    }

    public void addPercentDataValueList(String tagName, Decimal percentValue){
        if(percentValue == null){
            return;
        }
        esdsext.DocuSignAPI.TemplateReferenceFieldDataDataValue dataValue = new esdsext.DocuSignAPI.TemplateReferenceFieldDataDataValue();
        dataValue.TabLabel = tagName;
        dataValue.Value = '';
        //call override method to format the date
        dataValue.Value = getFormattedPercent(percentValue);
        //add the tag to the envelope
        dataValueList.add(dataValue);
    }

    /*********** End of formatting methods **************/

    

    protected String getTemplateId(String ExternalId, String CountryISOCode){
        if(templateCodeToIdMap.containsKey(ExternalId + CountryISOCode)){
            return templateCodeToIdMap.get(ExternalId + CountryISOCode);
        }
        else{
            return null;
        }
    }



    protected void addTemplate(String templateId){
        if(templateId == null){
            return;
        }

        esdsext.DocuSignAPI.TemplateReference template = setUpTemplate(templateId);
        if(template !=null){
            templateList.add(template);
        }
    }

    public esdsext.DocuSignAPI.TemplateReference setUpTemplate(String templateId){
        esdsext.DocuSignAPI.TemplateReference template = new esdsext.DocuSignAPI.TemplateReference();
        template.Template = templateId;

        //template location
        template.TemplateLocation = 'Server';

        //signer details
        String fullName = acquisitionOffer.First_Name_Legal__c + ' ' + acquisitionOffer.Last_Name_Legal__c;
        esdsext.DocuSignAPI.Recipient acqRecipient = getAcquisitionRecipient(acquisitionOffer.Employee_Personal_Email__c, fullName, 'Docusign Signer');
        esdsext.DocuSignAPI.TemplateReferenceRoleAssignment acqRecipientRoleAssignment = new esdsext.DocuSignAPI.TemplateReferenceRoleAssignment();
        acqRecipientRoleAssignment.RoleName = acqRecipient.RoleName;
        acqRecipientRoleAssignment.RecipientID = acqRecipient.ID;

        template.RoleAssignments = new esdsext.DocuSignAPI.ArrayOfTemplateReferenceRoleAssignment();
        template.RoleAssignments.RoleAssignment = new esdsext.DocuSignAPI.TemplateReferenceRoleAssignment[1];
        template.RoleAssignments.RoleAssignment[0] = acqRecipientRoleAssignment;

         
        template.FieldData = new esdsext.DocuSignAPI.TemplateReferenceFieldData();
        template.FieldData.DataValues = new esdsext.DocuSignAPI.ArrayOfTemplateReferenceFieldDataDataValue();
        template.FieldData.DataValues.DataValue = new esdsext.DocuSignAPI.TemplateReferenceFieldDataDataValue[dataValueList.size()];       
        for(Integer i=0;i<dataValueList.size();i++){

            template.FieldData.DataValues.DataValue[i] = dataValueList.get(i);
        }


        return template;
    }

    public esdsext.DocuSignAPI.Recipient getAcquisitionRecipient(String email, String fullName, String roleType) {
        esdsext.DocuSignAPI.Recipient acqRecipient = new esdsext.DocuSignAPI.Recipient();
        acqRecipient.ID = 1;
        acqRecipient.Type_x = 'Signer';
        acqRecipient.RoutingOrder = 1;
        acqRecipient.Email = email; 
        acqRecipient.UserName = fullName;
        acqRecipient.RoleName = roleType;
        acqRecipient.RequireIDLookup = false;  
        return acqRecipient;   
    }

    public abstract String getFormattedCurrency(Decimal currencyValue);

    public abstract String getFormattedDate(Date dateValue);

    public abstract String getFormattedPercent(Decimal percentValue);

    public abstract List<esdsext.DocuSignAPI.TemplateReference> collectAllTemplates();

    public abstract String getSubject();

    public abstract String getEmailBlurb();

}