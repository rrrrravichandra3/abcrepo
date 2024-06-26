/**
 * Controller class to display emaployee details associated to Offer communicator
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         20-09-2021      Ashutosh Belwal         Initial Version
 * v2.0         24-11-2021      Chakshu Malhotra        W-10141936 -> Reduced server round trips & updated response to format fields on UI based on its data type
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_EmployeeCompensastionCtrl {

    private static final String MY_TEAM_LIST_KEY = 'myTeamList';
    private static final String ACQ_CONTACT_FIELDS_KEY = 'acqContactFields';
    private static final String ACQ_COMPENSATION_FIELDS_KEY = 'acqCompensationFields';

    private static final String REQUIRED_COMPENSATION_FIELDS = 'Id';
    private static final String REQUIRED_CONTACT_FIELDS = 'Id,Name';
    
    private static final String CONTACT_STATUS_CANCELLED = Label.MA_Contact_Status_Cancelled;

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Retrieves the Acquisition Contact records along with Compensation details for a team under Offer Communicator.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqContactFieldSet 	   	    DESCRIPTION (Data type String, Acquisition Contact FieldSet name)
    * @param    acqCompensationFieldSet 	DESCRIPTION (Data type String, Acquisition Compensation FieldSet name)
    * @return   String                      DESCRIPTION (returns serialized response containing field sets & acquisition contact 
    *                                                    records along with compensation details)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled(cacheable=true)
    public static String getMyTeamDetails(String acqContactFieldSet, String acqCompensationFieldSet) {
        try {
            List<Schema.FieldSetMember> acqContactFields = Schema.SObjectType.Acquisition_Contacts__c.fieldSets.getMap().get(acqContactFieldSet).getFields();
            List<Schema.FieldSetMember> acqCompensationFields = Schema.SObjectType.Acquisition_Compensation__c.fieldSets.getMap().get(acqCompensationFieldSet).getFields();

            Id offerCommunicatorId = [SELECT Id, Contact.Acquisition_Contacts__c 
                                      FROM User 
                                      WHERE Id = :UserInfo.getUserId() LIMIT 1]?.Contact?.Acquisition_Contacts__c;

            Map<String, Object> myTeamDetails = new Map<String, Object>();

            if(offerCommunicatorId != null) {
                myTeamDetails.put(ACQ_CONTACT_FIELDS_KEY, acqContactFields);
                myTeamDetails.put(ACQ_COMPENSATION_FIELDS_KEY, acqCompensationFields);
                myTeamDetails.put(MY_TEAM_LIST_KEY, Database.query(getAcqContactQueryString(offerCommunicatorId, acqContactFields, acqCompensationFields)));
            }

            return JSON.serialize(myTeamDetails);
        } catch (Exception e) {
           
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Retrieves the Acquisition Contact records along with Compensation details for a team under Offer Communicator.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    offerCommunicatorId 	   	DESCRIPTION (Data type Id, User Id of offer communicator)
    * @param    acqContactFields 	        DESCRIPTION (Data type List<Schema.FieldSetMember>, acquisition contact field set members)
    * @param    acqCompensationFields 	    DESCRIPTION (Data type List<Schema.FieldSetMember>, acquisition compensation field set members)
    * @return   String                      DESCRIPTION (returns dynamic query string to fetch acquisition contacts.)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getAcqContactQueryString(Id offerCommunicatorId, List<Schema.FieldSetMember> acqContactFields, List<Schema.FieldSetMember> acqCompensationFields) {
        Set<String> soqlContactFields = new Set<String>(REQUIRED_CONTACT_FIELDS.split(','));
        Set<String> soqlCompFields = new Set<String>(REQUIRED_COMPENSATION_FIELDS.split(','));

        return 'SELECT ' + getSoqlReadyFields(acqContactFields, soqlContactFields, REQUIRED_CONTACT_FIELDS) + ', ' +
                '(SELECT CurrencyIsoCode,' + getSoqlReadyFields(acqCompensationFields, soqlCompFields, REQUIRED_COMPENSATION_FIELDS) + 
                ' FROM Acquisition_Compensation__r LIMIT 1) ' +
                'FROM Acquisition_Contacts__c ' + 
                'WHERE Offer_Communicator__c = :offerCommunicatorId AND Contact_Status__c != :CONTACT_STATUS_CANCELLED ' +
                'ORDER BY Name ASC';
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Retrieves the Acquisition Contact records along with Compensation details for a team under Offer Communicator.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    fields 	        DESCRIPTION (Data type List<Schema.FieldSetMember>, field set members)
    * @param    soqlFields 	    DESCRIPTION (Data type Set<String>, required fields in dynamic soql query)
    * @param    soqlFields 	    DESCRIPTION (Data type String, soql query string for dynamic query)
    * @return   String          DESCRIPTION (returns comma separated fields to query from acquistion contact & compensation)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getSoqlReadyFields(List<Schema.FieldSetMember> fields, Set<String> soqlFields, String soqlFieldsStr) {
        for(Schema.FieldSetMember field : fields) {
            String fieldPath = field.getFieldPath();

            if(!soqlFields.contains(fieldPath)) {
                soqlFieldsStr += String.isBlank(soqlFieldsStr) ? '' : ',';
                soqlFieldsStr += fieldPath;
                soqlFields.add(fieldPath);
            }
        }

        return soqlFieldsStr;
    }
}