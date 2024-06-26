@isTest
public class PbCaseWrapperTest {
	@isTest
    static void testPbCaseWrapper() {
        // Create a test case
        Case testCase = new Case(
            Subject = 'Test Subject',
            Status = 'Open',
            Description = 'Test Description'
        );
        insert testCase;

        // Create PbCaseWrapper instance
        PbCaseWrapper wrapper = new PbCaseWrapper();
        wrapper.Id = testCase.Id;
        wrapper.CreatedDate = String.valueOf(testCase.CreatedDate);
        wrapper.LastModifiedDate = String.valueOf(testCase.LastModifiedDate);
        wrapper.Subject = testCase.Subject;
        wrapper.CaseNumber = testCase.CaseNumber;
        wrapper.Status = testCase.Status;
        wrapper.IsClosed = testCase.IsClosed;
        wrapper.OwnerName = testCase.Owner.Name; // Assuming Owner is a User
        wrapper.Description = testCase.Description;

        // Perform assertions
        System.assertEquals(testCase.Id, wrapper.Id);
        System.assertEquals(String.valueOf(testCase.CreatedDate), wrapper.CreatedDate);
        System.assertEquals(String.valueOf(testCase.LastModifiedDate), wrapper.LastModifiedDate);
        System.assertEquals(testCase.Subject, wrapper.Subject);
        System.assertEquals(testCase.CaseNumber, wrapper.CaseNumber);
        System.assertEquals(testCase.Status, wrapper.Status);
        System.assertEquals(testCase.IsClosed, wrapper.IsClosed);
        System.assertEquals(testCase.Owner.Name, wrapper.OwnerName);
        System.assertEquals(testCase.Description, wrapper.Description);

    }
}