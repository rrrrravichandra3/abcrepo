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
*/ 

public with sharing class PerformanceIntroController {
        PerformanceReview__c    performanceReview;
        V2MOM__c                v2mom;
        String                  currentUserId = userInfo.getUserId();
        
        public class SharingException extends Exception {} 
  
        list<Method>                        methods;
        boolean                             isPCOMMLikeViewProfile;
        User                                currentUser;
        User                                scorecardTypeProfile;
        public PerformanceAccessUtil        accessUtil;
        //PerformanceReviewPrint.MethodUtil   utilMethod = new PerformanceReviewPrint.MethodUtil();
        PerformanceSOQLController  util = new PerformanceSOQLController();
        AdditionalCommentDate               currentComment;                                     
        AdditionalCommentDate               commentsManager;
        AdditionalCommentDate               commentsEmployee;
        List<Competency>                    competencies;
        public PageReference status {get;set;}
        List<User>                          EmplAndMngrUsers;
        private String                      msgError = '';
        private boolean                     showError = false;
        private boolean                     reject = false;  
        String                              v2momType = '';
        String                              effectiveDate = '';
        public boolean isAdHoc {get;set;}         
                 
        public PerformanceIntroController (ApexPages.StandardController stdController, Id i) {
            currentUserId = i;
            constructor(stdController);
            accessUtil.setUserInf(i);
            isPCOMMLikeViewProfile = accessUtil.getPCOMMLikeViewProfile();
        }                
        
        // The extension constructor initializes the private member
        // variable by using the getSubject method on the standard
        // controller.
        public PerformanceIntroController (ApexPages.StandardController stdController) {
            constructor(stdController);
        }
        
        public PageReference goStep1(){
            return new PageReference('/apex/NewPeopleForceStep1?id=' + performanceReview.Id);   
        }
        public boolean getShowRatingToEmployee(){
        	boolean showIt = false;
        	set<String> possibleStatus = new set<string>();
        	possibleStatus.add('Employee Approval');
        	possibleStatus.add('Complete');
        	if(performanceReview.Employee__c==userInfo.getUserId()&&possibleStatus.contains(performanceReview.Status__c)){
        		showIt=true;
        	}
        	return showIt;
        }
        public void constructor(ApexPages.StandardController stdController) {
            
          
            isAdHoc = false;
            performanceReview = (PerformanceReview__c)stdController.getSubject();
            
            performanceReview = new IntroUtil().getPerformanceReviewDetail(performanceReview);
            if (performanceReview == null) 
                throw new SharingException(Label.PerformanceV2MOMAssessmentController_exception2);
            
            if(performanceReview != null){           
               if(performanceReview == null) {
                 throw new SharingException(Label.PerformanceV2MOMAssessmentController_exception2);
               }
               else {

                  v2mom = [SELECT Vision__c, Locked__c, IsLocked, ParentId__c, V2MOM_Type__c FROM V2MOM__c WHERE Id =: performanceReview.V2MOM__c];    
               }
            }
            
            if (v2mom == null) {
                throw new SharingException(Label.PerformanceIntroPage_Exception1);
            }
             
            currentUser = [Select Id, Profile.Name From User u where id = :currentUserId];            
            util.setCurrentUser(currentUser);
            
            // gets the profile of the employee to see what kind of scorecard it might have
            scorecardTypeProfile = [Select Id, Profile.Name From User u where id = :performanceReview.Employee__c];   
            
            // access class for permissions
            accessUtil = new PerformanceAccessUtil(performanceReview, currentUser, scorecardTypeProfile);

            EmplAndMngrUsers = [Select  Name,
                                        lastName,
                                        firstName,
                                        Title,
                                        Cost_Center__c
                                From User
                                Where id=:performanceReview.Employee__c or
                                id=:performanceReview.Manager__c];
                                //Department

            // uses the inion of the performance review to check if the profile of the
            // current user should see data filtered by sharing rules or filtered manually
            isPCOMMLikeViewProfile = accessUtil.getPCOMMLikeViewProfile();
            
            commentsManager = getManagerComments();
            commentsEmployee = getEmployeeComments();
            
            if ((v2momType == '') || (v2momType == null)){
                List<V2MOM__c> v2momaux = [Select v.V2MOM_Type__c, v.Effective_Date__c
                                           From V2MOM__c v
                                           Where v.id=:performanceReview.V2MOM__c];

                
                if (v2momaux.size() > 0)
                {
                    v2momType = v2momaux.get(0).V2MOM_Type__c;
                    if(v2momaux.get(0).Effective_Date__c != null){
                        effectiveDate = v2momaux.get(0).Effective_Date__c;
                    
                    }else{
                        
                    }
                }
            }
            
        }

        public void setPerformanceReview(PerformanceReview__c pr){
            performanceReview = pr;
            
            performanceReview = new IntroUtil().getPerformanceReviewDetail(performanceReview);
            
            if(performanceReview == null) throw new SharingException(Label.PerformanceV2MOMAssessmentController_exception2);

            if (performanceReview.V2MOM__c != null)
                v2mom = [SELECT Vision__c, Locked__c, IsLocked, ParentId__c FROM V2MOM__c WHERE Id =: performanceReview.V2MOM__c];
        }
        
        public PerformanceReview__c getPerformanceReview(){
            return performanceReview;
        }

        public V2MOM__c getV2MOM() {
            return v2mom;
        }
        
        public String getCurrentUserId(){
            return currentUserId;
        }

        public void setCurrentUserId(String id){
            currentUserId = id;
        }

        // Return employee user data of performance review 
        public User getEmployee(){
            for(User u: EmplAndMngrUsers){
                if (u.id == performanceReview.Employee__c)
                    return u;
            }
            return null;
        }
	
		/**
		* Return if the performance review is or not in employee self assesment or created status
		* @Return Boolean
		*/
		public Boolean getIsEmployeeSelfAssessmentOrCreated()
		{
			return 	performanceReview.Status__c == 'Employee Self Assessment' || performanceReview.Status__c == 'Created'; 
		}
	public String getDueDate(){
		if (PerformanceReview.DueDate__c != null)
		{
			String dueDateMM_dd_yyyy;
			Date dueDate = PerformanceReview.DueDate__c; 
			dueDateMM_dd_yyyy = dueDate.month()+ '/' + dueDate.day() + '/' + dueDate.year();
			return dueDateMM_dd_yyyy;
		}
		else
		{
			return '';
		}
	}
	
	public String getQuarter(){
		if(performanceReview.Quarter__c == 'null'){
			return '-';
		}	
		return performanceReview.Quarter__c;
	}
	
    public boolean getIsShort(){
    	
        return (((performanceReview.PerformanceReviewPeriod__r.V2MOM_Type__c != null && performanceReview.PerformanceReviewPeriod__r.V2MOM_Type__c.equals('Individual')) || (performancereview.V2MOM__r.V2MOM_Type__c != null && performancereview.V2MOM__r.V2MOM_Type__c.equals('Individual'))) 
                && (performanceReview.Name.contains('(Short)')));
    }
    public boolean getIsYearEnd(){
    	
    	
       if (getIsIndividual())return false;
        return (performanceReview.PerformanceReviewPeriod__r.V2MOM_Type__c != null && (performanceReview.PerformanceReviewPeriod__r.V2MOM_Type__c.equals('Year End Short') || (performanceReview.V2MOM__r.V2MOM_Type__c != null && performanceReview.V2MOM__r.V2MOM_Type__c.equals('Year End Short')))) 
        		|| (performanceReview.V2MOM__r.V2MOM_Type__c != null && 
        ( 	(performanceReview.V2MOM__r.V2MOM_Type__c.equals('Individual') && //Not is an Ad Hoc Short
        	(!performanceReview.Name.contains('(Short)'))) || (performanceReview.V2MOM__r.V2MOM_Type__c != null && performanceReview.V2MOM__r.V2MOM_Type__c.equals('Year End Short')))
        );
               
    }
   public String getPrId(){
   		system.debug(ApexPages.currentPage().getParameters().get('id'));
    	return ApexPages.currentPage().getParameters().get('id');
    }
    public boolean getIsSales(){
    	System.debug('##################################PerformanceReviewPeriod V2MOM_Type: ' + performanceReview.PerformanceReviewPeriod__r.V2MOM_Type__c);
    	System.debug('##################################V2MOM_Type: ' + performanceReview.V2MOM__r.V2MOM_Type__c);
    			
	       		return 	(performanceReview.V2MOM__r.V2MOM_Type__c != null && performanceReview.V2MOM__r.V2MOM_Type__c.equals('Sales')) || 
       				(performanceReview.PerformanceReviewPeriod__r.V2MOM_Type__c != null && performanceReview.PerformanceReviewPeriod__r.V2MOM_Type__c.equals('Sales'));
    }
    
    // Employee, Manager, 2nd Manager or 3rd Party in Assessment - Write permission
	public boolean getIsEmplMngr2ndMngrOr3PtInAssmnt() {
		return accessUtil.getIsEmplMngr2ndMngrOr3PtInAssmnt();
	} 
     
        // Return manager user data of performance review 
        public User getManager(){
            for(User u: EmplAndMngrUsers){
                if (u.id == performanceReview.Manager__c)
                    return u;
            }
            return null;
        }
        
        /**
        * Return true if user have privileges for modify value or is system admin
        */        
        public boolean getWithPrivileges() {
            // if have privileges
            List<Id> group_member_list = new List<Id>();
            for (GroupMember share_group : [select Id
                                            from GroupMember 
                                            where UserOrGroupId =:currentUserId]) {
                group_member_list.add(share_group.Id);
            }
     
            V2MOM__Share[] shares = [select Id, AccessLevel 
                                    from V2MOM__Share 
                                    where ParentId = :performanceReview.V2MOM__c 
                                        and (UserOrGroupId = :currentUserId
                                        or UserOrGroupId in :group_member_list)];
        
            if (shares.size() > 0){
                return (!shares[0].AccessLevel.equals('Read') && !v2mom.Locked__c);
            }
            
           if (accessUtil.getIsSysAdminProfile() && (! v2mom.Locked__c))
                return true;
                
            return false;
        }        
        
    	public boolean getIsManagerAssessment(){
    			return performanceReview.Status__c == 'Manager Assessment';
   		 }
         
        public boolean getIsIndividual(){
        	
        	return 	(performanceReview.V2MOM__r.V2MOM_Type__c != null && performanceReview.V2MOM__r.V2MOM_Type__c.equals('Individual')) && 
        			(performanceReview.PerformanceReviewPeriod__r.V2MOM_Type__c != null && performanceReview.PerformanceReviewPeriod__r.V2MOM_Type__c.equals('Individual'));
        }
	
        public PageReference setStatus(){
        	
        	if (getIsShort()) {
        		isAdHoc = true;
        	}
        	
        	if (getIsIndividual()) {
        		isAdHoc = true;
        	}
        	
            //get ReviewFormTemplate Owner
            Id ownerId = [Select OwnerId From ReviewFormTemplate__c Where Id =: performanceReview.ReviewFormTemplate__c].OwnerId;
            if (currentUserId != ownerId && currentUser.Profile.Name != 'System Administrator' && currentUser.Profile.Name != 'systemadministrator'){
                ReviewFormTemplate__Share rftShare = new ReviewFormTemplate__Share ();
                rftShare.AccessLevel    = 'Edit';
                rftShare.ParentId       = performanceReview.ReviewFormTemplate__c;
	        	rftShare.UserOrGroupId 	= currentUserId;
                
                PerformanceReviewPeriod__Share periodShare = new PerformanceReviewPeriod__Share();
	        	periodShare.AccessLevel = 'Read';
	        	periodShare.ParentId = performanceReview.PerformanceReviewPeriod__c;
	        	periodShare.UserOrGroupId = currentUserId;                      
            }
        	
        	
        	
            if ((performanceReview.Status__c == null || performanceReview.Status__c.equals('Created'))
                && (currentUserId.equals(performanceReview.Employee__c))) {
                 performanceReview.Status__c = 'Employee Self Assessment';
                 
                 performanceReview.PreviousStatus__c = 'Created';  // this is here b/c the trigger updates the database but not the value in the memory in the controller

            }
            
            //this function is to add the old hierarchy to the performance review share, 
            //only to ad hoc PRs 
            if(performanceReview.V2MOM__r.V2MOM_Type__c == 'Ad Hoc' || (performanceReview.PerformanceReviewPeriod__r.V2MOM_Type__c != null && performanceReview.PerformanceReviewPeriod__r.V2MOM_Type__c.equals('Ad Hoc'))){
            	isAdHoc = true;
            }
            PageReference pageref = null;
            //if is sales	
            if(getIsSales()){
            	List<CompetencyReview__Share> crShares = new List<CompetencyReview__Share>();
            	PerformanceReview__c pr = [Select pr.Id, pr.CompetencyGroup__c, (Select Id From R00N700000027PKjEAM Where PerformanceReview__c =: getPrId()) From PerformanceReview__c pr Where pr.Id =: getPrId()];
            	if(getIsESBP() || this.getIsMngr()){
            		
            		
            		for(CompetencyReview__c cr : pr.R00N700000027PKjEAM){
                        CompetencyReview__Share crShare = new CompetencyReview__Share();
                        crShare.AccessLevel = 'Edit';
                        crShare.ParentId = cr.Id;
                        crShare.UserOrGroupId = userInfo.getUserId();
                        crShares.add(crShare);
                        
                    }
                    CompetencyGroup__Share cgShare = new CompetencyGroup__Share();
                    cgShare.AccessLevel = 'Edit';
                    cgShare.ParentId = pr.CompetencyGroup__c;
                    cgShare.UserOrGroupId = userInfo.getUserId(); 
            	}else{
            		if (performanceReview.Employee__c == userInfo.getUserId() && performanceReview.Status__c == 'Manager Assessment'){
            			for(CompetencyReview__c cr : pr.R00N700000027PKjEAM){
                        	CompetencyReview__Share crShare = new CompetencyReview__Share();
                        	crShare.AccessLevel = 'Read';
                       	 	crShare.ParentId = cr.Id;
                        	crShare.UserOrGroupId = userInfo.getUserId();
                        	crShares.add(crShare);
                        
                    	}
            		}
            	}
            	
	            pageref = page.salesScoreCard_new;
				pageref.getparameters().put('prId', getPrId());
				pageref.setRedirect(true);
            }
            else if(getIsYearEnd()){
                
                if(performanceReview.PerformanceReviewPeriod__r.Effective_Date__c != null && 
                   performanceReview.PerformanceReviewPeriod__r.Effective_Date__c.equals('FY12')){
                
                    pageref = page.PerformanceReviewYearEnd;
                }else{
                    pageref = page.performanceReview;
                }
                
                if(performanceReview.PerformanceReviewPeriod__r.Effective_Date__c == null &&
                   this.effectiveDate != null){
                    if(effectiveDate.equals('FY12')){
                        pageref = page.PerformanceReviewYearEnd;
                    }else{
                        pageref = page.performanceReview;
                    }
                }
                
                pageref.getparameters().put('id', getPrId());
                pageref.setRedirect(true);
            }
            else if (pageref != null){
            	System.debug('PageRef URL: ' + pageref.getUrl());
            }
            
            return pageref;
        }

        public String getStartLinkText() {

            if(getIsCurrentReviewer())
                return Label.Start_Now_label;
            else
                return Label.View_Employee_s_Performance_Review_label;
        }

        public String getStepsTopMargin(){
            if(performanceReview.Status__c.equals('Pending Employee Services') || performanceReview.Status__c.equals('PCOMM Review'))
            return 'margin-top:134px;';
            else return 'margin-top:none;';
        }

        public Boolean getIsCurrentReviewer() {
            if(currentUserId.equals(performanceReview.SecondManager__c) &&
                   (performanceReview.Status__c.equals('2nd Level Manager Assessment') ||
                    performanceReview.Status__c.equals('2nd Level Manager Approval') )) 
                return true;

            if(currentUserId.equals(performanceReview.Manager__c) &&
                   (performanceReview.Status__c.equals('Manager Assessment') ||
                    performanceReview.Status__c.equals('Manager Approval') )) 
                return true;

            if(currentUserId.equals(performanceReview.Employee__c) &&
                   (performanceReview.Status__c.equals('Employee Self Assessment') ||
                    performanceReview.Status__c.equals('Employee Approval') ||
                    performanceReview.Status__c.equals('Created') )) 
                return true;

            if(currentUserId.equals(performanceReview.ThirdPartyReviewer__c) &&
                    performanceReview.Status__c.equals('3rd Party Assessment') ) 
                return true;
                    
            if(currentUserId.equals(performanceReview.PCOMM__c) &&
                    performanceReview.Status__c.equals('PCOMM Review') ) 
                return true;

            return false;
        }

        public String getStyleEditV2MOMLink(){
            if(performanceReview.V2MOM__r.Name == null
                    || performanceReview.V2MOM__r.Locked__c)
                return 'display:none';
            else return '';
        }

        public list<PerformanceReview__History> getDateApprovalList(){
            return  [SELECT CreatedDate,
            				Id,
                            CreatedById,
                            CreatedBy.Profile.Name,
                            NewValue,
                            OldValue,
                            Field 
                    FROM PerformanceReview__History
                    WHERE Field = 'Status__c' AND ParentId =: performanceReview.id
                    Order By CreatedDate desc];
        }
		
		
        // ----------------------------
        // Control info for interface
        // ----------------------------
        public List<Reviewer> getReviewers() {
            
           list<PerformanceReview__History> listHistory = getDateApprovalList();
            
            List<Reviewer> reviewers = new List<Reviewer>();

            reviewers.add( new Reviewer(performanceReview.Employee__r, performanceReview, 'Employee', listHistory) );
            reviewers.add( new Reviewer(performanceReview.Manager__r, performanceReview, 'Manager', listHistory) );

            if( performanceReview.SecondManager__r != null)
                reviewers.add( new Reviewer(performanceReview.SecondManager__r, performanceReview, 'Second Manager', listHistory) );

            reviewers.add( new Reviewer(performanceReview.PCOMM__r, performanceReview, 'PCOMM', listHistory) );
            
            return reviewers;
        }

        public class Reviewer {
            User user;
            PerformanceReview__c review;
            String reviewerType;
            list<PerformanceReview__History>  performanceReviewHistory;
              
            
            public Reviewer(User u, PerformanceReview__c r, String t, list<PerformanceReview__History> l) {
                user = u;
                review = r;
                reviewerType = t;
                performanceReviewHistory = l;
            }

            public String getDateApproval(){
                if(reviewerType.equals('PCOMM') &&
                        (review.Status__c.equals('2nd Level Manager Approval')
                            || review.Status__c.equals('Manager Approval')
                            || review.Status__c.equals('Employee Approval')
                            || review.Status__c.equals('Complete'))){
                                
                    for(Integer i = 0; i < performanceReviewHistory.size(); i++){
                        PerformanceReview__History aux = performanceReviewHistory[i];
                      	
                        if(aux.CreatedById == review.Pcomm__c || aux.CreatedBy.Profile.Name == 'System Administrator' || aux.CreatedBy.Profile.Name == 'systemadministrator'){
                       
                            if(aux.NewValue != null){
	                            if(String.valueOf(aux.NewValue).equals('2nd Level Manager Approval')
	                                    || String.valueOf(aux.NewValue).equals('Manager Approval')){   	
	                                return aux.CreatedDate.format();
	                            }
                            }
                       }
                    }
                }else{
                    if(reviewerType.equals('Second Manager') &&
	                   (review.Status__c.equals('Manager Approval') ||
	                    review.Status__c.equals('Employee Approval') ||
	                    review.Status__c.equals('Complete') 
	                    || review.Status__c.equals('Pending Employee Services')
	                    || review.Status__c.equals('PCOMM Review'))){

                        for(Integer i = 0; i < performanceReviewHistory.size(); i++){
                            PerformanceReview__History aux = performanceReviewHistory[i];
                            if(aux.CreatedById == review.SecondManager__c){
                                if(String.valueOf(aux.NewValue).equals('Pending Employee Services')){
   	
                                    return aux.CreatedDate.format();
                                }
                            }
                        }
                    }
                    else {
                       if(reviewerType.equals('Manager') &&
		                   (review.Status__c.equals('Employee Approval') 
		                   || review.Status__c.equals('Complete') 
		                   || review.Status__c.equals('2nd Level Manager Assessment') 
		                   || (review.Status__c.equals('3rd Party Assessment') && review.PreviousStatus__c.equals('2nd Level Manager Assessment'))
		                   || review.Status__c.equals('Pending Employee Services')
		                   || review.Status__c.equals('PCOMM Review')
		                   || review.Status__c.equals('2nd Level Manager Approval')
		                   || review.Status__c.equals('Manager Approval'))){
                            for(Integer i = 0; i < performanceReviewHistory.size(); i++){
                                PerformanceReview__History aux = performanceReviewHistory[i];
                                if(aux.CreatedById == review.Manager__c){
                                    if (review.SecondManager__c != null) {
                                        if(String.valueOf(aux.NewValue).equals('2nd Level Manager Assessment')){  

                                            return aux.CreatedDate.format();
                                        }
                                    }
                                    else {
                                        if (String.valueOf(aux.NewValue).equals('Pending Employee Services')){
                                               	
                                            return aux.CreatedDate.format();
                                        }   
                                    }
                                }
                            }
                        }else{
                            if(reviewerType.equals('Employee') &&
			                   (review.Status__c.equals('Complete') 
			                   || review.Status__c.equals('Manager Assessment') 
			                   || review.Status__c.equals('3rd Party Assessment') 
			                   || review.Status__c.equals('2nd Level Manager Assessment') 
			                   || review.Status__c.equals('Pending Employee Services') 
			                   || review.Status__c.equals('PCOMM Review') 
			                   || review.Status__c.equals('2nd Level Manager Approval') 
			                   || review.Status__c.equals('Manager Approval')
			                   || review.Status__c.equals('Employee Approval'))){
				                            	                            
				                for(Integer i = 0; i < performanceReviewHistory.size(); i++){
				                    PerformanceReview__History aux = performanceReviewHistory[i];
				                    if(aux.CreatedById == review.Employee__c){
				                        if(String.valueOf(aux.NewValue).equals('Manager Assessment')){
				                               	
				                            return aux.CreatedDate.format();
				                        }
				                    }
				                }
				            }
                        }
                     }
                 }
                return '';
            }
			
			public boolean getLabelApproved(){
				if(reviewerType.equals('PCOMM') &&
	                (review.Status__c.equals('2nd Level Manager Approval')
                    || review.Status__c.equals('Manager Approval')
                    || review.Status__c.equals('Employee Approval')
                    || review.Status__c.equals('Complete'))){
	                	for(Integer i = 0; i < performanceReviewHistory.size(); i++){
                        	PerformanceReview__History aux = performanceReviewHistory[i];                     	
	                        if(aux.CreatedById == review.Pcomm__c || aux.CreatedBy.Profile.Name == 'System Administrator' || aux.CreatedBy.Profile.Name == 'systemadministrator'){
	                       
	                            if(aux.NewValue != null){
		                            if(String.valueOf(aux.NewValue).equals('2nd Level Manager Approval')
		                                    || String.valueOf(aux.NewValue).equals('Manager Approval')){   	
		                                return true;
		                            }
	                            }
	                       	}
                    	}	                 	
                }
                if(reviewerType.equals('Second Manager') &&
                   (review.Status__c.equals('Manager Approval') ||
                    review.Status__c.equals('Employee Approval') ||
                    review.Status__c.equals('Complete') 
                    || review.Status__c.equals('Pending Employee Services')
                    || review.Status__c.equals('PCOMM Review'))){
                    	for(Integer i = 0; i < performanceReviewHistory.size(); i++){
                            PerformanceReview__History aux = performanceReviewHistory[i];
                            if(aux.CreatedById == review.SecondManager__c){
                                if(String.valueOf(aux.NewValue).equals('Pending Employee Services')){	
                                    return true;
                                }
                            }
                        }    	
                }
                if(reviewerType.equals('Manager') &&
                   (review.Status__c.equals('Employee Approval') 
                   || review.Status__c.equals('Complete') 
                   || review.Status__c.equals('2nd Level Manager Assessment') 
                   || review.Status__c.equals('Pending Employee Services')
                   || review.Status__c.equals('PCOMM Review')
                   || review.Status__c.equals('2nd Level Manager Approval')
                   || review.Status__c.equals('Manager Approval'))){
               	 		for(Integer i = 0; i < performanceReviewHistory.size(); i++){
                        	PerformanceReview__History aux = performanceReviewHistory[i];
                            if(aux.CreatedById == review.Manager__c){
                           		if (review.SecondManager__c != null) {
                                	if(String.valueOf(aux.NewValue).equals('2nd Level Manager Assessment')){  
                                            return true;
                                    }
                                }
                                else {
	                                if (String.valueOf(aux.NewValue).equals('Pending Employee Services')){	                                       	
	                                    return true;
	                                }   
                                }
                            }
                        }
               }             
               return false;
			}
			
			public String getDateApprovedEmployee(){
				
				if(reviewerType.equals('Employee') &&
                        (review.Status__c.equals('2nd Level Manager Approval') ||
                            review.Status__c.equals('Manager Approval') ||
                            review.Status__c.equals('Employee Approval') ||
                            review.Status__c.equals('Complete') )){
                                
                                
                    for(Integer i = 0; i < performanceReviewHistory.size(); i++){
                        PerformanceReview__History aux = performanceReviewHistory[i];
                        if(aux.CreatedById == review.Employee__c){
                            if(String.valueOf(aux.NewValue).equals('Complete')){ 	
                                return aux.CreatedDate.format();
                            }
                        }
                    }
                }
	            return '';
			}
			
            // UI control info
            public Boolean getApproved() {
				
                if(reviewerType.equals('PCOMM') &&
                   (review.Status__c.equals('2nd Level Manager Approval') ||
                    review.Status__c.equals('Manager Approval') ||
                    review.Status__c.equals('Employee Approval') ||
                    review.Status__c.equals('Complete'))) return true;

                if(reviewerType.equals('Second Manager') &&
                   (review.Status__c.equals('Manager Approval') ||
                    review.Status__c.equals('Employee Approval') ||
                    review.Status__c.equals('Complete') ||
                    review.Status__c.equals('Pending Employee Services') ||
                    review.Status__c.equals('2nd Level Manager Approval')||
                    review.Status__c.equals('PCOMM Review'))) return true;

	
                if(reviewerType.equals('Manager') && (review.Status__c.equals('Employee Approval') 
                   || review.Status__c.equals('Complete')  
                   || review.Status__c.equals('2nd Level Manager Assessment') 
                   || (review.Status__c.equals('3rd Party Assessment') && review.PreviousStatus__c.equals('2nd Level Manager Assessment'))
                   || review.Status__c.equals('Pending Employee Services')
                   || review.Status__c.equals('PCOMM Review')
                   || review.Status__c.equals('2nd Level Manager Approval') 
                   || review.Status__c.equals('Manager Approval'))) return true;

                if(reviewerType.equals('Employee') &&
                   (review.Status__c.equals('Complete') 
                   || review.Status__c.equals('Manager Assessment') 
                   || review.Status__c.equals('2nd Level Manager Assessment') 
                   || review.Status__c.equals('3rd Party Assessment') 
                   || review.Status__c.equals('Pending Employee Services') 
                   || review.Status__c.equals('PCOMM Review') 
                   || review.Status__c.equals('2nd Level Manager Approval') 
                   || review.Status__c.equals('Manager Approval'))) return true;

                return false;
            }

            public Boolean getCurrentReviewer() {

                if(reviewerType.equals('PCOMM') &&
                   (review.Status__c.equals('Pending Employee Services') ||
                    review.Status__c.equals('PCOMM Review') )) 
                    return true;

                if(reviewerType.equals('Second Manager') &&
                   (review.Status__c.equals('2nd Level Manager Assessment') ||
                    review.Status__c.equals('2nd Level Manager Approval')  ||
                    (review.Status__c.equals('3rd Party Assessment') &&
                    review.PreviousStatus__c.equals('2nd Level Manager Assessment') ))) 
                    return true;

                if(reviewerType.equals('Manager') &&
                   (review.Status__c.equals('Manager Assessment') ||
                    review.Status__c.equals('Manager Approval') ||
                    (review.Status__c.equals('3rd Party Assessment') &&
                    review.PreviousStatus__c.equals('Manager Assessment') ))) 
                    return true;

                if(reviewerType.equals('Employee') &&
                   (review.Status__c.equals('Employee Self Assessment') ||
                    review.Status__c.equals('Employee Approval') ||
                    review.Status__c.equals('Created') )) 
                    return true;

                return false;
            }
            
            public Boolean getCurrentReviewerReview() {

                if(reviewerType.equals('PCOMM') &&
                   review.Status__c.equals('Pending Employee Services')) return true;

                if(reviewerType.equals('Second Manager') &&
                   (review.Status__c.equals('2nd Level Manager Assessment') ||
                    (review.Status__c.equals('3rd Party Assessment') &&
                    review.PreviousStatus__c.equals('2nd Level Manager Assessment') ))) return true;

                if(reviewerType.equals('Manager') &&
                   (review.Status__c.equals('Manager Assessment') ||
                    (review.Status__c.equals('3rd Party Assessment') &&
                    review.PreviousStatus__c.equals('Manager Assessment') ))) return true;

                if(reviewerType.equals('Employee') &&
                   (review.Status__c.equals('Manager Assessment') ||
                    review.Status__c.equals('Created') )) return true;

                return false;
            }

            public Boolean getCurrentReviewerApproval() {

                if(reviewerType.equals('PCOMM') &&
                   review.Status__c.equals('PCOMM Review') ) return true;

                if(reviewerType.equals('Second Manager') &&
                   review.Status__c.equals('2nd Level Manager Approval')) return true;

                if(reviewerType.equals('Manager') &&
                    review.Status__c.equals('Manager Approval')) return true;

                if(reviewerType.equals('Employee') &&
                    review.Status__c.equals('Employee Approval')) return true;

                return false;
            }
            
            public String getStatus() {
                
                if (reviewerType.equals('Employee') && review.Status__c.equals('Created'))
                        return Label.Start_Performance_Review_label;   /// TODO this currently does not show up b/c the setStatus changes the v
                                                             /// alue before this method can run.  Should probably move the set
                                                             /// status to V2MOMAssessment.

                if (review.PreviousStatus__c == null) return '';

                // If Manager or 2nd Manager is previous status and 3rd party is current status
                // then show the                
                if (review.Status__c.equals('3rd Party Assessment') && (reviewerType.equals('Manager') &&
                    review.PreviousStatus__c.equals('Manager Assessment')) ||
                   (reviewerType.equals('Second Manager') && review.PreviousStatus__c.equals('2nd Level Manager Assessment')))
                        return Label.Waiting_for_Third_Party_Review_by_label + ' ' + review.ThirdPartyReviewer__r.Name;
                
                if (reviewerType.equals('Employee') && review.Status__c.equals('Employee Self Assessment') )
                        return Label.In_Progress_label;

                if (reviewerType.equals('Employee') && review.Status__c.equals('Complete'))
                        return Label.Performance_Review_Completed_label;

                if (getCurrentReviewerReview()) return Label.Waiting_for_review_label;
				
				if((reviewerType.equals('PCOMM') && review.Status__c.equals('PCOMM Review')) || (reviewerType.equals('Employee') && review.Status__c.equals('Employee Approval'))) return Label.Waiting_for_approval_label;
                   
                if(reviewerType.equals('Manager') &&
                    review.Status__c.equals('Manager Approval')) return 'Waiting to route to Employee';   
                
                return '';
            }

            public Boolean getIsUserReviewer() {
                return UserInfo.getUserId() == user.Id;
            }
			
            // Accessors
            public String getName() {
                return user.Name;
            }  

            public String getTitle() {
                if(user.Title == null){
                    return '';
                }
                return user.Title;
            }

            public String getDepartment() {
                //if(user.Department == null){
                if(user.Cost_Center__c == null){
                    return '';
                }
                //return user.Department;
                return user.Cost_Center__c;
            }

            public String getLocation(){
                if(reviewerType.equals('PCOMM')) {
                    return '';
                }
                if(user.City == null || user.Country == null){
                    return '';
                }
                return user.City + ', ' + user.Country;
            }

            public String getReviewerType() {
                if(reviewerType.equals('PCOMM'))
                    return Label.PerformanceESBPAdminController_PCOMMLabel;
                if(reviewerType.equals('Manager'))
                    return Label.Manager_label;
                if(reviewerType.equals('Second Manager'))
                    return Label.Second_Manager_label;
                if(reviewerType.equals('Employee'))
                    return Label.Employee_label;
                    
                return reviewerType;
            }
            
			public boolean getIsReviewerEmployee(){
				if(!reviewerType.equals('Employee')){
					return false;
				}
				return true;
			}
			
			public boolean getIsCompleted(){
				if(reviewerType.equals('Employee') && review.Status__c == 'Complete'){
					return true;
				}
				return false;
			}
            public String getCalculatedRating(){

                double calculatedRating = review.ReviewRating__r.CalculatedRating__c;
                if(review.ReviewRating__r.CalculatedRating__c == null) {
                    return '';
                }
                String subStr = String.valueOf(calculatedRating);
                if(reviewerType.equals('PCOMM'))
                {
                    return Label.Calculated_Overall_Rating_label + ': -';
                }
                if( subStr.length() > 3){
                   return Label.Calculated_Overall_Rating_label + ': ' +  subStr.substring(0,4);
                }
                   return Label.Calculated_Overall_Rating_label +': ' + subStr.substring(0,3);
            }
        }
        
        /*
			Returns true if the profile of the logged user is Employee Success/Business Partner.
		*/
		public Boolean getIsESBP(){
			Profile p = [Select id,name From Profile Where Name=:'Employee Success/Business Partner'];
			return (UserInfo.getProfileId()==p.id); 
		}

        public list<Value> getValues(){

            List<Value__c> values =  [Select name
                                      From Value__c
                                      Where V2MOM__c=:performanceReview.V2MOM__c
                                      Order by Priority__c];

            List<Value> retValues = new List<Value>();

            for(Integer i = 0; i < values.size(); i++) {

                if(i == values.size() - 1)
                    retValues.add(new Value(values[i], true));
                else
                    retValues.add(new Value(values[i], false));
            }
            return retValues;
        }

        // This is BS that i have to do this.  There should be something within the apex repeat component that
        // lets me know this is the last element
        public class Value {

            Value__c value;
            Boolean isLast;

            public Value(Value__c v, Boolean l) {
                value = v;
                isLast = l;
            }

            public String getName() {
                return value.Name;
            }

            public Boolean getIsLast() {
                return isLast;
            }

            public String getId() {
                return value.Id;
            }
        }

        public with sharing class IntroUtil {

            public PerformanceReview__c getPerformanceReviewDetail(PerformanceReview__c p) {

                List<PerformanceReview__c> prs = [Select id, name,
                										   v2momRating__c,	
                										   Rating__c,
                                                           Status__c,
                                                           PreviousStatus__c,
                                                           Employee__r.Name,
                                                           Employee__r.Title,
                                                           Employee__r.Cost_Center__c,
                                                           Employee__r.City,
                                                           Employee__r.Country,
                                                           Manager__r.Name,
                                                           Manager__r.Title,
                                                           Manager__r.Cost_Center__c,
                                                           Manager__r.City,
                                                           Manager__r.Country,
                                                           SecondManager__r.Name,
                                                           SecondManager__r.Title,
                                                           SecondManager__r.Cost_Center__c,
                                                           SecondManager__r.City,
                                                           SecondManager__r.Country,
                                                           ThirdPartyReviewer__r.Name,
                                                           PCOMM__r.Name,
                                                           OwnerId,
                                                           PCOMM__r.Title,
                                                           PCOMM__r.Cost_Center__c,
                                                           PCOMM__r.City,
                                                           PCOMM__r.Country,
                                                           ReviewRating__r.CalculatedRating__c,
                                                           PerformanceReviewPeriod__r.name,
                                                           PerformanceReviewPeriod__r.EndDate__c,
                                                           PerformanceReviewPeriod__r.Effective_Date__c,
                                                           PerformanceReviewPeriod__r.V2MOM_Type__c,
                                                           ReviewFormTemplate__r.Introduction__c,
                                                           CompetencyGroup__c,
                                                           V2MOM__c,
                                                           V2MOM__r.V2MOM_Type__c,
                                                           V2MOM__r.Name,
                                                           V2MOM__r.Locked__c,
                                                           Quarter__c,
                                                           DueDate__c,
                                                           EmailComment__c
                                                    From PerformanceReview__c
                                                    Where id = :p.id];

                if(prs.size() == 0) {
                     throw new SharingException(Label.PerformanceV2MOMAssessmentController_exception2);
                }
                else {
                     return prs.get(0); 
                }
            }
    }
        
        
    //////////////////////////////// Performance Intro SHORT ////////////////////////////////
    
    
    public List<Method> getMethods(){           
        methods = new List<Method>();
            
        list<Value__c> tempValues = [SELECT Name,
                                           (SELECT Id
                                            FROM Methods__r)
                                     FROM Value__c
                                     WHERE V2MOM__c = :performanceReview.V2MOM__c
                                     ORDER BY Priority__c];
                          
        list<Method__c> methodsc = [Select m.id, 
                                           m.name, 
                                           m.Value__c, 
                                           m.Value__r.Name, 
                                           m.Description__c, 
                                           (Select name, description__c From Obstacles__r ORDER BY Priority__c),  
                                           (Select name, description__c From Measures__r ORDER BY Priority__c)
                                    From Method__c m
                                    Where V2MOM__c=:performanceReview.V2MOM__c
                                       and Value__c IN :tempValues
                                    ORDER BY Priority__c];
                                        
        list<Method__c> methodsc_withoutvalue = [Select m.id, 
                                                       m.name, 
                                                       m.Value__c, 
                                                       m.Value__r.Name, 
                                                       m.Description__c, 
                                                       (Select name, description__c From Obstacles__r),  
                                                       (Select name, description__c From Measures__r)
                                                From Method__c m
                                                Where V2MOM__c=:performanceReview.V2MOM__c
                                                   and Value__c NOT IN :tempValues
                                                ORDER BY Priority__c];
                                    
        list<MethodReview__c> historyMethods = new List <MethodReview__c>();
                                   
        Map<Id, MethodReview__c> methodReviewsManager;
        Map<Id, MethodReview__c> methodReviewsEmployee;
        List<MethodReview__c> methodReviewsComments;

        if (isPCOMMLikeViewProfile) {
            // retrieve data without sharing       
            methodReviewsManager = getPerformanceReviewDataWithoutSharing(performanceReview, methodsc);
            methodReviewsEmployee = getPerformanceReviewEmployeeWithoutSharing(performanceReview, methodsc);
            methodReviewsComments = getPerformanceReviewCommentWithoutSharing(performanceReview, methodsc);
        }
        else {
            methodReviewsManager = util.getPerformanceReviewDataWithSharing(performanceReview, methodsc);
            methodReviewsEmployee = util.getPerformanceReviewEmployeeWithSharing(performanceReview, methodsc);
            methodReviewsComments = util.getPerformanceReviewCommentWithSharing(performanceReview, methodsc);
        }
          
        for(Method__c methodc: methodsc){               
            List<MethodReview__c> temp = new List<MethodReview__c>();
            Method method = new Method(methodc,  performanceReview);    
            MethodReview__c review = methodReviewsManager.get(methodc.Id);
            MethodReview__c reviewEmployee = methodReviewsEmployee.get(methodc.Id);
        
            if (review != null) {
                method.setReview(review);
            }
            
            if (reviewEmployee != null) {
                method.setReview(reviewEmployee);
            }
            
            if (methodReviewsComments.size() > 0) {
                temp = getMr(methodReviewsComments,methodc);
            }
            
            methods.add(method);
        }

        if (isPCOMMLikeViewProfile) {
            // retrieve data without sharing       
            methodReviewsManager = getPerformanceReviewDataWithoutSharing(performanceReview, methodsc_withoutvalue);
            methodReviewsEmployee = getPerformanceReviewEmployeeWithoutSharing(performanceReview, methodsc_withoutvalue);
            methodReviewsComments = getPerformanceReviewCommentWithoutSharing(performanceReview, methodsc_withoutvalue);
        }
        else {
            methodReviewsManager = util.getPerformanceReviewDataWithSharing(performanceReview, methodsc_withoutvalue);
            methodReviewsEmployee = util.getPerformanceReviewEmployeeWithSharing(performanceReview, methodsc_withoutvalue);
            methodReviewsComments = util.getPerformanceReviewCommentWithSharing(performanceReview, methodsc_withoutvalue);
        }
          
        for(Method__c methodc: methodsc_withoutvalue){               
            List<MethodReview__c> temp = new List<MethodReview__c>();
            Method method = new Method(methodc,  performanceReview);    
            MethodReview__c review = methodReviewsManager.get(methodc.Id);
            MethodReview__c reviewEmployee = methodReviewsEmployee.get(methodc.Id);
    
            if (review != null) {
                method.setReview(review);
            }
            
            if (reviewEmployee != null) {
                method.setReview(reviewEmployee);
            }
            
            if (methodReviewsComments.size() > 0) {
                temp = getMr(methodReviewsComments,methodc);
            }
                
            methods.add(method);
        }
            
        return methods;
    }
    
    // Return Method Review of one list of method review for the method
    public List<MethodReview__c> getMr(List<MethodReview__c> mrs, Method__c m){   
        List<MethodReview__c> tempMe = new List<MethodReview__c>();
        
        for(MethodReview__c mr: mrs) {
            if (mr.Method__c == m.Id) {
                tempMe.add(mr);
            }
        }
          
        return tempMe;
    }
    
    // gets the method review data without sharing
    public Map<Id, MethodReview__c> getPerformanceReviewDataWithoutSharing(PerformanceReview__c p, List<Method__c> m){
        Map<Id, MethodReview__c> tempmap = new Map<Id, MethodReview__c>();
        
        for(MethodReview__c mr: [Select r.Name, 
                                        r.Method__c, 
                                        r.CreatedDate, 
                                        r.CreatedBy.Name, 
                                        r.Reviewer__c, 
                                        r.Weight__c, 
                                        r.Rating__c 
                                 From MethodReview__c r 
                                 Where PerformanceReview__c =: p.Id 
                                 AND r.Reviewer__c =: p.Manager__c
                                 and Method__c IN : m]) {
                
                  tempmap.put(mr.Method__c, mr);
        }
       
        return tempmap;
    }
    
    // gets the method review data from the employee without sharing
    public Map<Id, MethodReview__c> getPerformanceReviewEmployeeWithoutSharing(PerformanceReview__c p, List<Method__c> m){
        Map<Id, MethodReview__c> tempmap = new Map<Id, MethodReview__c>();
            
         for(MethodReview__c mr: [Select r.Name, 
                                         r.Method__c, 
                                         r.CreatedDate, 
                                         r.CreatedBy.Name, 
                                         r.Reviewer__c, 
                                         r.Status__c
                                 From MethodReview__c r 
                                 Where PerformanceReview__c =: p.Id 
                                 AND r.Reviewer__c =: p.Employee__c
                                 and Method__c IN : m]) {
                
                  tempmap.put(mr.Method__c, mr);
       }
           
       return tempmap;
   }           

    // gets the method comments without sharing
    public List<MethodReview__c> getPerformanceReviewCommentWithoutSharing(PerformanceReview__c p, List<Method__c> m){
        List<MethodReview__c> tempmap = new List<MethodReview__c>();

        if (isPCOMMLikeViewProfile){
            if (!accessUtil.getStatusRO3()){
                if (!performanceReview.Status__c.equals('Manager Assessment')){
                    if (!performanceReview.Status__c.equals('2nd Level Manager Assessment')){
                        // any status except created, empl self assmnt, mngr assmnt 
                        // or 2nd level mngr assmnt retrieve all
                         for(MethodReview__c mr: [Select r.Comment__c, 
                                                         r.CreatedById, 
                                                         r.CreatedBy.Name, 
                                                         r.CreatedDate, 
                                                         r.Method__c
                                                 From MethodReview__c r 
                                                 Where PerformanceReview__c =: p.Id 
                                                 and Method__c IN : m]) {
                                
                                  tempmap.add(mr);
                       }
                    }
                    else{
                        // status 2nd level mngr assmnt retrieve all except the 2nd Manager comments
                         for(MethodReview__c mr: [Select r.Comment__c, 
                                                         r.CreatedById, 
                                                         r.CreatedBy.Name, 
                                                         r.CreatedDate, 
                                                         r.Method__c
                                                 From MethodReview__c r 
                                                 Where PerformanceReview__c =: p.Id 
                                                and (Reviewer__c =: p.Employee__c 
                                                or Reviewer__c =: p.Manager__c 
                                                or Reviewer__c =: p.ThirdPartyReviewer__c)
                                                 and Method__c IN : m]) {
                                
                                  tempmap.add(mr);
                       }
                    }
                }
                else{
                    // status mngr assmnt retrieve all except the Manager and 2nd Manager comments
                         for(MethodReview__c mr: [Select r.Comment__c, 
                                                         r.CreatedById, 
                                                         r.CreatedBy.Name, 
                                                         r.CreatedDate, 
                                                         r.Method__c
                                                 From MethodReview__c r 
                                                 Where PerformanceReview__c =: p.Id 
                                                and (Reviewer__c =: p.Employee__c 
                                                or Reviewer__c =: p.ThirdPartyReviewer__c)
                                                 and Method__c IN : m]) {
                                
                                  tempmap.add(mr);
                       }
                }
            }
        }
        return tempmap;
    }  

    // Return true if the logged user is the manager of performance review no matter the status
    public boolean getIsMngr() {
        return accessUtil.getIsMngr();
    }

    // Return true if the logged user is of System Administrator profile
    public boolean getIsSysAdminProfile(){
        return accessUtil.getIsSysAdminProfile();
    }
    
    // Employee or Manager in Assessment - Write permission
    public boolean getIsEmplOrMngrInAssmnt() {
        
        return ((accessUtil.getIsEmplInAssmnt() || accessUtil.getIsMngrInAssmnt()) && !(accessUtil.getIsSysAdminProfile()));
    }

    // Return comment of login user
    public AdditionalCommentDate getCurrentComment() {    
         if(currentComment != null) return currentComment;
     
         List<AdditionalComment__c> comments = [Select  id,
                                                        Comment__c,
                                                        Reviewer__c,
                                                        PerformanceReview__c,
                                                        CreatedBy.Name,
                                                        CreatedDate,
                                                        UpdateMethods__c,
                                                        SuggestionMethods__c,
                                                        SuggestionsCompetencies__c,
                                                        CommentCompetencies__c, LastModifiedDate
                                                From AdditionalComment__c
                                                Where PerformanceReview__c =: performanceReview.id
                                                and Reviewer__c =: currentUserId
                                                and Locked__c = false
                                                ORDER BY CreatedDate ASC];
                                                
         if (comments.size() == 0) {
             currentComment = new AdditionalCommentDate(new AdditionalComment__c(PerformanceReview__c = performanceReview.id));
             currentComment.additionalComment.Reviewer__c = currentUserId;
         } 
         else {
             currentComment = new AdditionalCommentDate(comments[0]);
         }
    
         return currentComment;
    }
        
    public List<Competency> getCompetencies(){
        competencies = new List<Competency>();
           
        List<CompetencyGroupMember__c> competenciesGroupMember = [Select Id, Name,
                                                                        Weight__c,
                                                                        Competency__c, 
                                                                        Competency__r.Name, 
                                                                        Competency__r.Description__c 
                                                                  From CompetencyGroupMember__c
                                                                  Where CompetencyGroup__c =: performanceReview.CompetencyGroup__c];
             
        Map<Id, CompetencyReview__c> competenciesReview;
        List <CompetencyReview__c> competenciesReviewComments;  
            
        if (isPCOMMLikeViewProfile){
            // retrieve the rating of the competencies
            competenciesReview = new Map<Id, CompetencyReview__c>();
        
            for (CompetencyReview__c cr: [SELECT Rating__c,
                                                 CompetencyGroupMember__r.Competency__c,
                                                 CompetencyGroupMember__c
                                         FROM CompetencyReview__c
                                         WHERE PerformanceReview__c =: performanceReview.id
                                         AND Reviewer__c =: performanceReview.Manager__c
                                         AND CompetencyGroupMember__c IN: competenciesGroupMember]) {
        
                competenciesReview.put(cr.CompetencyGroupMember__r.Competency__c, cr);
            }

            competenciesReviewComments = new List<CompetencyReview__c>();
                            
            if (!accessUtil.getStatusRO3()){
                if (!performanceReview.Status__c.equals('Manager Assessment')){
                    if (!performanceReview.Status__c.equals('2nd Level Manager Assessment')){
                        // any status except created, empl self assmnt, mngr assmnt 
                        // or 2nd level mngr assmnt retrieve all
                        for(CompetencyReview__c cr: [SELECT Rating__c, 
                                                           Comment__c,
                                                           CompetencyGroupMember__r.Competency__c,
                                                           CreatedBy.Name,
                                                           CreatedDate,
                                                           CompetencyGroupMember__c
                                                    FROM CompetencyReview__c
                                                    WHERE PerformanceReview__c =: performanceReview.id                                      
                                                    AND CompetencyGroupMember__c IN: competenciesGroupMember]) {
                                    competenciesReviewComments.add(cr);
                        }              
                    }
                    else{
                        // status 2nd level mngr assmnt retrieve all except the 2nd Manager comments
                        for(CompetencyReview__c cr: [SELECT Rating__c, 
                                                           Comment__c,
                                                           CompetencyGroupMember__r.Competency__c,
                                                           CreatedBy.Name,
                                                           CreatedDate,
                                                           CompetencyGroupMember__c
                                                    FROM CompetencyReview__c
                                                    WHERE PerformanceReview__c =: performanceReview.id                                      
                                                    and (Reviewer__c =: performanceReview.Employee__c 
                                                    or Reviewer__c =: performanceReview.Manager__c 
                                                    or Reviewer__c =: performanceReview.ThirdPartyReviewer__c)
                                                    AND CompetencyGroupMember__c IN: competenciesGroupMember]) {
                                    competenciesReviewComments.add(cr);
                          }              
                    }
                }
                else{
                    // status mngr assmnt retrieve all except the Manager and 2nd Manager comments
                    for(CompetencyReview__c cr: [SELECT Rating__c, 
                                                       Comment__c,
                                                       CompetencyGroupMember__r.Competency__c,
                                                       CreatedBy.Name,
                                                       CreatedDate,
                                                       CompetencyGroupMember__c
                                                FROM CompetencyReview__c
                                                WHERE PerformanceReview__c =: performanceReview.id                                      
                                                and (Reviewer__c =: performanceReview.Employee__c 
                                                or Reviewer__c =: performanceReview.ThirdPartyReviewer__c)
                                                AND CompetencyGroupMember__c IN: competenciesGroupMember]) {
                                    competenciesReviewComments.add(cr);
                    }              
                }
            }              
        }
        else {
            competenciesReview = util.getCompetencyReviewWithSharingMap(performanceReview, competenciesGroupMember);
            competenciesReviewComments =  util.getCompetencyReviewListWithSharing(performanceReview, competenciesGroupMember);
        }
                        
        for(CompetencyGroupMember__c competencyGroup: competenciesGroupMember) {                
            List<CompetencyReview__c> tempList = new List<CompetencyReview__c>();
                 
            Competency competency = new Competency(competencyGroup);
            CompetencyReview__c review = competenciesReview.get(competencyGroup.Competency__c);
                
            for(CompetencyReview__c cr: competenciesReviewComments) {
                if (cr.CompetencyGroupMember__c == competencyGroup.Id) {
                    tempList.add(cr);   
                }
            }
                 
            competencies.add(competency);                
        }
            
        return competencies;                 
    }
    
    // return the summary comments without sharing
    public List<AdditionalCommentDate> getCommentsHistory() {
        List<AdditionalComment__c> originalList = new List<AdditionalComment__c>();
        List<AdditionalCommentDate> resultList = new List<AdditionalCommentDate>();
        
        if (isPCOMMLikeViewProfile){
            if (!accessUtil.getStatusRO3()){
                if (!performanceReview.Status__c.equals('Manager Assessment')){
                        // status Employee Approval retrieve all comments (Employee and manager)
                        originalList = [Select  id,
                                        Comment__c,
                                        Reviewer__c,
                                        PerformanceReview__c,
                                        CreatedBy.Name,
                                        CreatedDate,
                                        Locked__c,
                                        UpdateMethods__c,
                                        SuggestionMethods__c,
                                        CommentCompetencies__c,
                                        SuggestionsCompetencies__c, LastModifiedDate
                                From AdditionalComment__c
                                Where PerformanceReview__c =: performanceReview.id
                                and Locked__c = true
                                and (Reviewer__c =: performanceReview.Employee__c 
                                or Reviewer__c =: performanceReview.Manager__c)
                                ORDER BY CreatedDate ASC];
                }
                else{
                    // status mngr assmnt retrieve all except the Manager comments
                    originalList = [Select  id,
                                    Comment__c,
                                    Reviewer__c,
                                    PerformanceReview__c,
                                    CreatedBy.Name,
                                    CreatedDate,
                                    Locked__c,
                                    UpdateMethods__c,
                                    SuggestionMethods__c,
                                    CommentCompetencies__c,
                                    SuggestionsCompetencies__c, LastModifiedDate
                            From AdditionalComment__c
                            Where PerformanceReview__c =: performanceReview.id
                            and Locked__c = true
                            and Reviewer__c =: performanceReview.Employee__c
                            ORDER BY CreatedDate ASC];
                }
            }
            else 
                originalList = new List<AdditionalComment__c>();
        }else{
            originalList = util.getCommentsHistoryWithSharing(performanceReview);
        }
        
        for(AdditionalComment__c c : originalList){
            if (c.Locked__c == true) {
                resultList.add(new AdditionalCommentDate(c));
            }
        }
        
        return resultList;
    }

    
    public class AdditionalCommentDate{
        String modifiedDate = '';
        AdditionalComment__c additionalComment;
        
        public AdditionalCommentDate(AdditionalComment__c c){
            if ((c != null) && (c.LastModifiedDate != null))
                modifiedDate = c.LastModifiedDate.format();
            additionalComment = c;
        }
        
        public AdditionalComment__c getAdditionalComment(){
            return additionalComment;
        }
        
        public void setAdditionalComment(AdditionalComment__c c){
            additionalComment = c;
        }
        
        public String getModifiedDate(){
            return modifiedDate;
        }
        
        public void setCreatedDate(String s){
        }
        
    }

    public AdditionalCommentDate getEmployeeCommentsHistory() {
        return commentsEmployee;
    }

    public AdditionalCommentDate getManagerCommentsHistory() {
        return commentsManager;
    }
    
    // return the additional comments without sharing for employee
    public AdditionalCommentDate getEmployeeComments() {
        if(performanceReview.Manager__c == userInfo.getUserId() && getIsShort())
        {
        	List<AdditionalComment__c> acs = [Select id,
                                                    Comment__c,
                                                    Reviewer__c,
                                                    PerformanceReview__c,
                                                    CreatedBy.Name,
                                                    CreatedDate,
                                                    UpdateMethods__c,
                                                    SuggestionMethods__c,
                                                    CommentCompetencies__c,
                                                    SuggestionsCompetencies__c , LastModifiedDate
                                            From AdditionalComment__c
                                            Where PerformanceReview__c =: performanceReview.id
                                             and Reviewer__c = :performanceReview.Employee__c
                                            ORDER BY CreatedDate ASC];
            if (acs.size() > 0)
                return new AdditionalCommentDate(acs[0]);
            else
                return new AdditionalCommentDate(new AdditionalComment__c());
        }
        else if (!accessUtil.getStatusRO3() 
        && getIsShort()){
            List<AdditionalComment__c> acs = [Select  id,
                                                    Comment__c,
                                                    Reviewer__c,
                                                    PerformanceReview__c,
                                                    CreatedBy.Name,
                                                    CreatedDate,
                                                    UpdateMethods__c,
                                                    SuggestionMethods__c,
                                                    CommentCompetencies__c,
                                                    SuggestionsCompetencies__c , LastModifiedDate
                                            From AdditionalComment__c
                                            Where PerformanceReview__c =: performanceReview.id
                                                and Locked__c = true
                                                and Reviewer__c = :performanceReview.Employee__c
                                            ORDER BY CreatedDate ASC];
            if (acs.size() > 0)
                return new AdditionalCommentDate(acs[0]);
            else
                return new AdditionalCommentDate(new AdditionalComment__c());
        }
        else 
            return new AdditionalCommentDate(new AdditionalComment__c());
    }
    
    // return the additional comments without sharing for employee
    public AdditionalCommentDate getManagerComments() {
        if(performanceReview.Manager__c == userInfo.getUserId() && getIsShort())
        {
        	List<AdditionalComment__c> acs = [Select id,
                                                    Comment__c,
                                                    Reviewer__c,
                                                    PerformanceReview__c,
                                                    CreatedBy.Name,
                                                    CreatedDate,
                                                    UpdateMethods__c,
                                                    SuggestionMethods__c,
                                                    CommentCompetencies__c,
                                                    SuggestionsCompetencies__c , LastModifiedDate
                                            From AdditionalComment__c
                                            Where PerformanceReview__c =: performanceReview.id
                                             and Reviewer__c = :performanceReview.Manager__c
                                            ORDER BY CreatedDate ASC];
            if (acs.size() > 0)
                return new AdditionalCommentDate(acs[0]);
            else
                return new AdditionalCommentDate(new AdditionalComment__c());
        }
        else if (!accessUtil.getStatusRO3() && !performanceReview.Status__c.equals('Manager Assessment') 
        && getIsShort()){
            List<AdditionalComment__c> acs = [Select id,
                                                    Comment__c,
                                                    Reviewer__c,
                                                    PerformanceReview__c,
                                                    CreatedBy.Name,
                                                    CreatedDate,
                                                    UpdateMethods__c,
                                                    SuggestionMethods__c,
                                                    CommentCompetencies__c,
                                                    SuggestionsCompetencies__c , LastModifiedDate
                                            From AdditionalComment__c
                                            Where PerformanceReview__c =: performanceReview.id
                                                and Locked__c = true
                                                and Reviewer__c = :performanceReview.Manager__c
                                            ORDER BY CreatedDate ASC];
            if (acs.size() > 0)
                return new AdditionalCommentDate(acs[0]);
            else
                return new AdditionalCommentDate(new AdditionalComment__c());
        }
        else 
            return new AdditionalCommentDate(new AdditionalComment__c());
    }

/* BEGIN Functions for Print View */
    
    // return the additional comments without sharing for employee in print view
    public AdditionalCommentDate getEmployeeCommentsPrint() {
        if (accessUtil.getIsEmplInAssmnt())
            return getCurrentComment();
        return commentsEmployee;
    }
    
    // return the additional comments without sharing for employee in print view
    public AdditionalCommentDate getManagerCommentsPrint() {
        if (accessUtil.getIsMngrInAssmnt())
            return getCurrentComment();
        return commentsManager;
    }
    
    public boolean getShowEmployeeMessageMethodsPrint (){
        boolean show = false;
        AdditionalComment__c ac = getEmployeeCommentsPrint().additionalComment;
        if (ac == null) return show;
            if ((ac.Reviewer__c == performanceReview.Employee__c) && 
            (!commentNullOrEmpty(ac.UpdateMethods__c) || !commentNullOrEmpty(ac.SuggestionMethods__c)))
                show = true;

        return show;   
    } 

    public boolean getShowManagerMessageMethodsPrint (){
        boolean show = false;
        AdditionalComment__c ac = getManagerCommentsPrint().additionalComment;
        if (ac == null) return show;
            if ((ac.Reviewer__c == performanceReview.Manager__c) && 
            (!commentNullOrEmpty(ac.UpdateMethods__c) || !commentNullOrEmpty(ac.SuggestionMethods__c)))
                show = true;

        return show;   
    } 

    public boolean getShowEmployeeMessageCompetenciesPrint (){
        boolean show = false;
        AdditionalComment__c ac = getEmployeeCommentsPrint().additionalComment;
        if (ac == null) return show;
            if ((ac.Reviewer__c == performanceReview.Employee__c) && 
            (!commentNullOrEmpty(ac.CommentCompetencies__c) || !commentNullOrEmpty(ac.SuggestionsCompetencies__c)))
                show = true;

        return show;   
    } 

    public boolean getShowManagerMessageCompetenciesPrint (){
        boolean show = false;
        AdditionalComment__c ac = getManagerCommentsPrint().additionalComment;
        if (ac == null) return show;
            if ((ac.Reviewer__c == performanceReview.Manager__c) && 
            (!commentNullOrEmpty(ac.CommentCompetencies__c) || !commentNullOrEmpty(ac.SuggestionsCompetencies__c)))
                show = true;

        return show;   
    } 

    public boolean getShowMessageAdditionalPrint (){
        boolean show = false;
        AdditionalComment__c ac= getEmployeeCommentsPrint().additionalComment;
            if ((ac != null) && !commentNullOrEmpty(ac.Comment__c)){
                show = true;
            }

        ac = getManagerCommentsPrint().additionalComment;
            if ((ac != null) && !commentNullOrEmpty(ac.Comment__c)){
                show = true;
            }

        return show;   
    } 

    // return the summary comments for the print view
    public List<AdditionalCommentDate> getCommentsHistoryPrint() {
        List<AdditionalCommentDate> listAdditionalComments = new List<AdditionalCommentDate>();
        
        AdditionalCommentDate comment = getEmployeeCommentsPrint();
        
        if (comment != null){
            listAdditionalComments.add(comment);
        }
        
        comment = getManagerCommentsPrint();
        
        if (comment != null){
            listAdditionalComments.add(comment);
        }
        
        return listAdditionalComments;
    }

/* END Functions for Print View */  
    
    public boolean getShowEmployeeMessageMethods (){
        boolean show = false;
        if (commentsEmployee == null) return show;
        AdditionalComment__c ac = commentsEmployee.additionalComment;
        if (ac == null) return show;
            if ((ac.Reviewer__c == performanceReview.Employee__c) && 
            (!commentNullOrEmpty(ac.UpdateMethods__c) || !commentNullOrEmpty(ac.SuggestionMethods__c)))
                show = true;

        return show;   
    } 

    public boolean getShowManagerMessageMethods (){
        boolean show = false;
        if (commentsManager == null) return show;
        AdditionalComment__c ac = commentsManager.additionalComment;
        if (ac == null) return show;
            if ((ac.Reviewer__c == performanceReview.Manager__c) && 
            (!commentNullOrEmpty(ac.UpdateMethods__c) || !commentNullOrEmpty(ac.SuggestionMethods__c)))
                show = true;

        return show;   
    } 

    public boolean getShowEmployeeMessageCompetencies (){
        boolean show = false;
        if (commentsEmployee == null) return show;
        AdditionalComment__c ac = commentsEmployee.additionalComment;
        if (ac == null) return show;
            if ((ac.Reviewer__c == performanceReview.Employee__c) && 
            (!commentNullOrEmpty(ac.CommentCompetencies__c) || !commentNullOrEmpty(ac.SuggestionsCompetencies__c)))
                show = true;

        return show;   
    } 

    public boolean getShowManagerMessageCompetencies (){
        boolean show = false;
        if (commentsManager == null) return show;
        AdditionalComment__c ac = commentsManager.additionalComment;
        if (ac == null) return show;
            if ((ac.Reviewer__c == performanceReview.Manager__c) && 
            (!commentNullOrEmpty(ac.CommentCompetencies__c) || !commentNullOrEmpty(ac.SuggestionsCompetencies__c)))
                show = true;

        return show;   
    } 

    public boolean getShowMessageAdditional (){
        boolean show = false;
        if (commentsEmployee == null) return show;
        AdditionalComment__c ac = commentsEmployee.additionalComment;
            if ((ac != null) && !commentNullOrEmpty(ac.Comment__c)){
                show = true;
            }
        
        if ((commentsManager == null)) return show;
        
        ac = commentsManager.additionalComment;
            if ((ac != null) && !commentNullOrEmpty(ac.Comment__c)){
                show = true;
            }

        return show;   
    } 
    
    // -----------------------------------------------------
    // Control code for submitting and approving a review
    // -----------------------------------------------------
    // This procedure change the value of Status to the next status
     // when performance review is approved comment
    
    private boolean commentNullOrEmpty(String c){
        return ((c == null) || (c == ''));
    }
    public boolean getRejectFlag() {
        return reject;
    }
    
    public Boolean getShowError() {    
         return showError;
    }
    
    public String getMsgError() {    
         return  msgError;
    }
    
    //checks wether the rating field should be shown
    public boolean getRenderRating(){
    	boolean render=false;
    	set<string> possibleStatus=new set<string>();
    	possibleStatus.add('Manager Assessment');
    	possibleStatus.add('Employee Approval');
    	possibleStatus.add('Manager Approval');
    	possibleStatus.add('Complete');
    	if(possibleStatus.contains(performanceReview.status__c)){
    		render=true;
    	}
    	if(performanceReview.Employee__c==userInfo.getUserId()){
    		render=false;
    	}
    	return render;
    }
   
    private void checkComment() {
        // Check comment in summary comment
        if (currentComment.additionalComment.Comment__c.length() > 32000 || 
        		currentComment.additionalComment.SuggestionsCompetencies__c.length() > 32000 || 
        		currentComment.additionalComment.CommentCompetencies__c.length() > 32000 || 
        		currentComment.additionalComment.SuggestionMethods__c.length() > 32000 || 
        		currentComment.additionalComment.UpdateMethods__c.length() > 32000 ) {
             
             msgError = Label.PerformanceOverallController_Exception1;
             showError = true;
        }               
        
    }
    
    // Return true if show submit button
    public boolean getShowSubmit(){
        return (currentUserId.equals(performanceReview.Employee__c)
                && performanceReview.Status__c.equals('Employee Self Assessment'));
    }
    
     // Function to show the Change to incomplete button; only Sys admin can see it
    public boolean getShowIncomplete()
    {
    	return !accessUtil.getIsIncompleteStatus() && accessUtil.getIsOnlySysAdminProfile();
    }
    

    /*
    * Inner Class Method
    * Method__c, MethodReview__c, history of MethodReview__c, Obstacle__c, Measure__c, PerformanceReview__c
    * to hold data of the methods
    */
    public class Method {
        Method__c method;
        MethodReview__c review;
        List<Obstacle__c> obstacles;
        List<Measure__c> metrics;
        PerformanceReview__c performance;

        public Method(Method__c m, PerformanceReview__c p){
            method = m;
            performance = p;
            obstacles = m.Obstacles__r;
            metrics = m.Measures__r;
        }

        public Method__c getMethod(){
            return method;
        }

        public void setMethod(Method__c m){
                method = m;
        }

        public MethodReview__c getReview() {
            return review;
        }

        public void setReview(MethodReview__c m) {
            review = m;
        }

        public List<Obstacle__c> getObstacles(){
            return obstacles;
        }

        public void setObstacles(List<Obstacle__c> o){
            obstacles = o;
        }

        public List<Measure__c> getMetrics(){
            return metrics;
        }

        public void setMetrics(List<Measure__c> m){
            metrics = m;
        }
                
        public boolean getShowValue(){
            return (method.Value__c != NULL);   
        }
   }
   
   /*
    * Inner class Competency
    * to hold data of competencies with ratings
    */
    public class Competency{
        CompetencyGroupMember__c competency;

        public Competency(CompetencyGroupMember__c c){
            competency = c;
        }

        public CompetencyGroupMember__c getCompetency(){
            return competency;
        }

        public void setCompetency(CompetencyGroupMember__c c){
            competency = c;
        }
    }
    
    //////////////////////////////// Performance Intro SHORT ////////////////////////////////
    
}