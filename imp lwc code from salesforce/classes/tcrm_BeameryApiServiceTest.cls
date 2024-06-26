/**
 * @description       : 
 * @author            : Kyle Moseley (kmoseley)
 * @group             : 
 * @last modified on  : 01-22-2024
 * @last modified by  : Urvish Shah (ushah)
**/
@IsTest
public with sharing class tcrm_BeameryApiServiceTest {
    
    private static final String httpRequestHeaderParamContentType = 'Content-Type';
    private static final String httpRequestHeaderParamContentTypeJson = 'application/json;charset=UTF-8';
    private static final String assertFailureMessage = 'Unexpected exception message';

    private class Mock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest
    public static void testDoAuth() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String authToken = tcrm_BeameryAPIService.doAuth();
        System.assertNotEquals(null, authToken, 'Auth token should not be null');
    }

    @IsTest
    public static void testDoAuth_Exception() {
        Test.setMock(HttpCalloutMock.class, new AuthFailureMockHttpResponseGenerator());
        Test.startTest();
        try{
            String authToken = tcrm_BeameryAPIService.doAuth();
        } catch (CalloutException e) {
            System.assertEquals('Unauthorized endpoint', e.getMessage(), assertFailureMessage);
        }
        Test.stopTest();
    }

    @IsTest
    public static void getContactIdByEmail() {
        String emailAddress = 'test+12@test.com';
        Test.setMock(HttpCalloutMock.class, new ContactListMockHttpResponseGenerator());

        tcrm_BeameryAPIService service = new tcrm_BeameryAPIService();
        String contactId = service.getContactIdByEmail(emailAddress);

        System.assertNotEquals(null, contactId, 'Contact Id should not be null');
    }

    @IsTest
    public static void getContactIdByEmail_Exception() {
        Test.setMock(HttpCalloutMock.class, new ContactIdByEmailExceptionMockHttpResponseGenerator());

        Test.startTest();
        try{
            tcrm_BeameryAPIService service = new tcrm_BeameryAPIService();
            String contactId = service.getContactIdByEmail('test+12@test.com');
        } catch (CalloutException e) {
            System.assertEquals('Email does not exist', e.getMessage(), assertFailureMessage);
        }
        Test.stopTest();
    }

    @IsTest
    public static void getContactIdByWorkdayCandidateId() {
        String candId = 'CA1234567';
        Test.setMock(HttpCalloutMock.class, new ContactSingleMockHttpResponseGenerator());

        tcrm_BeameryAPIService service = new tcrm_BeameryAPIService();
        String contactId = service.getContactIdByWorkdayCandidateId(candId);

        System.assertNotEquals(null, contactId, 'Contact Id should not be null');

        tcrm_BeameryContacts.Contacts testContact = new tcrm_BeameryContacts.Contacts();
        testContact.id = '23201b04-e87c-4ea9-bced-cd6f3f81339c';
        service.updateContact(testContact);
    }

    @IsTest
    public static void getContactIdByWorkdayCandidateId_Exception() {
        Test.setMock(HttpCalloutMock.class, new ContactIdByWDIdExceptionMockHttpResponseGenerator());

        Test.startTest();
        try{
            tcrm_BeameryAPIService service = new tcrm_BeameryAPIService();
            String contactId = service.getContactIdByWorkdayCandidateId('CA1234569');
        } catch (CalloutException e) {
            System.assertEquals('Workday Candidate ID does not exist', e.getMessage(), assertFailureMessage);
        }
        Test.stopTest();
    }

    @IsTest
    public static void testUpdateContact_Exception() {
        Test.setMock(HttpCalloutMock.class, new UpdateContactMockHttpResponseGenerator());

        Test.startTest();
        try{
            tcrm_BeameryContacts.Contacts testContact = new tcrm_BeameryContacts.Contacts();
            testContact.id = '23201b04-e87c-4ea9-bced-cd6f3f81339c';

            tcrm_BeameryAPIService service = new tcrm_BeameryAPIService();
            service.updateContact(testContact);
        } catch (CalloutException e) {
            System.assertEquals('Contact Update failed Id does not exist', e.getMessage(), assertFailureMessage);
        }
        Test.stopTest();
    }

    @IsTest
    public static void testGetBeameryLeads() {
        Test.setMock(HttpCalloutMock.class, new ContactListMockHttpResponseGenerator());

        tcrm_BeameryAPIService service = new tcrm_BeameryAPIService();
        TCRM_BatchUtil.BeameryGetContactsResponseWrapper result = service.getBeameryLeads('2015-11-17T18:45:01Z',0);

        System.assert(result.beameryContacts.size() > 0, 'At least one contact should be returned');
    }

    @IsTest
    public static void testGetBeameryLeadUpdates() {
        Test.setMock(HttpCalloutMock.class, new ContactListMockHttpResponseGenerator());

        tcrm_BeameryAPIService service = new tcrm_BeameryAPIService();
        TCRM_BatchUtil.BeameryGetContactsResponseWrapper result = service.getBeameryLeadUpdates('2015-11-17T18:45:01Z',0);

        System.assert(result.beameryContacts.size() > 0, 'At least one contact should be returned');
    }

    @IsTest
    public static void testCreateContact() {
        Test.setMock(HttpCalloutMock.class, new ContactSingleMockHttpResponseGenerator());

        tcrm_BeameryContacts.Contacts testContact = new tcrm_BeameryContacts.Contacts();
        testContact.firstName = 'Test';
        testContact.lastName = 'CRM';

        HttpResponse response = tcrm_BeameryAPIService.createContact(testContact);

        System.assert(response.getStatusCode() == 200, 'Contact Creation Test Failed');
    }
    

    

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            String responseBody = '{"access_token":"mockToken"}';

            HttpResponse response = new HttpResponse();
            response.setHeader(httpRequestHeaderParamContentType, httpRequestHeaderParamContentTypeJson);
            response.setBody(responseBody);
            response.setStatusCode(200);

            return response;
        }
    }

    public class AuthFailureMockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Unauthorized endpoint');
            throw e;
        }
    }

    public class ContactIdByEmailExceptionMockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Email does not exist');
            throw e;
        }
    }

    public class ContactIdByWDIdExceptionMockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Workday Candidate ID does not exist');
            throw e;
        }
    }

    public class UpdateContactMockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Contact Update failed Id does not exist');
            throw e;
        }
    }
    
    public class ContactListMockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            String responseBody = '{"contacts":[{"id" : "23201b04-e87c-4ea9-bced-cd6f3f81339c"}]}';
            HttpResponse response = new HttpResponse();
            response.setHeader(httpRequestHeaderParamContentType, httpRequestHeaderParamContentTypeJson);
            response.setBody(responseBody);
            response.setStatusCode(200);
            return response;
        }
    }

    public class ContactSingleMockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            String responseBody = '{"id" : "23201b04-e87c-4ea9-bced-cd6f3f81339c"}';
            HttpResponse response = new HttpResponse();
            response.setHeader(httpRequestHeaderParamContentType, httpRequestHeaderParamContentTypeJson);
            response.setBody(responseBody);
            response.setStatusCode(200);
            return response;
        }
    }
}