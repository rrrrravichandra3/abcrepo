/**
 * W-10678114, W-10800884, W-11054257
 * Controller class of maGenerateCompanyPermissionSet (LWC component) to create Data Category Sharing Permission Sets 
 * and Custom Setting records.
 * 
 * Version   Date          Author               Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0      24-02-2022    Ashutosh Belwal      Initial Version
 * v2.0      11-03-2022    Chakshu Malhotra     W-10800884 - Converted to lwc quick action controller class
 * v3.0      05-05-2022    Chakshu Malhotra     W-11054257 - Added logic to create & add public group reference in Content Permission records
 * --------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_GenerateCompanyPermissionSet {
    private static final String MISSING_CATEGORY_EXCEPTION = Label.MA_Missing_Data_Category_Exception;
    private static final String INVALID_CATEGORY_GROUP_EXCEPTION = Label.MA_Invalid_Data_Category_Group_Exception;
    private static final String UNKNOWN_CATEGORY_FORMAT_EXCEPTION = Label.MA_Unknown_Data_Category_Format_Exception;
    private static final String INVALID_TOP_LEVEL_CATEGORY_EXCEPTION = Label.MA_Invalid_Top_Level_Data_Category_Exception;

    private static final String NOTIFICATION_TITLE = Label.MA_Generate_Permission_Sets_Title;
    private static final String CONFIG_TYPE_GENERATE_PERMISSION_SET = Label.MA_Messaging_Config_Type_Generate_Company_Permission_Set;

    private class ContentPermissionWrapper {
        String fieldAPIName;
        String dataCategoryName;
        Group contentSharingPublicGroup;
        PermissionSet contentSharingPermissionSet;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to create Permission Sets, Public Groups for article content visibility and add details as Custom Setting records
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param        companyId	 	 DESCRIPTION (Data type String, Acquistion Company record Id)
    * @return	
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled
    public static void setupContentSharingPermissions(String companyId) {
        Acquisition_Company__c company = getCompanyDetails(companyId);

        try {
            if(!company.Permission_Sets_Created__c && String.isNotBlank(company.Category_API_Name__c)) {
                Group companyContentSharingGroup = getCompanyContentSharingGroup(company.Name);
                Map<String, ContentPermissionWrapper> permissionMapping = getCategoryLabelToPermissionMapping(company.Name);
                system.debug('permissionMapping**** '+permissionMapping);
                Map<String, String> dataCategoryMap = MA_ContentEnrolmentHelper.getDataCategoryMap(company.Category_API_Name__c);
                system.debug('dataCategoryMap**** '+dataCategoryMap);
                MA_ContentEnrolmentHelper.throwExceptionIfMissingCategories(permissionMapping.keySet(), dataCategoryMap.keySet());
                processContentSharingPermissions(company, companyContentSharingGroup, permissionMapping, dataCategoryMap);
            }
        }catch(MA_ContentEnrolmentHelper.UnknownDataCategoryFormatException exType) {
            throw new AuraHandledException(String.format(UNKNOWN_CATEGORY_FORMAT_EXCEPTION, MA_ContentEnrolmentHelper.EXCEPTION_PARAMETERS));
        }catch(InvalidParameterValueException exType) {
            throw new AuraHandledException(INVALID_CATEGORY_GROUP_EXCEPTION);
        }catch(MA_ContentEnrolmentHelper.MissingDataCategoryGroupException exType) {
            throw new AuraHandledException(INVALID_CATEGORY_GROUP_EXCEPTION);
        }catch(MA_ContentEnrolmentHelper.InvalidTopLevelDataCategoryException exType) {
            throw new AuraHandledException(INVALID_TOP_LEVEL_CATEGORY_EXCEPTION);
        }catch(MA_ContentEnrolmentHelper.MissingDataCategoryException exType) {
            throw new AuraHandledException(String.format(MISSING_CATEGORY_EXCEPTION, MA_ContentEnrolmentHelper.EXCEPTION_PARAMETERS));
        }catch(Exception exType) {
            throw new AuraHandledException(exType.getMessage() + ' ' + exType.getStackTraceString());
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get Acquisition_Company__c record details.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    companyId	 	        DESCRIPTION (Data type String, Acquistion Company record Id)
    * @return   Acquisition_Company__c  DESCRIPTION (return Acquisition_Company__c record)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Acquisition_Company__c getCompanyDetails(String companyId) {
        return [SELECT Id, Name, Acquisition_Company_Name__c, Category_API_Name__c, Permission_Sets_Created__c 
                FROM Acquisition_Company__c 
                WHERE Id = :Id.valueOf(companyId) LIMIT 1];
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get content sharing public group for the company.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    companyName	    DESCRIPTION (Data type String, Acquistion Company name)
    * @return   Group           DESCRIPTION (return Content sharing public group)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Group getCompanyContentSharingGroup(String companyName) {
        String publicGroupName = ('MA' + ' ' + companyName + ' Video Group').left(39);
        String publicGroupDevName = ('MA_' + companyName.replace(' ', '_') + '_Video_Group').left(79);
        return getPublicGroup(publicGroupName, publicGroupDevName);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create Public Group for sharing company content.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    groupName	            DESCRIPTION (Data type String, Name of the public group)
    * @param    groupDeveloperName	    DESCRIPTION (Data type String, DeveloperName of the public group)
    * @return   Group                   DESCRIPTION (return Content sharing public group)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Group getPublicGroup(String groupName, String groupDeveloperName) {
        Group publicGroup = new Group();
        publicGroup.Type = 'Regular';
        publicGroup.Name = groupName;
        publicGroup.DoesIncludeBosses = false;
        publicGroup.DoesSendEmailToMembers = false;
        publicGroup.DeveloperName = groupDeveloperName;
        return publicGroup;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get Map of data category label to ContentPermissionWrapper type.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    companyName	 	                        DESCRIPTION (Data type String, Acquistion Company name)
    * @return   Map<String, ContentPermissionWrapper>   DESCRIPTION (return Map of data category label to ContentPermissionWrapper type)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<String, ContentPermissionWrapper> getCategoryLabelToPermissionMapping(String companyName) {
        Map<String, ContentPermissionWrapper> permissionMapping = new Map<String, ContentPermissionWrapper>();
        
        for(MA_Knowledge_Sharing_Master_Data__mdt contentSharingData : MA_Knowledge_Sharing_Master_Data__mdt.getAll().values()) {
            if(String.isNotBlank(contentSharingData.Data_Category_Label__c)) {
                ContentPermissionWrapper wrapperObj = getContentPermissionWrapper(contentSharingData, companyName);
                permissionMapping.put(contentSharingData.Data_Category_Label__c, wrapperObj);
            }
        }

        return permissionMapping;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get wrapper instance of ContentPermissionWrapper type.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    contentSharingData	        DESCRIPTION (Data type MA_Knowledge_Sharing_Master_Data__mdt, Content Sharing Maste Data type)
    * @param    companyName	 	            DESCRIPTION (Data type String, Acquistion Company name)
    * @return   ContentPermissionWrapper    DESCRIPTION (return wrapper instance of ContentPermissionWrapper type)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static ContentPermissionWrapper getContentPermissionWrapper(MA_Knowledge_Sharing_Master_Data__mdt contentSharingData, String companyName) {
        ContentPermissionWrapper wrapperObj = new ContentPermissionWrapper();
        wrapperObj.fieldAPIName = contentSharingData.Field_API_Name__c;
        wrapperObj.dataCategoryName = contentSharingData.DeveloperName;
        wrapperObj.contentSharingPublicGroup = getContentSharingPublicGroup(contentSharingData, companyName);
        wrapperObj.contentSharingPermissionSet = getContentSharingPermissionSet(contentSharingData, companyName);
        return wrapperObj;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get Public Group for content sharing.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    contentSharingData	    DESCRIPTION (Data type MA_Knowledge_Sharing_Master_Data__mdt, Content Sharing Maste Data type)
    * @param    companyName	 	        DESCRIPTION (Data type String, Acquistion Company name)
    * @return   Group                   DESCRIPTION (return Public Group for content sharing)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Group getContentSharingPublicGroup(MA_Knowledge_Sharing_Master_Data__mdt contentSharingData, String companyName) {
        String publicGroupName = (contentSharingData.Data_Category_Label__c + ' ' + companyName + ' ' + 'Group').left(39);
        String publicGroupDevName = ('MA_' + companyName.replace(' ', '_') + '_' + contentSharingData.DeveloperName + '_Group').left(79);
        return getPublicGroup(publicGroupName, publicGroupDevName);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get PermissionSet for content sharing.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    contentSharingData	    DESCRIPTION (Data type MA_Knowledge_Sharing_Master_Data__mdt, Content Sharing Maste Data type)
    * @param    companyName	 	        DESCRIPTION (Data type String, Acquistion Company name)
    * @return   Group                   DESCRIPTION (return PermissionSet for content sharing)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static PermissionSet getContentSharingPermissionSet(MA_Knowledge_Sharing_Master_Data__mdt contentSharingData, String companyName) {
        String permissionSetName = ('MA_' + companyName.replace(' ', '_') + '_' + contentSharingData.DeveloperName + '_Permission').left(79);
        return new PermissionSet(Name = permissionSetName, Label = permissionSetName);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create public groups & permission sets & process content sharing permission custom setting records in a queueable (to avoid Mixed DML error) job.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    company	 	            DESCRIPTION (Data type Acquisition_Company__c, Acquistion Company record)
    * @param    permissionMapping	    DESCRIPTION (Data type Map, Map of data category label to ContentPermissionWrapper)
    * @param    dataCategoryMap         DESCRIPTION (Data type Map, Map of data category label to data category name)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void processContentSharingPermissions(Acquisition_Company__c company, Group companyContentSharingGroup, Map<String, ContentPermissionWrapper> permissionMapping, 
                                                         Map<String, String> dataCategoryMap) {
        Map<String, Group> csPublicGroupMap = new Map<String, Group>();
        Map<String, PermissionSet> csPermissionSetMap = new Map<String, PermissionSet>();

        csPublicGroupMap.put(companyContentSharingGroup.DeveloperName, companyContentSharingGroup);

        for(ContentPermissionWrapper wrapperObj : permissionMapping.values()) {
            csPermissionSetMap.put(wrapperObj.contentSharingPermissionSet.Name, wrapperObj.contentSharingPermissionSet);
            csPublicGroupMap.put(wrapperObj.contentSharingPublicGroup.DeveloperName, wrapperObj.contentSharingPublicGroup);
        }

        insertContentSharingGroupsAndPermissionSets(csPublicGroupMap.clone(), csPermissionSetMap.clone());

        if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
            System.enqueueJob(new ProcessContentSharingPermissions(company, companyContentSharingGroup, csPermissionSetMap.keySet(), csPublicGroupMap.keySet(), dataCategoryMap, permissionMapping));
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create permission sets & public groups for content (articles & videos) sharing.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    csPublicGroupMap        DESCRIPTION (Data type Map, Map of Group DeveloperName to Group)
    * @param    csPermissionSetMap      DESCRIPTION (Data type Map, Map of PermissionSet Name to PermissionSet)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void insertContentSharingGroupsAndPermissionSets(Map<String, Group> csPublicGroupMap, Map<String, PermissionSet> csPermissionSetMap) {
        for(String csGroupDevName : getContentSharingPublicGroupMap(csPublicGroupMap.keySet()).keySet()) {
            csPublicGroupMap.remove(csGroupDevName);
        }

        for(String csPermissionSetName : getContentSharingPermissionSetMap(csPermissionSetMap.keySet()).keySet()) {
            csPermissionSetMap.remove(csPermissionSetName);
        }

        if(!csPublicGroupMap.isEmpty()) {
            insert csPublicGroupMap.values();
        }

        if(!csPermissionSetMap.isEmpty()) {
            insert csPermissionSetMap.values();
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get list of Group records based on set of Group DeveloperName.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    publicGroupDevNames	    DESCRIPTION (Data type Set, Set of public groups developer names)
    * @return   List<PermissionSet>     DESCRIPTION (return List of PermissionSet records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<String, Group> getContentSharingPublicGroupMap(Set<String> publicGroupDevNames) {
        Map<String, Group> publicGroupMap = new Map<String, Group>();
        for(Group csPublicGroup : [SELECT Id, Name, DeveloperName FROM Group WHERE DeveloperName IN :publicGroupDevNames]) {
            publicGroupMap.put(csPublicGroup.DeveloperName, csPublicGroup);
        }
        return publicGroupMap;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get list of PermissionSet records based on set of PermissionSet Name.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    permissionSetNames	    DESCRIPTION (Data type Set, Set of permission set names)
    * @return   List<PermissionSet>     DESCRIPTION (return List of PermissionSet records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<String, PermissionSet> getContentSharingPermissionSetMap(Set<String> permissionSetNames) {
        Map<String, PermissionSet> csPermissionSetMap = new Map<String, PermissionSet>();
        for(PermissionSet csPermissionSet : [SELECT Id, Name FROM PermissionSet WHERE Name IN :permissionSetNames]) {
            csPermissionSetMap.put(csPermissionSet.Name, csPermissionSet);
        }
        return csPermissionSetMap;
    }
    
    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable class to prevent Mixed DML error and insert article permissions custom setting records asynchronously.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class ProcessContentSharingPermissions implements Queueable {
        private Acquisition_Company__c company;
        private Group companyContentSharingGroup;
        private Set<String> csPermissionSetNames;
        private Set<String> csPublicGroupDevNames;
        private Map<String, String> dataCategoryMap;
        private Map<String, ContentPermissionWrapper> permissionMapping;
        private List<MA_Knowledge_Article_Permissions__c> contentPermissions;
        private List<MA_Community_Video_Mapping__c> companyContentPermissions;

        public ProcessContentSharingPermissions() {
            this.contentPermissions = new List<MA_Knowledge_Article_Permissions__c>();
            this.companyContentPermissions = new List<MA_Community_Video_Mapping__c>();
        }

        public ProcessContentSharingPermissions(Acquisition_Company__c company, Group companyContentSharingGroup, Set<String> csPermissionSetNames, 
                                                Set<String> csPublicGroupDevNames, Map<String, String> dataCategoryMap, Map<String, ContentPermissionWrapper> permissionMapping) {
            this();
            this.company = company;
            this.dataCategoryMap = dataCategoryMap;
            this.permissionMapping = permissionMapping;
            this.csPermissionSetNames = csPermissionSetNames;
            this.csPublicGroupDevNames = csPublicGroupDevNames;
            this.companyContentSharingGroup = companyContentSharingGroup;
        }
        
        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Queueable interface method to process Knowledge Article Permisssions custom setting records.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    qContext    DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void execute(QueueableContext qContext) {
            updateCompanyRecord();
            upsertContentPermissions();
            processContentEnrolmentAndNotifyUser();
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to update acquisition company record to setPermission_Sets_Created__c flag to true.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void updateCompanyRecord() {
            company.Permission_Sets_Created__c = true;
            Database.update(company, false);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to upsert Knowledge Article Permissions & Community Video Mapping custom setting records based on Name field.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void upsertContentPermissions() {
            setupContentSharingPermissions();
            Database.UpsertResult[] cpURList = Database.upsert(contentPermissions, MA_Knowledge_Article_Permissions__c.Name, false);
            Database.UpsertResult[] ccpURList = Database.upsert(companyContentPermissions, MA_Community_Video_Mapping__c.Name, false);
            MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(cpURList, MA_AbstractLogger.BulkLoggerType.UPSERT_RESULT);
            MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(ccpURList, MA_AbstractLogger.BulkLoggerType.UPSERT_RESULT);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to setup knowledge article permission & community video mapping custom setting records based on permission sets created.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void setupContentSharingPermissions() {
            Map<String, Group> publicGroupMap = MA_GenerateCompanyPermissionSet.getContentSharingPublicGroupMap(csPublicGroupDevNames);
            Map<String, PermissionSet> csPermissionSetMap = MA_GenerateCompanyPermissionSet.getContentSharingPermissionSetMap(csPermissionSetNames);

            for(String dataCategoryLabel : permissionMapping.keySet()) {
                ContentPermissionWrapper wrapperObj = permissionMapping.get(dataCategoryLabel);
                MA_Knowledge_Article_Permissions__c contentPermission = new MA_Knowledge_Article_Permissions__c();
                contentPermission.Company_Id__c = company.Id;
                contentPermission.Acquistion_Contact_Field_Name__c = wrapperObj.fieldAPIName;
                contentPermission.Name = wrapperObj.contentSharingPermissionSet.Name.left(37);
                contentPermission.PermissionSet_Id__c = csPermissionSetMap.get(wrapperObj.contentSharingPermissionSet.Name).Id;
                contentPermission.Public_Group_Id__c = publicGroupMap.get(wrapperObj.contentSharingPublicGroup.DeveloperName).Id;
                contentPermission.Data_Category_Name__c = company.Category_API_Name__c.split('\\.')[0] + '.' + dataCategoryMap.get(dataCategoryLabel);
                contentPermissions.add(contentPermission);
            }

            MA_Community_Video_Mapping__c companyContentPermission = new MA_Community_Video_Mapping__c();
            companyContentPermission.Company_Id__c = company.Id;
            companyContentPermission.Name = publicGroupMap.get(companyContentSharingGroup.DeveloperName).Name;
            companyContentPermission.Public_Group_Id__c = publicGroupMap.get(companyContentSharingGroup.DeveloperName).Id;
            companyContentPermissions.add(companyContentPermission);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to execute MA_ContentEnroller.EnrolUsers job to process content enrolment & notify user upon successful enrolment (using MA Messaging framework).
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        @TestVisible
        private void processContentEnrolmentAndNotifyUser() {
            Set<String> userIds = new Set<String> {String.valueOf(UserInfo.getUserId())};
            String notificationBody = NOTIFICATION_TITLE + ' for ' + company.Name;
            MA_MessageProcessing.initNotificationMessaging(CONFIG_TYPE_GENERATE_PERMISSION_SET, NOTIFICATION_TITLE, notificationBody, company.Id, userIds, MA_Messaging.NotificationTargetType.RECORD_ID_TYPE);
            Queueable messagingJob = MA_MessageProcessing.getMessagingJob(MA_MessageProcessing.ExecutionType.NOTIFICATION_JOB);
            MA_ContentEnroller.initContentEnrolment(company, companyContentPermissions[0].Public_Group_Id__c, contentPermissions);
            MA_ContentEnroller.processContentEnrolment(messagingJob);
        }
    }
}