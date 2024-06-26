public with sharing class AllegationTriggerHandler {

    public static Id ER_ALLEGATION_RECORD_TYPE_ID = Schema.SObjectType.Allegations__c.getRecordTypeInfosByName().get('ER Allegations').getRecordTypeId();
    public static Map<Id, ER_Restricted_Case__c> erRestrictedCaseDetailMap = new Map<Id, ER_Restricted_Case__c>();
    //*****************************************************************************
        // Method called on before Insert of Allegations
    //****************************************************************************/

    public static void onBeforeInsert( List<Allegations__c> newList ){  

        populateContactManagementHierarchy(newList,null,true); 
        populateAccusedAcquiredCompanyName(newList);
        
    }

    //*****************************************************************************
        // Method called on before Update of Allegations
    //****************************************************************************/

    public static void onBeforeUpdate( List<Allegations__c> newList, Map<Id,Allegations__c> newMap, 
                                       List<Allegations__c> oldList, Map<Id,Allegations__c> oldMap ){  

        populateContactManagementHierarchy(newList,oldMap,false); 
        populateAccusedAcquiredCompanyName(newList);
         
    }
    
    //*****************************************************************************
        // Method called on After Insert of Allegations
    //****************************************************************************/

    public static void onAfterInsert( Map<Id,Allegations__c> newMap, List<Allegations__c> oldList, Map<Id,Allegations__c> oldMap){  
        handleERRestrictedCase(newMap, oldMap);
            
    }

    //*****************************************************************************
        // Method called on After Update of Allegations
    //****************************************************************************/

    public static void onAfterUpdate( Map<Id,Allegations__c> newMap, List<Allegations__c> oldList, Map<Id,Allegations__c> oldMap){ 
        handleERRestrictedCase(newMap, oldMap);  
            
    }

    //*****************************************************************************
        // Method called on After Delete of Allegations
    //****************************************************************************/

    public static void onAfterDelete(List<Allegations__c> oldList){ 
        deleteERRestrictedCase(oldList);  
    }

    //*****************************************************************************
        // Method called on Before Delete of Allegations
    //****************************************************************************/

    public static void onBeforeDelete(List<Allegations__c> oldList){ 
        handelDeleteERCases(oldList);  
    }  

    //*****************************************************************************
        // Method to populate Contact ManagementHierarchy Fields on Allegations
    //****************************************************************************/

    private static void populateContactManagementHierarchy(List<Allegations__c> newList, Map<Id, Allegations__c> oldMap, Boolean isInsert){
        
        Set<Id> contactIds = new Set<Id>();
        Map<Id,ManagementHierarchy> mgmntHierarchyMap = new Map<Id,ManagementHierarchy>();
        Map<Id,Id> accusedToReportsToMap = new Map<Id,Id>();
        Map<Id,Id> accusedToManagementHierarchy2Map = new Map<Id,Id>();
        Map<Id,Id> accusedToManagementHierarchy3Map = new Map<Id,Id>();
        Map<Id,Id> accusedToManagementHierarchy4Map = new Map<Id,Id>();
        Map<Id,Id> accusedToManagementHierarchy5Map = new Map<Id,Id>();
        Map<Id,Id> accusedToManagementHierarchy6Map = new Map<Id,Id>();

        for(Allegations__c allegation : newList){

            if(isInsert || (!isInsert && oldMap.get(allegation.id).Accused__c != allegation.Accused__c)){

                contactIds.add(allegation.Accused__c);  

            }
        }

        if(contactIds != NULL && contactIds.size() > 0){
            
            for(Contact c : [Select Id,ReportsToId from Contact where Id IN : contactIds]){
                accusedToReportsToMap.put(c.Id,c.ReportsToId);
            }
            for(Contact c : [Select Id,ReportsToId from Contact where Id IN : accusedToReportsToMap.values()]){
                accusedToManagementHierarchy6Map.put(c.Id,c.ReportsToId);
            }
            for(Contact c : [Select Id,ReportsToId from Contact where Id IN : accusedToManagementHierarchy6Map.values()]){
                accusedToManagementHierarchy5Map.put(c.Id,c.ReportsToId);
            }
            for(Contact c : [Select Id,ReportsToId from Contact where Id IN : accusedToManagementHierarchy5Map.values()]){
                accusedToManagementHierarchy4Map.put(c.Id,c.ReportsToId);
            }
            for(Contact c : [Select Id,ReportsToId from Contact where Id IN : accusedToManagementHierarchy4Map.values()]){
                accusedToManagementHierarchy3Map.put(c.Id,c.ReportsToId);
            }

            for(Id contactId : contactIds){
                
                Id mh1,mh2,mh3,mh4,mh5,mh6;
                     
                mh6 = accusedToReportsToMap.get(contactId);
                mh5 = accusedToManagementHierarchy6Map.get(accusedToReportsToMap.get(contactId));
                mh4 = accusedToManagementHierarchy5Map.get(accusedToManagementHierarchy6Map.get(accusedToReportsToMap.get(contactId)));
                mh3 = accusedToManagementHierarchy4Map.get(accusedToManagementHierarchy5Map.get(accusedToManagementHierarchy6Map.get(accusedToReportsToMap.get(contactId))));
                mh2 = accusedToManagementHierarchy3Map.get(accusedToManagementHierarchy4Map.get(accusedToManagementHierarchy5Map.get(accusedToManagementHierarchy6Map.get(accusedToReportsToMap.get(contactId)))));
                mh1 = accusedToReportsToMap.get(contactId);

                ManagementHierarchy mgh = new ManagementHierarchy(mh1,mh2,mh3,mh4,mh5,mh6);
                mgmntHierarchyMap.put(contactId,mgh);

            }

            for(Allegations__c allegation : newList){

                allegation.Accused_Management_Hierarchy_6__c = mgmntHierarchyMap.get(allegation.Accused__c).MH6;
                allegation.Accused_Management_Hierarchy_5__c = mgmntHierarchyMap.get(allegation.Accused__c).MH5;
                allegation.Accused_Management_Hierarchy_4__c = mgmntHierarchyMap.get(allegation.Accused__c).MH4;
                allegation.Accused_Management_Hierarchy_3__c = mgmntHierarchyMap.get(allegation.Accused__c).MH3;
                allegation.Accused_Management_Hierarchy_2__c = mgmntHierarchyMap.get(allegation.Accused__c).MH2;
                allegation.Accused_Reports_To__c = mgmntHierarchyMap.get(allegation.Accused__c).MH1;
                
            }
        }
    }

    //*****************************************************************************
        // Method to populate Accussed Acquired Company Name on Allegations
    //****************************************************************************/

    private static void populateAccusedAcquiredCompanyName(List<Allegations__c> newList){
    
        Map<String,Allegations__c> allegationMap = new Map<String,Allegations__c>();
        Set<Id> allegationRecTypeIds = new Set<Id>();

        String queryString = 'select Id from RecordType where Developername IN '+ System.Label.ES_DJC_Allegation_Record_Type;
        
        try{

            for(SObject recType : Database.query(queryString)){

                allegationRecTypeIds.add(recType.Id);

            }

            if (!allegationRecTypeIds.isEmpty()){

                for(Allegations__c allegation : newList){
                    
                    Boolean isValidRecordType = allegationRecTypeIds.contains(allegation.RecordTypeId);
                    String accusedEmail = allegation.Accused_Email__c;

                    if(isValidRecordType && !String.isBlank(accusedEmail)){
                    
                        allegationMap.put(allegation.Accused_Email__c,allegation);
                        
                    }
                }
            }

            for(Acquisition_Contacts__c acq : [ Select Id, Salesforce_Email_Address__c,Acquisition_Company_Name__c 
                                                from Acquisition_Contacts__c where Salesforce_Email_Address__c IN : allegationMap.keySet()]){

                String accusedCompanyName = acq.Acquisition_Company_Name__c;
                
                if(!String.isBlank(accusedCompanyName)){

                    allegationMap.get(acq.Salesforce_Email_Address__c).Accused_Acquired_Company_Name__c = acq.Acquisition_Company_Name__c;

                }
            }
        }  
        catch (Exception ex){
            PF_Logger.log('DJC','ERROR',ex.getMessage(),ex.getTypeName(), ex.getLineNumber()+' Error while fetching Acquired Company Name ' + allegationMap + ' UserId '+ UserInfo.getUserId(), 'AllegationTriggerHandler'); 
        }
        finally{
            NHW_Util.insertNHWLogs();  
        }      
    }
    
    //*****************************************************************************
        // Method to get Allegation Records
    //****************************************************************************/
    private static Map<Id, Allegations__c> getAllegationInfo(Set<Id> AllegationIds){
        Map<Id, Allegations__c> allegationToRestrictedCaseMap = new Map<Id, Allegations__c>();
        for(Allegations__c allegation : [Select Id,Case__c,Case__r.Attorney_client_privilege__c,Case__r.ContactId,Case__r.OwnerId,Accused__r.Name,Accused__r.Email,Case__r.CaseNumber
                                         FROM Allegations__c
                                         WHERE Id IN :AllegationIds]){
                             
            allegationToRestrictedCaseMap.put(allegation.Id,allegation);
        }
        return allegationToRestrictedCaseMap;
    }

    //*****************************************************************************
        // Method to get ER Restricted Cases Related Allegations
    //****************************************************************************/
    private static Map<Id, ER_Restricted_Case__c> getERrestrictedCases(Set<Id> AllegationIds){
        Map<Id, ER_Restricted_Case__c> erRestrictedCaseMap = new Map<Id, ER_Restricted_Case__c>();
        for(ER_Restricted_Case__c erCase : [SELECT Id,Case__c,Allegation__c,Accused__c,Contact__c,Accused_Email_Search_only__c
                                            FROM ER_Restricted_Case__c
                                            WHERE Allegation__c IN :AllegationIds]){
                             
            erRestrictedCaseMap.put(erCase.Allegation__c, erCase);
        }
        return erRestrictedCaseMap;
    }

    //*****************************************************************************
        // Method to create or update ER Restricted Cases
    //****************************************************************************/
    private static void handleERRestrictedCase(Map<Id, Allegations__c> newMap, Map<Id, Allegations__c> oldMap){
     
        Set<Id> restrictedCaseIds = new Set<Id>();
        Set<Id> ErAllegationIds = new Set<Id>();
        List<Allegations__c> ErAllegationList = new List<Allegations__c>();       
        try{
            for(Allegations__c allegation : newMap.values()){
                if(allegation.RecordTypeId == ER_ALLEGATION_RECORD_TYPE_ID){
                    if(string.isNotBlank(allegation.Accused__c) && 
                        (oldMap == null || (oldMap <> null && oldMap.get(allegation.Id).Accused__c <> allegation.Accused__c) ||string.isBlank(allegation.Case__r.Accused_Email_Search_only__c) ))
                    {
                        ErAllegationList.add(allegation);
                        ErAllegationIds.add(allegation.Id);
                    
                    }
                }
            }    

            if (!ErAllegationList.isEmpty()){
			
                Map<Id, Allegations__c> allegationToRestrictedCaseMap = getAllegationInfo(ErAllegationIds);//To Get the Case Field Info
                Map<Id, ER_Restricted_Case__c> erRestrictedCaseMap = getERrestrictedCases(ErAllegationIds); // To check existing ER Restricted Case for an Allegation.
                List<ER_Restricted_Case__c> restrictedCaseList = getERRestrictedCaseList(ErAllegationList, allegationToRestrictedCaseMap, erRestrictedCaseMap);
                //Update Accused Name on Case
                handleToUpdateCaseWithAccused(ErAllegationList);
                //Operation On ER Restricted Case 
                if(!restrictedCaseList.isEmpty()){
                    Database.UpsertResult[] restrictedCaseListUpsert = Database.Upsert(restrictedCaseList,false);
                    for (Database.UpsertResult sr : restrictedCaseListUpsert){
                         if(sr.isSuccess()){
                             restrictedCaseIds.add(sr.getId());
                         }
                    }
                } 
            }
        }  
        catch (Exception ex){
           PF_Logger.log('DJC','ERROR',ex.getMessage(),' Error during ER Restricted Case Creation ',' UserId '+ UserInfo.getUserId(), 'AllegationTriggerHandler');
        }
        finally{
            NHW_Util.insertNHWLogs();  
        }
    }

 private static void handleToUpdateCaseWithAccused(List<Allegations__c> alegationList){
        
        Map<Id, Set<String>> accusedMap = new Map<Id, Set<String>>();
        Map<Id, Set<String>> accusedEmailMap = new Map<Id, Set<String>>();
        List<Case> accusedCaseList = new List<Case>();
        set<Id> caseIds = new set<Id>();
        try{
        for(Allegations__c allegation: alegationList){
            if(string.isNotBlank(allegation.Case__c)){
                caseIds.add(allegation.Case__c);
            }
        }
        if(!caseIds.isEmpty()){
            for(Allegations__c allegation: [SELECT Id, Name, Case__c, Accused__c, Accused__r.Name,Accused__r.Email  
                                            FROM Allegations__c 
                                            WHERE Case__c IN: caseIds AND Accused__c != Null])
            {
                if(!accusedMap.containsKey(allegation.Case__c) && !accusedEmailMap.containsKey(allegation.Case__c)){
                    accusedMap.put(allegation.Case__c, new Set<String>());
                    accusedEmailMap.put(allegation.Case__c, new Set<String>());
                  }
                accusedMap.get(allegation.Case__c).add(allegation.Accused__r.Name);
                accusedEmailMap.get(allegation.Case__c).add(allegation.Accused__r.Email);   
            }
            for(Id caseId: caseIds){
                if(!accusedMap.isEmpty() && accusedMap.containsKey(caseId) && !accusedEmailMap.isEmpty() && accusedEmailMap.containsKey(caseId)){
                    string accusedNames = string.join(new List<String>(accusedMap.get(caseId)),',');
                    string accusedEmails = string.join(new List<String>(accusedEmailMap.get(caseId)),',');
                    accusedCaseList.add(new Case(Id=caseId, Accused_Search_only__c = accusedNames,Accused_Email_Search_only__c =accusedEmails));
                }else{
                     accusedCaseList.add(new Case(Id=caseId, Accused_Search_only__c = '',Accused_Email_Search_only__c ='' ));
                   
                }
            }
        }
        if(!accusedCaseList.isEmpty()){
            Database.SaveResult[] caseResult = Database.update(accusedCaseList, false);
            for(Database.SaveResult res : caseResult){
                if(!res.isSuccess()){
                    String errorMsg = '';
                    for(Database.Error err : res.getErrors()){
                        errorMsg += err.getMessage() +  '\n' ;
                    }
                }
            }
        }
        }  
        catch (Exception ex){
           PF_Logger.log('SCC_ER_Search','ERROR',ex.getMessage(),' Error during Case Updation ',' UserId '+ UserInfo.getUserId(), 'AllegationTriggerHandler');
        }
        finally{
            NHW_Util.insertNHWLogs();  
        }
    }
    private static void handelDeleteERCases(List<Allegations__c> oldList){
        Set<Id> erAllegationIds = new Set<Id>();
        for(Allegations__c allegation: oldList){
            if(allegation.RecordTypeId == ER_ALLEGATION_RECORD_TYPE_ID){
                if(string.isNotBlank(allegation.Accused__c)){
                    erAllegationIds.add(allegation.Id);
                }
            }
        }
        if(!erAllegationIds.isEmpty()){
            erRestrictedCaseDetailMap = getERrestrictedCases(ErAllegationIds);
            
        }        
    }

    private static void deleteERRestrictedCase(List<Allegations__c> oldList){
        Set<Id> erAllegationIds = new Set<Id>();
        List<Allegations__c> erAllegationList = new List<Allegations__c>();

        for(Allegations__c allegation: oldList){
            if(allegation.RecordTypeId == ER_ALLEGATION_RECORD_TYPE_ID){
                if(string.isNotBlank(allegation.Accused__c)){
                    erAllegationList.add(allegation);
                    erAllegationIds.add(allegation.Id);
                }
            }
        }
        try{
            if(!erAllegationList.isEmpty()){
                //Handle to Update the Accused Name
                handleToUpdateCaseWithAccused(erAllegationList);
                List<ER_Restricted_Case__c> erRestrictedList = getERRestrictedCaseDelList(erAllegationList, erRestrictedCaseDetailMap);
                if(!erRestrictedList.isEmpty()){
                    delete erRestrictedList;
                }
            }
        }catch (Exception ex){
           PF_Logger.log('DJC','ERROR',ex.getMessage(),' Error during ER Restricted Case Delete ',' UserId '+ UserInfo.getUserId(), 'AllegationTriggerHandler');
        }
        finally{
            NHW_Util.insertNHWLogs();  
        }
        
    }

    //List will use for updating the ER Cases when changes on Allegation.
    private static List<ER_Restricted_Case__c> getERRestrictedCaseList(List<Allegations__c> ErAllegationList, 
                                                                          Map<Id, Allegations__c> allegationToRestrictedCaseMap,
                                                                          Map<Id, ER_Restricted_Case__c> erRestrictedCaseMap)
    {
        List<ER_Restricted_Case__c> restrictedCaseListToInsert = new List<ER_Restricted_Case__c>();
        for(Allegations__c allegation : ErAllegationList){
            if(allegationToRestrictedCaseMap.get(allegation.Id).Case__r.Attorney_client_privilege__c){
                ER_Restricted_Case__c ERRestrictedCaseRec = new ER_Restricted_Case__c();              
                //While Updating the Allegation Record
                if(!erRestrictedCaseMap.isEmpty() && erRestrictedCaseMap.containsKey(allegation.Id)){
                    ERRestrictedCaseRec.Accused__c = allegation.Accused__c;
                    ERRestrictedCaseRec.Id = erRestrictedCaseMap.get(allegation.Id).Id;
                    ERRestrictedCaseRec.Name   = allegationToRestrictedCaseMap.get(allegation.Id).Accused__r.Name+'-'+allegationToRestrictedCaseMap.get(allegation.Id).Case__r.CaseNumber;
                    ERRestrictedCaseRec.Accused_Email_Search_only__c = allegationToRestrictedCaseMap.get(allegation.Id).Accused__r.Email;
                 }
                restrictedCaseListToInsert.add(ERRestrictedCaseRec);
            }                    
        }
        return restrictedCaseListToInsert;
    }
    // Delete set of records
    private static List<ER_Restricted_Case__c> getERRestrictedCaseDelList(List<Allegations__c> erAllegationList, 
                                                                       Map<Id, ER_Restricted_Case__c> erRestrictedCaseMap)
    {
        List<ER_Restricted_Case__c> restrictedCaseListToDel = new List<ER_Restricted_Case__c>();

        for(Allegations__c allegation : erAllegationList){
            if(!erRestrictedCaseMap.isEmpty() && erRestrictedCaseMap.containsKey(allegation.Id)){
                restrictedCaseListToDel.add(erRestrictedCaseMap.get(allegation.Id));
            }
        }

        return restrictedCaseListToDel;
    }
    
    public class ManagementHierarchy{

        public Id MH1{get;set;}

        public Id MH2{get;set;}

        public Id MH3{get;set;}

        public Id MH4{get;set;}

        public Id MH5{get;set;}

        public Id MH6{get;set;}

        public ManagementHierarchy(Id mh1,Id mh2,Id mh3,Id mh4,Id mh5,Id mh6){

            this.MH1 = mh1;

            this.MH2 = mh2;

            this.MH3 = mh3;

            this.MH4 = mh4;

            this.MH5 = mh5;

            this.MH6 = mh6;   

        }

    }
    
}