/*
  This class assigns payroll permsets for all users where created>=YESTERDAY AND Role in "Payroll Amer Manager". 
  CreateDate: 08/11/2015
 */

global class  ESDJC_AutoAssign_PayrollPermset implements Database.Batchable<sObject> , Database.Stateful{

    private ESDJC_Settings__c settings;  
    private static final String payrollAmer = 'ES_DJC_Payroll_Amer';

    global Database.QueryLocator start(Database.BatchableContext BC){
        settings = ESDJC_Settings__c.getInstance();   
        return Database.getQueryLocator([SELECT Id from user where isActive = true and userroleId in : settings.Payroll_Amer_ID__c.split(',',-1) and createdDate>=YESTERDAY]);
    }

    global void execute(Database.BatchableContext BC,  List<sObject> scope){

        //fetch permset Id. 
        List<PermissionSet> payrollPermSet = [select id from PermissionSet where Name = 'ES_DJC_Payroll_Amer']; 
        List<PermissionSetAssignment> permsetAssignments = new List<PermissionSetAssignment>();
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> existingPermUsers = new Set<Id>();
        if(payrollPermSet.isEmpty()){
            return;
        }

        for(sObject usr : scope){
            User u = (User)usr;
            userIdSet.add(u.Id);
        }

        for(PermissionSetAssignment existingPerm : [select Id,AssigneeId from PermissionSetAssignment where AssigneeId in : userIdSet and PermissionSetId = :  payrollPermSet[0].Id ]){
            existingPermUsers.add(existingPerm.AssigneeId);
        }

        //assign permsets for vaid users --> where user role is payrollAmerManager and this user has not already been assigned this permset. 

        for(Id usrId : userIdSet){
            if(!existingPermUsers.contains(usrId)){
                PermissionSetAssignment permPayrollAmer = new PermissionSetAssignment(AssigneeId=usrId,PermissionSetId=payrollPermSet[0].Id);
                permsetAssignments.add(permPayrollAmer);
            }
        }

        if(!permsetAssignments.isEmpty()){
            insert permsetAssignments;
        }
    }

    global void finish(Database.BatchableContext BC){}

        
}