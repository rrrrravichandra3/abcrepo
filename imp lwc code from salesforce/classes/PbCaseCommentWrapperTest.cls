@isTest
public class PbCaseCommentWrapperTest {
@isTest
    static void testPbCaseCommentWrapper() {
        // Create a test case
        Case testCase = new Case(
            Subject = 'Test Subject',
            Status = 'Open',
            Description = 'Test Description'
        );
        insert testCase;
         
        // Create test CaseComment
        CaseComment testCaseComment = new CaseComment(
            ParentId = testCase.Id,
            CommentBody = 'Test Message for comment'
        );
        insert testCaseComment;

        // Create PbCaseCommentWrapper instance
        PbCaseCommentWrapper wrapper = new PbCaseCommentWrapper();
        wrapper.Id = testCaseComment.Id;
        wrapper.ParentId = testCaseComment.ParentId;
        wrapper.CommentBody = testCaseComment.CommentBody;
        

        // Perform assertions
        System.assertEquals(testCaseComment.Id, wrapper.Id, 'Check Id');
        System.assertEquals(testCaseComment.ParentId, wrapper.ParentId, 'Check ParentId');
        System.assertEquals(testCaseComment.CommentBody, wrapper.CommentBody, 'Check CommentBody');
    }
}