/*
    This class enables users to download a resume associated with an offer without logging in
    The supplied parameter "token" determines the behavior
    The token is valid for Max_Days_Resume_Access_Open__c days after creation
    Also the token is valid for upto Max_Resume_Access_Count__c downloads   
*/
public with sharing class TF2RDController {
    private List<TF2_RD_Tracker__c> trackerList {get; set;}
    public TF2RDController(){
        String token = System.currentPageReference().getParameters().get('token');  
        token  = String.escapeSingleQuotes(token); // Pradeep: to validate the String..     
        populateTracker(token);
    }
    
    public void populateTracker(String token) {
        this.trackerList = [Select Id,Access_Count__c,Activated_Date__c,Resume_ID__c,Status__c From TF2_RD_Tracker__c Where  Token__c =: token and Status__c ='Active'];
    }
    
    public PageReference getResource() {
        TF2_RD_Tracker__c rec = null;
        PageReference errorPage = new PageReference('/FileNotFound');
        PageReference newPage = errorPage;
        if (trackerList != null && trackerList.size() == 1) {
            rec = trackerList.get(0); 
            TF2Settings__c configurations = TF2Settings__c.getInstance();
            
            if(rec != null && (rec.Access_Count__c < configurations.Max_Resume_Access_Count__c || 
                Date.today().daysBetween(rec.Activated_Date__c) < configurations.Max_Days_Resume_Access_Open__c)){
                rec.Access_Count__c =  rec.Access_Count__c + 1;
                update(rec);
                newPage = new PageReference('/servlet/servlet.FileDownload?file='+rec.Resume_ID__c);
            }
        }
        newPage.setRedirect(true);
        return newPage ;
    }
}