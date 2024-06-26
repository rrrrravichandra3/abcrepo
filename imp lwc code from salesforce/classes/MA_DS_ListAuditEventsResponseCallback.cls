/**
 * W-12218399
 * Extends MA_DS_AbstractResponseCallback class to handle success & error response for the eSignature API request to List Audit Events of the Envelope.
 * 
 * Version      Date            Author                  Description
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         14/11/2023      Chakshu Malhotra        W-12218399 - Adds logic to handle response for the eSignature API request to List Audit Events of the Envelope.
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_ListAuditEventsResponseCallback extends MA_DS_AbstractResponseCallback  {
    
    private static final String STATUS_OK = Label.MA_DS_Status_Code_OK;
    private static final String STATUS_OBJECT_CREATED = Label.MA_DS_Status_Code_Object_Created;

    private static final String EVENT_FIELD_ACTION = Label.MA_DS_List_Audit_Event_Field_Action;
    private static final String EVENT_FIELD_ACTION_SIGNED = Label.MA_DS_List_Audit_Event_Field_Action_Signed;
    private static final String EVENT_FIELD_CLIENT_IP_ADDRESS = Label.MA_DS_List_Audit_Event_Field_ClientIPAddress;

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to parse HttpResponse and invoke success / failure handler based on the Status code received in the response.
    * Provides handler for CalloutException (if any) during API callout.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                    DESCRIPTION (Data Type Id, Source Record Id from where the API Request is sent)
    * @param    eSignAPIRequest	                DESCRIPTION (Data Type HttpRequest, Http API Request instance)
    * @param    eSignAPIResponse	            DESCRIPTION (Data Type HttpResponse, Http API Response instance)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void handleResponse(Id srcRecordId, HttpRequest eSignAPIRequest, HttpResponse eSignAPIResponse) {
        try {
            super.handleResponse(srcRecordId, eSignAPIRequest, eSignAPIResponse);
            if(this.responseStatusCode == Integer.valueOf(STATUS_OK) || this.responseStatusCode == Integer.valueOf(STATUS_OBJECT_CREATED)) {
                this.handleSuccessResponse(srcRecordId);
            }
        }catch(MA_DS_CalloutFramework.CalloutServiceException exType) {
            this.handleErrorResponse(exType, MA_DS_CalloutFramework.CalloutServiceException.class.getName());
        }catch(MA_DS_CalloutFramework.CalloutResponseException exType) {
            this.handleErrorResponse(exType, MA_DS_CalloutFramework.CalloutResponseException.class.getName());
        }catch(Exception exType) {
            this.handleErrorResponse(exType, exType.getTypeName());
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to handle Success response, extracts ClientIPAddress from the responseBody where Audit Event's Action is "Signed".
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                    DESCRIPTION (Data Type Id, Source Record Id from where the API Request is sent)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void handleSuccessResponse(Id srcRecordId) {
        ListAuditEventsResponse listAuditEventsResponse = (ListAuditEventsResponse)JSON.deserialize(JSON.serialize(this.responseBody), ListAuditEventsResponse.class);

        EventField actionEventFieldRef = new EventField(EVENT_FIELD_ACTION);
        EventField clientIPAddressEventFieldRef = new EventField(EVENT_FIELD_CLIENT_IP_ADDRESS);

        for(AuditEvent auditEvent : listAuditEventsResponse?.auditEvents) {
            Integer actionEventFieldIndex = auditEvent?.eventFields?.indexOf(actionEventFieldRef);

            if(actionEventFieldIndex > -1) {
                EventField actionEventField = auditEvent?.eventFields?.get(actionEventFieldIndex);

                if(actionEventField != null && actionEventField.value?.equalsIgnoreCase(EVENT_FIELD_ACTION_SIGNED)) {
                    Integer clientIPAddressEventFieldIndex = auditEvent?.eventFields?.indexOf(clientIPAddressEventFieldRef);
                    EventField clientIPAddressEventField = auditEvent?.eventFields?.get(clientIPAddressEventFieldIndex);

                    if(clientIPAddressEventField != null && String.isNotBlank(clientIPAddressEventField.value)) {
                        MA_DS_ListAuditEventsResponseCallback.updateSourceRecord(srcRecordId, clientIPAddressEventField.value);
                        break;
                    }
                }
            }
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the "Signer's IP Address" of the srcRecord (Acquisition Contact) processed for the List Audit Events API callout.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	                    DESCRIPTION (Data Type Id, Source Record Id from where the API Request is sent)
    * @param    clientIPAdddress	            DESCRIPTION (Data Type String, ClientIPAddress of the Audit Event where Action is "Signed")
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateSourceRecord(Id srcRecordId, String clientIPAdddress) {
        Acquisition_Contacts__c srcRecord = new Acquisition_Contacts__c(Id = srcRecordId);
        srcRecord.MA_DS_Signer_IP_Address__c = clientIPAdddress;

        Acquisition_Contacts_Trigger_Handler.triggerDisabled = true;
        Database.SaveResult[] srcRecordsSRList = Database.update(new List<Acquisition_Contacts__c> {srcRecord}, false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(srcRecordsSRList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the response body; List of Audit Events from API callout to DocuSign eSignature.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class ListAuditEventsResponse {
        public List<AuditEvent> auditEvents;
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the List of Event Fields for each Audit Event.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class AuditEvent {
        public List<EventField> eventFields;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the peoperties of each Event Field reference.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class EventField {
        public String name;
        public String value;
        
        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Default constructor of EventField class to allow deserialization of Http Response Body from the API callout.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public EventField() {}
        
        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the EventField class.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    name	            DESCRIPTION (Data Type String, Name of the Event Field for a given Audit Event)
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public EventField(String name) {
            this.name = name;
        }
        
        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to support comparison ability & determines uniqueness of the the Custom Object types consistently.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    obj	                DESCRIPTION (Data Type Object, Reference for the Custom Object type)
        * @return   Boolean             DESCRIPTION (return true if two Custom Object types are equal)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Boolean equals(Object obj) {
            Boolean isEquals = false;
    
            if(obj instanceof EventField) {
                EventField eventFieldObj = (EventField) obj;
                isEquals = this.name.equalsIgnoreCase(eventFieldObj.name);
            }
    
            return isEquals;
        }
        
        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Method to provide consistent hashCode value for a given Custom Object type.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   Integer             DESCRIPTION (return hashCode value for a given Custom Object type)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Integer hashCode() {
            return System.hashCode(name);
        }
    }
}