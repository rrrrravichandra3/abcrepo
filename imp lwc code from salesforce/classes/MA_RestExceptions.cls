/**
 * W-11134167
 * Abstract class to hold common REST exceptions to be thrown while processing the Apex REST service classes.
 * 
 * Version      Date            Author                  Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         23/05/2022      Chakshu Malhotra        Implements methods to throw exceptions while processing the Apex REST service classes.
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract class MA_RestExceptions {
    
    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Class to hold ErrorResponse details to be sent in the Http response when a custom REST exception is thrown while processing the request. 
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class ErrorResponse {
        public String errorCode;
        public String message;

        private ErrorResponse(String errorCode, string message) {
            this.errorCode = errorCode;
            this.message = message;
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Class to hold custom REST exception type to be thrown while processing the request. 
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class HttpException extends Exception {
        public final String errorCode;
        public final Integer statusCode;
        private final ErrorResponse errorResponse;

        private HttpException(String errorCode, Integer statusCode) {
            this.errorCode = errorCode;
            this.statusCode = statusCode;
        }

        private HttpException(String errorCode, Integer statusCode, String message) {
            this(errorCode, statusCode);
            this.setMessage(message);
            this.errorResponse = new ErrorResponse(errorCode, message);
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method is used to get the Blob type to be set in RestContext.response.responseBody for the ErrorResponse type
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   Blob        DESCRIPTION (return Blob type to be set in RestContext.response.responseBody for the ErrorResponse type)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Blob getBlobErrorResponse() {
            return Blob.valueOf(JSON.serialize(new ErrorResponse[]{this.errorResponse}));
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to throw 400 Bad Request exception for a bad request format or request volume too large.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    message         DESCRIPTION (Data type String, Exception message to be added to the ErrorResponse type.)
    * @return   HttpException   DESCRIPTION (return HttpException type for the 400 Bad Request exception)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static HttpException throw400BadRequest(String message) {
        throw new HttpException(MA_RestConstants.ErrorStatusCode.BAD_REQUEST.name(), MA_RestConstants.STATUS_CODE_400, message);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to throw 404 Not Found exception for an invalid requestURI used to call the Apex REST service.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    message         DESCRIPTION (Data type String, Exception message to be added to the ErrorResponse type.)
    * @return   HttpException   DESCRIPTION (return HttpException type for the 404 Not Found exception)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static HttpException throw404NotFound(String message) {
        throw new HttpException(MA_RestConstants.ErrorStatusCode.NOT_FOUND.name(), MA_RestConstants.STATUS_CODE_404, message);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to throw 405 Method Not Allowed exception for an invalid Http MEthod used to call the Apex REST service.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    message         DESCRIPTION (Data type String, Exception message to be added to the ErrorResponse type.)
    * @return   HttpException   DESCRIPTION (return HttpException type for the 405 Method Not Allowed exception)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static HttpException throw405MethodNotAllowed(String message) {
        throw new HttpException(MA_RestConstants.ErrorStatusCode.METHOD_NOT_ALLOWED.name(), MA_RestConstants.STATUS_CODE_405, message);
    }
}