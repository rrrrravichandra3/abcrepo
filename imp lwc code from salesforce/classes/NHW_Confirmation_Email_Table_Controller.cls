public with sharing class NHW_Confirmation_Email_Table_Controller {
	public String cid{get; set;}
	public Case nhCase{
		get{
			if(nhCase == null){
				nhCase = [SELECT Id, CaseNumber, CreatedDate, Status, First_Name__c, Last_Name__c, Email_Address__c, NHW_Start_Date__c, End_Date__c, 
							Primary_Coverage_Country__c, Office_Address__c, Office_City__c, Office_State_Province__c, Office_Zip_Postal_Code__c, Office_Country__c,
							Floor_Location_Cube_Location__c, NHW_Organization__c, NHW_Role__c, Business_Title__c, Business_Unit_NHW__c,
							Cost_Center_NHW__c, Division__c, Department_Admin_Contact__c, NH_Is_Exact_Target__c, Description, Company_Agency_Name__c,
							Resource_Type__c, Manager_Name__r.Name, Manager_s_Email__c, Onboarding_Buddy_Name__c, Onboarding_Buddy_Email__c,
							NH_Training_Email_Merge__c, Computer_Type__c, Laptop_Type__c, Mobile_Phone_Required__c, Same_as_Office_Location__c, Shipping_Address__c,
							Shipping_City__c, Shipping_State__c, Shipping_Zip_Postal__c, Shipping_Country__c from Case where Id =: cid];
			}
			return nhCase;
		}
		set;
	}

}