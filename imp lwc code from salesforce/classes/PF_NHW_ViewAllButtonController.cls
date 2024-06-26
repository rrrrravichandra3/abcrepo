/*
* @Author : Satyam Kumar
* Controller for lightning component PF_NHW_Page_ViewAll_Button
* It checks visibility of View All button of NHW Past Submission page.
*/
public with sharing class PF_NHW_ViewAllButtonController {
    private static String GENERAL_EXCEPTION_MESSAGE = 'Internal System Error';
    
    //Checks visibility of View All button of NHW Past Submission page based on Show_View_All_Button__c field of NHW_Settings__c custom setting.
    @AuraEnabled
    public static Boolean getButtonVisibility() {
        
        Try {
            
            return (Boolean)NH_Settings__c.getInstance().Show_View_All_Button__c;
            
        } catch(Exception ex){
            system.debug('ex'+ex.getMessage()+ex.getLineNumber());
            throw new AuraHandledException(GENERAL_EXCEPTION_MESSAGE);
        }
    }
}