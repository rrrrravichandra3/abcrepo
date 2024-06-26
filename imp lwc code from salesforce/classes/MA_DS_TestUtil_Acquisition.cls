/**
 * Test Utility class to setup Acquisition Company, Acquisition Contacts & Compensation data.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         01/12/2023      Chakshu Malhotra        Adds utility methods to setup Acquisition Company, Acquisition Contacts & Compensation data.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
@isTest
public class MA_DS_TestUtil_Acquisition {

    public enum Employees {US_EMPLOYEES, US_NYC_EMPLOYEES, US_IL_EMPLOYEES, US_WA_EMPLOYEES, US_CAL_EMPLOYEES, IN_EMPLOYEES, IN_TEL_EMPLOYEES, IN_KA_EMPLOYEES}

    private static final String ACQ_COMPANY_PREFIX = 'testAcqCompany';
    private static final String ACQ_COMPANY_STATUS = 'Integration Planning';

    private static final String COUNTRY_INDIA = 'India';
    private static final String COUNTRY_USA = 'United States of America';

    private static final String STATE_TELANGANA = 'Telangana';
    private static final String STATE_KARNATAKA = 'Karnataka';
    private static final String STATE_NEW_YORK = 'New York';
    private static final String STATE_ILLINOIS = 'Illinois';
    private static final String STATE_WASHINGTON = 'Washington';
    private static final String STATE_CALIFORNIA = 'California';

    private static final String CITY_SEATTLE = 'Seattle';
    private static final String CITY_CHICAGO = 'Chicago';
    private static final String CITY_NEW_YORK = 'New York';
    private static final String CITY_SAN_FRANCISCO = 'San Francisco';
    private static final String CITY_BANGALORE = 'Bangalore';
    private static final String CITY_HYDERABAD = 'Hyderabad';

    private static final String MANAGER_PREFIX = 'manager';
    private static final String EMPLOYEE_PREFIX = 'employee';
    private static final String EXECUTIVE_PREFIX = 'executive';

    private static final String ENGINEERING_DEPT = 'Engineering';
    private static final String MARKETING_DEPT = 'Marketing';

    private static final String SUMMARY_EMAIL_BODY = 'Custom Manager Summary Email Body For ';
    private static final String SUMMARY_EMAIL_SUBJECT = 'Custom Manager Summary Email Subject For ';
    private static final String PACKAGE_ENVELOPE_EMAIL_BODY = 'Custom Package Envelope Email Body For ';
    private static final String PACKAGE_ENVELOPE_EMAIL_SUBJECT = 'Custom Package Envelope Email Subject For ';

    private static final String PACKAGE_STAGE_NOT_STARTED = Label.MA_DS_Package_Stage_Not_Started;
    private static final String SUMMARY_STAGE_NOT_STARTED = Label.MA_DS_Summary_Stage_Not_Started;

    private static final List<String> MANAGER_BUSINESS_TITLE = new List<String> {'Manager', 'Sr. Manager'};
    private static final List<String> EMPLOYEE_BUSINESS_TITLE = new List<String> {'Analyst', 'Developer'};
    private static final List<String> EXECUTIVE_BUSINESS_TITLE = new List<String> {'SVP', 'EVP'};

    private static final List<String> GENDERS = new List<String> {'Male', 'Female'};
    private static final List<String> REMOTE_NON_REMOTE = new List<String> {'Non-Remote', 'Remote'};
    private static final List<String> DEPARTMENTS = new List<String> {ENGINEERING_DEPT, MARKETING_DEPT};
    private static final List<String> WORK_LOCATION_STATUS = new List<String> {'Office-Flexible', 'Office-Based', 'Home-Based'};

    private static final Integer EXECUTIVES_PER_STATE = 5;
    private static final Integer MANAGERS_PER_EXECUTIVE = 5;
    private static final Integer EMPLOYEES_PER_MANAGER = 20;
    
    private static Integer managerNum = 1;
    private static Integer employeeNum = 1;
    private static Integer executiveNum = 1;

    private static Integer indiaCrossStateEmployeeKeyIndex = 0;
    private static Integer americaCrossStateEmployeeKeyIndex = 0;

    private static Integer baseSalaryVariant = 0;

    private static List<Integer> executiveBaseSalaries = new List<Integer> {350000, 12500000};
    private static List<Integer> managerBaseSalaries = new List<Integer> {250000, 7500000};
    private static List<Integer> employeeBaseSalaries = new List<Integer> {185000, 4500000};

    private static List<Integer> executiveOTPAmount = new List<Integer> {100000, 2500000};
    private static List<Integer> managerOTPAmount = new List<Integer> {50000, 1500000};
    private static List<Integer> employeeOTPAmount = new List<Integer> {25000, 750000};

    private static List<Integer> executiveAdditionalOTPAmount = new List<Integer> {75000, 2000000};
    private static List<Integer> executiveAdditionalAllowanceAmount = new List<Integer> {1000, 30000};

    private static List<Integer> executiveCarAllowanceAmount = new List<Integer> {150, 5000};
    private static List<Integer> managerCarAllowanceAmount = new List<Integer> {100, 3500};

    private static List<Integer> executiveStockGrant = new List<Integer> {500000, 350000};
    private static List<Integer> managerStockGrant = new List<Integer> {300000, 240000};
    private static List<Integer> employeeStockGrant = new List<Integer> {215000, 175000};

    private static List<Integer> executiveAdditonalStockGrant = new List<Integer> {300000, 200000};

    public static final String SUMMARY_STAGE_DELIVERED = Label.MA_DS_Summary_Stage_Delivered_To_Manager;
    public static final String PACKAGE_STAGE_DELIVERED = Label.MA_DS_Package_Stage_Delivered_To_Contact;

    private static List<String> americaCrossStateEmployeeKeys {
        get {
            if(americaCrossStateEmployeeKeys == null) {
                americaCrossStateEmployeeKeys = new List<String> {
                    COUNTRY_USA + '.' + STATE_ILLINOIS + '.' + CITY_CHICAGO,
                    COUNTRY_USA + '.' + STATE_NEW_YORK + '.' + CITY_NEW_YORK,
                    COUNTRY_USA + '.' + STATE_WASHINGTON + '.' + CITY_SEATTLE
                };
            }
            return americaCrossStateEmployeeKeys;
        }set;
    }

    private static List<String> indiaCrossStateEmployeeKeys {
        get {
            if(indiaCrossStateEmployeeKeys == null) {
                indiaCrossStateEmployeeKeys = new List<String> {
                    COUNTRY_INDIA + '.' + STATE_KARNATAKA + '.' + CITY_BANGALORE
                };
            }
            return indiaCrossStateEmployeeKeys;
        }set;
    }

    public static Acquisition_Company__c setupTestAcquisitionCompany(String testIdentifier) {
        Acquisition_Company__c testAcqCompany = new Acquisition_Company__c();
        testAcqCompany.Status__c = ACQ_COMPANY_STATUS;
        testAcqCompany.Close_Date__c = System.today().addDays(90);
        testAcqCompany.Name = ACQ_COMPANY_PREFIX + '.' + testIdentifier;
        testAcqCompany.Acquisition_Company_Name__c = ACQ_COMPANY_PREFIX + '.' + testIdentifier;
        
        insert testAcqCompany;
        return testAcqCompany;
    }

    public static Acquisition_Company__c getTestAcquisitionCompany(String testIdentifier) {
        String acqCompanyName = ACQ_COMPANY_PREFIX + '.' + testIdentifier;
        return [SELECT Id, Name FROM Acquisition_Company__c WHERE Name = :acqCompanyName LIMIT 1];
    }

    public static void setupTestAcquisitionContacts(Acquisition_Company__c acqCompany, Set<Employees> maEmployees) {
        setupTestAcquisitionContacts(acqCompany, maEmployees, SUMMARY_STAGE_NOT_STARTED, PACKAGE_STAGE_NOT_STARTED);
    }

    public static void setupTestAcquisitionContacts(Acquisition_Company__c acqCompany, Set<Employees> maEmployees, String summaryStage) {
        setupTestAcquisitionContacts(acqCompany, maEmployees, summaryStage, PACKAGE_STAGE_NOT_STARTED);
    }

    public static void setupTestAcquisitionContacts(Acquisition_Company__c acqCompany, Set<Employees> maEmployees, String summaryStage, String packageStage) {
        disableTriggersAndAutoEnrolmentFramework();
        Map<String, Acquisition_Contacts__c> executivesMap = getExecutivesMap(acqCompany, getCountryMap(maEmployees), summaryStage, packageStage);
        insert executivesMap.values();

        Map<String, Acquisition_Contacts__c> managersMap = getManagersMap(acqCompany, executivesMap, summaryStage, packageStage);
        insert managersMap.values();

        Map<String, Acquisition_Contacts__c> employeesMap = getEmployeesMap(acqCompany, managersMap, SUMMARY_STAGE_NOT_STARTED, packageStage);
        insert employeesMap.values();

        List<Acquisition_Contacts__c> acqContacts = getAcqContacts(executivesMap, managersMap, employeesMap);
        setupAcquisitionCompensationDetails(acqContacts);
    }

    private static void disableTriggersAndAutoEnrolmentFramework() {
        Acquisition_Contacts_Trigger_Handler.triggerDisabled = true;
        Acquisition_Compensation_TriggerHandler.triggerDisabled = true;
        MA_AutoEnrolmentHelper.DISABLED_AUTO_ENROLMENT_FRAMEWORK = true;
    }

    private static Map<String, Map<String, String>> getCountryMap(Set<Employees> maEmployees) {
        Map<String, Map<String, String>> countryMap = new Map<String, Map<String, String>>();

        for(Employees maEmployee : maEmployees) {
            switch on maEmployee {
                when US_EMPLOYEES {
                    countryMap.put(COUNTRY_USA, new Map<String, String> {STATE_NEW_YORK => CITY_NEW_YORK, STATE_ILLINOIS => CITY_CHICAGO, STATE_WASHINGTON => CITY_SEATTLE, STATE_CALIFORNIA => CITY_SAN_FRANCISCO});
                }when US_NYC_EMPLOYEES {
                    countryMap.put(COUNTRY_USA, new Map<String, String> {STATE_NEW_YORK => CITY_NEW_YORK});
                }when US_IL_EMPLOYEES {
                    countryMap.put(COUNTRY_USA, new Map<String, String> {STATE_ILLINOIS => CITY_CHICAGO});
                }when US_WA_EMPLOYEES {
                    countryMap.put(COUNTRY_USA, new Map<String, String> {STATE_WASHINGTON => CITY_SEATTLE});
                }when US_CAL_EMPLOYEES {
                    countryMap.put(COUNTRY_USA, new Map<String, String> {STATE_CALIFORNIA => CITY_SAN_FRANCISCO});
                }when IN_EMPLOYEES {
                    countryMap.put(COUNTRY_INDIA, new Map<String, String> {STATE_TELANGANA => CITY_HYDERABAD, STATE_KARNATAKA => CITY_BANGALORE});
                }when IN_TEL_EMPLOYEES {
                    countryMap.put(COUNTRY_USA, new Map<String, String> {STATE_TELANGANA => CITY_HYDERABAD});
                }when IN_KA_EMPLOYEES {
                    countryMap.put(COUNTRY_USA, new Map<String, String> {STATE_KARNATAKA => CITY_BANGALORE});
                }
            }
        }

        return countryMap;
    }

    private static Map<String, Acquisition_Contacts__c> getExecutivesMap(Acquisition_Company__c acqCompany, Map<String, Map<String, String>> countryMap, String summaryStage, String packageStage) {
        Map<String, Acquisition_Contacts__c> executivesMap = new Map<String, Acquisition_Contacts__c>();

        for(String country : countryMap.keySet()) {
            Map<String, String> stateMap = countryMap.get(country);
            
            for(String state : stateMap.keySet()) {
                String city = stateMap.get(state);
                
                for(Integer recordNum = 1; recordNum <= EXECUTIVES_PER_STATE; recordNum++) {
                    String executivesMapKey = country + '.' + state + '.' + city + '.' + recordNum;
                    executivesMap.put(executivesMapKey, getAcquisitionContact(acqCompany, null, country, state, city, true, false, summaryStage, packageStage));
                }
            }
        }

        return executivesMap;
    }

    private static Acquisition_Contacts__c getAcquisitionContact(Acquisition_Company__c acqCompany, Acquisition_Contacts__c acqContactManager, String country, String state, String city, Boolean isExecutive, Boolean isManager, String summaryStage, String packageStage) {
        Integer empNum = isExecutive ? executiveNum : isManager ? managerNum : employeeNum;
        Integer empNumModulo2 = Math.mod(empNum, 2);
        Integer empNumModulo3 = Math.mod(empNum, 3);

        String empPrefix = isExecutive ? EXECUTIVE_PREFIX : isManager ? MANAGER_PREFIX : EMPLOYEE_PREFIX;
        String businessTitle = isExecutive ? EXECUTIVE_BUSINESS_TITLE[empNumModulo2] : isManager ? MANAGER_BUSINESS_TITLE[empNumModulo2] : EMPLOYEE_BUSINESS_TITLE[empNumModulo2];

        Acquisition_Contacts__c acqContact = new Acquisition_Contacts__c();
        acqContact.Name = 'testN ' + empPrefix + empNum;
        acqContact.First_Name_Legal__c = 'testFNL ' + empPrefix + empNum;
        acqContact.Last_Name_Legal__c = 'testLNL ' + empPrefix + empNum;
        acqContact.First_Name_Preferred__c = 'testFNP ' + empPrefix + empNum;
        acqContact.Last_Name_Preferred__c = 'testLNP ' + empPrefix + empNum;
        acqContact.Personal_Email_Address__c = empPrefix + empNum + '@testmail.com';
        acqContact.Email_Address_Target__c = empPrefix + empNum + '@' + acqCompany.Name + '.test.com';

        acqContact.Business_Title__c = businessTitle;
        acqContact.Business_Title_Target__c = businessTitle;

        acqContact.Gender__c = GENDERS[empNumModulo2];
        acqContact.Department__c = DEPARTMENTS[empNumModulo2];
        acqContact.Remote_Non_Remote__c = REMOTE_NON_REMOTE[empNumModulo2];
        acqContact.Work_Location_Status__c = WORK_LOCATION_STATUS[empNumModulo3];

        acqContact.Employee_ID_Target__c = empPrefix + empNum;
        acqContact.Executive__c = isExecutive ? true : false;
        acqContact.People_Manager__c = isManager ? true : false;
        acqContact.Key_Critical_Employee__c = isExecutive ? 'Critical' : isManager ? 'Key' : null;

        acqContact.Acquisition_Company__c = acqCompany.Id;

        acqContact.Employee_Type__c = 'Regular';
        acqContact.Pay_Rate_Type__c = 'Salary';
        acqContact.COBRA_Months__c = '12';
        acqContact.Outplacement_Months__c = '12';
        acqContact.Transitional_Employee__c = false;
        acqContact.PTO_Annual_Leave_Days__c = '21';
        acqContact.MA_DS_Envelope_Void_Period_Days__c = 3;
        acqContact.MA_DS_Email_Address_Type__c = 'Email Address (Target)';

        acqContact.Hire_Date__c = System.today().addDays(90);
        acqContact.Confirmed_On__c = Datetime.now().addDays(180);
        acqContact.Hire_Date_Target__c = System.today().addDays(-500);
        acqContact.Probation_End_Date__c = System.today().addDays(180);
        acqContact.Continuous_Service_Date__c = System.today().addDays(90);
        
        acqContact.Office_Address_Country__c = country;
        acqContact.Office_Address_Country_Target__c = country;
        
        acqContact.Office_Address_State_Province__c = state;
        acqContact.Office_Address_State_Province_Target__c = state;

        acqContact.Office_Address_City__c = city;
        acqContact.Office_Address_City_Target__c = city;

        acqContact.Manager_Name__c = acqContactManager?.Id;
        acqContact.Offer_Communicator__c = acqContactManager?.Id;
        acqContact.Manager_Name_Target__c = acqContactManager?.Id;

        acqContact.MuleExtId__c = acqContact.Employee_ID_Target__c + ':' + acqCompany.Name;
        acqContact.Nationality__c = (country == COUNTRY_USA) ? 'American' : (country == COUNTRY_INDIA) ? 'Indian' : null;
        acqContact.Workday_Location__c = (country == COUNTRY_USA) ? (state + ' - ' + city) : (country == COUNTRY_INDIA) ? (country + ' - ' + city) : null;

        acqContact.MA_DS_Custom_Manager_Summary_Email__c = isExecutive ? true : false;
        acqContact.MA_DS_Custom_Package_Envelope_Email__c = isExecutive ? true : false;

        acqContact.MA_DS_Manager_Summary_Email_Body__c = isExecutive ? SUMMARY_EMAIL_BODY + acqContact.Name : null;
        acqContact.MA_DS_Manager_Summary_Email_Subject__c = isExecutive ? SUMMARY_EMAIL_SUBJECT + acqContact.Name : null;

        acqContact.MA_DS_Package_Envelope_Email_Body__c = isExecutive ? PACKAGE_ENVELOPE_EMAIL_BODY + acqContact.Name : null;
        acqContact.MA_DS_Package_Envelope_Email_Subject__c = isExecutive ? PACKAGE_ENVELOPE_EMAIL_SUBJECT + acqContact.Name : null;

        acqContact.MA_DS_Package_Stage__c = packageStage;
        acqContact.MA_DS_Manager_Summary_Stage__c = summaryStage;
 
        if(isExecutive) {
            executiveNum++;
        }else if(isManager) {
            managerNum++;
        }else {
            employeeNum++;
        }

        return acqContact;
    }

    private static Map<String, Acquisition_Contacts__c> getManagersMap(Acquisition_Company__c acqCompany, Map<String, Acquisition_Contacts__c> executivesMap, String summaryStage, String packageStage) {
        Map<String, Acquisition_Contacts__c> managersMap = new Map<String, Acquisition_Contacts__c>();
        
        for(String executivesMapKey : executivesMap.keySet()) {
            List<String> splittedKey = executivesMapKey.split('\\.');

            for(Integer recordNum = 1; recordNum <= MANAGERS_PER_EXECUTIVE; recordNum++) {
                managersMap.put(getAcqContactsMapKey(splittedKey, managerNum), getAcquisitionContact(acqCompany, executivesMap.get(executivesMapKey), splittedKey[0], splittedKey[1], splittedKey[2], false, true, summaryStage, packageStage));
            }
        }

        return managersMap;
    }

    private static String getAcqContactsMapKey(List<String> splittedKey, Integer recordNum) {
        return splittedKey[0] + '.' + splittedKey[1]  + '.' + splittedKey[2] + '.' + recordNum ;
    }

    private static Map<String, Acquisition_Contacts__c> getEmployeesMap(Acquisition_Company__c acqCompany, Map<String, Acquisition_Contacts__c> managersMap, String summaryStage, String packageStage) {
        Map<String, Acquisition_Contacts__c> employeesMap = new Map<String, Acquisition_Contacts__c>();

        for(String managersMapKey : managersMap.keySet()) {
            List<String> splittedKey = managersMapKey.split('\\.');

            for(Integer recordNum = 1; recordNum <= EMPLOYEES_PER_MANAGER; recordNum++) {
                employeesMap.put(getAcqContactsMapKey(splittedKey, employeeNum), getAcquisitionContact(acqCompany, managersMap.get(managersMapKey), splittedKey[0], splittedKey[1], splittedKey[2], false, false, summaryStage, packageStage));
            }

            if(splittedKey[1] == STATE_CALIFORNIA && americaCrossStateEmployeeKeyIndex < americaCrossStateEmployeeKeys.size()) {
                List<String> americaSplittedKey = americaCrossStateEmployeeKeys[americaCrossStateEmployeeKeyIndex].split('\\.');
                employeesMap.put(getAcqContactsMapKey(americaSplittedKey, employeeNum), getAcquisitionContact(acqCompany, managersMap.get(managersMapKey), americaSplittedKey[0], americaSplittedKey[1], americaSplittedKey[2], false, false, summaryStage, packageStage));
                americaCrossStateEmployeeKeyIndex++;
            }else if(splittedKey[1] == STATE_TELANGANA && indiaCrossStateEmployeeKeyIndex < indiaCrossStateEmployeeKeys.size()) {
                List<String> indiaSplittedKey = indiaCrossStateEmployeeKeys[indiaCrossStateEmployeeKeyIndex].split('\\.');
                employeesMap.put(getAcqContactsMapKey(indiaSplittedKey, employeeNum), getAcquisitionContact(acqCompany, managersMap.get(managersMapKey), indiaSplittedKey[0], indiaSplittedKey[1], indiaSplittedKey[2], false, false, summaryStage, packageStage));
                indiaCrossStateEmployeeKeyIndex++;
            }
        }

        return employeesMap;
    }

    private static List<Acquisition_Contacts__c> getAcqContacts(Map<String, Acquisition_Contacts__c> executivesMap, Map<String, Acquisition_Contacts__c> managersMap, Map<String, Acquisition_Contacts__c> employeesMap) {
        List<Acquisition_Contacts__c> acqContacts = new List<Acquisition_Contacts__c>(executivesMap.values());
        acqContacts.addAll(managersMap.values());
        acqContacts.addAll(employeesMap.values());
        return acqContacts;
    }

    private static void setupAcquisitionCompensationDetails(List<Acquisition_Contacts__c> acqContacts) {
        List<Acquisition_Compensation__c> acqCompList = new List<Acquisition_Compensation__c>();

        for(Acquisition_Contacts__c acqContact : acqContacts) {
            Acquisition_Compensation__c acqComp = new Acquisition_Compensation__c();
            acqComp.Acquisition_Contact__c = acqContact.Id;
            acqComp.MuleExtId__c = acqContact.MuleExtId__c;

            Boolean isCountryUSA = (acqContact.Office_Address_Country__c == COUNTRY_USA);
            Boolean isExecutive = acqContact.Executive__c;
            Boolean isManager = acqContact.People_Manager__c;
            Boolean isEnggDept = acqContact.Department__c.equalsIgnoreCase(ENGINEERING_DEPT);

            acqComp.Job_Grade__c = isExecutive ? 8 : isManager ? 5 : 3;
            acqComp.Bonus_Target__c = isExecutive ? 0.33 : isManager ? 0.2 : 0.15;
            acqComp.Bonus_Plan__c = 'Gratitude';
            acqComp.Pay_Rate_Type__c = 'Salary';

            acqComp.Flextime_Eligible__c = true;
            acqComp.On_call_Working__c = false;
            acqComp.Overtime_Ineligible__c = false;

            acqComp.Default_Hours__c = 8;
            acqComp.Scheduled_Hours__c = 8;
            acqComp.Time_Type__c = 'Full Time';

            if(isExecutive) {
                acqComp.Annualized_Base_Salary__c = (isCountryUSA ? executiveBaseSalaries[0] : executiveBaseSalaries[1]) + baseSalaryVariant;
                acqComp.One_Time_Payment_Amount__c = isCountryUSA ? executiveOTPAmount[0] : executiveOTPAmount[1];

                acqComp.Additional_OTP_Amount__c = isCountryUSA ? executiveAdditionalOTPAmount[0] : executiveAdditionalOTPAmount[1];
                acqComp.Additional_OTP_Effective_Date__c = System.today().addDays(365);

                acqComp.Additional_Allowance_Amount__c = isCountryUSA ? executiveAdditionalAllowanceAmount[0] : executiveAdditionalAllowanceAmount[1];
                acqComp.Additional_Allowance_Frequency__c = 'Monthly';

                acqComp.Car_Allowance_Amount__c = isCountryUSA ? executiveCarAllowanceAmount[0] : executiveCarAllowanceAmount[1];
                acqComp.Car_Allowance_Frequency__c = 'Monthly';

                acqComp.Stock_Grant_Date__c = System.today().addDays(90);
                acqComp.Stock_Grant_Amount__c = isCountryUSA ? executiveStockGrant[0] : executiveStockGrant[1];
                acqComp.Additional_Stock_Grant_Amount__c = isCountryUSA ? executiveAdditonalStockGrant[0] : executiveAdditonalStockGrant[1];
            }else if(isManager) {
                acqComp.Annualized_Base_Salary__c = (isCountryUSA ? managerBaseSalaries[0] : managerBaseSalaries[1]) + baseSalaryVariant;
                acqComp.One_Time_Payment_Amount__c = isCountryUSA ? managerOTPAmount[0] : managerOTPAmount[1];

                acqComp.Car_Allowance_Amount__c = isCountryUSA ? managerCarAllowanceAmount[0] : managerCarAllowanceAmount[1];
                acqComp.Car_Allowance_Frequency__c = 'Monthly';

                acqComp.Stock_Grant_Date__c = System.today().addDays(90);
                acqComp.Stock_Grant_Amount__c = isCountryUSA ? managerStockGrant[0] : managerStockGrant[1];
            }else {
                acqComp.Annualized_Base_Salary__c = (isCountryUSA ? employeeBaseSalaries[0] : employeeBaseSalaries[1]) + baseSalaryVariant;
                acqComp.One_Time_Payment_Amount__c = isCountryUSA ? employeeOTPAmount[0] : employeeOTPAmount[1];

                acqComp.Stock_Grant_Date__c = isEnggDept ? System.today().addDays(90) : null;
                acqComp.Stock_Grant_Amount__c = isEnggDept ? isCountryUSA ? employeeStockGrant[0] : employeeStockGrant[1] : 0;
            }

            acqComp.Bonus_Amount__c = acqComp.Bonus_Target__c * acqComp.Annualized_Base_Salary__c;

            baseSalaryVariant += 500;
            acqCompList.add(acqComp);
        }

        insert acqCompList;
    }
}