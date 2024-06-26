public with sharing class FilteredJobsCtrl {
	private List<JobInfo> jobList {get; set;}
 	public  Integer DISPLAY_ROWS = 120;
	public  Integer MAX_ROWS = 800;
	private TF2Settings__c configurations;
 	private ApexPages.StandardSetController paginator;
 	public String gridSortField {get;set;}
	public String sortOrder {get;set;}
	public String locationName {get; private set;}
	public String countryName {get; private set;}
	public String categoryName {get; private set;}
	public String divisionName {get; private set;}
	public String businessunitName {get; private set;}
	private boolean category_flag {get; set;}
	private boolean location_flag { get; set; }
	private boolean division_flag { get; set; }
	private boolean country_flag { get; set; } 
	private boolean bu_flag { get; set; }
	
	public FilteredJobsCtrl(){
		boolean filterCriteria = false;
		//Assuming all inputs are good
		category_flag = true;
		location_flag = true;
		division_flag = true;
		country_flag = true;
		bu_flag = true;
		
		configurations = TF2Settings__c.getInstance();
		List<TF2_Location_Currency_Mapping__c> locationCurrencyList = [SELECT Name, Location_Code__c,Country_ISO_Code__c,Country__c FROM TF2_Location_Currency_Mapping__c];
		String categoryName = System.currentPageReference().getParameters().get('category');
		String location = System.currentPageReference().getParameters().get('location');
		String division = System.currentPageReference().getParameters().get('division');
		String country = System.currentPageReference().getParameters().get('country');
		String businessunitName = System.currentPageReference().getParameters().get('businessunit');


		if(businessunitName != null && businessunitName.length()>0){
			if( Utils.checkBusinessUnitExists(businessunitName) ){
				filterCriteria = true;
			} else {
				bu_flag = false;
			}
		}
				
		if(categoryName != null && categoryName.length() > 0) {
			if(Utils.checkJobCategoryExists(categoryName)) {
				filterCriteria = true;
			} else{
				category_flag = false;
			}
		}

		if(division != null && division.length() > 0) {
  		    divisionName = Utils.checkDivisionExists(division);
  		    if(divisionName != null && divisionName.length() > 0) {
				filterCriteria = true;
			} else {
				division_flag = false;
  		    }
		}

		if(location != null && location.length() > 0){
			for(TF2_Location_Currency_Mapping__c locationDetails : locationCurrencyList) {
				if (locationDetails != null && locationDetails.Location_Code__c.equalsIgnoreCase(location)) {
					locationName = locationDetails.Name;
					break;
				}
			}
			if(locationName != null && locationName.length() > 0) {
				filterCriteria = true;
			} else {
				location_flag = false;
			}
		}
		
		if(country != null && country.trim().length() > 0) {
			for(TF2_Location_Currency_Mapping__c locationDetails : locationCurrencyList) {
				if (locationDetails != null && locationDetails.Country_ISO_Code__c != null && locationDetails.Country_ISO_Code__c.equalsIgnoreCase(country)) {
					countryName =locationDetails.Country__c; 
					break;
				}
			}
            if(countryName != null && countryName.length() > 0) {
				filterCriteria = true;
			} else {
				country_flag = false;
			}
		}
		if(!filterCriteria) {
			DISPLAY_ROWS = MAX_ROWS;
		}

		if (!filterCriteria) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No jobs fit your criteria. Below is a full listing of open positions at Salesforce.com.' ));
		}
		//this.jobList = Utils.getJobsByLocationByCategory(location, category, MAX_ROWS);
	}
	public String getJobSite() {
		return configurations.External_Job_Site_URL__c;
	}
    public List<JobInfo> getJobs() {
 		return jobList;
    }
    
    public PageReference doSort4Grid(){	
		if(sortOrder == null || sortOrder == ''){
			sortOrder = 'ASC';
		}
		jobList = Utils.getJobsByLocationByCategory(paginator,configurations.Job_Details_Site_URL__c);		
		return null;
	}
	//paginated pages
	public Boolean hasNext {
		get {
			return paginator.getHasNext();
		}
		set;
	}
 
	// indicates whether there are more records before the current page set.
	public Boolean hasPrevious {
		get {
			return paginator.getHasPrevious();
		}
		set;
	}
 
	// returns the page number of the current page set
	public Integer pageNumber {
		get {
			return paginator.getPageNumber();
		}
		set;
	}
 
	// returns the first page of records
 	public void first() {
 		paginator.first();
		jobList = Utils.getJobsByLocationByCategory(paginator,configurations.Job_Details_Site_URL__c);
 	}
 
 	// returns the last page of records
 	public void last() {
 		paginator.last();
		jobList = Utils.getJobsByLocationByCategory(paginator,configurations.Job_Details_Site_URL__c);
 	}
 
 	// returns the previous page of records
 	public void previous() {
 		paginator.previous();
		jobList = Utils.getJobsByLocationByCategory(paginator,configurations.Job_Details_Site_URL__c);
 	}
 
 	// returns the next page of records
 	public void next() {
 		paginator.next();
		jobList = Utils.getJobsByLocationByCategory(paginator,configurations.Job_Details_Site_URL__c);
 	}
 
 	// returns the PageReference of the original page, if known, or the home page.
 	public void cancel() {
 		paginator.cancel();
 	}    
}