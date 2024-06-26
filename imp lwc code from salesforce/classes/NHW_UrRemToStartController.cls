public with sharing class NHW_UrRemToStartController {

	private Boolean valuesCalculated = false;
	public String caseId{ get; set; }
	public Case nhCase{
		get{ 
			if(nhCase == null){
				nhCase = [SELECT Id, First_Name__c, Manager_First_Name__c, Last_Name__c, Manager_Last_Name__c from Case where Id= : caseId];
			}
			return nhCase; 
		}
		set;
	}

	private static Map<String,String> ccToProfileMap = new Map<String,String>();
    private static Map<String,String> buToProfileMap = new Map<String,String>();
    private static Map<String,NHW_Default_Profiles__c> dpHardwareOptionsMap = new Map<String,NHW_Default_Profiles__c>();

	static{
		for(NHW_DP_Cost_Centers__c ccRec:NHW_DP_Cost_Centers__c.getall().values()){
            if(ccRec.Cost_Centers_id__c != null && ccToProfileMap.get(ccRec.Cost_Centers_id__c) == null){
                ccToProfileMap.put(ccRec.Cost_Centers_id__c,ccRec.Profile_Name__c);
            }
        }
        for(NHW_DP_Cost_Centers__c buRec:NHW_DP_Cost_Centers__c.getall().values()){
            if(buRec.Business_Unit_Id__c != null && buToProfileMap.get(buRec.Business_Unit_Id__c) == null){
                buToProfileMap.put(buRec.Business_Unit_Id__c+buRec.Profile_Name__c,buRec.Profile_Name__c);
            }
        }
        
        for(NHW_Default_Profiles__c dp:NHW_Default_Profiles__c.getall().values()){
            if(dp.Profile_Name__c != null && dpHardwareOptionsMap.get(dp.Profile_Name__c) == null){
                dpHardwareOptionsMap.put(dp.Profile_Name__c,dp);
            }
        }
    }

	public String emailAddress{
		get;
		set;
	}

	public String costCenter{
		get;
		set{
			if (value != null && value != '') {
				costCenter = value.split('-',-1)[0];
			}else{
				costCenter = null;
			}
		}
	}

	public String businessUnit{
		get;
		set{

			if(value != null && value != ''){
				businessUnit = value.split('-',-1)[0];
			}else{
				businessUnit = null;
			}

		}
	}

	public String imageAndAccess{
		get{
			if(!valuesCalculated){
				calculateValues();
			}
			return imageAndAccess;
		}
		private set;
	}

	public String laptop{
		get{
			if(!valuesCalculated){
				calculateValues();
			}
			return laptop;
		}
		private set;
	}

	public String workstation{
		get{
			if(!valuesCalculated){
				calculateValues();
			}
			return workstation;
		}
		private set;
	}

	public String workstationImage{
		get{
			if(!valuesCalculated){
				calculateValues();
			}
			return workstationImage;
		}
		private set;
	}

	private String businessUnitKey{
		get{
			if(businessUnitKey == null){
				businessUnitKey = businessUnit + ccToProfileMap.get(costCenter);
			}
			return businessUnitKey;
		}
		private set;
	}

	public Boolean standardEmployee{
		get{
			if(standardEmployee == null){
				standardEmployee = !(buToProfileMap.get(businessUnitKey) != null && 
                               buToProfileMap.get(businessUnitKey) == ccToProfileMap.get(costCenter) &&
                               dpHardwareOptionsMap.get(ccToProfileMap.get(costCenter)) != null);
			}
			return standardEmployee;
		}
		private set;
	}

	private void calculateValues(){

		if(!standardEmployee){

			NHW_Default_Profiles__c profileOptions = dpHardwareOptionsMap.get(ccToProfileMap.get(costCenter));

			if(profileOptions != null){
				imageAndAccess = profileOptions.Image_and_Access__c;
				laptop = profileOptions.Laptop__c;
				workstation = profileOptions.Workstation__c;
				workstationImage = profileOptions.Workstation_Image__c;
			}
		}

		valuesCalculated = true;
	}

	public String getDivision(){
		String caseDivision =  ccToProfileMap.get(costCenter);
		if(caseDivision == null) return 'Other';
		else return caseDivision;
	}

	public String getDefaultOptions(){
		if(!standardEmployee){
			String division = ccToProfileMap.get(costCenter);
			if(division != null && division == 'Finance'){
				return Label.NHW_Default_Provisioning_Finance;
			}else if(division != null && division == 'T&P'){
				return Label.NHW_Default_Provisioning_T_P;
			}else if(division != null && division == 'IT'){
				return Label.NHW_Default_Provisioning_IT;
			}else{
				return null;
			}
		}else{
			return null;
		}
	}
}