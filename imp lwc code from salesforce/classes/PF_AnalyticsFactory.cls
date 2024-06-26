public without sharing class PF_AnalyticsFactory {
    
    public static PF_AnalyticsInterface getPFAnalyticsImpl(){
        //If MDT active - spawn respective handler class.
        List<PF_Analytics_Mechanism__mdt> PF_AnalyticsMechanisms = [select developername from PF_Analytics_Mechanism__mdt  
                                                                    where Active__c = true];
        //Fallback to debug log if mechanism MDT is not configured properly.
        if(PF_AnalyticsMechanisms.size()!=1){
            return new PF_AnalyticsDebugLogImpl();          
        }else{
            if(PF_AnalyticsMechanisms[0].developername.contains('Google')){
                return new PF_AnalyticsGoogleImpl();
            }else {
                return new PF_AnalyticsDebugLogImpl();
            }            
        }
        
    }
}