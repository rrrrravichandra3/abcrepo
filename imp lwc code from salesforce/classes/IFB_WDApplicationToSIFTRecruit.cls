/**
* @author Angel Abrego, Apuroop Gadde
* @date 07-01-2017
* @group TriggerHandlerUtils
* @description Handles Recruit updates when WDR proxy objects are updated.
*/
public class IFB_WDApplicationToSIFTRecruit implements Queueable{
    @TestVisible
    private Set<Id> listWDApplicationIds;
    @TestVisible 
    private DateTime syncDateTime;
    @TestVisible
    private List<IFB_Interview_Candidate__c> recruitsToBeUpdated ;
    @TestVisible
    Schema.SObjectType objectType;
    
    /**
    * @description Constructor that initializes the Ids of applications and the object type from whose handler the class is instantiated.
    * @param wdrApplicationIds Ids of applications whose related recruits need to be updated.
    * @param inObjectType object type of the object from where the class was instantiated.
    **/ 
    public IFB_WDApplicationToSIFTRecruit(Set<Id> wdrApplicationIds, Schema.SObjectType inObjectType){
        this.recruitsToBeUpdated = new List<IFB_Interview_Candidate__c>();        
        this.syncDateTime = Datetime.now();
        if(wdrApplicationIds == null || inObjectType == null) {
            listWDApplicationIds = new Set<Id>();
            syncDateTime = Datetime.now();
            return;
        }
        this.listWDApplicationIds = wdrApplicationIds;
        this.objectType = inObjectType;
    }
    
    /**
    * @description Execute method for Queueable interface
    * @param context QueueableContext
    **/
    public void execute(QueueableContext context) {
        getRecruitMappingByApplicationId();
        updateRecruitsinQueue();
    }
    
    /**
    *@description Updates the corresponding SIFT 'Recruits' by 'WD Job Application' record
    **/
    @TestVisible
    private void getRecruitMappingByApplicationId() {   
        /*
        Role: Recruiter
        Permission Set Name: IFB RECRUITER-RECRUITER
        IFB_Interview_Candidate__c.Years_of_Experience__c -> Is Editable in Permission Set?: YES
        IFB_Interview_Candidate__c.State__c -> Is Editable in Permission Set?: YES
        IFB_Interview_Candidate__c.Rejected__c -> Is Editable in Permission Set?: YES
        IFB_Interview_Candidate__c.Rejected_Offer__c -> Is Editable in Permission Set?: YES
        IFB_Interview_Candidate__c.Recruiter_Intro__c -> Is Editable in Permission Set?: YES
        IFB_Interview_Candidate__c.Region__c -> Is Editable in Permission Set?: YES
        IFB_Interview_Candidate__c.Recruiter_Intro__c -> Is Editable in Permission Set?: YES
        IFB_Interview_Candidate__c.Phone__c -> Is Editable in Permission Set?: YES
        IFB_Interview_Candidate__c.Email__c -> Is Editable in Permission Set?: YES
        IFB_Interview_Candidate__c.Accepted_Offer__c -> Is Editable in Permission Set?: YES
        IFB_Interview_Candidate__c.Projected_Start_Date__c -> Is Editable in Permission Set?: NO
        IFB_Interview_Candidate__c.Hire_date__c -> Is Editable in Permission Set?: NO
        SIFT_Position__c --> Not found in PermissionSet
        SIFT_Group__c --> Not found in PermissionSet
        Last_Name__c --> Not found in PermissionSet
        first_name__c --> Not found in PermissionSet
        City__c --> Not found in PermissionSet
        last_wdr_sync__c --> Not found in PermissionSet
        job_application_wdr__c --> Not found in PermissionSet

         */

        for (WDR_Application__c wdApp : [SELECT Id, SIFT_Recruit__c, Candidate__r.First_Name__c, Candidate__r.Last_Name__c, Candidate__r.Mailing_City__c, 
                                        Candidate__r.Mailing_State__c, Candidate__r.Email__c, Candidate__r.Phone__c, SIFT_Recruiter_Intro__c, SIFT_Group__c,
                                        SIFT_Position__c, SIFT_Group_Lookup__c, SIFT_Position_Lookup__c, SIFT_Years_of_Experience__c, Candidate_Stage__c, Start_Date__c, Job__r.Region__c,
                                        Job__r.Target_Hire_Date__c 
                                        FROM WDR_Application__c 
                                        WHERE Id in :listWDApplicationIds 
                                        AND SIFT_Recruit__c != null 
                                        AND Candidate__c != null 
                                        AND Job__c != null 
                                        AND SIFT_Recruit__r.Do_not_sync_with_WDR__c = false]) { 
            IFB_Interview_Candidate__c recruit = new IFB_Interview_Candidate__c(Id = wdApp.SIFT_Recruit__c);

            if(IFB_WDUtils.getValuesForCustomSetting('Post_Placement_Candidate_Stages__c').contains(wdApp.Candidate_Stage__c) == true) {
                if(objectType == WDR_Application__c.sObjectType) {

                    if(IFB_AccessibilityUtils.checkFLS('IFB_Interview_Candidate__c',
                            IFB_AccessibilityUtils.PermissionType.UPDATEABLE,
                            new List<String> {'Last_WDR_Sync__c', 'Job_Application_WDR__c', 'Accepted_Offer__c'})){
                        recruit.Job_Application_WDR__c = wdApp.Id;
                        recruit.Last_WDR_Sync__c = this.syncDateTime;

                        //IFB_Interview_Candidate__c.Hire_date__c -> Is Editable in Permission Set?: NO
                        recruit.Hire_Date__c = wdApp.Start_Date__c;
                        recruit.Accepted_Offer__c = true;
                        recruitsToBeUpdated.add(recruit);
                    }else{
                        throw new PF_SecurityCheckException(Label.SIFT_Exception_Update_IFB_Interview_Candidate);
                    }
                }
            }
            else {
                if(IFB_AccessibilityUtils.checkFLS('IFB_Interview_Candidate__c',
                        IFB_AccessibilityUtils.PermissionType.UPDATEABLE,
                        new List<String> {'Last_WDR_Sync__c', 'Job_Application_WDR__c'})) {
                    recruit.Job_Application_WDR__c = wdApp.Id;
                    recruit.Last_WDR_Sync__c = this.syncDateTime;
                }else{
                    throw new PF_SecurityCheckException(Label.SIFT_Exception_Update_IFB_Interview_Candidate);
                }

                //Information coming from the related 'WD Candidate' record.
                if(objectType == WDR_Candidate__c.sObjectType) {
                    if(IFB_AccessibilityUtils.checkFLS('IFB_Interview_Candidate__c',
                            IFB_AccessibilityUtils.PermissionType.UPDATEABLE,
                            new List<String> {'State__c', 'Phone__c', 'First_Name__c', 'Last_Name__c', 'Email__c', 'City__c'})){
                        recruit.First_Name__c = wdApp.Candidate__r.First_Name__c;
                        recruit.Last_Name__c = wdApp.Candidate__r.Last_Name__c;
                        recruit.City__c = wdApp.Candidate__r.Mailing_City__c;
                        recruit.State__c = wdApp.Candidate__r.Mailing_State__c;
                        recruit.Email__c = wdApp.Candidate__r.Email__c;
                        recruit.Phone__c = wdApp.Candidate__r.Phone__c;
                    }else{
                        throw new PF_SecurityCheckException(Label.SIFT_Exception_Update_IFB_Interview_Candidate);
                    }
                }
                
                //Information coming from the related 'WD Job Application' record.
                if(objectType == WDR_Application__c.sObjectType) {
                    if(IFB_AccessibilityUtils.checkFLS('IFB_Interview_Candidate__c',
                            IFB_AccessibilityUtils.PermissionType.UPDATEABLE,
                            new List<String> {'Years_of_Experience__c', 'SIFT_Position__c', 'SIFT_Group__c', 'Rejected__c', 'Rejected_Offer__c', 'Recruiter_Intro__c'})){
                        recruit.Recruiter_Intro__c = wdApp.SIFT_Recruiter_Intro__c;
                        recruit.SIFT_Group__c = wdApp.SIFT_Group_Lookup__c;
                        recruit.SIFT_Position__c = wdApp.SIFT_Position_Lookup__c;
                        recruit.Years_of_Experience__c = wdApp.SIFT_Years_of_Experience__c;
                        recruit.Rejected__c = (IFB_WDUtils.getValuesForCustomSetting('WDR_Rejected_Candidate_Stages__c')
                                .contains(wdApp.Candidate_Stage__c) ? true : false);
                        recruit.Accepted_Offer__c = (IFB_WDUtils.getValuesForCustomSetting('WDR_Accepted_Offer_Status__c')
                                .contains(wdApp.Candidate_Stage__c) ? true : false);
                        recruit.Rejected_Offer__c = (IFB_WDUtils.getValuesForCustomSetting('WDR_Rejected_Offer_Status__c')
                                .contains(wdApp.Candidate_Stage__c) ? true : false);
                    }else{
                        throw new PF_SecurityCheckException(Label.SIFT_Exception_Update_IFB_Interview_Candidate);
                    }
                }

                //Information coming from the related 'WD Job Requisition' record.
                if(objectType == WDR_Job__c.sObjectType) {
                    if(IFB_AccessibilityUtils.checkFLS('IFB_Interview_Candidate__c',
                            IFB_AccessibilityUtils.PermissionType.UPDATEABLE,
                            new List<String> {'Region__c'})){
                        //IFB_Interview_Candidate__c.Region__c -> Is Editable in Permission Set?: YES
                        recruit.Region__c = wdApp.Job__r.Region__c;
                        //IFB_Interview_Candidate__c.Projected_Start_Date__c -> Is Editable in Permission Set?: NO
                        recruit.Projected_Start_Date__c = wdApp.Job__r.Target_Hire_Date__c;
                    }else{
                        throw new PF_SecurityCheckException(Label.SIFT_Exception_Update_IFB_Interview_Candidate);
                    }
                }
                recruitsToBeUpdated.add(recruit);
            }
        }
    }

    /**
    * @description Update recruits and send an email on failures
    **/
    @TestVisible
    private void updateRecruitsinQueue() {
        String recruitUpdateErrors = 'Below are the errors while updating recruits from WDR objects:\n';
        String errorFileDesc = 'Errors that occurred when updating Recruits through Integration';   
        String errorFileTitle = 'Errors on SIFT Recruit Update ' + System.now().format('yyyymmddhhmmss');  
        Integer noOfErrors = 0;
        List<Database.SaveResult> updateResults = Database.update(recruitsToBeUpdated,false);
        for(Integer i =0;i< recruitsToBeUpdated.size();i++) {
            if(updateResults[i].isSuccess() == false) {
                noOfErrors++;
                recruitUpdateErrors = recruitUpdateErrors+'Recruit with Id :'+ recruitsToBeUpdated[i].Id + ' failed when updating application with id:'+
                                            recruitsToBeUpdated[i].Job_Application_WDR__c+'\n';
                for(Database.Error error : updateResults[i].getErrors()) {
                    recruitUpdateErrors = recruitUpdateErrors + error.getStatusCode()+':'+error.getMessage()+ '\n';
                }
            }
        }
        if(noOfErrors > 0) {
            IFB_WDUtils.mailErrors(recruitUpdateErrors,errorFileDesc,errorFileTitle);
        }
    } 
}