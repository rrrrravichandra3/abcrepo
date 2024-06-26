@isTest
private class IFB_InterviewQuestionUtilitiesTest {

    private static String dummyExistingPosition = 'Dishwasher';
    private static String dummyMissingPosition = 'Punter';
    private static String dummyExistingRecordTypeName = 'Tribunal Interview';
    private static String dummyMissingRecordTypeName = 'Nonexistent Interview';
    private static String technicalRecordTypeName = 'Technical Interview';
    private static String defaultCategory = 'Category A';
    private static String positionSpecificCategory = 'Category B';  
    private static String technicalCategory = 'Technical Question';  
    
    @testSetup static void setup() {
        List<String> interviewRecordTypeNames = new List<String>{dummyExistingRecordTypeName,dummyExistingRecordTypeName, technicalRecordTypeName};
        List<String> positions = new List<String>{IFB_InterviewQuestionUtilities.DEFAULT_POSITION, dummyExistingPosition, dummyExistingPosition};
        List<String> categories = new List<String>{defaultCategory, positionSpecificCategory, technicalCategory};
        IFB_RecruitingTestDataFactory.createInterviewQuestionCategory(interviewRecordTypeNames, positions, categories);
        IFB_RecruitingTestDataFactory.createInterviewQuestions(technicalCategory, 5);
    }
    
    // if a question category is mapped for a position/recordType, we expect to get that mapping
    static testMethod void validatePositionSpecificQuestionCategory() {
        System.assertEquals(
            IFB_InterviewQuestionUtilities.getQuestionCategory(dummyExistingPosition, 
                                                           dummyExistingRecordTypeName),
            positionSpecificCategory);
    }
    
    // if position/rt not mapped, but default/rt mapped we get a default mapping
    static testMethod void validateDefaultPositionQuestionCategory() {
        System.assertEquals(
            IFB_InterviewQuestionUtilities.getQuestionCategory(dummyMissingPosition, 
                                                           dummyExistingRecordTypeName),
            defaultCategory);
    }

    // if position/rt not mapped and default/rt not mapped, we get Empty String - ''
    static testMethod void validateUnmappedQuestionCategory() {
         System.assertEquals(
            IFB_InterviewQuestionUtilities.getQuestionCategory(dummyMissingPosition, dummyMissingRecordTypeName),
            '');       
    }
    
    // Test getActiveQuestions method
    static testMethod void validateGetActiveQuestions() {
        System.assertEquals(
            IFB_InterviewQuestionUtilities.GetActiveQuestions(dummyExistingPosition, 
                                                          technicalRecordTypeName).size(),
            5);
    }
    
    // Test reNumberQuestions method
    static testMethod void validateRenumberQuestions() {
        System.assertEquals(
            IFB_InterviewQuestionUtilities.RenumberQuestions(technicalCategory).contains('Renumbered'),
            true);
    }
    
    // Test reNumberQuestions method when there are no questions to number
    static testMethod void validateRenumberNoQuestions() {
        System.assertEquals(
            IFB_InterviewQuestionUtilities.RenumberQuestions(positionSpecificCategory).contains('No questions to renumber'),
            true);
    }
}