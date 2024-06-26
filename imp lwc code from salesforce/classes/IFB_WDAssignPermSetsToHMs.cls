/**
* @author Apuroop Gadde
* @date 07-20-2017
* @group Util Classes
* @description Util class to add WD specific perm set to the Hiring Manager.
*/
public class IFB_WDAssignPermSetsToHMs implements Queueable{
    @testVisible private Set<Id> listOfHMs;
    @testVisible private String insertOrDeleteErrors;
    @testVisible private Integer noOfErrors;
    /**
    * @description Constructor that initializes the Ids of Hiring Managers that need to be assigned Hiring manager Perm sets
    * @param listOfHMs Ids of HMs that need to be assigned Hiring manager Perm sets.
    **/ 
    public IFB_WDAssignPermSetsToHMs(Set<Id> listOfHMs){
        this.insertOrDeleteErrors = 'Errors that occurred when inserting Permsets for Hiring Manager: \n';
        this.noOfErrors = 0 ;
        this.listOfHMs = listOfHMS == null ? new Set<Id>() : listOfHMs;
    }
        
    /**
    * @description Execute method for Queueable interface
    * @param context QueueableContext
    **/
    public void execute(QueueableContext context) {
        assignPermsetToHMs();
        if(noOfErrors > 0) {
            mailErrors();
        }

    }

    /**
    * @description Assign SIFT-WD Hiring Manager permset to the input users
    * 
    **/
    private void assignPermsetToHMs() {
        String HMPermsetNamesString = IFB_SIFT_Settings_List__c.getInstance('SIFT').SIFT_WD_HM_Permsets__c;
        if(String.isEmpty(HMPermsetNamesString) == true) {
            return;
        }
        List<String> HMPermSetNames = HMPermsetNamesString.split(',');
        List<PermissionSet> HMPermSets = [SELECT Id FROM PermissionSet WHERE Label IN :HMPermSetNames];                
        Map<Id,Set<Id>> mapOfHMsAndSetOfPermSets = getHMsandSetOfPermSetsAssigned(HMPermSets);
        List<PermissionSetAssignment> permSetAssnsToInsert = new List<PermissionSetAssignment>();
        for(Id hmId : listOfHMs) {
            for(PermissionSet HMPermSet : HMPermSets) {
                if(mapOfHMsAndSetOfPermSets.get(hmId) == null || mapOfHMsAndSetOfPermSets.get(hmId).contains(HMPermSet.Id) == false) {
                    PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = HMPermSet.Id, AssigneeId = hmId);
                    permSetAssnsToInsert.add(psa);                    
                }
            }
        }
        List<Database.SaveResult> permSetAssnsSaveResults = Database.insert(permSetAssnsToInsert,false);
        for(Integer i =0;i< permSetAssnsSaveResults.size();i++) {
            if(permSetAssnsSaveResults[i].isSuccess() == false) {
                noOfErrors++;
                insertOrDeleteErrors = insertOrDeleteErrors + 'Inserting Permset for HM with Id :'+ permSetAssnsToInsert[i].AssigneeId + ' failed with error: \n';
                for(Database.Error error : permSetAssnsSaveResults[i].getErrors()) {
                    insertOrDeleteErrors = insertOrDeleteErrors + error.getStatusCode()+':'+error.getMessage()+ '\n';
                }
            }
        }                
    }

    /**
    * @description Util method to create an error log of errors that occur when updating SIFT objects from WDR objects on org 
    * and send the link to interested parties .
    * @param errorLog String that contains all the errors 
    * @param errorFileDesc Description of the error file
    * @param errorFileTitle Title for the error file.
    **/
    private void mailErrors() {
        String emailIdsFromCustomSetting = IFB_SIFT_Settings_List__c.getInstance('SIFT').IFB_WD_Integration_Downstream_Err_Emails__c;
        if(String.isEmpty(emailIdsFromCustomSetting) == true) {
            return;
        }
        List<String>emailIds = emailIdsFromCustomSetting.split(',');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(emailIds);
        mail.setSenderDisplayName('WDR Integation - PermSet assignment failures');
        mail.setSubject('Errors that occurred when inserting Permsets for Hiring Manager');
        mail.setPlainTextBody(insertOrDeleteErrors);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });        
    }

    /**
    * @decription This method returns a map of hiring manager ids and it's associated HM permsets that are already assigned
    * @param HMPermset A list of strings all WD specific HM Permsets
    * @return A Map of hiring manger ID and his assoicated WD specific HM permsets
    **/
    private Map<Id,Set<Id>> getHMsandSetOfPermSetsAssigned(List<PermissionSet> HMPermSets) {
        Map<Id,Set<Id>> mapOfHMsAndSetOfPermSets = new Map<Id,Set<Id>>();
        Map<Id,PermissionSet> HMPermSetsMap = new Map<Id,PermissionSet>(HMPermSets);
        for(PermissionSetAssignment psa : [SELECT AssigneeId,PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId IN : listOfHMs
                                                                      AND PermissionSetId IN :HMPermSetsMap.keySet()]) {
            if(mapOfHMsAndSetOfPermSets.get(psa.AssigneeId) == null) {
                Set<Id> permSetIds = new Set<Id>();
                permSetIds.add(psa.PermissionSetId);
                mapOfHMsAndSetOfPermSets.put(psa.AssigneeId,permSetIds);
            }
            else {
                mapOfHMsAndSetOfPermSets.get(psa.AssigneeId).add(psa.PermissionSetId);
            }
        }
        return mapOfHMsAndSetOfPermSets;
    }
}