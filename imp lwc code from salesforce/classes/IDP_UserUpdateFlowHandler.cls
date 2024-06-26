/*
    This class is run from process automation and serves
    to manage Users' IDP access share with their Manager
    It is executed from record triggered flow on User object
    which runs in System Context without sharing
    and hence this class has been purposely declared as without sharing 
    to not override the behaviour.
*/
public without sharing class IDP_UserUpdateFlowHandler {

    //This is invoked from apex action of flow - IDP_ShareIDPOnManagerUpdate
    /* Apex action is bulkifiable element -
     i.e multiple flow interviews are spawned in same transaction hit the apex, it invoked this method ONCE 
     - Eg: Multiple user updates from Worker Integration API user.
     - Hence input to the method is collection.
    */
    @InvocableMethod
    public static void shareIDPToNewManager(List<User> users){
        map<string,User> mUsersByEmpId = new map<string,User>();
        map<string, IDP__c> mIDPsByEmpId = new map<String,IDP__c>();
        try{
            //Get User Emp Id
            for(User u:Users){
                mUsersByEmpId.put(u.EmployeeNumber,u);
            }
            //Get and gather the IDPs for given users based on their employee numbers.
            List<IDP__c> IDPs = [SELECT Id,Employee_Number__c from IDP__c 
                                 where Employee_Number__c =:mUsersByEmpId.keySet()];
            
            for(IDP__c IDP:IDPs){
                mIDPsByEmpId.put(IDP.Employee_Number__c,IDP);
            }
            //Prepare platform event to share IDP of the updated Users with their respective new managers.
            List<sobjectShare__e> IDPShareEvts = new List<sobjectShare__e>();
            for(String empId:mIDPsByEmpId.keySet()){
                String managerId= mUsersByEmpId.get(empId).Manager__c;
                if(managerId!= null){
                sobjectShare__e IDPShareEvt =  new sobjectShare__e(ParentId__c=mIDPsByEmpId.get(empId).Id, 
                                                                    UserOrGroupId__c=ManagerId,
                                                                    sObjectShareAPIName__c='IDP__Share'
                                                                    );
                    IDPShareEvts.add(IDPShareEvt);
                }
            }
            // Call method to publish events 
            List<Database.SaveResult> srList = EventBus.publish(IDPShareEvts);
            for(Database.SaveResult sr : srList){
                if (sr.isSuccess()) {
                    System.debug('Successfully published new manager share event from IDP_UserUpdateFlowHandler.');
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        String ErrContext = 'Unable to share IDP with manager for User with Id  '+ UserInfo.getUserId();
                        String ExceptionMessage = ' sobjectShare__e platform event failed with '+ err.getStatusCode()  + ' - ' + err.getMessage();
                        system.debug(ErrContext+ExceptionMessage);
                        PF_Logger.log('IDP','ERROR',err.getMessage(),ErrContext,ExceptionMessage,'IDP_UserUpdateFlowHandler');
                    }
                }
            }

        }catch (exception ex){
            String errorContext = 'Exception happened when sharing IDP to managers for users '+users;
            system.debug(errorContext+' -'+ ex.getMessage());
            PF_Logger.log('IDP','ERROR',ex.getMessage(),errorContext,ex.getStackTraceString(),'IDP_UserUpdateFlowHandler');          
        }
        if( PF_Logger.logs.size()>0){
            PF_Logger.createLogs(PF_Logger.logs);
        }
    }
}