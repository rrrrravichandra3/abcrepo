public without sharing class NHW_TestDataHelper {

    private static final String JOB_TITLE = 'Tableau Success Technician (Tier 2)';
    
    public static List<Business_Unit__c> businessUnits = new List<Business_Unit__c>{
        new Business_Unit__c(Name = 'A', BU_Code__c = '0001'),
        new Business_Unit__c(Name = 'B', BU_Code__c = '0002'),
        new Business_Unit__c(Name = 'C', BU_Code__c = '0003'),
        new Business_Unit__c(Name = 'D', BU_Code__c = '0004'),
        new Business_Unit__c(Name = 'E', BU_Code__c = '0005')};
                
            //Cost centers
    public static List<TF2_Department__c> costCenters = new List<TF2_Department__c>{
        new TF2_Department__c(Name = 'CCA', Department_Number__c = 'CCA'),
        new TF2_Department__c(Name = 'CCB', Department_Number__c = 'CCB'),
        new TF2_Department__c(Name = 'CCC', Department_Number__c = 'CCC'),
        new TF2_Department__c(Name = 'CCD', Department_Number__c = 'CCD'),
        new TF2_Department__c(Name = 'CCE', Department_Number__c = 'CCE')
    };
                            
    public static  List<NH_Profile__c> profiles = new List<NH_Profile__c>{
        new NH_Profile__c(Name = 'IT', Grouping_Category__c = 'BU CC', Type__c = 'Organization'),
        new NH_Profile__c(Name = 'T&P', Grouping_Category__c = 'BU CC', Type__c = 'Organization'),
        new NH_Profile__c(Name = 'Finance', Grouping_Category__c = 'BU CC', Type__c = 'Organization'),
        new NH_Profile__c(Name = 'MarketingCloud', Grouping_Category__c = 'BU CC', Type__c = 'Organization'),
        new NH_Profile__c(Name = 'MarketingCloud Laptop', Grouping_Category__c = 'BU CC', Type__c = 'Laptop')};
                                    
    public static List<NH_BU_CC_Profile__c> buccprofiles;
    
    public static List<NHW_Provisioning__c> provisionings = new List<NHW_Provisioning__c>{
        new NHW_Provisioning__c(Type__c = 'Application', Filter_Criteria__c = 'Primary_Coverage_Country__c != 100-United States of America && Primary_Coverage_Country__c != 128-Brazil'),
        new NHW_Provisioning__c(Type__c = 'Application', Filter_Criteria__c = 'NHW_Role__c == Services || NHW_Role__c == Support && NH_ET_Team__c == Platinum'),

        new NHW_Provisioning__c(Name = 'App-Finance', Type__c = 'Application', Profile_Criteria__c = 'Finance;MarketingCloud'),
        new NHW_Provisioning__c(Name = 'App-NoFinance', Type__c = 'Application', Profile_Criteria__c = '!Finance;MarketingCloud'),
            
        new NHW_Provisioning__c(Type__c = 'Application', Filter_Criteria__c = 'NHW_Role__c =IN AB|CD'),
        new NHW_Provisioning__c(Type__c = 'Application', Filter_Criteria__c = 'NHW_Role__c !IN AB|CD'),
        
        new NHW_Provisioning__c(Type__c = 'Application', Filter_Criteria__c = 'NHW_Role__c =% B'),
        new NHW_Provisioning__c(Type__c = 'Application', Filter_Criteria__c = 'NHW_Role__c !% C'),
            
        new NHW_Provisioning__c(Type__c = 'Application', Filter_Criteria__c = 'NHW_Role__c != null'),
        new NHW_Provisioning__c(Type__c = 'Application', Filter_Criteria__c = 'NHW_Role__c == null')
    };
        
    public static void loadProvisioningsTestData(){
        INSERT provisionings;
    }

    public static void loadProfilesTestData(){

        INSERT businessUnits;
        INSERT costCenters;
        INSERT profiles;
        
        buccprofiles = new List<NH_BU_CC_Profile__c>{
            
            new NH_BU_CC_Profile__c(NH_Profile__c = profiles[0].Id, Business_Unit__c = businessUnits[0].Id, Cost_Center__c = costCenters[0].Id),
            new NH_BU_CC_Profile__c(NH_Profile__c = profiles[0].Id, Business_Unit__c = businessUnits[1].Id),
            new NH_BU_CC_Profile__c(NH_Profile__c = profiles[0].Id, Cost_Center__c = costCenters[1].Id),
                
            new NH_BU_CC_Profile__c(NH_Profile__c = profiles[1].Id, Business_Unit__c = businessUnits[0].Id, Cost_Center__c = costCenters[1].Id),
            new NH_BU_CC_Profile__c(NH_Profile__c = profiles[1].Id, Business_Unit__c = businessUnits[1].Id, Cost_Center__c = costCenters[0].Id),
                
            new NH_BU_CC_Profile__c(NH_Profile__c = profiles[2].Id, Business_Unit__c = businessUnits[0].Id),
            new NH_BU_CC_Profile__c(NH_Profile__c = profiles[2].Id, Cost_Center__c = costCenters[1].Id),
            new NH_BU_CC_Profile__c(NH_Profile__c = profiles[2].Id, Business_Unit__c = businessUnits[2].Id, Cost_Center__c = costCenters[2].Id),
                
            new NH_BU_CC_Profile__c(NH_Profile__c = profiles[3].Id, Business_Unit__c = businessUnits[1].Id),
            new NH_BU_CC_Profile__c(NH_Profile__c = profiles[3].Id, Cost_Center__c = costCenters[0].Id),
            new NH_BU_CC_Profile__c(NH_Profile__c = profiles[3].Id, Business_Unit__c = businessUnits[2].Id, Cost_Center__c = costCenters[2].Id),
            
            new NH_BU_CC_Profile__c(NH_Profile__c = profiles[4].Id, Business_Unit__c = businessUnits[0].Id, Cost_Center__c = costCenters[0].Id),
            new NH_BU_CC_Profile__c(NH_Profile__c = profiles[4].Id, Business_Unit__c = businessUnits[1].Id),
            new NH_BU_CC_Profile__c(NH_Profile__c = profiles[4].Id, Cost_Center__c = costCenters[1].Id),
            new NH_BU_CC_Profile__c(NH_Profile__c = profiles[4].Id, Business_Unit__c = businessUnits[3].Id, Cost_Center__c = costCenters[3].Id)
        };
        
        INSERT buccprofiles;        
    }

    public static  List<NH_Profile__c> tableauprofiles = new List<NH_Profile__c>{
        new NH_Profile__c(Name = 'Tableau Laptops', Grouping_Category__c = 'BU CC JobProfile', Type__c = 'Laptop')
    };
                                    
    public static List<NH_BU_CC_Profile__c> tableaubuccprofiles;
    
    public static List<NHW_Provisioning__c> tableauprovisionings = new List<NHW_Provisioning__c>{

        new NHW_Provisioning__c(Name = '13“ MacBook Pro Touchbar', Type__c = 'Laptop', Profile_Criteria__c = 'Tableau Laptops',Filter_Criteria__c = '*')

    };
        
    public static void loadtableauProvisioningsTestData(){
        INSERT tableauprovisionings;
    }    

    public static void loadTableauProfilesTestData(){

        INSERT businessUnits;
        INSERT costCenters;
        INSERT tableauprofiles;
        
        tableaubuccprofiles = new List<NH_BU_CC_Profile__c>{
            
            new NH_BU_CC_Profile__c(NH_Profile__c = tableauprofiles[0].Id, Business_Unit__c = businessUnits[0].Id, Cost_Center__c = costCenters[0].Id,Job_Title__c = JOB_TITLE),
            new NH_BU_CC_Profile__c(NH_Profile__c = tableauprofiles[0].Id, Business_Unit__c = businessUnits[1].Id,Job_Title__c = JOB_TITLE),
            new NH_BU_CC_Profile__c(NH_Profile__c = tableauprofiles[0].Id, Cost_Center__c = costCenters[1].Id,Job_Title__c = JOB_TITLE),
            new NH_BU_CC_Profile__c(NH_Profile__c = tableauprofiles[0].Id)
        };
        
        INSERT tableaubuccprofiles;        
    }
    
}