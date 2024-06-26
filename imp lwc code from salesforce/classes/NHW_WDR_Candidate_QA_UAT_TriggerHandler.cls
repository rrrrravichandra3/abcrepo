@SuppressWarnings(
    'PMD.CognitiveComplexity'
)
public with sharing class NHW_WDR_Candidate_QA_UAT_TriggerHandler implements WDR_CommonTriggerHandler {

    private static final String EMAIL_POSTFIX = '.masking';
	/**
    * @description Interface method for handling before insert method.
    *
    **/
    public void beforeInsert(){
    	if((!URL.getSalesforceBaseUrl().toExternalForm().equalsIgnoreCase('https://dreamjobcentral.my.salesforce.com'))&&(UserInfo.getName().containsIgnoreCase('api'))){
		        for(WDR_Candidate__c candidate : (List<WDR_Candidate__c>) Trigger.New){
		        	if(candidate.Email__c != null && !candidate.Email__c.endsWith(EMAIL_POSTFIX)){
		            	candidate.Email__c = candidate.Email__c != null? candidate.Email__c+EMAIL_POSTFIX: null;
		            }
		        }
		}
    }

    /**
    * @description Interface method for handling after insert method.
    * 
    **/
    public void afterInsert(){
    }

    /**
    * @description Interface method for handling before update method.
    * //Populate do not send and do Validations on preboarding & do not send NHW flags
    **/
    public void beforeUpdate(){
    	if((!URL.getSalesforceBaseUrl().toExternalForm().equalsIgnoreCase('https://dreamjobcentral.my.salesforce.com'))&&(UserInfo.getName().containsIgnoreCase('api'))){
		        for(WDR_Candidate__c candidate : (List<WDR_Candidate__c>) Trigger.New){
		            if(candidate.Email__c != null && !candidate.Email__c.endsWith(EMAIL_POSTFIX)){
		            	candidate.Email__c = candidate.Email__c != null? candidate.Email__c+EMAIL_POSTFIX: null;
		            }
		        }
    	}
    }

    /**
    * @description Interface method for handling after update method.
    *  Based on appropriate transtion of preboarding flag invoke async preboarding create process.
    **/
    public void afterUpdate(){
    }
    /**
    * @description Interface method for handling before delete method.
    *
    **/
    public void beforeDelete(){ 
    }
    
    /**
    * @description Interface method for handling after delete method.
    *
    **/
    public void afterDelete(){
    }

    /**
    * @description Interface method for handling after undelete method.
    *
    **/
    public void afterUnDelete(){
    }
}