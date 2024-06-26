/**
* @author Apuroop Gadde
* @date 07-20-2017
* @group Util Classes
* @description Util class to share WD Job Application with Hiring Managers listed on the related Job Req.
*/
public class IFB_WDShareAppsWithHM implements Queueable{
    @testVisible private Set<Id> applicationIds;
    @testVisible private boolean isInsert = false;
    @testVisible private Set<Id> hiringManagers;
    @testVisible private String insertOrDeleteErrors;
    @testVisible private Integer noOfErrors;    
    
    /**
    * @description Constructor that initializes the Ids of applications and the object type from whose handler the class is instantiated.
    * @param wdrApplicationIds Ids of the WD Job Applications which need to be shared with the Hiring Manager.
    * @param isInsert Determines if the function is being called from an insert or update trigger.
    **/ 
    public IFB_WDShareAppsWithHM(Set<Id> inApplicationIds, boolean isInsert){
        this.hiringManagers = new Set<Id>();   
        this.insertOrDeleteErrors = 'Below are the errors while inserting or deleting share records for WD Objects \n';
        this.noOfErrors = 0;    
        this.applicationIds = inApplicationIds == null? new Set<Id>():inApplicationIds;
        this.isInsert = isInsert == null ? false : isInsert;
    }
        
    /**
    * @description Execute method for Queueable interface
    * @param context QueueableContext
    **/
    public void execute(QueueableContext context) {
        shareApplicationsWithHM();
        if(noOfErrors != 0) {
            String errorFileDesc = 'Errors that occurred when inserting or deleting Share objects or Permsets for Hiring Manager';   
            String errorFileTitle = 'Errors on inserting or deleting Share Objects and PermSets ' + System.now().format('yyyymmddhhmmss');
            IFB_WDUtils.mailErrors(insertOrDeleteErrors,errorFileDesc,errorFileTitle);
        }
        if(hiringManagers.size() != 0) {
            System.enqueueJob(new IFB_WDAssignPermSetsToHMs(hiringManagers));
        }
    }

    /**
    * @description This method shares application with the Hiring Manager on application insert.
    **/
    private void shareApplicationsWithHM() {
        Set<Id> hiringManagers = new Set<Id>();        
        if(isInsert == false) {
            List<WDR_Application__share> sharesForApplicationsToBeDeleted = [SELECT Id FROM WDR_Application__share WHERE ParentId IN :applicationIds 
                                                                             AND RowCause = :Schema.WDR_Application__share.RowCause.Hiring_Manager__c];  
            List<Database.DeleteResult> applicationDeleteResults = Database.delete(sharesForApplicationsToBeDeleted,false);
            for(Integer i =0;i< applicationDeleteResults.size();i++) {
                if(applicationDeleteResults[i].isSuccess() == false) {
                    noOfErrors++;
                    insertOrDeleteErrors = insertOrDeleteErrors + 'Deleting WD Job Application share with Id :'+ sharesForApplicationsToBeDeleted[i].Id + ' failed with error: \n';
                    for(Database.Error error : applicationDeleteResults[i].getErrors()) {
                        insertOrDeleteErrors = insertOrDeleteErrors + error.getStatusCode()+':'+error.getMessage()+ '\n';
                    }
            }
        }              
        }

        List<WDR_Application__share> sharesForApplications = new List<WDR_Application__share>();
        for(WDR_Application__c app : [SELECT Id,Job__r.Hiring_Manager__c FROM WDR_Application__c WHERE Id IN:applicationIds]) {
            sharesForApplications.add(IFB_WDUtils.createShareForApplication(app));
            hiringManagers.add(app.Job__r.Hiring_Manager__c);
        }
        if(sharesForApplications.size() != 0) {
            List<Database.SaveResult> applicationShareSaveResults = Database.insert(sharesForApplications,false);
            for(Integer i =0;i< applicationShareSaveResults.size();i++) {
                if(applicationShareSaveResults[i].isSuccess() == false) {
                    noOfErrors++;
                    insertOrDeleteErrors = insertOrDeleteErrors + 'Inserting WD Job Application share for Application with Id :'+ sharesForApplications[i].ParentId + ' failed with error: \n';
                    for(Database.Error error : applicationShareSaveResults[i].getErrors()) {
                        insertOrDeleteErrors = insertOrDeleteErrors + error.getStatusCode()+':'+error.getMessage()+ '\n';
                    }
                }
            }            
        }
    }
}