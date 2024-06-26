/**
* #DreamJobCentral
* @date:        10/20/2015
* @description: Controller for ESDJC_ReportRequestPage.
**/
public with sharing class ESDJC_ReportRequestController extends BaseDJCController {

    public string name{get;set;}
    public string email{get;set;}
    public string phone{get;set;}
    public string url{get;set;}
    public string  orgId{get;set;}
    public boolean showThanks{get;set;}
    public String web2CaseURL{get;set;}

    public static final String DEFAULT_ERROR_MESSAGE = 'Value is required';
    
    private static final String INVALID_DATE_MESSAGE = 'Please select a future date';
    
    public ESDJC_ReportRequestController controller{get{return this;}}

    public ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();

    public List<SelectOption> yesNoOptions{
        get{
            if(yesNoOptions == null){
                yesNoOptions = new List<SelectOption>();
                yesNoOptions.add(new SelectOption('true','Yes'));
                yesNoOptions.add(new SelectOption('false','No'));
            }
            return yesNoOptions;
        }
        set;
    }

    public ESDJC_ReportRequestController(){
        orgId =  UserInfo.getOrganizationId();
        contact userContact;
        url = ESDJC_Util.getSSOURL();

        newCase.Type = 'ES Data Request';
        newCase.Origin = 'Employee Success - Web';
        newCase.Tier__c = 'Tier 1';
        
        headermsg = Label.ES_DJC_ReportRequest_ReportRequest;
    }

    public override string getRecordType(){

        String recordType;
        if (division != null){          
            if (settings!= null){
                if (division == 'AmerHQ'){
                    recordType = settings.All_Cases_Except_ER_AMER_RT__c;
                }else if (division == 'AmerNonHQ'){
                    recordType = settings.All_Cases_Except_ER_AMER_RT__c;
                }else if (division == 'APAC'){
                    recordType = settings.All_Cases_Except_ER_APAC_RT__c;
                }else if (division == 'EMEA'){
                    recordType = settings.All_Cases_Except_ER_EMEA_RT__c;
                }else if (division == 'Japan'){
                    recordType = settings.All_Cases_Except_ER_Japan_RT__c;
                }
            }
        }
        else{
            recordType = settings.All_Cases_Except_ER_AMER_RT__c;
        }
        return recordType;
    }

    public PageReference saveCase(){

        if(!validateForm()){
            return null;
        }
        
        if(!isBlank(newCase.ES_DJC_Report_Request_Frequency_Other__c)){
            newCase.Description = 'Frequency: ' + newCase.ES_DJC_Report_Request_Frequency_Other__c + '.  ' + (isBlank(newCase.Description) ? '' : newCase.Description);
        }
        
        if(!isBlank(newCase.ES_DJC_Report_Request_Type_Other__c)){
            newCase.Description = 'Topic: ' + newCase.ES_DJC_Report_Request_Type_Other__c + '.  ' + (isBlank(newCase.Description) ? '' : newCase.Description);
        }
        
        saveCaseRecord();

        String url = ApexPages.CurrentPage().getUrl();
        PageReference p = new PageReference(url + '&thanks=true');
        p.setRedirect(true);
        return p;
    }

    private Boolean validateForm(){
        Boolean validForm = true;
        if(newCase.ES_DJC_Report_Request_Due_Date__c <= Date.today()){
            newCase.ES_DJC_Report_Request_Due_Date__c.addError(INVALID_DATE_MESSAGE);
            newCase.ES_DJC_Report_Request_Due_Date__c = null;
            validForm = false;
        }
        return validForm;
    }
}