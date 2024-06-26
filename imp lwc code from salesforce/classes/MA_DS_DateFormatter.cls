/**
* W-13999460
* Utility class to help with formatting of Date fields for Docusign CLM integration payloads.
* Formats dates based on the Country value and returns formatted date string.
* 
* Version      Date            Author                  Description
* --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         25/10/2023      Chakshu Malhotra        W-13999460 - Adds logic to help with formatting of Date fields for Docusign CLM integration payloads.
* --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public abstract without sharing class MA_DS_DateFormatter {
    
    private static final String USA_DATE_FORMAT = Label.MA_DS_USA_Date_Format;
    private static final String USA_DATE_FORMAT_SEPARATOR = Label.MA_DS_USA_Date_Format_Separator;

    private static final String NON_USA_DATE_FORMAT = Label.MA_DS_Non_USA_Date_Format;
    private static final String NON_USA_DATE_FORMAT_SEPARATOR = Label.MA_DS_Non_USA_Date_Format_Separator;
    
    private static final String OFFICE_ADDRESS_COUNTRY_USA = Label.MA_DS_Office_Address_Country_USA;

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to return the formatted string for the date instance based on the office address country of the Acquisition Contact.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    dateInstance                            DESCRIPTION (Data Type Date, Instance of the Date, representing a Date field within integration payload)
    * @param    officeAddressCountry	                DESCRIPTION (Data Type String, Office Address Country for the Acquisition Contact)
    * @return   String                                  DESCRIPTION (return Formatted Date string)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static String getFormattedDate(Date dateInstance, String officeAddressCountry) {
        return (dateInstance == null) ? '' : getFormattedDate(dateInstance.day(), dateInstance.month(), dateInstance.year(), officeAddressCountry);
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to format the day, month & year component of Date instance based on the office address country of the Acquisition Contact.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    day                                     DESCRIPTION (Data Type Integer, Day-of-month component of a Date instance)
    * @param    month                                   DESCRIPTION (Data Type Integer, Month component of a Date instance, 1=Jan)
    * @param    year                                    DESCRIPTION (Data Type Integer, Year component of a Date instance)
    * @param    officeAddressCountry	                DESCRIPTION (Data Type String, Office Address Country for the Acquisition Contact)
    * @return   String                                  DESCRIPTION (return Formatted Date string)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getFormattedDate(Integer day, Integer month, Integer year, String officeAddressCountry) {
        return (String.isNotBlank(officeAddressCountry) && officeAddressCountry.equalsIgnoreCase(OFFICE_ADDRESS_COUNTRY_USA)) ? getUSAFormattedDate(day, month, year) : getNonUSAFormattedDate(day, month, year);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to format the day, month & year component of Date instance as per the USA format.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    day                                     DESCRIPTION (Data Type Integer, Day-of-month component of a Date instance)
    * @param    month                                   DESCRIPTION (Data Type Integer, Month component of a Date instance, 1=Jan)
    * @param    year                                    DESCRIPTION (Data Type Integer, Year component of a Date instance)
    * @return   String                                  DESCRIPTION (return USA Formatted Date string)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getUSAFormattedDate(Integer day, Integer month, Integer year) {
        return month + USA_DATE_FORMAT_SEPARATOR + day + USA_DATE_FORMAT_SEPARATOR + year;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to format the day, month & year component of Date instance as per the Non-USA format.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    day                                     DESCRIPTION (Data Type Integer, Day-of-month component of a Date instance)
    * @param    month                                   DESCRIPTION (Data Type Integer, Month component of a Date instance, 1=Jan)
    * @param    year                                    DESCRIPTION (Data Type Integer, Year component of a Date instance)
    * @return   String                                  DESCRIPTION (return Non-USA Formatted Date string)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getNonUSAFormattedDate(Integer day, Integer month, Integer year) {
        return day + USA_DATE_FORMAT_SEPARATOR + month + USA_DATE_FORMAT_SEPARATOR + year;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to return the Date Format based on the Office Address Country for the Acquisition Contact.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    officeAddressCountry	                DESCRIPTION (Data Type String, Office Address Country for the Acquisition Contact)
    * @return   String                                  DESCRIPTION (return Formatted Date string)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static String getDateFormat(String officeAddressCountry) {
        return (String.isNotBlank(officeAddressCountry) && officeAddressCountry.equalsIgnoreCase(OFFICE_ADDRESS_COUNTRY_USA)) ? USA_DATE_FORMAT : NON_USA_DATE_FORMAT;
    }
}