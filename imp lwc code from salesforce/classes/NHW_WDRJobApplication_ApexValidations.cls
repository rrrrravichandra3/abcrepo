@SuppressWarnings(
    'PMD.CognitiveComplexity'
)
public class NHW_WDRJobApplication_ApexValidations {
    
    public class NHW_WDRJobApplication_ApexValidations_Results{
        public Boolean result;
        public String errorMessage;
        
        public NHW_WDRJobApplication_ApexValidations_Results(Boolean result,String errorMessage){
            this.result = result;
            this.errorMessage = errorMessage;
        }
    }
    
    //validation check that replaces the rule NHW_Required_fields_For_Placement
    public static NHW_WDRJobApplication_ApexValidations_Results requiredCandidateFieldsForPlacementCheck(WDR_Application__c currentJobApp, Onboarding_Setting__c settings){
        //False implies validation failed
        Set<String> requiredFieldNames = new Set<String>();
        Set<String> mailingCountryExclusions = new Set<String>();

        if (!String.isBlank(settings.Mailing_Country_to_Exclude_For_NHW__c)) {
            mailingCountryExclusions.addAll(settings.Mailing_Country_to_Exclude_For_NHW__c.split(','));
        }
        
        if(
            currentJobApp.Candidate_Stage__c=='Placement'
            &&
            currentJobApp.Internal_Candidate__c!=TRUE
            &&
            ((!String.isBlank(currentJobApp.Business_Site__c)) && (!String.isBlank(currentJobApp.Business_Site__r.City__c)) && (currentJobApp.Business_Site__r.City__c).contains('Remote'))
            &&
            (!mailingCountryExclusions.contains(currentJobApp.Candidate__r.Mailing_Country__c))) {
                
                if (String.isBlank(currentJobApp.Candidate__r.Mailing_City__c)) {
                    requiredFieldNames.add('Candidate Mailing City');
                }
                if (String.isBlank(currentJobApp.Candidate__r.Mailing_Country__c)) {
                    requiredFieldNames.add('Candidate Mailing Country');
                }
                if (String.isBlank(currentJobApp.Candidate__r.Mailing_Postal_Code__c)) {
                    requiredFieldNames.add('Candidate Mailing Postal Code');
                }
                if (String.isBlank(currentJobApp.Candidate__r.Mailing_Street__c)) {
                    requiredFieldNames.add('Candidate Mailing Street');
                }
            }

            if (requiredFieldNames.isEmpty()) {
                return new NHW_WDRJobApplication_ApexValidations_Results(TRUE, null);
            } else {
                //any criteria of validation rule met, return FALSE to throw error message
                return new NHW_WDRJobApplication_ApexValidations_Results(FALSE, String.join(new List<String>(requiredFieldNames), ', ') + ' are required when job application is moved to Placement');
            }
        
    }
    
    //validation check that replaces the rule NHW_Required_Fields_From_Job_Req
    public static NHW_WDRJobApplication_ApexValidations_Results requiredJobReqFieldsForPlacementCheck(WDR_Application__c currentJobApp, Onboarding_Setting__c settings){
        Set<String> requiredFieldNames = new Set<String>();
        Set<String> jobCreationReasonsExclusionsSet = new Set<String>();
        String jobCreationReasonsExclusions = settings.JobCreationReasons_to_Exclude_For_NHW__c;
        if(!String.isBlank(jobCreationReasonsExclusions)){
            jobCreationReasonsExclusionsSet.addAll(jobCreationReasonsExclusions.split(','));
        }
        
    // ES Next Changes - Commented below to replace Offer type field with Job Req Creation Reason
       /* if(
            ((!String.isBlank(currentJobApp.Offer_Type__c)) && (!offerTypeExclusions.contains(currentJobApp.Offer_Type__c)))
            &&
            (
                (!String.isBlank(currentJobApp.Candidate_Stage__c)) 
                &&
                (((currentJobApp.Candidate_Stage__c).equalsIgnoreCase('Pre-Placement')) || ((currentJobApp.Candidate_Stage__c).equalsIgnoreCase('Placement')))
            )) */

            if(
            ((!String.isBlank(currentJobApp.Job__r.Req_Creation_Reason__c)) && (!jobCreationReasonsExclusionsSet.contains(currentJobApp.Job__r.Req_Creation_Reason__c)))
            &&
            (
                (!String.isBlank(currentJobApp.Candidate_Stage__c))
                &&
                (((currentJobApp.Candidate_Stage__c).equalsIgnoreCase('Pre-Placement')) || ((currentJobApp.Candidate_Stage__c).equalsIgnoreCase('Placement')))
            ))
            {
            if(String.isBlank(currentJobApp.Job__r.Job_Code__c)){
                requiredFieldNames.add('Job Code');
            }
            if(String.isBlank(currentJobApp.Job__r.Employment_Type__c)){
                requiredFieldNames.add('Employement Type');
            }
            if(String.isBlank(currentJobApp.Job__r.Company__c)){
                requiredFieldNames.add('Company');
            }
            if(String.isBlank(currentJobApp.Job__r.Business_Unit__c)){
                requiredFieldNames.add('Business Unit');
            }
            if(String.isBlank(currentJobApp.Job__r.Department__c)){
                requiredFieldNames.add('Department');
            }
            if(String.isBlank(currentJobApp.Job__r.Region__c)){
                requiredFieldNames.add('Region');
            }
            if(String.isBlank(currentJobApp.Job__r.Hiring_Manager__c)){
                requiredFieldNames.add('Hiring Manager');
            }
        }

        if (requiredFieldNames.isEmpty()) {
            return new NHW_WDRJobApplication_ApexValidations_Results(TRUE, null);
        } else {
            if(requiredFieldNames.size() == 1){
                return new NHW_WDRJobApplication_ApexValidations_Results(FALSE,
                        String.join(new List<String>(requiredFieldNames), ', ') + ' is required when job application is moved to Placement');
            }else {
                //any criteria of validation rule met, return FALSE to throw error message
                return new NHW_WDRJobApplication_ApexValidations_Results(FALSE,
                        String.join(new List<String>(requiredFieldNames), ', ') + ' are required when job application is moved to Placement');
            }
        }
    }

    //validation check that replaces the rule Business_Site_Required_For_Placement

    // Before insert context
    public static NHW_WDRJobApplication_ApexValidations_Results requiredBusinessSiteRequiredForPlacementCheck(WDR_Application__c currentJobApp, Boolean isPfExcludeValidationRuleAssigned) {
        if (
            !isPfExcludeValidationRuleAssigned 
            &&
            currentJobApp.Candidate_Stage__c.equalsIgnoreCase('Placement')
            &&
            currentJobApp.Start_Date__c > System.today()
            &&
            String.isBlank(currentJobApp.Business_Site__c)
        ) {
            return new NHW_WDRJobApplication_ApexValidations_Results(FALSE, 'Business Site is a required field.');
        } else {
            return new NHW_WDRJobApplication_ApexValidations_Results(TRUE,null);
        }
    }

    //validation check that replaces the rule Start_Date
    public static NHW_WDRJobApplication_ApexValidations_Results requiredStartDateForPlacementCheck(WDR_Application__c jobAppToUpdate, Boolean isPfExcludeValidationRuleAssigned, String profileName) {
        if (
            (profileName.equalsIgnoreCase('API Vendor - SOA Recruiting') || !isPfExcludeValidationRuleAssigned) 
            &&
            jobAppToUpdate.Candidate_Stage__c.equalsIgnoreCase('Placement')
            &&
            jobAppToUpdate.Start_Date__c == null
        ) {
            return new NHW_WDRJobApplication_ApexValidations_Results(FALSE, 'Please mention start date for new hire.');
        } else {
            return new NHW_WDRJobApplication_ApexValidations_Results(TRUE,null);
        }

    }

}