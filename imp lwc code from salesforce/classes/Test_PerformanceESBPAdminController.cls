@isTest
private class Test_PerformanceESBPAdminController {
        
     public static testMethod void execute_methods_ESBPController() {
     	
     	GenerateEnvironmentTest2.genPerformanceReview();
     	 
     	Test.startTest();
     	 
    
	        PerformanceESBPAdminController esbp = new PerformanceESBPAdminController();
	        
	        esbp.getAllEffectiveDates();
	        esbp.getAllEffectiveDatesPR();
	        esbp.getDefaultEffectiveDateAll();
	        
	        // This variables should be small for query rows
	        esbp.maxSelect = 3;
	        esbp.max = 5;
	        
	        // --------------- BEGIN FUNCTIONS     
	        List<PerformanceESBPAdminController.PerformanceReviewWrapper> prw = esbp.getPerformanceReviewWrappers();
	        if(prw == null){
	            System.assert(true, 'Null performance Review Wrapper'); 
	        }
	        if(esbp.ReverseCollection(prw) != null){
	          System.assert(true, 'Error in reverse prw');    
	        }
	        
	        esbp.selectAllReviews();
	        esbp.acceptChecked();
	        esbp.deselectAllReviews();
	        esbp.getPcommFilterReport();
	        
	        
	        
	        if(esbp.getPCOMMOptions() == null){
	            System.assert(true, 'Null pcomm options');  
	        }
	        if(esbp.getPRPOptions() == null){
	            System.assert(true, 'Null prp options');    
	        }        
	        if(esbp.getPcommFilter() == null){
	            System.assert(true, 'Null pcomm filter');   
	        }
	        if(esbp.getPrpFilter() == null){
	            System.assert(true, 'Null prp filter'); 
	        }
	        
	        if(esbp.getPerformanceReviews() == null){
	            System.assert(true, 'Null performance Reviews');    
	        }
	        
	        if(esbp.getRowsToShow() != null){
	            System.assert(true, 'Error in get rows to show');   
	        }
	        if(esbp.getTotalItemsNumber() != null){
	            System.assert(true, 'Error in get total items number'); 
	        }
	        if(esbp.genCntPagination() != null){
	            System.assert(true, 'Error in get cnt pagination'); 
	        }
	        
	        esbp.nextPage();
	        esbp.getLastId();
	        esbp.prevPage();
	        esbp.getLastId();
	        esbp.lastPage();
	        esbp.firstPage();
	        
	        if(esbp.genCntPagination() != null){
	            System.assert(true, 'Error in get cnt pagination'); 
	        }
	        if(esbp.getCurrentPagination() != null){
	            System.assert(true, 'Error in get current pagination'); 
	        }
	        if(esbp.getCntPagination() != null){
	            System.assert(true, 'Error in get cnt pagination'); 
	        }
	        if(esbp.getNumberOfItemsToShow() != null){
	            System.assert(true, 'Error in get number of items to show');    
	        }
	        if(esbp.getJumpPage() != null){
	            System.assert(true, 'Error in get jump page');  
	        }
	        
	        esbp.JumpToPage();
	
	        if(esbp.getSortByDesc()){
	            System.assert(true, 'Error in sort desc');  
	        }
	        if(esbp.getSortBy() != null){
	            System.assert(true, 'Error in sort by');    
	        }
	        if(esbp.getColSize() != null){
	            System.assert(true, 'Error in col size');   
	        }
	        if(esbp.getPerformanceReviewsPrev() != null){
	            System.assert(true, 'Error in get prs previous');   
	        }
	        
	        if(esbp.getFirstId() != null){
	            System.assert(true, 'Error in get first id');   
	        }
	        if(esbp.getPrevPageShow()){
	            System.assert(true, 'Error in get previous page show'); 
	        }
	        if(esbp.getNextPageShow()){
	            System.assert(true, 'Error in get next page show'); 
	        }
	        esbp.getPrevPageLinkShow();
	        esbp.getNextPageLinkShow();
	        
	        if(esbp.getPreviousLabel() == null){
	            System.assert(true, 'Null label previous'); 
	        }
	        if(esbp.getNextLabel() == null){
	            System.assert(true, 'Null label next'); 
	        }
	        
	        esbp.setSortBy('Employee__r.Name');
	        esbp.sortList();
	        
	        
	        // --------------- BEGIN FUNCTIONS OF ORDER         
	        esbp.orderByStatus(); 
	        
	        esbp.nextPage();
	        esbp.getPerformanceReviewWrapper();        
	        esbp.getPerformanceReviewWrappers();
	        
	        esbp.prevPage();
	        esbp.getPerformanceReviewWrapper();        
	        esbp.getPerformanceReviewWrappers();
	        
	        esbp.orderByName();
	        esbp.getPerformanceReviewWrapper();        
	        esbp.getPerformanceReviewWrappers();
	        
	        
	        System.currentPageReference().getParameters().put('hasToReload', 'true');
		    esbp.getPerformanceReviewWrapper();
	        esbp.getPerformanceReviewWrappers();
	        
	        System.currentPageReference().getParameters().put('actionType', 'true');
		    esbp.getPerformanceReviewWrapper();        
	        
	        esbp.getFirstIdSortedByStatus();
	        esbp.getFirstIdSortedByStatus();
	        
	        
	        esbp.getPerformanceReviewsPrevOrderByStatus();
	        
	        esbp.setPcommFilter('0');
	        esbp.setPrpFilter('0');
	        esbp.getPerformanceReviewsPrevOrderByStatus();
	        esbp.getPerformanceReviewsOrderByName();
	        
	        esbp.setPcommFilter(esbp.getPCOMMOptions()[1].getvalue());
	        esbp.getPerformanceReviewsPrevOrderByStatus();
	        esbp.getPerformanceReviewsOrderByName();
	        
	        esbp.setPrpFilter(esbp.getPRPOptions()[1].getvalue());
	        esbp.getPerformanceReviewsPrevOrderByStatus();
	        esbp.getPerformanceReviewsOrderByName();
	        
	        esbp.setPcommFilter('0');
	        esbp.getPerformanceReviewsPrevOrderByStatus();
	        esbp.getPerformanceReviewsOrderByName();
	        
	        System.currentPageReference().getParameters().put('lastName', '');
	        esbp.setPcommFilter('0');
	        esbp.setPrpFilter('0');
	        esbp.getPerformanceReviewsPrevOrderByStatus();
	        esbp.getPerformanceReviewsOrderByName();
	        
	        esbp.setPcommFilter(esbp.getPCOMMOptions()[1].getvalue());
	        esbp.getPerformanceReviewsPrevOrderByStatus();
	        esbp.getPerformanceReviewsOrderByName();
	        
	        esbp.setPrpFilter(esbp.getPRPOptions()[1].getvalue());
	        esbp.getPerformanceReviewsPrevOrderByStatus();
	        esbp.getPerformanceReviewsOrderByName();
	        
	        esbp.setPcommFilter('0');
	        esbp.getPerformanceReviewsPrevOrderByStatus();
	        esbp.getPerformanceReviewsOrderByName();
	        esbp.setPcommFilterReport('');
	        esbp.setManagerFilterReport('');
	        esbp.getManagerFilterReport();
	        esbp.rejectChecked();

	        esbp.getAllPCOMM();
	        esbp.getThisYear();
	        esbp.getManagers();
	        
	        if(esbp.getPerformanceReviewsOrderByStatus() != null){
	            System.assert(true, 'Error in get prs sorted by status');   
	        }
	        if(esbp.getOrderByStatus()){
	            System.assert(true, 'Error in get order by status');    
	        }
	        if(esbp.getDesccByStatus()){
	            System.assert(true, 'Error in get desc by status'); 
	        }
	        if(esbp.getPrevPageLinkShow()){
	            System.assert(true, 'Error in get previous page link show');    
	        }
	        esbp.getNextPageLinkShow();
	        esbp.getPrevPageShow();
	        
			if(esbp.getOrderByName()){
	            System.assert(true, 'Error in get order by name');  
	        }
	        if(esbp.getDescByName()){
	            System.assert(true, 'Error in get desc by name');   
	        }
	        esbp.setJumpPage(1);
	        
	        esbp.getFirstStatus();
	        
	        
	        System.currentPageReference().getParameters().put('lastStatus', '');
		    esbp.setLastStatus('lastStatus');
	        
	        // --------------- BEGIN FUNCIONES DE ORDER POR NAME        
	        esbp.orderByName();
	        
	 		esbp.nextPage();
	        esbp.getPerformanceReviewWrappers();
	        System.currentPageReference().getParameters().put('hasToReload', 'true');
		    esbp.getPerformanceReviewWrapper();
	        esbp.getPerformanceReviewWrappers();
	        
	        System.currentPageReference().getParameters().put('actionType', 'true');
		    esbp.getPerformanceReviewWrapper();        
	        
	        esbp.prevPage();
	        esbp.getPerformanceReviewWrappers();
	        System.currentPageReference().getParameters().put('hasToReload', 'true');
		    esbp.getPerformanceReviewWrapper();
	        
	        System.currentPageReference().getParameters().put('actionType', 'true');
		    esbp.getPerformanceReviewWrapper();        
	        
	        
	        esbp.setPcommFilter('0');
	        esbp.setPrpFilter('0');
	        esbp.getPerformanceReviewsPrevOrderByStatus();
	        esbp.getPerformanceReviewsOrderByName();
	        
	        esbp.setPcommFilter(esbp.getPCOMMOptions()[1].getvalue());
	        esbp.getPerformanceReviewsPrevOrderByStatus();
	        esbp.getPerformanceReviewsOrderByName();
	        
	        esbp.setPrpFilter(esbp.getPRPOptions()[1].getvalue());
	        esbp.getPerformanceReviewsPrevOrderByStatus();
	        esbp.getPerformanceReviewsOrderByName();
	        
	        esbp.setPcommFilter('0');
	        esbp.getPerformanceReviewsPrevOrderByStatus();
	        esbp.getPerformanceReviewsOrderByName();
	        
	        
	        if(esbp.getPrevPageLinkShow()){
	            System.assert(true, 'Error in get previous page link show');    
	        }
	        esbp.getNextPageLinkShow();
	        System.currentPageReference().getParameters().put('lastId', '');
		    esbp.getNextPageLinkShow();
	        esbp.getPrevPageShow();
	        
	        if(esbp.getNextPageShow()){
	            System.assert(true, 'Error in get next page show'); 
	        }
	        if(esbp.getPerformanceReviewsPrevOrderByName() != null){
	            System.assert(true, 'Error in get prs previous sorted by name');    
	        }
	        if(esbp.getLastName() != null){
	            System.assert(true, 'Error in get last name');  
	        }
	        if(esbp.getFirstName() != null){
	            System.assert(true, 'Error in get first name'); 
	        }  
	        if(esbp.getPrevPageShow()){
	            System.assert(true, 'Error in get previous page show'); 
	        }
	        if(esbp.getRowsToShow() != null){
	            System.assert(true, 'Error in get rows to show');   
	        }
	        if(esbp.getTotalItemsNumber() != null){
	            System.assert(true, 'Error in get total items number'); 
	        }
	        if(esbp.genCntPagination() != null){
	            System.assert(true, 'Error in get cnt pagination'); 
	        }
	        
	        esbp.lastPage();
	        esbp.firstPage();
	        
	        if(esbp.genCntPagination() != null){
	            System.assert(true, 'Error in get cnt pagination'); 
	        }
	        if(esbp.getCurrentPagination() != null){
	            System.assert(true, 'Error in get current pagination'); 
	        }
	        if(esbp.getCntPagination() != null){
	            System.assert(true, 'Error in get cnt pagination'); 
	        }
	        if(esbp.getNumberOfItemsToShow() != null){
	            System.assert(true, 'Error in get number of items to show');    
	        }
	        if(esbp.getJumpPage() != null){
	            System.assert(true, 'Error in get jump page');  
	        }
	        
	        esbp.JumpToPage();
	
	        if(esbp.getSortByDesc()){
	            System.assert(true, 'Error in sort desc');  
	        }
	        if(esbp.getSortBy() != null){
	            System.assert(true, 'Error in sort by');    
	        }
	        if(esbp.getColSize() != null){
	            System.assert(true, 'Error in col size');   
	        }
	        if(esbp.getPerformanceReviewsPrev() != null){
	            System.assert(true, 'Error in get prs previous');   
	        }        
	        if(esbp.getFirstId() != null){
	            System.assert(true, 'Error in get first id');   
	        }
	        if(esbp.getLastId() != null){
	            System.assert(true, 'Error in last id');    
	        }
	 		
	 
	 
	        // PerformanceReviewWrapper Innerclass
	        PerformanceESBPAdminController.PerformanceReviewWrapper innerClass = new PerformanceESBPAdminController.PerformanceReviewWrapper();
	     //   innerClass.setCurrentUserId(GenerateEnvironmentTest2.PRDepartment.Employee__c);
	    
	        innerClass.setPerformanceReview(GenerateEnvironmentTest2.PRDepartment);
	        //innerClass.getOverallRating();
	        //innerClass.getCalculatedRating();
	        
	        if(innerClass.getPerformanceReview() == null){
	            System.assert(true, 'Null performance reviews');
	        }            
	        if(innerClass.getCurrentUserId() == null){
	            System.assert(true, 'Null current user id');
	        }            
	        innerClass.setSelected(true);            
	        if(!innerClass.getSelected()){
	            System.assert(true, 'Not selected');
	        }
	        esbp.acceptChecked();
	      
	        if(innerClass.getCurrentUserId() == null){
	            System.assert(true, 'Null current user');
	        }         
	        
	        
	        esbp.getEffectiveDate();
	        
	        esbp.SetStatus('Completed');
	        esbp.getStatus();
	        
	     
	        esbp.setLastName('Test');
	      
	        esbp.reloadManagers();
	        
	        esbp.acceptChecked();
	        
	    	esbp.setEffectiveDate('FY10');
	    	esbp.refreshLinks();
	    	esbp.getHiddenNumberOfPages();
	    	esbp.setHiddenNumberOfPages(1);
	    	esbp.getTotalPages();
	    	esbp.getCurrentPage(); 
	    	esbp.getShowPagination(); 
	    
	    	esbp.getStatus();
	    	esbp.getLastIdSortedByStatus();
	    
	    	esbp.setLastId(userInfo.getUserId());
	    	esbp.Dummy(); 
	    	
 
       Test.stopTest() ;
       
     }
    
}