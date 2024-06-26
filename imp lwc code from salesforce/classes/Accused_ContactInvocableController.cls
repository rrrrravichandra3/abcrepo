/*******
 * Update is happening from process builder it will be running as an admin we need to implement without sharing
******/
public without sharing class Accused_ContactInvocableController {
    @InvocableMethod(label='Contact Email Update' description='Contact Emails update on Case')
    public static void getSynchContactEmailsOnCases(List<ESDJC_Util> invocableResults){
        List<Case> caseRecords = getCaseWithEmails(invocableResults);
        try{
            if(!caseRecords.isEmpty()){
                update caseRecords;
            }
        }catch(exception ex){
           PF_Logger.log('ER Cases','ERROR',ex.getMessage(),ex.getTypeName(), ex.getLineNumber()+' Error while Updating Accused Email Name ' + caseRecords + ' UserId '+ UserInfo.getUserId(), 'Accused_ContactInvocableController');
        }
    }
    private static List<Case> getCaseWithEmails(List<ESDJC_Util> invocableResults){
        Map<Id, Case> caseRecordMap = new Map<Id, Case>();
        Map<Id, String> currentVersionValues = New Map<Id, String>();
        Map<Id, String> oldVersionValues = New Map<Id, String>();
        
        for(ESDJC_Util invocable: invocableResults){
            currentVersionValues.put(invocable.recordId, 
                                     invocable.currentInputVal<>null && string.isNotBlank(invocable.currentInputVal)?invocable.currentInputVal:'');
            oldVersionValues.put(invocable.recordId, 
                                 invocable.prevInputVal<>null && string.isNotBlank(invocable.prevInputVal)?invocable.prevInputVal:'');
        }
        if(!oldVersionValues.isEmpty()){
            for(Allegations__c alg: [SELECT Id,Name,Accused__c,Case__c,Case__r.Accused_Email_Search_only__c 
                                     FROM Allegations__c 
                                     WHERE Accused__c IN: oldVersionValues.keyset()]){
                if(oldVersionValues.containsKey(alg.Accused__c)){
                    if(!caseRecordMap.containsKey(alg.Case__c)){
                    	Case caseRecord = new Case(Id=alg.Case__c);
                        caseRecord.Accused_Email_Search_only__c = replaceEmails(alg.Case__r.Accused_Email_Search_only__c,
                                                                                currentVersionValues.get(alg.Accused__c),
                                                                                oldVersionValues.get(alg.Accused__c));
                        caseRecordMap.put(caseRecord.Id, caseRecord);
                    }else{
                        Case caseRecord = caseRecordMap.get(alg.Case__c);
                        caseRecord.Accused_Email_Search_only__c = replaceEmails(alg.Case__r.Accused_Email_Search_only__c,
                                                                                currentVersionValues.get(alg.Accused__c),
                                                                                oldVersionValues.get(alg.Accused__c));
                        caseRecordMap.put(caseRecord.Id, caseRecord);
                    }                       
                }
            }
        }
        return caseRecordMap.values();
    }
    private static string replaceEmails(string orginalEmail, string currentContactEmail, string previousEmail){
        string accusedEmail = '';
        if(string.isNotBlank(orginalEmail)){
            accusedEmail = string.isBlank(previousEmail)?orginalEmail+','+currentContactEmail:orginalEmail.replace(previousEmail, currentContactEmail);
        }
        return accusedEmail;            
    }
}