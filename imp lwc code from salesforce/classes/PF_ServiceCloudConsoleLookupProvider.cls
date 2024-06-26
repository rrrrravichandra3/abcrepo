public class PF_ServiceCloudConsoleLookupProvider implements PF_LookupAuraProvider{

    public List<PF_AuraLookupOption> getOptions(PF_LookupId lookupId, String searchText, Map<String,String> additionalInformation){
        //No lookup components has been implemented in Service Cloud Console forms yet.
        return null;
    }
    
    public PF_AuraLookupOption getOption(PF_LookupId lookupId, String optionId, Map<String,String> additionalInformation){
        //No lookup components has been implemented in Service Cloud Console forms yet.
        return null;
    }
    
}