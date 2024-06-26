public with sharing abstract class Ergo_Controller extends BaseDJCController{

	private static ESDJC_Settings__c esdjcSettings = ESDJC_Settings__c.getInstance();

    private static REWS_Setting__c rewsSettings = REWS_Setting__c.getInstance();

    public static final Set<String> ERGO_LOCATIONS = new Set<String>(); 

    public static final String DEFAULT_ERROR_MESSAGE = 'Value is required';

	static{
        if(esdjcSettings.Ergo_Locations__c != null){
            for(String s : esdjcSettings.Ergo_Locations__c.split(',', -1)){
                ERGO_LOCATIONS.add(s);
            }
        }
    }

	public override string getRecordType(){
        return rewsSettings.Ergo_Case_Record_Type_AMER__c;
    }

	protected string getRewsRecordType(){
        String recordType;
        if (division != null){          
            if (division == 'AmerHQ'){
                recordType = rewsSettings.REWS_Case_Record_Type_Amer_HQ__c;
            }else if (division == 'AmerNonHQ'){
                recordType = rewsSettings.REWS_Case_Record_Type_Amer_Non_HQ__c;
            }else if (division == 'APAC'){
                recordType = rewsSettings.REWS_Case_Record_Type_APAC__c;
            }else if (division == 'EMEA'){
                recordType = rewsSettings.REWS_Case_Record_Type_EMEA__c;
            }else if (division == 'Japan'){
                recordType = rewsSettings.REWS_Case_Record_Type_Japan__c;
            }
        }
        else recordType = rewsSettings.REWS_Case_Record_Type_Amer_HQ__c; //default to Amer HQ
        
        return recordType;
    }

	public PageReference cancel(){
        PageReference p = ApexPages.CurrentPage();
        p.setRedirect(true);
        return p;
    }
    
    public boolean isErgoPresent{
        get{
            if(isErgoPresent == null){

                isErgoPresent = false;
                if(contactCity != null){
                    for (String location: ERGO_LOCATIONS){
                        if (contactCity.toLowerCase().contains(location)){
                            isErgoPresent = true;
                        }
                    }
                }
            }
            return isErgoPresent;
        }
        private set;
    }
}