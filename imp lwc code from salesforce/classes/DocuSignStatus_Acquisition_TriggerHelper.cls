public with sharing class DocuSignStatus_Acquisition_TriggerHelper{

    //method to filter in NEW acquisiton docusign status
    public static void filterAcqDocuSignStatus(List<dsfs__DocuSign_Status__c> newDocusignStatusRecords){
        List<dsfs__DocuSign_Status__c> filteredDocuSignStatusRecords = new List<dsfs__DocuSign_Status__c>();


        //filter only those docusign status records that belong to "Acquisition Offer"
        //this is achieved by looking if the lookup field to Acquisition Offer is populated or not
        for(dsfs__DocuSign_Status__c currDocuSignStatusRecord : newDocusignStatusRecords){
            if(currDocuSignStatusRecord.Acquisition_Offer__c != null){
                filteredDocuSignStatusRecords.add(currDocuSignStatusRecord);
            }
        }

        if(filteredDocuSignStatusRecords.size() > 0){
            updateParentAcquisitionOffer(filteredDocuSignStatusRecords);
        }
    }


    //methos to update an "Acquistion Offer" record's "Current Docusign Status" field with the status of the MOST recent child docusign status record
    public static void updateParentAcquisitionOffer(List<dsfs__DocuSign_Status__c> docuSignStatusRecords){
        
        //get IDs all parent "Acquisition Offer" records that need to be updated
        Set<Id> parentAcquisitionOfferIDs = new Set<Id>();
        for(dsfs__DocuSign_Status__c currentDocuSignStatusRecord : docuSignStatusRecords){
            parentAcquisitionOfferIDs.add(currentDocuSignStatusRecord.Acquisition_Offer__c);
        }

        //query all parent "Acquisition Offer" records along with its LATEST (most recent Created Date) docusign_Status record
        List<Acquisition_Offer__c> parentAcquisitionOffers = [SELECT Id, Current_DocuSign__c, 
                                                                  (select Id, dsfs__Envelope_Status__c from DocuSign_Status__r ORDER BY dsfs__Sent_Date_Time__c DESC limit 1)
                                                              FROM Acquisition_Offer__c 
                                                              WHERE Id in : parentAcquisitionOfferIDs];

        //Map Acquisition Offer to Docusign_Status's Envelope Status
        
        Map<Id, String> acqOfferIDToEnvelopeStatusMap = new Map<Id, String>();
        for(Acquisition_Offer__c currAcqOffer : parentAcquisitionOffers){
            acqOfferIDToEnvelopeStatusMap.put(currAcqOffer.Id, null);

            List<dsfs__DocuSign_Status__c> childDocuSignStatusRecords = new List<dsfs__DocuSign_Status__c>();
            childDocuSignStatusRecords.addAll(currAcqOffer.DocuSign_Status__r);

            if(childDocuSignStatusRecords.size()>0){
                acqOfferIDToEnvelopeStatusMap.put(currAcqOffer.Id, childDocuSignStatusRecords[0].dsfs__Envelope_Status__c);
            }
        }
        
        
        //if the "Envelope Status" field on Child Docusign Status record is not same as parent Acquistion Offer's "Current Docusign Status" field, then update the parent field
        //this logic ensures that if one of the older child "Docusign Status" record is updated, it doesn't change the parent Acquistion Offer's "Current Docusign Status" field
        //An Acquisition Offer's "Current Docusign Status" must always reflect the "Envelope Status" of the most recent Docusign_Status record
        List<Acquisition_Offer__c> acqOffersToBeUpdated = new List<Acquisition_Offer__c>();

        for(Acquisition_Offer__c currAcqOffer : parentAcquisitionOffers){
            if(currAcqOffer.Current_DocuSign__c != acqOfferIDToEnvelopeStatusMap.get(currAcqOffer.Id) ){
                currAcqOffer.Current_DocuSign__c = acqOfferIDToEnvelopeStatusMap.get(currAcqOffer.Id);
                acqOffersToBeUpdated.add(currAcqOffer);
            }
        }

        if(acqOffersToBeUpdated != null){
            update acqOffersToBeUpdated;
        }

    }
}