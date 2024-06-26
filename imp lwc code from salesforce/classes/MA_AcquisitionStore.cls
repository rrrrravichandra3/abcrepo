/**
 * @description       : Class to get Acquisition objects record
 * @author            : Satyam Kumar
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   05-24-2021   Satyam Kumar   Initial Version
**/
public with sharing class MA_AcquisitionStore {
    
    public static Acquisition_Contacts__c getAcquisitionContactByEmail(String email){
        return new ElevatedContext().performAcqContactQuery(email);
    }
    
    private without sharing class ElevatedContext{
        //Keep the class without sharing.
        public Acquisition_Contacts__c performAcqContactQuery(String email) {
            return [SELECT Id, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, 
                    SystemModstamp, LastActivityDate, MayEdit, IsLocked, LastViewedDate, LastReferencedDate, 
                    ConnectionReceivedId, ConnectionSentId, Acquisition_Company__c, Entity_Name__c, Employee_ID_Target__c,
                    Acquisition_Company_Name__c, Notes__c, Background_Check__c, Birth_Date__c, Email_Address_Target__c,
                    Business_Unit__c, Contractor_Agency_Name__c, Continuous_Service_Date__c, Contractor_End_Date__c,
                    Cost_Center__c, Phone_Number_Target__c, Cube_Location_Floor__c, Office_Address_City_Target__c, 
                    Office_Address_Country_Target__c, Office_Address_State_Province_Target__c, Office_Address_Street_Target__c, 
                    Office_Address_Zip_Postal_Code_Target__c, Contractor_Start_Date__c, Day_1_Address_City__c, 
                    Day_1_Address_Country__c, Day_1_Address_State_Province__c, Day_1_Address_Street__c, Day_1_Address_Zip_Code__c,
                    Day_1_Location__c, Department__c, Distance_from_SF_Office__c, Division__c, Founder_Type__c, Employee_ID__c,
                    Employee_Type__c, Employment_Package__c, Manager_Name_Target__c, Manager_Title_Target__c, First_Name_Legal__c,
                    Gender__c, Hire_Reason__c, Home_Address_City__c, Home_Address_Country__c, Home_Address_Region__c, 
                    Home_Address_Street__c, Home_Address_Zip_Postal_Code__c, Home_Address_State_Province__c, ID_Type__c,
                    IT_Onboarding_Day_1_Date__c, Last_Name_Legal__c, Middle_Name_Legal__c,
                    Office_Address_City__c, Office_Address_Country__c, Office_Address_State_Province__c,
                    Office_Address_Street__c, Office_Address_Zip_Postal_Code__c, Onboarding_Group__c,
                    Business_Title_Target__c, Remote__c, Original_Hire_Date__c, PCC_For_Integration__c, 
                    Executive__c, Personal_Email_Address__c, Personal_Phone_Number__c, First_Name_Preferred__c,
                    Last_Name_Preferred__c, Primary_Coverage_Country__c, Probation_End_Date__c, Leader__c, 
                    Manager_ID_Target__c, Rehire_Former_Worker__c, Remote_Non_Remote__c, Resource_Type__c,
                    Business_Title__c, Hire_Date__c, Manager_ID__c, Acquisition_Org__c, Pay_Rate_Type__c, 
                    Badge_Access_Required_Post_Day_1__c, Contact_Status__c, Hire_Date_Target__c, Team__c,
                    Term_Date_Target__c, Transitional_Employee__c, Temporary_Password__c, Workday_Employee_Change_Key__c,
                     Salesforce_Email_Address__c, Employee_Type_Target__c, Company_Service_Date__c, 
                    Total_Years_of_Service__c, Visa_Type__c, Visa_Expiration_Date__c, Contractor_Status__c, 
                    Manager_Employee_ID_Target__c, Close_Date__c, Nationality__c, Marital_Status__c, People_Manager__c, 
                    Manager_Email_Address_Target__c, Citizenship__c, Probation_Start_Date__c, 
                    Permanent_Residency_Process_Initiated__c, Home_Address_Street_Line_2__c, Contractor_Type__c, 
                    University__c, Employment_End_Date__c, Background_Check_Notes__c, Transitional_Time_Period__c, 
                    Currently_Has_Badge_Access__c, Change_in_Control_CiC__c, CiC_Notes__c, CiC_End_Date__c,
                    Leave_of_Absence_LOA__c, LOA_Type__c, LOA_Start_Date__c, LOA_End_Date_Estimated__c, Contractor__c,
                    Additional_Field_1__c, Additional_Field_2__c, Additional_Field_3__c, Additional_Field_4__c, 
                    Additional_Field_5__c, Transitional_End_Date__c, Severance_Weeks__c, COBRA_Months__c, Outplacement_Months__c,
                    Company__c, Data_Centre__c, I_9_Right_to_Work_Verified__c, I_9_Right_to_Work_Notes__c, Benefits_Enrolled__c,
                    First_Timesheet_Submitted__c, Arbitration_Agreement_Opt_Out__c, Key_Critical_Employee__c, Manager_Name__c,
                    Manager_Title__c, Manager_Email_Address__c, Manager_Employee_ID__c, Currently_Has_Network_Access__c, 
                    Currently_on_Payroll__c, Email_Address_Required_Post_Day_1__c, Network_Access_Required_Post_Day_1__c, 
                    Prior_Employee_of_Target_Company__c, Visa_Number__c, Workday_Setup_Required_Post_Day_1__c,
                    Work_Location_Target__c, Last_Modified_in_Orgvue__c, MuleExtId__c, Salesforce_Laptop_Selection__c,
                    Confirmed_On__c, Full_Name_Preferred__c, Offer_Date_Target__c, Remove_Community_Access__c,
                    Active_at_Close__c, SSNID_Number__c, Active_at_Harmonization__c, Department_Target__c 
                    FROM Acquisition_Contacts__c Where Email_Address_Target__c = :email Order By CreatedDate Desc Limit 1]; 
        }
    }
}