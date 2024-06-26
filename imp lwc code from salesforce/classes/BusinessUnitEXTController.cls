public with sharing class BusinessUnitEXTController {
	public Business_Unit_Mapping__c businessUnitMapping {get; set;}
	public List<SelectOption> businessUnit;
	public List<SelectOption> divisions;
	private TF2Settings__c configurations ;
	private List<Business_Unit__c> businessUnitList;
	private String objectkeyPrefix ;
	
	public BusinessUnitEXTController(ApexPages.StandardController controller) {
		this.businessUnitMapping =(Business_Unit_Mapping__c) controller.getRecord();
		this.configurations = TF2Settings__c.getInstance();
		this.businessUnitList = [Select Id,Name,BU_Code__c from Business_Unit__c];
		Schema.DescribeSObjectResult result = Business_Unit_Mapping__c.SObjectType.getDescribe();
		this.objectkeyPrefix = result.getKeyPrefix();
		
	}
	
	
	/**
     * Method to load the business units.
     */
    public List<SelectOption> getBusinessUnit(){
        businessUnit= new List<SelectOption>();
        //businessUnit.add(new SelectOption(Constants.NONE,Constants.NONE));
        if (businessUnitList != null && businessUnitList.size() > 0) {
        	for (Business_Unit__c businessUnitInfo : businessUnitList) {
        		businessUnit.add(new SelectOption(businessUnitInfo.Id,businessUnitInfo.Name));
        	}
        }
        return businessUnit;
    }
    
    /**
     * Method to load the divisions.
     */
    public List<SelectOption> getDivisions(){
        divisions= new List<SelectOption>();
        divisions.add(new SelectOption(Constants.NONE,Constants.NONE));

        List<DynamicValue__c> lst_dynamicValues= DynamicValue__c.getAll().values();
        List<String> lst_divisionEntries = new List<String>();

        for (DynamicValue__c value : lst_dynamicValues) {
            if (value.Type__c == 'Division') {
                lst_divisionEntries.add(value.Name);
            }
        }

        lst_divisionEntries.sort();


            for( String divName : lst_divisionEntries ){
                divisions.add(new SelectOption(divName,divName));
            }


        
        return divisions;
    }
    
    public PageReference saveBusinessUnit() {
    	PageReference pageReference = null;
    	if(businessUnitMapping.Business_Unit__c == null) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Please select a business unit.'));
    	}
    	
    	if(businessUnitMapping.Division__c == null || businessUnitMapping.Division__c == Constants.NONE) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Please select a division.'));
    	}
    	if (businessUnitMappingAlreadyExists(businessUnitMapping)) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'This mapping of business unit and division already exists in the system'));
    	}
    	if (!ApexPages.hasMessages()) {
    		try {
    			
     		    upsert businessUnitMapping;
     		    pageReference = new PageReference('/'+this.objectkeyPrefix+'/o'); 
	     	} catch(Exception ex) {
	     		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage()+ ' Please contact System Administrator '));
	     	}
    	}
    	
    	return pageReference;
    }
    
    public boolean businessUnitMappingAlreadyExists(Business_Unit_Mapping__c businessUnitMapping) {
    	boolean alreadyExists = false;
    	
    	if (businessUnitMapping.Id == null) {
    	
    		for(Business_Unit_Mapping__c businessInfo :[Select id,name,Business_Unit__c,Division__c from Business_Unit_Mapping__c Where Business_Unit__c =: businessUnitMapping.Business_Unit__c AND Division__c =:businessUnitMapping.Division__c]) {
    			alreadyExists = true;
    			break;
    		}
    	} else if (businessUnitMapping.Id != null) {
    		for(Business_Unit_Mapping__c businessInfo :[Select id,name,Business_Unit__c,Division__c from Business_Unit_Mapping__c Where Business_Unit__c =: businessUnitMapping.Business_Unit__c AND Division__c =:businessUnitMapping.Division__c And Id != :businessUnitMapping.Id]) {
    			alreadyExists = true;
    			break;
    		}
    	}
    	
    	return alreadyExists;
    }

}