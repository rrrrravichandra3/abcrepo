@isTest
public class IFBTest_SIFT_Repository_Controller {
	/*@isTest
	public static void testGetInterviewQuestions() {
		IFB_InterviewQuestionCategoryMap__c questionCatMap = new IFB_InterviewQuestionCategoryMap__c();
		questionCatMap.Name = 'Test Cat Map';
		questionCatMap.Question_Category__c = 'Test Category';
		questionCatMap.Position__c = 'Test Position';
		questionCatMap.Interview_Record_Type_Name__c = 'Test Intw Type';
		insert questionCatMap;
		List<IFB_Interview_Question__c> questions = new List<IFB_Interview_Question__c>();
		for(Integer i=0; i<10;i++){
			IFB_Interview_Question__c intwQuestion = new IFB_Interview_Question__c();
			intwQuestion.Competency__c = 'Test Competency';
			intwQuestion.Question__c = 'Test Question';
			intwQuestion.Question_Category_Text__c = 'Test Category';
			intwQuestion.Active__c = true;
			questions.add(intwQuestion);
		}
		insert questions;
		IFB_SIFT_Repository_Controller.interviewQuestion expected = new IFB_SIFT_Repository_Controller.interviewQuestion('Test Intw Type', 'Test Competency', 'Test Comp Desc', new List<String>{'Test qstn1','Test qstn2'}, 'Test Question');
		Test.startTest();
		IFB_SIFT_Repository_Controller.interviewQuestionval actual = IFB_SIFT_Repository_Controller.getInterviewQuestions('Test Group', 'Test Position', 'Test Intw Type');
		System.assertEquals(expected.interviewType, actual.interviewQuestions[0].interviewType);
		actual = IFB_SIFT_Repository_Controller.getInterviewQuestions('Test Group', 'Test Position', null);
		System.assertEquals(expected.interviewType, actual.interviewQuestions[0].interviewType);
		Test.stopTest();
	}

	@isTest
	public static void testGetCompetencyDescriptions() {
		SIFT_Group__c siftGroup = new SIFT_Group__c(Name='Test SIFT Group');
		insert siftGroup;
		SIFT_Position__c siftPosition = new SIFT_Position__c(Name='Test SIFT Position');
		siftPosition.SIFT_Group__c = siftGroup.Id;
		insert siftPosition;
		SIFT_Interview_Type__c siftInterviewType = new SIFT_Interview_Type__c(Name='Test Interview Type');
		siftInterviewType.SIFT_Group__c = siftGroup.Id;
		insert siftInterviewType;
		IFB_Competency_Description__c compDesc = new IFB_Competency_Description__c();
		compDesc.Name = 'Test Comp Name';
		compDesc.Competency_Description__c = 'Test Eng Description';
		compDesc.SIFT_Group_Lookup__c = siftGroup.Id;
		compDesc.SIFT_Interview_Type_Lookup__c = siftInterviewType.Id;
		compDesc.SIFT_Position_Lookup__c = siftPosition.Id;
		compDesc.Additional_Questions__c = 'Test Addtnl Questions';
		compDesc.Japan_Additional_Question__c = 'Test Addtnl Jap Questions';
		compDesc.Japan_Competency_Description__c = 'Test Jap Description';
		compDesc.Japan_Name__c = 'Test Jap Comp Name';
		insert compDesc;
		IFB_SIFT_Repository_Controller.Competency expectedComp = new IFB_SIFT_Repository_Controller.Competency('Test Comp Name','Test Eng Description','Test Jap Comp Name','Test Jap Description');
		Test.startTest();
		Map<String,IFB_SIFT_Repository_Controller.Competency> actualCompMap = IFB_SIFT_Repository_Controller.getCompetencyDescriptions(new List<String>{'Test Comp Name'},'Test SIFT Group','Test Interview Type', 'Test SIFT Position');
		IFB_SIFT_Repository_Controller.Competency actualComp = actualCompMap.get('Test Comp Name');
		System.assertEquals('Test Comp Name',actualComp.name);
		actualCompMap = IFB_SIFT_Repository_Controller.getCompetencyDescriptions(new List<String>{'Test Comp Name'},'Test SIFT Group',null, 'Test SIFT Position');
		actualComp = actualCompMap.get('Test Comp Name');
		System.assertEquals('Test Comp Name',actualComp.name);
		Test.stopTest();
	}*/
}