/**
 * W-13497500, W-12218399
 * Acquisition Contact After Update Trigger handler class; implements Acquisition_Contacts_Trigger_Handler.TriggerActionHandler interface to handle after update logic on Package Stage field.
 * 
 * Version      Date            Author                  Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         15/06/2023      Chakshu Malhotra        W-13497500 - Adds logic to update the IUT type Applied Rules with "Need To Deliver" as true upon Package Voiding.
 * v1.0         05/11/2023      Chakshu Malhotra        W-12218399 - Adds logic to retrieve the ClientIPAddress from DocuSign eSignature when Envelope Id is updated.
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_AcqContactAfterUpdateHandler implements Acquisition_Contacts_Trigger_Handler.TriggerActionHandler {

    private static final String PACKAGE_STAGE_VOIDED = Label.MA_DS_Package_Stage_Voided;
    private static final String PACKAGE_STAGE_ACCEPTED = Label.MA_DS_Package_Stage_Accepted;
    private static final String PACKAGE_STAGE_DECLINED = Label.MA_DS_Package_Stage_Declined;
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to handle after update trigger logic on Acquisition Contact records.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecords          (Data type List<Acquisition_Contacts__c>, List of new Acquisition Contact records)
    * @param    oldMap 	            (Data type Map<Id, Acquisition_Contacts__c>, Trigger.oldMap of Acquisition Contact records)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void handleAfterUpdate(List<Acquisition_Contacts__c> newRecords, Map<Id, Acquisition_Contacts__c> oldMap) {
        MA_DS_AcqContactAfterUpdateHandler.handlePackageStageUpdates(newRecords, oldMap);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the IUT type Applied Rules with "Need To Deliver" as true when Package is Voided and "Void Distribution Id" is updated by the CLM.
    * Method to handle the update on "Envelope Id", retrieves ClientIPAddress from DocuSign eSignature via API callout.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newAcqContacts       (Data type List<Acquisition_Contacts__c>, List of new Acquisition Contact records)
    * @param    oldAcqContactMap 	 (Data type Map<Id, Acquisition_Contacts__c>, Trigger.oldMap of Acquisition Contact records)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void handlePackageStageUpdates(List<Acquisition_Contacts__c> newAcqContacts, Map<Id, Acquisition_Contacts__c> oldAcqContactMap) {
        Map<Id, String> acqContactToEnvelopeIdMap = new Map<Id, String>();
        Map<Id, String> acqContactToVoidDistributionMap = new Map<Id, String>();
        
        for(Acquisition_Contacts__c newAcqContact : newAcqContacts) {
            if(isPackageAcceptedOrDeclined(newAcqContact, oldAcqContactMap.get(newAcqContact.Id))) {
                acqContactToEnvelopeIdMap.put(newAcqContact.Id, newAcqContact.MA_DS_Envelope_Id__c);
            }
            if(isPackageVoidedOrDeclined(newAcqContact, oldAcqContactMap.get(newAcqContact.Id))) {
                acqContactToVoidDistributionMap.put(newAcqContact.Id, newAcqContact.MA_DS_Void_Distribution_Id__c);
            }
        }
        
        if(acqContactToVoidDistributionMap.size() > 0) {
            MA_DS_SinglePackageDeliveryHelper.updateVoidedPackageAppliedRules(acqContactToVoidDistributionMap);
        }

        if(acqContactToEnvelopeIdMap.size() > 0) {
            MA_DS_AcqContactAfterUpdateHandler.initGetClientIPAddressHandlerService(acqContactToEnvelopeIdMap, MA_DS_PackageStageHandlerService.HandlerAction.GET_CLIENT_IP_ADDRESS);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to check if the Package Stage is Accepted / Declined and "Envelope Id" is updated by the CLM.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newAcqContact       (Data type Acquisition_Contacts__c, Acquisition Contact record in Trigger.new)
    * @param    oldAcqContact       (Data type Acquisition_Contacts__c, Acquisition Contact record in Trigger.oldMap)
    * @return   Boolean             DESCRIPTION (return true if Package is voided)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isPackageAcceptedOrDeclined(Acquisition_Contacts__c newAcqContact, Acquisition_Contacts__c oldAcqContact) {
        return newAcqContact.MA_DS_Envelope_Id__c != null && 
            newAcqContact.MA_DS_Envelope_Id__c != oldAcqContact.MA_DS_Envelope_Id__c && 
            (newAcqContact.MA_DS_Package_Stage__c.equalsIgnoreCase(PACKAGE_STAGE_ACCEPTED) || newAcqContact.MA_DS_Package_Stage__c.equalsIgnoreCase(PACKAGE_STAGE_DECLINED));
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to check if the Package Stage is Voided / Declined and "Void Distribution Id" is updated by the CLM.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newAcqContact       (Data type Acquisition_Contacts__c, Acquisition Contact record in Trigger.new)
    * @param    oldAcqContact       (Data type Acquisition_Contacts__c, Acquisition Contact record in Trigger.oldMap)
    * @return   Boolean             DESCRIPTION (return true if Package is voided)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isPackageVoidedOrDeclined(Acquisition_Contacts__c newAcqContact, Acquisition_Contacts__c oldAcqContact) {
        return newAcqContact.MA_DS_Void_Distribution_Id__c != null && 
            newAcqContact.MA_DS_Void_Distribution_Id__c != oldAcqContact.MA_DS_Void_Distribution_Id__c && 
            (newAcqContact.MA_DS_Package_Stage__c.equalsIgnoreCase(PACKAGE_STAGE_VOIDED) || newAcqContact.MA_DS_Package_Stage__c.equalsIgnoreCase(PACKAGE_STAGE_DECLINED));
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to execute PackageStatusHandlerJob to handle post-processing logic for Recalled status update.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionIds	            DESCRIPTION (Data Type Set<String>, Set of Package Distribution Ids)
    * @param    packageStatusType	            DESCRIPTION (Data Type MA_DS_PackageStatusHandlerService.PackageStatus, PackageStatus type for Recalled update)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void initGetClientIPAddressHandlerService(Map<Id, String> envelopeIdsMap, MA_DS_PackageStageHandlerService.HandlerAction handlerActionType) {
        MA_DS_PackageStageHandlerService.strategyInstance.setEnvelopeIdsMap(envelopeIdsMap)
                                                         .setHandlerActionType(handlerActionType)
                                                         .initHandlerService()
                                                         .initPackageStageHandlerJob()
                                                         .execute();
    }
}