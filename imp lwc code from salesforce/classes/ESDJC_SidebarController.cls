public with sharing class ESDJC_SidebarController extends BaseDJCController{
    public string getStartURL(){        
        return ESDJC_Util.getSSOURL();        
    }
    
    public String getSiteURL(){    
        return ESDJC_Util.getSiteURL();        
    }  
    
    public boolean showErgo {
        public get {
            if (showErgo == null) {
                if (division.equalsIgnoreCase('AmerHQ') || division.equalsIgnoreCase('AmerNonHQ') || division.equalsIgnoreCase('EMEA')) {
                    showErgo = true;
                } else {
                    showErgo = false;
                }
            }
            return showErgo;
        }        
        private set;
    }

    public boolean showWellness {
        public get {
            if (showWellness == null) {
                Integer wellnessPolicies = [select count()
                                            from DJC_Wellness_Health_Policy__c 
                                            where  DJC_Wellness_Active__c = true
                                            and DJC_Wellness_Policy_Start_Date__c <= today  
                                            and (DJC_Wellness_Policy_End_Date__c = null OR DJC_Wellness_Policy_End_Date__c >= today)
                                            and DJC_Wellness_Country__r.name = :contactCountry
                                           ];
                showWellness = (wellnessPolicies > 0); 
            }
            return showWellness;
        }
        private set;
    }
    
    public override String getRecordType() {
        return null;
    }
    
}