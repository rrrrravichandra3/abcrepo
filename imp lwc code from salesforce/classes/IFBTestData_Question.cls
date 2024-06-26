@isTest
public class IFBTestData_Question {
	public enum Option { ACTIVE, INACTIVE }

	public static Integer questionIndex = 1;

	private static final String EXCEPTION_INFORMATION_MISSING = 'Question Category, Domain and Group were not provided. Can not create Interview Question record for testing.';
	private static final String EXCEPTION_QUESTION_CATEGORY_MISSING = 'Question Category was not provided. Can not create Interview Question record for testing.';
	private static final String EXCEPTION_DOMAIN_MISSING = 'Domain was not provided. Can not create Interview Question record for testing.';
	private static final String EXCEPTION_GROUP_IS_MISSING = 'Group was not provided. Can not create Interview Question record for testing.';
	private static final String EXCEPTION_INVALID_OPTION = 'Invalid Option. Do not know if the question record should be Active or not. Can not create Interview Question record for testing.';

	public static IFB_Interview_Question__c getQuestion(IFB_Interview_Question__c question, Option opt) {
		// Validate tha the minimum information is provided ("Questin Category" and "Competency")
		if (question == null) {
			throw new IFB_TestException(EXCEPTION_INFORMATION_MISSING);
		}
		if (question.Question_Category__c == null) {
			throw new IFB_TestException(EXCEPTION_QUESTION_CATEGORY_MISSING + '[question.Question_Category__c:' + question.Question_Category__c + ']');
		}
		if (question.Domain__c == null) {
			throw new IFB_TestException(EXCEPTION_DOMAIN_MISSING + '[question.Domain__c:' + question.Domain__c + ']');
		}
		if (question.Group__c == null) {
			throw new IFB_TestException(EXCEPTION_GROUP_IS_MISSING + '[question.Group__c:' + question.Group__c + ']');
		}

		if (opt == Option.ACTIVE) {
			question.Active__c = true;
		} else if (opt == Option.INACTIVE) {
			question.Active__c = false;
		} else {
			throw new IFB_TestException(EXCEPTION_INVALID_OPTION + '[opt:' + opt.name() + ']');
		}

		// If a sort order is not especified, we provide a generic, global, consecutive integer. (transaction context)
		question.Sort_Order__c = (question.Sort_Order__c  == null) ? questionIndex : question.Sort_Order__c;
		questionIndex++;

		// For testing purposes, actual question wording is just a concatenation of the "Question Category" and the "Domain"
		if (question.Question__c == null) {
			question.Question__c = 'Question ' + '[' + question.Question_Category__c +  ']'
										  	   + '[' + question.Domain__c +  ']';	
		}
		//Ratings definition.
		question.Rating1_Definition__c = (question.Rating1_Definition__c == null) ? 'Does not demonstrate' : question.Rating1_Definition__c;
		question.Rating2_Definition__c = (question.Rating2_Definition__c == null) ? 'Developing' : question.Rating2_Definition__c;	
		question.Rating3_Definition__c = (question.Rating3_Definition__c == null) ? 'Proficient' : question.Rating3_Definition__c;	
		question.Rating4_Definition__c = (question.Rating4_Definition__c == null) ? 'Advanced' : question.Rating4_Definition__c;	

		return question;
	}
}