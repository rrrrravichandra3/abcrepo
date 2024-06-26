/**
 * W-11134167
 * Abstract class to execute Queueable job to log errors for acquired contacts that failed while updating / syncing the workday worker Id.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         24/05/2022      Chakshu Malhotra        Implements the queueable logic to log errors for acquired contacts that failed while updating / syncing the workday worker Id.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract class MA_WorkerIdSyncLoggerService {

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to initialize & execute the queueable job to log errors for acquired contacts that failed while being updated.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    responseBodyJSON            DESCRIPTION (Data type String, Serialized error response sent in the Http response body.)
    * @param    unknownCompanyErrorsJSON    DESCRIPTION (Data type String, Serialized errors for unknown acquired company names in the request body.)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void logErrors(String responseBodyJSON, String unknownCompanyErrorsJSON) {
        ErrorLogger loggingJob = new ErrorLogger(responseBodyJSON, unknownCompanyErrorsJSON);
        Id loggingJobId = System.enqueueJob(loggingJob);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queueable implementation to log errors for any acquired contact that failed during update operation.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class ErrorLogger implements Queueable {
        private String responseBodyJSON;
        private String unknownCompanyErrorsJSON;

        private String logType = MA_RestConstants.LOG_TYPE;
        private String component = MA_RestConstants.LOG_COMPONENT;
        private String application = MA_RestConstants.LOG_APPLICATION;

        public ErrorLogger(String responseBodyJSON, String unknownCompanyErrorsJSON) {
            this.responseBodyJSON = responseBodyJSON;
            this.unknownCompanyErrorsJSON = unknownCompanyErrorsJSON;
        }
        
        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Queueable interface method to bulk insert error logs for acquired contacts that failed while being updated.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    qContext    DESCRIPTION (Data type QueueableContext, Queueable context variable containing Job Id.)
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void execute(QueueableContext qContext) {
            PF_Logger.logs.clear();
            logResponseBodyErrors();
            logUnknownCompanyErrors();
            Database.insert(PF_Logger.logs, false);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method is used to log errors sent in the Http response (RestContext.response.responseBody).
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void logResponseBodyErrors() {
            List<Object> responseBody = (List<Object>)JSON.deserializeUntyped(responseBodyJSON);
            
            for(Object response : responseBody) {
                Map<String, Object> responseMap = (Map<String, Object>) response;

                if(!(Boolean)responseMap.get(MA_RestConstants.RESPONSE_ATTRIBUTE_SUCCESS)) {
                    PF_Debug_Log__c log = getDebugLog(responseMap.get(MA_RestConstants.RESPONSE_ATTRIBUTE_ERRORS));
                    Object referenceId = responseMap.get(MA_RestConstants.RESPONSE_ATTRIBUTE_REFERENCE_ID);
                    log.Record_Id__c = (referenceId == null) ? null : (String)referenceId;
                    PF_Logger.logs.add(log);
                }
            }
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method is used to initialize the PF_Debug_Log__c instance with key details & description to the error.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    errorDescription    DESCRIPTION (Data type Object, Error description containing error statusCode, message & fields.)
        * @return   PF_Debug_Log__c     DESCRIPTION (return PF_Debug_Log__c instance with key details & description to the error)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private PF_Debug_Log__c getDebugLog(Object errorDescription) {
            PF_Debug_Log__c log = new PF_Debug_Log__c(Type__c = logType, Component__c = component, Application__c = application);
            log.Running_User__c = UserInfo.getUserId();
            log.Description__c = JSON.serialize(errorDescription);
            return log;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method is used to log errors for the unknown acquired company names received in the Http request (RestContext.request.requestBody).
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private void logUnknownCompanyErrors() {
            List<Object> unknownCompanyErrors = (List<Object>)JSON.deserializeUntyped(unknownCompanyErrorsJSON);

            for(Object unknownCompanyError : unknownCompanyErrors) {
                Map<String, Object> unknownCompanyErrorMap = (Map<String, Object>) unknownCompanyError;
                PF_Debug_Log__c log = getDebugLog(unknownCompanyError);
                Integer permissibleLength = PF_Debug_Log__c.Error_Message__c.getDescribe().getLength();
                log.Error_Message__c = ((String)unknownCompanyErrorMap.get(MA_RestConstants.ERROR_ATTRIBUTE_MESSAGE)).abbreviate(permissibleLength);
                PF_Logger.logs.add(log);
            }
        }
    }
}