/**
 * W-10149775
 * Abstract class to trace Bulk Result lists for any errors and logging it in PF Debug Log.
 * 
 * Version      Date            Author                  Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         13/12/2021      Chakshu Malhotra        Implements strategy pattern to identify right implemtation of logging errors for Bulk result list.
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract class MA_AbstractLogger {

    public enum BulkLoggerType {SAVE_RESULT, UPSERT_RESULT, DELETE_RESULT, SEND_EMAIL_RESULT}
    
    private static final String LOG_TYPE = 'ERROR';
    private static final String LOG_APPLICATION = 'MA';
    private static final String LOG_COMPONENT = 'APEX CLASS';

    private static BulkLoggerStrategy bulkLoggerStrategy;

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Interface to trace & log errors on Bulk Result list. Created to remove dependency from actual implementation.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private interface BulkResultLogger {
        void traceAndLogErrors(List<Object> resultList);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Abstract class that implements BulkResultLogger interface and hold common methods for its child classes.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private abstract class AbstractBulkResultLogger implements BulkResultLogger {
        protected abstract void traceAndLogErrors(List<Object> resultList);

        protected void addErrorLog(List<Database.Error> errors) {
            String errorMessage = errors[0].getMessage();
            String errorDescription = JSON.serialize(errors);
            String errorType = String.valueOf(errors[0].getStatusCode());
            PF_Logger.log(LOG_APPLICATION, LOG_TYPE, errorMessage, errorType, errorDescription, LOG_COMPONENT);
        }

        protected void addErrorLog(List<Messaging.SendEmailError> errors) {
            String errorMessage = errors[0].getMessage();
            String errorDescription = JSON.serialize(errors);
            String errorType = String.valueOf(errors[0].getStatusCode());
            PF_Logger.log(LOG_APPLICATION, LOG_TYPE, errorMessage, errorType, errorDescription, LOG_COMPONENT);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Sub-class of AbstractBulkResultLogger to parse List of Database.SaveResult records and trace & log errors if any.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class BulkSaveResultLogger extends AbstractBulkResultLogger {
        public override void traceAndLogErrors(List<Object> resultList) {
            List<Database.SaveResult> srList = (List<Database.SaveResult>)resultList;
            for(Database.SaveResult sr : srList) {
                if(!sr.isSuccess()) {
                    super.addErrorLog(sr.getErrors());
                }
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Sub-class of AbstractBulkResultLogger to parse List of Database.UpsertResult records and trace & log errors if any.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class BulkUpsertResultLogger extends AbstractBulkResultLogger {
        public override void traceAndLogErrors(List<Object> resultList) {
            List<Database.UpsertResult> urList = (List<Database.UpsertResult>)resultList;
            for(Database.UpsertResult ur : urList) {
                if(!ur.isSuccess()) {
                    super.addErrorLog(ur.getErrors());
                }
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Sub-class of AbstractBulkResultLogger to parse List of Database.DeleteResult records and trace & log errors if any.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class BulkDeleteResultLogger extends AbstractBulkResultLogger {
        public override void traceAndLogErrors(List<Object> resultList) {
            List<Database.DeleteResult> drList = (List<Database.DeleteResult>)resultList;
            for(Database.DeleteResult dr : drList) {
                if(!dr.isSuccess()) {
                    super.addErrorLog(dr.getErrors());
                }
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Sub-class of AbstractBulkResultLogger to parse List of Messaging.SendEmailResult records and trace & log errors if any.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class BulkSendEmailResultLogger extends AbstractBulkResultLogger {
        public override void traceAndLogErrors(List<Object> resultList) {
            List<Messaging.SendEmailResult> seList = (List<Messaging.SendEmailResult>)resultList;
            for(Messaging.SendEmailResult se : seList) {
                if(!se.isSuccess()) {
                    super.addErrorLog(se.getErrors());
                }
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to retrieve singleton instance of BulkLoggerStrategy type.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   BulkLoggerStrategy        DESCRIPTION (return instance of BulkLoggerStrategy)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static BulkLoggerStrategy getBulkLoggerStrategy() {
        if(bulkLoggerStrategy == null) {
            bulkLoggerStrategy = new BulkLoggerStrategy();
        }
        return bulkLoggerStrategy;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Strategy class to idenitfy right implementation of BulkResultLogger and trace & log errors if any. 
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class BulkLoggerStrategy {
        private BulkLoggerStrategy() {
            // to enforce singleton design
        }
        
        public void traceAndLogErrors(List<Object> resultList, BulkLoggerType loggerType) {
            BulkResultLogger resultLogger = getBulkResultLogger(loggerType);
            PF_Logger.logs.clear();
            resultLogger.traceAndLogErrors(resultList);
            PF_Logger.createLogs(PF_Logger.logs);
        }

        private BulkResultLogger getBulkResultLogger(BulkLoggerType loggerType) {
            Type loggerTypeImpl;

            switch on loggerType {
                when SAVE_RESULT {
                    loggerTypeImpl = BulkSaveResultLogger.class;
                }when UPSERT_RESULT {
                    loggerTypeImpl = BulkUpsertResultLogger.class;
                }when DELETE_RESULT {
                    loggerTypeImpl = BulkDeleteResultLogger.class;
                }when SEND_EMAIL_RESULT {
                    loggerTypeImpl = BulkSendEmailResultLogger.class;
                }
            }

            return (BulkResultLogger)loggerTypeImpl.newInstance();
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to log exception in PF_Logger
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    exType 	                DESCRIPTION (Data type Exception, Type of exception)
    * @param    exceptionIdentifier     DESCRIPTION (Data type String, An identifier for the exception type)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void logException(Exception exType, String exceptionIdentifier) {
        PF_Logger.logs.clear();
        String errorType = exType.getTypeName();
        String errorMessage = exType.getMessage();
        String errorDescription = exType.getStackTraceString();
        PF_Logger.log(LOG_APPLICATION, LOG_TYPE, errorMessage, errorType, errorDescription, LOG_COMPONENT, exceptionIdentifier);
        PF_Logger.createLogs(PF_Logger.logs);
    }
}