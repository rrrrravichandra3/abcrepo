public with sharing class PF_SobjectShareEventService {

    public static map<String,Boolean>  createApexShares(string TypeName, List<sobjectShare__e> sobjectShares){
        if(TypeName == 'IDP__Share'){
            map<string,string> mMgerIdByIDPRecId = new map<string,string>();
            for(sobjectShare__e shareEvt : sobjectShares){
                mMgerIdByIDPRecId.put(shareEvt.ParentId__c ,shareEvt.UserOrGroupId__c) ;                
            }
            return IDP_AccessUtil.shareIDPWithManager(mMgerIdByIDPRecId);
        }
        return null;

    }
    public static void deleteIdpShares(List<IDP__share> idpShares){
        String errDesc;
        List<String> errDescs = new List<String>();
        if(idpShares.size()>0){
               List<Database.DeleteResult> deleteResults = database.delete(idpShares,false);
               for (Database.DeleteResult sr : deleteResults){
                   if (!sr.isSuccess()) {
                       errDesc = 'Deleting the IDP Share Records Failed';
                       for (Database.Error err : sr.getErrors()) {
                           errDesc += 'and Status code is ' +err.getStatusCode()+ ' message is '+err.getMessage()+ ' fields are '+err.getfields();
                           errDescs.add(errDesc);
                            //Something happened to this claim on PF claim triggers side.This error will not duplicate as it will be skipped after one run.So Only Insert.
                           PF_Logger.log('IDP','ERROR',err.getMessage(),'DML Error',errDesc,'UserUpdateFlowForIdp',sr.getId());
                       }
                       
                   }
               }
               
        }
   }

}