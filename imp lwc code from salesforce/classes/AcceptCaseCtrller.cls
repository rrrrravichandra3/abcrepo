public with sharing class AcceptCaseCtrller {

    @AuraEnabled
    public static void updateCaseOwner(String caseIds){

        List<String> caseList =  caseIds.split(',');
        
        if(!Schema.sObjectType.Case.fields.OwnerId.isUpdateable()){
            throw new AuraHandledException('ERROR: You don\'t have sufficient privilages to update Case owner.');
        }

        try{
            List<Case> casesSelected = [Select OwnerId from Case where Id in : caseList];
            for(Case c : casesSelected){
                c.OwnerId = UserInfo.getUserId();
            }
            update casesSelected;
        }catch(Exception ex){
            System.debug(LOGGINGLEVEL.INFO,'Exception has occured' + ex.getMessage()+ ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage());
        }
    }
}