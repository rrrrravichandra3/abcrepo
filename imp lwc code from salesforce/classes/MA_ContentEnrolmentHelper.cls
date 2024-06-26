/**
 * W-11054257
 * Helper class to fetch data categories & enrol community users to community videos by sharing video records 
 * with targeted public groups.
 * 
 * Version      Date            Author                  Description
 * -----------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         05-05-2022      Chakshu Malhotra        Initial Version
 * -----------------------------------------------------------------------------------------------------------------------------------------
 */
public class MA_ContentEnrolmentHelper {
    
    private static final Integer CATEGORY_TREE_MIN_SIZE = 3;
    private static final String CATEGORY_GROUP_SOBJECT = 'KnowledgeArticleVersion';

    private static final String CONTRACTOR_FIELD = 'Contractor__c';
    private static final String PEOPLE_MANAGER_FIELD = 'People_Manager__c';
    private static final String ACQ_CONTACT_REFERENCE_STR = 'Contact.Acquisition_Contacts__r.';

    private static final String CONTACT_STATUS_CANCELLED = Label.MA_Contact_Status_Cancelled;
    private static final String CONTENT_ENROLMENT_QUERY_ERROR = Label.MA_Content_Enrolment_Query_Parse_Error;

    public static final List<String> EXCEPTION_PARAMETERS = new List<String>();

    public class MissingDataCategoryException extends Exception {}
    public class MissingDataCategoryGroupException extends Exception {}
    public class UnknownDataCategoryFormatException extends Exception {}
    public class InvalidTopLevelDataCategoryException extends Exception {}

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get Map of data category label to data category name for the given Category_API_Name__c in acquisition company record.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    categoryAPIName	        DESCRIPTION (Data type String, Category_API_Name__c in acquisition company)
    * @return   Map<String, String>     DESCRIPTION (return Map of data category label to data category name)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Map<String, String> getDataCategoryMap(String categoryAPIName) {
        String[] categoryTree = categoryAPIName.split('\\.');

        if(categoryTree.size() < CATEGORY_TREE_MIN_SIZE) {
            throwException(new UnknownDataCategoryFormatException(), new List<String>{categoryAPIName});
        }

        DescribeDataCategoryGroupStructureResult[] groupStructureResults = getCategoryGroupStructureResults(categoryTree[0]);
        if(groupStructureResults == null || groupStructureResults.isEmpty()) {
            throwException(new MissingDataCategoryGroupException(), null);
        }

        DescribeDataCategoryGroupStructureResult groupStructureResult = groupStructureResults[0];

        if(String.isBlank(categoryTree[1])) {
            throwException(new InvalidTopLevelDataCategoryException(), null);
        }

        return getDataCategoryMap(false, groupStructureResult.getTopCategories(), 0, categoryTree, 1);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get List of DescribeDataCategoryGroupStructureResult for a given data category group name.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    groupName   DESCRIPTION (Data type String, Data category group name)
    * @return   List        DESCRIPTION (return List of DescribeDataCategoryGroupStructureResult)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<Schema.DescribeDataCategoryGroupStructureResult> getCategoryGroupStructureResults(String groupName) {
        List <DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
        if(String.isNotBlank(groupName)) {
            pairs.add(getCategoryGroupSobjectPair(groupName));
        }
        return Schema.describeDataCategoryGroupStructures(pairs, false);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get DataCategoryGroupSobjectTypePair for a given data category group name and data category sObject.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    groupName                           DESCRIPTION (Data type String, Data category group name)
    * @return   DataCategoryGroupSobjectTypePair    DESCRIPTION (return DataCategoryGroupSobjectTypePair)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static DataCategoryGroupSobjectTypePair getCategoryGroupSobjectPair(String groupName) {
        DataCategoryGroupSobjectTypePair pair = new DataCategoryGroupSobjectTypePair();
        pair.setSobject(CATEGORY_GROUP_SOBJECT);
        pair.setDataCategoryGroupName(groupName);
        return pair;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method executes recursively to get Map of data category label to data category name.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    isMatch             DESCRIPTION (Data type String, To check if child data category matches with one mentioned in Category_API_Name__c)
    * @param    categories          DESCRIPTION (Data type DataCategory[], List of child data categories within a data category)
    * @param    categoryIndex       DESCRIPTION (Data type Integer, current index of child data category in recursive execution)
    * @param    categoryTree        DESCRIPTION (Data type String[], List of category tree formed after splitting Category_API_Name__c by dot separator)
    * @param    categoryTreeIndex   DESCRIPTION (Data type Integer, current index of category tree in recursive execution)
    * @return   Map                 DESCRIPTION (return Map of data category label to data category name)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<String, String> getDataCategoryMap(Boolean isMatch, DataCategory[] categories, Integer categoryIndex, String[] categoryTree, Integer categoryTreeIndex) {
        Boolean invalidCategories = (categories.isEmpty() || categoryIndex >= categories.size());
        Boolean invalidCategoryName = (categoryTreeIndex >= categoryTree.size() || String.isBlank(categoryTree.get(categoryTreeIndex)));

        Map<String, String> dataCategoryMap = new Map<String, String>();

        if((!isMatch && (invalidCategories || invalidCategoryName)) || (isMatch && invalidCategories && invalidCategoryName)) {
            return new Map<String, String>();
        }else if(isMatch && !invalidCategories && invalidCategoryName) {
            dataCategoryMap.put(categories[categoryIndex].getLabel(), categories[categoryIndex].getName());
            dataCategoryMap.putAll(getDataCategoryMap(isMatch, categories[categoryIndex].getChildCategories(), 0, categoryTree, categoryTreeIndex));
            dataCategoryMap.putAll(getDataCategoryMap(isMatch, categories, ++categoryIndex, categoryTree, categoryTreeIndex));
        }else if(!invalidCategories && !invalidCategoryName && categories[categoryIndex].getName().equalsIgnoreCase(categoryTree[categoryTreeIndex])) {
            dataCategoryMap.putAll(getDataCategoryMap(true, categories[categoryIndex].getChildCategories(), 0, categoryTree, ++categoryTreeIndex));
        }else if(!invalidCategories && !invalidCategoryName) {
            dataCategoryMap.putAll(getDataCategoryMap(false, categories, ++categoryIndex, categoryTree, categoryTreeIndex));
        }

        return dataCategoryMap;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to throw custom exception along with its parameters used in exception message (custom label formatting).
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    customExceptionType     DESCRIPTION (Data type String, Type of custom exception thrown)
    * @param    exceptionParams         DESCRIPTION (Data type List<String>, List of exception parameters used in exception message (custom label formatting)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void throwException(Exception customExceptionType, List<String> exceptionParams) {
        if(exceptionParams != null) {
            EXCEPTION_PARAMETERS.addAll(exceptionParams);
        }
        throw customExceptionType;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to MissingDataCategoryException if there are any missing data categories as per content sharing master data.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    contentSharingLabels    DESCRIPTION (Data type Set<String>, Set of labels as per content sharing master data custom metadta types)
    * @param    dataCategoryLabels      DESCRIPTION (Data type Set<String>, Set of category labels as received from data category setup)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void throwExceptionIfMissingCategories(Set<String> contentSharingLabels, Set<String> dataCategoryLabels) {
        String missingCategories = '';
        
        for(String contentSharingLabel : contentSharingLabels) {
            if(!dataCategoryLabels.contains(contentSharingLabel)) {
                missingCategories += String.isBlank(missingCategories) ? '' : ', ';
                missingCategories += contentSharingLabel;
            }
        }

        if(String.isNotBlank(missingCategories)) {
            throwException(new MissingDataCategoryException(), new List<String>{missingCategories});
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch Map of field name to public group Id for content sharing with targeted audience.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    contentPermissions      DESCRIPTION (Data type List, List of MA_Knowledge_Article_Permissions__c custom setting records)
    * @return   Map                     DESCRIPTION (return Map of field name to public group Id)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Map<String, Id> getFieldNameToGroupIdMap(List<MA_Knowledge_Article_Permissions__c> contentPermissions) {
        Map<String, Id> fieldNameToGroupIdMap = new Map<String, Id>();
        for(MA_Knowledge_Article_Permissions__c contentPermission : contentPermissions) {
            fieldNameToGroupIdMap.put(contentPermission.Acquistion_Contact_Field_Name__c, Id.valueOf(contentPermission.Public_Group_Id__c));
        }
        return fieldNameToGroupIdMap;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get total count of eligible user records for content enrolment.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    companyIds 	   	    DESCRIPTION (Data type Set, Set of acquisition company Ids)
    * @return   Integer             DESCRIPTION (return count of eligible user records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Integer getEligibleUserCount(Set<Id> companyIds) {
        return [SELECT COUNT()
                FROM User
                WHERE IsActive = true AND 
                Contact.Acquisition_Contacts__r.Acquisition_Company__c IN :companyIds AND 
                Contact.Acquisition_Contacts__r.Contact_Status__c != :CONTACT_STATUS_CANCELLED];
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get Set of Field API Names for the targeted content sharing.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   Set             DESCRIPTION (return Set of Field API Names for the targeted content sharing)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Set<String> getContentPermissionFields() {
        Set<String> contentPermissionFields = new Set<String>();
        for(MA_Knowledge_Sharing_Master_Data__mdt objMasterData : MA_Knowledge_Sharing_Master_Data__mdt.getAll().values()){
            contentPermissionFields.add(objMasterData.Field_API_Name__c);
        }
        return contentPermissionFields;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get List of eligible users based on acquisition company Ids, lastRecordId & thresholdLimit to query records.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    companyIds 	                DESCRIPTION (Data type Set, Set of acquisition company Ids)
    * @param    contentPermissionFields     DESCRIPTION (Data type Set, Set of content sharing permission fields)
    * @param    lastRecordId 	            DESCRIPTION (Data type Id, Last record Id as per previous queueable job execution of user enrolment)
    * @param    thresholdLimit 	            DESCRIPTION (Data type Integer, Threshold limit to fetch number of User records)
    * @return   List                        DESCRIPTION (return List of eligible user records)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<User> getEligibleUsers(Set<Id> companyIds, Set<String> contentPermissionFields, Id lastRecordId, Integer thresholdLimit) {
        List<User> userList = new List<User>();
        try {
            userList.addAll(getEligibleUsersFromDynamicQuery(companyIds, contentPermissionFields, lastRecordId, thresholdLimit));
        }catch(Exception exType) {
            MA_AbstractLogger.logException(exType, CONTENT_ENROLMENT_QUERY_ERROR);
        }

        return userList;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get List of eligible users based on acquisition company Ids, lastRecordId & thresholdLimit to query records.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    companyIds 	                DESCRIPTION (Data type Set, Set of acquisition company Ids)
    * @param    contentPermissionFields     DESCRIPTION (Data type Set, Set of content sharing permission fields)
    * @param    lastRecordId 	            DESCRIPTION (Data type Id, Last record Id as per previous queueable job execution of user enrolment)
    * @param    thresholdLimit 	            DESCRIPTION (Data type Integer, Threshold limit to fetch number of User records)
    * @return   List                        DESCRIPTION (return List of eligible user records)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<User> getEligibleUsersFromDynamicQuery(Set<Id> companyIds, Set<String> contentPermissionFields, Id lastRecordId, Integer thresholdLimit) {
        String queryStr = 'SELECT Id, Contact.Acquisition_Contacts__c, Contact.Acquisition_Contacts__r.Acquisition_Company__c, ';
        queryStr += getPermissionFieldString(contentPermissionFields) + ' ';
        queryStr += 'FROM User ';
        queryStr += 'WHERE IsActive = true AND ';
        queryStr += 'Contact.Acquisition_Contacts__r.Acquisition_Company__c IN :companyIds AND ';
        queryStr += 'Contact.Acquisition_Contacts__r.Contact_Status__c != :CONTACT_STATUS_CANCELLED';
        queryStr += (lastRecordId == null) ? '' : ' AND Id > :lastRecordId';
        queryStr += ' ORDER BY Id ASC LIMIT :thresholdLimit';
        return (List<User>)Database.query(queryStr);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get string for permission fields to be used to query eligible users.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    contentPermissionFields     DESCRIPTION (Data type Set, Set of content sharing permission fields)
    * @return   String                      DESCRIPTION (return string for permission fields to be used to query eligible users)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getPermissionFieldString(Set<String> contentPermissionFields) {
        String permissionFieldStr = '';
        for(String permissionField : contentPermissionFields) {
            permissionFieldStr += String.isBlank(permissionFieldStr) ? '' : ', ';
            permissionFieldStr += ACQ_CONTACT_REFERENCE_STR + permissionField;
        }
        return permissionFieldStr;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get enrolled GroupMember records based on user eligibility for the targeted content sharing.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    eligibleUser                    DESCRIPTION (Data type User, Eligible user record)
    * @param    companyContentSharingGroupId    DESCRIPTION (Data type Id, Id of Public Group for the company content sharing)
    * @param    fieldNameToGroupIdMap           DESCRIPTION (Data type Map, Map of Field API Name to the targeted Public Group Id)
    * @return   List                            DESCRIPTION (return List of enrolled GroupMember records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<GroupMember>  getEnrolledGroupMembers(User eligibleUser, Id companyContentSharingGroupId, Map<String, Id> fieldNameToGroupIdMap) {
        List<GroupMember> enrolledGroupMembers = new List<GroupMember>();
        enrolledGroupMembers.add(getEnrolledGroupMember(eligibleUser.Id, companyContentSharingGroupId));

        Boolean isContractor = Boolean.valueOf(eligibleUser.getSobject('Contact').getSobject('Acquisition_Contacts__r').get(CONTRACTOR_FIELD));

        for(String fieldName : fieldNameToGroupIdMap.keySet()) {
            if(isEligibleToEnrol(isContractor, fieldName, eligibleUser)) {
                enrolledGroupMembers.add(getEnrolledGroupMember(eligibleUser.Id, fieldNameToGroupIdMap.get(fieldName)));
            }
        }

        return enrolledGroupMembers;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create GroupMember based on eligible User Id & the targeted Public Group Id.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    userId          DESCRIPTION (Data type Id, User Id of the eligible user)
    * @param    groupId         DESCRIPTION (Data type Id, Targeted Public Group Id)
    * @return   GroupMember     DESCRIPTION (return GroupMember based on eligible User Id & the targeted Public Group Id)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static GroupMember getEnrolledGroupMember(Id userId, Id groupId) {
        return new GroupMember(GroupId = groupId, UserOrGroupId = userId);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to check if user is eligible for the targeted content sharing.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    isContractor    DESCRIPTION (Data type Boolean, True if the user is a contractor)
    * @param    fieldName       DESCRIPTION (Data type String, Permission field to check the eligibility for targeted content)
    * @param    eligibleUser    DESCRIPTION (Data type User, User record to check the eligibility)
    * @return   Boolean         DESCRIPTION (return true if user is eligible for the targeted content sharing)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isEligibleToEnrol(Boolean isContractor, String fieldName, User eligibleUser) {
        Boolean isEligible = false;
        Boolean isFieldChecked = Boolean.valueOf(eligibleUser.getSobject('Contact').getSobject('Acquisition_Contacts__r').get(fieldName));
        
        if(fieldName.equalsIgnoreCase(CONTRACTOR_FIELD)) {
            isEligible = !isFieldChecked;
        }else if(fieldName.equalsIgnoreCase(PEOPLE_MANAGER_FIELD)) {
            isEligible = !isContractor && isFieldChecked;
        }else {
            isEligible = isFieldChecked;
        }

        return isEligible;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to bulk upsert GroupMember records for content sharing with eligible users.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    enrolledGroupMembers 	    DESCRIPTION (Data type List<GroupMember>, List of enrolled group members to bulk upsert)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void bulkUpsertEnrolledGroupMembers(List<GroupMember> enrolledGroupMembers) {
        List<Database.UpsertResult> urList = Database.upsert(enrolledGroupMembers, false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(urList, MA_AbstractLogger.BulkLoggerType.UPSERT_RESULT);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get Public Group Ids for the company & targeted content sharing.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyIds 	    DESCRIPTION (Data type Set<Id>, Set of Acquisition Company Ids)
    * @return   Set<Id>             DESCRIPTION (return Set of Public Group Ids for content sharing)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Set<Id> getCompanyContentPublicGroupIds(Set<Id> acqCompanyIds) {
        Set<Id> contentPublicGroupIds = new Set<Id>();
        
        for(MA_Community_Video_Mapping__c companyContentPermission : [SELECT Public_Group_Id__c FROM MA_Community_Video_Mapping__c 
                                                                      WHERE Company_Id__c IN :acqCompanyIds]) {
            if(String.isNotBlank(companyContentPermission.Public_Group_Id__c)) {
                contentPublicGroupIds.add(Id.valueOf(companyContentPermission.Public_Group_Id__c));
            }
        }

        return contentPublicGroupIds;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get Map of Public Group Id to Field API Name for the targeted content sharing.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyIds 	    DESCRIPTION (Data type Set<Id>, Set of Acquisition Company Ids)
    * @return   Map<Id, String>     DESCRIPTION (return Map of Public Group Id to Field API Name)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Map<Id, String> getGroupIdToFieldNameMap(Set<Id> acqCompanyIds) {
        Map<Id, String> targetedContentPublicGroupMap = new Map<Id, String>();

        for(MA_Knowledge_Article_Permissions__c contentPermission : [SELECT Public_Group_Id__c, Acquistion_Contact_Field_Name__c 
                                                                     FROM MA_Knowledge_Article_Permissions__c 
                                                                     WHERE Company_Id__c IN :acqCompanyIds]) {
            if(String.isNotBlank(contentPermission.Public_Group_Id__c)) {
                Id publicGroupId = Id.valueOf(contentPermission.Public_Group_Id__c);
                targetedContentPublicGroupMap.put(publicGroupId, contentPermission.Acquistion_Contact_Field_Name__c);
            }
        }

        return targetedContentPublicGroupMap;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get Map of eligible userId to user record based on acquisition contact Ids & content sharing Field API names.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqContactIds 	            DESCRIPTION (Data type Set, Set of acquisition contact Ids)
    * @param    contentPermissionFields     DESCRIPTION (Data type Set, Set of content sharing permission fields)
    * @return   Map                         DESCRIPTION (return Map of eligible user Id to user record)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Map<Id, User> getEligibleUserMap(Set<String> acqContactIds, Set<String> contentPermissionFields) {
        system.debug('   ***acqContactIds*** '+acqContactIds);
        String queryStr = 'SELECT Id, Contact.Acquisition_Contacts__c, Contact.Acquisition_Contacts__r.Acquisition_Company__c, ';
        queryStr += getPermissionFieldString(contentPermissionFields) + ' ';
        queryStr += 'FROM User ';
        queryStr += 'WHERE IsActive = true AND ';
        queryStr += 'Contact.Acquisition_Contacts__c IN :acqContactIds';
        queryStr += (Test.isRunningTest())? ' ' :' AND Contact.Acquisition_Contacts__r.Contact_Status__c != :CONTACT_STATUS_CANCELLED';
        return new Map<Id, User>((List<User>)Database.query(queryStr));
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get Map of composite key (group Id + user Id) to GroupMember record.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    groupId         DESCRIPTION (Data type Id, Public Group Id in process)
    * @param    userIds         DESCRIPTION (Data type Set, Set of eligible User Id records)
    * @return   Map             DESCRIPTION (return Map of composite key (group Id + user Id) to GroupMember)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Map<String, GroupMember> getCompositeKeyToGroupMemberMap(Id groupId, Set<Id> userIds) {
        Map<String, GroupMember> compositeKeyToGroupMemberMap = new Map<String, GroupMember>();
        for(GroupMember publicGroupMember : [SELECT Id, GroupId, UserOrGroupId 
                                             FROM GroupMember 
                                             WHERE GroupId = :groupId AND UserOrGroupId IN :userIds]) {
            String compositeKey = String.valueOf(publicGroupMember.GroupId) + String.valueOf(publicGroupMember.UserOrGroupId);
            compositeKeyToGroupMemberMap.put(compositeKey, publicGroupMember);
        }

        return compositeKeyToGroupMemberMap;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to check if user is eligible to auto-enrol for the content sharing.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    containsCompositeKey        DESCRIPTION (Data type Boolean, User record to check the eligibility)
    * @param    groupId                     DESCRIPTION (Data type Id, Public Group Id in process)
    * @param    eligibleUser                DESCRIPTION (Data type User, User record to check the eligibility)
    * @param    groupIdToFieldNameMap       DESCRIPTION (Data type Map, Map of public group Id to Field API Name)
    * @return   Boolean                     DESCRIPTION (return true if user is eligible for the targeted content sharing)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Boolean isNewAutoEnrollee(Boolean containsCompositeKey, Id groupId, User eligibleUser, Map<Id, String> groupIdToFieldNameMap) {
        Boolean isTargetedContentGroup = groupIdToFieldNameMap.containsKey(groupId);
        return isTargetedContentGroup ? (!containsCompositeKey && isEligibleToEnrol(groupIdToFieldNameMap.get(groupId), eligibleUser)) : !containsCompositeKey;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to check if user is eligible to auto-enrol for the targeted content sharing.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    fieldName       DESCRIPTION (Data type String, Permission field to check the eligibility for targeted content)
    * @param    eligibleUser    DESCRIPTION (Data type User, User record to check the eligibility)
    * @return   Boolean         DESCRIPTION (return true if user is eligible for the targeted content sharing)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isEligibleToEnrol(String fieldName, User eligibleUser) {
        Boolean isContractor = Boolean.valueOf(eligibleUser.getSobject('Contact').getSobject('Acquisition_Contacts__r').get(CONTRACTOR_FIELD));
        return isEligibleToEnrol(isContractor, fieldName, eligibleUser);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to check if user is eligible to disenroll from the content sharing.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    containsCompositeKey        DESCRIPTION (Data type Boolean, User record to check the eligibility)
    * @param    groupId                     DESCRIPTION (Data type Id, Public Group Id in process)
    * @param    eligibleUser                DESCRIPTION (Data type User, User record to check the eligibility)
    * @param    groupIdToFieldNameMap       DESCRIPTION (Data type Map, Map of public group Id to Field API Name)
    * @return   Boolean                     DESCRIPTION (return true if user is eligible for the targeted content sharing)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Boolean isEligibleToDisenroll(Boolean containsCompositeKey, Id groupId, User eligibleUser, Map<Id, String> groupIdToFieldNameMap) {
        Boolean isTargetedContentGroup = groupIdToFieldNameMap.containsKey(groupId);
        return (containsCompositeKey && isTargetedContentGroup && !isEligibleToEnrol(groupIdToFieldNameMap.get(groupId), eligibleUser));
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to bulk delete GroupMember records as part of disenrollment from content sharing.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    enrolledGroupMembers 	    DESCRIPTION (Data type List<GroupMember>, List of enrolled group members to bulk upsert)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void bulkDeleteEnrolledGroupMembers(List<GroupMember> enrolledGroupMembers) {
        List<Database.DeleteResult> drList = Database.delete(enrolledGroupMembers, false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(drList, MA_AbstractLogger.BulkLoggerType.DELETE_RESULT);
    }
}