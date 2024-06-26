/*
 * RelEng Perforce/RCS Header - Do not remove!
 *
 * $Author:  $
 * $Change:  $
 * $DateTime:  $
 * $File:  $
 * $Id:  $
 * $Revision:  $
 */

/*
 * this class will take an account and assign it to a user.
 * @author 
*/
   
public with sharing class PerformanceESBPAdminController { 

	public list<PerformanceReviewWrapper> performanceReviewsWrapper;

	String pcommFilter = System.currentPageReference().getParameters().get('pcomm');
	String prpFilter = System.currentPageReference().getParameters().get('prp');
	String status = System.currentPageReference().getParameters().get('status');
	private String effectiveDate = '';
	Public integer max = 60;
	Public integer maxSelect = 1000;
	String last = '0';
	Public integer idx = 0;
	Map<Integer, String> indexList = new Map<Integer, String>{0=>'0'};
	PerformanceReview__c lastPr;
	boolean next = true;
	integer listSize;
	//this variables are used for the translation
	String PCOMMLabel = 'PCOMM';
	String LaunchedLabel = 'Launched';
	String pcommFilterReport = '';
	String managerFilterReport = '';
	
	Boolean noMatches;
	String lastId = '';
	String firstId = '';
	String lastName = '';
	String firstName = '';
	String lastStatus = '';
	String firstStatus = '';
	boolean isNext = true;
	boolean isPrev = false;
	boolean orderByStatus = false;
	boolean orderByName = true;
	boolean desccByStatus = false;
	boolean descByName = false;
	boolean enter = false;
	Integer colNumber;
	Long totalPages;
	Long currentPage = 1;
	
	private Integer hiddenNumberOfPages;
	public PerformanceESBPAdminController() {
		if (pcommFilter == null) pcommFilter = '0';
		if (prpFilter == null) prpFilter = '0';
		
		effectiveDate = System.currentPageReference().getParameters().get('effectiveDate');
		
		if (effectiveDate == null)
		{
			effectiveDate = 'All';	
		}
		
		if (status == null)
		{
			status = 'All';	
		}
		
		totalPages = Math.round(getNumberOfPages());
		
	}

	
	public List<SelectOption> getEffectiveDate() {
		List<SelectOption> options = new List<SelectOption>();

		options.add(new SelectOption('All', 'All'));
		options.add(new SelectOption('FY08', 'FY08'));
		options.add(new SelectOption('FY09', 'FY09'));
		options.add(new SelectOption('FY10', 'FY10'));
	
		return options;
	}
	
	 /**
    * Return all effective Dates
    */
    public List<SelectOption> getAllEffectiveDates()
	{
		List<String> effectiveDates = new List<String>();
		List<SelectOption> options = new List<SelectOption>();
		Boolean showNext = false;
			
		Schema.DescribeFieldResult fieldResult = V2MOM__c.Effective_Date__c.getDescribe();

		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		
	  	for( Schema.PicklistEntry f : ple)
	   	{
	     
	      	effectiveDates.add(f.getLabel());  
	   }   
      	
      	for (Integer i = effectiveDates.size() ; i > 0 ; i --)
      	{
      		options.add(new SelectOption(effectiveDates[i - 1], effectiveDates[i - 1]));	
      	}
      
        return options;
        
	}
	
	/**
    * Return all effective Dates for the performance review filter
    */
    public List<SelectOption> getAllEffectiveDatesPR()
	{
		List<String> effectiveDates = new List<String>();
		List<SelectOption> options = new List<SelectOption>();
		Boolean showNext = false;
			
		Schema.DescribeFieldResult fieldResult = V2MOM__c.Effective_Date__c.getDescribe();

		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		
		options.add(new SelectOption('All', 'All'));
		
	  	for( Schema.PicklistEntry f : ple)
	   	{
	     
	      	effectiveDates.add(f.getLabel());  
	   }   
      	
      	for (Integer i = 0 ; i < effectiveDates.size()  ; i ++)
      	{
      		options.add(new SelectOption(effectiveDates[i], effectiveDates[i]));	
      	}
      
        return options;
        
	}
	
	 /**
    * Return default effective Date
    */
	public String getDefaultEffectiveDateAll()
	{
		Schema.DescribeFieldResult fieldResult = V2MOM__c.Effective_Date__c.getDescribe();

		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		
	  	for( Schema.PicklistEntry f : ple)
	   	{
	     	if (f.isDefaultValue())
	     	{
	      		return f.getLabel();
	     	}  
	   }   
	   
	   return '';
	}
	
	
	public void setEffectiveDate(String effectiveDateValue)
	{
		effectiveDate = effectiveDateValue;
	}
	
	public String getPcommFilterReport()
	{
		return pcommFilterReport;
	}
	public void setPcommFilterReport(String value)
	{
		pcommFilterReport =  value;
	}
	
	public void setManagerFilterReport(String value)
	{
		managerFilterReport = value;
	}
	
	public String getManagerFilterReport()
	{
		return managerFilterReport;
	}
	
	public List<SelectOption> getPCOMMOptions() {
		List<SelectOption> options = new List<SelectOption>();

		options.add(new SelectOption('0', Label.PerformanceESBPAdminController_AllLabel));
		for(User u: [select u.Name
		             from User u
		             where u.Profile.Name =: PCOMMLabel limit :maxSelect]) {

			options.add(new SelectOption(u.Id, u.Name));
		}

		if(options.size() > 0 && pcommFilter.equals('0')) pcommFilter = options[0].getValue();

		return options;
	}
	
	public void refreshLinks()
	{
		
	}
	
	public Integer getNumberOfPages()
	{
		//Decimal pages =  ESBPPaginationController.getNumberOfPages(max, isNext, descByName, pcommFilter, prpFilter, effectiveDate, status);		
		//return pages.divide(max,0,System.RoundingMode.UP).intValue();
		if (hiddenNumberOfPages != null)
		{
			return hiddenNumberOfPages + 1;
		}
		else
		{
			return 0;
		}
	}
	
	public Integer getHiddenNumberOfPages()
	{
		if (hiddenNumberOfPages != null)
		{
			return hiddenNumberOfPages;
		}
		else
		{
			return 0;
		}
	}
	
	public void setHiddenNumberOfPages(Integer value)
	{
		hiddenNumberOfPages = value;
	} 
	
	public List<SelectOption> getPRPOptions() {
		List<SelectOption> options = new List<SelectOption>();
		List<PerformanceReviewPeriod__c> prpList = new List<PerformanceReviewPeriod__c> ();
		List<PerformanceReviewPeriod__c> sortedPRPList = new List<PerformanceReviewPeriod__c> ();
		options.add(new SelectOption('0', Label.PerformanceESBPAdminController_AllLabel));
		prpList =[SELECT Name FROM PerformanceReviewPeriod__c  WHERE Status__c =: LaunchedLabel ORDER BY CreatedDate DESC LIMIT :maxSelect];
		sortedPRPList = sortResult(prpList, 'Name', false);
		for(PerformanceReviewPeriod__c prp:sortedPRPList){	

			options.add(new SelectOption(prp.Id, prp.Name));
		}

		if(options.size() > 0 && prpFilter.equals('0')) prpFilter = options[0].getValue();

		return options;
	}
	public List<PerformanceReviewPeriod__c> sortResult (List<PerformanceReviewPeriod__c> result, String sortBy, Boolean sortByDesc) {
	    Integer n;
	    Integer i;
	    Integer j;
	    n = result.size() - 1;       
	    for (i = 1; i <= n; i++) {          
	    	for (j = n; j >= i ; j--) 
	    	{
	 			if (!sortByDesc) 
	         	{
		            if ( (sortBy == 'Name') && (result.get(j).Name < result.get(j - 1).Name) ) {
						PerformanceReviewPeriod__c tempPRP;
	               		tempPRP = result.get(j - 1);
	               		result.set(j - 1, result.get(j));
	               		result.set(j, tempPRP);  
		            }   
	         	}
	         	else 
	         	{
	            	if ( (sortBy == 'Name') && (result.get(j).Name >= result.get(j - 1).Name) ) {
						PerformanceReviewPeriod__c tempPRP;
	               		tempPRP = result.get(j - 1);
	               		result.set(j - 1, result.get(j));
	               		result.set(j, tempPRP);  
		            }   
	         	}
	      	}
	    }
	    return result;
	}

	public void setPcommFilter(String filter) {
		pcommFilter= filter;
	}

	public String getPcommFilter() {
		return pcommFilter;
	}

	public void setPrpFilter(String filter) {
		prpFilter = filter;
	}

	public String getPrpFilter() {
		return prpFilter; 
	}
	
	public Long getTotalPages()
	{
		if (hiddenNumberOfPages != null)
		{
			return hiddenNumberOfPages + 1;
		}
		else
		{
			return 0;			
		}
	}
	
	public Long getCurrentPage()
	{
		return currentPage;
	}
	
	public Boolean getShowPagination()
	{
		if (totalPages != 0) return true;
		return false;
	}
	
	public void rejectChecked() {
		List<PerformanceReview__c> reviews = new List<PerformanceReview__c>();

		for(PerformanceReviewWrapper prp: performanceReviewsWrapper) {
			if (prp.getSelected()){
				PerformanceReview__c pr = prp.getPerformanceReview();
				if(pr.SecondManager__c == null)
					pr.Status__c = 'Manager Assessment';
				else
					pr.Status__c = '2nd Level Manager Assessment';

				reviews.add(pr);
			}
		}
		
		update reviews;
		
		
		for(PerformanceReviewWrapper prp: performanceReviewsWrapper){
			prp.setSelected(false);
		}
		
	}


	public void SetStatus(String value)
	{
		status = value;
	}
	
	public List<SelectOption> getStatus() {
		List<SelectOption> options = new List<SelectOption>();

		options.add(new SelectOption(Label.PerformanceESBPAdminController_AllLabel, Label.PerformanceESBPAdminController_AllLabel));
		options.add(new SelectOption(Label.Created_label, Label.Created_label));
		options.add(new SelectOption(Label.Employee_Self_Assessment_label, Label.Employee_Self_Assessment_label));
		options.add(new SelectOption(Label.Manager_Assessment_label, Label.Manager_Assessment_label));
		options.add(new SelectOption(Label.Second_Level_Manager_Assessment_label, Label.Second_Level_Manager_Assessment_label));
		options.add(new SelectOption('Pending Employee Services', 'Pending Employee Services'));
		options.add(new SelectOption('PCOMM Review', 'PCOMM Review'));
		options.add(new SelectOption('Manager Approval', 'Manager Approval'));
		options.add(new SelectOption('Employee Approval', 'Employee Approval'));
		options.add(new SelectOption('Complete', 'Complete'));
		options.add(new SelectOption('3rd Party Assessment', '3rd Party Assessment'));

		if(options.size() > 0 && status.equals('0')) status = options[0].getValue();
 
		return options;
	}
	
	
	public void acceptChecked() {
		List<PerformanceReview__c> reviews = new List<PerformanceReview__c>();
	
		for(PerformanceReviewWrapper prp: performanceReviewsWrapper){
			if (prp.getSelected()){
				PerformanceReview__c pr = prp.getPerformanceReview();
				pr.Status__c = 'PCOMM Review';
				reviews.add(pr);
			}
		}

		update reviews;
		
		for(PerformanceReviewWrapper prp: performanceReviewsWrapper){
			prp.setSelected(false);
		}
		
	}  

	public list<PerformanceReviewWrapper> getPerformanceReviewWrappers(){ 
		
		
		System.debug('Entererrr');
		if (System.currentPageReference().getParameters().get('actionType') == null){				
			if (performanceReviewsWrapper == null){
				performanceReviewsWrapper = new List<PerformanceReviewWrapper>();	
			}

			if (System.currentPageReference().getParameters().get('hasToReload') != null){
				for(PerformanceReview__c pr : getPerformanceReviewsUpdate()){
					PerformanceReviewWrapper prp = new PerformanceReviewWrapper();
					prp.setPerformanceReview(pr);
					performanceReviewsWrapper.add(prp);
				}
	
	
				if (performanceReviewsWrapper.size() > 0 ){
					lastId = performanceReviewsWrapper[performanceReviewsWrapper.size() - 1].performanceReview.Id;
					firstId = performanceReviewsWrapper[0].performanceReview.Id; 
					lastStatus = performanceReviewsWrapper[performanceReviewsWrapper.size() - 1].performanceReview.Status__c;
					firstStatus = performanceReviewsWrapper[0].performanceReview.Status__c;
				}
				
				return performanceReviewsWrapper;
			}

			// link Name
			if (orderByName) {	
				
				
				performanceReviewsWrapper.clear();

				if (isNext == true)	{
					
					System.debug('Enter is next' );
					List<PerformanceReview__c> oneList = getPerformanceReviewsOrderByName();
					
					for(PerformanceReview__c pr : oneList)
					{
						PerformanceReviewWrapper prp = new PerformanceReviewWrapper();
						prp.setPerformanceReview(pr);
						performanceReviewsWrapper.add(prp);
					}
					
					
					
				}
				else {
					for(PerformanceReview__c pr : getPerformanceReviewsPrevOrderByName()){ 
						PerformanceReviewWrapper prp = new PerformanceReviewWrapper();
						prp.setPerformanceReview(pr);
						performanceReviewsWrapper.add(prp);
					}

					System.debug('Go to reverse Collection');
					//Reverse collection if previous
					if (enter)
					{
						
					}
					performanceReviewsWrapper = ReverseCollection(performanceReviewsWrapper);
					
				}

				if (performanceReviewsWrapper.size() > 0 ){
					lastId = performanceReviewsWrapper[performanceReviewsWrapper.size() - 1].performanceReview.Id;
					firstId = performanceReviewsWrapper[0].performanceReview.Id; 

					lastName = performanceReviewsWrapper[performanceReviewsWrapper.size() - 1].performanceReview.Employee__r.Name;
					firstName = performanceReviewsWrapper[0].performanceReview.Employee__r.Name;
				}

				colNumber = performanceReviewsWrapper.size();
				return performanceReviewsWrapper;
			}

			// link Status 
			if (orderByStatus) {
				performanceReviewsWrapper.clear();			
				if (isNext == true)	{
					for(PerformanceReview__c pr : getPerformanceReviewsOrderByStatus()){

						PerformanceReviewWrapper prp = new PerformanceReviewWrapper();
						prp.setPerformanceReview(pr);
						performanceReviewsWrapper.add(prp);
					}
				}
				else {
					for(PerformanceReview__c pr : getPerformanceReviewsPrevOrderByStatus()){  
						PerformanceReviewWrapper prp = new PerformanceReviewWrapper();
						prp.setPerformanceReview(pr);
						performanceReviewsWrapper.add(prp);
					}
					//Reverse collection if previous
					performanceReviewsWrapper = ReverseCollection(performanceReviewsWrapper); /////TODO
					
					if (performanceReviewsWrapper.size() > 0 ){
						lastId = performanceReviewsWrapper[performanceReviewsWrapper.size() - 1].performanceReview.Id;
						firstId = performanceReviewsWrapper[0].performanceReview.Id; 
						lastStatus = performanceReviewsWrapper[performanceReviewsWrapper.size() - 1].performanceReview.Status__c;
						firstStatus = performanceReviewsWrapper[0].performanceReview.Status__c;
					}
				}

				if (performanceReviewsWrapper.size() > 0 ){
					lastId = performanceReviewsWrapper[performanceReviewsWrapper.size() - 1].performanceReview.Id;
					firstId = performanceReviewsWrapper[0].performanceReview.Id; 
					lastStatus = performanceReviewsWrapper[performanceReviewsWrapper.size() - 1].performanceReview.Status__c;
					firstStatus = performanceReviewsWrapper[0].performanceReview.Status__c;
				}

				colNumber = performanceReviewsWrapper.size();
				return performanceReviewsWrapper;
			} 

			if (System.currentPageReference().getParameters().get('actionType') == null){
				performanceReviewsWrapper = new list<PerformanceReviewWrapper>();

				if (isNext == true)	{
					for(PerformanceReview__c pr : getPerformanceReviews()){

						PerformanceReviewWrapper prp = new PerformanceReviewWrapper();
						prp.setPerformanceReview(pr);
						performanceReviewsWrapper.add(prp);
					}
				} 
				else {
					for(PerformanceReview__c pr : getPerformanceReviewsPrev()){
						PerformanceReviewWrapper prp = new PerformanceReviewWrapper();
						prp.setPerformanceReview(pr);
						performanceReviewsWrapper.add(prp);
					}

					//Reverse collection if previous
					performanceReviewsWrapper = ReverseCollection(performanceReviewsWrapper);
					
					if (performanceReviewsWrapper.size() > 0 ){
						lastId = performanceReviewsWrapper[performanceReviewsWrapper.size() - 1].performanceReview.Id;
						firstId = performanceReviewsWrapper[0].performanceReview.Id; 
						lastStatus = performanceReviewsWrapper[performanceReviewsWrapper.size() - 1].performanceReview.Status__c;
						firstStatus = performanceReviewsWrapper[0].performanceReview.Status__c;
					}
				}

				if (performanceReviewsWrapper.size() > 0 ){
					lastId = performanceReviewsWrapper[performanceReviewsWrapper.size() - 1].performanceReview.Id;
					firstId = performanceReviewsWrapper[0].performanceReview.Id; 
				}
				
				colNumber = performanceReviewsWrapper.size();
				return performanceReviewsWrapper;
			}
			else {
				if (performanceReviewsWrapper.size() > 0 ){
					lastId = performanceReviewsWrapper[performanceReviewsWrapper.size() - 1].performanceReview.Id;
					firstId = performanceReviewsWrapper[0].performanceReview.Id; 
					lastStatus = performanceReviewsWrapper[performanceReviewsWrapper.size() - 1].performanceReview.Status__c;
					firstStatus = performanceReviewsWrapper[0].performanceReview.Status__c;
				}
				colNumber = performanceReviewsWrapper.size();
				return performanceReviewsWrapper;
			}
		}
		else {
			if (performanceReviewsWrapper.size() > 0 ){
					lastId = performanceReviewsWrapper[performanceReviewsWrapper.size() - 1].performanceReview.Id;
					firstId = performanceReviewsWrapper[0].performanceReview.Id; 
					lastStatus = performanceReviewsWrapper[performanceReviewsWrapper.size() - 1].performanceReview.Status__c;
					firstStatus = performanceReviewsWrapper[0].performanceReview.Status__c;
				}
				colNumber = performanceReviewsWrapper.size();
			return performanceReviewsWrapper;
		}

	}

	public void selectAllReviews() {
		for(PerformanceReviewWrapper prp: performanceReviewsWrapper) {
			if(prp.getShowCheckbox())
				prp.setSelected(true);
		}
	}

	public void deselectAllReviews() {
		for(PerformanceReviewWrapper prp: performanceReviewsWrapper) {
			if(prp.getShowCheckbox())
				prp.setSelected(false);
		}
	}

	public void Dummy()
	{
		totalPages = hiddenNumberOfPages; 
		System.debug('TotalPages ' + totalPages );
	}
	public class PerformanceReviewWrapper {
		PerformanceReview__c performanceReview;
		boolean selected = false;
		String currentUserId = userInfo.getUserId();

		public String getCurrentUserId(){
			return currentUserId;
		}
		public void setCurrentUserId(String id){
			currentUserId = id;
		}
		public void setPerformanceReview(PerformanceReview__c pr){
			performanceReview = pr;
		}

		public PerformanceReview__c getPerformanceReview(){
			return performanceReview;
		}

		public void setSelected(boolean s){
			selected = s;
		}

		public boolean getSelected(){
			return selected;
		}

		// Show the checkbox if the review is in a pending state with employee services
		// AND do not let the current user promote there own review.
		public boolean getShowCheckbox() {
			return (performanceReview.Status__c == 'Pending Employee Services') &&
			(!currentUserId.equals(performanceReview.Employee__c));
		}

		public String getOverallRating() {
			if(performanceReview.ReviewRating__r.OverAllRating__c == null) return null;

			if (performanceReview.ReviewRating__r.OverAllRating__c == -1) return null;
			return PAMUtil.getRatingLabel(performanceReview.ReviewRating__r.OverAllRating__c.intValue());
		}

		public String getCalculatedRating() {
			if(performanceReview.ReviewRating__r.CalculatedRating__c == null) return null;

			Decimal decimalValue = Decimal.valueOf(performanceReview.ReviewRating__r.CalculatedRating__c);
	        String subStr = String.valueOf(decimalValue.setScale(2, System.RoundingMode.UP));
	    	return subStr;		
	
		}
		
		public String getStatus(){
			if (performanceReview.Status__c.equals('Created')){
				return Label.Created_label;
			}
			if (performanceReview.Status__c.equals('Employee Self Assessment')){
				return Label.Employee_Self_Assessment_label;
			}
			if (performanceReview.Status__c.equals('Manager Assessment')){
				return Label.Manager_Assessment_label;
			}
			if (performanceReview.Status__c.equals('2nd Level Manager Assessment')){
				return Label.Second_Level_Manager_Assessment_label;
			}
			if (performanceReview.Status__c.equals('3rd Party Assessment')){
				return Label.Third_Party_Assessment_label;
			}
			if (performanceReview.Status__c.equals('Pending Employee Services')){
				return Label.Pending_Employee_Services;
			}
			if (performanceReview.Status__c.equals('PCOMM Review')){
				return Label.PCOMM_Review_label;
			}
			if (performanceReview.Status__c.equals('Employee Approval')){
				return Label.Employee_Approval_label;
			}
			if (performanceReview.Status__c.equals('Manager Approval')){
				return Label.Manager_Approval_label;
			}
			if (performanceReview.Status__c.equals('2nd Level Manager Approval')){
				return Label.Second_Level_Manager_Approval_label;
			}
			if (performanceReview.Status__c.equals('Complete')){
				return Label.Complete_label;
			}
			
			return '';
		}
		
	}


	/* ---------------------------- */
	/*       	 ORDER BY		    */
	/* ---------------------------- */
	public Boolean sortByDesc = false;
	public String sortBy = Label.PerformanceESBPAdminController_SortBy;

	public Boolean getSortByDesc () {
		return !sortByDesc;
	}

	public void setSortBy (String s){
		sortBy = s;	
	}

	public String getSortBy () {
		String sbCol = '';
		if (sortBy == null || sortBy == Label.PerformanceESBPAdminController_SortBy) {
			sbCol = Label.PerformanceESBPAdminController_NameLabel;	
		}
		if (sortBy == 'Status__c') {
			sbCol = Label.PerformanceESBPAdminController_StatusLabel;	
		}	
		return sbCol;
	}

	/*
	 * This is a temporary method to cover us until dynamic apex is back.  This will use hard coded
	 * SOQL statements in place of the dynamic statements
	 */
	public void sortList () {

		List<PerformanceReviewWrapper> perfList = new List<PerformanceReviewWrapper>();
		if (sortBy == System.currentPageReference().getParameters().get('sb')) {
			sortByDesc = !sortByDesc;
		}
		else {
			sortByDesc = false;
		}

		//Sort param
		List<PerformanceReview__c> perfResultList = new List<PerformanceReview__c>();
		perfResultList = getPerformanceReviews();

		if(System.currentPageReference().getParameters().get('sb') != null)
			sortBy = System.currentPageReference().getParameters().get('sb');



		for (PerformanceReview__c item: perfResultList) {
			PerformanceReviewWrapper wrapperItem = new PerformanceReviewWrapper();
			wrapperItem.setPerformanceReview(item);
			perfList.add(wrapperItem);
		}		
	}

	public String getLastId(){
		return lastId;
	}

	public Integer getColSize()	{
		return colNumber;	
	}
 
	public String getLastIdSortedByStatus(){
		return lastId;
	}

	public void setFirstId(Id value){
		firstId = value;
	}

	
	
	public String getFirstId(){
		return FirstId;
	}

	public String getFirstIdSortedByStatus(){
		return firstId;
	}

	public void setLastId(Id value)	{
		lastId = value;
	}

	public void setLastName(String value) {
		lastName = value;
	}

	public String getLastName() {
		return lastName;
	}	

	public String getFirstName() {
		return firstName;
	}

	public String getFirstStatus() {
		return firstStatus;
	}

	public void setLastStatus(String value) {
		lastStatus = value;
	}

	public String getLastStatus() {
		return lastStatus;
	}

	public list<PerformanceReview__c> getPerformanceReviews(){
		return  [Select  pr.id,
				         pr.Name,
				         pr.Employee__c,
				         pr.Employee__r.Name,
				         pr.Employee__r.Title,
				         pr.Employee__r.Manager__r.Name,
				         pr.Employee__r.ReviewManager__r.Name,
				         pr.Employee__r.Cost_Center__c,
				         pr.Employee__r.Division,
				         pr.Employee__r.employeeNumber,
				         pr.manager__c,
				         pr.SecondManager__c,
				         pr.V2MOM__c,
				         pr.V2MOM__r.V2MOM_Type__c,
				         pr.ReviewRating__r.CalculatedRating__c,
				         pr.ReviewRating__r.OverAllRating__c,  pr.PerformanceReviewPeriod__r.Effective_Date__c,
				         pr.Status__c
		         From PerformanceReview__c pr
		         Where Id >: System.currentPageReference().getParameters().get('lastId') 
		         ORDER BY pr.Employee__r.Name, Id 
		         LIMIT :max];
	}

	public list<PerformanceReview__c> getPerformanceReviewsPrev(){
		return  [Select  pr.id,
				         pr.Name,
				         pr.Employee__c,
				         pr.Employee__r.Name,
				         pr.Employee__r.Title,
				         pr.Employee__r.Manager__r.Name,
				         pr.Employee__r.ReviewManager__r.Name,
				         pr.Employee__r.Cost_Center__c,
				         pr.Employee__r.Division,
				         pr.Employee__r.EmployeeNumber,
				         pr.manager__c,
				         pr.SecondManager__c,
				         pr.V2MOM__c,
				         pr.V2MOM__r.V2MOM_Type__c,
				         pr.ReviewRating__r.CalculatedRating__c,
				         pr.ReviewRating__r.OverAllRating__c,  pr.PerformanceReviewPeriod__r.Effective_Date__c,
				         pr.Status__c, pr.V2MOM__r.Effective_Date__c 
		         From PerformanceReview__c pr
		         Where Id <: System.currentPageReference().getParameters().get('prevId') 
		         ORDER BY pr.Employee__r.Name,Id DESC 
		         LIMIT :max];
	}

	public list<PerformanceReview__c> getPerformanceReviewsPrevOrderByName(){		
		return ESBPUtil.getPerformanceReviewsPrevOrderByNameAux(max,isNext,descByName,pcommFilter,prpFilter, effectiveDate, status );
	}
 
	public list<PerformanceReview__c> getPerformanceReviewsPrevOrderByStatus(){	
		return ESBPAdminControllerOrderStatus.getPerformanceReviewsPrevOrderByStatus(max, isNext,desccByStatus,  pcommFilter,prpFilter, effectiveDate,  status);
	}

	public list<PerformanceReview__c> getPerformanceReviewsUpdate(){
		return  [Select  pr.id,
				         pr.Name,
				         pr.Employee__c,
				         pr.Employee__r.Name,
				         pr.Employee__r.Title,
				         pr.Employee__r.Manager__r.Name,
				         pr.Employee__r.ReviewManager__r.Name,
				         pr.Employee__r.Cost_Center__c,
				         pr.Employee__r.Division,
				         pr.Employee__r.EmployeeNumber,
				         pr.manager__c,
				         pr.SecondManager__c,
				         pr.V2MOM__c,
				         pr.V2MOM__r.V2MOM_Type__c,
				         pr.ReviewRating__r.CalculatedRating__c,
				         pr.ReviewRating__r.OverAllRating__c,  pr.PerformanceReviewPeriod__r.Effective_Date__c,
				          pr.Status__c, pr.V2MOM__r.Effective_Date__c 
		         From PerformanceReview__c pr
		         Where Id >=: System.currentPageReference().getParameters().get('prevId') 
		         ORDER BY pr.Employee__r.Name, Id 
		         LIMIT :max];
	}

	public list<PerformanceReview__c> getPerformanceReviewsOrderByName() 
	{	 
		return ESBPAdminControllerStatusFilter.getPerformanceReviewsOrderByName(lastId, lastName, isNext, pcommFilter, prpFilter, effectiveDate, status, max, descByName);
	}

	public list<PerformanceReview__c> getPerformanceReviewsOrderByStatus() {		
		return ESBPAdminControllerStatusPrev.getPerformanceReviewsOrderByStatus( max,  isNext,  desccByStatus,  pcommFilter,  prpFilter, effectiveDate, status);
	}

	public Double getRowsToShow() {
		if (performanceReviewsWrapper != null){
			return performanceReviewsWrapper.size();
		}
		else{
			return 0;	
		}	
	}
	
	/**
    * @return the All user in pcomm profile
    */
    public List<SelectOption> getAllPCOMM()
    {
    	List<User> userWithPcommProfile = [Select Id, Name from User Where Profile.Name = 'PCOMM' order by Name ];
    	List <SelectOption> options = new List<SelectOption>();
    	
    	options.add(new SelectOption('1','-Select One-'));
    	for (User u : userWithPcommProfile)
    	{
    		options.add(new SelectOption(u.Id,u.Name));
    	}
    	
    	return options;
    }
    
    /**
    * @return the Efective date value from the current year
    */
    public String getThisYear(){
    	String currentYear = 'FY';
    	String year = String.valueOf(System.Now().Year() + 1);
    	
    	currentYear += year.substring(year.length() - 2,year.length());   	
    	return currentYear;
    }
    
    /**
    * Reload manager based on pcomm filter
    */
    public void reloadManagers()
    {
    	
    }
    
    /**
    * @return the list of manager of the selected pcomm
    */
    public List<SelectOption> getManagers()
    {
    	List<User> pcomms = [Select Id, Name from User Where Profile.Name  = 'PCOMM' order by Name];
    	List<User> managers = new List<User>();
    	
    	if (pcommFilterReport != '')
    	{
    		managers = [Select Id, Name from User where PCOMM__c =: pcommFilterReport 
    							and (Profile.Name = 'Support Manager' or Profile.Name = 'CSM Manager'
    						    	or Profile.Name = 'Education Manager' or Profile.Name = 'Manager') 
    						    		order by Name ];
    	}
    					    	
    	List <SelectOption> options = new List<SelectOption>();
    	
    	options.add(new SelectOption('All',' All'));
    	
    	for (User u : managers)
    	{
    		options.add(new SelectOption(u.Id,u.Name));
    	}
    	
    	return options;	
    }
    
	public list<PerformanceReviewWrapper> getPerformanceReviewWrapper(){ 
		if (System.currentPageReference().getParameters().get('hasToReload') != null){
			for(PerformanceReview__c pr : getPerformanceReviewsUpdate()){
				PerformanceReviewWrapper prp = new PerformanceReviewWrapper();
				prp.setPerformanceReview(pr);
				performanceReviewsWrapper.add(prp);
			}

			return performanceReviewsWrapper;
		}

		// link Name
		System.debug('OrderrrrbyName');
		if (orderByName) {
			performanceReviewsWrapper.clear();

			if (isNext == true)	
			{
				
				System.debug('Enter Is NExt');
				List<PerformanceReview__c> tt = getPerformanceReviewsOrderByName();
				System.debug('PAss');
				for(PerformanceReview__c pr : tt)
				{
					PerformanceReviewWrapper prp = new PerformanceReviewWrapper();
					prp.setPerformanceReview(pr);
					performanceReviewsWrapper.add(prp);
				}
				
						
			}
			else 
			{
				System.debug('GoOrderByNamePrev');
				for(PerformanceReview__c pr : getPerformanceReviewsPrevOrderByName())
				{ 
					PerformanceReviewWrapper prp = new PerformanceReviewWrapper();
					prp.setPerformanceReview(pr);
					performanceReviewsWrapper.add(prp);
				}

				System.debug('Issss ' + performanceReviewsWrapper[0].PerformanceReview.Id);
				
				//Reverse collection if previous
				performanceReviewsWrapper = ReverseCollection(performanceReviewsWrapper);
				System.debug('Go to reversee');
				System.debug(performanceReviewsWrapper[0].PerformanceReview.Id);
			}

			
			
			if (performanceReviewsWrapper.size() > 0 ){
				lastId = performanceReviewsWrapper[performanceReviewsWrapper.size() - 1].performanceReview.Id;
				firstId = performanceReviewsWrapper[0].performanceReview.Id; 				

				lastName = performanceReviewsWrapper[performanceReviewsWrapper.size() - 1].performanceReview.Employee__r.Name;
				firstName = performanceReviewsWrapper[0].performanceReview.Employee__r.Name;
			}

			return performanceReviewsWrapper;
		}

		// link Status 
		if (orderByStatus) {
			performanceReviewsWrapper.clear();			
			if (isNext == true)	{
				
				
				System.debug('Enter isssNext');
				for(PerformanceReview__c pr : getPerformanceReviewsOrderByStatus()){
					PerformanceReviewWrapper prp = new PerformanceReviewWrapper();
					prp.setPerformanceReview(pr);
					performanceReviewsWrapper.add(prp);
				}
			}
			else {
				System.debug('PerformanceRevvvi');
				for(PerformanceReview__c pr : getPerformanceReviewsPrevOrderByStatus()){ 
					PerformanceReviewWrapper prp = new PerformanceReviewWrapper();
					prp.setPerformanceReview(pr);
					performanceReviewsWrapper.add(prp);
				}

				//Reverse collection if previous
				performanceReviewsWrapper = ReverseCollection(performanceReviewsWrapper); /////TODO
			}
			if (performanceReviewsWrapper.size() > 0 ){
				lastId = performanceReviewsWrapper[performanceReviewsWrapper.size() - 1].performanceReview.Id;
				firstId = performanceReviewsWrapper[0].performanceReview.Id; 
				lastStatus = performanceReviewsWrapper[performanceReviewsWrapper.size() - 1].performanceReview.Status__c;
				firstStatus = performanceReviewsWrapper[0].performanceReview.Status__c;				
			}

			return performanceReviewsWrapper;
		}

		if (System.currentPageReference().getParameters().get('actionType') == null){
			performanceReviewsWrapper = new list<PerformanceReviewWrapper>();

			if (isNext == true)	{
				for(PerformanceReview__c pr : getPerformanceReviews()){

					PerformanceReviewWrapper prp = new PerformanceReviewWrapper();
					prp.setPerformanceReview(pr);
					performanceReviewsWrapper.add(prp);
				}
			}
			else {
				for(PerformanceReview__c pr : getPerformanceReviewsPrev()){
					PerformanceReviewWrapper prp = new PerformanceReviewWrapper();
					prp.setPerformanceReview(pr);
					performanceReviewsWrapper.add(prp);
				}

				//Reverse collection if previous
				performanceReviewsWrapper = ReverseCollection(performanceReviewsWrapper);
			}

			if (performanceReviewsWrapper.size() > 0 ){
				lastId = performanceReviewsWrapper[performanceReviewsWrapper.size() - 1].performanceReview.Id;
				firstId = performanceReviewsWrapper[0].performanceReview.Id; 
			}

			return performanceReviewsWrapper;
		}
		else {
			return performanceReviewsWrapper;
		}
	}

	public List<PerformanceReviewWrapper> ReverseCollection(List<PerformanceReviewWrapper> originalCol){
		PerformanceReviewWrapper currentPerformance;
		List<PerformanceReviewWrapper> newCol = new List<PerformanceReviewWrapper>();

		Integer index = originalCol.size() -1;

		for(PerformanceReviewWrapper pr : originalCol){
			currentPerformance = originalCol[index];
			newCol.add(currentPerformance);
			index = index - 1;
		}

		return newCol;
	}

	public String getPreviousLabel() {
		return Label.PerformanceESBPAdminController_PreviousPage + ' ';
	}

	public String getNextLabel() {
		return ' ' + Label.PerformanceESBPAdminController_NextPage;	
	}


	/* ************************ */
	/*        Pagination        */
	/* ************************ */

	/**
	 * Set of Integers to control pagination
	 */
	public Integer numberOfItemsToShow = max;
	public Integer cntPagination;
	public Integer currentPagination = 1;
	public Integer totalItemsNumber= 0;

	public Integer getTotalItemsNumber () {
		return totalItemsNumber;
	}

	/**
	 * Set of Booleans to show or not prev / next links
	 */
	public boolean prevPageLinkShow = false;
	public boolean prevPageShow  = false;
	public boolean nextPageLinkShow  = false;
	public boolean nextPageShow  = false;

	public void genCntPagination () {

		cntPagination = (totalItemsNumber - (Math.mod(totalItemsNumber, numberOfItemsToShow)))/ numberOfItemsToShow;    
		if (Math.mod(totalItemsNumber, numberOfItemsToShow) != 0 ) {
			cntPagination++;
		}           
	}

	public void orderByName(){
		descByName = ! descByName; 
		desccByStatus = false;

		isNext = true;
		isPrev = false;	 

		currentPagination = 1;
		jumpPage = 1;

		orderByName = true;
		orderByStatus = false;

		lastId = '';
		lastStatus = '';
		
		currentPage = 1;
	}

	public void orderByStatus(){

		desccByStatus = ! desccByStatus;
		descByName = false;

		isNext = true;
		isPrev = false;	

		currentPagination = 1;
		jumpPage = 1;

		orderByStatus = true;
		orderByName = false;

		totalItemsNumber = getPerformanceReviews().size();

		if (totalItemsNumber == 0 ) {
			noMatches = true;
			cntPagination = 0;  
			currentPagination = 1;
			jumpPage = 1;
		}
		else {
			noMatches = false;
			currentPagination = 1;
			jumpPage = 1;
			genCntPagination(); 
		}	

		currentPage = 1;
		
		List<PerformanceReview__c> prList = getPerformanceReviews();
	}

	public void nextPage() {
		isNext = true;
		isPrev = false;	

		currentPagination++;
		jumpPage = currentPagination;
		
		currentPage++;
	}

	public void prevPage() {
		
		System.debug('Go to set IsNext False');
		isNext = false;
		isPrev = true;

		currentPagination--;
		jumpPage = currentPagination;
		
		currentPage--;
	}

	/* Last Page */
	public void lastPage() {
		currentPagination = cntPagination;
		jumpPage = cntPagination;
	}

	/* First Page */
	public void firstPage() {
		currentPagination = 1;
		jumpPage = 1;
	}

	public Integer getCurrentPagination () {
		return currentPagination;
	}

	public Integer getCntPagination () {
		return cntPagination;
	}

	public Integer getNumberOfItemsToShow () {
		return numberOfItemsToShow;
	}

	/**
	 * Pagination Boolean Getters
	 */
	public boolean getPrevPageLinkShow () {

		if(currentPagination == 1){ 
			prevPageLinkShow = false;       
		} else {
			prevPageLinkShow = true;
		}

		return prevPageLinkShow;
	}

	public boolean getPrevPageShow () {
		if(currentPagination == 1){ 
			prevPageLinkShow = false;       
		} else {
			prevPageLinkShow = true;
		}

		return prevPageLinkShow;
	}

	public boolean getNextPageLinkShow () {
		if (orderByStatus){
			List<PerformanceReview__c> listTest;

			if ( !desccByStatus) {
				listTest = [Select  pr.id,
						            pr.Name,
						            pr.Employee__c,
						            pr.Employee__r.Name,
						            pr.Employee__r.Title,
						            pr.Employee__r.Manager__r.Name,
						            pr.Employee__r.ReviewManager__r.Name,
						            pr.Employee__r.Cost_Center__c,
						            pr.Employee__r.Division,
						            pr.Employee__r.EmployeeNumber,
						            pr.manager__c,
						            pr.SecondManager__c,
						            pr.V2MOM__c,
				         			pr.V2MOM__r.V2MOM_Type__c,
						            pr.ReviewRating__r.CalculatedRating__c,
						            pr.ReviewRating__r.OverAllRating__c, pr.PerformanceReviewPeriod__r.Effective_Date__c,
						            pr.Status__c, pr.V2MOM__r.Effective_Date__c 
				            From PerformanceReview__c pr
				            Where Id >: System.currentPageReference().getParameters().get('lastId') AND 
				            Status__c >=: System.currentPageReference().getParameters().get('lastStatus')  
				            ORDER BY pr.Status__c,Id 
				            LIMIT 20];
			}
			else  {
				if (System.currentPageReference().getParameters().get('lastId') == '') {
					listTest = [Select  pr.id,
							            pr.Name,
							            pr.Employee__c,
							            pr.Employee__r.Name,
							            pr.Employee__r.Title,
							            pr.Employee__r.Manager__r.Name,
							            pr.Employee__r.ReviewManager__r.Name,
							            pr.Employee__r.Cost_Center__c,
							            pr.Employee__r.EmployeeNumber,
							            pr.Employee__r.Division,
							            pr.manager__c,
							            pr.SecondManager__c,
							            pr.V2MOM__c,
				         				pr.V2MOM__r.V2MOM_Type__c,
							            pr.ReviewRating__r.CalculatedRating__c,
							            pr.ReviewRating__r.OverAllRating__c, pr.PerformanceReviewPeriod__r.Effective_Date__c,
							            pr.Status__c, pr.V2MOM__r.Effective_Date__c 
					            From PerformanceReview__c pr
					            Where Id <: getLastIdSortedByStatus() AND Status__c 
					            <=:       getLastStatus()
					            ORDER BY pr.Status__c ,Id  
					            LIMIT 20];
				}
				else { 
					listTest = [Select  pr.id,
							            pr.Name,
							            pr.Employee__c,
							            pr.Employee__r.Name,
							            pr.Employee__r.Title,
							            pr.Employee__r.Manager__r.Name,
							            pr.Employee__r.ReviewManager__r.Name,
							            pr.Employee__r.Cost_Center__c,
							            pr.Employee__r.EmployeeNumber,
							            pr.Employee__r.Division,
							            pr.manager__c,
							            pr.V2MOM__c,
				         				pr.V2MOM__r.V2MOM_Type__c,
							            pr.SecondManager__c,
							            pr.ReviewRating__r.CalculatedRating__c,
							            pr.ReviewRating__r.OverAllRating__c, pr.PerformanceReviewPeriod__r.Effective_Date__c,
							            pr.Status__c, pr.V2MOM__r.Effective_Date__c 
					            From PerformanceReview__c pr
					            Where (pr.Status__c <: getLastIdSortedByStatus()
					            		OR (Id <: getLastIdSortedByStatus()
					            				AND pr.Status__c <= : getLastStatus() )) 
					            limit 20];

					if (listTest.size() < 20 ){
						return false;
					}

					List<PerformanceReview__c> listPerformance = [Select pr.id  From PerformanceReview__c pr
					                                              Where  (pr.Status__c < : getLastIdSortedByStatus()
					                                            		  OR (Id <: getLastIdSortedByStatus()
					                                            				  AND pr.Status__c <= : getLastStatus() ))
					                                             limit 20];	 	   	     	
				}	 	   	
			}

			if (listTest.size() == 20) {
				List<PerformanceReview__c> listPerformance  = [Select pr.id  From PerformanceReview__c pr
				                                               Where Id >: listTest[19].Id
				                                               ORDER BY pr.Status__c,Id 
				                                               LIMIT 1];

				if (listPerformance.size() == 0) {
					return false;
				}

				return true;
			}
			else{
				return false;	
			}
		}
		else{
			List<PerformanceReview__c> listTest = [Select  pr.id,
					                                       pr.Name,
					                                       pr.Employee__c,
					                                       pr.Employee__r.Name,
					                                       pr.Employee__r.Title,
					                                       pr.Employee__r.Manager__r.Name,
					                                       pr.Employee__r.ReviewManager__r.Name,
					                                       pr.Employee__r.Cost_Center__c,
					                                       pr.Employee__r.Division,
					                                       pr.Employee__r.EmployeeNumber,
					                                       pr.manager__c,
					                                       pr.SecondManager__c,
					                                       pr.V2MOM__c,
				         								   pr.V2MOM__r.V2MOM_Type__c,
					                                       pr.ReviewRating__r.CalculatedRating__c,
					                                       pr.ReviewRating__r.OverAllRating__c, pr.PerformanceReviewPeriod__r.Effective_Date__c,
					                                       pr.Status__c, pr.V2MOM__r.Effective_Date__c 
			                                       From PerformanceReview__c pr
			                                       Where Id >: System.currentPageReference().getParameters().get('lastId') AND 
			                                       	pr.Employee__r.Name >=: System.currentPageReference().getParameters().get('lastName')  
			                                       ORDER BY pr.Employee__r.Name,Id 
			                                       LIMIT 20];

			if (listTest.size() < 20 ){
				return false;
			}

			List<PerformanceReview__c> listPerformance  = [Select pr.id  From PerformanceReview__c pr
			                                               Where  Id >: listTest[19].Id
			                                               ORDER BY pr.Employee__r.Name ,Id 
			                                               LIMIT 1];

			if (listPerformance.size() == 0){
				return false;
			}

			return true;
		}
	}

	public boolean getNextPageShow () {
		if((currentPagination == cntPagination) || (cntPagination == 0)){ 
			nextPageShow = true; 
		} 
		else { 
			nextPageShow = false;
		} 

		return nextPageShow;
	}   

	/* ************************ */
	/*        Jump to Page      */
	/* ************************ */
	public Integer jumpPage = 1;

	public Integer getJumpPage () {
		return jumpPage;
	}
 
	public void setJumpPage (Integer jumpPage) {
		this.jumpPage = jumpPage;
	}

	public void JumpToPage () {
		if (jumpPage > cntPagination) {
			currentPagination = cntPagination;
			jumpPage = cntPagination;
		}
		else {
			if (jumpPage < 1) {
				currentPagination = 1;
				jumpPage = 1;
			}
			else {  
				currentPagination = jumpPage;
			}
		}
	} 

	public Boolean getOrderByName()	{
		return orderByName;	
	}

	public Boolean getOrderByStatus(){
		return orderByStatus;
	}

	public Boolean getDesccByStatus(){
		return desccByStatus;
	}

	public Boolean getDescByName(){
		return descByName;	
	}
}