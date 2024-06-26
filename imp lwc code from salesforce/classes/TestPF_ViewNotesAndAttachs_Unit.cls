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
private class TestPF_ViewNotesAndAttachs_Unit {

    static testMethod void myUnitTest() {
        GenerateEnvironmentTest1.gen();
        System.assert(GenerateEnvironmentTest1.v2momLocked != null);
        System.assert(GenerateEnvironmentTest1.v2momUnlocked != null);
        System.assert(GenerateEnvironmentTest1.v2momNoValue != null);
        
        Test.startTest();
        
        
        System.currentPageReference().getParameters().put('pid', GenerateEnvironmentTest1.obstacleList[0].Id);
        System.currentPageReference().getParameters().put('retURL', 'home');
        
        ViewAllNotesAndAttachmentsController controller = new ViewAllNotesAndAttachmentsController();
        
        controller.getHasNotesAndAttachs();
        controller.getNotesAndAttachs();
        controller.getParentName();
        controller.getPId();
        controller.getRetURL();
        String parentId = GenerateEnvironmentTest1.testNote.ParentId;
        
        ViewAllNotesAndAttachmentsController.NotesAndAttachments innerClass = new  ViewAllNotesAndAttachmentsController.NotesAndAttachments(parentId, 'Title', 'Note', '', 'test user', System.now(), System.now());
		
		innerClass.getId();innerClass.getBody();
		innerClass.getDocumentType();
		innerClass.getLastModified();
		innerClass.getTitle();
		innerClass.getCreatedDate();
		innerClass.getLastModifiedDate();
		innerClass.getIsNote();
		innerClass.getIsAttach();
		
		
        Test.stopTest();
    }
}