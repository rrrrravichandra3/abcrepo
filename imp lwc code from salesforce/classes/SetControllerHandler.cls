/*
* ===========================================================================
* Timba Confidential
*
* Timba Surveys
*
* (C) Copyright Timba Software Corp., 2009-2011.
*
* The source code for this program is not published or otherwise divested of
* its trade secrets, irrespective of what has been deposited with the U.S.
* Copyright office.
*
*/
/**
*	SetControllerHandler aka Pagination Handler
*	@author bdiaz@timbasoftware.com
*	Created Date 5/2010
*/
public without sharing class SetControllerHandler {
	// The Core 
	public ApexPages.StandardSetController setController {get;set;}
	/* Properties */
	public Double pageSize {get;set;}
	/* New - Store Local Query */
	private String storedQuery = '';

	/* Get Results Of The Query */
	public List<Sobject> getQuery(){
   		return (List<Sobject>) this.setController.getRecords();
   	}
   	
   	/* Set Query */
	public void setQuery(String soql){

		storedQuery = soql;
		if(pageSize==null){
			pageSize = 10;
		}
   		Integer pageNumber = 1;
   		if(this.setController != null){
   			pageNumber = this.setController.getPageNumber();
   		}
   		this.setController = new ApexPages.StandardSetController(Database.getQueryLocator(soql));
    	this.setController.setPageSize(pageSize.intValue());
    	if( ((this.setController.getResultSize()/pageSize)+1)<= pageNumber){
    		pageNumber --;
    	}
    	this.setController.setPageNumber(pageNumber);
   	}

   	/* Set Query */
	public void setQueryList(List<Sobject> lobj){
		//storedQuery = soql;
		if(pageSize==null){
			pageSize = 10;
		}
   		Integer pageNumber = 1;
   		if(this.setController != null){
   			pageNumber = this.setController.getPageNumber();
   		}
   		this.setController = new ApexPages.StandardSetController(lobj);
    	this.setController.setPageSize(pageSize.intValue());
    	if( ((this.setController.getResultSize()/pageSize)+1)<= pageNumber){
    		pageNumber --;
    	}
    	this.setController.setPageNumber(pageNumber);
   	}

   	/* Pagination Methods */
	public void GoPrevious(){ setController.previous();}

	public void GoNext(){ setController.next(); }

	public void GoLast(){ setController.last(); }

	public void GoFirst(){ setController.first(); }

	/* This method returns true if there is a page before the acttual */
	public Boolean getRenderPrevious(){return setController.getHasPrevious();}
   	/* This method returns true if there is a page after the acttual */
	public Boolean getRenderNext(){return setController.getHasNext();}
	/* This method returns the size of the list */
	public Integer getRecordSize(){return setController.getResultSize();}
	/*
	*	This method returns total page number
	*	This method is affected by the page size
	*/
	public Integer getTotalPages(){
		double div = (setController.getResultSize())/double.valueOf(String.valueOf(PAGESIZE));
		if (div> div.intValue()) {
		  div = div + 1 ;
		}
		if (div ==0) {
		  div = 1 ;
		}
		return div.intValue();
	}

	/* Get Page Number */
	public Integer getPage(){return setController.getPageNumber();}
	/* Set Page Number */
	public void setPage(){
		setController.setpageNumber(integer.valueOf(ApexPages.currentPage().getParameters().get('Page')));
   	}
   	/*
   		Usefull Methods To Construct The Paginator Environment
   	*/
   	/* Refresh Environment  */
   	public void refreshList(){
   		this.setQuery(storedQuery);
	}
	/* Generate a set with every Page */
	public Set<Integer> getNumericPaginationSet(){
		Set<Integer> tempSet = new Set<Integer>();
		for(integer i=1;i <= getTotalPages() ;i++){
			tempSet.add(i);
		}
		return tempSet;
	}
	/* Generate a set with characters */
	public List<String> getAlphabeticPaginationSet(){
		List<String> tempList = new List<String>{'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','*'};
		tempList.sort();
		return tempList;
	}
	
	/*
	*	Search By™ Engine
	*	Search By char or word in the Base query
	*/
	public void searchBy(){
		String operation = ApexPages.currentPage().getParameters().get('op');
		String field = ApexPages.currentPage().getParameters().get('field');
		String searchBy = '';
		Boolean isUpdated = false;

		Pattern fromPattern = Pattern.compile(' [fF][rR][oO][mM] [a-zA-Z]+(__c)*( [a-z]{1})?');
		Pattern likePattern = Pattern.compile(field+' [lL][iI][kK][eE] \'%*((.)*?)%*\'');
		Pattern baseSoqlPattern = Pattern.compile('(?<=^|\\))[^\\)\\(]+?(?=\\(|$)');
		Pattern nestedSoqlPattern = Pattern.compile('[\\(][^\\)\\(]*[\\)]');

		integer searchStartIndex = 0;
		searchStartIndex =  storedQuery.toLowerCase().indexOf('from ' + String.valueOf(getQuery().getSobjectType()).toLowerCase());
		string SoqlPartToEdit ='';
		string SoqlFirstPart = '';

		//My Patch
		if(searchStartIndex>-1){
			SoqlPartToEdit = storedQuery.substring(searchStartIndex,storedQuery.length());
			SoqlFirstPart = storedQuery.substring(0,searchStartIndex);
		}
		//
		// Like
		Matcher likeMatcher = likePattern.matcher(storedQuery);
		String likeExpresion = '';
		while(likeMatcher.find()){
			likeExpresion = likeMatcher.group(0);
		}
		// Escape single quotes and bing variables
		String searchString = ApexPages.currentPage().getParameters().get('param');
		searchString = String.escapeSingleQuotes(searchString);
		field = String.escapeSingleQuotes(field);
		if(operation == 'byChar'){
			searchBy = searchString + '%';
		}else if(operation=='byWord'){
			/* By Word */
			searchBy = '%' + searchString + '%';
		}
		if(likeExpresion==''){
			if(storedQuery.toLowerCase().indexOf(' Where ') != -1){
				storedQuery = SoqlPartToEdit.replaceFirst(' [wW][hH][eE][rR][eE] ',' Where ' + field +' like \'' + searchBy + '\' and ');
			}else{
				Matcher fromMatcher = fromPattern.matcher(storedQuery);
				while(fromMatcher.find() && !isUpdated){
					storedQuery = SoqlPartToEdit.replaceFirst(fromMatcher.group(0),fromMatcher.group(0)+' Where ' + field + ' Like \'' + searchBy + '\' ');
					isUpdated=true;
				}
			}
		}else{
			storedQuery = SoqlPartToEdit.replaceFirst(likeExpresion,field+' Like \'' + searchBy + '\'');
		}
		storedQuery = SoqlFirstPart+storedQuery;
		this.setQuery(storedQuery);
	}

}