/**
 * W-13465459
 * Extends MA_DS_AbstractCalloutRequestParams class to Serialize value of Params attribute for the Package Delivery API callout.
 * 
 * Version      Date            Author                  Description
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         27/05/2023      Chakshu Malhotra        W-13465459 - Adds logic to convert MA_DS_PackageDeliveryWrapper.PackageDeliveryParams to an accepted format of Package Delivery API callout.
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_PackageDeliveryCalloutRequestParam extends MA_DS_AbstractCalloutRequestParams {
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to convert the requestParams & wrap it in a ParamsWrapper instance, as per the accepted Payload format for the Package Delivery API Request.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    requestParams	    DESCRIPTION (Data Type MA_DS_CalloutFramework.RequestParams , RequestParams type Params that need to be added in the API callout payload)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void deserializeParams(MA_DS_CalloutFramework.RequestParams requestParams) {
        this.requestParams = requestParams;
        MA_DS_PackageDeliveryWrapper.PackageDeliveryParams packageDeliveryParams = (MA_DS_PackageDeliveryWrapper.PackageDeliveryParams)requestParams;

        ParamsWrapper wrapperInstance = new ParamsWrapper();
        wrapperInstance.CommonInformation = getCommonInformationWrapper(packageDeliveryParams.commonId, packageDeliveryParams.firstBatch, packageDeliveryParams.finalBatch, packageDeliveryParams.singleContactDelivery, packageDeliveryParams.acqCompany, packageDeliveryParams.customDeliveryEmailMap);
        wrapperInstance.BackgroundEmailTemplates = getTemplatesWrapper(packageDeliveryParams.bgcEmailTemplates);
        wrapperInstance.PackageRecipients = getPackageRecipientsWrapper(packageDeliveryParams.acqContacts, packageDeliveryParams.sortOrderMap);

        super.deserializedParams = JSON.deserializeUntyped(JSON.serialize(wrapperInstance));
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create & wrap Batch details, Acquisition Company & Package Distribution details of the payload within CommonInformationWrapper instance, based on the details in "requestParams".
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    commonId	                        DESCRIPTION (Data Type Id, Common Id used across all payloads of Package Delivery API request)
    * @param    firstBatch	                        DESCRIPTION (Data Type Boolean, True if the payload is the First Batch being processed)
    * @param    finalBatch	                        DESCRIPTION (Data Type Boolean, True if the payload is the Final Batch being processed)
    * @param    singleContactDelivery               DESCRIPTION (Data Type Boolean, True if the payload is for the Single Contact Package Delivery)
    * @param    acqCompany	                        DESCRIPTION (Data Type Acquisition_Company__c, Acquisition Company record)
    * @param    customDeliveryEmailMap	            DESCRIPTION (Data Type Map<Id, Boolean>, Map of Package Distribution Id to "Custom Package Envelope Email" flag)
    * @return   CommonInformationWrapper            DESCRIPTION (return CommonInformationWrapper instance containing Batch details, Acquisition Company & Package Distribution details)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static CommonInformationWrapper getCommonInformationWrapper(Id commonId, Boolean firstBatch, Boolean finalBatch, Boolean singleContactDelivery, Acquisition_Company__c acqCompany, Map<Id, Boolean> customDeliveryEmailMap) {
        CommonInformationWrapper commonInformationWrapper = new CommonInformationWrapper();
        commonInformationWrapper.Batch = getBatchWrapper(commonId, firstBatch, finalBatch, singleContactDelivery);
        commonInformationWrapper.AcquisitionCompany = getAcquisitionCompanyWrapper(acqCompany);
        commonInformationWrapper.PackageDistributions = getDistributionsWrapper(customDeliveryEmailMap);
        return commonInformationWrapper;
    }
    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create & wrap Common Id & Batch details of the payload within BatchWrapper instance, based on the details in "requestParams".
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    commonId	                        DESCRIPTION (Data Type Id, Common Id used across all payloads of Package Delivery API request)
    * @param    firstBatch	                        DESCRIPTION (Data Type Boolean, True if the payload is the First Batch being processed)
    * @param    finalBatch	                        DESCRIPTION (Data Type Boolean, True if the payload is the Final Batch being processed)
    * @param    singleContactDelivery               DESCRIPTION (Data Type Boolean, True if the payload is for the Single Contact Package Delivery)
    * @return   BatchWrapper                        DESCRIPTION (return BatchWrapper instance containing Common Id & Batch details)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static BatchWrapper getBatchWrapper(Id commonId, Boolean firstBatch, Boolean finalBatch, Boolean singleContactDelivery) {
        BatchWrapper batchWrapper = new BatchWrapper();
        batchWrapper.CommonId = commonId;
        batchWrapper.FirstBatch = String.valueOf(firstBatch).toUpperCase();
        batchWrapper.FinalBatch = String.valueOf(finalBatch).toUpperCase();
        batchWrapper.SingleContact = String.valueOf(singleContactDelivery).toUpperCase();
        return batchWrapper;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create & wrap Package Envelope Email Subject & Body details within AcquisitionCompanyWrapper instance, based on the details in "requestParams".
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompany	                        DESCRIPTION (Data Type Acquisition_Company__c, Acquisition Company record)
    * @return   AcquisitionCompanyWrapper           DESCRIPTION (return AcquisitionCompanyWrapper instance containing Package Envelope Email Subject & Body)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static AcquisitionCompanyWrapper getAcquisitionCompanyWrapper(Acquisition_Company__c acqCompany) {
        AcquisitionCompanyWrapper acquisitionCompanyWrapper = new AcquisitionCompanyWrapper();
        acquisitionCompanyWrapper.SignatureLeadEmailSubject = acqCompany.MA_DS_Package_Envelope_Email_Subject__c;
        acquisitionCompanyWrapper.SignatureLeadEmailBody = acqCompany.MA_DS_Package_Envelope_Email_Body__c;
        return acquisitionCompanyWrapper;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to wrap the Package Distribution details within DistributionWrapper, and wrapping the List of DistributionWrapper instances within DistributionsWrapper instance.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    customDeliveryEmailMap	            DESCRIPTION (Data Type Map<Id, Boolean>, Map of Package Distribution Id to "Custom Package Envelope Email" flag)
    * @return   DistributionsWrapper                DESCRIPTION (return DistributionsWrapper instance)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static DistributionsWrapper getDistributionsWrapper(Map<Id, Boolean> customDeliveryEmailMap) {
        List<DistributionWrapper> distributionWrapperList = new List<DistributionWrapper>();

        for(Id pkgDistributionId : customDeliveryEmailMap.keySet()) {
            DistributionWrapper distributionWrapper = new DistributionWrapper();
            distributionWrapper.DistributionId = pkgDistributionId;
            distributionWrapper.CustomEmail = String.valueOf(customDeliveryEmailMap.get(pkgDistributionId)).toUpperCase();
            distributionWrapperList.add(distributionWrapper);
        }

        DistributionsWrapper distributionsWrapper = new DistributionsWrapper();
        distributionsWrapper.Distribution = distributionWrapperList;

        return distributionsWrapper;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to wrap the Background Check Templates within TemplateWrapper, and wrapping the List of TemplateWrapper instances within TemplatesWrapper instance.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    bgcEmailTemplates	                DESCRIPTION (Data Type List<MA_DS_Template__c>, List of Background Check Template records)
    * @return   TemplatesWrapper                    DESCRIPTION (return TemplatesWrapper instance)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static TemplatesWrapper getTemplatesWrapper(List<MA_DS_Template__c> bgcEmailTemplates) {
        List<TemplateWrapper> templateWrapperList = new List<TemplateWrapper>();

        for(MA_DS_Template__c bgcEmailTemplate : bgcEmailTemplates) {
            TemplateWrapper templateWrapper = new TemplateWrapper();
            templateWrapper.Region = bgcEmailTemplate.MA_DS_Background_Check_Region__c;
            templateWrapper.BackgroundCheckUrl = bgcEmailTemplate.MA_DS_Background_Check_URL__c;
            templateWrapper.BackgroundSubject = bgcEmailTemplate.MA_DS_Background_Check_Email_Subject__c;
            templateWrapper.BackgroundBody = bgcEmailTemplate.MA_DS_Background_Check_Email_Body__c;
            templateWrapperList.add(templateWrapper);
        }

        TemplatesWrapper templatesWrapper = new TemplatesWrapper();
        templatesWrapper.Template = templateWrapperList;

        return templatesWrapper;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to wrap List of PackageRecipientWrapper instances within PackageRecipientsWrapper instance, based on the details in "requestParams".
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqContacts	                        DESCRIPTION (Data Type List<Acquisition_Contacts__c>, List of Acquisition Contacts for the Package Prep)
    * @param    sortOrderMap	                    DESCRIPTION (Data Type Map<String, Integer>, Map of Concatenated Id (Package Id + Template Id) to "Sort Order" value)
    * @return   PackageRecipientsWrapper            DESCRIPTION (return PackageRecipientsWrapper instance)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static PackageRecipientsWrapper getPackageRecipientsWrapper(List<Acquisition_Contacts__c> acqContacts, Map<String, Integer> sortOrderMap) {
        PackageRecipientsWrapper packageRecipientsWrapper = new PackageRecipientsWrapper();
        packageRecipientsWrapper.PackageRecipient = getPackageRecipientWrapperList(acqContacts, sortOrderMap);
        return packageRecipientsWrapper;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create & wrap PackageRecipientWrapper details in the List of PackageRecipientWrapper instance, based on the details in "requestParams".
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqContacts	                        DESCRIPTION (Data Type List<Acquisition_Contacts__c>, List of Acquisition Contacts for the Package Prep)
    * @param    sortOrderMap	                    DESCRIPTION (Data Type Map<String, Integer>, Map of Concatenated Id (Package Id + Template Id) to "Sort Order" value)
    * @return   List<PackageRecipientWrapper>       DESCRIPTION (return List of PackageRecipientWrapper instances)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<PackageRecipientWrapper> getPackageRecipientWrapperList(List<Acquisition_Contacts__c> acqContacts, Map<String, Integer> sortOrderMap) {
        List<PackageRecipientWrapper> packageRecipientWrapperList = new List<PackageRecipientWrapper>();

        for(Acquisition_Contacts__c acqContact : acqContacts) {
            PackageRecipientWrapper packageRecipientWrapper = new PackageRecipientWrapper();
            updateWithContactInfo(packageRecipientWrapper, acqContact);

            if(acqContact.Acquisition_Compensation__r != null && acqContact.Acquisition_Compensation__r.size() > 0) {
                updateWithCompensationInfo(packageRecipientWrapper, acqContact.Acquisition_Compensation__r[0]);
            }

            if(acqContact.MA_DS_Applied_Rules__r != null && acqContact.MA_DS_Applied_Rules__r.size() > 0) {
                packageRecipientWrapper.AppliedRules = getAppliedRulesWrapper(acqContact.MA_DS_Applied_Rules__r, sortOrderMap);
            }

            packageRecipientWrapperList.add(packageRecipientWrapper);
        }

        return packageRecipientWrapperList;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update Acquisition Contact record details in PackageRecipientWrapper wrapper instance.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    packageRecipientWrapper	            DESCRIPTION (Data Type PackageRecipientWrapper, Wrapper instance to wrap Acquisition Contact details)
    * @param    acqContact	                        DESCRIPTION (Data Type Acquisition_Contacts__c, Acquisition Contact record details)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateWithContactInfo(PackageRecipientWrapper packageRecipientWrapper, Acquisition_Contacts__c acqContact) {
        packageRecipientWrapper.ContactId = acqContact.Id;
        packageRecipientWrapper.Email = acqContact.MA_DS_Preferred_Email_Address__c;
        packageRecipientWrapper.FirstNameLegal = acqContact.First_Name_Legal__c;
        packageRecipientWrapper.LastNameLegal = acqContact.Last_Name_Legal__c;
        packageRecipientWrapper.FirstNamePreferred = acqContact.First_Name_Preferred__c;
        packageRecipientWrapper.LastNamePreferred = acqContact.Last_Name_Preferred__c;
        packageRecipientWrapper.EnvelopeVoidPeriodDays = Integer.valueOf(acqContact.MA_DS_Envelope_Void_Period_Days__c);
        packageRecipientWrapper.EnvelopeVoidDate =  MA_DS_DateFormatter.getFormattedDate(acqContact.MA_DS_Envelope_Void_Date__c, acqContact.Office_Address_Country__c);
        packageRecipientWrapper.BackgroundRegion = acqContact.Office_Address_Country__c;
        packageRecipientWrapper.BackgroundCheckStatus = acqContact.Background_Check__c;
        packageRecipientWrapper.CustomEmail = String.valueOf(acqContact.MA_DS_Custom_Package_Envelope_Email__c).toUpperCase();
        packageRecipientWrapper.FullName = acqContact.Name;
        packageRecipientWrapper.PreferredFullName = acqContact.Full_Name_Preferred__c;
        packageRecipientWrapper.AdditionalField1 = acqContact.Additional_Field_1__c;
        packageRecipientWrapper.AdditionalField2 = acqContact.Additional_Field_2__c;
        packageRecipientWrapper.AdditionalField3 = acqContact.Additional_Field_3__c;
        packageRecipientWrapper.AdditionalField4 = acqContact.Additional_Field_4__c;
        packageRecipientWrapper.AdditionalField5 = acqContact.Additional_Field_5__c;
        packageRecipientWrapper.DateFormat = MA_DS_DateFormatter.getDateFormat(acqContact.Office_Address_Country__c);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update Acquisition Compensation record details in PackageRecipientWrapper wrapper instance.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    packageRecipientWrapper	            DESCRIPTION (Data Type PackageRecipientWrapper, Wrapper instance to wrap Acquisition Contact details)
    * @param    acqCompensation	                    DESCRIPTION (Data Type Acquisition_Compensation__c, Acquisition Compensation record details of the Acquisition Contact)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateWithCompensationInfo(PackageRecipientWrapper packageRecipientWrapper, Acquisition_Compensation__c acqCompensation) {
        packageRecipientWrapper.CompensationAdditionalField1 = acqCompensation.Additional_Field_1__c;
        packageRecipientWrapper.CompensationAdditionalField2 = acqCompensation.Additional_Field_2__c;
        packageRecipientWrapper.CompensationAdditionalField3 = acqCompensation.Additional_Field_3__c;
        packageRecipientWrapper.CompensationAdditionalField4 = acqCompensation.Additional_Field_4__c;
        packageRecipientWrapper.CompensationAdditionalField5 = acqCompensation.Additional_Field_5__c;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to wrap the Applied Rules within AppliedRuleWrapper, and wrapping the List of AppliedRuleWrapper instances within AppliedRulesWrapper instance.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    appliedRules	                    DESCRIPTION (Data Type List<MA_DS_Applied_Rule__c>, List of Applied Rule records for the Acquisition Contact)
    * @param    sortOrderMap	                    DESCRIPTION (Data Type Map<String, Integer>, Map of Concatenated Id (Package Id + Template Id) to "Sort Order" value)
    * @return   AppliedRulesWrapper                 DESCRIPTION (return AppliedRulesWrapper instance)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static AppliedRulesWrapper getAppliedRulesWrapper(List<MA_DS_Applied_Rule__c> appliedRules, Map<String, Integer> sortOrderMap) {
        List<AppliedRuleWrapper> appliedRuleWrapperList = new List<AppliedRuleWrapper>();

        for(MA_DS_Applied_Rule__c appliedRule : appliedRules) {
            String concatenatedId = String.valueOf(appliedRule.MA_DS_Package_Distribution__r.MA_DS_Package__c) + String.valueOf(appliedRule.MA_DS_Template__c);

            AppliedRuleWrapper appliedRuleWrapper = new AppliedRuleWrapper();
            appliedRuleWrapper.AppliedRuleRecordId = appliedRule.Id;
            appliedRuleWrapper.PackageDistId = appliedRule.MA_DS_Package_Distribution__c;
            appliedRuleWrapper.SortOrder = sortOrderMap.get(concatenatedId);
            appliedRuleWrapperList.add(appliedRuleWrapper);
        }

        AppliedRulesWrapper appliedRulesWrapper = new AppliedRulesWrapper();
        appliedRulesWrapper.AppliedRule = appliedRuleWrapperList;

        return appliedRulesWrapper;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold details of Params attribute of the API payload for the Package Delivery process.
    * Holds Common Information, Background Check Templates & Package Recipients details being sent for the Package Delivery.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class ParamsWrapper {
        BatchWrapper Batch;
        AcquisitionCompanyWrapper AcquisitionCompany;
        DistributionsWrapper PackageDistributions;

        CommonInformationWrapper CommonInformation;
        TemplatesWrapper BackgroundEmailTemplates;
        PackageRecipientsWrapper PackageRecipients;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold Acquisition Company, Package Distributions, Background Check Templates & Batch details being sent for the Package Delivery.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class CommonInformationWrapper {
        BatchWrapper Batch;
        AcquisitionCompanyWrapper AcquisitionCompany;
        DistributionsWrapper PackageDistributions;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold Common Id and Batch Details for the request payload.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class BatchWrapper {
        Id CommonId;
        String FirstBatch;
        String FinalBatch;
        String SingleContact;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold "Package Envelope Email Subject" & "Package Envelope Email Body" at Acquisition Company level.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class AcquisitionCompanyWrapper {
        String SignatureLeadEmailSubject;
        String SignatureLeadEmailBody;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the List of DistributionWrapper instances, to wrap it within DistributionsWrapper node.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class DistributionsWrapper {
        List<DistributionWrapper> Distribution;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the details of Package Distribution record Id and "Custom Package Envelope Email" flag.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class DistributionWrapper {
        Id DistributionId;
        String CustomEmail;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the List of TemplateWrapper instances, to wrap it within TemplatesWrapper node.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class TemplatesWrapper {
        List<TemplateWrapper> Template;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the details of Background Check Template type record.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class TemplateWrapper {
        String Region;
        String BackgroundCheckUrl;
        String BackgroundSubject;
        String BackgroundBody;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the List of PackageRecipientWrapper instances, to wrap it within PackageRecipientsWrapper node.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class PackageRecipientsWrapper {
        List<PackageRecipientWrapper> PackageRecipient;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the details (from Acquisition Contact & Acquisition Compensation record) of each Acquisition Contact.
    * Also, holds the AppliedRulesWrapper for each Acquisition Contact.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class PackageRecipientWrapper {
        Id ContactId;
        String Email;
        String FirstNameLegal;
        String LastNameLegal;
        String FirstNamePreferred;
        String LastNamePreferred;
        Integer EnvelopeVoidPeriodDays;
        String EnvelopeVoidDate;
        String BackgroundRegion;
        String BackgroundCheckStatus;
        String CustomEmail;
        String FullName;
        String PreferredFullName;
        String AdditionalField1;
        String AdditionalField2;
        String AdditionalField3;
        String AdditionalField4;
        String AdditionalField5;
        String CompensationAdditionalField1;
        String CompensationAdditionalField2;
        String CompensationAdditionalField3;
        String CompensationAdditionalField4;
        String CompensationAdditionalField5;
        String DateFormat;
        AppliedRulesWrapper AppliedRules;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the List of AppliedRuleWrapper instances, to wrap it within AppliedRulesWrapper node.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class AppliedRulesWrapper {
        List<AppliedRuleWrapper> AppliedRule;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the Applied Rule details of each Acquisition Contact.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class AppliedRuleWrapper {
        Id AppliedRuleRecordId;
        Id PackageDistId;
        Integer SortOrder;
    }
}