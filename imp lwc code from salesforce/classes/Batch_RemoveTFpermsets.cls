global class Batch_RemoveTFpermsets implements Database.Batchable<sObject>, Database.Stateful{

    Set<Id> excludedUserIds = new Set<Id>();
    Set<Id> tfPermsetIds = new Set<Id>();
    Set<Id> failedUserIds = new Set<Id>();
    Integer succesfulDeletions = 0;

    global Batch_RemoveTFpermsets(){
        //get the names of system admin profiles
        Set<String> sysAdminProfileNames = new Set<String>();
        sysAdminProfileNames.add('systemadministrator');
        sysAdminProfileNames.add('System Administrator');
        sysAdminProfileNames.add('System Admin - w/o VAD');

        //get the IDs of system admin profiles
        List<Profile> sysAdminProfiles = [Select Id from Profile where Name IN :sysAdminProfileNames ];
        Set<Id> sysAdminProfileIds = new Set<Id>();
        for(Profile pf : sysAdminProfiles){
            sysAdminProfileIds.add(pf.Id);
        }

        //get the users that are system admins and add them to the set of excluded Ids
        List<User> sysAdminUsers = [Select Id from User where ProfileId IN :sysAdminProfileIds And isActive = true];
        for(User u : sysAdminUsers){
            excludedUserIds.add(u.Id);
        }

        //Name of TF Permsets
        Set<String> tfPermsetNames = new Set<String>();
        tfPermsetNames.add('Talentforce_Acquisition');
        tfPermsetNames.add('Talentforce_BI_Admin');
        tfPermsetNames.add('TF_Compliance');
        tfPermsetNames.add('Talentforce_Docusign_Admin');
        tfPermsetNames.add('Talentforce_EEO_Info');
        tfPermsetNames.add('Talentforce_ESS_Comp');
        tfPermsetNames.add('Talentforce_FinanceBusinessPartner');
        tfPermsetNames.add('Talentforce_Finance_Business_Partner_w_Do_Not_Share_Post_Access');
        tfPermsetNames.add('Talentforce_HiringManager');
        tfPermsetNames.add('Talentforce_Recruiter_Japan');
        tfPermsetNames.add('Talentforce_Recruiter_Base');
        tfPermsetNames.add('Talentforce_Recruiter_Base_w_Do_Not_Share');
        tfPermsetNames.add('Talentforce_Recruiting_Coordinator');
        tfPermsetNames.add('Talentforce_Recruiting_Manager');
        tfPermsetNames.add('Talentforce_Recruiting_Ops');
        tfPermsetNames.add('Talentforce_Recruiting_Research');
        tfPermsetNames.add('Talentforce_Referrals_Admin');
        tfPermsetNames.add('Task_Reassign_Owner');
        tfPermsetNames.add('Talentforce_Visualforce');
        tfPermsetNames.add('Talentforce_Administrator');
        tfPermsetNames.add('Talentforce_Base');
        tfPermsetNames.add('Talentforce_Legal');


        // Set of Ids of permsets
        List<PermissionSet> permSets = [Select Id from PermissionSet where Name in :tfPermsetNames];
        for(PermissionSet ps : permSets){
            tfPermsetIds.add(ps.Id);
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String queryString = 'Select Id from PermissionSetAssignment where PermissionSetId IN :tfPermsetIds AND AssigneeId NOT IN :excludedUserIds';
        return Database.getQueryLocator(queryString);       
    }

    global void execute(Database.BatchableContext BC, List<PermissionSetAssignment> scope){
        List<Database.DeleteResult> deleteResults = Database.delete(scope, false); // Allow partial success.
        for(Integer i=0;i<deleteResults.size();i++){
            if(deleteResults.get(i).isSuccess()){
                succesfulDeletions++;
            }else{
                failedUserIds.add(scope.get(i).AssigneeId);
            }
        }
    }

    global void finish(Database.BatchableContext BC){
        String[] toAddresses = new String[]{};
        toAddresses.add('ksrivastava@salesforce.com');
        toAddresses.add('pmunukuntla@salesforce.com');
        String message = '';
        message = message + '\n Successfully Deleleted '+ succesfulDeletions+' PermissionSetAssignments';
        if(failedUserIds.size()>0){
            message = message + '\nFor following Users some TF permission sets were not deleted. Please check them manually\n';
            for(Id currId : failedUserIds){
                message = message+'\n'+String.ValueOf(currId);
            }
        }else{
            message = message + '\nNo failures';
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Remove TF Permission Batch');
        mail.setSubject('Batch Process Batch_RemoveTFpermsets Complete');
        mail.setPlainTextBody(message);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }



}