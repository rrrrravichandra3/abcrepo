/**
 * W-10678114
 * Helper class to auto-enrol or remove acquisition contacts from community events.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         22/02/2022      Ashutosh Belwal         Holds utility methods to perform SOQL queries or DML operations during auto-enrolment process.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public class MA_DataCatergoryAssignmentHelper {
    
    private static final String CROSS_REFERENCE_STR = 'Contact.Acquisition_Contacts__r.';
    private static final String DEFAULT_FIELDS = 'Contact.Acquisition_Contacts__r.Acquisition_Company__c,  Contact.Acquisition_Contacts__c';
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * W-10678114 : Method retreive the User records along with Acquisition Contact fields
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    queryFields 	 DESCRIPTION (Data type Set<String>, Set of fields to generate dynamic soql)
    * @param	acqContactIds	 DESCRIPTION (Data type Set<String>, List of eligible Acquistion contacts)
    * @return	acqConIdVsUser	 DESCRIPTION (Data type Map<Id, User>, Map of eligible Acquistion contacts)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Map<Id, User> getAcqContactRecords(Set<String> queryFields, Set<String> acqContactIds, Set<Id> companyIds){
        String acqConFieldString = '';

        for(String queryField : queryFields){
            acqConFieldString += ', ' + CROSS_REFERENCE_STR + queryField;
        }
		acqConFieldString = DEFAULT_FIELDS+acqConFieldString;
        String query = 'SELECT Id, '+acqConFieldString+' FROM User ';
        query += ' WHERE Contact.Acquisition_Contacts__c IN: acqContactIds';

        List<User> lstUsers = (List<User>)Database.query(query);
        Map<Id, User> acqConIdVsUser = new Map<Id, User>();

        for(User userRecord : lstUsers){
            acqConIdVsUser.put(userRecord.Contact.Acquisition_Contacts__c, userRecord);
            companyIds.add(userRecord.Contact.Acquisition_Contacts__r.Acquisition_Company__c);
        }

        return acqConIdVsUser;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method retreive the Existing Users Permission Set Assignments
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    lstUser				 	 			DESCRIPTION (Data type List<User>, List of eligible Acquisition Contacts related users)
    * @return	userVsPermissionSetAssignment		DESCRIPTION (Data type Map<Id, Map<String,PermissionSetAssignment>>, Map of User Vs 
	*															 All associated permission sets)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Map<Id, Map<Id,PermissionSetAssignment>> getPermissionSetAssignment(List<User> lstUser){
        Map<Id, Map<Id,PermissionSetAssignment>> userVsPermissionSetAssignment = new Map<Id, Map<Id,PermissionSetAssignment>>();

        for(PermissionSetAssignment objAssignment:[SELECT AssigneeId, PermissionSet.Name
                                                   FROM PermissionSetAssignment
                                                   WHERE Assignee.Id IN: lstUser]) {
            if(userVsPermissionSetAssignment.get(objAssignment.AssigneeId) == null) {
                userVsPermissionSetAssignment.put(objAssignment.AssigneeId, new Map<Id, PermissionSetAssignment>());
            }
            userVsPermissionSetAssignment.get(objAssignment.AssigneeId).put(objAssignment.PermissionSetId, objAssignment);
        }

        return userVsPermissionSetAssignment;
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * W-10678114 : Method retrieve the fields from custom metadata to generate dynamic query
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return	Set<String>	    DESCRIPTION (return )
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Map<Id, List<MA_Knowledge_Article_Permissions__c>> getCompanySpecificConfig(Set<Id> companyIds) {
        
        Map<Id, List<MA_Knowledge_Article_Permissions__c>> companyIdVsPermission = new Map<Id, List<MA_Knowledge_Article_Permissions__c>>();
        for(MA_Knowledge_Article_Permissions__c objCustomSetting: [SELECT Acquistion_Contact_Field_Name__c , PermissionSet_Id__c, Company_Id__c      
                                                                   FROM MA_Knowledge_Article_Permissions__c
                                                                   WHERE Company_Id__c =: companyIds ])
        {
            Id companyId = Id.valueOf(objCustomSetting.Company_Id__c);
            if(companyIdVsPermission.get(companyId) == null){
                companyIdVsPermission.put(companyId, new List<MA_Knowledge_Article_Permissions__c>());
            }
            companyIdVsPermission.get(companyId).add(objCustomSetting);
            
        }
        return companyIdVsPermission;
    }
    
    
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * W-10678114 : Method retrieve the fields from custom metadata to generate dynamic query
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return	Set<String>	    DESCRIPTION (return )
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Set<String> getSetupFields() {
        Set<String> fields = new Set<String>();
        
        for(MA_Knowledge_Sharing_Master_Data__mdt objMasterData : MA_Knowledge_Sharing_Master_Data__mdt.getAll().values()){
            fields.add(objMasterData.Field_API_Name__c);
        }
        return fields;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * W-10678114 : Method to Assign Permission Set based on Acquisition Contact field changes
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    permissionToInsert 	 DESCRIPTION (Data type List, List of Permission Set Assignments to insert)
    * @param    permissionToDelete 	 DESCRIPTION (Data type List, List of Permission Set Assignments to delete)
    * @return
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void executeDataCategoryPermSetEnrolment(List<PermissionSetAssignment> permissionToInsert, List<PermissionSetAssignment> permissionToDelete) {        
        if(permissionToInsert.size()>0){
           MA_ExecuteDmlQueuableBatches batchObj = new MA_ExecuteDmlQueuableBatches(permissionToInsert, MA_ExecuteDmlQueuableBatches.ACTION_TYPE.UPSERT_RECORDS, 200);
           System.enqueueJob(batchObj);
        }
            
        if(permissionToDelete.size()>0){
           MA_ExecuteDmlQueuableBatches batchObj = new MA_ExecuteDmlQueuableBatches(permissionToDelete, MA_ExecuteDmlQueuableBatches.ACTION_TYPE.DELETE_RECORDS, 200);
           System.enqueueJob(batchObj);
        }
    }
}