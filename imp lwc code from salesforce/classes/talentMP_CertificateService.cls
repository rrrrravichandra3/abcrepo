/**
 * @description       : 
 * @author            : Priyanka Kanani
 * @group             : 
 * @last modified on  : 15-12-2023
 * @last modified by  : Priyanka Kanani
**/
public with sharing class talentMP_CertificateService {
   

    @AuraEnabled
    public static List<Certifications__c> getCertificatesSearchResult(String CertificateName, List<String> existingCertifications){
        List<Certifications__c> certificationList = new List<Certifications__c>();
        certificateName = String.escapeSingleQuotes(CertificateName);

        String query = 'Select Id, Name FROM Certifications__c WHERE Name LIKE \'%' +
                        certificateName.trim() +
                        '%\' and Id NOT IN: existingCertifications ORDER BY Name ASC';
        
        try{
            certificationList = Database.query(query);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return certificationList; 
    }

   

    @AuraEnabled
    public static CertificationAssignmentWrapper getCertificateAssignments(){
        CertificationAssignmentWrapper certificationassignmentWrapper = New CertificationAssignmentWrapper();
        String userId = UserInfo.getUserId();
        system.debug('UserId**** '+userId);
        User usr = [Select id, EmployeeNumber FROM User WHERE id=:userId];
        try {
            List<Certification_Assignment__c> assignments = [SELECT Id, Certifications__c, Certifications__r.Name,Contact__c
                                                FROM Certification_Assignment__c
                                                WHERE Contact__r.EmployeeNumber__c =: usr.EmployeeNumber];
            certificationassignmentWrapper.certificationAssignments = assignments;
            certificationassignmentWrapper.certificationContentVersionMap = getCertificationContentVersionMap();
            certificationassignmentWrapper.certificationIdName = getCertificationIdNameMap(assignments, certificationassignmentWrapper.certificationContentVersionMap);
            
            return certificationassignmentWrapper;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static Map<String,String> getcertificationContentVersionMap(){
        Map<String,String> certificationContentVersionMap = new Map<String,String>();
        Map<Id, Certifications__c> certificationMap = new Map<Id, Certifications__c>([SELECT Id FROM Certifications__c]);
        Map<String,String> contentDocAndEntityMap= new Map<String,String>();
        for(ContentDocumentLink objCDL : [SELECT Id, ContentDocumentId, LinkedEntityId
                                            FROM ContentDocumentLink 
                                            WHERE LinkedEntityId IN :certificationMap.keySet()])
        {
            contentDocAndEntityMap.put(objCDL.ContentDocumentId, objCDL.LinkedEntityId);
        }
        for(ContentVersion contentVer : [SELECT Id, Title, Description, ContentDocumentId, ContentSize, FileType, FileExtension, CreatedBy.Name
                                                FROM ContentVersion 
                                                WHERE ContentDocumentId =: contentDocAndEntityMap.keySet()
                                                ORDER BY CreatedDate DESC ]){
                certificationContentVersionMap.put(contentDocAndEntityMap.get(contentVer.ContentDocumentId), contentVer.id);                                     

        }
        return certificationContentVersionMap;
    }

    public static List<CertificationWrapper> getCertificationIdNameMap(List<Certification_Assignment__c> assignments, Map<String,String> certificationContentVersionMap){
        Map<String,String> certificationIdNameMap = new Map<String,String>();
        List<CertificationWrapper> certificationIdNameList= new  List<CertificationWrapper>();
        Map<Id, Certifications__c> certificationMap = new Map<Id, Certifications__c>([SELECT Id FROM Certifications__c]);
        Map<String,String> contentDocAndEntityMap= new Map<String,String>();
        for(Certification_Assignment__c assignment : assignments)
        {
            CertificationWrapper wrap = new CertificationWrapper();
            wrap.Id = assignment.Certifications__c;
            wrap.Name =  assignment.Certifications__r.Name;
            certificationIdNameList.add(wrap);
        }
    
        return certificationIdNameList;
    }

    @AuraEnabled
    public static void removeCertificateAssignments(List<String> certificationIds){       
        try {
            if(!certificationIds.isEmpty()){
                delete [SELECT Id FROM Certification_Assignment__c WHERE Certifications__c IN :certificationIds];
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void processNewCertificateAssignments(List<String> certificationIds){ 
        String userId = UserInfo.getUserId();
        User usr = [SELECT id, EmployeeNumber FROM User WHERE id =: userId];
        Id contactId = [SELECT Id, EmployeeNumber__c FROM Contact WHERE EmployeeNumber__c =: usr.EmployeeNumber].Id;

            if(!certificationIds.isEmpty()){
                  addCertificationAssignment(certificationIds, contactId);
              }
        }

    private static void addCertificationAssignment(List<String> certificationIds, Id contactId){
        List<Certification_Assignment__c> listNewCertificateAssignments = new List<Certification_Assignment__c>();
            for(String certificationId : certificationIds){
                listNewCertificateAssignments.add(new Certification_Assignment__c(Certifications__c = certificationId, Contact__c = contactId));
            }
            try {
                insert listNewCertificateAssignments;
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
    }

    @AuraEnabled
    public static Id createCertificate(String certificateName, String title, String base64Data) {

        Id contactId = [SELECT Id,ContactId FROM User WHERE Id =:UserInfo.getUserId()].ContactId;
        
        Certifications__c newCertificate = new Certifications__c(Name = certificateName);
        insert newCertificate;

       if(!String.isBlank(base64Data)){
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = title;
        contentVersion.VersionData = EncodingUtil.base64Decode(base64Data);
        contentVersion.PathOnClient = title; // You might want to adjust this based on your needs
        insert contentVersion;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;
        cdl.LinkedEntityId = newCertificate.Id;// Linking to the user for example; adjust as needed
        cdl.ShareType = 'V'; // Viewer permission, adjust as needed
        cdl.Visibility = 'AllUsers'; // Adjust based on your sharing requirements
        insert cdl;
       }
        
        Certification_Assignment__c certificateAssignment = new Certification_Assignment__c(
            Certifications__c = newCertificate.Id,
            Contact__c = contactId
        );
        insert certificateAssignment;
        
        return certificateAssignment.Id;
    }
  
    public class CertificationAssignmentWrapper{
        @AuraEnabled
        public List<Certification_Assignment__c> certificationAssignments { get; set; }
        @AuraEnabled
        public List<CertificationWrapper> certificationIdName { get; set; }
        @AuraEnabled
        public Map<String,String> certificationContentVersionMap { get; set; }
    }
    public class CertificationWrapper{
        @AuraEnabled
        public String Id { get; set; }
        @AuraEnabled
        public String Name { get; set; }
        @AuraEnabled
        public String Image { get; set; }
    }
}