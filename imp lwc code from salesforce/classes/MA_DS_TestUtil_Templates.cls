/**
 * Test Utility class to setup Templates (Master & Acquisition Master type) data.
 * 
 * Version      Date            Author                  Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         02/12/2023      Chakshu Malhotra        Adds utility methods to setup Templates (Master & Acquisition Master type) data.
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
@isTest
public class MA_DS_TestUtil_Templates {
    
    public enum TemplateType {MASTER, ACQUISITION, BACKGROUND_CHECK}

    public enum Template {PIIA_CAL, PIIA_WA, PIIA_IL, PIIA_US_OTHERS, CAL_WORKER_COMP_FORM, CAL_WORKER_COMP_GUIDE, NYC_PREG_EMP_RIGHTS_NOTICE, NYC_PAID_SICK_LEAVE_NOTICE, 
                          SF_FAIR_CHANCE_ORDINANCE, US_HIPAA_NOTICE, US_OFFER_LETTER, PIIA_TL, PIIA_KA, IN_OFFER_LETTER, GL_OBA_FORM, GL_SEC_BEST_PRAC, GL_SIG_ACK_FORM, 
                          GL_COC, GL_EMP_HANDBOOK, GL_RSU_LETTER, MANAGER_SUMMARY}

    public enum BGCTemplate {US_BGC_TEMPLATE, INDIA_BGC_TEMPLATE}

    public static final String TEMPLATE_TYPE_MASTER = Label.MA_DS_Template_Type_Master;
    public static final String TEMPLATE_TYPE_ACQUISITION = Label.MA_DS_Template_Type_Acquisition;
    private static final String TEMPLATE_TYPE_BACKGROUND_CHECK = Label.MA_DS_Template_Type_Background_Check;

    private static final String TEMPLATE_DOC_TYPE_NA = Label.MA_DS_Rule_Sync_Status_NA;
    private static final String TEMPLATE_DOC_TYPE_PACKAGE = Label.MA_DS_Document_Type_Package;
    private static final String TEMPLATE_DOC_TYPE_SUMMARY = Label.MA_DS_Document_Type_Manager_Summary;

    private static Map<TemplateType, String> templateTypeMap {
        get {
            if(templateTypeMap == null) {
                templateTypeMap = new Map<TemplateType, String> {
                    TemplateType.MASTER => TEMPLATE_TYPE_MASTER,
                    TemplateType.ACQUISITION => TEMPLATE_TYPE_ACQUISITION,
                    TemplateType.BACKGROUND_CHECK => TEMPLATE_TYPE_BACKGROUND_CHECK
                };
            }
            return templateTypeMap;
        }set;
    }
    
    private static List<TemplateWrapper> templateWrappers {
        get {
            if(templateWrappers == null) {
                templateWrappers = bgcTemplateTypeWrapperMap.values();
                templateWrappers.addAll(templateTypeWrapperMap.values());
            }
            return templateWrappers;
        }set;
    }

    private static Map<BGCTemplate, TemplateWrapper> bgcTemplateTypeWrapperMap {
        get {
            if(bgcTemplateTypeWrapperMap == null) {
                bgcTemplateTypeWrapperMap = new Map<BGCTemplate, TemplateWrapper>();

                bgcTemplateTypeWrapperMap.put(BGCTemplate.US_BGC_TEMPLATE, new TemplateWrapper(BGCTemplate.US_BGC_TEMPLATE, 'US - Background Check', 'testbgcusa.com', 'United States of America', 'Test US BGC Email Subject', 'Test US BGC Email Body'));
                bgcTemplateTypeWrapperMap.put(BGCTemplate.US_BGC_TEMPLATE, new TemplateWrapper(BGCTemplate.INDIA_BGC_TEMPLATE, 'INDIA - Background Check', 'testbgcindia.com', 'India', 'Test India BGC Email Subject', 'Test India BGC Email Body'));
            }
            return bgcTemplateTypeWrapperMap;
        }set;
    }

    private static Map<Template, TemplateWrapper> templateTypeWrapperMap {
        get {
            if(templateTypeWrapperMap == null) {
                templateTypeWrapperMap = new Map<Template, TemplateWrapper>();

                templateTypeWrapperMap.put(Template.PIIA_CAL, new TemplateWrapper(Template.PIIA_CAL, 'PIIA - US - California', TEMPLATE_DOC_TYPE_PACKAGE, true, 20, false, false, 'United States of America', 'California', null));
                templateTypeWrapperMap.put(Template.PIIA_WA, new TemplateWrapper(Template.PIIA_WA, 'PIIA - US - Washington', TEMPLATE_DOC_TYPE_PACKAGE, true, 20, false, false, 'United States of America', 'Washington', null));
                templateTypeWrapperMap.put(Template.PIIA_IL, new TemplateWrapper(Template.PIIA_IL, 'PIIA - US - Illinois', TEMPLATE_DOC_TYPE_PACKAGE, true, 20, false, false, 'United States of America', 'Illinois', null));
                
                templateTypeWrapperMap.put(Template.PIIA_US_OTHERS, new TemplateWrapper(Template.PIIA_US_OTHERS, 'PIIA - US - Except CA, IL and WA', TEMPLATE_DOC_TYPE_PACKAGE, true, 20, false, false, 'United States of America', null, null));

                templateTypeWrapperMap.put(Template.CAL_WORKER_COMP_FORM, new TemplateWrapper(Template.CAL_WORKER_COMP_FORM, 'California Worker\'s Compensation Form', TEMPLATE_DOC_TYPE_PACKAGE, false, 30, false, true, 'United States of America', 'California', null));
                templateTypeWrapperMap.put(Template.CAL_WORKER_COMP_GUIDE, new TemplateWrapper(Template.CAL_WORKER_COMP_GUIDE, 'California Worker\'s Compensation Guide', TEMPLATE_DOC_TYPE_PACKAGE, false, 40, false, true, 'United States of America', 'California', null));
                
                templateTypeWrapperMap.put(Template.NYC_PREG_EMP_RIGHTS_NOTICE, new TemplateWrapper(Template.NYC_PREG_EMP_RIGHTS_NOTICE, 'New York Pregnancy _ Employment Rights Notice', TEMPLATE_DOC_TYPE_PACKAGE, false, 30, false, true, 'United States of America', 'New York', null));
                templateTypeWrapperMap.put(Template.NYC_PAID_SICK_LEAVE_NOTICE, new TemplateWrapper(Template.NYC_PAID_SICK_LEAVE_NOTICE, 'New York Paid Safe Sick Leave Notice', TEMPLATE_DOC_TYPE_PACKAGE, false, 40, false, true, 'United States of America', 'New York', null));

                templateTypeWrapperMap.put(Template.SF_FAIR_CHANCE_ORDINANCE, new TemplateWrapper(Template.SF_FAIR_CHANCE_ORDINANCE, 'San Francisco Fair Chance Ordinance', TEMPLATE_DOC_TYPE_PACKAGE, false, 50, false, true, 'United States of America', 'California', 'San Francisco'));
                
                templateTypeWrapperMap.put(Template.US_HIPAA_NOTICE, new TemplateWrapper(Template.US_HIPAA_NOTICE, 'US HIPAA Notice', TEMPLATE_DOC_TYPE_PACKAGE, false, 60, false, true, 'United States of America', null, null));

                templateTypeWrapperMap.put(Template.US_OFFER_LETTER, new TemplateWrapper(Template.US_OFFER_LETTER, 'US Offer Letter', TEMPLATE_DOC_TYPE_PACKAGE, true, 10, false, false, 'United States of America', null, null));

                templateTypeWrapperMap.put(Template.PIIA_TL, new TemplateWrapper(Template.PIIA_TL, 'PIIA - IN - Telangana', TEMPLATE_DOC_TYPE_PACKAGE, true, 20, false, false, 'India', 'Telangana', null));
                templateTypeWrapperMap.put(Template.PIIA_KA, new TemplateWrapper(Template.PIIA_KA, 'PIIA - IN - Karnataka', TEMPLATE_DOC_TYPE_PACKAGE, true, 20, false, false, 'India', 'Karnataka', null));
                
                templateTypeWrapperMap.put(Template.IN_OFFER_LETTER, new TemplateWrapper(Template.IN_OFFER_LETTER, 'IN Offer Letter', TEMPLATE_DOC_TYPE_PACKAGE, true, 10, false, false, 'India', null, null));

                templateTypeWrapperMap.put(Template.GL_OBA_FORM, new TemplateWrapper(Template.GL_OBA_FORM, 'Global OBA Form', TEMPLATE_DOC_TYPE_PACKAGE, false, 70, true, true, null, null, null));
                templateTypeWrapperMap.put(Template.GL_SEC_BEST_PRAC, new TemplateWrapper(Template.GL_SEC_BEST_PRAC, 'Global Security Best Practices', TEMPLATE_DOC_TYPE_PACKAGE, false, 80, true, true, null, null, null));
                templateTypeWrapperMap.put(Template.GL_SIG_ACK_FORM, new TemplateWrapper(Template.GL_SIG_ACK_FORM, 'Global Signature Acknowledgement Form', TEMPLATE_DOC_TYPE_PACKAGE, false, 90, true, true, null, null, null));
                templateTypeWrapperMap.put(Template.GL_COC, new TemplateWrapper(Template.GL_COC, 'Global Code of Conduct', TEMPLATE_DOC_TYPE_PACKAGE, false, 100, true, true, null, null, null));
                templateTypeWrapperMap.put(Template.GL_EMP_HANDBOOK, new TemplateWrapper(Template.GL_EMP_HANDBOOK, 'Global Employee Handbook', TEMPLATE_DOC_TYPE_PACKAGE, false, 110, true, true, null, null, null));
                
                templateTypeWrapperMap.put(Template.GL_RSU_LETTER, new TemplateWrapper(Template.GL_RSU_LETTER, 'Global RSU Letter', TEMPLATE_DOC_TYPE_PACKAGE, true, 120, false, false, null, null, null));

                templateTypeWrapperMap.put(Template.MANAGER_SUMMARY, new TemplateWrapper(Template.MANAGER_SUMMARY, 'Manager Summary', TEMPLATE_DOC_TYPE_SUMMARY, true, null, true, false, null, null, null));
            }
            return templateTypeWrapperMap;
        }set;
    }

    public static Map<Template, MA_DS_Template__c> setupMasterTemplates(Boolean triggerDisabled) {
        return setupMasterTemplates(new Set<Template>(Template.values()), triggerDisabled);
    }

    public static Map<Template, MA_DS_Template__c> setupMasterTemplates(Set<Template> maTemplates, Boolean triggerDisabled) {
        Map<Template, MA_DS_Template__c> masterTemplateMap = new Map<Template, MA_DS_Template__c>();

        for(Template maTemplate : maTemplates) {
            TemplateWrapper templateWrapper = templateTypeWrapperMap.get(maTemplate);
            
            if(templateWrapper != null) {
                MA_DS_Template__c template = new MA_DS_Template__c();
                template.Name = templateWrapper.templateName;
                template.MA_DS_Template_Type__c = TEMPLATE_TYPE_MASTER;
                template.MA_DS_Template_Document_Type__c = templateWrapper.templateDocType;
                template.MA_DS_Merge_Capable__c = templateWrapper.mergeCapable;

                masterTemplateMap.put(maTemplate, template);
            }
        }

        insertTemplates(masterTemplateMap.values(), triggerDisabled);
        return masterTemplateMap;
    }

    private static void insertTemplates(List<MA_DS_Template__c> templates, Boolean triggerDisabled) {
        MA_DS_TemplateTriggerHandler.triggerDisabled = triggerDisabled;
        insert templates;
        MA_DS_TemplateTriggerHandler.triggerDisabled = false;
    }

    public static Map<BGCTemplate, MA_DS_Template__c> setupBGCTemplates(Acquisition_Company__c acqCompany, Boolean triggerDisabled) {
        return setupBGCTemplates(new Set<BGCTemplate>(BGCTemplate.values()), acqCompany, triggerDisabled);
    }

    public static Map<BGCTemplate, MA_DS_Template__c> setupBGCTemplates(Set<BGCTemplate> maBGCTemplates, Acquisition_Company__c acqCompany, Boolean triggerDisabled) {
        Map<BGCTemplate, MA_DS_Template__c> bgcTemplateMap = new Map<BGCTemplate, MA_DS_Template__c>();

        for(BGCTemplate maBGCTemplate : maBGCTemplates) {
            TemplateWrapper templateWrapper = bgcTemplateTypeWrapperMap.get(maBGCTemplate);
            
            if(templateWrapper != null) {
                MA_DS_Template__c template = new MA_DS_Template__c();
                template.Name = templateWrapper.templateName;
                template.MA_DS_Acquisition_Company__c = acqCompany.Id;
                template.MA_DS_Template_Type__c = TEMPLATE_TYPE_BACKGROUND_CHECK;
                template.MA_DS_Template_Document_Type__c = templateWrapper.templateDocType;
                template.MA_DS_Background_Check_URL__c = templateWrapper.bgcURL;
                template.MA_DS_Background_Check_Region__c = templateWrapper.bgcRegion;
                template.MA_DS_Background_Check_Email_Body__c = templateWrapper.bgcEmailBody;
                template.MA_DS_Background_Check_Email_Subject__c = templateWrapper.bgcEmailSubject;

                bgcTemplateMap.put(maBGCTemplate, template);
            }
        }

        insertTemplates(bgcTemplateMap.values(), triggerDisabled);
        return bgcTemplateMap;
    }

    public static TemplateWrapper getTemplateWrapper(String templateName) {
        Integer templateIndex = templateWrappers.indexOf(new TemplateWrapper(templateName));
        return templateWrappers.get(templateIndex);
    }

    public static Map<Template, MA_DS_Template__c> setupAcquisitionTemplates(Acquisition_Company__c acqCompany, Map<Template, MA_DS_Template__c> masterTemplateMap, Boolean triggerDisabled) {
        Map<Template, MA_DS_Template__c> acqTemplateMap = new Map<Template, MA_DS_Template__c>();

        for(Template templateType : masterTemplateMap.keySet()) {
            MA_DS_Template__c masterTemplate = masterTemplateMap.get(templateType);

            MA_DS_Template__c acqTemplate = new MA_DS_Template__c();
            acqTemplate.Name = masterTemplate.Name;
            acqTemplate.MA_DS_Acquisition_Company__c = acqCompany.Id;
            acqTemplate.MA_DS_Derived_From_Template__c = masterTemplate.Id;
            acqTemplate.MA_DS_Template_Type__c = TEMPLATE_TYPE_ACQUISITION;
            acqTemplate.MA_DS_Merge_Capable__c = masterTemplate.MA_DS_Merge_Capable__c;
            acqTemplate.MA_DS_Template_Document_Type__c = masterTemplate.MA_DS_Template_Document_Type__c;

            acqTemplateMap.put(templateType, acqTemplate);
        }

        insertTemplates(acqTemplateMap.values(), triggerDisabled);
        return acqTemplateMap;
    }

    public static Set<Template> getUSPackageTemplates() {
        return new Set<Template> {Template.PIIA_CAL, Template.PIIA_WA, Template.PIIA_IL, Template.PIIA_US_OTHERS, 
                                  Template.CAL_WORKER_COMP_FORM, Template.CAL_WORKER_COMP_GUIDE, Template.NYC_PREG_EMP_RIGHTS_NOTICE, Template.NYC_PAID_SICK_LEAVE_NOTICE, 
                                  Template.SF_FAIR_CHANCE_ORDINANCE, Template.US_HIPAA_NOTICE, Template.US_OFFER_LETTER, 
                                  Template.GL_OBA_FORM, Template.GL_SEC_BEST_PRAC, Template.GL_SIG_ACK_FORM, Template.GL_COC, Template.GL_EMP_HANDBOOK, Template.GL_RSU_LETTER, 
                                  Template.MANAGER_SUMMARY};
    }

    public static Set<Template> getIndiaPackageTemplates() {
        return new Set<Template> {Template.PIIA_TL, Template.PIIA_KA, Template.IN_OFFER_LETTER, 
                                  Template.GL_OBA_FORM, Template.GL_SEC_BEST_PRAC, Template.GL_SIG_ACK_FORM, Template.GL_COC, Template.GL_EMP_HANDBOOK, Template.GL_RSU_LETTER, 
                                  Template.MANAGER_SUMMARY};
    }

    public static List<MA_DS_Template__c> getTemplates(Set<Template> maTemplates, TemplateType maTemplateType, Acquisition_Company__c acqCompany) {
        Id acqCompanyId = acqCompany?.Id;
        String templateType = templateTypeMap.get(maTemplateType);
        Set<String> templateNames = getTemplateNames(maTemplates);

        String queryStr = 'SELECT Id, Name, MA_DS_Template_Type__c, MA_DS_Acquisition_Company__c, MA_DS_Template_Document_Type__c, MA_DS_Merge_Capable__c, MA_DS_Derived_From_Template__c';
        queryStr += ' FROM MA_DS_Template__c';
        queryStr += ' WHERE Name IN :templateNames AND';
        queryStr += ' MA_DS_Template_Type__c = :templateType';
        queryStr += (acqCompanyId == null) ? '' : ' AND MA_DS_Acquisition_Company__c = :acqCompanyId';

        return (List<MA_DS_Template__c>)Database.query(queryStr);
    }

    public static Set<String> getTemplateNames(Set<Template> maTemplates) {
        Set<String> templateNames = new Set<String>();
        
        for(Template maTemplate : maTemplates) {
            templateNames.add(templateTypeWrapperMap.get(maTemplate).templateName);
        }
        
        return templateNames;
    }

    public static MA_DS_Template__c getTemplate(Template maTemplate, TemplateType maTemplateType) {
        List<MA_DS_Template__c> templates = getTemplates(new Set<Template> {maTemplate}, maTemplateType, null);
        return (templates.size() > 0) ? templates[0] : null;
    }

    public static MA_DS_Template__c getTemplate(Template maTemplate, TemplateType maTemplateType, Acquisition_Company__c acqCompany) {
        List<MA_DS_Template__c> templates = getTemplates(new Set<Template> {maTemplate}, maTemplateType, acqCompany);
        return (templates.size() > 0) ? templates[0] : null;
    }

    public static Map<Template, MA_DS_Template__c> getTemplateMap(TemplateType maTemplateType) {
        return getTemplateMap(maTemplateType, null);
    }

    public static Map<Template, MA_DS_Template__c> getTemplateMap(TemplateType maTemplateType, Acquisition_Company__c acqCompany) {
        Map<Template, MA_DS_Template__c> templateMap = new Map<Template, MA_DS_Template__c>();

        for(MA_DS_Template__c templateRef : getTemplates(new Set<Template>(Template.values()), maTemplateType, acqCompany)) {
            templateMap.put(getTemplateWrapper(templateRef.Name).templateEnumType, templateRef);
        }

        return templateMap;
    }

    public static Map<Template, MA_DS_Template__c> getTemplateMap(Set<Template> maTemplates, TemplateType maTemplateType) {
        return getTemplateMap(maTemplates, maTemplateType, null);
    }

    public static Map<Template, MA_DS_Template__c> getTemplateMap(Set<Template> maTemplates, TemplateType maTemplateType, Acquisition_Company__c acqCompany) {
        Map<Template, MA_DS_Template__c> templateMap = new Map<Template, MA_DS_Template__c>();

        for(MA_DS_Template__c templateRef : getTemplates(maTemplates, maTemplateType, acqCompany)) {
            templateMap.put(getTemplateWrapper(templateRef.Name).templateEnumType, templateRef);
        }

        return templateMap;
    }

    public static Set<Id> getTemplateIds(Set<Template> maTemplates, TemplateType maTemplateType) {
        return getTemplateIds(maTemplates, maTemplateType, null);
    }

    public static Set<Id> getTemplateIds(Set<Template> maTemplates, TemplateType maTemplateType, Acquisition_Company__c acqCompany) {
        Set<Id> templateIds = new Set<Id>();

        for(MA_DS_Template__c templateRef : getTemplates(maTemplates, maTemplateType, acqCompany)) {
            templateIds.add(templateRef.Id);
        }

        return templateIds;
    }

    public static Map<BGCTemplate, MA_DS_Template__c> getBGCTemplateMap(BGCTemplate maBGCTemplate, Acquisition_Company__c acqCompany) {
        return getBGCTemplateMap(new Set<BGCTemplate> {maBGCTemplate}, acqCompany);
    }

    public static Map<BGCTemplate, MA_DS_Template__c> getBGCTemplateMap(Set<BGCTemplate> maBGCTemplates, Acquisition_Company__c acqCompany) {
        Map<BGCTemplate, MA_DS_Template__c> templateMap = new Map<BGCTemplate, MA_DS_Template__c>();

        for(MA_DS_Template__c templateRef : getBGCTemplates(maBGCTemplates, acqCompany)) {
            templateMap.put(getTemplateWrapper(templateRef.Name).bgcTemplateEnumType, templateRef);
        }

        return templateMap;
    }

    public static List<MA_DS_Template__c> getBGCTemplates(Set<BGCTemplate> maBGCTemplates, Acquisition_Company__c acqCompany) {
        Id acqCompanyId = acqCompany.Id;
        Set<String> templateNames = getBGCTemplateNames(maBGCTemplates);

        String queryStr = 'SELECT Id, Name, MA_DS_Template_Type__c, MA_DS_Acquisition_Company__c, MA_DS_Template_Document_Type__c, MA_DS_Background_Check_URL__c, MA_DS_Background_Check_Region__c, MA_DS_Background_Check_Email_Subject__c, MA_DS_Background_Check_Email_Body__c';
        queryStr += ' FROM MA_DS_Template__c';
        queryStr += ' WHERE Name IN :templateNames AND';
        queryStr += ' MA_DS_Template_Type__c = :TEMPLATE_TYPE_BACKGROUND_CHECK AND';
        queryStr += ' MA_DS_Acquisition_Company__c = :acqCompanyId';

        return (List<MA_DS_Template__c>)Database.query(queryStr);
    }

    private static Set<String> getBGCTemplateNames(Set<BGCTemplate> maBGCTemplates) {
        Set<String> templateNames = new Set<String>();

        for(BGCTemplate maBGCTemplate : maBGCTemplates) {
            templateNames.add(bgcTemplateTypeWrapperMap.get(maBGCTemplate).templateName);
        }
        
        return templateNames;
    }

    public class TemplateWrapper {
        public Integer sortOrder {get; private set;}
        public String templateName {get; private set;}
        public Boolean mergeCapable {get; private set;}
        public String templateDocType {get; private set;}
        public Boolean suppressAuditFlags {get; private set;}
        public Boolean suppressRulesCriteria {get; private set;}
        
        public String city {get; private set;}
        public String state {get; private set;}
        public String country {get; private set;}

        public Template templateEnumType {get; private set;}
        public BGCTemplate bgcTemplateEnumType {get; private set;}

        public String bgcURL {get; private set;}
        public String bgcRegion {get; private set;}
        public String bgcEmailBody {get; private set;}
        public String bgcEmailSubject {get; private set;}

        public TemplateWrapper() {}

        public TemplateWrapper(String templateName) {
            this.templateName = templateName;
        }

        public TemplateWrapper(Template templateEnumType, String templateName, String templateDocType, Boolean mergeCapable, Integer sortOrder, Boolean suppressRulesCriteria, Boolean suppressAuditFlags, String country, String state, String city) {
            this.city = city;
            this.state = state;
            this.country = country;
            this.sortOrder = sortOrder;
            this.templateName = templateName;
            this.mergeCapable = mergeCapable;
            this.templateDocType = templateDocType;
            this.templateEnumType = templateEnumType;
            this.suppressAuditFlags = suppressAuditFlags;
            this.suppressRulesCriteria = suppressRulesCriteria;
        }

        public TemplateWrapper(BGCTemplate bgcTemplateEnumType, String templateName, String bgcURL, String bgcRegion, String bgcEmailSubject, String bgcEmailBody) {
            this.bgcURL = bgcURL;
            this.bgcRegion = bgcRegion;
            this.templateName = templateName;
            this.bgcEmailBody = bgcEmailBody;
            this.bgcEmailSubject = bgcEmailSubject;
            this.templateDocType = TEMPLATE_DOC_TYPE_NA;
            this.bgcTemplateEnumType = bgcTemplateEnumType;
        }

        public Boolean equals(Object obj) {
            Boolean isEquals = false;
    
            if(obj instanceof TemplateWrapper) {
                TemplateWrapper templateWrapper = (TemplateWrapper) obj;
                isEquals = this.templateName.equalsIgnoreCase(templateWrapper.templateName);
            }
    
            return isEquals;
        }
    
        public Integer hashCode() {
            return System.hashCode(templateName);
        }
    }
}