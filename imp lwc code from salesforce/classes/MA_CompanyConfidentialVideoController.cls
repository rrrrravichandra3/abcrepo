/**
* W-10947662
* M&A Preboarding App - Ablity to share salesforce videos with community users
* 
* Version      Date            Author                  Description
* -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         05/04/2022      Ashutosh Belwal         This class is used as controller for lwc component to retrive company specific videos and display in community
* -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public without sharing class MA_CompanyConfidentialVideoController {
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to retreive content version of all company videos
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param        	 	 
    * @return	List<ContentVersion>
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled(cacheable=true)
    public static List<ContentVersion> getContentVersionList(String recordId){
        Id companyVideoRecordId = getCompanyVideoRecord(recordId);
        
        List<ContentVersion> lstContentVersion =  new  List<ContentVersion>();
        if(companyVideoRecordId != null){

            Set<Id> contentDocumentIds = new Set<Id>();
            for(ContentDocumentLink objCDL : [SELECT Id, ContentDocumentId 
                                              FROM ContentDocumentLink 
                                              WHERE LinkedEntityId =: companyVideoRecordId])
            {
                contentDocumentIds.add(objCDL.ContentDocumentId);
            }
           
            
            if(contentDocumentIds.size() > 0){
               lstContentVersion = [SELECT Id, Title, Description, ContentDocumentId, ContentSize, FileType, FileExtension, CreatedBy.Name
                                    FROM ContentVersion 
                                    WHERE ContentDocumentId =: contentDocumentIds
                                    ORDER BY CreatedDate DESC ];
            }
        }
        return lstContentVersion;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to retreive the instance of community video record
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param        	 	 
    * @return	Instance of MA_Community_Videos__c
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Id getCompanyVideoRecord(String recordId){
        Id companyVideoRecordId;
        if(recordId == null){
            User userRecord = [SELECT Id, Contact.Acquisition_Contacts__c, Contact.Acquisition_Contacts__r.Acquisition_Company__c 
                          FROM User 
                          WHERE Id =: UserInfo.getUserId()
                          LIMIT 1];
            // for home page
            recordId = userRecord.Contact.Acquisition_Contacts__r.Acquisition_Company__c;
           
        }
       
        String objectName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();

        List<MA_Community_Videos__c> lstCompanyVideo = new List<MA_Community_Videos__c>();

        List<MA_Company_Video_Config__mdt> lstConfig = new List<MA_Company_Video_Config__mdt>([ SELECT Id, Field_Name__c 
                                                                                                FROM MA_Company_Video_Config__mdt 
                                                                                                WHERE Object_Name__c =: objectName
                                                                                                LIMIT 1]);
        if(!lstConfig.isEmpty() && lstConfig[0].Field_Name__c != null){
            String query = 'SELECT Id FROM MA_Community_Videos__c WHERE '+lstConfig[0].Field_Name__c+' =: recordId';
            lstCompanyVideo = (List<MA_Community_Videos__c>)Database.query(query);
            if(lstCompanyVideo.size() > 0){
                companyVideoRecordId = lstCompanyVideo[0].Id;
            }
        }
       
       
        return companyVideoRecordId;
        
    }
}