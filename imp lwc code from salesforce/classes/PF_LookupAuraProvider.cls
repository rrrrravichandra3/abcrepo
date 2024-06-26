public interface PF_LookupAuraProvider {

    List<PF_AuraLookupOption> getOptions(PF_LookupId lookupId, String searchText, Map<String,String> additionalInformation);
    
    PF_AuraLookupOption getOption(PF_LookupId lookupId, String optionId, Map<String,String> additionalInformation);
    
}