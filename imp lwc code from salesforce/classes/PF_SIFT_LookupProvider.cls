public class PF_SIFT_LookupProvider implements PF_LookupAuraProvider{

	public List<PF_AuraLookupOption> getOptions(PF_LookupId lookupId, String searchText, Map<String,String> additionalInformation){

        if(lookupId == PF_LookupId.SIFT_GROUP){
            return getSIFTGroups(searchText);
        }
        else if(lookupId == PF_LookupId.SIFT_POSITION){
            return getSIFTPositions(searchText,additionalInformation);
        }
        else if(lookupId == PF_LookupId.SIFT_INTERVIEWTYPE){
            return getSIFTInterviewTypes(searchText,additionalInformation);
        }
        return null;
    }
    
    public PF_AuraLookupOption getOption(PF_LookupId lookupId, String optionId, Map<String,String> additionalInformation){
        
        if(lookupId == PF_LookupId.SIFT_GROUP){
            return getSIFTGroup(optionId);
                }else if(lookupId == PF_LookupId.SIFT_POSITION){
            return getSIFTPosition(optionId);
               }else if(lookupId == PF_LookupId.SIFT_INTERVIEWTYPE){
            return getSIFTInterviewType(optionId);
        }
        return null;
    }

	private List<PF_AuraLookupOption> getSIFTGroups(String searchText){
               
        List<PF_AuraLookupOption> result = new List<PF_AuraLookupOption>();
        
       for(SIFT_Group__c  sg:[SELECT Id, Name FROM SIFT_Group__c  WHERE Name LIKE :getSearchTextFilterStatement(searchText) AND Active__c = true ORDER BY Name]){
            result.add(new PF_AuraLookupOption(sg.Id, sg.Name));
        }
        
        return result; 
    }
     private PF_AuraLookupOption getSIFTGroup(String idObject){
        List<SIFT_Group__c> sg = [SELECT Id, Name FROM SIFT_Group__c WHERE Id = :idObject];
        if(!sg.isEmpty()){
            return new PF_AuraLookupOption(sg[0].Id, sg[0].Name);
        }
        return null;
    }
     private List<PF_AuraLookupOption> getSIFTPositions(String searchText,map<string,string> additionalinfo ){
        List<PF_AuraLookupOption> result = new List<PF_AuraLookupOption>();
        List<SIFT_Position__c> positions = new List<SIFT_Position__c>();
        if(additionalinfo != null && additionalinfo.size()>0){
                 string SiftGroupID = additionalinfo.get('SIFT_GROUP');   
            positions = [SELECT Id, Name FROM SIFT_Position__c  
                                                  WHERE Name LIKE :getSearchTextFilterStatement(searchText) 
                                                  AND Active__c = true 
                                                  AND SIFT_Group__c  = :SiftGroupID
                                                  ORDER BY Name];
            
        }else{
              positions = [SELECT Id, Name FROM SIFT_Position__c  
                                                  WHERE Name LIKE :getSearchTextFilterStatement(searchText) 
                                                  AND Active__c = true 
                                                  ORDER BY Name];          
        }
        
        for(SIFT_Position__c  sp: positions){
            result.add(new PF_AuraLookupOption(sp.Id, sp.Name));
        }
        
        return result;    
    }
        
    private PF_AuraLookupOption getSIFTPosition(String idObject){
        List<SIFT_Position__c> sp = [SELECT Id, Name FROM SIFT_Position__c WHERE Id = :idObject];
        if(!sp.isEmpty()){
            return new PF_AuraLookupOption(sp[0].Id, sp[0].Name);
        }
        return null;
    
    }
    
    private List<PF_AuraLookupOption> getSIFTInterviewTypes(String searchText,map<string,string> additionalInformation){
              
        List<PF_AuraLookupOption> result = new List<PF_AuraLookupOption>();
        List<SIFT_Interview_Type__c> InterviewTypes = new List<SIFT_Interview_Type__c>();
        if(additionalInformation != null && additionalInformation.size()>0){
           string groupId = additionalInformation.get('SIFT_GROUP');
           InterviewTypes =  [SELECT Id, Name FROM SIFT_Interview_Type__c  
                                        WHERE Name LIKE :getSearchTextFilterStatement(searchText) 
                                        AND SIFT_Group__c   =:groupId
                                        AND Active__c = true ORDER BY Name];
        }else{
           InterviewTypes = [SELECT Id, Name FROM SIFT_Interview_Type__c  
                                        WHERE Name LIKE :getSearchTextFilterStatement(searchText) 
                                        AND Active__c = true ORDER BY Name];
        }
        for(SIFT_Interview_Type__c  ST:InterviewTypes){
            result.add(new PF_AuraLookupOption(st.Id, st.Name));
        }
        
        return result;      
    }
        
    private PF_AuraLookupOption getSIFTInterviewType(String idObject){
        List<SIFT_Interview_Type__c> st = [SELECT Id, Name FROM SIFT_Interview_Type__c WHERE Id = :idObject];
        if(!st.isEmpty()){
            return new PF_AuraLookupOption(st[0].Id, st[0].Name);
        }
        return null;
    
    }

    private static String getSearchTextFilterStatement(String searchText){

        searchText = '%' + searchText + '%';
        searchText = searchText.replaceAll('\\*', '%');
        
        return searchText;
    }
}