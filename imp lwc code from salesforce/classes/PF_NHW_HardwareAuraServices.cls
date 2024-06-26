@SuppressWarnings(
    'PMD.CognitiveComplexity'
)
public with sharing class PF_NHW_HardwareAuraServices{
    private static String GENERAL_EXCEPTION_MESSAGE = 'Internal System Error';
    private static String REGULAR_EMPLOYEE = 'Regular Employee';
    
    @AuraEnabled
    public static Map<String, Object> getBSRelatedFieldsInfo(Id businessSiteId,Id provCaseId){
        try{
            //Get global flags for COVID restrictions logic
            Onboarding_Setting__c settings = Onboarding_Setting__c.getInstance(); 
            Boolean globalBSRedirectFlagFTE = (settings.Activate_feature_for_Business_Site_redir__c == True? True: False);
            Boolean globalBSRedirectFlagContractors = (settings.COVID_contractor_delivery_to_BS__c == True? True: False);
            
            Map<String, Object> mBSInfo = new Map<String, Object>();
            system.debug('businessSiteId'+businessSiteId);
            TF2_Business_Site__c BU = [SELECT Id, isReopen__c,Name,City__c ,Country__c , Postal_Code__c , State_Province__c , Street_Address__c 
                                       FROM TF2_Business_Site__c WHERE Id = :businessSiteId];
            Boolean businessSiteReopened = (BU.isReopen__c == True? True : False);
            Case provCase = [select NHW_Employee_Type__c,NHW_Employee__c,NHW_Job_Application__c,NHW_Job_Application__r.Candidate__c
                             from case where id=:provCaseId];

            mBSInfo.put('Name',BU.Name);
            Contact contactOnCase = PF_NHW_ContactStore.getContactById(ProvCase.NHW_Employee__c);
            WDR_Candidate__c wdCandidate = PF_NHW_WDCandidateStore.getWDCandidateById(provCase.NHW_Job_Application__r.Candidate__c);
            
            //FTEs Grab the Candidate Contact
            //International FTEs or remote FTEs - populate Local Contact Info for shipping.
            if(provCase.NHW_Employee_Type__c.containsIgnoreCase(REGULAR_EMPLOYEE)){

                mBSInfo.put('ContactName',contactOnCase.Name);
                mBSInfo.put('Email',contactOnCase.Email);
                //For McLaren - Get Phone from WDR Candidate Record
                if(wdCandidate != null){
                    mBSInfo.put('Phone',wdCandidate.Phone__c);                                           
                }else{
                    mBSInfo.put('Phone',contactOnCase.Phone);                                                                      
                }
            }

            if(provCase.NHW_Employee_Type__c.containsIgnoreCase('Contractor')){
                mBSInfo.put('ContactName',contactOnCase.Name);
                mBSInfo.put('Email',contactOnCase.Secondary_Email__c);
                mBSInfo.put('Phone',contactOnCase.Phone); 
            }
                                  
            //Populate Shipping address for New Hires
            //Logic for when Business Unit is NOT remote. This NON-Remote Sites logic has been modified and now takes into account temporary restrictions due to COVID. See the story W-8437306
            if(!BU.name.containsIgnoreCase('Remote')){
                //if global flag Onboarding_Setting__c.Activate_feature_for_Business_Site_redir__c is false, retain original functionality

                //if global flag Onboarding_Setting__c.Activate_feature_for_Business_Site_redir__c is true
                    //for FTEs, if BS is not open, copy candidate's mailing address, else copy Business site's address
                    //for non-FTEs, if BS is not open, based on global flag Onboarding_Setting__c.COVID_contractor_delivery_to_BS__c, either default to BS address ot leave it blank
                
                //FTE Logic
                if (provCase.NHW_Employee_Type__c.containsIgnoreCase(REGULAR_EMPLOYEE)) {
                    if (globalBSRedirectFlagFTE == false) {
                        mBSInfo.put('City',BU.City__c);
                        mBSInfo.put('Street',BU.Street_Address__c);
                        mBSInfo.put('State',BU.State_Province__c);
                        mBSInfo.put('Country',BU.Country__c);
                        mBSInfo.put('Zipcode',BU.Postal_Code__c);
                        mBSInfo.put('BusinessSiteRedirect', false);
                    } else {
                        mBSInfo.put('BusinessSiteRedirect', true);
                        if (businessSiteReopened == false) {
                            //use candidate's mailing address. This logic encompass copying address from contact record, if WD Candidate record is missing
                            if (wdCandidate != null) {
                                mBSInfo.put('City',wdCandidate.Mailing_City__c);
                                mBSInfo.put('Street',wdCandidate.Mailing_Street__c);
                                mBSInfo.put('State',wdCandidate.Mailing_State__c);
                                mBSInfo.put('Country',wdCandidate.Mailing_Country__c);
                                mBSInfo.put('Zipcode',wdCandidate.Mailing_Postal_Code__c );                        
                            } else {
                                mBSInfo.put('City',contactOnCase.MailingCity);
                                mBSInfo.put('Street',contactOnCase.MailingStreet);
                                mBSInfo.put('State',contactOnCase.MailingState);
                                mBSInfo.put('Country',contactOnCase.MailingCountry);
                                mBSInfo.put('Zipcode',contactOnCase.MailingPostalCode );
                            }
                            mBSInfo.put('BusinessSiteRedirectMessage',System.Label.PF_NHW_Business_Site_Redirect_BS_Is_Closed_FTE_Msg);
                        } else {
                            //use business site's address
                            mBSInfo.put('City',BU.City__c);
                            mBSInfo.put('Street',BU.Street_Address__c);
                            mBSInfo.put('State',BU.State_Province__c);
                            mBSInfo.put('Country',BU.Country__c);
                            mBSInfo.put('Zipcode',BU.Postal_Code__c);
                            mBSInfo.put('BusinessSiteRedirectMessage',System.Label.PF_NHW_Business_Site_Redirect_Global_Redirect_FTE_Msg);
                        }
                    }
                } else {
                //Contractor and Intl Relocation logic
                    if(globalBSRedirectFlagContractors == false) {
                        mBSInfo.put('City',BU.City__c);
                        mBSInfo.put('Street',BU.Street_Address__c);
                        mBSInfo.put('State',BU.State_Province__c);
                        mBSInfo.put('Country',BU.Country__c);
                        mBSInfo.put('Zipcode',BU.Postal_Code__c);
                        mBSInfo.put('BusinessSiteRedirect', false);
                    } else {
                        if (businessSiteReopened == false) {
                            mBSInfo.put('BusinessSiteRedirect', true);
                            mBSInfo.put('City',contactOnCase.MailingCity);
                            mBSInfo.put('Street',contactOnCase.MailingStreet);
                            mBSInfo.put('State',contactOnCase.MailingState);
                            mBSInfo.put('Country',contactOnCase.MailingCountry);
                            mBSInfo.put('Zipcode',contactOnCase.MailingPostalCode );
                            mBSInfo.put('BusinessSiteRedirectMessage', System.Label.PF_NHW_Business_Site_Redirect_BS_Is_Closed_FTE_Msg);
                        } else {
                            mBSInfo.put('BusinessSiteRedirect', false);
                            mBSInfo.put('City',BU.City__c);
                            mBSInfo.put('Street',BU.Street_Address__c);
                            mBSInfo.put('State',BU.State_Province__c);
                            mBSInfo.put('Country',BU.Country__c);
                            mBSInfo.put('Zipcode',BU.Postal_Code__c);
                            mBSInfo.put('BusinessSiteRedirect', false);
                        }
                    }
                }
            } else if(BU.name.containsIgnoreCase('Remote')) {
                mBSInfo.put('BusinessSiteRedirect', true);
                if(provCase.NHW_Employee_Type__c.containsIgnoreCase(REGULAR_EMPLOYEE)){
                    mBSInfo.put('BusinessSiteRedirectMessage', System.Label.PF_NHW_Business_Site_Redirect_BS_Remote_FTE_Msg);
                    //For McLaren Get the Mailing address from candidate contact
                    if(wdCandidate != null){
                        mBSInfo.put('City',wdCandidate.Mailing_City__c);
                        mBSInfo.put('Street',wdCandidate.Mailing_Street__c);
                        mBSInfo.put('State',wdCandidate.Mailing_State__c);
                        mBSInfo.put('Country',wdCandidate.Mailing_Country__c);
                        mBSInfo.put('Zipcode',wdCandidate.Mailing_Postal_Code__c );  
                    }else{
                        mBSInfo.put('City',contactOnCase.MailingCity);
                        mBSInfo.put('Street',contactOnCase.MailingStreet);
                        mBSInfo.put('State',contactOnCase.MailingState);
                        mBSInfo.put('Country',contactOnCase.MailingCountry);
                        mBSInfo.put('Zipcode',contactOnCase.MailingPostalCode );
                    }

                }else{
                    mBSInfo.put('City',contactOnCase.MailingCity);
                    mBSInfo.put('Street',contactOnCase.MailingStreet);
                    mBSInfo.put('State',contactOnCase.MailingState);
                    mBSInfo.put('Country',contactOnCase.MailingCountry);
                    mBSInfo.put('Zipcode',contactOnCase.MailingPostalCode );
                    mBSInfo.put('BusinessSiteRedirectMessage', System.Label.PF_NHW_Business_Site_Redirect_Contractors_Msg);
                }   
            }
            
            system.debug('mBSInfo'+mBSInfo);
            return mBSInfo;
        }catch(Exception ex){
            system.debug('ex'+ex.getMessage()+ex.getLineNumber());
            throw new AuraHandledException(GENERAL_EXCEPTION_MESSAGE);
        }
        
    }
    
}