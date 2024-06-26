/*
 * RelEng Perforce/RCS Header - Do not remove!
 * $Author:  $
 * $Change:  $
 * $DateTime:  $
 * $File:  $
 * $Id:  $
 * $Revision:   $
/*
 * this class will take an account and assign it to a user.
 * @author
*/
public with sharing class PerformanceReviewPrint{

        public PerformanceReview__c      performanceReview;
        list<PerformanceCompetencyController> competencies;
        list<PerformanceMethodController> methods;
        PerformanceReviewPeriod__c	performanceReviewPeriod;        
        PerformanceSOQLController util = new PerformanceSOQLController();
        //CompetencyUtil utilCompetency = new CompetencyUtil();
        //MethodUtil utilMethod = new MethodUtil();
    	public PerformanceAccessUtil accessUtil; 
    	ScorecardSupport scorecardSupport = new ScorecardSupport();
    	List<ScorecardSupportReview__c> listScorecard;
    	String userInf = UserInfo.getUserId();
    	User currentUser; 
    	User scorecardTypeProfile; 
    	List<User> EmplMngr2ndMngr3PtPCOMMUsers;
    	public list<ScorecardSupportComment__c> scorecardComments = new list<ScorecardSupportComment__c>();
    	public boolean isPCOMMLikeViewProfile = false;
    	public Id performanceRevId = System.currentPageReference().getParameters().get('id');
	    public boolean hasCommentCS = false;
	    public boolean hasCommentRenewals = false;
	    public boolean hasCommentSI = false;    
	    public boolean hasCommentWMCases = false;
	    public boolean hasCommentWMSMES = false;
	    public boolean hasCommentWMHC = false;
	    public boolean hasCommentWMPA = false;
		public boolean hasCommentSalesImpact = false;
		public boolean hasCommentTimeOnPlatform = false;
		public boolean hasCommentForecastAccuracy = false;
		public boolean hasCommentRenewalExcellence = false;
		public boolean hasCommentOperationalExcellence = false;
		public boolean hasCommentStrategicInitiatives = false;
		public boolean hasCommentCSMSalesImpact = false;
		public boolean hasCommentWMCCP = false;
		public boolean hasCommentWMCAA = false;		
		boolean isScorecardProfile=false;
        double avgMethods;
        double avgCompetencies;
    	String v2momType = '';
        /*
        * Constructor
        */
        public PerformanceReviewPrint(){
    		// checks the id of the performance is not null
        	if(performanceRevId != null) {
				//call constructor
				constructor();  
		    }else{
		      listScorecard = new List<ScorecardSupportReview__c>();
		    }		        
		        isScorecardProfile = isScorecardProfile && (listScorecard.size() > 0);
		        if(performanceReview !=null && performanceReview.Manager__c != null && performanceReview.SecondManager__c != null && performanceReview.PCOMM__c != null){
		        	EmplMngr2ndMngr3PtPCOMMUsers = [Select Id, Name, lastName,	firstName, Title, Cost_Center__c From User Where id=:performanceReview.Employee__c or
						                        id=:performanceReview.Manager__c or id=:performanceReview.SecondManager__c or id=:performanceReview.PCOMM__c];
	            if ((v2momType != '') || (v2momType == null)){
			        List<V2MOM__c> v2momaux = [Select v.V2MOM_Type__c From V2MOM__c v Where v.id=:performanceReview.V2MOM__c];			        
			        if (v2momaux.size() > 0)
			        	v2momType = v2momaux.get(0).V2MOM_Type__c;
	            	}	
		        }		        
	               
	            if(scorecardSupport != null){ 
		        	scorecardSupport.setPerformanceAccessUtil(accessUtil);
		        	scorecardSupport.csmController.setPerformanceAccessUtil(accessUtil);
		        	scorecardSupport.educationController.setPerformanceAccessUtil(accessUtil);
		        	scorecardSupport.supportController.setPerformanceAccessUtil(accessUtil);
		        } 
		        
        	     
        }
        
        public void constructor(){
        		// checks the profile of the user
        		currentUser = [Select u.Profile.Name, u.ProfileId From User u where id = :userInf];   				
				util.setCurrentUser(currentUser);
				util.setCurrentUser(currentUser);			
				// gets the performance review completely
		        performanceReview = getPerformanceReviewWithoutSharing(performanceRevId);
                List<PerformanceReviewPeriod__c> performanceReviewPeriodList;
				performanceReviewPeriodList = [Select OwnerId, StartDate__c, EndDate__c
                    From PerformanceReviewPeriod__c
                    Where id=:performanceReview.PerformanceReviewPeriod__c];
                
                if (performanceReviewPeriodList.size() > 0)
                	performanceReviewPeriod = performanceReviewPeriodList.get(0);                   
				if ((performanceReview.V2MOM__r != null) && (performanceReview.V2MOM__r.V2MOM_Type__c != null))
					v2momType = performanceReview.V2MOM__r.V2MOM_Type__c;
				// gets the profile of the employee to see what kind of scorecard it might have
        		scorecardTypeProfile = [Select u.Profile.Name, u.ProfileId From User u where id = :performanceReview.Employee__c];      		
	    		// access class for permissions
	            accessUtil = new PerformanceAccessUtil(performanceReview, currentUser, scorecardTypeProfile);		
				// uses the information of the performance review to check if the profile of the
				// current user should see data filtered by sharing rules or filtered manually
				isPCOMMLikeViewProfile = accessUtil.getPCOMMLikeViewProfile();	
				if (!isPCOMMLikeViewProfile)
		        	performanceReview = util.getPerformanceReviewWithSharing(performanceRevId);	                                
	        	isScorecardProfile = accessUtil.getIsScorecardProfile();	        
		        if (isScorecardProfile){
			        // if it is a profile filtered by the sharing rules retrieve the values
			    	if ((isPCOMMLikeViewProfile) || ((accessUtil.getIsEmplMngr2ndMngrOrPCOMM() && !accessUtil.getIsMngr()))){
			        	scorecardSupport = new ScorecardSupport(performanceReview, accessUtil.getStatusRO3()
			        	 || (accessUtil.getIsEmpl() && (accessUtil.getStatusRO1() || performanceReview.Status__c.equals('Manager Assessment'))) 
			        	 || (!getIsSysAdminProfile() && performanceReview.Status__c.equals('Manager Assessment')));   
			    	}else{
			        	scorecardSupport = new ScorecardSupport(performanceReview);   
			    	}
			    	if (isPCOMMLikeViewProfile){
						scorecardComments = getScorecardCommentWithoutSharing();
			    	}else{
						scorecardComments = util.getScorecardCommentWithSharing(performanceReview);
			    	}			    	
			    	scorecardComments = orderScorecardReviewList(scorecardComments);			    	
			    	setScorecardHasComments();			    	
		            // gets data of the metrics
		             listScorecard = [Select Id, FiscalQuarter__c FROM ScorecardSupportReview__c WHERE PerformanceReview__c =: performanceReview.Id ];
		        }
        }
		public boolean getIsScorecardProfile(){
			return isScorecardProfile;
		}
		//Only use for Test case
		public void setPerformanceRev(PerformanceReview__c perf){
			this.performanceReview = perf;
		}		
		
		public boolean getIsPremierUser(){
			return performanceReview.PremierUser__c;	
		}
/*
* BEGIN FUNCTIONS WITHOUT SHARING *******
*/
		// gets the performance review without sharing
        public PerformanceReview__c getPerformanceReviewWithoutSharing(Id id) {
            PerformanceReview__c performanceReview = [Select  id,  name, Employee__c, Manager__c,  SecondManager__c, PCOMM__c, ThirdPartyReviewer__c, CompetencyGroup__c,  CompetencyGroup__r.Name,  PerformanceReviewPeriod__c,  PerformanceReviewPeriod__r.name, PerformanceReviewPeriod__r.Effective_Date__c,  ReviewFormTemplate__c,  ReviewFormTemplate__r.MethodWeight__c,  ReviewFormTemplate__r.CompetencyWeight__c,  V2MOM__c,  V2MOM__r.V2MOM_Type__c,  V2MOM__r.Vision__c,
                                                            OwnerId, Status__c, PreviousStatus__c, EmailComment__c, ReviewRating__c, PremierUser__c, ReviewRating__r.OverallRating__c
                                                            From PerformanceReview__c Where Id=:id];
    
              
            return performanceReview;
        }
		// returns the scorecard comments without sharing
        public list<ScorecardSupportComment__c> getScorecardCommentWithoutSharing(){
    		if (!accessUtil.getStatusRO3()){
	    		if (!performanceReview.Status__c.equals('Manager Assessment')){
		    		if (!performanceReview.Status__c.equals('2nd Level Manager Assessment')){
				            return [select  s.Reviewer__r.Name, s.Reviewer__c, s.CommentCS__c, s.CommentRenewals__c, s.CommentSupportInitiatives__c, s.CommentWMCases__c, s.CommentWMSMES__c, s.CommentWMPA__c, s.CommentWMHC__c,
				                    s.CommentSalesImpact__c, s.CommentForecastAccuracy__c, s.CommentTimeOnPlatform__c, s.CommentCSMSalesImpact__c, s.CommentRenewalExcellence__c, s.CommentOperationalExcellence__c, s.CommentStrategicInitiatives__c, s.CommentWMCCP__c, s.CommentWMCAA__c, s.CreatedDate  
				                    from ScorecardSupportComment__c s where  PerformanceReview__c  =: performanceReview.Id and Locked__c = true order by CreatedDate ASC];   
		    		}else{
				            return [select  s.Reviewer__r.Name, s.Reviewer__c, s.CommentCS__c, s.CommentRenewals__c, s.CommentSupportInitiatives__c, s.CommentWMCases__c, s.CommentWMSMES__c, s.CommentWMPA__c, s.CommentWMHC__c,
				                    s.CommentSalesImpact__c, s.CommentForecastAccuracy__c, s.CommentOperationalExcellence__c, s.CommentTimeOnPlatform__c, s.CommentCSMSalesImpact__c, s.CommentRenewalExcellence__c, s.CommentStrategicInitiatives__c, s.CommentWMCCP__c, s.CommentWMCAA__c, s.CreatedDate 
				                    from ScorecardSupportComment__c s where  PerformanceReview__c  =: performanceReview.Id and (Reviewer__c <>: performanceReview.SecondManager__c)
				                    and Locked__c = true order by CreatedDate ASC];   
		    		}  
	    		}else{
			            return [select  s.Reviewer__r.Name, s.Reviewer__c, s.CommentCS__c, s.CommentRenewals__c,s.CommentSupportInitiatives__c,s.CommentWMCases__c, s.CommentWMSMES__c, s.CommentWMPA__c,s.CommentWMHC__c,
			                    s.CommentSalesImpact__c,s.CommentForecastAccuracy__c, s.CommentTimeOnPlatform__c, s.CommentOperationalExcellence__c, s.CommentStrategicInitiatives__c, s.CommentCSMSalesImpact__c, s.CommentRenewalExcellence__c, s.CommentWMCCP__c, s.CommentWMCAA__c, s.CreatedDate 
			                    from ScorecardSupportComment__c s where  PerformanceReview__c  =: performanceReview.Id and (Reviewer__c <>: performanceReview.Manager__c 
			                    and Reviewer__c <>: performanceReview.SecondManager__c) and Locked__c = true order by CreatedDate ASC];   
	    		} 
    		}	   	
	    	return new list<ScorecardSupportComment__c>();    
        }     
        public List<ScorecardSupportComment__c> orderScorecardReviewList(List<ScorecardSupportComment__c> originalList) {       	
	        List<ScorecardSupportComment__c> scorecardReviewComments = new List<ScorecardSupportComment__c>();	        
	        for(ScorecardSupportComment__c src : originalList){
	        	if (src.Reviewer__c == performanceReview.Employee__c)
	        		scorecardReviewComments.add(src);
	        }	        
	        for(ScorecardSupportComment__c src : originalList){
	        	if (src.Reviewer__c == performanceReview.Manager__c)
	        		scorecardReviewComments.add(src);
	        }	        
	        for(ScorecardSupportComment__c src : originalList){
	        	if (src.Reviewer__c == performanceReview.SecondManager__c)
	        		scorecardReviewComments.add(src);
	        }        
	        for(ScorecardSupportComment__c src : originalList){
	        	if ((src.Reviewer__c != performanceReview.Employee__c)
	        	&& (src.Reviewer__c != performanceReview.Manager__c)
	        	&& (src.Reviewer__c != performanceReview.SecondManager__c)
	        	&& (performanceReview.Status__c != 'Employee Self Assessment'))
	        		scorecardReviewComments.add(src);
	        }        
	        return scorecardReviewComments;
        }
        
        public boolean getIsOldPerformanceReview(){ 
			if(performanceReview.PerformanceReviewPeriod__r.Effective_Date__c == 'FY08' || performanceReview.PerformanceReviewPeriod__r.Effective_Date__c == 'FY09'){
				return true;
			}
			
			return false;
		}
		// gets the method review data from the employee without sharing
      public Map<Id, MethodReview__c> getPerformanceReviewEmployeeWithoutSharing(PerformanceReview__c p, List<Method__c> m){
            Map<Id, MethodReview__c> tempmap = new Map<Id, MethodReview__c>();           
             for(MethodReview__c mr: [Select r.Name, r.Method__c, r.CreatedDate, r.CreatedBy.Name, r.LastModifiedDate, r.Reviewer__c, r.Reviewer__r.Name, r.Status__c
                                     From MethodReview__c r Where PerformanceReview__c =: p.Id AND r.Reviewer__c =: p.Employee__c and Method__c IN : m]) {                  
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
				                 for(MethodReview__c mr: [Select r.Comment__c, r.CreatedById, r.CreatedBy.Name, r.LastModifiedDate, r.CreatedDate,r.Reviewer__c, r.Reviewer__r.Name, r.Method__c, r.Status__c
				                                         From MethodReview__c r Where PerformanceReview__c =: p.Id and Method__c IN : m order by CreatedDate ASC]) {				                        
				                          tempmap.add(mr);
				               }
				    		}else{
								// status 2nd level mngr assmnt retrieve all except the 2nd Manager comments
				                 for(MethodReview__c mr: [Select r.Comment__c, r.CreatedById, r.CreatedBy.Name, r.CreatedDate, r.LastModifiedDate, r.Reviewer__c, r.Reviewer__r.Name, r.Method__c, r.Status__c
				                                         From MethodReview__c r Where PerformanceReview__c =: p.Id and (Reviewer__c <>: p.SecondManager__c) and Method__c IN : m order by CreatedDate ASC]) {			                        
				                          tempmap.add(mr);
				               }
				    		}
			    		}else{
							// status mngr assmnt retrieve all except the Manager and 2nd Manager comments
				                 for(MethodReview__c mr: [Select r.Comment__c, r.CreatedById, r.CreatedBy.Name, r.CreatedDate, r.LastModifiedDate, r.Reviewer__c, r.Reviewer__r.Name, r.Method__c, r.Status__c
				                                         From MethodReview__c r Where PerformanceReview__c =: p.Id and (Reviewer__c <>: p.Manager__c and Reviewer__c <>: p.SecondManager__c) and Method__c IN : m order by CreatedDate ASC]) {			                        
				                          tempmap.add(mr);
				               }
			    		}
		    		}
		    	}
				return tempmap;
     		}           
        public List<MethodReview__c> orderMethodReviewList(List<MethodReview__c> originalList) {      	
	        List<MethodReview__c> methodsReviewComments = new List<MethodReview__c>();
	        for(MethodReview__c mr : originalList){
	        	if (mr.Reviewer__c == performanceReview.Employee__c)
	        		methodsReviewComments.add(mr);
	        }	        
	        for(MethodReview__c mr : originalList){
	        	if (mr.Reviewer__c == performanceReview.Manager__c)
	        		methodsReviewComments.add(mr);
	        }	        
	        for(MethodReview__c mr : originalList){
	        	if (mr.Reviewer__c == performanceReview.SecondManager__c)
	        		methodsReviewComments.add(mr);
	        }	        
	        for(MethodReview__c mr : originalList){
	        	if ((mr.Reviewer__c != performanceReview.Employee__c)
	        	&& (mr.Reviewer__c != performanceReview.Manager__c)
	        	&& (mr.Reviewer__c != performanceReview.SecondManager__c)
	        	&& (performanceReview.Status__c != 'Employee Self Assessment'))
	        		methodsReviewComments.add(mr);
	        }        
	        return methodsReviewComments;
        }         
           // gets the method review data without sharing
           public Map<Id, MethodReview__c> getPerformanceReviewDataWithoutSharing(PerformanceReview__c p, List<Method__c> m){
                Map<Id, MethodReview__c> tempmap = new Map<Id, MethodReview__c>();               
                 for(MethodReview__c mr: [Select r.Name, r.Method__c, r.CreatedDate, r.CreatedBy.Name, r.LastModifiedDate, r.Reviewer__c, r.Reviewer__r.Name, r.Weight__c, r.Rating__c, r.Status__c 
                                         From MethodReview__c r Where PerformanceReview__c =: p.Id AND r.Reviewer__c =: p.Manager__c and Method__c IN : m order by CreatedDate ASC]) {                     
                          tempmap.put(mr.Method__c, mr);
               }              
               return tempmap;
           }          
    public class AdditionalCommentDate{
		String createdDate = '';
		AdditionalComment__c additionalComment;		
		public AdditionalCommentDate(AdditionalComment__c c){
			createdDate = c.LastModifiedDate.format();
			additionalComment = c;
		}		
		public AdditionalComment__c getAdditionalComment(){
			return additionalComment;
		}		
		public void setAdditionalComment(AdditionalComment__c c){
			additionalComment = c;
		}		
		public String getCreatedDateFormatted(){
			return createdDate;
		}		
		public void setCreatedDateFormatted(String s){
		}		
	}
       // return the summary comments without sharing
        public List<AdditionalCommentDate> getCommentsHistory() {
	    	List<AdditionalComment__c> originalList = new List<AdditionalComment__c>();
	    	List<AdditionalCommentDate> resultList = new List<AdditionalCommentDate>();	    	
	    	if (isPCOMMLikeViewProfile){
	    		if (!accessUtil.getStatusRO3()){
		    		if (!performanceReview.Status__c.equals('Manager Assessment')){
			    		if (!performanceReview.Status__c.equals('2nd Level Manager Assessment')){
							// any status except created, empl self assmnt, mngr assmnt 
							// or 2nd level mngr assmnt retrieve all
				    		originalList = [Select id, Comment__c,Reviewer__c,PerformanceReview__c,CreatedBy.Name,CreatedDate,LastModifiedDate
				                    		From AdditionalComment__c Where PerformanceReview__c =: performanceReview.id and Locked__c = true ORDER BY CreatedDate ASC];
			    		}else{
							// status 2nd level mngr assmnt retrieve all except the 2nd Manager comments
				    		originalList = [Select id,Comment__c,Reviewer__c,PerformanceReview__c,CreatedBy.Name,CreatedDate,LastModifiedDate
				                    		From AdditionalComment__c Where PerformanceReview__c =: performanceReview.id and Locked__c = true and (Reviewer__c <>: performanceReview.SecondManager__c) ORDER BY CreatedDate ASC];
			    		}
		    		}else{
						// status mngr assmnt retrieve all except the Manager and 2nd Manager comments
			    		originalList = [Select id,Comment__c,Reviewer__c,PerformanceReview__c,CreatedBy.Name,CreatedDate,LastModifiedDate
			                    From AdditionalComment__c Where PerformanceReview__c =: performanceReview.id
			                    and Locked__c = true and (Reviewer__c <>: performanceReview.Manager__c and Reviewer__c <>: performanceReview.SecondManager__c) ORDER BY CreatedDate ASC];
		    		}
	    		}
	    		else 
	    			originalList = new List<AdditionalComment__c>();
	    	}else{
	            originalList = util.getCommentsHistoryWithSharing(performanceReview);
	    	}	    	    	    
	    	//originalList = orderOverallReviewList(originalList);	    	        
	         for (AdditionalComment__c c : originalList) {
	         	if(((performanceReview.PreviousStatus__c == 'Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
					||((performanceReview.PreviousStatus__c == '2nd Level Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
					|| ((performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.PCOMM__c == userInfo.getUserId()))){
						if(c.Reviewer__c == performanceReview.Employee__c){
							resultList.add(new AdditionalCommentDate(c));
						}
				 }	
				 else
         		 {
         			resultList.add(new AdditionalCommentDate(c)); 	
         		 }         	
	         }	         
	         return resultList;
        } 
    public List<AdditionalComment__c> orderOverallReviewList(List<AdditionalComment__c> originalList) {  	
        List<AdditionalComment__c> overallReviewComments = new List<AdditionalComment__c>();       
        for(AdditionalComment__c ac : originalList){
        	if (ac.Reviewer__c == performanceReview.Employee__c)
        		overallReviewComments.add(ac);
        }       
        for(AdditionalComment__c ac : originalList){
        	if (ac.Reviewer__c == performanceReview.Manager__c)
        		overallReviewComments.add(ac);
        }       
        for(AdditionalComment__c ac : originalList){
        	if (ac.Reviewer__c == performanceReview.SecondManager__c)
        		overallReviewComments.add(ac);
        }       
        for(AdditionalComment__c ac : originalList){
        	if ((ac.Reviewer__c != performanceReview.Employee__c)
        	&& (ac.Reviewer__c != performanceReview.Manager__c)
        	&& (ac.Reviewer__c != performanceReview.SecondManager__c)
	        && (performanceReview.Status__c != 'Employee Self Assessment'))
        		overallReviewComments.add(ac);
        }      
        return overallReviewComments;
    }
/*
* END FUNCTIONS WITHOUT SHARING *******

* BEGIN FUNCTIONS TO GET METRIC HAS COMMENTS **************
*/
	public void setScorecardHasComments(){
		for(ScorecardSupportComment__c s:scorecardComments){
			if ((s.CommentCS__c != null) && (s.CommentCS__c != ''))
				hasCommentCS = true;
			if ((s.CommentRenewals__c != null) && (s.CommentRenewals__c != ''))
				hasCommentRenewals = true;
			if ((s.CommentSupportInitiatives__c != null) && (s.CommentSupportInitiatives__c != ''))
				hasCommentSI = true;
			if ((s.CommentWMCases__c != null) && (s.CommentWMCases__c != ''))
				hasCommentWMCases = true;
			if ((s.CommentWMSMES__c != null) && (s.CommentWMSMES__c != ''))
				hasCommentWMSMES = true;
			if ((s.CommentWMPA__c != null) && (s.CommentWMPA__c != ''))
				hasCommentWMPA = true;
			if ((s.CommentWMHC__c != null) && (s.CommentWMHC__c != ''))
				hasCommentWMHC = true;
			if ((s.CommentSalesImpact__c != null) && (s.CommentSalesImpact__c != ''))
				hasCommentSalesImpact = true;
			if ((s.CommentTimeOnPlatform__c != null) && (s.CommentTimeOnPlatform__c != ''))
				hasCommentTimeOnPlatform = true;
			if ((s.CommentForecastAccuracy__c != null) && (s.CommentForecastAccuracy__c != ''))
				hasCommentForecastAccuracy = true;
			if ((s.CommentRenewalExcellence__c != null) && (s.CommentRenewalExcellence__c != ''))
				hasCommentRenewalExcellence = true;
			if ((s.CommentOperationalExcellence__c != null) && (s.CommentOperationalExcellence__c != ''))
				hasCommentOperationalExcellence = true;	
			if ((s.CommentStrategicInitiatives__c != null) && (s.CommentStrategicInitiatives__c != ''))
				hasCommentStrategicInitiatives = true;			
			if ((s.CommentCSMSalesImpact__c != null) && (s.CommentCSMSalesImpact__c != ''))
				hasCommentCSMSalesImpact = true;
			if ((s.CommentWMCCP__c != null) && (s.CommentWMCCP__c != ''))
				hasCommentWMCCP = true;	
			if ((s.CommentWMCAA__c != null) && (s.CommentWMCAA__c != ''))
				hasCommentWMCAA = true;	
	}
}	
    public boolean getHasCommentCS(){
        return hasCommentCS;
    }
    public boolean getHasCommentRenewals(){
        return hasCommentRenewals;
    }
	public boolean getHasCommentSI(){
		return hasCommentSI;
	}	
	public boolean getHasCommentWMCases(){
        return hasCommentWMCases;
    }	
	public boolean getHasCommentWMSMES(){
        return hasCommentWMSMES;
    }	
	public boolean getHasCommentWMPA(){
        return hasCommentWMPA;
    }
	public boolean getHasCommentWMHC(){
        return hasCommentWMHC;
    }   
    public boolean getHasCommentWMCCP(){
        return hasCommentWMCCP;
    }	
	public boolean getHasCommentWMCAA(){
        return hasCommentWMCAA;
    }   
	public boolean getHasCommentForecastAccuracy(){
        return hasCommentForecastAccuracy;
    }
	public boolean getHasCommentSalesImpact(){
        return hasCommentSalesImpact;
    }
	public boolean getHasCommentTimeOnPlatform(){
        return hasCommentTimeOnPlatform;
    }   
    public boolean getHasCommentCSMSalesImpact(){
        return hasCommentCSMSalesImpact;
    }   
    public boolean getHasCommentRenewalExcellence(){
        return hasCommentRenewalExcellence;
    }
    public boolean getHasCommentOperationalExcellence(){
        return hasCommentOperationalExcellence;
    }
    public boolean getHasCommentStrategicInitiatives(){
        return hasCommentStrategicInitiatives;
    }  
/*
* END FUNCTIONS TO GET METRIC HAS COMMENTS **************
*/
		public class ScorecardSupportCommentDate{
			ScorecardSupportComment__c ScorecardSupportComment;
			String CreatedDate;			
			public ScorecardSupportCommentDate(ScorecardSupportComment__c c){
				ScorecardSupportComment = c;
				CreatedDate = c.CreatedDate.format();
			}			
			public ScorecardSupportComment__c getScorecardSupportComment(){
				return ScorecardSupportComment;
			}			
			public void setScorecardSupportComment(ScorecardSupportComment__c c){
				ScorecardSupportComment = c;
			}			
			public String getCreatedDateScorecardComment(){
				return createdDate;
			}		
			public void setCreatedDateScorecardComment(String s){
			}		
		}
		// returns the comments of the scorecards
        public list<ScorecardSupportCommentDate> getScorecardComments(){
        	List<ScorecardSupportCommentDate> resultList = new List<ScorecardSupportCommentDate>();       	
        	for (ScorecardSupportComment__c c : scorecardComments) {
        		if(performanceReview.Status__c != '3rd Party Assessment'){
        			resultList.add(new ScorecardSupportCommentDate(c));
        		}
        	}      	
			return resultList;
        }
		// returns true if the process of the performance review is completed
        public boolean getIsApproved(){
        	return (performanceReview.Status__c == 'Complete');
        }		
    	// Return the PerformanceReview
        public PerformanceReview__c getPerformanceReview(){
            return performanceReview;
        }		
    	// gets the data of the scorecards
	    public ScorecardSupport getScorecardSupport(){
	        if(scorecardSupport != null){
	            return scorecardSupport;
	        }
	        else
	            return scorecardSupport = new ScorecardSupport();   
	    } 
        // Return employee user data of performance review 
        public User getEmployee(){
        	try{
        		if (EmplMngr2ndMngr3PtPCOMMUsers != null && EmplMngr2ndMngr3PtPCOMMUsers.size() > 0){
        			for(User u: EmplMngr2ndMngr3PtPCOMMUsers){
        				if (u.id == performanceReview.Employee__c) return u;
        			}
        		
        		}else{
        			//User emp = [Select Id, Name, lastName,	firstName, Title, Department From User Where id =: performanceReview.Employee__c];
        			User emp = [Select Id, Name, lastName,	firstName, Title, Cost_Center__c From User Where id =: performanceReview.Employee__c];
        			return emp;
        		}	
        	}catch(Exception e){
        		System.debug('Exception: ' + e);
        	}
        	
        	
        	return null;
        }
        // Return manager user data of performance review 
        public User getManager(){
        	try{
        		if (EmplMngr2ndMngr3PtPCOMMUsers != null && EmplMngr2ndMngr3PtPCOMMUsers.size() > 0){
        			for(User u: EmplMngr2ndMngr3PtPCOMMUsers){
        				if (u.id == performanceReview.Manager__c)
        					return u;
        			}	
        		}else{
        			//User mgr = [Select Id, Name, lastName, firstName, Title, Department From User Where Id =: performanceReview.Manager__c];
        			User mgr = [Select Id, Name, lastName, firstName, Title, Cost_Center__c From User Where Id =: performanceReview.Manager__c];
        			return mgr;
        		}
        			
        	}catch(Exception e){
        		System.debug(e);
        	}
        	
            return null;
        }
        // Return second manager user data of performance review 
        public User getSecondManager(){
            if(performanceReview.SecondManager__c == null) return null;
        	try{
        		if(EmplMngr2ndMngr3PtPCOMMUsers != null && EmplMngr2ndMngr3PtPCOMMUsers.size() > 0){
        			for(User u: EmplMngr2ndMngr3PtPCOMMUsers){
        				if (u.id == performanceReview.SecondManager__c)
        					return u;
        			}	
        		}else{
        			//User sndManager = [Select Id, Name, lastName, firstName, Title, Department From User Where id =: performanceReview.SecondManager__c];
        			User sndManager = [Select Id, Name, lastName, firstName, Title, Cost_Center__c From User Where id =: performanceReview.SecondManager__c];
        			return sndManager;
        		}
        			
        	}catch(Exception e){
        		System.debug(e);
        	}
        	
            return null;
        }
        // Return pcomm user data of performance review 
        public User getPComm(){
        	try{
        		if(EmplMngr2ndMngr3PtPCOMMUsers != null && EmplMngr2ndMngr3PtPCOMMUsers.size() > 0){
        			for(User u: EmplMngr2ndMngr3PtPCOMMUsers){
        				if (u.id == performanceReview.PCOMM__c)
        					return u;
        			}	
        		}else{
        			//User pcomm = [Select Id, Name, lastName, firstName, Title, Department From User Where id =: performanceReview.PCOMM__c];
        			User pcomm = [Select Id, Name, lastName, firstName, Title, Cost_Center__c From User Where id =: performanceReview.PCOMM__c];
        			return pcomm;
        		}
        			
        	}catch(Exception e){
        		System.debug(e);
        	}
        	
            return (new User());
        }
        // Return Review Form Template of Performance Review 
        public ReviewFormTemplate__c getReviewFormTemplate(){
            if (performanceReview.ReviewFormTemplate__c == null)
                    return new ReviewFormTemplate__c();                  
            return [Select Introduction__c From ReviewFormTemplate__c Where id=:performanceReview.ReviewFormTemplate__c];
        }
        // Return start date of the Performance Review Period of Performance Review 
        public String getPerformanceReviewPeriodStartDate(){
        	if (performanceReviewPeriod != null)
			  return performanceReviewPeriod.StartDate__c.format(); 
			return '';
        }
        // Return end date of the Performance Review Period of Performance Review 
        public String getPerformanceReviewPeriodEndDate(){
        	if (performanceReviewPeriod != null)
			  return performanceReviewPeriod.EndDate__c.format(); 
			return '';
        }
        // Return name of owner of performance review period
        public String getNameOwner(){
            Id idOwner = performanceReviewPeriod.OwnerId;
            String ret = '';           
            if(idOwner == null){
                return ret;
            }
            else {
                User u = [Select u.Name From User u Where u.id =:idOwner];
                if(u.Name == null){
                    return ret;
                }
                else {
                    ret = u.Name;
                    return ret;
                }
            }
        }
	// return the current user profile
    public String getUserProfile(){
        return currentUser.Profile.Name;    
    }
	// returns true if it is a profile Individual Q1/Q2 or Individual Q3/Q4
    public boolean getIsQuarterV2MOM(){
        if(v2momType == 'Individual Q1/Q2' || v2momType == 'Individual Q3/Q4'){   
            return true;
        }
        return false;   
    }     
/*
* BEGIN FUNCTION FOR COMPETENCIES *********************
*/
        public List<PerformanceCompetencyController> getCompetencies(){
            competencies = new List<PerformanceCompetencyController>();
            if (performanceReview != null) {
            	List<CompetencyGroupMember__c> competenciesGroupMember = [Select Id, Name,Weight__c,Competency__c , Competency__r.Name, Competency__r.Description__c 
                                                                      From CompetencyGroupMember__c Where CompetencyGroup__c =: performanceReview.CompetencyGroup__c];      
			Map<Id, CompetencyReview__c> competenciesReview;
            List <CompetencyReview__c> competenciesReviewComments;  			
	        if (isPCOMMLikeViewProfile){
	        	// retrieve the rating of the competencies
	            competenciesReview = new Map<Id, CompetencyReview__c>();	    
	            for(CompetencyReview__c cr: [SELECT Rating__c,CompetencyGroupMember__r.Competency__c, Reviewer__c, Reviewer__r.Name,CompetencyGroupMember__c
	                                         FROM CompetencyReview__c WHERE PerformanceReview__c =: performanceReview.id
	                                         AND Reviewer__c =: performanceReview.Manager__c AND CompetencyGroupMember__c IN: competenciesGroupMember
	                                         order by CreatedDate ASC]) {   
	                competenciesReview.put(cr.CompetencyGroupMember__r.Competency__c, cr);
	            }               
               competenciesReviewComments = new List<CompetencyReview__c>();                      		
	    		if (!accessUtil.getStatusRO3()){
		    		if (!performanceReview.Status__c.equals('Manager Assessment')){
			    		if (!performanceReview.Status__c.equals('2nd Level Manager Assessment')){
							// any status except created, empl self assmnt, mngr assmnt 
							// or 2nd level mngr assmnt retrieve all
				    		for(CompetencyReview__c cr: [SELECT Rating__c, Comment__c,CompetencyGroupMember__r.Competency__c,CreatedBy.Name,CreatedDate, LastModifiedDate, Reviewer__c, Reviewer__r.Name, CompetencyGroupMember__c
						                                FROM CompetencyReview__c WHERE PerformanceReview__c =: performanceReview.id                                      
						                                AND CompetencyGroupMember__c IN: competenciesGroupMember
						                                AND ((Locked__c = true) or (Reviewer__c =: currentUser.Id))
						                                order by CreatedDate ASC]) {
	 		                         	competenciesReviewComments.add(cr);
				              }              	                                	
			    		}else{
							// status 2nd level mngr assmnt retrieve all except the 2nd Manager comments
				    		for(CompetencyReview__c cr: [SELECT Rating__c, Comment__c,CompetencyGroupMember__r.Competency__c,CreatedBy.Name,CreatedDate, LastModifiedDate, Reviewer__c, Reviewer__r.Name, CompetencyGroupMember__c
						                                FROM CompetencyReview__c WHERE PerformanceReview__c =: performanceReview.id                                      
			                                            and (Reviewer__c <>: performanceReview.SecondManager__c)
						                                AND CompetencyGroupMember__c IN: competenciesGroupMember
						                                AND ((Locked__c = true) or (Reviewer__c =: currentUser.Id))
						                                order by CreatedDate ASC]) {
	 		                         	competenciesReviewComments.add(cr);
				              }              
			    		}
		    		}else{
						// status mngr assmnt retrieve all except the Manager and 2nd Manager comments
				    		for(CompetencyReview__c cr: [SELECT Rating__c, Comment__c,CompetencyGroupMember__r.Competency__c,CreatedBy.Name,CreatedDate, LastModifiedDate, Reviewer__c, Reviewer__r.Name, CompetencyGroupMember__c
						                                FROM CompetencyReview__c WHERE PerformanceReview__c =: performanceReview.id                                      
			                                            and (Reviewer__c <>: performanceReview.Manager__c 
									                    and Reviewer__c <>: performanceReview.SecondManager__c)
						                                AND CompetencyGroupMember__c IN: competenciesGroupMember
						                                AND ((Locked__c = true) or (Reviewer__c =: currentUser.Id))
						                                order by CreatedDate ASC]) {
	 		                         	competenciesReviewComments.add(cr);
			              }              
	    			}
               }                              
	        }else{
	        	competenciesReview = util.getCompetencyReviewWithSharingMap(performanceReview, competenciesGroupMember);
	        	competenciesReviewComments =  util.getCompetencyReviewListWithSharing(performanceReview, competenciesGroupMember);
	        }            
            competenciesReviewComments = orderCompetencyReviewList(competenciesReviewComments);           
            for(CompetencyGroupMember__c competencyGroup: competenciesGroupMember) {                
                List<CompetencyReview__c> tempList = new List<CompetencyReview__c>();                
                PerformanceCompetencyController competency = new PerformanceCompetencyController(competencyGroup, performanceReview);
                CompetencyReview__c review = competenciesReview.get(competencyGroup.Competency__c);               
                competency.setWeight(competencyGroup.Weight__c);         
                if (review != null) 
                {
	                if ((accessUtil.getIs3PtInAssmnt() && performanceReview.PreviousStatus__c.equals('Manager Assessment'))
            		|| ((accessUtil.getIsEmpl() && !(performanceReview.Status__c.equals('Complete') || performanceReview.Status__c.equals('Employee Approval')))) 
		            || (accessUtil.getIsMngr2ndMngrOrPCOMM() && performanceReview.Status__c.equals('Employee Self Assessment'))
		            || ((accessUtil.getIs2ndMngr() || accessUtil.getIsPCOMM()) && performanceReview.Status__c.equals('Manager Assessment'))
	                || (isPCOMMLikeViewProfile && (accessUtil.getStatusRO3() || (!getIsSysAdminProfile() && performanceReview.Status__c.equals('Manager Assessment'))))){		               	
	                	competency.setRating(null);	               
                    }else{
		                if (accessUtil.getIsPCOMM())
                    	{                   		
                    		if (performanceReview.Status__c == '3rd Party Assessment' || performanceReview.Status__c == 'Manager Assessment' )
                    		{
                    			 competency.setRating(null);  
                    		}
                    		else
                    		{
                    			competency.setRating(review.Rating__c);
                    		}
                    	}
                    	else
                    	{
		                   competency.setRating(review.Rating__c);
                    	}                 
                    }
                    if(accessUtil.getUserProfile() == 'System Administrator'||accessUtil.getUserProfile()=='systemadministrator'){ 
						competency.setRating(review.Rating__c);
					}
                    if(accessUtil.getIsPCOMM() && accessUtil.getIsMngr()){	               
	                    if(performanceReview.Status__c != 'Employee Self Assessment'){    
	                    competency.setRating(review.Rating__c);
	                    }	
                    }                    
                    if(userInf.equals(performanceReview.ThirdPartyReviewer__c) && performanceReview.PreviousStatus__c.equals('Manager Assessment')){
                    	competency.setRating(null); 
                    }	
                }               
                for(CompetencyReview__c cr: competenciesReviewComments)
                {
                    	if (cr.CompetencyGroupMember__c == competencyGroup.Id)
                    	{
                        	tempList.add(cr);   
                    	}
                	}              
                	competency.setHistory(tempList);
                	competencies.add(competency);                
            	}	
            }         
                       
            return competencies;                 
        }
        public List<CompetencyReview__c> orderCompetencyReviewList(List<CompetencyReview__c> originalList) {       	
	        List<CompetencyReview__c> competenciesReviewComments = new List<CompetencyReview__c>();	        
	        for(CompetencyReview__c cr : originalList){
	        	if (cr.Reviewer__c == performanceReview.Employee__c)
	        		competenciesReviewComments.add(cr);
	        }	        
	        for(CompetencyReview__c cr : originalList){
	        	if (cr.Reviewer__c == performanceReview.Manager__c)
	        		competenciesReviewComments.add(cr);
	        }	        
	        for(CompetencyReview__c cr : originalList){
	        	if (cr.Reviewer__c == performanceReview.SecondManager__c)
	        		competenciesReviewComments.add(cr);
	        }        
	        for(CompetencyReview__c cr : originalList){
	        	if ((cr.Reviewer__c != performanceReview.Employee__c)
	        	&& (cr.Reviewer__c != performanceReview.Manager__c)
	        	&& (cr.Reviewer__c != performanceReview.SecondManager__c)
	        	&& (performanceReview.Status__c != 'Employee Self Assessment'))
	        		competenciesReviewComments.add(cr);
	        }	        
	        return competenciesReviewComments;
        }       
/* 
* END FUNCTION FOR COMPETENCIES *********************
* BEGIN FUNCTIONS FOR METHODS *********************
*/
        public List<PerformanceMethodController> getMethods(){
        	methods = new List<PerformanceMethodController>();
        	if (performanceReview != null) {
        		
            	list<Value__c> tempValues = [SELECT Name, (SELECT Id FROM Methods__r)
                                         FROM Value__c WHERE V2MOM__c=:performanceReview.V2MOM__c ORDER BY Priority__c];                        
            	list<Method__c> methodsc = [Select m.id, m.name, m.Value__c, m.Value__r.Name, m.Description__c, 
                                               (Select name, description__c From Obstacles__r ORDER BY Priority__c),  
                                               (Select name, description__c From Measures__r ORDER BY Priority__c)
                                        From Method__c m
                                        Where V2MOM__c=:performanceReview.V2MOM__c
                                           and Value__c IN :tempValues
                                        ORDER BY Priority__c];                                       
            	list<Method__c> methodsc_withoutvalue = [Select m.id, m.name, m.Value__c, m.Value__r.Name, m.Description__c, 
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
            	if (isPCOMMLikeViewProfile){
	        		// retrieve data without sharing       
	            	methodReviewsManager = getPerformanceReviewDataWithoutSharing(performanceReview, methodsc);
	            	methodReviewsEmployee = getPerformanceReviewEmployeeWithoutSharing(performanceReview, methodsc);
	            	methodReviewsComments = getPerformanceReviewCommentWithoutSharing(performanceReview, methodsc);
	            	methodReviewsComments = orderMethodReviewList(methodReviewsComments);
	        	}else{
	            	methodReviewsManager = util.getPerformanceReviewDataWithSharing(performanceReview, methodsc);
	            	methodReviewsEmployee = util.getPerformanceReviewEmployeeWithSharing(performanceReview, methodsc);
	            	methodReviewsComments = util.getPerformanceReviewCommentWithSharing(performanceReview, methodsc);
	            	methodReviewsComments = orderMethodReviewList(methodReviewsComments);
	        	}         
            	for(Method__c methodc: methodsc){               
                	List<MethodReview__c> temp = new List<MethodReview__c>();
                	PerformanceMethodController method = new PerformanceMethodController(methodc,  performanceReview);    
                	MethodReview__c review = methodReviewsManager.get(methodc.Id);
                	MethodReview__c reviewEmployee = methodReviewsEmployee.get(methodc.Id);       
                	if (review != null)
                	{
                    	method.setReview(review);
	                	if ((accessUtil.getIs3PtInAssmnt() && performanceReview.PreviousStatus__c.equals('Manager Assessment'))
            			|| ((accessUtil.getIsEmpl() && !(performanceReview.Status__c.equals('Complete') || performanceReview.Status__c.equals('Employee Approval')))) 
		            	|| (accessUtil.getIsMngr2ndMngrOrPCOMM() && performanceReview.Status__c.equals('Employee Self Assessment'))
		            	|| ((accessUtil.getIs2ndMngr() || accessUtil.getIsPCOMM()) && performanceReview.Status__c.equals('Manager Assessment'))
	                	|| (isPCOMMLikeViewProfile && (accessUtil.getStatusRO3() || (!getIsSysAdminProfile() && performanceReview.Status__c.equals('Manager Assessment'))))){                   
	                    method.setRating(null);
	                    method.setWeight(null);	                 
                    }else{
	                  	if (accessUtil.getIsPCOMM())
                    	{
                    		if (performanceReview.Status__c == '3rd Party Assessment' || performanceReview.Status__c == 'Manager Assessment' )
                    		{
                    			 method.setRating(null);
			                	 method.setWeight(null); 
                    		}
                    		else
                    		{
                    			method.setRating(review.Rating__c);
		                    	method.setWeight(review.Weight__c);
                    		}
                    	}
                    	else
                    	{
		                    method.setRating(review.Rating__c);
		                    method.setWeight(review.Weight__c);
                    	}
                    }
                    if(accessUtil.getIsPCOMM() && accessUtil.getIsMngr()){	 			                    
	                    if(performanceReview.Status__c != 'Employee Self Assessment'){    
	                    method.setRating(review.Rating__c);
                    	method.setWeight(review.Weight__c);                  	
	                    }	                	
                    }                  
                    if(userInf.equals(performanceReview.ThirdPartyReviewer__c) && performanceReview.PreviousStatus__c.equals('Manager Assessment')){
                    	method.setRating(null);
		                method.setWeight(null);
                    }	
                    if(accessUtil.getUserProfile() == 'System Administrator'|| accessUtil.getUserProfile()=='systemadministrator'){ 
						method.setRating(review.Rating__c);
                    	method.setWeight(review.Weight__c);
					}	
                }              
                if (reviewEmployee != null)
                {
                    method.setReview(reviewEmployee);
                    if(accessUtil.getUserProfile() == 'System Administrator'|| accessUtil.getUserProfile()=='systemadministrator'){ 
                		method.setStatus(reviewEmployee.Status__c);
                	}
                	else{
	                    if (isPCOMMLikeViewProfile && accessUtil.getStatusRO3()){
                    	method.setStatus(null);
	                    }
	                    else{
                    	method.setStatus(reviewEmployee.Status__c);
	                    }
	            	}
                }                
                if (methodReviewsComments.size() > 0)
                {
                    temp = getMr(methodReviewsComments,methodc);
                    method.setHistory(temp);
                }                
                methods.add(method);
            }
	        if (isPCOMMLikeViewProfile){
	        	// retrieve data without sharing       
	            methodReviewsManager = getPerformanceReviewDataWithoutSharing(performanceReview, methodsc_withoutvalue);
	            methodReviewsEmployee = getPerformanceReviewEmployeeWithoutSharing(performanceReview, methodsc_withoutvalue);
	            methodReviewsComments = getPerformanceReviewCommentWithoutSharing(performanceReview, methodsc_withoutvalue);
	            methodReviewsComments = orderMethodReviewList(methodReviewsComments);
	        }else{
	            methodReviewsManager = util.getPerformanceReviewDataWithSharing(performanceReview, methodsc_withoutvalue);
	            methodReviewsEmployee = util.getPerformanceReviewEmployeeWithSharing(performanceReview, methodsc_withoutvalue);
	            methodReviewsComments = util.getPerformanceReviewCommentWithSharing(performanceReview, methodsc_withoutvalue);
	            methodReviewsComments = orderMethodReviewList(methodReviewsComments);
	        }         
            for(Method__c methodc: methodsc_withoutvalue){               
                List<MethodReview__c> temp = new List<MethodReview__c>();
                PerformanceMethodController method = new PerformanceMethodController(methodc,  performanceReview);    
                MethodReview__c review = methodReviewsManager.get(methodc.Id);
                MethodReview__c reviewEmployee = methodReviewsEmployee.get(methodc.Id);        
                if (review != null)
                {
                    method.setReview(review);
	                if ((accessUtil.getIs3PtInAssmnt() && performanceReview.PreviousStatus__c.equals('Manager Assessment'))
            		|| ((accessUtil.getIsEmpl() && !(performanceReview.Status__c.equals('Complete') || performanceReview.Status__c.equals('Employee Approval')))) 
		            || (accessUtil.getIsMngr2ndMngrOrPCOMM() && performanceReview.Status__c.equals('Employee Self Assessment'))
		            || ((accessUtil.getIs2ndMngr() || accessUtil.getIsPCOMM()) && performanceReview.Status__c.equals('Manager Assessment'))
	                || (isPCOMMLikeViewProfile && (accessUtil.getStatusRO3() || (!getIsSysAdminProfile() && performanceReview.Status__c.equals('Manager Assessment'))))){
	                    method.setRating(null);
	                    method.setWeight(null);
                    }else{
	              		if (accessUtil.getIsPCOMM())
		                    	{
		                    		if (performanceReview.Status__c == '3rd Party Assessment' || performanceReview.Status__c == 'Manager Assessment' )
		                    		{
		                    			 method.setRating(null);
					                	 method.setWeight(null); 
		                    		}
		                    		else
		                    		{
		                    			method.setRating(review.Rating__c);
				                    	method.setWeight(review.Weight__c);
		                    		}
		                    	}
		                    	else
		                    	{
				                    method.setRating(review.Rating__c);
				                    method.setWeight(review.Weight__c);
		                    	}
                    }
                    if(accessUtil.getIsPCOMM() && accessUtil.getIsMngr()){	 			                    
	                    if(performanceReview.Status__c != 'Employee Self Assessment'){    
	                    method.setRating(review.Rating__c);
                    	method.setWeight(review.Weight__c);                  	
	                    }	                 	
                    }  
                    if(accessUtil.getUserProfile() == 'System Administrator'|| accessUtil.getUserProfile()=='systemadministrator'){ 
						method.setRating(review.Rating__c);
                    	method.setWeight(review.Weight__c);
					}	
                }               
                if (reviewEmployee != null)
                {
                    method.setReview(reviewEmployee);
                    if(accessUtil.getUserProfile() == 'System Administrator'|| accessUtil.getUserProfile()=='systemadministrator'){ 
                		method.setStatus(reviewEmployee.Status__c);
                	}
                	else{
	                    if (isPCOMMLikeViewProfile && accessUtil.getStatusRO3()){
                    	method.setStatus(null);
	                    }
	                    else{
                    	method.setStatus(reviewEmployee.Status__c);
	                    }
	            	}
                }                
                if (methodReviewsComments.size() > 0)
                {
                    temp = getMr(methodReviewsComments,methodc);
                    method.setHistory(temp);
                }               
                methods.add(method);
            }
        	}          
                       
            return methods;
        }       
        // Return Method Review of one list of method review for the method
        public List<MethodReview__c> getMr(List<MethodReview__c> mrs, Method__c m){   
            List<MethodReview__c> tempMe = new List<MethodReview__c>();            
            for(MethodReview__c mr: mrs)
            {
                if (mr.Method__c == m.Id)
                {
                    tempMe.add(mr);
                }
            }            
            return tempMe;
        }
/*
* END FUNCTIONS FOR METHODS *********************
* BEGIN FUNCTIONS FOR CALCULATIONS *********************
*/
     //Returns the sum of all weights for all methods
     public double getAllMethodWeightSum(){
         double methodWeightSum = 0;         
         if (methods == null) methods = getMethods();
         for(PerformanceMethodController method: methods){
             if (method.weight != null)
                 methodWeightSum = methodWeightSum + method.weight; 
         }        
         return methodWeightSum;
     }
        // Return Overall Method Rating
        // Overall Method rating = SUM(Rate * (Weight/100))
        public Double getAvgRatingMethods(){
            avgMethods = 0;
            if (methods == null) methods = getMethods();
            for(PerformanceMethodController method: methods){
                    if (method.weight != null && method.rating != null)
                            avgMethods = avgMethods + (method.rating * (method.weight / 100));
            }
            return avgMethods;
        }    
     //Returns the weight for Methods & Metrics from the review template
     public double getMethodAndMetricWeight(){
         double mw = 1;
         if (performanceReview.ReviewFormTemplate__r.MethodWeight__c != null) 
            mw = performanceReview.ReviewFormTemplate__r.MethodWeight__c;
         return mw;
     }
     public String getMethodAndMetricWeightShow(){
         if (performanceReview.ReviewFormTemplate__r.MethodWeight__c != null){ 
           	String subStr = String.valueOf(performanceReview.ReviewFormTemplate__r.MethodWeight__c);
           	if(subStr.length() > 0)
        		return subStr + '%';
         }
         return '-';
     }
     //Returns the weight for Metrics according to the sum of weights for Methods
     public double getMetricWeight(){
         double methodWeights = getAllMethodWeightSum();
         return (100 - methodWeights);
     }   
     //Returns the weight for Competencies from the review template
     public double getCompetencyWeight(){
         double cw = 1;
         if (performanceReview != null && performanceReview.ReviewFormTemplate__r.CompetencyWeight__c != null) 
            cw = performanceReview.ReviewFormTemplate__r.CompetencyWeight__c;
         return cw;
     }        
     public String getCompetencyWeightShow(){
         if (performanceReview != null && performanceReview.ReviewFormTemplate__r.CompetencyWeight__c != null){ 
            String subStr = String.valueOf(performanceReview.ReviewFormTemplate__r.CompetencyWeight__c);
        	if(subStr.length() > 0)
        		return subStr + '%';
         }
         return '-';
     }           
     // Returns Method Calculated Rating for all methods
     // Calculated Method Rating = SUM(Rate * (Weight/100))
     public Double getMethodCalculatedRating(){
         double methodCalculatedRating = 0;
         if (methods == null) methods = getMethods();
         for(PerformanceMethodController method: methods){
             if (method.weight != null && method.rating != null)
                 methodCalculatedRating = methodCalculatedRating + (method.rating * (method.weight / 100));
         }
         return methodCalculatedRating;
     }
     // Returns Average of Method Calculated Rating for all methods within the Method section
     // Average Calculated Method Calculated Rating = SUM(Rate * (Weight/100) * (Weight/methodWeightSum))
     public Double getMethodCalculatedRatingWithinMethods(){
         double methodCalculatedRatingWithinMethods = 0;
         double methodWeightSum = getAllMethodWeightSum();
         if (methods == null) methods = getMethods();
         for(PerformanceMethodController method: methods){
             if ((method.weight != null) && (method.rating != null) && (methodWeightSum != 0))
                 methodCalculatedRatingWithinMethods = methodCalculatedRatingWithinMethods + method.rating*(method.weight/methodWeightSum);
         }
         return methodCalculatedRatingWithinMethods;
     }
    // Returns Metric Calculated Rating for all metrics
    public Double getMetricCalculatedRating(){
    	// Metric Calculated Rating = SUM((Rate * (Weight/100))/2)
         if ((scorecardTypeProfile.Profile.Name.equals('Support Employee') && scorecardSupport.getIsOld())|| (scorecardTypeProfile.Profile.Name.equals('Support Manager')&& scorecardSupport.getIsOld()))
         {
         	return scorecardSupport.getAvgRatingCSAT() + scorecardSupport.getAvgRatingRenewals() 
         			+ scorecardSupport.getAvgRatingWMCases() 
         			+ scorecardSupport.getAvgRatingWMSMES() + scorecardSupport.getAvgRatingWMHC() 
         			+ scorecardSupport.getAvgRatingWMPA() + scorecardSupport.getAvgRatingSI();
         }        			
    	// Metric Calculated Rating = SUM(Rate * (Weight/100))
    	if ((scorecardTypeProfile.Profile.Name.equals('Education Employee') || (scorecardTypeProfile.Profile.Name.equals('Education Manager'))) && (getMetricWeight() != 0))
    		return scorecardSupport.getAvgRatingEducationMetrics() / getMetricWeight() * 100;
        	
    	if ((scorecardTypeProfile.Profile.Name.equals('CSM Employee') || (scorecardTypeProfile.Profile.Name.equals('CSM Manager'))) && (getMetricWeight() != 0))
    		return scorecardSupport.getAvgRatingCSMMetrics() / getMetricWeight() * 100;
    	
    	if ((scorecardTypeProfile.Profile.Name.equals('Support Employee') || scorecardTypeProfile.Profile.Name.equals('Support Manager')  )&& (getMetricWeight() != 0))
    		return scorecardSupport.getAvgRatingSupportMetrics() / getMetricWeight() * 100;	
      		
         return 0;
     }
    // Returns Average Metric Calculated Rating for all metrics within the Metric section
    // Average Metric Calculated Rating = (SUM((Rate * (Weight/100))/2))*(MeW / 100)
    public Double getMetricCalculatedRatingWithinMetrics(){
         double metricCalculatedRatingWithinMetrics = getMetricCalculatedRating();   
         return metricCalculatedRatingWithinMetrics * getMetricWeight() / 100;
     }
     // Returns Average Method & Metric Calculated Rating
     // Average Method & Metric Calculated Rating = (MethodCalculatedRating + MetricCalculatedRatingWithinMetrics)* MethodAndMetricWeight
     public Double getMethodsAndMetricsCalculatedRating(){
         return (getMethodCalculatedRating() + getMetricCalculatedRatingWithinMetrics()) * getMethodAndMetricWeight() / 100;
     }   
     // Returns Competency Calculated Rating for all competencies
     // Competency Calculated Rating = SUM(Rate * (Weight/100))
     public Double getCompetencyCalculatedRating() {
         double competencyCalculatedRating = 0;
    
         if (competencies == null) competencies = getCompetencies();
         for(PerformanceCompetencyController competency: competencies){
             if (competency.weight != null && competency.Rating != null){
                 competencyCalculatedRating = competencyCalculatedRating + (competency.Rating * (competency.weight / 100));
             }
         }          
         return competencyCalculatedRating;
     }
     // Returns Average Competency Calculated Rating for all competencies within the competency section
     // Average Competency Calculated Rating = (SUM(Rate * (Weight/100))) * (CompetencyWeight/100)
     public Double getCompetencyCalculatedRatingWithinCompetencies() {
         double competencyCalculatedRating = getCompetencyCalculatedRating();        
         double cw = getCompetencyWeight();   
         return competencyCalculatedRating * cw / 100;
     }   
     // Returns Overall Calculated Rating
     // Overall Calculated Rating = MethodsAndMetricsCalculatedRating + getCompetencyCalculatedRatingWithinCompetencies
     public double getOverallCalculatedRating(){        
         return getMethodsAndMetricsCalculatedRating() + getCompetencyCalculatedRatingWithinCompetencies();
     }
/*
* END FUNCTIONS FOR CALCULATIONS *********************
* BEGIN FUNCTIONS TO SHOW VALUES - ACCESS DESIGN ******
*/
    //-----------------  USER PROFILES ----------------------------------
	// returns true if the performance review has scorecards
     public Boolean getShowSupportScorecard()
     {
         if(performanceReview.ThirdPartyReviewer__c == userInfo.getUserId()){
         	return false;        	
         }
         if ((v2momType != 'Individual Q1/Q2') && (v2momType != 'Individual Q3/Q4'))
         	return false;        
         if(listScorecard != null){	
	         if (listScorecard.size()>0)
	         {
	         	for(ScorecardSupportReview__c s : listScorecard){
	         		if ((v2momType == 'Individual Q1/Q2') 
	         		&& (s.FiscalQuarter__c.equals('Q1') || s.FiscalQuarter__c.equals('Q2')))
	         			return true;
	         		if ((v2momType == 'Individual Q3/Q4') 
	         		&& (s.FiscalQuarter__c.equals('Q3') || s.FiscalQuarter__c.equals('Q4')))
	         			return true;
	         	}
	         	return false;
	         }
	         else
	         {
	             return false;
	         }
         }
         return false;
     }
	// returns true if is has scorecards and if the logged is a education profile
    public boolean getIsEducationProfile(){    
        if (! getShowSupportScorecard()){
            return false;   
        }        
		return accessUtil.getIsEducationProfile();
    }        
	// returns true if is has scorecards and if the logged is a support profile
    public boolean getIsSupportProfile(){   
        if (! getShowSupportScorecard()){
            return false;   
        }        
		return accessUtil.getIsSupportProfile();
    }   
	// returns true if is has scorecards and if the logged is a consulting profile
    public boolean getIsConsultingProfile(){   
        if (! getShowSupportScorecard()){
            return false;   
        }        
		return accessUtil.getIsConsultingProfile();
    }    
	// returns true if is has scorecards and if the logged is a CSM profile
    public boolean getIsCSMProfile(){
    
        if (! getShowSupportScorecard()){
            return false;   
        }
        
		return accessUtil.getIsCSMProfile();
    }
    // Return true if the logged user is of System Administrator profile
    public boolean getIsSysAdminProfile(){
		return accessUtil.getIsSysAdminProfile();
    }   
    // checks all the profiles that can view the scorecards if there are scorecards
    public boolean getScorecardViewProfile(){
        if (! getShowSupportScorecard()){
            return false;   
        }  
		return accessUtil.getScorecardViewProfile();
    }       
    // returns true if it is not a profile that should see scorecards
    public boolean getHaveProfile(){
		return accessUtil.getHaveProfile();
    }   
    //--------------------- END OF USER PROFILES ------------------------
     // Return true if the logged user is the manager of performance review no matter the status
     public boolean getIsMngr() {
		return accessUtil.getIsMngr();
     }    
    // Manager in Assessment - Write permission
     public boolean getIsMngrInAssmnt() {
		return accessUtil.getIsMngrInAssmnt();
     }         
    // Employee, Manager, 2nd Manager or 3rd Party in Assessment - Write permission
     public boolean getIsEmplMngr2ndMngrOr3PtInAssmnt() {
		return accessUtil.getIsEmplMngr2ndMngrOr3PtInAssmnt();
     } 
	// determines the users and statuses in which the overall calculated method rating can be shown
	public boolean getOverallCalcMethodRatingView(){
		return accessUtil.getOverallCalcMethodRatingView();
	}
	// determines the users and statuses in which the overall calculated metric rating can be shown
	public boolean getOverallCalcMetricRatingView(){
		return accessUtil.getOverallCalcMetricRatingView();
	}
	// determines the users and statuses in which the overall calculated competency rating can be shown
	public boolean getOverallCalcCompRatingView(){
		return accessUtil.getOverallCalcCompRatingView();
	}
	// determines the users and statuses in which the overall calculated rating can be shown
	public boolean getOverallRatingView(){
		return accessUtil.getOverallRatingView();
	}
	// returns if the overall rating should be shown
    public boolean getShowOverallRating() {
        return !(userInf.equals(performanceReview.Employee__c)
                && (performanceReview.Status__c.equals('Employee Self Assessment')
                        || performanceReview.Status__c.equals('Manager Assessment')
                        || performanceReview.Status__c.equals('2nd Level Manager Assessment')
                        || performanceReview.Status__c.equals('3rd Party Assessment')
                        || performanceReview.Status__c.equals('2nd Level Manager Approval')
                        || performanceReview.Status__c.equals('Manager Approval')));
    }        
// ----------------------- FUNCTIONS FOR DISPLAY
     // Return Competency Calculated Rating formated for display
     public String getDisplayCompetencyCalculatedRating(){
    	if(accessUtil.getIsOnlySysAdminProfile()){
    		String subStr = String.valueOf(getCompetencyCalculatedRating());	    
	         if( subStr.length() > 3)
	             return subStr.substring(0,4);
	         return subStr.substring(0,3);
    	}
    	if(((performanceReview.PreviousStatus__c == 'Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
			||((performanceReview.PreviousStatus__c == '2nd Level Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
			|| ((performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.PCOMM__c == userInfo.getUserId()))){
				return '-';
		}
    	if (getOverallCalcCompRatingView()){
	         String subStr = String.valueOf(getCompetencyCalculatedRating());
	    
	         if( subStr.length() > 3)
	             return subStr.substring(0,4);
	         return subStr.substring(0,3);
    	}
    	return '-';
     }
     public boolean getIsOnlySysAdminProfile()
     {   	
    	 return accessUtil.getIsOnlySysAdminProfile();
     }
     // Return Method Calculated Weight formated for display
     public String getDisplayMethodCalculatedWeight(){    	
    	if(getIsOnlySysAdminProfile()){
    		String subStr = String.valueOf(getMethodAndMetricWeight()); 	    
     		if( subStr.length() > 4)
        		return subStr.substring(0,5);
     		return subStr + '%';
    	}
    	if(((performanceReview.PreviousStatus__c == 'Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
			||((performanceReview.PreviousStatus__c == '2nd Level Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
			|| ((performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.PCOMM__c == userInfo.getUserId()))
			|| performanceReview.Status__c == 'Employee Self Assessment'){
				return '-';
		}
    	if (!getShowSupportScorecard()){	    		
	         String subStr = String.valueOf(getMethodAndMetricWeight()); 	    
	         if( subStr.length() > 4)
	             return subStr.substring(0,5);
	         return subStr + '%';
    	}else{
    		if (((accessUtil.getIsMngr2ndMngrOrPCOMM() || accessUtil.getPCOMMLikeViewProfile()) && accessUtil.getStatusRO1()) 
			|| ((accessUtil.getIsEmplMngr2ndMngrOrPCOMM() || accessUtil.getPCOMMLikeViewProfile()) && accessUtil.getStatusRO2() && !accessUtil.getIsEmplIn3PtAssmnt())
			|| getIsMngrInAssmnt() || accessUtil.getIs3rdManager()){
	         String subStr = String.valueOf(getAllMethodWeightSum());
	    
	         if( subStr.length() > 4)
	             return subStr.substring(0,5);
	         return subStr + '%';
    		}
    	}
    	return '-';
     }   
     // Return Method Calculated Rating formated for display
     public String getDisplayMethodCalculatedRating(){   
    	if(accessUtil.getIsOnlySysAdminProfile()){
    		Decimal decimalValue = Decimal.valueOf(getMethodCalculatedRatingWithinMethods());
	        String subStr = String.valueOf(decimalValue.setScale(2, System.RoundingMode.UP));
	    	return subStr;
    	}
    	if(((performanceReview.PreviousStatus__c == 'Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
			||((performanceReview.PreviousStatus__c == '2nd Level Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
			|| ((performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.PCOMM__c == userInfo.getUserId()))){
				return '-';
		}
    	if (getOverallCalcMethodRatingView()){
	        Decimal decimalValue = Decimal.valueOf(getMethodCalculatedRatingWithinMethods());
	        String subStr = String.valueOf(decimalValue.setScale(2, System.RoundingMode.UP));
	    	return subStr;
    	}
    	return '-';
     }
     // Return Metric Calculated Weight formated for display
     public String getDisplayMetricCalculatedWeight(){   
    	if(accessUtil.getIsOnlySysAdminProfile()){
    		String subStr = String.valueOf(getMetricWeight());	    
	         if( subStr.length() > 4)
	             return subStr.substring(0,5) + '%';
	         return subStr + '%';
    	}
    	if(((performanceReview.PreviousStatus__c == 'Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
			||((performanceReview.PreviousStatus__c == '2nd Level Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
			|| ((performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.PCOMM__c == userInfo.getUserId()))){
				return '-';
		}
    	if (getShowSupportScorecard() && 
    		(((accessUtil.getIsMngr2ndMngrOrPCOMM() || accessUtil.getPCOMMLikeViewProfile()) && accessUtil.getStatusRO1()) 
			|| ((accessUtil.getIsEmplMngr2ndMngrOrPCOMM() || accessUtil.getPCOMMLikeViewProfile()) && accessUtil.getStatusRO2() && !accessUtil.getIsEmplIn3PtAssmnt())
			|| getIsMngrInAssmnt())){
	         String subStr = String.valueOf(getMetricWeight());
	    
	         if( subStr.length() > 4)
	             return subStr.substring(0,5) + '%';
	         return subStr + '%';
    	}
    	return '-';
     }
     // Return Metric Calculated Rating formated for display
     public String getDisplayMetricCalculatedRating(){   
    	if(accessUtil.getIsOnlySysAdminProfile()){
    		Decimal decimalValue = Decimal.valueOf(getMetricCalculatedRating());
	        String subStr = String.valueOf(decimalValue.setScale(2, System.RoundingMode.UP));
	        return subStr;
    	}
    	if(((performanceReview.PreviousStatus__c == 'Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
			||((performanceReview.PreviousStatus__c == '2nd Level Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
			|| ((performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.PCOMM__c == userInfo.getUserId()))){
				return '-';
		}
    	if (getOverallCalcMetricRatingView()){
	         Decimal decimalValue = Decimal.valueOf(getMetricCalculatedRating());
	         String subStr = String.valueOf(decimalValue.setScale(2, System.RoundingMode.UP));
	         return subStr;
    	}
    	return '-';
     }   
     // Return Overall Calculated Rating formated for display
     public String getDisplayOverallCalculatedRating(){
     	if(accessUtil.getIsOnlySysAdminProfile()){
    		Decimal decimalValue = Decimal.valueOf(getOverallCalculatedRating());
	         String subStr = String.valueOf(decimalValue.setScale(2, System.RoundingMode.UP));
	         return subStr;
    	}
     	if(((performanceReview.PreviousStatus__c == 'Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
			||((performanceReview.PreviousStatus__c == '2nd Level Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
			|| ((performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.PCOMM__c == userInfo.getUserId()))){
				return '-';
		}
     	if (getOverallRatingView()){    	
	         Decimal decimalValue = Decimal.valueOf(getOverallCalculatedRating());
	         String subStr = String.valueOf(decimalValue.setScale(2, System.RoundingMode.UP));
	         return subStr;
     	}
    	return '-';
     }
     // Return Final Overall Calculated Rating formated for display
    public String getDisplayOverallRating() {
        if(accessUtil.getIsOnlySysAdminProfile()){
    		if(performanceReview != null && performanceReview.ReviewRating__r != null && performanceReview.ReviewRating__r.OverallRating__c != null){
    			return PAMUtil.getRatingLabel(performanceReview.ReviewRating__r.OverallRating__c.intValue());
    		}
    	}
        if(((performanceReview.PreviousStatus__c == 'Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
			||((performanceReview.PreviousStatus__c == '2nd Level Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
			|| ((performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.PCOMM__c == userInfo.getUserId()))){
				return '-';
		}
        if(performanceReview.ReviewRating__r == null) return '-';
        if(performanceReview.ReviewRating__r.OverallRating__c == null) return '-';       
        if (!getOverallRatingView())
			return '-';       
        return PAMUtil.getRatingLabel(performanceReview.ReviewRating__r.OverallRating__c.intValue());
    }
/*
* END FUNCTIONS TO SHOW VALUES - ACCESS DESIGN ******
*/
		public class PerformanceReviewHistoryDate{
			PerformanceReview__History performanceReviewHistory;
			String CreatedDate;			
			public PerformanceReviewHistoryDate(PerformanceReview__History ph){
				performanceReviewHistory = ph;
				CreatedDate = ph.CreatedDate.format();
			}			
			public PerformanceReview__History getPerformanceReviewHistory(){
				return performanceReviewHistory;
			}			
			public void setPerformanceReviewHistory(PerformanceReview__History ph){
				performanceReviewHistory = ph;
			}			
			public String getCreatedDate(){
				return createdDate;
			}			
			public void setCreatedDate(String s){
			}		
		}
        // Return a List of approval history to show
        list<PerformanceReview__History>  performanceReviewHistory;
        public list<PerformanceReviewHistoryDate> getPerformanceReviewHistory(){
            list<PerformanceReviewHistoryDate> ret = new list<PerformanceReviewHistoryDate>();
            if (performanceReviewHistory == null){
                performanceReviewHistory = [SELECT CreatedBy.name, CreatedDate, NewValue, OldValue
                                            FROM PerformanceReview__History
                                            WHERE Field =: 'Status__c' and ParentId =: performanceReview.id Order By CreatedDate];
            }
            for(Integer i = 0; i < performanceReviewHistory.size(); i++){
                PerformanceReview__History aux = performanceReviewHistory[i];
                String oldVal = String.valueOf(aux.oldValue); 
                String newVal = String.valueOf(aux.newValue);              
                if(oldVal != null && newVal != null){
                    if((oldVal.equals('PCOMM Review') && newVal.equals('Manager Approval')) 
                            || (oldVal.equals('Manager Assessment') && newVal.equals('2nd Level Manager Assessment')) 
                            || (oldVal.equals('2nd Level Manager Assessment') && newVal.equals('Pending Employee Services')) 
                            || (oldVal.equals('Employee Approval') && newVal.equals('Complete'))){
                        ret.add(new PerformanceReviewHistoryDate(aux));
                    }
                }
            }
            return ret;
        }
        /*
        * Inner Class Value
        * To hold Value and their Methods
        */
        public class Value {
            Value__c value;
            List<PerformanceMethodController> methods;
            public Value(Value__c v, List<PerformanceMethodController> m) {
                value = v;
                methods = m;
            }
            public String getId() {
                return value.Id;
            }
            public String getName() {
                return value.Name;
            }
           	public List<PerformanceMethodController> getMethods() {
                return methods;
            }
            public Integer getMethodCount() {
                return methods.size();
            }
        }

		
         // returns the data of the competencies if the logged user is allowed to access it
      public Map<Id, CompetencyReview__c> getCompetencyReviewWithSharingMap(PerformanceReview__c p, List<CompetencyGroupMember__c> c) {            
            Map<Id, CompetencyReview__c> tempmap = new Map<Id, CompetencyReview__c>();             
            for(CompetencyReview__c cr: [SELECT Rating__c,CompetencyGroupMember__r.Competency__c, Reviewer__c, Reviewer__r.Name, CompetencyGroupMember__c
                                        FROM CompetencyReview__c WHERE PerformanceReview__c =: p.id AND CompetencyGroupMember__c IN: c order by CreatedDate ASC]) {                 
                      tempmap.put(cr.CompetencyGroupMember__r.Competency__c, cr);
            }         
            return tempmap;
       }       
}