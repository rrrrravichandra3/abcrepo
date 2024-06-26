public with sharing class ContactUtil {
    
    
    public static String currentUserName = Userinfo.getName();
    
    //When an application is created with a salesforce.com Referral_Email or Referral_Name, a referral record will be created
    public static void createReferral(Map <Id, ts2__Application__c> applicationMap, 
                                        List<Contact> contacts,
                                        Set <String> referrerEmailSet,
                                        Set <String> referrerNameSet,
                                        Map <String, Contact> candidatesById) {
        
    }
    
    //Just a simple sanity check for salesforce.com address
    public static boolean isSalesforceEmail(String email) {
        if(email != null && email.trim().length() > 0){
            return email.toLowerCase().indexOf('@salesforce.com') > 0;
        }
        return false;
    }
    

    
    public static void createReferralFromContacts(List<Contact> contactsWithReferrer) {

    }
    /*
    * Method parseEmailAddress added for Story W-3756290 May A 2017 release
    * Replaces domain with @salesforce.com
    */
    public static String parseEmailAddress(String actualEmail){
        if(String.isBlank(actualEmail)){
            return actualEmail;
        }else{
            String domainName = '@salesforce.com';
            String modifiedEmail = actualEmail;
            if(!actualEmail.containsAny('@')){
                modifiedEmail = actualEmail + domainName;
            }else{
                modifiedEmail = actualEmail.SubString(0,actualEmail.lastIndexOf('@')) + domainName;
            }
            return modifiedEmail;
        }
    }

    /*
        Update the offer values from the candidate records. This is needed since the frmula fields are  maxed out
    */
    public static void updateOffersWithCandidateValues(List<Contact> contactsWithUpdatedChecks, boolean isCandidateSourceChanged) {

   }
   
    /* This is to back fill the employee Id into Interview feedback object for the sharing rule to work */
    public static void UpdateInterviewFeedbackSharing(Map<Id, String> EIDMap ){
        List<Interview_Feedback__c> IFLists = [select Id, Internal_Employee__c, Candidate__c from Interview_Feedback__c where Candidate__c in : EIDMap.keyset() ];

        for ( Interview_Feedback__c ifList : IFLists  ){
            
            if ( EIDMap.get( ifList.Candidate__c ) != null )
                ifList.Internal_Employee__c = true;
            else
                ifList.Internal_Employee__c = false;
        }
        
        update IFLists;
    }
    
    
    /*Method to add candidate source as "Recruiter Resume Upload" when ever a condidate is created manually by the recruiter. If the currentuser
    *is Internal Site Guest User or Job Site Guest User it does not do any thing.
    *@paran contactList: list of candidate contacts
    *return: none 
    */
    public static void populateCandidateSourceForAddResume(List<Contact> contactList){
        if(currentUserName==null){
            return;
        }
        if(currentUserName.contains('Site Guest User')){
            return;
        }
    }
    
    public class ApplicationInfo {

    }
public static void VerifyAndUpdate(Map<Id,Contact> newTriggerMap){

}

public static void VerifyAndUpdate(Map<Id,Contact> newTriggerMap, Map<Id,Contact> oldTriggerMap){

}

	public static String SanitizeNameFromDigit ( String UserInput ){
		
		return UserInput.replaceAll('\\d', '') != '' ? UserInput.replaceAll('\\d', '') : 'Invalid';
	
	}
}