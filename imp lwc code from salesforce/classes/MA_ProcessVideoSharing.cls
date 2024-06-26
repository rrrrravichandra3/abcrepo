/**
* W-10947662
* M&A Preboarding App - [Wayfinder Videos] Embed video in Wayfinder knowledge article
* 
* Version      Date            Author                  Description
* -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         04/05/2022      Ashutosh Belwal         This Class generates video sharing records based on Data Category Assignment on Knowledge Articles
* -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public class MA_ProcessVideoSharing implements Queueable {

    Id articleId;
    Set<String> stAssignedDataCategories 	 = new Set<String>();
    MA_Community_Videos__c objCommunityVideo = new MA_Community_Videos__c();
    Map<String, String> dataCategoryVsGroup	 = new Map<String, String>();
    Map<Id, MA_Community_Videos__share> groupVsShareRecordOld = new Map<Id, MA_Community_Videos__share>();
    Map<String, MA_Community_Videos__share> dataCatVsShareRecord = new Map<String, MA_Community_Videos__share>();
    
    public MA_ProcessVideoSharing(Id articleId) {
        this.articleId = articleId;
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable interface method to check and generate sharing record as per data category assignment.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    qContext    DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void execute(QueueableContext qContext) {
        List<MA_Community_Videos__share> lstDeleteShareRecords = new List<MA_Community_Videos__share>();
        List<MA_Community_Videos__share> lstInsertShareRecords = new List<MA_Community_Videos__share>();
        
        getAssignedDataCategories(articleId);
        getKnowledgeVideoRecord(articleId);
        getKnowledgeSharingConfig(stAssignedDataCategories);
        
        if(objCommunityVideo != null) {
            getVideoShareRecord(objCommunityVideo.Id);
            if(stAssignedDataCategories.isEmpty() && !groupVsShareRecordOld.isEmpty()) {
                lstDeleteShareRecords.addAll(groupVsShareRecordOld.values());
            }else {
                prepareDMLRecords(lstDeleteShareRecords, lstInsertShareRecords);
            }
        }
        
        if(lstDeleteShareRecords.size() > 0) deleteVideoShareRecords(lstDeleteShareRecords);
        if(lstInsertShareRecords.size() > 0) insertVideoShareRecords(lstInsertShareRecords);
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to prepare the list of records for insertion and deletion
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void prepareDMLRecords(List<MA_Community_Videos__share> lstDeleteShareRecords,
                                   List<MA_Community_Videos__share> lstInsertShareRecords) {
        Set<Id> sharedGroupIds = new Set<Id>();
        
        for(String dataCategoryName : stAssignedDataCategories) {
            Id publicGroupId = dataCategoryVsGroup.get(dataCategoryName);
            if(groupVsShareRecordOld.get(publicGroupId) == null) {
                lstInsertShareRecords.add(new MA_Community_Videos__share(ParentId = objCommunityVideo.Id,
                                                                         UserOrGroupId = publicGroupId, 
                                                                         AccessLevel = 'Read'));
            }
            sharedGroupIds.add(publicGroupId);
        }
        
        groupVsShareRecordOld.keySet().removeAll(sharedGroupIds);
        lstDeleteShareRecords.addAll(groupVsShareRecordOld.values());
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to prepare list Datacategory Associated to an Knowledge Article
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void getAssignedDataCategories(Id articleId) {
        for(Knowledge__DataCategorySelection objSelection : [SELECT ParentId, DataCategoryGroupName, DataCategoryName 
                                                             FROM Knowledge__DataCategorySelection 
                                                             WHERE ParentId =: articleId]) {
            stAssignedDataCategories.add(objSelection.DataCategoryGroupName+'.'+objSelection.DataCategoryName);
        }
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to prepare list Datacategory Associated to an Knowledge Article
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void getKnowledgeVideoRecord(Id articleId) {
        List<MA_Community_Videos__c> lstCommunityVideo = new List<MA_Community_Videos__c>([SELECT Id 
                                                                                           FROM MA_Community_Videos__c 
                                                                                           WHERE Knowledge__c =: articleId
                                                                                           LIMIT 1]);
        if(lstCommunityVideo.size() > 0){
            objCommunityVideo = lstCommunityVideo[0];
        }
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to prepare the map of UserOrGroupId and Knowledge Video Share records
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    
    private void getVideoShareRecord(Id videoRecordId) {
        for(MA_Community_Videos__share objShare : [SELECT Id, ParentId, UserOrGroupId, AccessLevel 
                                                   FROM MA_Community_Videos__share 
                                                   WHERE ParentId =: videoRecordId]) {
            groupVsShareRecordOld.put(objShare.UserOrGroupId, objShare);
        }       
    }
    
	/**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to prepare the map of Datactegory vs UserOrGroupId
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */    
    private void getKnowledgeSharingConfig(Set<String> stAssignedDataCategories) {
        for(MA_Knowledge_Article_Permissions__c objKAPermission : [SELECT Id, Data_Category_Name__c, Public_Group_Id__c  
                                                                   FROM MA_Knowledge_Article_Permissions__c
                                                                   WHERE Data_Category_Name__c IN: stAssignedDataCategories]) {
            dataCategoryVsGroup.put(objKAPermission.Data_Category_Name__c, objKAPermission.Public_Group_Id__c);
        }
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to perform Delete operation
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void deleteVideoShareRecords(List<MA_Community_Videos__share> videoShareRecords) {
        Database.DeleteResult[] delteResults = Database.delete(videoShareRecords, false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(delteResults, MA_AbstractLogger.BulkLoggerType.DELETE_RESULT);
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to perform Insert operation
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void insertVideoShareRecords(List<MA_Community_Videos__share> videoShareRecords) {
        Database.SaveResult[] srList = Database.insert(videoShareRecords, false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(srList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
    }
    
}