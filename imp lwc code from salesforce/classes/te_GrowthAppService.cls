public with sharing class te_GrowthAppService {
    
    @AuraEnabled
    public static te_EmployeeWrapper.EmployeeWrapper getEmployeeContactData(){
        te_EmployeeWrapper.EmployeeWrapper emp;

        String userId = UserInfo.getUserId();
        system.debug('UserId**** '+userId);
        User usr = [SELECT Id, EmployeeNumber FROM User WHERE Id =: userId];
        String workerId = usr.EmployeeNumber;
        if(workerId != null){
            emp = te_EmployeeWrapper.getEmployeeData(workerId);
        }
        return emp; 
    }

}