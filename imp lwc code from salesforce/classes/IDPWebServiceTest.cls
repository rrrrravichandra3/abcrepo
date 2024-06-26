@isTest
private class IDPWebServiceTest {
    private static final String REST_URI = '/services/apexrest/IDP/';
    private static final String EMPLOYEE_NO = '826610';
    /*
* No Request Sent to satify else condition
* Covering the If condition where no IDP Found
*/
    static testMethod void getIDPDataTestWithoutRequest(){
        IDPWebService.getIDPData();
    }
    
    /*
* Queried user and updated the user employee with different employee number to satisfy else condition 
* HTTP GET callout with request URI
*/
    static testMethod void getIDPDataTest(){
        
        User u = [Select id,EmployeeNumber,Manager__c,Manager__r.EmployeeNumber  from user WHERE Id=:UserInfo.getUserId()];
        u.EmployeeNumber = EMPLOYEE_NO;
        update u;
        
        //ARRANGE - setup request like the external system would....
        RestRequest req = new RestRequest(); 
        req.requestURI = REST_URI + EMPLOYEE_NO;
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueof('{}');
        RestContext.request = req;
        
        //ACT - make the request from inside the test execution context
        Test.startTest();
        IDPWebService.IDPWrapper idpResponseWrapper = IDPWebService.getIDPData();
        System.assert(idpResponseWrapper!=Null);//Checking the wrapper response, if it has some value
        Test.stopTest();
    }
    
    
    /*
* Queried user and updated the user employee with same employee number to satisfy if positive condition 
* HTTP GET callout with request URI
*/
    static testMethod void getIDPDataTest2(){
        
        User u1 = [Select id from user LIMIT 1];
        
        User u = [Select id,EmployeeNumber,Manager__c,Manager__r.EmployeeNumber  from user WHERE Id=:UserInfo.getUserId()];
        u.EmployeeNumber = EMPLOYEE_NO;
        //u.Manager__c = u1.id;//comment to cover the else error condition
        update u;
        
        //ARRANGE - setup request like the external system would....
        RestRequest req = new RestRequest(); 
        req.requestURI = REST_URI + EMPLOYEE_NO;
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueof('{}');
        RestContext.request = req;
        
        //ACT - make the request from inside the test execution context, rather than from the external system
        Test.startTest();
        IDPWebService.IDPWrapper idpResponseWrapper = IDPWebService.getIDPData();
        System.Assert(idpResponseWrapper!=Null);//Checking the wrapper response, if it has some value
        Test.stopTest();
    }
    
    
    /*
* Queried user and updated the user manager with some user id to cover conditions where Manager!=NULL 
* HTTP GET callout with request URI
*/
    static testMethod void test_IDPWebServicePositiveScenario(){
        
        User u1 = [Select id from user LIMIT 1];
        
        User u = [Select id,EmployeeNumber,Manager__c,Manager__r.EmployeeNumber  from user WHERE Id=:UserInfo.getUserId()];
        u.EmployeeNumber = EMPLOYEE_NO;
        u.Manager__c = u1.id;
        update u;
        
        
        //ARRANGE - setup request like the external system would....
        RestRequest req = new RestRequest(); 
        req.requestURI = REST_URI + EMPLOYEE_NO;
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueof('{}');
        RestContext.request = req;
        
        //ACT - make the request from inside the test execution context, rather than from the external system
        Test.startTest();
        IDPWebService.IDPWrapper idpResponseWrapper = IDPWebService.getIDPData();
        System.Assert(idpResponseWrapper!=Null);//Checking the wrapper response, if it has some value
        Test.stopTest();
    }
    
    /*
* Inserted data for IDP, Objective & Actions
* HTTP GET callout with request URI
* Creating data helps in covering all SOQL queries and checking the list size > 0
*/
    static testMethod void test_IDPWebServicePositiveScenarioWithAction(){
        IDP__c newIDP = new IDP__c();
        newIDP.Key_Strengths__c = 'Test Key Strengths';
        newIDP.Career_Interest__c = 'Test Place Holder';
        newIDP.Employee_Number__c = EMPLOYEE_NO;
        newIDP.QuipId__c = '877778863677';
        insert newIDP;
        
        IDP_Objective__c objective = new IDP_Objective__c();
        objective.IDP__c = newIDP.id;
        objective.IDP_Objective_Name__c = 'Objective';
        objective.QuipId__c = '877778863677';
        insert objective;
        
        IDP_Action__c actions = new IDP_Action__c();
        actions.Status__c='Complete';
        actions.Action__c='action';
        actions.Completed_Date__c=system.today();
        actions.IDP_Objective__c = objective.id;
        actions.QuipId__c = '877778863677';
        insert actions;
        
        User u1 = [Select id from user LIMIT 1];
        
        User u = [Select id,EmployeeNumber,Manager__c,Manager__r.EmployeeNumber  from user WHERE Id=:UserInfo.getUserId()];
        u.EmployeeNumber = EMPLOYEE_NO;
        u.Manager__c = u1.id;
        update u;
        
        
        //ARRANGE - setup request like the external system would....
        RestRequest req = new RestRequest(); 
        req.requestURI = REST_URI + EMPLOYEE_NO;
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueof('{}');
        RestContext.request = req;
        
        //ACT - make the request from inside the test execution context, rather than from the external system
        Test.startTest();
        IDPWebService.IDPWrapper idpResponseWrapper = IDPWebService.getIDPData();
        System.Assert(idpResponseWrapper!=Null);//Checking the wrapper response, if it has some value
        Test.stopTest();
    }
    
    
    /*
* Inserted data for IDP, Objective & Actions
* HTTP PATCH callout
* Creating data helps in covering all SOQL queries and checking the list size > 0
* Covering class where ActionId!=NULL & all Postive if scenario
*/
    static testMethod void test_IDPWebServicePositivePatchHandling(){
        
        IDP__c newIDP = new IDP__c();
        newIDP.Key_Strengths__c = 'Test Key Strengths';
        newIDP.Career_Interest__c = 'Test Place Holder';
        newIDP.Employee_Number__c = EMPLOYEE_NO;
        newIDP.QuipId__c = '877778863677';
        insert newIDP;
        
        IDP_Objective__c objective = new IDP_Objective__c();
        objective.IDP__c = newIDP.id;
        objective.IDP_Objective_Name__c = 'Objective';
        objective.QuipId__c = '877778863677';
        insert objective;
        
        IDP_Action__c actions = new IDP_Action__c();
        actions.Status__c='Complete';
        actions.Action__c='action';
        actions.Completed_Date__c=system.today();
        actions.IDP_Objective__c = objective.id;
        actions.QuipId__c = '877778863677';
        insert actions;
        
        String JSONMsg = '{"recordId": null,"objectiveName": "Objective Update from patch","idpRecordId": "a7p9A00000000OMQAY","actions": [{"Status": "In Progress","recordId": \"'+(id)actions.id+'\", "completionDate": "2021-01-12","Action": "A1-1-13Jan update"}]}';
        RestRequest req = new RestRequest();
        req.requestURI = REST_URI + EMPLOYEE_NO;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueof(JSONMsg);
        RestContext.request = req;
        
        Test.startTest();
        IDPWebService.IDPObjectiveWrapper wrap = IDPWebService.updateObjectives();
        System.Assert(wrap!=Null);//Checking the wrapper response, if it has some value
        Test.stopTest();
        
    }
    
    /*
* Inserted data for IDP, Objective & Actions
* HTTP PATCH callout
* Creating data helps in covering all SOQL queries and checking the list size > 0
* Covering class where ActionId=NULL & all Negative if scenario
*/
    static testMethod void test_IDPWebServiceNegativePatchHandling(){
        
        IDP__c newIDP = new IDP__c();
        newIDP.Key_Strengths__c = 'Test Key Strengths';
        newIDP.Career_Interest__c = 'Test Place Holder';
        newIDP.Employee_Number__c = EMPLOYEE_NO;
        newIDP.QuipId__c = '877778863677';
        insert newIDP;
        
        IDP_Objective__c objective = new IDP_Objective__c();
        objective.IDP__c = newIDP.id;
        objective.IDP_Objective_Name__c = 'Objective';
        objective.QuipId__c = '877778863677';
        insert objective;
        
        IDP_Action__c actions = new IDP_Action__c();
        actions.Status__c='Complete';
        actions.Action__c='action';
        actions.Completed_Date__c=system.today();
        actions.IDP_Objective__c = objective.id;
        actions.QuipId__c = '877778863677';
        insert actions;
        
        String JSONMsg = '{"recordId": null,"objectiveName": "Objective Update from patch","idpRecordId": "a7p9A00000000OMQAY","actions": [{"Status": "In Progress","recordId": null, "completionDate": "2021-01-12","Action": "A1-1-13Jan update"}]}';
        RestRequest req = new RestRequest();
        req.requestURI = REST_URI + EMPLOYEE_NO;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueof(JSONMsg);
        RestContext.request = req;
        
        Test.startTest();
        IDPWebService.IDPObjectiveWrapper wrap = IDPWebService.updateObjectives();
        System.Assert(wrap!=Null);//Checking the wrapper response, if it has some value
        Test.stopTest();
        
    }
    
    /*
* Inserted data for IDP, Objective & Actions
* HTTP PATCH callout
* Creating data helps in covering all SOQL queries and checking the list size > 0
* Covering class where ObjectiveId!=NULL & all Negative if scenario
*/
    static testMethod void test_IDPWebServiceNegativePatchHandlingWithObjectiveId(){
        
        IDP__c newIDP = new IDP__c();
        newIDP.Key_Strengths__c = 'Test Key Strengths';
        newIDP.Career_Interest__c = 'Test Place Holder';
        newIDP.Employee_Number__c = EMPLOYEE_NO;
        newIDP.QuipId__c = '877778863677';
        insert newIDP;
        
        IDP_Objective__c objective = new IDP_Objective__c();
        objective.IDP__c = newIDP.id;
        objective.IDP_Objective_Name__c = 'Objective';
        objective.QuipId__c = '877778863677';
        insert objective;
        
        IDP_Action__c actions = new IDP_Action__c();
        actions.Status__c='Complete';
        actions.Action__c='action';
        actions.Completed_Date__c=system.today();
        actions.IDP_Objective__c = objective.id;
        actions.QuipId__c = '877778863677';
        insert actions;
        String JSONMsg = '{"recordId": \"'+(id)objective.id+'\","objectiveName": "Objective Update from patch","idpRecordId": "a7p9A00000000OMQAY","actions": [{"Status": "In Progress","recordId": null, "completionDate": "2021-01-12","Action": "A1-1-13Jan update"}]}';
        RestRequest req = new RestRequest();
        req.requestURI = REST_URI + EMPLOYEE_NO;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueof(JSONMsg);
        RestContext.request = req;
        
        Test.startTest();
        IDPWebService.IDPObjectiveWrapper wrap = IDPWebService.updateObjectives();
        System.Assert(wrap!=Null);//Checking the wrapper response, if it has some value
        Test.stopTest();
    }
}