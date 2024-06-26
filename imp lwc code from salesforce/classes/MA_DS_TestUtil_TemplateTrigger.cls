/**
 * Test utility class for MA_DS_Test_TemplateTrigger class.
 * 
 * Version      Date            Author                  Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         07/12/2023      Chakshu Malhotra        Adds utility methods for MA_DS_Test_TemplateTrigger class.
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
@isTest
public class MA_DS_TestUtil_TemplateTrigger {

    public static void updateTemplates(Set<MA_DS_TestUtil_Templates.Template> maTemplates, MA_DS_TestUtil_Templates.TemplateType maTemplateType) {
        updateTemplates(maTemplates, maTemplateType, null);
    }

    public static void updateTemplates(Set<MA_DS_TestUtil_Templates.Template> maTemplates, MA_DS_TestUtil_Templates.TemplateType maTemplateType, Acquisition_Company__c acqCompany) {
        List<MA_DS_Template__c> templates = new List<MA_DS_Template__c>();

        for(MA_DS_Template__c templateRef : MA_DS_TestUtil_Templates.getTemplates(maTemplates, maTemplateType, acqCompany)) {
            templateRef.MA_DS_Merge_Capable__c = !templateRef.MA_DS_Merge_Capable__c;
            templates.add(templateRef);
        }

        update templates;
    }

    public static void updateBGCTemplates(Set<MA_DS_TestUtil_Templates.BGCTemplate> maBGCTemplates, Acquisition_Company__c acqCompany) {
        List<MA_DS_Template__c> templates = new List<MA_DS_Template__c>();

        for(MA_DS_Template__c templateRef : MA_DS_TestUtil_Templates.getBGCTemplates(maBGCTemplates, acqCompany)) {
            templateRef.MA_DS_Background_Check_Email_Subject__c = templateRef.MA_DS_Background_Check_Email_Subject__c + ' updated!';
            templates.add(templateRef);
        }

        update templates;
    }

    public static void deleteTemplates(Set<MA_DS_TestUtil_Templates.Template> maTemplates, MA_DS_TestUtil_Templates.TemplateType maTemplateType) {
        deleteTemplates(maTemplates, maTemplateType, null);
    }

    public static void deleteTemplates(Set<MA_DS_TestUtil_Templates.Template> maTemplates, MA_DS_TestUtil_Templates.TemplateType maTemplateType, Acquisition_Company__c acqCompany) {
        List<MA_DS_Template__c> templates = MA_DS_TestUtil_Templates.getTemplates(maTemplates, maTemplateType, acqCompany);
        delete templates;
    }

    public static void deleteBGCTemplates(Set<MA_DS_TestUtil_Templates.BGCTemplate> maBGCTemplates, Acquisition_Company__c acqCompany) {
        List<MA_DS_Template__c> templates = MA_DS_TestUtil_Templates.getBGCTemplates(maBGCTemplates, acqCompany);
        delete templates;
    }
}