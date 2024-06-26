public with sharing class NHW_BUCCJobProfileCategoryMatcher implements NHW_CategoryMatcher {
        
    //This matcher checks for BU,CC,JobProfile triad Combo  which includes combinations with non-null Job Profiles only.
    //The rationale here is - for BU/CC combinations which do not have job profile , the simple NHW_BUCCCategoryMatcher matcher WILL be used.
    //Update after story W-9631247 -
        //Job title can have * at the beginning or the end, which implies partial match is allowed
        //logic is broken down into 2 parts -
        //Part 1 = query NH_BU_CC_Profile__c records based on BU and CC values
        //Part 2 = run job title match logic on each of the retrieved record to see if profile criteria is satisfied or not
    public List<NH_Profile__c> matchProfiles(Case provisioningCase, List<NH_Profile__c> profiles){
        
        Map<Id,NH_Profile__c> profilesMap = new Map<Id,NH_Profile__c>(profiles);
        List<NH_Profile__c> profilesMatched = new List<NH_Profile__c>();
        Set<Id> profileMatchedIds = new Set<Id>();
        //Aggregate function is not useful in this case. So using query of NH_BU_CC_Profile__c records
        List<NH_BU_CC_Profile__c> partialMatches = [SELECT NH_Profile__c,Job_Title__c,Business_Unit__c,Cost_Center__c FROM NH_BU_CC_Profile__c WHERE (
                                                    //BU/CC/JobProfile COMBO
                                                    //BU and CC should be exact match. We will run Job Title criteria check later on these records
                                                    (Business_Unit__c!= null AND Cost_Center__c != null AND Job_Title__c != null  
                                                    AND Business_Unit__c = :provisioningCase.NHW_Business_Unit__c AND Cost_Center__c = :provisioningCase.NHW_Cost_Center__c)
                                                    //Just Job Title
                                                    //records where BU=null, CC=null and Job title!=null. Will run job title crietria check later on these records
                                                    OR (Job_Title__c != null AND Business_Unit__c = null AND Cost_Center__c = null)
                                                    //Job Title/CC
                                                    //records where BU=null, CC is exact match and job title !=null. Will run job title crietria check later on these records
                                                    OR (Job_Title__c != null AND Business_Unit__c = null AND Cost_Center__c != null AND Cost_Center__c = :provisioningCase.NHW_Cost_Center__c )
                                                    //Job Title/BU
                                                    //records where CC=null, BU is exact match, Job title !=null. Will run job title criteria check later on these records.
                                                    OR (Job_Title__c != null AND Business_Unit__c != null AND Cost_Center__c = null AND Business_Unit__c = :provisioningCase.NHW_Business_Unit__c)
                                                    )
                                                    AND NH_Profile__c IN :profilesMap.keySet()];
        
        for(NH_BU_CC_Profile__c result:partialMatches){
            if(profileMatchedIds.contains(result.NH_Profile__c)){
                //if NH profile listed on current NH_BU_CC_Profile__c record was already considered "matched" through some other records in previous iteration, it is pointless to evaluate it for current record also
                continue;
            }
            String currentJobTitle = result.Job_Title__c;
            //run the job title criteria check and add it to profilesMatched if it matches
            Boolean jobTitleCriteriaSatisfied = matchJobTitle(currentJobTitle,provisioningCase);
            if(jobTitleCriteriaSatisfied){
                profileMatchedIds.add(result.NH_Profile__c);
            }
        }
        //all the NH profiles that are matched, their IDs are in set profileMatchedIds. We need to return List of NH_Profile__c records
        for(Id currentProfileId : profileMatchedIds){
            profilesMatched.add(profilesMap.get(currentProfileId));
        }
        
        return profilesMatched;
    }

    /*
    * Method which determines if Job title on NH BU CC Profile record matches with Case.Business_Title__c
    * If Job title has * in begining or end, then it is considered to be a substring of Case.Business_Title__c to qualify as a match
    * If Job title has no * in begining or end, then we check for exact match with Case.Busiess_Title__c
    */
    private Boolean matchJobTitle(String jobTitle, Case provisioningCase){
        String caseBusinessTitle = provisioningCase.Business_Title__c;
        //basic null check on case field
        if(String.isBlank(caseBusinessTitle)){
            return FALSE;
        }
        if(jobTitle == '*'){
            return TRUE;
        }
        if((jobTitle.startsWith('*')) || (jobtitle.endsWith('*'))){
            String jobTitleWithoutAsterisk = (jobTitle.removeStart('*')).removeEnd('*');
            //basic null check on Job title on NHBUCCProfile record after removing asterisk
            if(String.isBlank(jobTitleWithoutAsterisk)){
                return FALSE;
            }
            //now check if job title on NHBUCCProfile is a subset of Business title on case
            if(caseBusinessTitle.containsIgnoreCase(jobTitleWithoutAsterisk)){
                return TRUE;
            }else{
                return FALSE;
            }
        }else{
            //job title should be an exact match
            if(caseBusinessTitle.equalsIgnoreCase(jobTitle)){
                return TRUE;
            }else{
                return FALSE;
            }
        }
    }
    
}