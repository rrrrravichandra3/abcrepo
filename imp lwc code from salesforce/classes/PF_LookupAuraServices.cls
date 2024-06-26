public without sharing class PF_LookupAuraServices {
    
    private static Map<String, PF_LookupId> lookupIds;
    
    static {
        lookupIds = new Map<String, PF_LookupId>();
        for(PF_LookupId lookupId : PF_LookupId.values()){
            lookupIds.put(lookupId.name(), lookupId);
        }
    }
    
    @AuraEnabled
    /** app parameter: SCC or NHW */
    public static List<PF_AuraLookupOption> getOptions(String lookupId, String searchText, String app, Map<String,String> additionalInfo){
        
        PF_LookupAuraProvider provider = getProviderByApp(app);
        PF_LookupId lId = lookupIds.get(lookupId);
        
        searchText = searchText.trim();

        if(searchText.startsWith('*')){
            searchText = searchText.substring(1);
        }
        
        if(searchText.endsWith('*')){
            searchText = searchText.substring(0, searchText.length() - 1);
        }

        searchText = searchText.trim();

        if(provider != null && lId != null){
            return provider.getOptions(lId, searchText, additionalInfo);
        }
        
        return null;
    }
    
    @AuraEnabled
    /** app parameter: SCC or NHW */
    public static PF_AuraLookupOption getOption(String lookupId, String optionId, String app, Map<String,String> additionalInfo){
        
        PF_LookupAuraProvider provider = getProviderByApp(app);
        PF_LookupId lId = lookupIds.get(lookupId);
        
        if(provider != null && lId != null){
            return provider.getOption(lId, optionId, additionalInfo);
        }
        
        return null;
    }
    
    private static PF_LookupAuraProvider getProviderByApp(String app){
        if(app == 'NHW'){
            return (PF_LookupAuraProvider)Type.forName('PF_NHW_LookupProvider').newInstance();
        }else if(app == 'SCC'){
            return (PF_LookupAuraProvider)Type.forName('PF_ServiceCloudConsoleLookupProvider').newInstance();
        }else if(app == 'SIFT'){
            return (PF_LookupAuraProvider)Type.forName('PF_SIFT_LookupProvider').newInstance();
        }
        return null;
    }
}