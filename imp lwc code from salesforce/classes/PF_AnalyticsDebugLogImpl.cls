public class PF_AnalyticsDebugLogImpl implements PF_AnalyticsInterface{
    
    public void trackEvents(List<PF_AnalyticsEvent> PFevents){
        
        for(PF_AnalyticsEvent event:PFevents){
            PF_Logger.log(Event.category,'INFO',event.label,'EVENT',event.action,Event.category);
        }
        PF_Logger.createLogs(PF_Logger.logs);
    }

}