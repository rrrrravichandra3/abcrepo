@isTest
public class MA_LogCaseControllerTest {
    
    static testMethod void testSubmitCase() {
        // Create a test case
        Case testCase = new Case(
            Subject = 'Test Subject',
            Description = 'Test Description'
        );
        
        // Create a test Knowledge Article
        Knowledge__kav testArticle = new Knowledge__kav(
            Title = 'Test Article',
            UrlName = 'test'
           // KnowledgeArticleId = 'KA-000001' // Provide a unique Knowledge Article Id
        );
        insert testArticle;
        
        // Call the submitCase method
        Test.startTest();
        MA_LogCaseController.submitCase(testCase, testArticle.Id, 'VGhpcyBpcyBhIHRlc3QgZmlsZQ==', 'TestFile.txt', 'text/plain');
        Test.stopTest();
        
        // Add assertions here if needed
    }
}