/**
 * W-13497500
 * Helper class to update the IUT type Applied Rules upon Package Voiding and help initiating the Single Package Delivery.
 * 
 * Version      Date            Author                  Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         15/06/2023      Chakshu Malhotra        W-13497500 - Adds logic to update the IUT type Applied Rules upon Package Voiding and help initiating the Single Package Delivery.
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_SinglePackageDeliveryHelper {
    
    private static final String AGG_FIELD_PKG_DIST_ID = 'pkgDistId';
    private static final String IUT_TYPE_APPLIED_RULE = Label.MA_DS_IUT_Type_Applied_Rule;
    private static final String IUT_DOCUMENT_TYPE_PACKAGE = Label.MA_DS_Document_Type_Package;

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the IUT type Applied Rules with "Need To Deliver" as true.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqContactToVoidDistributionMap         (Data type Map<Id, String>, Map of Acquisition Contact Id to the Voided Package Distribution Id)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @future
    public static void updateVoidedPackageAppliedRules(Map<Id, String> acqContactToVoidDistributionMap) {
        List<MA_DS_Applied_Rule__c> appliedRules = new List<MA_DS_Applied_Rule__c>();

        for(MA_DS_Applied_Rule__c appliedRule : getVoidedPackageAppliedRules(acqContactToVoidDistributionMap.keySet(), new Set<String>(acqContactToVoidDistributionMap.values()))) {
            if(appliedRule.MA_DS_Package_Distribution__c == acqContactToVoidDistributionMap.get(appliedRule.MA_DS_Acquisition_Contact__c)) {
                appliedRule.MA_DS_Need_To_Deliver__c = true;
                appliedRules.add(appliedRule);
            }
        }

        Acquisition_Contacts_Trigger_Handler.triggerDisabled = true;

        if(appliedRules.size() > 0) {
            updatePackageAppliedRules(appliedRules);
        }

        updateAcquisitionContacts(acqContactToVoidDistributionMap.keySet());
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the List of Package IUT type Applied Rule records based on the Acquisition Contacts & Voided Package Distribution Ids.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqContactIds	                            DESCRIPTION (Data Type Set<Id>, Set of Acquisition Contact Ids)
    * @param    pkgDistributionIds	                        DESCRIPTION (Data Type Set<String>, Set of Voided Package Distribution Ids)
    * @return   List<MA_DS_Applied_Rule__c>                 DESCRIPTION (return List of Package IUT type Applied Rule records)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<MA_DS_Applied_Rule__c> getVoidedPackageAppliedRules(Set<Id> acqContactIds, Set<String> pkgDistributionIds) {
        return [SELECT Id, MA_DS_Need_To_Deliver__c, MA_DS_Package_Distribution__c, MA_DS_Acquisition_Contact__c
                FROM MA_DS_Applied_Rule__c
                WHERE MA_DS_Rule_Type__c = :IUT_TYPE_APPLIED_RULE AND
                MA_DS_Template__r.MA_DS_Template_Document_Type__c = :IUT_DOCUMENT_TYPE_PACKAGE AND
                MA_DS_Package_Distribution__c IN :pkgDistributionIds AND
                MA_DS_Acquisition_Contact__c IN :acqContactIds];
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update Package Document IUT type Applied Rules with "Need To Deliver" as true.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    appliedRules	            DESCRIPTION (Data Type List<MA_DS_Applied_Rule__c>, List of updated Applied Rule records)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updatePackageAppliedRules(List<MA_DS_Applied_Rule__c> appliedRules) {
        MA_DS_PackageDistributionTriggerHandler.triggerDisabled = true;
        Database.SaveResult[] appliedRulesSRList = Database.update(appliedRules, false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(appliedRulesSRList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the Acquisition Contacts with "Void Distribution Id" as null.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqContactIds	                            DESCRIPTION (Data Type Set<Id>, Set of Acquisition Contact Ids)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateAcquisitionContacts(Set<Id> acqContactIds) {
        List<Acquisition_Contacts__c> acqContacts = [SELECT Id, MA_DS_Void_Distribution_Id__c FROM Acquisition_Contacts__c WHERE Id IN :acqContactIds];
        
        for (Acquisition_Contacts__c acqContact : acqContacts) {
            acqContact.MA_DS_Void_Distribution_Id__c = null;
        }
        
        Database.SaveResult[] acqContactsSRList = Database.update(acqContacts, false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(acqContactsSRList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the Package Distribution record Ids for the Single Acquisition Contact Package Delivery (post Package Void).
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqContactId	            DESCRIPTION (Data Type Id, Acquisition Contact record Id)
    * @return   Set<Id>                     DESCRIPTION (return Set of Package Distribution record Ids for the given Acquisition Contact)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Set<Id> getDistributionsForSingleContactPackageDelivery(Id acqContactId) {
        List<AggregateResult> aggAppliedRules = [SELECT MA_DS_Package_Distribution__c pkgDistId, Count(Id)
                                                 FROM MA_DS_Applied_Rule__c
                                                 WHERE MA_DS_Acquisition_Contact__c = :acqContactId AND
                                                 MA_DS_Rule_Type__c = :IUT_TYPE_APPLIED_RULE AND
                                                 MA_DS_Template__r.MA_DS_Template_Document_Type__c = :IUT_DOCUMENT_TYPE_PACKAGE AND
                                                 MA_DS_Need_To_Deliver__c = true AND
                                                 MA_DS_Acquisition_Contact__r.MA_DS_No_Offer__c = false AND
                                                 MA_DS_Acquisition_Contact__r.MA_DS_Offer_Declined__c = false
                                                 GROUP BY MA_DS_Package_Distribution__c
                                                 HAVING Count(Id) > 0];
        Set<Id> pkgDistributionIds = new Set<Id>();

        for(AggregateResult aggAppliedRule : aggAppliedRules) {
            Id pkgDistId = (Id)aggAppliedRule.get(AGG_FIELD_PKG_DIST_ID);
            pkgDistributionIds.add(pkgDistId);
        }

        return pkgDistributionIds;
    }
}