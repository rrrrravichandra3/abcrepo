/**
 * @description       : Apex contoller for LWC MA_RelatedAcquisitionRecords
 * @author            : Satyam Kumar
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   05-06-2021   Satyam Kumar   Initial Version
**/
public with sharing class MA_RelatedAcquisitionRecordsController {

    //Method to retrieve initial list of related Acquisition records.
    //used by LWC MA_RelatedAcquisitionRecords
    @AuraEnabled(cacheable=true)
    public static List<acquisitionWrapper> getAcquisitionWrapperList(String acquisitionObjectId, String objectName) {
        Id acqContactId = getAcquisitionContactId(acquisitionObjectId, objectName);   
        List<acquisitionWrapper> allacquisitionWrappers = new List<acquisitionWrapper>();
        Acquisition_Contacts__c acqContact;

        if(String.isNotBlank(acqContactId)) {
            acqContact = getAcqContactInfo(acqContactId);
        }
        
        if(acqContact != null) {
            if(String.isNotBlank(acqContact.Id) && String.isNotBlank(acqContact.Name)) {
                allacquisitionWrappers.add(new acquisitionWrapper('Acquisition Contact', '/'+acqContact.Id,acqContact.Name));
            }
            if(String.isNotBlank(acqContact.Acquisition_Company__c) && String.isNotBlank(acqContact.Acquisition_Company_Name__c)) {
                allacquisitionWrappers.add(new acquisitionWrapper('Acquisition Company', '/'+acqContact.Acquisition_Company__c,acqContact.Acquisition_Company_Name__c));
            }
            if(acqContact.Acquisition_Provisioning__r != null && acqContact.Acquisition_Provisioning__r.size() != 0) {
                allacquisitionWrappers.add(new acquisitionWrapper('Acquisition Provisioning', '/'+acqContact.Acquisition_Provisioning__r[0].Id,acqContact.Acquisition_Provisioning__r[0].Name));
            }
        }
        return allacquisitionWrappers;
    }

    //Method to retrieve acquisition contact Id
    private static Id getAcquisitionContactId(String acquisitionObjectId, String objectName) {
        
        if(String.isNotBlank(acquisitionObjectId) && String.isNotBlank(objectName)) {
          if(objectName.equalsIgnoreCase('Acquisition_Contacts__c')) {
              return acquisitionObjectId;
            }
            else if(objectName.equalsIgnoreCase('Acquisition_Compensation__c')) {
                Acquisition_Compensation__c acqComp = getAcqCompensationInfo(acquisitionObjectId);
                return acqComp.Acquisition_Contact__c;
            }
            else if(objectName.equalsIgnoreCase('Acquisition_Provisioning__c')) {
                Acquisition_Provisioning__c acqProv = getAcqProvisioningInfo(acquisitionObjectId);
                return acqProv.Acquisition_Contact__c;
            }
        }
            return null;
    }

    public class acquisitionWrapper {
        @AuraEnabled
        public String objectName ;
        @AuraEnabled
        public String recordName ;
        @AuraEnabled
        public String recordUrl;

        public acquisitionWrapper(String objectName, String recordUrl, String recordName){
            this.objectName = objectName;
            this.recordName = recordName;
            this.recordUrl = recordUrl;
        }
    }
    
	public static Acquisition_Contacts__c getAcqContactInfo(Id recordId){
        return new ElevatedContext().performAcqContactQuery(recordId);
    }
    
    public static Acquisition_Compensation__c getAcqCompensationInfo(Id recordId){
        return new ElevatedContext().performAcqCompensationQuery(recordId);
    }
    
    public static Acquisition_Provisioning__c getAcqProvisioningInfo(Id recordId){
        return new ElevatedContext().performAcqProvisioningQuery(recordId);
    }

    private without sharing class ElevatedContext{
        //Keep the class without sharing. MA ES permission set doesn't have read all access to related Acquisition records
        public Acquisition_Contacts__c performAcqContactQuery(Id  recordId){
            return [Select Id, Name, Acquisition_Company__c, Acquisition_Company_Name__c,
                                                (Select Id,Name from Acquisition_Provisioning__r limit 1)
                                                 From Acquisition_Contacts__c Where Id=:recordId];
        }
        
        public Acquisition_Compensation__c performAcqCompensationQuery(Id  recordId){
            return [Select Acquisition_Contact__c From Acquisition_Compensation__c Where Id =: recordId];
        }
        
        public Acquisition_Provisioning__c performAcqProvisioningQuery(Id  recordId){
            return [Select Acquisition_Contact__c From Acquisition_Provisioning__c Where Id =: recordId];
        }
    }
}