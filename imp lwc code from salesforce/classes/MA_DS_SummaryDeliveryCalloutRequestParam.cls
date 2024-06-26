/**
 * W-12578130
 * Extends MA_DS_AbstractCalloutRequestParams class to Serialize value of Params attribute for the Manager Summary Delivery API callout.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         23/04/2023      Chakshu Malhotra        W-12578130 - Adds logic to convert MA_DS_ManagerSummaryDeliveryWrapper.ManagerSummaryDeliveryParams to an accepted format of Manager Summary Delivery API callout.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_SummaryDeliveryCalloutRequestParam extends MA_DS_AbstractCalloutRequestParams {
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to convert the requestParams & wrap it in a ParamsWrapper instance, as per the accepted Payload format for the Manager Summary Delivery API Request.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    requestParams	    DESCRIPTION (Data Type MA_DS_CalloutFramework.RequestParams , RequestParams type Params that need to be added in the API callout payload)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void deserializeParams(MA_DS_CalloutFramework.RequestParams requestParams) {
        this.requestParams = requestParams;
        MA_DS_ManagerSummaryDeliveryWrapper.ManagerSummaryDeliveryParams summaryDeliveryParams = (MA_DS_ManagerSummaryDeliveryWrapper.ManagerSummaryDeliveryParams)requestParams;
        
        ParamsWrapper wrapperInstance = new ParamsWrapper();
        wrapperInstance.CommonId = summaryDeliveryParams.commonId;
        wrapperInstance.TotalBatches = summaryDeliveryParams.totalBatches;
        wrapperInstance.CurrentBatchNumber = summaryDeliveryParams.currentBatchNumber;
        wrapperInstance.AcquisitionCompany = getAcquisitionCompanyWrapper(summaryDeliveryParams.acqCompany);
        wrapperInstance.PackageDistributions = getPackageDistributionsWrapper(summaryDeliveryParams.pkgDistributionId, summaryDeliveryParams.customSummaryEmail, summaryDeliveryParams.offerCommunicators);

        super.deserializedParams = JSON.deserializeUntyped(JSON.serialize(wrapperInstance));
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create & wrap Manager Summary Email Subject & Body details within AcquisitionCompanyWrapper instance, based on the details in "requestParams".
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompany	                        DESCRIPTION (Data Type Acquisition_Company__c, Acquisition Company record)
    * @return   AcquisitionCompanyWrapper           DESCRIPTION (return AcquisitionCompanyWrapper instance containing Manager Summary Email Subject & Body)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static AcquisitionCompanyWrapper getAcquisitionCompanyWrapper(Acquisition_Company__c acqCompany) {
        AcquisitionCompanyWrapper acquisitionCompanyWrapper = new AcquisitionCompanyWrapper();
        acquisitionCompanyWrapper.SummaryEmailSubject = acqCompany.MA_DS_Manager_Summary_Email_Subject__c;
        acquisitionCompanyWrapper.SummaryEmailBody = acqCompany.MA_DS_Manager_Summary_Email_Body__c;
        return acquisitionCompanyWrapper;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to wrap Package Distribution & Offer Communicators details within PackageDistributionsWrapper instance, based on the details in "requestParams".
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionId	                DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    customSummaryEmail	                DESCRIPTION (Data Type Boolean, True if "Custom Manager Summary Email" flag is set for the Package Distribution record)
    * @param    offerCommunicators	                DESCRIPTION (Data Type List<Acquisition_Contacts__c>, List of Offer Communicators to be processed for the Manager Summary Delivery API)
    * @return   PackageDistributionsWrapper         DESCRIPTION (return PackageDistributionsWrapper instance containing Package Distribution & Offer Communicators details)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static PackageDistributionsWrapper getPackageDistributionsWrapper(Id pkgDistributionId, Boolean customSummaryEmail, List<Acquisition_Contacts__c> offerCommunicators) {
        PackageDistributionsWrapper packageDistributionsWrapper = new PackageDistributionsWrapper();
        packageDistributionsWrapper.PackageDistribution = getPackageDistributionWrapperList(pkgDistributionId, customSummaryEmail, offerCommunicators);
        return packageDistributionsWrapper;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create & wrap PackageDistributionWrapper details in the List of PackageDistributionWrapper instance, based on the details in "requestParams".
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionId	                DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    customSummaryEmail	                DESCRIPTION (Data Type Boolean, True if "Custom Manager Summary Email" flag is set for the Package Distribution record)
    * @param    offerCommunicators	                DESCRIPTION (Data Type List<Acquisition_Contacts__c>, List of Offer Communicators to be processed for the Manager Summary Delivery API)
    * @return   List<PackageDistributionWrapper>    DESCRIPTION (return List of PackageDistributionWrapper instances)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<PackageDistributionWrapper> getPackageDistributionWrapperList(Id pkgDistributionId, Boolean customSummaryEmail, List<Acquisition_Contacts__c> offerCommunicators) {
        PackageDistributionWrapper packageDistributionWrapper = new PackageDistributionWrapper();
        packageDistributionWrapper.PackageDistributionId = pkgDistributionId;
        packageDistributionWrapper.CustomEmail = String.valueOf(customSummaryEmail).toUpperCase();
        packageDistributionWrapper.OfferCommunicators = getOfferCommunicatorsWrapper(offerCommunicators);
        return new List<PackageDistributionWrapper> {packageDistributionWrapper};
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to wrap List of OfferCommunicatorWrapper instances within OfferCommunicatorsWrapper instance, based on the details in "requestParams".
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    offerCommunicators	                DESCRIPTION (Data Type List<Acquisition_Contacts__c>, List of Offer Communicators to be processed for the Manager Summary Delivery API)
    * @return   OfferCommunicatorsWrapper           DESCRIPTION (return OfferCommunicatorsWrapper instance)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static OfferCommunicatorsWrapper getOfferCommunicatorsWrapper(List<Acquisition_Contacts__c> offerCommunicators) {
        OfferCommunicatorsWrapper offerCommunicatorsWrapper = new OfferCommunicatorsWrapper();
        offerCommunicatorsWrapper.OfferCommunicator = getOfferCommunicatorWrapperList(offerCommunicators);
        return offerCommunicatorsWrapper;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create & wrap OfferCommunicatorWrapper details in the List of OfferCommunicatorWrapper instance, based on the details in "requestParams".
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    offerCommunicators	                DESCRIPTION (Data Type List<Acquisition_Contacts__c>, List of Offer Communicators to be processed for the Manager Summary Delivery API)
    * @return   List<OfferCommunicatorWrapper>      DESCRIPTION (return List of OfferCommunicatorWrapper instances)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<OfferCommunicatorWrapper> getOfferCommunicatorWrapperList(List<Acquisition_Contacts__c> offerCommunicators) {
        List<OfferCommunicatorWrapper> offerCommunicatorWrapperList = new List<OfferCommunicatorWrapper>();

        for(Acquisition_Contacts__c offerCommunicator : offerCommunicators) {
            OfferCommunicatorWrapper offerCommunicatorWrapper = new OfferCommunicatorWrapper();
            offerCommunicatorWrapper.OfferCommunicatorId = offerCommunicator.Id;
            offerCommunicatorWrapper.FirstName = offerCommunicator.First_Name_Legal__c;
            offerCommunicatorWrapper.LastName = offerCommunicator.Last_Name_Legal__c;
            offerCommunicatorWrapper.FullName = offerCommunicator.Name;
            offerCommunicatorWrapper.PreferredFirstName = offerCommunicator.First_Name_Preferred__c;
            offerCommunicatorWrapper.PreferredLastName = offerCommunicator.Last_Name_Preferred__c;
            offerCommunicatorWrapper.PreferredFullName = offerCommunicator.Full_Name_Preferred__c;
            offerCommunicatorWrapper.EmployeeIDTarget = offerCommunicator.Employee_ID_Target__c;
            offerCommunicatorWrapper.AdditionalField1 = offerCommunicator.Additional_Field_1__c;
            offerCommunicatorWrapper.AdditionalField2 = offerCommunicator.Additional_Field_2__c;
            offerCommunicatorWrapper.AdditionalField3 = offerCommunicator.Additional_Field_3__c;
            offerCommunicatorWrapper.AdditionalField4 = offerCommunicator.Additional_Field_4__c;
            offerCommunicatorWrapper.AdditionalField5 = offerCommunicator.Additional_Field_5__c;
            offerCommunicatorWrapper.Email = offerCommunicator.MA_DS_Preferred_Email_Address__c;            
            offerCommunicatorWrapper.CustomEmail = String.valueOf(offerCommunicator.MA_DS_Custom_Manager_Summary_Email__c).toUpperCase();

            if(offerCommunicator.Acquisition_Compensation__r != null && offerCommunicator.Acquisition_Compensation__r.size() > 0) {
                updateWithCompensationInfo(offerCommunicatorWrapper, offerCommunicator.Acquisition_Compensation__r[0]);
            }

            offerCommunicatorWrapperList.add(offerCommunicatorWrapper);
        }

        return offerCommunicatorWrapperList;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update Acquisition Compensation record details in OfferCommunicatorWrapper wrapper instance.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    offerCommunicatorWrapper	        DESCRIPTION (Data Type OfferCommunicatorWrapper, Wrapper instance to wrap Offer Communicator details)
    * @param    acqCompensation	                    DESCRIPTION (Data Type Acquisition_Compensation__c, Acquisition Compensation record details of the Offer Communicator)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateWithCompensationInfo(OfferCommunicatorWrapper offerCommunicatorWrapper, Acquisition_Compensation__c acqCompensation) {
        offerCommunicatorWrapper.CompensationAdditionalField1 = acqCompensation.Additional_Field_1__c;
        offerCommunicatorWrapper.CompensationAdditionalField2 = acqCompensation.Additional_Field_2__c;
        offerCommunicatorWrapper.CompensationAdditionalField3 = acqCompensation.Additional_Field_3__c;
        offerCommunicatorWrapper.CompensationAdditionalField4 = acqCompensation.Additional_Field_4__c;
        offerCommunicatorWrapper.CompensationAdditionalField5 = acqCompensation.Additional_Field_5__c;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold details of Params attribute of the API payload for the Manager Summary Delivery process.
    * Wraps instance of AcquisitionCompanyWrapper & PackageDistributionsWrapper.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class ParamsWrapper {
        Id CommonId;
        Integer TotalBatches;
        Integer CurrentBatchNumber;
        AcquisitionCompanyWrapper AcquisitionCompany;
        PackageDistributionsWrapper PackageDistributions;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the Manager Summary Email & Body at the Acquisition Company level.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class AcquisitionCompanyWrapper {
        String SummaryEmailSubject;
        String SummaryEmailBody;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the List of PackageDistributionWrapper instances, to wrap it within PackageDistributionsWrapper node.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class PackageDistributionsWrapper {
        List<PackageDistributionWrapper> PackageDistribution;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the Package Distribution record Id & "Custom Manager Summary Email" flag, along with OfferCommunicatorsWrapper instance.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class PackageDistributionWrapper {
        Id PackageDistributionId;
        String CustomEmail;
        OfferCommunicatorsWrapper OfferCommunicators;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the List of OfferCommunicatorWrapper instances, to wrap it within OfferCommunicatorsWrapper node.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class OfferCommunicatorsWrapper {
        List<OfferCommunicatorWrapper> OfferCommunicator;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the details (from Acquisition Contact) of each Offer Communicator for the Package Distribution record.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class OfferCommunicatorWrapper {
        Id OfferCommunicatorId;
        String FirstName;
        String LastName;
        String FullName;
        String PreferredFirstName;
        String PreferredLastName;
        String PreferredFullName;
        String EmployeeIDTarget;
        String AdditionalField1;
        String AdditionalField2;
        String AdditionalField3;
        String AdditionalField4;
        String AdditionalField5;
        String Email;
        String CustomEmail;
        String CompensationAdditionalField1;
        String CompensationAdditionalField2;
        String CompensationAdditionalField3;
        String CompensationAdditionalField4;
        String CompensationAdditionalField5;
    }
}