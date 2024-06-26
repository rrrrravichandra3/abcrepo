/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_CandidateExtController {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        RecordType accountRecordType = [select id,name from RecordType where SObjectType='Account' and name='Candidate'];
		Account account =[Select Id, name from Account Where recordTypeId =: accountRecordType.Id and name='Candidates'];
		RecordType contactRecordType = [select id,name from RecordType where SObjectType='Contact' and name='Candidate'];
		Contact candidate = new Contact();
		candidate.RecordTypeId=contactRecordType.Id;
		candidate.AccountId = account.Id;
		candidate.FirstName = 'Test FS';
		candidate.lastName='Test Ls';
		candidate.email='a@b.com';
		candidate.Phone='1111111111';
		insert candidate;
		//Select a.Name, a.IsPrivate, a.Id, a.Body From Attachment a
		Attachment attach1 = new Attachment();
		attach1.parentId=candidate.Id;
		attach1.Name='test';
		attach1.isPrivate = false;
		attach1.body = Blob.valueof('test');
		insert attach1;
		
		Attachment attach2 = new Attachment();
		attach2.parentId=candidate.Id;
		attach2.Name='test';
		attach2.isPrivate = false;
		attach2.body = Blob.valueof('test1');
		insert attach2;

       CandidateExtController controller = new CandidateExtController(new ApexPages.StandardController(candidate));
       System.assert(controller.attachmentList != null);
       System.assert(controller.attachmentList.size() == 2);	
       
       ApexPages.currentPage().getParameters().put('attachmentId',attach2.Id);
       controller.deleteAttachment();
       System.assert(controller.attachmentList != null);
       System.assert(controller.attachmentList.size() == 1);
       	
    }
}