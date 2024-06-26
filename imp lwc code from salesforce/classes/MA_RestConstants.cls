/**
 * W-11134167
 * Abstract class to hold common Constants used in MA Apex REST service classes.
 * 
 * Version      Date            Author                  Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         23/05/2022      Chakshu Malhotra        Holds common constants used in MA Apex REST service classes.
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract class MA_RestConstants {
    public enum ErrorStatusCode {BAD_REQUEST, NOT_FOUND, METHOD_NOT_ALLOWED, REQUIRED_FIELD_MISSING, UNKNOWN_MA_WORKER, UNKNOWN_ACQUIRED_COMPANY}

    public static final Integer STATUS_CODE_200 = 200;
    public static final Integer STATUS_CODE_400 = 400;
    public static final Integer STATUS_CODE_404 = 404;
    public static final Integer STATUS_CODE_405 = 405;

    public static final String LOG_TYPE = 'ERROR';
    public static final String LOG_APPLICATION = 'MA';
    public static final String LOG_COMPONENT = 'APEX CLASS';

    public static final String RESPONSE_ATTRIBUTE_ERRORS = 'errors';
    public static final String RESPONSE_ATTRIBUTE_SUCCESS = 'success';
    public static final String RESPONSE_ATTRIBUTE_REFERENCE_ID = 'referenceId';

    public static final String ERROR_ATTRIBUTE_FIELDS = 'fields';
    public static final String ERROR_ATTRIBUTE_MESSAGE = 'message';
    public static final String ERROR_ATTRIBUTE_STATUS_CODE = 'statusCode';

    public static final String HEADER_CONTENT_TYPE = 'Content-Type';
    public static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';

    public static final String ERROR_MESSAGE_NOT_FOUND = 'Could not find a match for URL';
    public static final String ERROR_MESSAGE_BAD_REQUEST_BODY = 'Request body isn\'t well formed for this API';
    public static final String ERROR_MESSAGE_BAD_REQUEST_VOLUME = 'Request cannot have more than {0} records';
    public static final String ERROR_MESSAGE_REQUIRED_FIELD_MISSING = 'Required fields {0} missing for M&A Worker with detail : {1}';
    public static final String ERROR_MESSAGE_UNKNOWN_MA_WORKER = 'Could not find the M&A Worker with detail : {0}';
    public static final String ERROR_MESSAGE_UNKNOWN_ACQUIRED_COMPANY = 'Could not find Acquired Company Name {0} for M&A Worker with detail : {1}';
}