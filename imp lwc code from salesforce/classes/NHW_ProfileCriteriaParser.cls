@SuppressWarnings(
    'PMD.CognitiveComplexity'
)
public with sharing class NHW_ProfileCriteriaParser {
    
    public static boolean evaluateProfileCriteria(Case provisioningCase,NHW_Lightning_Component_Configuration__c  compConfig){
        Set<String> profilesNames = new Set<String>();
        
        //Get set of profiles names from comp Config         
        String profileCriteria = compConfig.Profile_Criteria__c;
        Boolean inclusive = true;
        
        if(profileCriteria.startsWith('!') && profileCriteria.length() > 1){
            profileCriteria = profileCriteria.substring(1);
            inclusive = false;
        }
        
        profilesNames.addAll(profileCriteria.split(';'));
        
        //Query profiles by Id
        List<NH_Profile__c> profiles = [SELECT Id, Name, Grouping_Category__c FROM NH_Profile__c WHERE Name IN :profilesNames];
        Map<String, List<NH_Profile__c>> profilesByCategory = new Map<String, List<NH_Profile__c>>();
        
        //Organize profiles by Grouping Category, given each category is matched differently
        for(NH_Profile__c profile:profiles){
            if(!profilesByCategory.containsKey(profile.Grouping_Category__c)){
                profilesByCategory.put(profile.Grouping_Category__c, new List<NH_Profile__c>());
            }
            profilesByCategory.get(profile.Grouping_Category__c).add(profile);
        }  
        //Match profiles depending on the category
        profiles = new List<NH_Profile__c>();
        for(String category:profilesByCategory.keySet()){
            NHW_CategoryMatcher matcher = NHW_CategoryMatcherFactory.getCategoryMatcher(category);
            profiles.addAll(matcher.matchProfiles(provisioningCase, profilesByCategory.get(category)));
        }
        
        Set<String> matchedProfilesNames = new Set<String>();
        
        //List of names of profiles that matched with the provisioning case
        for(NH_Profile__c profile:profiles){
            matchedProfilesNames.add(profile.Name);
        }
        //For each provisioning determine if it must be applied or not to the case given its profile criteria        
        
        
        //If '!' is appended at the beginning of profile criteria, it means it's an exclusive condition
        if(profileCriteria.startsWith('!')){
            if(profileCriteria.length() > 1){
                profileCriteria = profileCriteria.substring(1);
            }
            inclusive = false;
        }
        
        //Go over the list of profile names in provisioning's profile criteria and determine if there is any included
        //into the list of matched profiles
        
        Boolean profileFound = false;
        for(String profileName : profilesNames){
            if(matchedProfilesNames.contains(profileName)){
                profileFound = true;
                break;
            }
        }
        
        //If profile criteria condition is inclusive and any of the profiles listed there matches the provisioning case,
        //or if the profile criteria condition is exclusive and no profile listed there matches the provisioning case then the
        //comp config should be true 
        if((inclusive && profileFound) || (!inclusive && !profileFound)){
            return true;
        }
        
        return false;
        
    }
    
    
    
    public static List<NHW_Provisioning__c> parseProvisionings(Case provisioningCase, List<NHW_Provisioning__c> provisionings){
        
        List<NHW_Provisioning__c> matchedProvisionings = new List<NHW_Provisioning__c>();
        Set<String> profilesNames = new Set<String>();
        
        //Get set of profiles names in provisionings list
        for(NHW_Provisioning__c provisioning:provisionings){
            
            String profileCriteria = provisioning.Profile_Criteria__c;
            
            if(profileCriteria.startsWith('!') && profileCriteria.length() > 1){
                profileCriteria = profileCriteria.substring(1);
            }
            
            profilesNames.addAll(profileCriteria.split(';'));
        }
        
        //Query profiles by Id
        List<NH_Profile__c> profiles = [SELECT Id, Name, Grouping_Category__c FROM NH_Profile__c WHERE Name IN :profilesNames];
        Map<String, List<NH_Profile__c>> profilesByCategory = new Map<String, List<NH_Profile__c>>();
        
        //Organize profiles by Grouping Category, given each category is matched differently
        for(NH_Profile__c profile:profiles){
            if(!profilesByCategory.containsKey(profile.Grouping_Category__c)){
                profilesByCategory.put(profile.Grouping_Category__c, new List<NH_Profile__c>());
            }
            profilesByCategory.get(profile.Grouping_Category__c).add(profile);
        }
        
        //Match profiles depending on the category
        profiles = new List<NH_Profile__c>();
        for(String category:profilesByCategory.keySet()){
            NHW_CategoryMatcher matcher = NHW_CategoryMatcherFactory.getCategoryMatcher(category);
            profiles.addAll(matcher.matchProfiles(provisioningCase, profilesByCategory.get(category)));
        }
        
        Set<String> matchedProfilesNames = new Set<String>();
        
        //List of names of profiles that matched with the provisioning case
        for(NH_Profile__c profile:profiles){
            matchedProfilesNames.add(profile.Name);
        }
        
        //For each provisioning determine if it must be applied or not to the case given its profile criteria        
        for(NHW_Provisioning__c provisioning:provisionings){
            
            String profileCriteria = provisioning.Profile_Criteria__c;
            Boolean inclusive = true;
            
            //If '!' is appended at the beginning of profile criteria, it means it's an exclusive condition
            if(profileCriteria.startsWith('!')){
                if(profileCriteria.length() > 1){
                    profileCriteria = profileCriteria.substring(1);
                }
                inclusive = false;
            }
            
            //Go over the list of profile names in provisioning's profile criteria and determine if there is any included
            //into the list of matched profiles
            List<String> provisioningProfilesNames = profileCriteria.split(';');
            
            Boolean profileFound = false;
            for(String profileName : provisioningProfilesNames){
                if(matchedProfilesNames.contains(profileName)){
                    profileFound = true;
                    break;
                }
            }
            
            //If profile criteria condition is inclusive and any of the profiles listed there matches the provisioning case,
            //or if the profile criteria condition is exclusive and no profile listed there matches the provisioning case then the
            //provisioning is added to the list of matched provisionings
            if((inclusive && profileFound) || (!inclusive && !profileFound)){
                matchedProvisionings.add(provisioning);
            }
        }
        
        return matchedProvisionings;
    }   
}