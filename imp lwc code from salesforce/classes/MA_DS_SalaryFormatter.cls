/**
* W-13999473
* Utility class to help with formatting of Salary / Compensation related fields for Docusign CLM integration payloads.
* Formats Compensation related fields based on the Country value and returns CurrencyFormatsWrapper instance.
* 
* Version      Date            Author                  Description
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         05/11/2023      Chakshu Malhotra        W-13999473 - Adds logic to help with formatting of Salary / Compensation related fields for Docusign CLM integration payloads.
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public abstract without sharing class MA_DS_SalaryFormatter {
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to return the CurrencyFormattedFieldsWrapper instance containing Salary / Compensation related fields that need to be formatted with salary format.
    * CurrencyFormattedFieldsWrapper details are passed on to the Docusign CLM along with rest of the integration payload.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    formattedFieldsStr	                    DESCRIPTION (Data Type String, JSON string representing fields that need to be formatted)
    * @return   CurrencyFormattedFieldsWrapper          DESCRIPTION (return CurrencyFormattedFieldsWrapper instance)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static CurrencyFormattedFieldsWrapper getCurrencyFormattedFieldsWrapper(String formattedFieldsStr) {
        CurrencyFormattedFieldsWrapper currencyFormattedFieldsWrapper = new CurrencyFormattedFieldsWrapper();
        currencyFormattedFieldsWrapper.CurrencyFormattedField = new List<String>();

        for(String formattedField : (List<String>)JSON.deserialize(formattedFieldsStr, List<String>.class)) {
            currencyFormattedFieldsWrapper.CurrencyFormattedField.add(formattedField);
        }

        return currencyFormattedFieldsWrapper;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to return the CurrencyFormatsWrapper instance containing formatting details for the Salary / Compensation related fields.
    * The Office Address Country values are used to identify the right salary / compensation format for the Acquisition Contacts.
    * CurrencyFormatsWrapper details are passed on to the Docusign CLM along with rest of the integration payload.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    officeAddressCountries	                DESCRIPTION (Data Type Set<String>, Set of Office Address Country value for the Acquisition Contacts)
    * @return   CurrencyFormatsWrapper                  DESCRIPTION (return CurrencyFormatsWrapper instance)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static CurrencyFormatsWrapper getCurrencyFormatsWrapper(Set<String> officeAddressCountries) {
        CurrencyFormatsWrapper currencyFormatsWrapper = new CurrencyFormatsWrapper();
        if(officeAddressCountries != null) {
            currencyFormatsWrapper.CurrencyFormat = getCurrencyFormatWrapperList(officeAddressCountries);
        }
        return currencyFormatsWrapper;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to return the List of CurrencyFormatWrapper instances, with each instance containing salary formatting details for an individual Office Address Country.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    officeAddressCountries	                DESCRIPTION (Data Type Set<String>, Set of Office Address Country value for the Acquisition Contacts)
    * @return   List<CurrencyFormatWrapper>             DESCRIPTION (return List of CurrencyFormatWrapper instances)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<CurrencyFormatWrapper> getCurrencyFormatWrapperList(Set<String> officeAddressCountries) {
        List<CurrencyFormatWrapper> currencyFormatWrapperList = new List<CurrencyFormatWrapper>();

        for(MA_DS_Salary_Format__mdt salaryFormatType : getSalaryFormatTypes(officeAddressCountries)) {
            CurrencyFormatWrapper currencyFormatWrapper = new CurrencyFormatWrapper();
            currencyFormatWrapper.Country = salaryFormatType.MA_DS_Country__c;
            currencyFormatWrapper.Prefix = (salaryFormatType.MA_DS_Has_Prefix_Symbol__c || salaryFormatType.MA_DS_Has_Prefix_Code__c) ? getPrefixSuffixWrapper(true, salaryFormatType) : null;
            currencyFormatWrapper.Suffix = (salaryFormatType.MA_DS_Has_Suffix_Symbol__c || salaryFormatType.MA_DS_Has_Suffix_Code__c) ? getPrefixSuffixWrapper(false, salaryFormatType) : null;
            currencyFormatWrapper.IntegerSeparator = salaryFormatType.MA_DS_Integer_Separator__c;
            currencyFormatWrapper.FractionSeparator = salaryFormatType.MA_DS_Fraction_Separator__c;
            currencyFormatWrapperList.add(currencyFormatWrapper);
        }

        return currencyFormatWrapperList;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to return the List of Salary Formats (custom metadata records), based on the Set of Office Address Countries.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    officeAddressCountries	                DESCRIPTION (Data Type Set<String>, Set of Office Address Country value for the Acquisition Contacts)
    * @return   List<MA_DS_Salary_Format__mdt>          DESCRIPTION (return List of Salary Format custom metadata records)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<MA_DS_Salary_Format__mdt> getSalaryFormatTypes(Set<String> officeAddressCountries) {
        return [SELECT Id, MA_DS_Country__c, MA_DS_Has_Prefix_Symbol__c, MA_DS_Has_Prefix_Code__c, MA_DS_Has_Suffix_Symbol__c, MA_DS_Has_Suffix_Code__c, 
                MA_DS_Currency_Unicode__c, MA_DS_Currency_Code__c, MA_DS_Integer_Separator__c, MA_DS_Fraction_Separator__c
                FROM MA_DS_Salary_Format__mdt
                WHERE MA_DS_Country__c IN :officeAddressCountries];
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to return the PrefixSuffixWrapper instance, containing details of Prefix / Suffix for the Salary format.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    isPrefix	                        DESCRIPTION (Data Type Boolean, True if Prefix details are to be populated in PrefixSuffixWrapper instance)
    * @param    salaryFormatType	                DESCRIPTION (Data Type MA_DS_Salary_Format__mdt, Salary Format custom metadata type record)
    * @return   PrefixSuffixWrapper                 DESCRIPTION (return PrefixSuffixWrapper instance)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static PrefixSuffixWrapper getPrefixSuffixWrapper(Boolean isPrefix, MA_DS_Salary_Format__mdt salaryFormatType) {
        Boolean hasSymbol = isPrefix ? salaryFormatType.MA_DS_Has_Prefix_Symbol__c : salaryFormatType.MA_DS_Has_Suffix_Symbol__c;
        Boolean hasCode = isPrefix ? salaryFormatType.MA_DS_Has_Prefix_Code__c : salaryFormatType.MA_DS_Has_Suffix_Code__c;

        PrefixSuffixWrapper prefixSuffixWrapper = new PrefixSuffixWrapper();
        prefixSuffixWrapper.IncludeSymbol = String.valueOf(hasSymbol).toUpperCase();
        prefixSuffixWrapper.IncludeName = String.valueOf(hasCode).toUpperCase();
        prefixSuffixWrapper.Symbol = hasSymbol ? salaryFormatType.MA_DS_Currency_Unicode__c : null;
        prefixSuffixWrapper.Name = hasCode ? salaryFormatType.MA_DS_Currency_Code__c : null;
        return prefixSuffixWrapper;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the List of Currency Formatted Fields, to wrap it within CurrencyFormattedFieldsWrapper node.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class CurrencyFormattedFieldsWrapper {
        public List<String> CurrencyFormattedField {get; private set;}
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the List of CurrencyFormatWrapper instances, to wrap it within CurrencyFormatsWrapper node.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class CurrencyFormatsWrapper {
        public List<CurrencyFormatWrapper> CurrencyFormat {get; private set;}
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the details such as Country, Prefix / Suffix & Separators for the Salary format.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class CurrencyFormatWrapper {
        public String Country {get; private set;}
        public PrefixSuffixWrapper Prefix {get; private set;}
        public PrefixSuffixWrapper Suffix {get; private set;}
        public String IntegerSeparator {get; private set;}
        public String FractionSeparator {get; private set;}
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the details of Prefix / Suffix for the Salary format.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class PrefixSuffixWrapper {
        public String IncludeSymbol {get; private set;}
        public String IncludeName {get; private set;}
        public String Symbol {get; private set;}
        public String Name {get; private set;}
    }
}