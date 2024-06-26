/**
 * Test class implementing HttpCalloutMock to mock DocuSign API callouts and generate HttpResponse based on CalloutResponse type.
 * 
 * Version      Date            Author                  Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         04/12/2023      Chakshu Malhotra        Adds logic to mock DocuSign API callouts and generate HttpResponse based on CalloutResponse type.
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
@isTest
public class MA_DS_TestCallout_MultiMock implements HttpCalloutMock {
    
    public enum CalloutResponse {UNAUTHORIZED_ENDPOINT, 
                                 WORKFLOW_STARTED, WORKFLOW_BAD_REQUEST, WORKFLOW_NOT_FOUND, WORKFLOW_MALFORMED_RESPONSE, 
                                 AUDIT_EVENTS_FOUND, AUDIT_EVENTS_BAD_REQUEST, AUDIT_EVENTS_NOT_FOUND, AUDIT_EVENTS_MALFORMED_RESPONSE}

    private final ResponseGeneratorStrategy strategyInstance;

    private static final Integer STATUS_CODE_200 = 200;
    private static final String STATUS_OK = 'OK';

    private static final Integer STATUS_CODE_201 = 201;
    private static final String STATUS_CREATED = 'Object Created';

    private static final Integer STATUS_CODE_400 = 400;
    private static final Integer CLM_ERROR_CODE_101 = 101;
    private static final String STATUS_BAD_REQUEST = 'Bad Request';

    private static final Integer STATUS_CODE_404 = 404;
    private static final Integer CLM_ERROR_CODE_104 = 104;
    private static final String STATUS_NOT_FOUND = 'Not Found';

    private static final String HEADER_KEY_CONTENT_TYPE = 'Content-Type';
    private static final String CONTENT_TYPE_APP_JSON = 'application/json';

    private static final String WORKFLOW_STATUS = 'Executing';

    private static final String WORKFLOW_ERROR_KEY = 'Error';
    private static final String WORKFLOW_STATUS_KEY = Label.MA_DS_Workflow_Object_Attribute_Status;

    private static final String CLM_ERROR_RESPONSE_REF_ID = 'b797912a-xxxx-xxxx-xxxx-6febc4e07875';

    private static final String UNAUTHORIZED_EXCEPTION_MSG = 'Unauthorized endpoint, please check Setup->Security->Remote site settings.';
    
    private static final String AUDIT_EVENTS_CLIENT_IP_ADDRESS_VALUE = '24.14.151.60';
    private static final String AUDIT_EVENTS_FIELD_ACTION = Label.MA_DS_List_Audit_Event_Field_Action;
    private static final String AUDIT_EVENTS_ACTION_SIGNED = Label.MA_DS_List_Audit_Event_Field_Action_Signed;
    private static final String AUDIT_EVENTS_FIELD_CLIENT_IP_ADDRESS = Label.MA_DS_List_Audit_Event_Field_ClientIPAddress;
    
    public static final String CALLOUT_SERVICE_EXCEPTION_IDENTIFIER = MA_DS_CalloutFramework.CalloutServiceException.class.getName();
    public static final String ASSERT_MSG_CALLOUT_SERVICE_EXCEPTION_NOT_LOGGED = 'Failed to log MA_DS_CalloutFramework.CalloutServiceException!';

    public static final String CALLOUT_RESPONSE_EXCEPTION_IDENTIFIER = MA_DS_CalloutFramework.CalloutResponseException.class.getName();
    public static final String ASSERT_MSG_CALLOUT_RESPONSE_EXCEPTION_NOT_LOGGED = 'Failed to log MA_DS_CalloutFramework.CalloutResponseException!';

    public static final String JSON_EXCEPTION_IDENTIFIER = System.JSONException.class.getName();
    public static final String ASSERT_MSG_JSON_EXCEPTION_NOT_LOGGED = 'Failed to log System.JSONException!';

    public MA_DS_TestCallout_MultiMock(CalloutResponse calloutResponseType) {
        strategyInstance = new ResponseGeneratorStrategy();
        strategyInstance.initResponseGenerator(calloutResponseType);
    }

    public HttpResponse respond(HttpRequest request) {
        return strategyInstance.getResponse(request);
    }

    private class ResponseGeneratorStrategy {
        private ResponseGenerator responseGenerator;

        public ResponseGeneratorStrategy() {
            responseGenerator = null;
        }

        public void initResponseGenerator(CalloutResponse calloutResponseType) {
            Type responseGeneratorType;

            switch on calloutResponseType {
                when UNAUTHORIZED_ENDPOINT {
                    responseGeneratorType = UnauthorizedEndpointResponseGenerator.class;
                }when WORKFLOW_STARTED {
                    responseGeneratorType = WorkflowStartedResponseGenerator.class;
                }when WORKFLOW_BAD_REQUEST {
                    responseGeneratorType = WorkflowBadRequestResponseGenerator.class;
                }when WORKFLOW_NOT_FOUND {
                    responseGeneratorType = WorkflowNotFoundResponseGenerator.class;
                }when WORKFLOW_MALFORMED_RESPONSE {
                    responseGeneratorType = WorkflowMalformedResponseGenerator.class;
                }when AUDIT_EVENTS_FOUND {
                    responseGeneratorType = AuditEventsFoundResponseGenerator.class;
                }when AUDIT_EVENTS_BAD_REQUEST {
                    responseGeneratorType = AuditEventsBadRequestResponseGenerator.class;
                }when AUDIT_EVENTS_NOT_FOUND {
                    responseGeneratorType = AuditEventsNotFoundResponseGenerator.class;
                }when AUDIT_EVENTS_MALFORMED_RESPONSE {
                    responseGeneratorType = AuditEventsMalformedResponseGenerator.class;
                }
            }

            responseGenerator = (ResponseGenerator)responseGeneratorType.newInstance();
        }

        public HttpResponse getResponse(HttpRequest request) {
            return responseGenerator.getResponse(request);
        }
    }

    private interface ResponseGenerator {
        Object getMockResponseObject();
        HttpResponse getResponse(HttpRequest request);
    }

    private abstract class AbstractResponseGenerator implements ResponseGenerator {
        protected abstract HttpResponse getResponse(HttpRequest request);

        protected HttpResponse getResponse(Integer statusCode, String status, String body) {
            HttpResponse response = new HttpResponse();
            response.setBody(body);
            response.setStatus(status);
            response.setStatusCode(statusCode);
            response.setHeader(HEADER_KEY_CONTENT_TYPE, CONTENT_TYPE_APP_JSON);
            return response;
        }

        protected CLMErrorResponse getCLMErrorResponse(Integer ErrorCode, Integer HttpStatusCode, String DeveloperMessage) {
            return new CLMErrorResponse(ErrorCode, CLM_ERROR_RESPONSE_REF_ID, DeveloperMessage, HttpStatusCode, DeveloperMessage);
        }

        protected ESignErrorResponse getESignErrorResponse(Integer errorCode, String message) {
            return new ESignErrorResponse(errorCode, message);
        }

        public virtual Object getMockResponseObject() {
            return null;
        }
    }

    private class UnauthorizedEndpointResponseGenerator extends AbstractResponseGenerator {
        public override HttpResponse getResponse(HttpRequest request) {
            throw new System.CalloutException(UNAUTHORIZED_EXCEPTION_MSG);
        }
    }

    private class WorkflowStartedResponseGenerator extends AbstractResponseGenerator {
        public override HttpResponse getResponse(HttpRequest request) {
            JSONGenerator bodyGen = JSON.createGenerator(false);
            bodyGen.writeStartObject();
            bodyGen.writeStringField(WORKFLOW_STATUS_KEY, WORKFLOW_STATUS);
            bodyGen.writeEndObject();
            return super.getResponse(STATUS_CODE_201, STATUS_CREATED, bodyGen.getAsString());
        }
    }

    private class WorkflowBadRequestResponseGenerator extends AbstractResponseGenerator {
        public override HttpResponse getResponse(HttpRequest request) {
            JSONGenerator bodyGen = JSON.createGenerator(false);
            bodyGen.writeStartObject();
            bodyGen.writeObjectField(WORKFLOW_ERROR_KEY, super.getCLMErrorResponse(CLM_ERROR_CODE_101, STATUS_CODE_400, STATUS_BAD_REQUEST));
            bodyGen.writeEndObject();
            return super.getResponse(STATUS_CODE_400, STATUS_BAD_REQUEST, bodyGen.getAsString());
        }
    }

    private class WorkflowNotFoundResponseGenerator extends AbstractResponseGenerator {
        public override HttpResponse getResponse(HttpRequest request) {
            JSONGenerator bodyGen = JSON.createGenerator(false);
            bodyGen.writeStartObject();
            bodyGen.writeObjectField(WORKFLOW_ERROR_KEY, super.getCLMErrorResponse(CLM_ERROR_CODE_104, STATUS_CODE_404, STATUS_NOT_FOUND));
            bodyGen.writeEndObject();
            return super.getResponse(STATUS_CODE_404, STATUS_NOT_FOUND, bodyGen.getAsString());
        }
    }

    private class WorkflowMalformedResponseGenerator extends AbstractResponseGenerator {
        public override HttpResponse getResponse(HttpRequest request) {
            return super.getResponse(STATUS_CODE_201, STATUS_CREATED, '{"status":}');
        }
    }

    private class CLMErrorResponse {
        public Integer ErrorCode {get; private set;}
        public String ReferenceId {get; private set;}
        public String UserMessage {get; private set;}
        public Integer HttpStatusCode {get; private set;}
        public String DeveloperMessage {get; private set;}

        public CLMErrorResponse() {}

        public CLMErrorResponse(Integer ErrorCode, String ReferenceId, String UserMessage, Integer HttpStatusCode, String DeveloperMessage) {
            this.ErrorCode = ErrorCode;
            this.ReferenceId = ReferenceId;
            this.UserMessage = UserMessage;
            this.HttpStatusCode = HttpStatusCode;
            this.DeveloperMessage = DeveloperMessage;
        }
    }

    private class AuditEventsFoundResponseGenerator extends AbstractResponseGenerator {
        public override HttpResponse getResponse(HttpRequest request) {
            JSONGenerator bodyGen = JSON.createGenerator(false);
            bodyGen.writeObject(getMockResponseObject());
            return super.getResponse(STATUS_CODE_200, STATUS_OK, bodyGen.getAsString());
        }

        public override Object getMockResponseObject() {
            return new AuditEvents(
                new List<AuditEvent> {
                    new AuditEvent(new List<EventField> {
                        new EventField(AUDIT_EVENTS_FIELD_ACTION, AUDIT_EVENTS_ACTION_SIGNED), 
                        new EventField(AUDIT_EVENTS_FIELD_CLIENT_IP_ADDRESS, AUDIT_EVENTS_CLIENT_IP_ADDRESS_VALUE)
                    })
                });
        }
    }

    private class AuditEvents {
        public List<AuditEvent> auditEvents;

        public AuditEvents() {}

        public AuditEvents(List<AuditEvent> auditEvents) {
            this.auditEvents = auditEvents;
        }
    }
    
    private class AuditEvent {
        public List<EventField> eventFields;

        public AuditEvent() {}

        public AuditEvent(List<EventField> eventFields) {
            this.eventFields = eventFields;
        }
    }

    private class EventField {
        public String name;
        public String value;
        
        public EventField() {}
        
        public EventField(String name, String value) {
            this.name = name;
            this.value = value;
        }
    }

    private class AuditEventsBadRequestResponseGenerator extends AbstractResponseGenerator {
        public override HttpResponse getResponse(HttpRequest request) {
            JSONGenerator bodyGen = JSON.createGenerator(false);
            bodyGen.writeObject(super.getESignErrorResponse(STATUS_CODE_400, STATUS_BAD_REQUEST));
            return super.getResponse(STATUS_CODE_400, STATUS_BAD_REQUEST, bodyGen.getAsString());
        }
    }

    private class AuditEventsNotFoundResponseGenerator extends AbstractResponseGenerator {
        public override HttpResponse getResponse(HttpRequest request) {
            JSONGenerator bodyGen = JSON.createGenerator(false);
            bodyGen.writeObject(super.getESignErrorResponse(STATUS_CODE_404, STATUS_NOT_FOUND));
            return super.getResponse(STATUS_CODE_404, STATUS_NOT_FOUND, bodyGen.getAsString());
        }
    }

    private class AuditEventsMalformedResponseGenerator extends AbstractResponseGenerator {
        public override HttpResponse getResponse(HttpRequest request) {
            return super.getResponse(STATUS_CODE_200, STATUS_OK, '{"auditEvents": [{"eventFields": [{]}]}');
        }
    }

    private class ESignErrorResponse {
        public Integer errorCode {get; private set;}
        public String message {get; private set;}

        public ESignErrorResponse() {}

        public ESignErrorResponse(Integer errorCode, String message) {
            this.errorCode = errorCode;
            this.message = message;
        }
    }
}