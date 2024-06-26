/**
 * W-13011380
 * Trigger helper class for MA_DS_TemplateTriggerHandler
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         19/04/2023      Chakshu Malhotra        Trigger helper logic for MA_DS_TemplateTriggerHandler.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public with sharing class MA_DS_TemplateTriggerHelper {

    public static Boolean overrideTemplateCRUDAccess = false;

    private static final String TEMPLATE_TYPE_MASTER = Label.MA_DS_Template_Type_Master;
    private static final String TEMPLATE_TYPE_BGC = Label.MA_DS_Template_Type_Background_Check;
    private static final String INSUFFICIENT_CRUD_ACCESS = Label.MA_DS_Insufficient_Template_CRUD_Access;
    private static final String DOCUMENT_TYPE_MANAGER_SUMMARY = Label.MA_DS_Document_Type_Manager_Summary;
    private static final String DUPLICATE_SUMMARY_TEMPLATE_EXCEPTION = Label.MA_DS_Duplicate_Summary_Template_Exception;
    private static final String DUPLICATE_BGC_TEMPLATE_EXCEPTION = Label.MA_DS_Duplicate_Background_Check_Template_Exception;

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the singleton instance of the MA_DS_TemplateTriggerHelper class.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static final MA_DS_TemplateTriggerHelper helperInstance {
        get {
            if(helperInstance == null) {
                helperInstance = new MA_DS_TemplateTriggerHelper();
            }
            return helperInstance;
        }private set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Private default constructor of the MA_DS_TemplateTriggerHelper class.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private MA_DS_TemplateTriggerHelper() {
        // to enforce singleton design
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the map of Template Type to Custom Permission Name used to check CRUD access for user.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private Map<String, String> templateCrudAccessMap {
        get {
            if(templateCRUDAccessMap == null) {
                templateCRUDAccessMap = new Map<String, String>();
                for(MA_DS_Template_CRUD_Access_Metadata__mdt crudAccessMetadata : [SELECT MA_DS_Template_Type__c, MA_DS_Custom_Permission_Name__c
                                                                                   FROM MA_DS_Template_CRUD_Access_Metadata__mdt]) {
                    templateCRUDAccessMap.put(crudAccessMetadata.MA_DS_Template_Type__c.toLowerCase(), crudAccessMetadata.MA_DS_Custom_Permission_Name__c);
                }
            }
            return templateCRUDAccessMap;
        }set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to check & add error on Trigger.new records if user doesn't have CRUD access on the Template Type or access is not overridden.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecords 	   	DESCRIPTION (Data type List<MA_DS_Template__c>, Trigger.new list)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void checkTemplatesCRUDAccess(List<MA_DS_Template__c> newRecords) {
        for(MA_DS_Template__c newRec : newRecords) {
            addErrorIfInsufficientAccess(newRec);
        }
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to addError to the MA_DS_Template__c record if user doesn't have sufficient CRUD access on the template type.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecords 	   	DESCRIPTION (Data type List<MA_DS_Template__c>, Trigger.new list)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void addErrorIfInsufficientAccess(MA_DS_Template__c template) {
        String templateTypeKey = template.MA_DS_Template_Type__c.toLowerCase();
        Boolean hasTemplateTypeKey = templateCrudAccessMap.containsKey(templateTypeKey);
        
        if(!overrideTemplateCRUDAccess && hasTemplateTypeKey && !FeatureManagement.checkPermission(templateCrudAccessMap.get(templateTypeKey))) {
            template.addError(INSUFFICIENT_CRUD_ACCESS);
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to addError to the Trigger.new record if a Duplicate Manager Summary / Background Check Template is added / updated in the system.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecords 	   	DESCRIPTION (Data type List<MA_DS_Template__c>, Trigger.new list)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void preventDuplicateTemplates(List<MA_DS_Template__c> newRecords) {
        Set<Id> acqCompanyIds = new Set<Id>();
        Set<String> bgcRegions = new Set<String>();

        Map<String, MA_DS_Template__c> bgcTemplateMap = new Map<String, MA_DS_Template__c>();
        Map<String, MA_DS_Template__c> summaryTemplateMap = new Map<String, MA_DS_Template__c>();

        for(MA_DS_Template__c newRec : newRecords) {
            if(newRec.MA_DS_Acquisition_Company__c != null) {
                acqCompanyIds.add(newRec.MA_DS_Acquisition_Company__c);
            }
            if(newRec.MA_DS_Template_Document_Type__c.equalsIgnoreCase(DOCUMENT_TYPE_MANAGER_SUMMARY)) {
                String summaryTemplateKey = (newRec.MA_DS_Acquisition_Company__c == null) ? '' : String.valueOf(newRec.MA_DS_Acquisition_Company__c);
                summaryTemplateKey += newRec.MA_DS_Template_Type__c + newRec.MA_DS_Template_Document_Type__c;
                summaryTemplateMap.put(summaryTemplateKey.toLowerCase(), newRec);
            }else if(newRec.MA_DS_Template_Type__c.equalsIgnoreCase(TEMPLATE_TYPE_BGC) && newRec.MA_DS_Background_Check_Region__c != null && newRec.MA_DS_Acquisition_Company__c != null) {
                String bgcTemplateKey = String.valueOf(newRec.MA_DS_Acquisition_Company__c) + newRec.MA_DS_Background_Check_Region__c;
                bgcRegions.add(newRec.MA_DS_Background_Check_Region__c);
                bgcTemplateMap.put(bgcTemplateKey.toLowerCase(), newRec);
            }
        }

        List<MA_DS_Template__c> comparableTemplates = getComparableTemplates(acqCompanyIds, bgcRegions);
        preventDuplicateTemplates(comparableTemplates, bgcTemplateMap, summaryTemplateMap);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to return Template records based on Acquisition Companies & Background Check Regions, to prevent duplicate templates.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyIds 	   	            DESCRIPTION (Data type Set<Id>, Set of Acquisition Company record Ids)
    * @param    bgcRegions 	   	                DESCRIPTION (Data type Set<String>, Set of Background Check Regions for the Background Check Template type)
    * @return   List<MA_DS_Template__c>         DESCRIPTION (return List of Template records to compare with, to identify duplicates)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private List<MA_DS_Template__c> getComparableTemplates(Set<Id> acqCompanyIds, Set<String> bgcRegions) {
        return [SELECT Id, MA_DS_Acquisition_Company__c, MA_DS_Template_Type__c, MA_DS_Template_Document_Type__c, MA_DS_Background_Check_Region__c
                FROM MA_DS_Template__c
                WHERE (MA_DS_Acquisition_Company__c = null OR MA_DS_Acquisition_Company__c IN :acqCompanyIds) AND
                (MA_DS_Template_Document_Type__c = :DOCUMENT_TYPE_MANAGER_SUMMARY OR (MA_DS_Template_Type__c = :TEMPLATE_TYPE_BGC AND MA_DS_Background_Check_Region__c IN :bgcRegions))];
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to addError to the Trigger.new record if a Duplicate Manager Summary / Background Check Template is added / updated in the system.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    comparableTemplates 	   	    DESCRIPTION (Data type List<MA_DS_Template__c>, List of Template records to compare with, to identify duplicates)
    * @param    bgcTemplateMap 	   	            DESCRIPTION (Data type MA_DS_Template__c, Map of Trigger.new Background Check Template records)
    * @param    summaryTemplateMap 	   	        DESCRIPTION (Data type MA_DS_Template__c, Map of Trigger.new Summary Template records)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void preventDuplicateTemplates(List<MA_DS_Template__c> comparableTemplates, Map<String, MA_DS_Template__c> bgcTemplateMap, Map<String, MA_DS_Template__c> summaryTemplateMap) {
        for(MA_DS_Template__c comparableTemplate : comparableTemplates) {
            String templateKey = (comparableTemplate.MA_DS_Acquisition_Company__c == null) ? '' : String.valueOf(comparableTemplate.MA_DS_Acquisition_Company__c);
            templateKey += comparableTemplate.MA_DS_Template_Type__c.equalsIgnoreCase(TEMPLATE_TYPE_BGC) ? comparableTemplate.MA_DS_Background_Check_Region__c : 
                           (comparableTemplate.MA_DS_Template_Type__c + comparableTemplate.MA_DS_Template_Document_Type__c);

            if(comparableTemplate.MA_DS_Template_Type__c.equalsIgnoreCase(TEMPLATE_TYPE_BGC) && isDuplicateBGCTemplate(Trigger.isInsert, templateKey, comparableTemplate, bgcTemplateMap)) {
                bgcTemplateMap.get(templateKey.toLowerCase()).addError(new MA_DS_DuplicateTemplateException(true, new String[] {comparableTemplate.Id}));
            }else if(isDuplicateSummaryTemplate(Trigger.isInsert, templateKey, comparableTemplate, summaryTemplateMap)) {
                summaryTemplateMap.get(templateKey.toLowerCase()).addError(new MA_DS_DuplicateTemplateException(false, new String[] {comparableTemplate.Id}));
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to check if the Background Check Template being inserted / updated is duplicate.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    isInsert 	   	            DESCRIPTION (Data type Boolean, Trigger.isInsert)
    * @param    templateKey 	   	        DESCRIPTION (Data type String, A Unique key formed by using Acquisition Company Id + Background Check Region)
    * @param    comparableTemplate 	   	    DESCRIPTION (Data type MA_DS_Template__c, Template record to compare with, to identify duplicate)
    * @param    bgcTemplateMap 	   	        DESCRIPTION (Data type MA_DS_Template__c, Map of Trigger.new Background Check Template records)
    * @return   Boolean                     DESCRIPTION (return True if the Background Check Template being inserted / updated is duplicate)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private Boolean isDuplicateBGCTemplate(Boolean isInsert, String templateKey, MA_DS_Template__c comparableTemplate, Map<String, MA_DS_Template__c> bgcTemplateMap) {
        Boolean containsTemplateKey = bgcTemplateMap.containsKey(templateKey.toLowerCase());
        MA_DS_Template__c bgcTemplate = containsTemplateKey ? bgcTemplateMap.get(templateKey.toLowerCase()) : null;
        return isInsert ? containsTemplateKey : (containsTemplateKey && bgcTemplate.Id != comparableTemplate.Id);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to check if the Summary Template being inserted / updated is duplicate.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    isInsert 	   	            DESCRIPTION (Data type Boolean, Trigger.isInsert)
    * @param    templateKey 	   	        DESCRIPTION (Data type String, A Unique key formed by using Acquisition Company Id + Template Type + Template Document Type)
    * @param    comparableTemplate 	   	    DESCRIPTION (Data type MA_DS_Template__c, Template record to compare with, to identify duplicate)
    * @param    summaryTemplateMap 	   	    DESCRIPTION (Data type MA_DS_Template__c, Map of Trigger.new Summary Template records)
    * @return   Boolean                     DESCRIPTION (return True if the Summary Template being inserted / updated is duplicate)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private Boolean isDuplicateSummaryTemplate(Boolean isInsert, String templateKey, MA_DS_Template__c comparableTemplate, Map<String, MA_DS_Template__c> summaryTemplateMap) {
        Boolean containsTemplateKey = summaryTemplateMap.containsKey(templateKey.toLowerCase());
        MA_DS_Template__c summaryTemplate = containsTemplateKey ? summaryTemplateMap.get(templateKey.toLowerCase()) : null;
        return isInsert ? containsTemplateKey : (containsTemplateKey && summaryTemplate.Id != comparableTemplate.Id);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to check & add error on Trigger.old record if user doesn't have CRUD access on the Template Type or access is not overridden.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    oldRec 	   	DESCRIPTION (Data type MA_DS_Template__c, Old Template record)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void preventDeletionIfInsufficientAccess(MA_DS_Template__c oldRec) {
        addErrorIfInsufficientAccess(oldRec);
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception class to addError to the Trigger.new record when a duplicate Manager Summary template is added in the system.
    * Only one Manager Summary template of the either type each is allowed in the system.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class MA_DS_DuplicateTemplateException extends Exception {
        private Boolean bgcTemplate;
        private List<String> exceptionMsgParams;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the MA_DS_DuplicateTemplateException class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public MA_DS_DuplicateTemplateException(Boolean bgcTemplate, List<String> exceptionMsgParams) {
            this.bgcTemplate = bgcTemplate;
            this.exceptionMsgParams = exceptionMsgParams;
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method overrides the getMessage() method of the Exception class to return the custom exception message.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getMessage() {
            return String.format(this.bgcTemplate ? DUPLICATE_BGC_TEMPLATE_EXCEPTION : DUPLICATE_SUMMARY_TEMPLATE_EXCEPTION, exceptionMsgParams);
        }
    }
}