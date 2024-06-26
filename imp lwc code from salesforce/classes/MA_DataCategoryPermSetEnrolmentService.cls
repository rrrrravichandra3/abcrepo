/**
 * W-10678114
 * EnrolmentService implementation to auto-enrol acquisition contacts to specific data categories related permission sets.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         24/02/2022      Chakshu Malhotra        Holds Queueable chaining logic to auto-enrol acquisition contacts to data categories related permission sets.
 * v1.1	        24/02/2022      Ashutosh Belwal         Built logic to dynamically assign data category permission set on Acquisition contact field changes
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public class MA_DataCategoryPermSetEnrolmentService implements MA_AutoEnrolment.EnrolmentService {

    private static final String CROSS_REFERENCE_STR  = 'Contact.Acquisition_Contacts__r.';
    private static final String CONTRACTOR_FIELD	 = 'Contractor__c';
    private static final String PEOPLE_MANAGER_FIELD = 'People_Manager__c';

    public MA_DataCategoryPermSetEnrolmentService() {
        // default constructor : for dynamic instance creation in MA_AutoEnrolment
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method inititates the auto-enrolment of the acquisition contacts to data category permission sets.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    autoEnrolmentEvents 	   DESCRIPTION (Data type List, List of Auto Enrolment Platform Event records)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void autoEnrol(List<MA_Auto_Enrolment_Event__e> autoEnrolmentEvents) {
        
        List<PermissionSetAssignment> permissionToInsert = new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> permissionToDelete = new List<PermissionSetAssignment>();
        
        Set<String> updatedAcqContactIds = new Set<String>();
        Set<Id> companyIds = new Set<Id>();

        for(MA_Auto_Enrolment_Event__e autoEnrolmentEvent : autoEnrolmentEvents) {
            String acqContactIdsStr = autoEnrolmentEvent.Acquisition_Contact_Ids__c;
            updatedAcqContactIds.addAll(new Set<String>(acqContactIdsStr.split(';')));
        }
        
		Set<String> fields = MA_DataCatergoryAssignmentHelper.getSetupFields();
        Map<Id, User> acqConVsUser = MA_DataCatergoryAssignmentHelper.getAcqContactRecords(fields, updatedAcqContactIds, companyIds);
        Map<Id, Map<Id, PermissionSetAssignment>> userVsPermSetAssignement = MA_DataCatergoryAssignmentHelper.getPermissionSetAssignment(acqConVsUser.values());
        Map<Id, List<MA_Knowledge_Article_Permissions__c>> companyIdVsConfig = MA_DataCatergoryAssignmentHelper.getCompanySpecificConfig(companyIds);

        for(String updatedAcqContactId : updatedAcqContactIds) {
            User userRecord = acqConVsUser.get(Id.valueOf(updatedAcqContactId));
            if(userRecord != null) {
                processDataCategoryAssignmentPermissions(userRecord, companyIdVsConfig, userVsPermSetAssignement, permissionToInsert, permissionToDelete);
            }
        }
        MA_DataCatergoryAssignmentHelper.executeDataCategoryPermSetEnrolment(permissionToInsert, permissionToDelete);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method inititates the execution of queueable jobs for permission set assignment insertion / deletion.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    userRecord 	                DESCRIPTION (Data type User, )
    * @param    companyIdVsConfig 	        DESCRIPTION (Data type Map, )
    * @param    userVsPermSetAssignement    DESCRIPTION (Data type Map, )
    * @param    permissionToInsert       	DESCRIPTION (Data type List, )
    * @param    permissionToDelete       	DESCRIPTION (Data type List, )
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void processDataCategoryAssignmentPermissions(User userRecord, Map<Id, List<MA_Knowledge_Article_Permissions__c>> companyIdVsConfig,
                                                                 Map<Id, Map<Id, PermissionSetAssignment>> userVsPermSetAssignement,
                                                                 List<PermissionSetAssignment> permissionToInsert, 
                                                                 List<PermissionSetAssignment> permissionToDelete) 
    {
        
        Id companyId = userRecord.Contact.Acquisition_Contacts__r.Acquisition_Company__c;
        
        for(MA_Knowledge_Article_Permissions__c objConfig : companyIdVsConfig.get(companyId)) {
            String fieldName = objConfig.Acquistion_Contact_Field_Name__c;
            Boolean isFieldChecked = Boolean.valueOf(userRecord.getSobject('Contact').getSobject('Acquisition_Contacts__r').get(fieldName));
            Boolean isAssignmentExists = userVsPermSetAssignement.get(userRecord.Id).keySet().Contains(objConfig.PermissionSet_Id__c);
            //for full time employee permission assignment
            if(fieldName.toLowerCase() == CONTRACTOR_FIELD.toLowerCase()){
                isFieldChecked = !isFieldChecked;
            }else if(fieldName.toLowerCase() == PEOPLE_MANAGER_FIELD.toLowerCase()){
                //FTE People manager permission assignment
                Boolean isContractor = Boolean.valueOf(userRecord.getSobject('Contact').getSobject('Acquisition_Contacts__r').get(CONTRACTOR_FIELD));
                isFieldChecked = isFieldChecked && !isContractor;
                
            }
            
            if(isFieldChecked && !isAssignmentExists){
                PermissionSetAssignment objAssignment = new PermissionSetAssignment();
                objAssignment.AssigneeId = userRecord.Id;
                objAssignment.PermissionSetId = objConfig.PermissionSet_Id__c;
                permissionToInsert.add(objAssignment);
            }else if(!isFieldChecked && isAssignmentExists){
                permissionToDelete.add(userVsPermSetAssignement.get(userRecord.Id).get(objConfig.PermissionSet_Id__c));
            }
        }
    }
}