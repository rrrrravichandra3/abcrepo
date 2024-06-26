public with sharing class NHWSendToSupportforceController {
	private final Case cse;
    public boolean successfullyTransfered{get; set;}
    public boolean disbleTransferButton{get; set;}
    public Map<Id,String> caseRecordTypesMap{
    	get{
    		if(caseRecordTypesMap == null){
	    		caseRecordTypesMap = new Map<Id, String>();
	    		Map<String, Schema.RecordTypeInfo> caseRecordTypes = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
	    		for(Schema.RecordTypeInfo rcrdTypeInfo : caseRecordTypes.values()){
	    			caseRecordTypesMap.put(rcrdTypeInfo.getRecordTypeId(), rcrdTypeInfo.getName());
	    		}
	    	}
	    	return caseRecordTypesMap;
    	}
    	set;
    }
    public NHWSendToSupportforceController(ApexPages.StandardController stdController) {
        this.cse = (Case)stdController.getRecord();
        if(this.cse.Id == null){
        	disbleTransferButton = true;
        	ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'id parameter with case record id is required.');
         	ApexPages.addMessage(errorMessage);
         	disbleTransferButton = true;
        }
        if(!caseRecordTypesMap.get(cse.RecordTypeId).contains('New Hire Process')){
        	ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,caseRecordTypesMap.get(cse.RecordTypeId) +' record Type is not eligible to transfer here.');
         	ApexPages.addMessage(errorMessage);
         	disbleTransferButton = true;
        }
         
    }

    public PageReference callJitterbitApi(){
    	disbleTransferButton = true;
        String reponse = NHWCaseTriggerHandler.jitterbitApiCallUtil(new List<Id>{cse.Id});
        if(reponse == '') {
            successfullyTransfered = true;
            ApexPages.Message successMessage = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Case is successfully transfered to Supportforce.');
            ApexPages.addMessage(successMessage);
        }else{
            successfullyTransfered = false;
            ApexPages.Message successMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'Case transfer to Supportforce failed with message : '+ reponse);
            ApexPages.addMessage(successMessage);
        } 
        disbleTransferButton = false;
        return null;
    }

    public PageReference sendCaseToSf() {
        NH_Settings__c settings = NH_Settings__c.getInstance();
        String reponse;
        if(settings.Disable_Jitterbit_Service_Button__c) {
            reponse = NHWSendCaseToSupportforce.sendCasesToSf(new List<Id>{cse.Id});
        } else {
            reponse = NHWCaseTriggerHandler.jitterbitApiCallUtil(new List<Id>{cse.Id});
        }
        if(reponse == 'success' || reponse == '') {
            successfullyTransfered = true;
            ApexPages.Message successMessage = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Case is successfully transfered to Supportforce.');
            ApexPages.addMessage(successMessage);
        }else{
            successfullyTransfered = false;
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'Case transfer to Supportforce failed with message : '+ reponse);
            ApexPages.addMessage(errorMessage);
        } 
        disbleTransferButton = false;
        return null;
    }
}