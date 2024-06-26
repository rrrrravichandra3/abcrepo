@isTest
public class PF_NHW_PastSubmissionDetailAuraSrvcsTest {
	@isTest
	public static void validateAddNewComment() {
		Case c = new Case();
		c.Origin = 'Phone';
		insert c;
		PF_NHW_CustomCaseComment expectedCaseComment = PF_NHW_PastSubmissionDetailAuraServices.addNewComment('Test Comments 123', c.Id);
		PF_NHW_CustomCaseComment actualCaseComment = new PF_NHW_CustomCaseComment(UserInfo.getName(),DateTime.now().format('MM/dd/yyyy'),'Test Comments 123');

		System.assertEquals(expectedCaseComment.comment, actualCaseComment.comment);
		System.assertEquals(expectedCaseComment.author, actualCaseComment.author);
		System.assertEquals(expectedCaseComment.publishDate, actualCaseComment.publishDate);
	}
    
    @isTest
	public static void validateAddNewCommentExeption() {
        PF_NHW_PastSubmissionDetailAuraServices.addNewComment('', '');
	}
}