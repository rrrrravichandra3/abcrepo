/**
 * W-11134167
 * Abstract handler class for apex REST service MA_WorkerIdSyncService.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         23/05/2022      Chakshu Malhotra        Implements the logic to sync Workday Worker Id & set RestContext.response for the Http request
 * --------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing abstract class MA_WorkerIdSyncHandler {

    private static final String KEY_OTHER_ID = Label.MA_Key_OtherId;
    private static final String KEY_WORK_EMAIL = Label.MA_Key_WorkEmail;
    private static final String KEY_LEGAL_LAST_NAME = Label.MA_Key_LegalLastName;
    private static final String KEY_LEGAL_FIRST_NAME = Label.MA_Key_LegalFirstName;
    private static final String KEY_WORKDAY_WORKER_ID = Label.MA_Key_WorkdayWorkerId;
    private static final String KEY_ACQUIRED_COMPANY_NAME = Label.MA_Key_AcquiredCompanyName;

    private static final String DEFAULT_COMPANY_DEV_NAME = Label.MA_Default_Company;

    private static List<MA_REST_Services_Mapping__mdt> serviceMapping;

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the default company metadata type to be used in case of unknown company name received in the request. 
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static MA_Unknown_Companies_Mapping__mdt defaultCompany {
        get {
            if(defaultCompany == null) {
                defaultCompany = MA_Unknown_Companies_Mapping__mdt.getInstance(DEFAULT_COMPANY_DEV_NAME);
            }
            return defaultCompany;
        }set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the acquired contact records as received in the Http request body. 
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<Request> requestBody {
        get {
            if(requestBody == null) {
                requestBody = new List<Request>();
            }
            return requestBody;
        }set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the Http response body after updating the acquired contact records to sync the workday worker Id.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<Response> responseBody {
        get {
            if(responseBody == null) {
                responseBody = new List<Response>();
            }
            return responseBody;
        }set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the list of Unknown Company error records to be logged in PF Debug Log.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<UnknownCompanyError> unknownCompanyErrors {
        get {
            if(unknownCompanyErrors == null) {
                unknownCompanyErrors = new List<UnknownCompanyError>();
            }
            return unknownCompanyErrors;
        }set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the map of Mule External Id to respective Request instance to be used later to identify request index.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<String, Request> muleExtIdToRequestMap {
        get {
            if(muleExtIdToRequestMap == null) {
                muleExtIdToRequestMap = new Map<String, Request>();
            }
            return muleExtIdToRequestMap;
        }set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the map of Mule External Id to Acquisition Contact records to be updated with Workday Worker Id.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<String, Acquisition_Contacts__c> muleExtIdToContactMap {
        get {
            if(muleExtIdToContactMap == null) {
                muleExtIdToContactMap = new Map<String, Acquisition_Contacts__c>();
            }
            return muleExtIdToContactMap;
        }set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the list of Acquisition Contact records to be updated with Workday Worker Id.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<Acquisition_Contacts__c> acqContactList {
        get {
            if(acqContactList == null) {
                acqContactList = new List<Acquisition_Contacts__c>();
            }
            return acqContactList;
        }set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the list of Acquisition Provisioning records to be updated with Salesforce Email Address.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<Acquisition_Provisioning__c> acqProvisioningList {
        get {
            if(acqProvisioningList == null) {
                acqProvisioningList = new List<Acquisition_Provisioning__c>();
            }
            return acqProvisioningList;
        }set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Class to hold Http request data by deserializing the RestContext.request instance. 
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class Request {
        public String otherId {get; set;}
        public String workEmail {get; set;}
        public String legalLastName {get; set;}
        public String legalFirstName {get; set;}
        public String workdayWorkerId {get; set;}
        public String acquiredCompanyName {get; set;}
        transient public Integer requestIndex {get; set;}
        transient public List<String> missingFields {get; set;}

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method is used to validate if the Request type has all the required fields' values & adds the missing fields in the missingFields list.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    requiredJSONKeys        DESCRIPTION (Data type Set, Set of required JSON key attributes for the given request)
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void validateRequiredFields(Set<String> requiredJSONKeys) {
            missingFields = new List<String>();
            Map<String, String> attributesMap = getAttributeMap();

            for(String requiredJSONKey : requiredJSONKeys) {
                if(String.isBlank(attributesMap.get(requiredJSONKey))) {
                    missingFields.add(requiredJSONKey);
                }
            }
        }

        /**
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method is used to get the request attribute to its value map.
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   Map   DESCRIPTION (return Map of request attribute to attribute value)
        * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private Map<String, String> getAttributeMap() {
            return new Map<String, String> {KEY_OTHER_ID => otherId, KEY_WORK_EMAIL => workEmail, KEY_LEGAL_LAST_NAME => legalLastName,
                                            KEY_LEGAL_FIRST_NAME => legalFirstName, KEY_WORKDAY_WORKER_ID => workdayWorkerId, 
                                            KEY_ACQUIRED_COMPANY_NAME => acquiredCompanyName};
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Class to hold Http response data before serializing the RestContext.request.responseBody. 
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class Response implements Comparable {
        public Object errors {get; set;}
        public Boolean success {get; set;}
        public String referenceId {get; set;}
        transient public Integer responseIndex {get; set;}

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method implements interface method to provide logic for custom sorting for the list of Response types.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    compareTo       DESCRIPTION (Data type Object, Comparison with another Response type while sorting list of Response types)
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public Integer compareTo(Object compareTo) {
            Response responseObj = (Response)compareTo;
            return (this.responseIndex == responseObj.responseIndex) ? 0 : (this.responseIndex > responseObj.responseIndex) ? 1 : -1;
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Class to hold error details if a record doesn't exist for the "acquiredCompanyName" received in the request body.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class UnknownCompanyError {
        public String message;
        public String errorCode;
        public String referenceId;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to get Apex REST Service mapping details to check if the requestURI is valid.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    requestURI        DESCRIPTION (Data type String, RestContext.request.requestURI for the Apex REST Service)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void checkIfValidURI(String requestURI) {
        List<MA_REST_Services_Mapping__mdt> serviceMapping = getServiceMapping(requestURI);
        if(serviceMapping.isEmpty()) {
            MA_RestExceptions.throw404NotFound(MA_RestConstants.ERROR_MESSAGE_NOT_FOUND);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to get MA Apex REST Service mapping details for a given requestURI.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    requestURI        DESCRIPTION (Data type String, RestContext.request.requestURI for the Apex REST Service)
    * @return   List              DESCRIPTION (return List of MA_REST_Services_Mapping__mdt types for a unique requestURI)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<MA_REST_Services_Mapping__mdt> getServiceMapping(String requestURI) {
        if(serviceMapping == null) {
            serviceMapping = [SELECT Id, Permitted_Request_Volume__c 
                              FROM MA_REST_Services_Mapping__mdt 
                              WHERE Request_URI__c = :requestURI];
        }
        return serviceMapping;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to parse the requestBody of the Http RestContext.request and deserialize it into list of Request types.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    request         DESCRIPTION (Data type RestRequest, RestContext.request instance to access data as received from EI PWT adapter)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void parseRestRequestBody(RestRequest request) {
        try {
            requestBody.addAll((List<Request>) JSON.deserialize(request.requestBody.toString(), List<Request>.class));
        }catch(Exception ex) {
            MA_RestExceptions.throw400BadRequest(MA_RestConstants.ERROR_MESSAGE_BAD_REQUEST_BODY);
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to check if the number of records sent in the requestBody are as per the volume limits of the service.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void checkIfPermittedVolume() {
        if(requestBody.size() > serviceMapping[0].Permitted_Request_Volume__c) {
            String permittedVolume = String.valueOf(serviceMapping[0].Permitted_Request_Volume__c);
            String exceptionMessage = String.format(MA_RestConstants.ERROR_MESSAGE_BAD_REQUEST_VOLUME, new String[]{permittedVolume});
            MA_RestExceptions.throw400BadRequest(exceptionMessage);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to prepare the acquisition contact records to update to sync the workday worker Ids.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void prepareAcquiredContactsToUpdate() {
        List<Request> validRequests = new List<Request>();
        Set<String> acquiredCompanyNames = new Set<String>();
        Set<String> requiredJSONKeys = getRequiredJSONKeys();

        for(Integer requestIndex=0; requestIndex < requestBody.size(); requestIndex++) {
            Request request = requestBody[requestIndex];
            request.requestIndex = requestIndex;
            request.validateRequiredFields(requiredJSONKeys);

            if(request.missingFields.isEmpty()) {
                validRequests.add(request);
                acquiredCompanyNames.add(request.acquiredCompanyName.toLowerCase());
            }else {
                addRequiredFieldMissingError(request);
            }
        }

        prepareAcquiredContactsToUpdate(validRequests, acquiredCompanyNames);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to get the required attributes of the Http request based on the service mapping details.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   Set         DESCRIPTION (return Set of required JSON keys / attributes for a given service mapping.)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Set<String> getRequiredJSONKeys() {
        Set<String> jsonKeys = new Set<String>();
        List<MA_Services_Data_Mapping__mdt> serviceDataList = [SELECT JSON_Key__c FROM MA_Services_Data_Mapping__mdt 
                                                               WHERE MA_REST_Services_Mapping__c = :serviceMapping[0].Id AND
                                                               Required__c = true];
        for(MA_Services_Data_Mapping__mdt serviceData : serviceDataList) {
            jsonKeys.add(serviceData.JSON_Key__c);
        }

        return jsonKeys;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to create a Response type and add to the responseBody list if one or more of the required attributes are missing for a given Request type.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    request         DESCRIPTION (Data type Request, Request type for a corresponding acquired contact record received in the Http request)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void addRequiredFieldMissingError(Request request) {
        List<String> errorFields = request.missingFields;
        String errorMessage = String.format(MA_RestConstants.ERROR_MESSAGE_REQUIRED_FIELD_MISSING, new String[]{request.missingFields.toString(), JSON.serialize(request)});
        addErrorResponse(request, errorFields, errorMessage, MA_RestConstants.ErrorStatusCode.REQUIRED_FIELD_MISSING);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to create an Error Response type with details about Error Fields, Error Message and Error Status Code.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    request                 DESCRIPTION (Data type Request, Request type for a corresponding acquired contact record received in the Http request)
    * @param    errorFields             DESCRIPTION (Data type List, List of fields that caused the error)
    * @param    errorMessage            DESCRIPTION (Data type String, Error response message)
    * @param    statusCode              DESCRIPTION (Data type MA_RestConstants.ErrorStatusCode, Error Status Code to be added in Error Response)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void addErrorResponse(Request request, List<String> errorFields, String errorMessage, MA_RestConstants.ErrorStatusCode statusCode) {
        Response response = new Response();
        response.success = false;
        response.responseIndex = request.requestIndex;
        response.errors = getErrorAttributeMap(errorFields, statusCode.name(), errorMessage);
        responseBody.add(response);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to get the Map of Error details to be sent in the Http response for the missing required fields.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    errorFields             DESCRIPTION (Data type List, List of fields that caused the error)
    * @param    errorMessage            DESCRIPTION (Data type String, Error message)
    * @param    statusCode              DESCRIPTION (Data type String, String value of MA_RestConstants.ErrorStatusCode)
    * @return   Map                     DESCRIPTION (return Map of Error attribute to its value)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<String, Object> getErrorAttributeMap(List<String> errorFields, String errorMessage, String statusCode) {
        Map<String, Object> errorAttributeMap = new Map<String, Object>();
        if(errorFields != null && !errorFields.isEmpty()) {
            errorAttributeMap.put(MA_RestConstants.ERROR_ATTRIBUTE_FIELDS, errorFields);
        }
        errorAttributeMap.put(MA_RestConstants.ERROR_ATTRIBUTE_MESSAGE, errorMessage);
        errorAttributeMap.put(MA_RestConstants.ERROR_ATTRIBUTE_STATUS_CODE, statusCode);
        return errorAttributeMap;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to prepare the list of valid acquisition contact records to update.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    validRequests           DESCRIPTION (Data type List, List of valid Request types to parse)
    * @param    acquiredCompanyNames    DESCRIPTION (Data type Set, Set of acquired company names)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void prepareAcquiredContactsToUpdate(List<Request> validRequests, Set<String> acquiredCompanyNames) {
        Map<Id, String> unknownCompaniesMap = getUnknownCompaniesMap(acquiredCompanyNames);
        Map<String, Acquisition_Company__c> acquiredCompanyMap = getAcquiredCompanyMap(acquiredCompanyNames, unknownCompaniesMap);

        for(Request validRequest : validRequests) {
            Acquisition_Contacts__c updatedAcqContact = getAcquiredContactToUpdate(validRequest, acquiredCompanyMap);
            muleExtIdToContactMap.put(updatedAcqContact.MuleExtId__c, updatedAcqContact);
        }

        filterOutUnknownAcquiredContacts();
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to get the Map of Id of unknown acquired company to its name.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acquiredCompanyNames    DESCRIPTION (Data type Set, Set of acquired company names)
    * @return   Map                     DESCRIPTION (return Map of Id of unknown acquired company to its name)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<Id, String> getUnknownCompaniesMap(Set<String> acquiredCompanyNames) {
        Map<Id, String> unknownCompaniesMap = new Map<Id, String>();
        List<MA_Unknown_Companies_Mapping__mdt> unknownCompanies = [SELECT Acquired_Company_Id__c, Acquired_Company_Name__c
                                                                    FROM MA_Unknown_Companies_Mapping__mdt
                                                                    WHERE Acquired_Company_Name__c IN :acquiredCompanyNames];
        unknownCompanies.add(defaultCompany);

        for(MA_Unknown_Companies_Mapping__mdt unknownCompany : unknownCompanies) {
            unknownCompaniesMap.put(Id.valueOf(unknownCompany.Acquired_Company_Id__c), unknownCompany.Acquired_Company_Name__c);
        }
        return unknownCompaniesMap;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to get the Map of Id of unknown acquired company to acquisition company record.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acquiredCompanyNames    DESCRIPTION (Data type Set, Set of acquired company names)
    * @param    unknownCompaniesMap     DESCRIPTION (Data type Map, Map of Id of unknown acquired company to its name)
    * @return   Map                     DESCRIPTION (return Map of Id of unknown acquired company to acquisition company record)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<String, Acquisition_Company__c> getAcquiredCompanyMap(Set<String> acquiredCompanyNames, Map<Id, String> unknownCompaniesMap) {
        List<Acquisition_Company__c> acquiredCompanies = [SELECT Id, Name, Acquisition_Company_Name__c
                                                          FROM Acquisition_Company__c
                                                          WHERE Acquisition_Company_Name__c IN :acquiredCompanyNames OR
                                                          Id IN :unknownCompaniesMap.keySet()];
        
        Map<String, Acquisition_Company__c> acquiredCompanyMap = new Map<String, Acquisition_Company__c>();

        for(Acquisition_Company__c acquiredCompany : acquiredCompanies) {
            if(acquiredCompanyNames.contains(acquiredCompany.Acquisition_Company_Name__c.toLowerCase())) {
                acquiredCompanyMap.put(acquiredCompany.Acquisition_Company_Name__c.toLowerCase(), acquiredCompany);
            }else if(unknownCompaniesMap.containsKey(acquiredCompany.Id)) {
                acquiredCompanyMap.put(unknownCompaniesMap.get(acquiredCompany.Id).toLowerCase(), acquiredCompany);
            }
        }

        return acquiredCompanyMap;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to populate the Acquisition_Contacts__c record using the Request data and acquiredCompanyMap.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    request                     DESCRIPTION (Data type Request, Request type for individual record in the Http request)
    * @param    acquiredCompanyMap          DESCRIPTION (Data type Map, Map of Id of unknown acquired company to acquisition company record)
    * @return   Acquisition_Contacts__c     DESCRIPTION (return Acquisition Contact record the Request data and acquiredCompanyMap)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Acquisition_Contacts__c getAcquiredContactToUpdate(Request request, Map<String, Acquisition_Company__c> acquiredCompanyMap) {
        Acquisition_Contacts__c acqContact = new Acquisition_Contacts__c();
        acqContact.Employee_ID_Target__c = request.otherId;
        acqContact.Name = request.legalFirstName + ' ' + request.legalLastName;
        acqContact.Employee_ID__c = String.isBlank(request.workdayWorkerId) ? acqContact.Employee_ID__c : request.workdayWorkerId;

        String acquiredCompanyKey = request.acquiredCompanyName.toLowerCase();
        String defaultCompanyKey = defaultCompany.Acquired_Company_Name__c.toLowerCase();
        Acquisition_Company__c acquiredCompany = acquiredCompanyMap.containsKey(acquiredCompanyKey) ? acquiredCompanyMap.get(acquiredCompanyKey) : acquiredCompanyMap.get(defaultCompanyKey);

        acqContact.Acquisition_Company__c = acquiredCompany.Id;
        acqContact.Salesforce_Email_Address__c = request.workEmail;
        acqContact.MuleExtId__c = request.otherId + ':' + acquiredCompany.Name;

        muleExtIdToRequestMap.put(acqContact.MuleExtId__c, request);

        if(!request.acquiredCompanyName.equalsIgnoreCase(acquiredCompany.Acquisition_Company_Name__c)) {
            addUnknownCompanyError(request, acqContact.MuleExtId__c);
        }

        return acqContact;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to create UnknownCompanyError type instance and add it in unknownCompanyErrors list.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    request             DESCRIPTION (Data type Request, Request type for individual record in the Http request)
    * @param    referenceId         DESCRIPTION (Data type Map, The MuleExtId__c on acquisition contact record used to update)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void addUnknownCompanyError(Request request, String referenceId) {
        UnknownCompanyError error = new UnknownCompanyError();
        error.referenceId = referenceId;
        error.errorCode = MA_RestConstants.ErrorStatusCode.UNKNOWN_ACQUIRED_COMPANY.name();
        error.message = String.format(MA_RestConstants.ERROR_MESSAGE_UNKNOWN_ACQUIRED_COMPANY, new String[]{request.acquiredCompanyName, JSON.serialize(request)});
        unknownCompanyErrors.add(error);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to filter out Unknown M&A Workers from the list of Acquired Contacts to update. Error Response type is captured for the Unknown 
    * M&A Workers and added back to the responseBody list.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void filterOutUnknownAcquiredContacts() {
        Set<String> clonedMuleExtIds = muleExtIdToContactMap.keySet().clone();
        List<Acquisition_Provisioning__c> provisioningRecs = [SELECT Id, Acquisition_Contact__c, Acquisition_Contact__r.MuleExtId__c, Salesforce_Email_Address__c
                                                              FROM Acquisition_Provisioning__c
                                                              WHERE Acquisition_Contact__r.MuleExtId__c IN :clonedMuleExtIds];
        Set<String> validMuleExtIds = new Set<String>();

        for(Acquisition_Provisioning__c provisioningRec : provisioningRecs) {
            String validMuleExtId = provisioningRec.Acquisition_Contact__r.MuleExtId__c;
            validMuleExtIds.add(validMuleExtId);
            setupContactAndProvisioningToUpdate(validMuleExtId, provisioningRec);
        }

        clonedMuleExtIds.removeAll(validMuleExtIds);
        addUnknownWorkerErrorResponse(clonedMuleExtIds);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to add Id on the Acquisition Contact record and populate the Provisioning record with the Salesforce Email Address.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    validMuleExtId          DESCRIPTION (Data type String, A Valid MuleExtId as received upon querying Acquisition Provisioning records)
    * @param    provisioningRec         DESCRIPTION (Data type Acquisition_Provisioning__c, The Acquisition Provisioning record with Salesforce Email Address)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void setupContactAndProvisioningToUpdate(String validMuleExtId, Acquisition_Provisioning__c provisioningRec) {
        Acquisition_Contacts__c acqContact = muleExtIdToContactMap.get(validMuleExtId);
        acqContact.Id = provisioningRec.Acquisition_Contact__c;
        provisioningRec.Salesforce_Email_Address__c = muleExtIdToRequestMap.get(validMuleExtId).workEmail;
        acqContactList.add(acqContact);
        acqProvisioningList.add(provisioningRec);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to create a Response type and add to the responseBody list if the M&A Worker details are not matched in the PF system.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    unknownMuleExtIds         DESCRIPTION (Data type Set<String>, MuleExt Ids of Unknown M&A Workers)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void addUnknownWorkerErrorResponse(Set<String> unknownMuleExtIds) {
        for(String unknownMuleExtId : unknownMuleExtIds) {
            Request unknownWorkerRequestPayload = muleExtIdToRequestMap.get(unknownMuleExtId);
            String errorMessage = String.format(MA_RestConstants.ERROR_MESSAGE_UNKNOWN_MA_WORKER, new String[]{JSON.serialize(unknownWorkerRequestPayload)});
            addErrorResponse(unknownWorkerRequestPayload, null, errorMessage, MA_RestConstants.ErrorStatusCode.UNKNOWN_MA_WORKER);
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to bulk update valid Acquisition_Contacts__c records to sync worday worker Ids and log errors in a queueable job.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    response            DESCRIPTION (Data type RestResponse, RestContext.response instance to pass response data back to EI)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void bulkUpdateAcquiredContacts(RestResponse response) {
        Acquisition_Contacts_Trigger_Handler.IS_MA_WORKER_ID_SYNC_ACTIVE = true;
        Database.SaveResult[] conSRList = Database.update(acqContactList, false);
        Database.SaveResult[] provSRList = Database.update(acqProvisioningList, false);
        createServiceResponse(response, conSRList, provSRList);
        MA_WorkerIdSyncLoggerService.logErrors(JSON.serialize(responseBody), JSON.serialize(unknownCompanyErrors));
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to set statusCode & responseBody on RestContext.response instance based on the urList for updated acquired contacts.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    response            DESCRIPTION (Data type RestResponse, RestContext.response instance to pass response data back to EI)
    * @param    conSRList           DESCRIPTION (Data type Database.SaveResult[], List of SaveResult types for updated acquired contacts)
    * @param    provSRList          DESCRIPTION (Data type Database.SaveResult[], List of SaveResult types for updated acquired provisioning records)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void createServiceResponse(RestResponse response, Database.SaveResult[] conSRList, Database.SaveResult[] provSRList) {
        setupResponseBody(conSRList, provSRList);
        response.statusCode = MA_RestConstants.STATUS_CODE_200;
        response.responseBody = Blob.valueOf(JSON.serialize(responseBody, true));
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to create Response types based on urList, add it to list of responseBody and then sort the list before adding it to RestContext.response.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    conSRList           DESCRIPTION (Data type Database.SaveResult[], List of SaveResult types for the updated acquired contacts)
    * @param    provSRList          DESCRIPTION (Data type Database.SaveResult[], List of SaveResult types for updated acquired provisioning records)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void setupResponseBody(Database.SaveResult[] conSRList, Database.SaveResult[] provSRList) {
        for(Integer srIndex=0; srIndex < conSRList.size(); srIndex++) {
            responseBody.add(getResponseForRequest(conSRList[srIndex], provSRList[srIndex], acqContactList[srIndex], acqProvisioningList[srIndex]));
        }
        responseBody.sort();
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to create the Response type based on updated acquired contact & its SaveResult.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    conSR               DESCRIPTION (Data type Database.SaveResult, SaveResult type for the updated acquired contact)
    * @param    provSR              DESCRIPTION (Data type Database.SaveResult, SaveResult type for the updated acquisition provisioning record)
    * @param    acqCon              DESCRIPTION (Data type Acquisition_Contacts__c, The updated Acquisition_Contacts__c record)
    * @param    acqProv             DESCRIPTION (Data type Acquisition_Provisioning__c, The updated Acquisition_Provisioning__c record)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Response getResponseForRequest(Database.SaveResult conSR, Database.SaveResult provSR, Acquisition_Contacts__c acqCon, Acquisition_Provisioning__c acqProv) {
        Response response = new Response();
        response.referenceId = acqCon.MuleExtId__c;
        response.success = (conSR.success && provSR.success);
        response.errors = conSR.errors.isEmpty() ? provSR.errors : conSR.errors;
        response.responseIndex = muleExtIdToRequestMap.get(acqCon.MuleExtId__c).requestIndex;
        return response;
    }
}