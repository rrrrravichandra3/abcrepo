/*
    Rest service used by IDP Quip Live app to sync IDP, IDP Objectives & IDP Actions.
    
    CRUD security checks are not added intentionally. 
    This needs to run even if the running user does not have any permissions on objects.
*/

@RestResource(UrlMapping='/IDPQuipSyncService/*')
global with sharing class IDPQuipSyncService {

    private static final String REQUEST_PARAM_TYPE = 'type';
    private static final String ERROR_MESSAGE_EMPTY_REQUEST = 'Request cannot be null.';
    private static final String ERROR_MESSAGE_EMPTY_EMPLOYEE_NUMBER = 'Exception occurred while syncing IDP. Employee Number Cannot be blank for the user. Please contact Administrator.';
    private static final String ERROR_CODE_BAD_REQUEST = 'BAD_REQUEST';
    private static final String ERROR_INCORRECT_GET_TYPE = 'Received incorrect or unexisting action type.';
    private static final String ERROR_EMPTY_ACTION_TYPE = 'Action type is required.';

    @HttpGet
    global static void getEntry() {
        String response;

        try {
            String actionType = String.escapeSingleQuotes(RestContext.request.params.get(REQUEST_PARAM_TYPE));

            if (String.isBlank(actionType)) throw new ApplicationException(ERROR_EMPTY_ACTION_TYPE);

            switch on actionType {
                when 'isUserFTE' {
                    response = getIsUserFullTimeEmployee();
                }
                // add other Get request types here
                when else {
                    throw new ApplicationException(ERROR_INCORRECT_GET_TYPE);
                }
            }
        } catch (Exception e) {
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf(e.getMessage());
        }

        RestContext.response.responseBody = Blob.valueOf(response);
    }

    @HttpPut
    global static void syncIDP() {

        /*
         Commenting  below as we are deprecating IDP and
         showing to users in read only mode for doc recovery
        
        ///*
        // * Set the savepoint as there are multiple dml statements in single transaction. 
        // * One DML fails then we rollback the entire transaction
        // 
        Savepoint sp = Database.setSavepoint();
        
        try {
            IDPQuipRequest request = (IDPQuipRequest) Json.deserialize(RestContext.request.requestBody.toString(), IDPQuipRequest.class);
            
            if(request == null) {
                throw new ApplicationException(ERROR_MESSAGE_EMPTY_REQUEST);
            } else { // if the request is not NULL then iterate over request body & create/update IDP data.
                IDP__c idpToUpsert = new IDP__c(QuipId__c = request.idp.QuipId__c);
                idpToUpsert.Quip_Document_Id__c = request.idp.Quip_Document_Id__c;
                idpToUpsert.Career_Interest__c = request.idp.Career_Interest__c;
                idpToUpsert.Key_Strengths__c = request.idp.Key_Strengths__c;
                idpToUpsert.Manager_Name__c = request.idp.Manager_Name__c;
                idpToUpsert.Employee_Number__c = getEmployeeNumber();
                
                // upsert using external ID (QuipId__c). This way, we do not have to save salesforce Id for this in quip.
                upsert idpToUpsert QuipId__c; // no need for CRUD/FLS checks because this is part of the business logic
                
                //If there are objective for the IDP, loop through each objective and actions to create/update data.
                if(!request.idpObjectives.isEmpty()) {
                    List<IDP_Objective__c> idpObjectivesToUpsert = new List<IDP_Objective__c>();
                    List<IDP_Action__c> idpActionsToUpsert = new List<IDP_Action__c>();
                    
                    for(IDPObjective wrapper : request.idpObjectives) {
                        IDP_Objective__c updatedObjective = new IDP_Objective__c(QuipId__c = wrapper.idpObjective.QuipId__c);
                        updatedObjective.IDP__c = idpToUpsert.Id;
                        updatedObjective.IDP_Objective_Name__c = wrapper.idpObjective.IDP_Objective_Name__c;
                        updatedObjective.IsDeleted__c = wrapper.idpObjective.IsDeleted__c;
                        idpObjectivesToUpsert.add(updatedObjective);
                        
                        if(!wrapper.idpActions.isEmpty()) {
                            for(IDP_Action__c reqObjAction : wrapper.idpActions) {
                                IDP_Action__c updatedAction = new IDP_Action__c(QuipId__c = reqObjAction.QuipId__c);
                                updatedAction.IDP_Objective__r = new IDP_Objective__c(QuipId__c = wrapper.idpObjective.QuipId__c);
                                updatedAction.Action__c = reqObjAction.Action__c;
                                updatedAction.Completed_Date__c = reqObjAction.Completed_Date__c;
                                updatedAction.IsDeleted__c = reqObjAction.IsDeleted__c;
                                updatedAction.Status__c = reqObjAction.Status__c;
                                updatedAction.Support__c = reqObjAction.Support__c;
                                updatedAction.Synced__c = false;
                                idpActionsToUpsert.add(updatedAction);
                            }
                        }
                    }
                    
                    if(!idpObjectivesToUpsert.isEmpty()) {
                        upsert idpObjectivesToUpsert QuipId__c; // no need for CRUD/FLS checks because this is part of the business logic
                    }
                    
                    if(!idpActionsToUpsert.isEmpty()) {
                        upsert idpActionsToUpsert QuipId__c; // no need for CRUD/FLS checks because this is part of the business logic
                    }
                }
            }
        } catch(Exception e) {
            Database.rollback(sp);
            //throw new ApplicationException('Exception occured while syncing IDP. ' + e.getMessage());
            RestContext.response.statusCode = 400;
            SalesforceError err = new SalesforceError(ERROR_CODE_BAD_REQUEST, e.getMessage());
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(err));
        }
        */
    }

    private static String getEmployeeNumber() {
        String employeeNumber = [
            SELECT EmployeeNumber
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ]?.EmployeeNumber;

        if (String.isBlank(employeeNumber)) throw new ApplicationException(ERROR_MESSAGE_EMPTY_EMPLOYEE_NUMBER);

        return employeeNumber;
    }

    private static String getIsUserFullTimeEmployee() {
        User contextUser = [
            SELECT Id, Is_Employee__c, EmployeeNumber
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];

        if (String.isBlank(contextUser?.EmployeeNumber)) throw new ApplicationException(ERROR_MESSAGE_EMPTY_EMPLOYEE_NUMBER);

        return JSON.serialize(contextUser.Is_Employee__c);
    }
    
    global class IDPQuipRequest {
        public IDP__c idp {get; set;}
        public List<IDPObjective> idpObjectives {get; set;}
    }
    
    global class IDPObjective {
        public IDP_Objective__c idpObjective {get; set;}
        public List<IDP_Action__c> idpActions {get; set;}
    }
    
    public class SalesforceError {
        public String errorCode;
        public String message;
        public SalesforceError(String errorCode, string message){
            this.errorCode = errorCode;
            this.message = message;
        }
    }
}