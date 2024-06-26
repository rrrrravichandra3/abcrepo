public class NHW_AccessWrapper {
    public Boolean selected             {get; set;}
    public Boolean isAutoProvisioned    {get; set;}//Controls as to if HM can remove this access or no.
    public NHW_Provisioning__c item     {get; set;}
    //public ts2__Placement__c placeHold  {get; set;}
    public Boolean OpenAirSelected    {get; set;}
    public String org62Holder {get;set;}  //org62 
    public String gusSSTHolder {get;set;} //gus 
    public String sfSSTHolder {get;set;} //supportforce

    
    public NHW_AccessWrapper(NHW_Provisioning__c i) {
        item = i;
        //placeHold = new ts2__Placement__c();
        selected = false;
        OpenAirSelected = false;   
    }
    
    public void removeAccess() {
        if(item.name == 'OpenAir' && selected){
            OpenAirSelected  = false;
        }
        if(item.Name == 'GUS access'){
            gusSSTHolder = null; 
        } else if(item.Name == 'Supportforce'){
            sfSSTHolder = null; 
        } 
        selected = false;
        
    }
}