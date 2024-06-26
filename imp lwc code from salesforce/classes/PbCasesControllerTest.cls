/*
*********************************************************
Apex Class Name    : PbCasesControllerTest
Created Date       : October 24, 2023
@description       : This is test class for the class PbCasesController
					for the Preboarding site
@author            : Mia de Haan
*********************************************************
*/
@isTest
public class PbCasesControllerTest {
    // Test data for Cases
    private static List<Case> createTestCases(Integer numCases) {
        List<Case> testCases = new List<Case>();
        for (Integer i = 0; i < numCases; i++) {
            Case testCase = new Case(
                Subject = 'Test Case ' + i,
                Status = 'Open',
                Description = 'Test Description ' + i
            );
            testCases.add(testCase);
        }
        insert testCases;
        
        // Create test CaseComments related to the first test Case
        List<CaseComment> testComments = new List<CaseComment>();
        for (Integer i = 0; i < 3; i++) {
            CaseComment comment = new CaseComment(
                ParentId = testCases[0].Id,
                CommentBody = 'Test Comment ' + i
            );
            testComments.add(comment);
        }
        insert testComments;
        
        return testCases;
    }
    
	@isTest
    static void testGetCasesPositive() {
        // Create test cases
        createTestCases(5);

        // Call the method to be tested
        Test.startTest();
        	List<PbCaseWrapper> result = PbCasesController.getCases();
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(5, result.size(), 'Expected 5 cases in the result');
        
    }
    
    @isTest
    static void testGetCaseComments(){
        // Create test cases
        List<Case> testCases = createTestCases(5);
        
        // Call the method to be tested
        Test.startTest();
        	List<PbCaseCommentWrapper> result = PbCasesController.getCaseComments(testCases[0].Id);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(3, result.size(), 'Expected 3 comments in the result');

    }
    
    @isTest
    static void testCreateCaseComment(){
        // Create test cases
        List<Case> testCases = createTestCases(3);
        String commentBody = 'New comment here';
        
        // Call the method to be tested
        Test.startTest();
        	PbCasesController.createCaseComment(testCases[1].Id, commentBody);
        Test.stopTest();

        // Query for the created CaseComment
        List<CaseComment> createdComments = [SELECT Id, ParentId, CommentBody FROM CaseComment WHERE ParentId = :testCases[1].Id];

        // Assertions
        System.assertNotEquals(null, createdComments, 'No comments were created');
        System.assertEquals(1, createdComments.size(), 'Expected 1 comment to be created');
        System.assertEquals('New comment here', createdComments[0].CommentBody, 'Comment body should match');

    }
    
}