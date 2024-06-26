public class PF_AnalyticsGoogleImpl implements PF_AnalyticsInterface{
    
    public void trackEvents(List<PF_AnalyticsEvent> PFevents){
        
        
       String trackingId= getTrackingId();
        
        if(trackingId == null)
        {
            PF_Logger.log(PFevents[0].category,'ERROR','Google Analytics Config mdt not setup correctly.','LOG',
                              'Callout to Google failed.Posting Events as records in PF debug log.',PFevents[0].category);
            postEvtsToPFDebugLog(PFevents) ;
            return;
        }
        
        GoogleAnalyticsService service = new GoogleAnalyticsService(trackingId, true);
        service.debugMode = false;
        system.debug('PFevents'+PFevents);
        // Single event
        List<GoogleAnalyticsEvent> events = new List<GoogleAnalyticsEvent>();
        for(PF_AnalyticsEvent PFevent:PFevents){
            GoogleAnalyticsEvent event = new GoogleAnalyticsEvent();
            event.category = PFevent.category;
            event.action = PFevent.action;
            event.label = PFevent.label;
            event.value = PFevent.value ;            
            events.add(event);
            
        }
        
        List<HttpResponse> responses = service.sendEvents(events);
        
        //If google response is finicky - adding fallback to pf_debug log to capture the lost events.
        
        if(responses.size()>0){
            System.debug('responses: ' + responses[0]);
            if(responses[0].getStatusCode () != 200){
                PF_Logger.log(PFevents[0].category,'ERROR','Callout to Google Analytics failed','LOG',
                              'Callout to Google failed.Posting Events as records in PF debug log.',PFevents[0].category);
                postEvtsToPFDebugLog(PFevents);
                
            }
        }
        
        
        
        
    }
    private void  postEvtsToPFDebugLog(List<PF_AnalyticsEvent> PFevents){
        for(PF_AnalyticsEvent PFevent:PFevents){
            PF_Logger.log(PFevent.category,'INFO',PFevent.label,'EVENT',PFevent.action,PFevent.category);
        }
        PF_Logger.createLogs(PF_Logger.logs);   
    }
    private string getTrackingId(){
                  
        String currentOrg = Url.getOrgDomainUrl().toExternalForm();
        List<Google_Analytics_Config__mdt > GoogleConfig  = [SELECT DomainUrl__c,TrackingId__c 
                                                             FROM Google_Analytics_Config__mdt
                                                             where DomainUrl__c= :currentOrg];
        
        if(GoogleConfig.size()>0){
            return GoogleConfig[0].TrackingId__c;
        }else{
            return null;
        }
    }
    
}