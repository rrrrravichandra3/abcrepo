/**
 * @description       : 
 * @author            : Urvish Shah (ushah)
 * @group             : 
 * @last modified on  : 01-20-2024
 * @last modified by  : Urvish Shah (ushah)
**/
@IsTest
private class tcrm_BatchSyncConsentTest {


    @testSetup
    static void setup() {
        List<Contact> contacts = new List<Contact>();
        // find the account just inserted. add contact for each
        Contact con = new Contact();
        con.FirstName = 'Test One';
        con.LastName = 'Candidate';
        con.Email = 'testconsentcrm@not.salesforce.com';
        con.AccountId = ESDJC_TestUtil.createAccount().Id;
        con.Marketing_Opt_In__c = 'Opt In';
        con.Recruiting_Opt_In__c = 'Opt In';
        contacts.add(con);
        insert contacts;

        tcrm_ConsentBatchSettings__c consentsetting = new tcrm_ConsentBatchSettings__c();
        consentsetting.LastSuccessfulRun__c = Datetime.now();
        consentsetting.BatchSize__c = 200;
        consentsetting.endpoint__c = '';
        insert consentsetting;
    }

    private static final String FAKE_RESPONSE_JSON = '';

    private class Mock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest static void testUpdateConsent() {

        Test.setMock(HttpCalloutMock.class, new Mock());
        Test.startTest();
        tcrm_BeameryAPIService service = new tcrm_BeameryAPIService();
        tcrm_BatchSyncConsent tcrmBatchSync = new tcrm_BatchSyncConsent();
        Id batchId = Database.executeBatch(tcrmBatchSync);
        Test.stopTest();
        
    }    

    @IsTest
    public static void testMockHttpResponseGenerator() {
        // Create the instance of the MockHttpResponseGenerator class
        tcrm_BeameryApiServiceTest.MockHttpResponseGenerator generator = new tcrm_BeameryApiServiceTest.MockHttpResponseGenerator();
        
        // Create a mock HttpRequest for testing
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://example.com');
        request.setMethod('GET');
        
        // Call the respond method and assert the HTTP response
        HttpResponse response = generator.respond(request);
        System.assertEquals(200, response.getStatusCode(), 'Unexpected status code');
        System.assertEquals('application/json;charset=UTF-8', response.getHeader('Content-Type'), 'Unexpected Content-Type header');
        System.assertEquals('{"access_token":"mockToken"}', response.getBody(), 'Unexpected response body');
    }

}