public with sharing class FBPCustomCTL extends Pagination {
	private static final String FBP_SOQL = 'SELECT Approver_EID__c,Approver_Name__c,CC_Id__c,Cost_Center_ID__c,Department__c,Department__r.Name,Division__c,FBP_Offer_Approver__c,Global_ESBP__c,Id,Name,Regional_ESBP__c,Region__c FROM Regional_FBP_Lookup__c ';
	public List<FBPInfo> fbpInfoCompleteList {get;set;}
	public List<FBPInfo> fbpInfoList {get; private set;}
	public List<SelectOption> regions;
	public String division {get; set;}
	public List<SelectOption> divisions;
	private TF2Settings__c configurations ;
	public List<String> selectedRegions {get;set;}
	public List<SelectOption> departments;
	public List<String> selectedDepartments {get;set;}
	public boolean showFilter {get;set;} 
	public boolean showModifyScreen {get;set;}
	public Regional_FBP_Lookup__c fbpLookup {get; set;}
	
	
	/**
	  Constructor
	**/  
	public FBPCustomCTL() {
		this.selectedRegions = new List<String>();
		this.selectedDepartments = new List<String>();
		this.division = '';
		this.configurations = TF2Settings__c.getInstance();
        this.showFilter = false;
        this.showModifyScreen = false;
        this.fbpLookup = new Regional_FBP_Lookup__c ();
		// loading the FBP data.
		this.fbpInfoCompleteList = loadFBPData(this.division, this.selectedRegions,this.selectedDepartments);
		this.currentPage = 1; 
		if (fbpInfoCompleteList !=null && fbpInfoCompleteList.size() > 0) {
             getPaginationNotesData();
        }

	}
	
	
	/**
     * Method to load only 25 records a time and do the pagination.
     *
     */
    public override void getPaginationNotesData() {
    	Integer dispRows = 25;
    	Integer recordCount = fbpInfoCompleteList.size();
    	fbpInfoList = new List<FBPInfo>();
        Integer modVal = 0; 
        if (recordCount > 0) {
    	    modVal = Math.mod(recordCount, dispRows);
            noOfpages = recordCount / dispRows;
        }
        //---check to see if the records pulled are greater than 25 , to see how many pages we have to display.
        if (modVal > 0) {
            noOfpages++;
        }
        //---Showing at least on page.
        if (noOfpages == 0) {
            noOfpages++;
        }
        if (currentPage > noOfpages) {
         	 currentPage = noOfpages;
        }
        //---Set the Page start and end positions
    	
    	try {
    		Integer startIndex = (currentPage - 1) * dispRows;
    		Integer endIndex = (startIndex+dispRows >= recordCount) ? recordCount : startIndex+dispRows;
    		if ((fbpInfoCompleteList != null && fbpInfoCompleteList.size() > 0) ) {
	            for (Integer i=startIndex; i<endIndex; i++) {
	            	fbpInfoList.add(fbpInfoCompleteList.get(i));
	            }
    		}
    		
    	} catch (Exception ex) {
    		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(msg);
    	}
    	
    }
	
	/**
	 * Loading the fbp data to a custom object.
	 * @param fbpList is a list.
	 * @return fbpInfoList is alist
	 */
	private List<FBPInfo> processFBPData(List<Regional_FBP_Lookup__c> fbpList) {
		List<FBPInfo> fbpInfoList = new List<FBPInfo> ();
		if (fbpList != null && fbpList.size() > 0) {
			for(Regional_FBP_Lookup__c fbpData : fbpList) {
				fbpInfoList.add(new FBPInfo(fbpData) );
			}
		}
		
		return fbpInfoList;
	}
	
	/**
	 * Method to query the fbp data from the Databsase.
	 * @param division is a string.
	 * @param selectedRegions is a List.
	 * @param selectedDepartments is a list.
	 * @return fbpList is a list.
	 */
	private List<FBPInfo> loadFBPData(String division ,List<String> selectedRegions,List<String> selectedDepartments) { 
		List<FBPInfo> fbpList =null;
		
		
		String fbpSoqlQuery = FBP_SOQL;
		Boolean whereClauseAdded = false;
		if (division != null && division.trim().length() > 0 && division != Constants.NONE) {
			fbpSoqlQuery = fbpSoqlQuery + ' Where Division__c = \''+ String.escapeSingleQuotes(division) + '\'';
			whereClauseAdded = true;
		}
		if (selectedRegions != null && selectedRegions.size() > 0) {
			if (!whereClauseAdded) {
				fbpSoqlQuery = fbpSoqlQuery + ' Where Region__c IN ' +  String.escapeSingleQuotes(Utils.buildInExpression(selectedRegions));
			} else {
				fbpSoqlQuery = fbpSoqlQuery + ' AND Region__c IN ' +  String.escapeSingleQuotes(Utils.buildInExpression(selectedRegions));
			}
			whereClauseAdded = true;
		}
		if (selectedDepartments != null && selectedDepartments.size() > 0) {
			
			if (!whereClauseAdded) {
				fbpSoqlQuery = fbpSoqlQuery + ' Where Department__c IN ' +  String.escapeSingleQuotes(Utils.buildInExpression(selectedDepartments)) ;
			} else {
				fbpSoqlQuery = fbpSoqlQuery + ' AND Department__c IN ' +  String.escapeSingleQuotes(Utils.buildInExpression(selectedDepartments)) ;
			}			
		}
		// loading the fbp data to custom object.
		fbpList = processFBPData(Database.query(fbpSoqlQuery));
		return fbpList;
	}
	
	 /**
     * Method to load the divisions.
     */
    public List<SelectOption> getDivisions(){
        divisions= new List<SelectOption>();
        divisions.add(new SelectOption(Constants.NONE,Constants.NONE));
        if(this.configurations !=null && this.configurations.Division_PickList_Values__c != null) {
	        for(String divisionName : this.configurations.Division_PickList_Values__c.split(Constants.COMMA)){
	            divisions.add(new SelectOption(divisionName,divisionName));
	        }
        }
        
        return divisions;
    }
    
    
     /**
     * Method to load the regions.
     */
    public List<SelectOption> getRegions(){
        regions= new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = ts2__Job__c.Region__c.getDescribe();
        if (fieldResult != null) {
        	for(Schema.PicklistEntry pickListEntry : fieldResult.getPicklistValues()) {
        		regions.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getValue()));
        	}
        }
        return regions;
    }

   /**
     * Method to load the departments.
     */
    public List<SelectOption> getDepartments(){
        departments= new List<SelectOption>();
        for(TF2_Department__c departmentInfo : [Select id,name from TF2_Department__c order by Department_Number__c ASC]) {
        	departments.add(new SelectOption(departmentInfo.Id,departmentInfo.Name));
        }
        return departments;
    }
    
   /**
     * Method to show the filter options like department, region and division.
     */    
    public PageReference showFilter() {
     	this.showFilter = true;
     	this.showModifyScreen = false;
     	this.selectedDepartments.clear();
		this.selectedRegions.clear();
		this.division ='';
     	return null;
     }
     
     /**
      * Method to get the user choices and apply the filters and retrieve the data from database.
      *
      */
     public PageReference applyFilter() {
     	this.showFilter = false;
     	this.fbpInfoCompleteList.clear();
     	this.fbpInfoList.clear();
     	this.fbpInfoCompleteList = loadFBPData(this.division, this.selectedRegions,this.selectedDepartments);
		this.currentPage = 1; 
		if (fbpInfoCompleteList !=null && fbpInfoCompleteList.size() > 0) {
             getPaginationNotesData();
        } else {
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No data found based on your filters.'));
        }
     	return null;
     }
     
     /**
      * Method to present the modification screen to the user.
      */
     public PageReference showModifyScreen() {
           this.showFilter = false;	
           this.showModifyScreen = true;
           this.fbpLookup = new Regional_FBP_Lookup__c();
           return null; 
     }
     
     /**
      * Method to update the values chosen by user to update (Job Req approver, Offer approver and Regional ESBP)
      */
     public PageReference applyValue() {
     	
     	Set<String> approverNameSet = new Set<String>();
     	if (fbpLookup.Approver_Name__c == null && fbpLookup.FBP_Offer_Approver__c == null && fbpLookup.Regional_ESBP__c == null) {
     		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Please select enter atleast one name to update'));
     	} else {
     		
     	    if(fbpLookup.FBP_Offer_Approver__c != null) {
     		    approverNameSet.add(fbpLookup.FBP_Offer_Approver__c);
     	    }  
     	    if(fbpLookup.Approver_Name__c != null) {
     		    approverNameSet.add(fbpLookup.Approver_Name__c);
     	    }
     	    if(fbpLookup.Regional_ESBP__c != null) {
     		   approverNameSet.add(fbpLookup.Regional_ESBP__c);
     	    }
     	}
        // checking for atleast one record is chosen.		
     	if (this.fbpInfoCompleteList != null && this.fbpInfoCompleteList.size() > 0) {
     		boolean atleastOneSelected = false;
     		for(FBPInfo fbpDetails : this.fbpInfoCompleteList ) {
     			if (fbpDetails.getSelectedFBP()) {
     				atleastOneSelected = true;
     				break;
     			}
     		}
     		if (!atleastOneSelected) {
     			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Please select at least one record to update'));
     		}
     	}
     	// checking if the approver names entered by the user are valid or not.
     	if (approverNameSet.size() > 0 && !ApexPages.hasMessages()) {
     		Map<String, User> approversMap = JobRequisitionUtils.getApproverDetails(approverNameSet); 
     		if (approversMap != null && approversMap.size() > 0) {
     			if (fbpLookup.FBP_Offer_Approver__c != null && !approversMap.containsKey(fbpLookup.FBP_Offer_Approver__c)) {
     				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Offer Approver name is incorrect or inactive. Please check with System Administrator'));
     			}
     			if (fbpLookup.Approver_Name__c != null && !approversMap.containsKey(fbpLookup.Approver_Name__c)) {
     				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Job Requisition Approver name is incorrect or inactive. Please check with System Administrator'));
     			}
     			if (fbpLookup.Regional_ESBP__c != null && !approversMap.containsKey(fbpLookup.Regional_ESBP__c)) {
     				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Regional ESBP Approver name is incorrect or inactive. Please check with System Administrator'));
     			}
     		} else {
     			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Approver names are incorrect or inactive. Please check with System Administrator'));
     		}
     	}
     	if (!ApexPages.hasMessages()) {
     		try {
    			List<Regional_FBP_Lookup__c>  updateList = new List<Regional_FBP_Lookup__c>();
    			Regional_FBP_Lookup__c fbpInfo = null;
    			// loading the values to the regional fbp objects and doing a mass update.
    			for(FBPInfo fbpDetails : this.fbpInfoCompleteList ) {
    				if (fbpDetails.getSelectedFBP()) {
    					fbpInfo = fbpDetails.getFbpInfo();
    					if (fbpLookup.FBP_Offer_Approver__c != null) {
    						fbpInfo.FBP_Offer_Approver__c = fbpLookup.FBP_Offer_Approver__c;
    					}
    					if (fbpLookup.Approver_Name__c != null) {
    						fbpInfo.Approver_Name__c = fbpLookup.Approver_Name__c;
    					}
    					if (fbpLookup.Regional_ESBP__c != null) {
    						fbpInfo.Regional_ESBP__c = fbpLookup.Regional_ESBP__c;
    					}
    					updateList.add(fbpInfo);
    				}
    			}
     		    upsert updateList;
     		    this.showModifyScreen = false;
     		    this.fbpInfoCompleteList.clear();
     		    // reloading the data from the DB after update.
     		    this.fbpInfoCompleteList = loadFBPData(this.division, this.selectedRegions,this.selectedDepartments);
     		    this.currentPage = 1; 
				if (fbpInfoCompleteList !=null && fbpInfoCompleteList.size() > 0) {
		             getPaginationNotesData();
		        }
		        this.fbpLookup = new Regional_FBP_Lookup__c();
		        this.selectedDepartments.clear();
		        this.selectedRegions.clear();
		        this.division ='';
     		    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Successfully updated the values.')); 
	     	} catch(Exception ex) {
	     		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage()+ ' Please contact System Administrator '));
	     	}
     	}
     	return null;
     }
     
     /*
       * Method to present complete data to the user.
      */
     public PageReference showAllData() {
         this.selectedDepartments.clear();
		 this.selectedRegions.clear();
		 this.division ='';
		 this.fbpInfoCompleteList = loadFBPData(this.division, this.selectedRegions,this.selectedDepartments);
		 this.currentPage = 1; 
		 if (fbpInfoCompleteList !=null && fbpInfoCompleteList.size() > 0) {
             getPaginationNotesData();
         }
         return null; 
     }
     
       /*
       * Method to present complete data to the user.
      */
     public PageReference clearValue() {
     	 if (this.showFilter) {
	         this.selectedDepartments.clear();
			 this.selectedRegions.clear();
			 this.division ='';
     	 } else if (this.showModifyScreen) {
     	 	this.fbpLookup = new Regional_FBP_Lookup__c();
     	 }
         return null; 
     }
     

}