public with sharing class PF_SobjectShareEventHandler {
    public static void  executeShares(List<sobjectShare__e> sobjectShares){
        //Group events by sobject share Type
        map<string,List<sobjectShare__e>> mShareEventsBySobjectShareType = new map<string,List<sobjectShare__e>> ();
        Set<String> idpRecords = new Set<String>();
        for(sobjectShare__e event:sobjectShares){
            string sobjectShareAPIName = event.sObjectShareAPIName__c;
            idpRecords.add(event.ParentId__c);
            if(mShareEventsBySobjectShareType.containsKey(sobjectShareAPIName)){
                mShareEventsBySobjectShareType.get(sobjectShareAPIName).add(event);
            }else{
                mShareEventsBySobjectShareType.put(sobjectShareAPIName , new List<sobjectShare__e>{event});
            }

        }
         //Select their previous Manual IDP shares with their old managers and delete them.
        if(idpRecords.size()>0){
            List<IDP__share> idpShares = [SELECT Id from IDP__share where ParentId in :idpRecords and rowCause ='Manual'];
            PF_SobjectShareEventService.deleteIdpShares(idpShares);
        }
        //Pass to service layer to create apex shares for respective sobj types
        for(String sobjectShareAPIName :mShareEventsBySobjectShareType.keyset()){
            PF_SobjectShareEventService.createApexShares(sobjectShareAPIName,mShareEventsBySobjectShareType.get(sobjectShareAPIName));
        }
    }
     

}