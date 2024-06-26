@isTest
private class IDP_WSControllerTest {
    
    //Test MEthod to cover the GET callout using JWT Token
    @isTest
    static void testGETCalloutSuccess() {      
        // arrange
        String employeeNumber = '826610';

        // act
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new IDP_WSControllerMock());
            IDP_WSControllerDTO deserializedResponse = IDP_WSController.getIDPList(employeeNumber);
        Test.stopTest();

        // assert
        System.assertequals('test', deserializedResponse.recordId, 'Unexpected RecordId'); // assert if mock record Id is retrieved 
        System.assertequals(true, String.isBlank(deserializedResponse.errorMessage), 'Unexpected RecordId'); // assert if no error has occured
    }

    @isTest
    static void testGETCalloutError() {  
        // arrange
        String employeeNumber = 'error';    

        // act
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new IDP_WSControllerMock());
            IDP_WSControllerDTO deserializedResponse = IDP_WSController.getIDPList(employeeNumber);
        Test.stopTest();

        // assert
        System.assertequals(IDP_WSController.GENERAL_ERROR_MESSAGE, deserializedResponse.errorMessage, 'Unexpected Error message'); // assert error message for negative scenario
    }
    
    //Test method to cover UpdateText with True FieldValues
    @isTest
    static void updateTextTestWithTrue() {      
        
        Test.startTest();
            Test.setMock(HttpCalloutMOck.class, new IDP_WSControllerMock());
            Boolean isTrue = IDP_WSController.updateText('Career_Interest__c','True', Null , 'IDP__c');
        Test.stopTest();
        
        // assert
        System.assertequals(true, isTrue, 'Unexpected value returned');
    } 
    
    //Test method to cover UpdateText with text FieldValues
    @isTest
    static void updateTextTestWithText() {      
        Test.startTest();
            Test.setMock(HttpCalloutMOck.class, new IDP_WSControllerMock());
            Boolean isTrue = IDP_WSController.updateText('Career_Interest__c','Test Career Interest', 'a7p9A0000008OTpQAM', 'IDP__c');
        Test.stopTest();

        // assert
        System.assertequals(true, isTrue, 'Unexpected value returned');
    }
       
    //Test method to cover patchObjective callout for new Objective scenario
    @isTest
    static void createObjectivesTest() {
        // arrange
        String requestBody = '{"idpId":"a7p9A0000008OTpQAM","objectiveId":"obj1","objectiveName":"test","actions":[],"newActions":[{"Action":"test","Status":"Not Started","recordId":1,"completionDate":"2023-02-28"}]}';
        
        //act
        Test.startTest();
            Test.setMock(HttpCalloutMOck.class, new IDP_WSControllerMock());
            IDP_ObjectivePatchWSDTO patchRequestBody = IDP_WSController.patchObjectives(requestBody);
        Test.stopTest();

        // assert
        System.assert(patchRequestBody != null, 'Patch response should not be empty');//Checking the wrapper response, if it has some value
        System.assertequals('test', patchRequestBody.idpRecordId, 'Unexpected recordId');
        System.assertequals(true, String.isBlank(patchRequestBody.errorMessage), 'Unexpected Error returned'); // assert if no error has occured
    } 

    //Test method to cover patchObjective callout for existing Objective scenario
    @isTest
    static void patchObjectivesTest() {
        // arrange
        String requestBody = '{"idpId":"a7p9A0000008OTpQAM","objectiveId":"a8p9A0000008OTpQAN","objectiveName":"test","actions":[],"newActions":[{"Action":"test","Status":"Not Started","recordId":1,"completionDate":"2023-02-28"}]}';
        
        //act
        Test.startTest();
            Test.setMock(HttpCalloutMOck.class, new IDP_WSControllerMock());
            IDP_ObjectivePatchWSDTO patchRequestBody = IDP_WSController.patchObjectives(requestBody);
        Test.stopTest();

        // assert
        System.assert(patchRequestBody != null, 'Patch response should not be empty');//Checking the wrapper response, if it has some value
        System.assertequals('test', patchRequestBody.idpRecordId, 'Unexpected Error Message');
    } 
}