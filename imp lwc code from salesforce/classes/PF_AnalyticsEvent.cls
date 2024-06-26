public class PF_AnalyticsEvent {
    public String category;
    public String action;
    public String label;
    public String value;
    public PF_AnalyticsEvent(){
        
    }
    public PF_AnalyticsEvent(String category,string Label,String action,String value){
        this.category = category;
        this.label=label;
        this.action=action;
        this.value=value;

    }
    
}