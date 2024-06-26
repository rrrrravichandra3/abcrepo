@isTest
public class TestESDJC_UpdateCaseStatusController {
    //happy path testing.. 
    private static testMethod void testChangeWellnessCaseStatusListView(){
        Case wellnessCase = Test_Wellness_Util.createAPACWellnessCase();
        ApexPages.StandardSetController stdContr = new ApexPages.StandardSetController(new List<Case>{wellnessCase});
        stdContr.setSelected(new List<Case>{wellnessCase});
        ESDJC_UpdateCaseStatusController contrlr = new ESDJC_UpdateCaseStatusController(stdContr);
        contrlr.validateOnLoad();
         PageReference pageRef = Page.ESDJC_UpdateCaseStatusPage; 
        Test.setCurrentPage(pageRef);
         ApexPages.currentPage().getParameters().put('retURL', '/500');//take to list view of case object.. 
        //select the status to approved.. 
        contrlr.selectedStatus = 'Approved'; 
        contrlr.piiValue = 'Yes'; 
        Test.startTest();
        contrlr.updateCaseStatus(); 
        Test.stopTest();
        System.assert(contrlr.getPIIValues().size() > 1, 'PII should have atleast one valid picklist value other than --None--');
        System.assert(contrlr.getCaseStatusValues().size() == 3, 'There should be 3 Statuses(Approved, Approved for Partial Payment and Closed) to pick');
        Case newCase = [select Status, PII__c from case where id = : wellnessCase.Id];
        System.assertEquals('Approved', newCase.Status, 'Case should be in Approved Status');
        System.assertEquals('Yes', newCase.PII__c, 'Case PII should be in Yes');
      
    }
    //when no records are selected, system should throw an appropriate error message.. 
    private static testMethod void testChangeWellnessCaseStatusNoneSelected(){
        ApexPages.StandardSetController stdContr = new ApexPages.StandardSetController(new List<Case>());
        ESDJC_UpdateCaseStatusController contrlr = new ESDJC_UpdateCaseStatusController(stdContr);
        contrlr.validateOnLoad();
         PageReference pageRef = Page.ESDJC_UpdateCaseStatusPage; 
        Test.setCurrentPage(pageRef);
         ApexPages.currentPage().getParameters().put('retURL', '/500');//take to list view of case object.. 
        //select the status to approved.. 
        Test.startTest();
        boolean selectAtleastOneRecord = false;
        for(ApexPages.Message msg : ApexPages.getMessages()){
            if(msg.getDetail().contains('Please select at least one record.')){
                selectAtleastOneRecord = true;
            }
        }
        System.assert(selectAtleastOneRecord);
        Test.stopTest();
      
    }
    
    //For all non wellness case records, system should throw an error message upon clicking on change status button. 
    private static testMethod void testChangeNonWellnessCaseStatus(){
        Case nonWellnessCase = Test_Wellness_Util.createAPACWellnessCase();
        //change wellnessCase type.. 
        nonWellnessCase.type = 'Benefits';
        nonWellnessCase.RecordTypeId = [select Id from RecordType where name='All Case Types except ER - AMER'].Id;
        update nonWellnessCase;
        ApexPages.StandardSetController stdContr = new ApexPages.StandardSetController(new List<Case>{nonWellnessCase});
        stdContr.setSelected(new List<Case>{nonWellnessCase});
        ESDJC_UpdateCaseStatusController contrlr = new ESDJC_UpdateCaseStatusController(stdContr);
        contrlr.validateOnLoad();
         PageReference pageRef = Page.ESDJC_UpdateCaseStatusPage; 
        Test.setCurrentPage(pageRef);
         ApexPages.currentPage().getParameters().put('retURL', '/500');//take to list view of case object.. 
        Test.startTest();
        for(ApexPages.Message msg : ApexPages.getMessages()){
            System.assert(msg.getDetail().contains(System.Label.DJC_Wellness_ChaneStatus));
        }
        Test.stopTest();
    }

    private static testMethod void testCancelButtonClick(){
        Case wellnessCase = Test_Wellness_Util.createAPACWellnessCase();
        ApexPages.StandardSetController stdContr = new ApexPages.StandardSetController(new List<Case>{wellnessCase});
        stdContr.setSelected(new List<Case>{wellnessCase});
        ESDJC_UpdateCaseStatusController contrlr = new ESDJC_UpdateCaseStatusController(stdContr);
        contrlr.validateOnLoad();
         PageReference pageRef = Page.ESDJC_UpdateCaseStatusPage; 
        Test.setCurrentPage(pageRef);
         ApexPages.currentPage().getParameters().put('retURL', '/500');//take to list view of case object.. 
        //select the status to approved.. 
        Test.startTest();
        PageReference cancelPage = contrlr.cancel();
        System.assert(cancelPage.getUrl().endsWith('/500'));
        Test.stopTest();
    }

}