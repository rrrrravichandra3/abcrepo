@isTest
public class PF_NHW_CustomCaseCommentTest {
	@isTest
	public static void validateCustomCaseComment() {
		PF_NHW_CustomCaseComment caseComment = new PF_NHW_CustomCaseComment('Test author','10/17/2017','Test comments');
		System.assertEquals(caseComment.author,'Test author');
		System.assertEquals(caseComment.publishDate,'10/17/2017');
		System.assertEquals(caseComment.comment,'Test comments');
	}
}