/**
 * W-12404865
 * Wrapper class of MA_DS_SetupPackages controller to hold details of selected or removed Packages, Templates & In Use Templates.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         31/01/2023      Chakshu Malhotra        W-12404865 - Adds wrapper classes to hold details of master / derived Packages, Templates & In Use Templates.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public with sharing class MA_DS_SetupPackagesWrapper {
    @AuraEnabled public InUseTemplateWrapper masterInUseTemplate {get; set;}
    @AuraEnabled public InUseTemplateWrapper derivedInUseTemplate {get; set;}

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold details of the In Use Template record.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class InUseTemplateWrapper {
        @AuraEnabled public Id inUseTemplateId {get; set;}
        @AuraEnabled public PackageWrapper packageUsing {get; set;}
        @AuraEnabled public TemplateWrapper templateBeingUsed {get; set;}
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold details of the Package reference in the In Use Template record.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class PackageWrapper {
        @AuraEnabled public Id packageId {get; set;}
        @AuraEnabled public String packageName {get; set;}
        @AuraEnabled public String packageDescription {get; set;}
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold details of the Template Being Used in the In Use Template record.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class TemplateWrapper {
        @AuraEnabled public Id templateId {get; set;}
        @AuraEnabled public String templateName {get; set;}
        @AuraEnabled public Boolean mergeCapable {get; set;}
        @AuraEnabled public String templateDocumentType {get; set;}
    }

    transient private static SetupPackagesHelperWrapper singletonInstance;

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create singleton instance of SetupPackagesHelperWrapper class.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   SetupPackagesHelperWrapper          DESCRIPTION (return singleton instance of SetupPackagesHelperWrapper)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static SetupPackagesHelperWrapper getInstance() {
        if(singletonInstance == null) {
            singletonInstance = new SetupPackagesHelperWrapper();
        }
        return singletonInstance;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold details of Master & Derived Packages, Master & Derived Templates and Master & Derived In Use Template.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class SetupPackagesHelperWrapper {
        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of Ids for Master Packages.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        transient public Set<Id> masterPackageIds {
            get {
                if(masterPackageIds == null) {
                    masterPackageIds = new Set<Id>();
                }
                return masterPackageIds;
            }set;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of Ids for existing Derived Packages.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        transient public Set<Id> derivedPackageIds {
            get {
                if(derivedPackageIds == null) {
                    derivedPackageIds = new Set<Id>();
                }
                return derivedPackageIds;
            }set;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of Ids for Master Templates.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        transient public Set<Id> masterTemplateIds {
            get {
                if(masterTemplateIds == null) {
                    masterTemplateIds = new Set<Id>();
                }
                return masterTemplateIds;
            }set;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of Ids for existing Derived Templates.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        transient public Set<Id> derivedTemplateIds {
            get {
                if(derivedTemplateIds == null) {
                    derivedTemplateIds = new Set<Id>();
                }
                return derivedTemplateIds;
            }set;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of Ids for Master In Use Templates.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        transient public Set<Id> masterInUseTemplateIds {
            get {
                if(masterInUseTemplateIds == null) {
                    masterInUseTemplateIds = new Set<Id>();
                }
                return masterInUseTemplateIds;
            }set;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Set of Ids for existing Derived In Use Templates.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        transient public Set<Id> derivedInUseTemplateIds {
            get {
                if(derivedInUseTemplateIds == null) {
                    derivedInUseTemplateIds = new Set<Id>();
                }
                return derivedInUseTemplateIds;
            }set;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Map of Id to existing Derived Packages.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        transient public Map<Id, MA_DS_Package__c> derivedPackageMap {
            get {
                if(derivedPackageMap == null) {
                    derivedPackageMap = new Map<Id, MA_DS_Package__c>();
                }
                return derivedPackageMap;
            }set;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Map of Id to newly selected Derived Packages.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        transient public Map<Id, MA_DS_Package__c> newDerivedPackageMap {
            get {
                if(newDerivedPackageMap == null) {
                    newDerivedPackageMap = new Map<Id, MA_DS_Package__c>();
                }
                return newDerivedPackageMap;
            }set;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Map of Id to existing Derived Templates.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        transient public Map<Id, MA_DS_Template__c> derivedTemplateMap {
            get {
                if(derivedTemplateMap == null) {
                    derivedTemplateMap = new Map<Id, MA_DS_Template__c>();
                }
                return derivedTemplateMap;
            }set;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Map of Id to newly selected Derived Templates.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        transient public Map<Id, MA_DS_Template__c> newDerivedTemplateMap {
            get {
                if(newDerivedTemplateMap == null) {
                    newDerivedTemplateMap = new Map<Id, MA_DS_Template__c>();
                }
                return newDerivedTemplateMap;
            }set;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the List of newly selected In Use Templates.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        transient public List<MA_DS_In_Use_Template__c> newDerivedInUseTemplates {
            get {
                if(newDerivedInUseTemplates == null) {
                    newDerivedInUseTemplates = new List<MA_DS_In_Use_Template__c>();
                }
                return newDerivedInUseTemplates;
            }set;
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Property to hold the Map of Id to Record detail of Master In Use Template.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        transient public Map<Id, MA_DS_In_Use_Template__c> masterInUseTemplateMap {
            get {
                if(masterInUseTemplateMap == null) {
                    masterInUseTemplateMap = new Map<Id, MA_DS_In_Use_Template__c>();
                }
                return masterInUseTemplateMap;
            }set;
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Private default constructor of SetupPackagesHelperWrapper class to enforce the singleton design.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private SetupPackagesHelperWrapper() {
            // to enforce singleton design
        }
    }
}