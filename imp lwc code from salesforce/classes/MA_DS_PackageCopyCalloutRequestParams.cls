/**
 * W-12456766
 * Extends MA_DS_AbstractCalloutRequestParams class to Serialize value of Params attribute for the Package Copy callout.
 * 
 * Version      Date            Author                  Description
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         28/02/2023      Chakshu Malhotra        W-12456766 - Adds logic to convert Derived Templates data to accepted format of Package Copy API callout.
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_PackageCopyCalloutRequestParams extends MA_DS_AbstractCalloutRequestParams {
    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to convert the requestParams & wrap it in a ParamsWrapper instance, as per the accepted Payload format for the Package Copy API Request.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    requestParams	    DESCRIPTION (Data Type Object, Object type Params that need to be added in the API callout payload)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void deserializeParams(Object requestParams) {
        List<MA_DS_Template__c> newDerivedTemplates = (List<MA_DS_Template__c>)requestParams;
        Id acqCompanyId = newDerivedTemplates[0]?.MA_DS_Acquisition_Company__c;

        ParamsWrapper wrapperInstance = new ParamsWrapper();
        wrapperInstance.Acquisition = getAcquisitionWrapper(acqCompanyId);
        wrapperInstance.Templates = getTemplatesWrapper(newDerivedTemplates);

        super.deserializedParams = JSON.deserializeUntyped(JSON.serialize(wrapperInstance));
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the Acquisition Company details and wrap it in an AcquisitionWrapper instance.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	        DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @return   AcquisitionWrapper      DESCRIPTION (return the AcquisitionWrapper instance)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static AcquisitionWrapper getAcquisitionWrapper(Id acqCompanyId) {
        AcquisitionWrapper acquisitionWrapper = new AcquisitionWrapper();
        acquisitionWrapper.AcquisitionId = acqCompanyId;
        acquisitionWrapper.AcquisitionName = [SELECT Name FROM Acquisition_Company__c WHERE Id = :acqCompanyId LIMIT 1]?.Name;
        return acquisitionWrapper;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create a List of TemplateWrapper instances and add it to a TemplatesWrapper instance, based on the "requestParams".
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    derivedTemplates	    DESCRIPTION (Data Type List<MA_DS_Template__c>, List of newly added Templates as part of Package & Template Copy process)
    * @return   TemplatesWrapper        DESCRIPTION (return the TemplatesWrapper instance)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static TemplatesWrapper getTemplatesWrapper(List<MA_DS_Template__c> derivedTemplates) {
        List<TemplateWrapper> templateWrapperList = new List<TemplateWrapper>();

        for(MA_DS_Template__c derivedTemplate : derivedTemplates) {
            templateWrapperList.add(getTemplateWrapper(derivedTemplate));
        }

        TemplatesWrapper templatesWrapper = new TemplatesWrapper();
        templatesWrapper.Template = templateWrapperList;
        return templatesWrapper;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create a TemplateWrapper instance for each newly added Template, as part of the Package & Template Copy process.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    derivedTemplate	            DESCRIPTION (Data Type MA_DS_Template__c, Newly added Template as part of Package & Template Copy process)
    * @return   TemplatesWrapper            DESCRIPTION (return the TemplatesWrapper instance)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static TemplateWrapper getTemplateWrapper(MA_DS_Template__c derivedTemplate) {
        TemplateWrapper templateWrapper = new TemplateWrapper();
        templateWrapper.TemplateId = derivedTemplate.Id;
        templateWrapper.TemplateName = derivedTemplate.Name;
        templateWrapper.FromTemplate = derivedTemplate.MA_DS_Derived_From_Template__c;
        return templateWrapper;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold details of Params attribute of the API payload for the Package Copy process.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class ParamsWrapper {
        AcquisitionWrapper Acquisition;
        TemplatesWrapper Templates;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold details of the Acquisition Company (Record Id & Name of the Acquisition Company).
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class AcquisitionWrapper {
        String AcquisitionId;
        String AcquisitionName;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the list of each instance of the TemplateWrapper, to wrap it within TemplatesWrapper node.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class TemplatesWrapper {
        List<TemplateWrapper> Template;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the details of each newly added Template, as part of the Package & Template Copy process.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class TemplateWrapper {
        String TemplateId;
        String TemplateName;
        String FromTemplate;
    }
}