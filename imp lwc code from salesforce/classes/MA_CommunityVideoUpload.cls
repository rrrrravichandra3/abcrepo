/**
* W-10853278 - Controller class for Filter Criteria LWC Component
* 
* Version      Date            Author                  Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         08-04-2022      Ashutosh Belwal         Initial Version
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public without sharing class MA_CommunityVideoUpload {
	public class CustomException extends Exception {}
    
    private static final String METADATA_MISSING_ERROR = Label.MA_Company_Video_Metadata_Missing;
    private static final String PUBLIC_GROUP_MISSING_ERROR = Label.MA_Public_Group_Missing_Error;
    private static final String KA_PUBLIC_GROUP_MISSING_ERROR = Label.MA_KA_Public_Group_Missing_Error;
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Genrates map of Company Video Id vs Content Vesrsion records
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    String                          DESCRIPTION (Data type String, Record Id)
    * @return   Map<Id, List<ContentVersion>>   DESCRIPTION (returns ap of Company Video Id vs Content Vesrsion records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled       
    public static Map<Id, List<ContentVersion>> getRecordDetails(String recordId) {

        try {
            String sObjName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
            Map<Id, List<ContentVersion>> companyVideosMap = new Map<Id, List<ContentVersion>>();

            MA_Community_Videos__c objCompanyVideo = getCommunityVideoInstance(sObjName, recordId);
            
            if(objCompanyVideo.Id == null){
                prepareSharingRecord(sObjName, recordId, objCompanyVideo);
                companyVideosMap.put(objCompanyVideo.Id , new List<ContentVersion>());
            }else{
                Set<Id> contentDocumentIds = new Set<Id>();
                companyVideosMap.put(objCompanyVideo.Id , new List<ContentVersion>());
                for(ContentDocumentLink objCDL : [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: objCompanyVideo.Id]){
                    contentDocumentIds.add(objCDL.ContentDocumentId);
                }
                
                if(contentDocumentIds.size() > 0){
                    List<ContentVersion> lstContentVersion = [SELECT Id, Title, Description, ContentDocumentId, ContentSize, FileType, FileExtension, CreatedBy.Name
                                                                FROM ContentVersion 
                                                                WHERE ContentDocumentId =: contentDocumentIds
                                                                ORDER BY CreatedDate DESC ];
                    companyVideosMap.put(objCompanyVideo.Id , lstContentVersion);
                }
            }
            
            return companyVideosMap;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }   
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method holds the logic to create dynamic query to retreive related MA_Community_Videos__c record
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    objectName            DESCRIPTION (Data type String,Current record objectname)
    * @return   objCompanyVideo       DESCRIPTION (Data type MA_Community_Videos__c, Custom video related record Instance)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled       
    public static MA_Community_Videos__c getCommunityVideoInstance(String objectName, String recordId) {
        try {
            List<MA_Community_Videos__c> lstCompanyVideo = new List<MA_Community_Videos__c>();

            List<MA_Company_Video_Config__mdt> lstConfig = new List<MA_Company_Video_Config__mdt>([ SELECT Id, Field_Name__c 
                                                                                                    FROM MA_Company_Video_Config__mdt 
                                                                                                    WHERE Object_Name__c =: objectName
                                                                                                   LIMIT 1]);
            system.debug('lstConfig*** '+lstConfig); 
            if(!lstConfig.isEmpty() && lstConfig[0].Field_Name__c != null){

                String query = 'SELECT Id FROM MA_Community_Videos__c WHERE '+lstConfig[0].Field_Name__c+' =: recordId';
                lstCompanyVideo = (List<MA_Community_Videos__c>)Database.query(query);
                if(lstCompanyVideo.isEmpty() && objectName.toLowerCase() == 'Knowledge__kav'.toLowerCase()){
                    lstCompanyVideo = checkExistingKAV(recordId);    
                }
                
                if(!lstCompanyVideo.isEmpty()){
                    return lstCompanyVideo[0];
                }else{
                    MA_Community_Videos__c objCompanyVideo = new MA_Community_Videos__c();
                    objCompanyVideo.put(lstConfig[0].Field_Name__c, recordId);
                    return objCompanyVideo;
                }
            }else{
                throw new CustomException(METADATA_MISSING_ERROR);
            }
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }               
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method holds the logic to move video record from previous KAV to current KAV
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    recordId            DESCRIPTION (Data type String,curren record Id)
    * @return   Void               
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<MA_Community_Videos__c> checkExistingKAV(String recordId){
        
        List<MA_Community_Videos__c> lstVideos = new List<MA_Community_Videos__c>();
        Id knowledgeArticleId = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id =: recordId].KnowledgeArticleId;
        Set<Id> kavIds = new Set<Id>();
        for(Knowledge__kav objKAV: [SELECT Id FROM Knowledge__kav 
                                    WHERE KnowledgeArticleId =:knowledgeArticleId ])
        {
            kavIds.add(objKAV.Id);
        }

        lstVideos = [SELECT Id FROM MA_Community_Videos__c WHERE  Knowledge__c IN: kavIds LIMIT 1];
        if(!lstVideos.isEmpty()){
            lstVideos[0].Knowledge__c = recordId;
            update lstVideos;
        }
		return lstVideos;
    }


    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method holds the logic to process any information update of Content Version
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    sObject            DESCRIPTION (Data type sObject,Instance of Content Version)
    * @return   Void               
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled       
    public static void updateData(sObject objContentVersion) {
        try {
            update objContentVersion;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method holds the logic to enable documents to community users
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    contentDocumentId            DESCRIPTION (Data type Id)
    * @return   Void               
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled       
    public static void updateContentDocumentLink(Id contentDocumentId) {
        try {
            List<ContentDocumentLink> lstCDLtoUpdate = new List<ContentDocumentLink>();

            
            for(ContentDocumentLink objDocumentLink : [SELECT Id, Visibility, LinkedEntityId
                                                       FROM ContentDocumentLink 
                                                       WHERE ContentDocumentId =: contentDocumentId ])
            {
                String sObjName = objDocumentLink.LinkedEntityId.getSObjectType().getDescribe().getName();
                if(sObjName.toLowerCase() == 'MA_Community_Videos__c'.toLowerCase()){
                    objDocumentLink.Visibility = 'AllUsers';
                    lstCDLtoUpdate.add(objDocumentLink);
                }
                update objDocumentLink;
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method holds the logic to Deletes ContentDocument record
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    Id            DESCRIPTION (Data type Id, Content Document Id)
    * @return   Void          
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled
    public static void deleteFile(Id contentDocumentId){
        try{
            delete new ContentDocument(Id = contentDocumentId);
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method holds the logic to check public group setup for knowledge Article
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    Id            DESCRIPTION (Data type Id, articleId)
    * @return   Void          
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void checkPublicGroupForKnowledge(Id articleId){
        
        Set<String> stAssignedDataCategories = new Set<String>();
        for(Knowledge__DataCategorySelection objSelection : [SELECT ParentId, DataCategoryGroupName, DataCategoryName 
                                                             FROM Knowledge__DataCategorySelection 
                                                             WHERE ParentId =: articleId])
        {
            stAssignedDataCategories.add(objSelection.DataCategoryGroupName+'.'+objSelection.DataCategoryName);
        }

        List<MA_Knowledge_Article_Permissions__c> lstArticlePermissions = [SELECT Id, Data_Category_Name__c, Public_Group_Id__c  
                                                                            FROM MA_Knowledge_Article_Permissions__c
                                                                            WHERE Data_Category_Name__c IN: stAssignedDataCategories];
        if(lstArticlePermissions.size() != stAssignedDataCategories.size()){
            throw new CustomException(KA_PUBLIC_GROUP_MISSING_ERROR);
        }       

    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method holds the logic to prepare sharing instance
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    String            DESCRIPTION (Data type String, Current Record Objectname)
    * @param    String            DESCRIPTION (Data type String,Current recordId)
    * @param    Id                DESCRIPTION (Data type Id, Custom video related record Id)
    * @return   void          
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void prepareSharingRecord(String sObjName, String recordId, MA_Community_Videos__c videoRecord){
        if(sObjName.toLowerCase() == 'Acquisition_Company__c'.toLowerCase()){
            List<MA_Community_Video_Mapping__c> lstCommunityMapping = [ SELECT Public_Group_Id__c 
                                                                        FROM MA_Community_Video_Mapping__c 
                                                                        WHERE Company_Id__c =: recordId 
                                                                        LIMIT 1];
            
            if(lstCommunityMapping.isEmpty()){
                throw new CustomException(PUBLIC_GROUP_MISSING_ERROR);
            }
            insert videoRecord;
            ProcessVideoSharing objQueueable = new ProcessVideoSharing(videoRecord.Id , lstCommunityMapping[0].Public_Group_Id__c);
            System.enqueueJob(objQueueable);
        }else{
            if(sObjName.toLowerCase() == 'Knowledge__kav'.toLowerCase()){
                checkPublicGroupForKnowledge(recordId);
            }

            insert videoRecord;
            // if videos uploaded after the knowledge article published
            if(sObjName.toLowerCase() == 'Knowledge__kav'.toLowerCase()){
                System.enqueueJob(new MA_ProcessVideoSharing(recordId));
            }
        }
    }

    


    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Class process Company video record and share Company video record to Acqisition Contacts
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class ProcessVideoSharing implements Queueable {

        private Id videoRecordId;
        private Id publicGroupId;
       

        public ProcessVideoSharing(Id videoRecordId, Id publicGroupId){
           this.videoRecordId = videoRecordId;
           this.publicGroupId = publicGroupId;
        }
         
        public void execute(QueueableContext context) {
            
            MA_Community_Videos__Share objRecordShare = new MA_Community_Videos__Share(
                                                                                        ParentId        = videoRecordId,
                                                                                        UserOrGroupId   = publicGroupId,
                                                                                        AccessLevel     = 'Read'
                                                                                    );
            Database.SaveResult[] srList = Database.insert(new List<sObject>{objRecordShare}, false);
            MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(srList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
           
        }
    }
   
  
}