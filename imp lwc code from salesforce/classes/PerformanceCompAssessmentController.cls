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
 
public with sharing class PerformanceCompAssessmentController {
  
        public static boolean 	isTestClass = false;
    	   
    	PerformanceReview__c 	performanceReview;
        public Id 	 			performanceRevId = System.currentPageReference().getParameters().get('id');
        List<Competency>  		competencies;
        String 					currentUserId = userInfo.getUserId();
        CompetencyUtil 			util = new CompetencyUtil();
        String 					currentUserProfile;
    	boolean 				isPCOMMLikeViewProfile;
    	User 					scorecardTypeProfile;
    	PerformanceAccessUtil 	accessUtil;
		boolean 				isSaving = false; // to avoid double comments
		User 					userprof;
		//boolean					error = false;
        public class SharingException extends Exception {} // This needs to be refactored into external class as soon
                                                           // they get this Apex thing right and let me extend an exception the right way
        /*
        * Constructor
        */
        public PerformanceCompAssessmentController(){
           // checks the id of the performance is not null
           if(performanceRevId != null ) {
				// inicialize constructor	
				this.constructor();
           }
	        else if (!isTestClass)throw new SharingException(Label.PerformanceV2MOMAssessmentController_exception5);
        }
        
        public void constructor(){
        		// checks the profile of the user
               userprof = [SELECT Id, Profile.Name FROM User WHERE id =: currentUserId];
               currentUserProfile = userprof.Profile.Name;

				// gets the performance review completely
		        performanceReview = getPerformanceReviewWithoutSharing(performanceRevId);
			
		        if(performanceReview == null && isTestClass == false) 
		        	throw new SharingException(Label.PerformanceV2MOMAssessmentController_exception1);

				// gets the profile of the employee to see what kind of scorecard it might have
	        	scorecardTypeProfile = [Select u.Profile.Name, u.ProfileId From User u where id = :performanceReview.Employee__c];   
    		
	    		// access class for permissions
	            accessUtil = new PerformanceAccessUtil(performanceReview, userprof, scorecardTypeProfile);
		
				// uses the information of the performance review to check if the profile of the
				// current user should see data filtered by sharing rules or filtered manually
				isPCOMMLikeViewProfile = accessUtil.getPCOMMLikeViewProfile();
	
				if (!isPCOMMLikeViewProfile)
		        	performanceReview = util.getPerformanceReviewWithSharing(performanceRevId);
	    
               if(performanceReview == null && !isTestClass) 
               		throw new SharingException(Label.PerformanceV2MOMAssessmentController_exception2);
    
               competencies = new List<Competency>();
    
               List<CompetencyGroupMember__c> competenciesGroupMember = [Select Id, Name,
                                                                                Weight__c,
                                                                                Competency__r.Name,
                                                                                Competency__r.Description__c,
                                                                                Competency__c
                                                                        From CompetencyGroupMember__c
                                                                        Where CompetencyGroup__c =: performanceReview.CompetencyGroup__c];
           
				Map<Id, CompetencyReview__c> competenciesReview;
	            List <CompetencyReview__c> competenciesReviewComments;  
				
            	// gets data and comments of the competencies
		        if (isPCOMMLikeViewProfile){
		        	competenciesReview = getCompetencyReviewWithoutSharingMap(performanceReview, competenciesGroupMember);
		        	competenciesReviewComments =  getCompetencyReviewListWithoutSharing(performanceReview, competenciesGroupMember);
		        }else{
		        	competenciesReview = util.getCompetencyReviewWithSharingMap(performanceReview, competenciesGroupMember);
		        	competenciesReviewComments =  util.getCompetencyReviewListWithSharing(performanceReview, competenciesGroupMember);
		        }
		        
               //competenciesReviewComments = orderCompetencyReviewList(competenciesReviewComments);
               
               for(CompetencyGroupMember__c competencyGroup: competenciesGroupMember) {
                     
                    List<CompetencyReview__c> tempList = new List<CompetencyReview__c>();
                     
                    Competency competency = new Competency(competencyGroup, performanceReview);
                    CompetencyReview__c review = competenciesReview.get(competencyGroup.Competency__c);                    
                    
                    if (review != null) 
                    {   
                        competency.setReview(review); 
	        			competency.setUserProfile(getUserProfile());
                        // filter manually the value of rating in these cases  
			            
			               if ((accessUtil.getIs3PtInAssmnt() && performanceReview.PreviousStatus__c.equals('Manager Assessment'))
		            		|| ((accessUtil.getIsEmpl() && !(performanceReview.Status__c.equals('Complete') || performanceReview.Status__c.equals('Employee Approval')))) 
				            || (accessUtil.getIsMngr2ndMngrOrPCOMM() && performanceReview.Status__c.equals('Employee Self Assessment'))
				            || ((accessUtil.getIs2ndMngr() || accessUtil.getIsPCOMM()) && performanceReview.Status__c.equals('Manager Assessment'))
			                || (isPCOMMLikeViewProfile && (accessUtil.getStatusRO3() || (!getIsSysAdminProfile() && performanceReview.Status__c.equals('Manager Assessment'))))){
			                	competency.setRating(null);   
		                    }
		                    else{
				                competency.setRating(review.Rating__c);
		                    }
		                    
		                    if(accessUtil.getIsPCOMM() && accessUtil.getIsMngr()){	               
			                    competency.setRating(review.Rating__c);
		                    }
		                    
		                    if(userInfo.getUserId().equals(performanceReview.ThirdPartyReviewer__c) && performanceReview.PreviousStatus__c.equals('Manager Assessment')){
		                    	competency.setRating(null); 
		                    }	
		                    
		                    if(PerformanceReview.Status__c.equals('Employee Self Assessment') && performanceReview.Manager__c == userInfo.getUserId()){
				            	competency.setRating(null);
					            review.Rating__c = null;
				            }
                    }
                    else{
                        CompetencyReview__c tempReview = new CompetencyReview__c(CompetencyGroupMember__c = competencyGroup.Id);
                        tempReview.performanceReview__c = performanceReview.id;
                        tempReview.Reviewer__c = currentUserId;
                        competency.setReview(tempReview);   
	        			competency.setUserProfile(getUserProfile());
                    }
                    
                    for(CompetencyReview__c cr: competenciesReviewComments)
                    {
                        if (cr.CompetencyGroupMember__c == competencyGroup.Id)
                        {
                            tempList.add(cr);   
                        }
                    }
                     
                    competency.setWeight(competencyGroup.Weight__c);
                    competency.setHistory(tempList); 
                    competencies.add(competency);   
                }   
        	
        }

		/*
		* BEGIN FUNCTIONS WITHOUT SHARING **************
		*/

			// gets the performance review without sharing
            public PerformanceReview__c getPerformanceReviewWithoutSharing(Id id) {

                List<PerformanceReview__c> performanceReview = [Select  Id,
                                                                        Name,
                                                                        Employee__c,
                                                                        Manager__c,
                                                                        SecondManager__c,
                                                                        PCOMM__c,
                                                                        ThirdPartyReviewer__c,
                                                                        CompetencyGroup__r.Name,
                                                                        PerformanceReviewPeriod__r.name,
                                                                        V2MOM__c,
                                                                        V2MOM__r.Vision__c,
                                                                        Status__c,
                                                                        PreviousStatus__c,
                                                                        ReviewFormTemplate__c 
                                                                From PerformanceReview__c
                                                                Where Id=:id];

                    if(performanceReview.size() == 0) return null;

                    return performanceReview.get(0);
            }

		// gets the data of the competencies without sharing
            public Map<Id, CompetencyReview__c> getCompetencyReviewWithoutSharingMap(PerformanceReview__c p, List<CompetencyGroupMember__c> c) {
            
                Map<Id, CompetencyReview__c> tempmap = new Map<Id, CompetencyReview__c>();
	             String reviewUser;
	             
	             if (p.Status__c.equals('Employee Self Assessment'))
	             	reviewUser = p.Employee__c;
	             else
	             	reviewUser = p.Manager__c; 
                   
                   for(CompetencyReview__c cr: [SELECT Rating__c,
                                                       Comment__c,
                                                       LastModifiedDate,
                                                       CompetencyGroupMember__r.Competency__c,
                                                       CompetencyGroupMember__c
                                            FROM CompetencyReview__c
                                            WHERE PerformanceReview__c =: p.id
                                            AND Reviewer__c =: reviewUser
                                            AND CompetencyGroupMember__c IN: c]) {
                            
                              tempmap.put(cr.CompetencyGroupMember__r.Competency__c, cr);
                   }
                   
                   return tempmap;
            }

			// gets the comments of the competencies without sharing
			// and filters the comments according to the logged user and the status of the performance review.
            public List<CompetencyReview__c> getCompetencyReviewListWithoutSharing(PerformanceReview__c p, List<CompetencyGroupMember__c> c) {

	               List<CompetencyReview__c> competenciesReviewComments = new List<CompetencyReview__c>();
	                
	               Profile profile = [select Id, Name from Profile where Id =: userInfo.getProfileId()];	
		    	
			    	if(profile.Name == 'System Administrator'||profile.Name=='systemadministrator'){
	                 	for(CompetencyReview__c cr: [SELECT Id, Name,
						                                    Comment__c,
						                                    Reviewer__c,
						                                    Reviewer__r.Name,
						                                    Rating__c,
						                                    CompetencyGroupMember__c,                   
						                                    PerformanceReview__c,
						                                    CreatedBy.Name,
						                                    LastModifiedDate,
						                                    CreatedDate
					                                FROM CompetencyReview__c
					                                WHERE PerformanceReview__c =: p.id                                      
					                                AND CompetencyGroupMember__c IN: c
					                               ORDER BY CreatedDate ASC]) {
 		                         	competenciesReviewComments.add(cr);
			              }  
			              
			              return    competenciesReviewComments;   
	                 }       		
		    		
		    		if (!accessUtil.getStatusRO3()){
			    		if (!performanceReview.Status__c.equals('Manager Assessment')){
				    		if (!performanceReview.Status__c.equals('2nd Level Manager Assessment')){
								// any status except created, empl self assmnt, mngr assmnt 
								// or 2nd level mngr assmnt retrieve all
					    		for(CompetencyReview__c cr: [SELECT Id, Name,
								                                    Comment__c,
								                                    Reviewer__c,
								                                    Reviewer__r.Name,
								                                    Rating__c,
								                                    CompetencyGroupMember__c,                   
								                                    PerformanceReview__c,
								                                    CreatedBy.Name,
								                                    LastModifiedDate,
								                                    CreatedDate
							                                FROM CompetencyReview__c
							                                WHERE PerformanceReview__c =: p.id                                      
							                                AND CompetencyGroupMember__c IN: c
							                               ORDER BY CreatedDate ASC]) {
		 		                         	competenciesReviewComments.add(cr);
					              }              
		                                	
				    		}else{
								// status 2nd level mngr assmnt retrieve all except the 2nd Manager comments
					    		for(CompetencyReview__c cr: [SELECT Id, Name,
								                                    Comment__c,
								                                    Reviewer__c,
								                                    Reviewer__r.Name,
								                                    Rating__c,
								                                    CompetencyGroupMember__c,                   
								                                    PerformanceReview__c,
								                                    CreatedBy.Name,
								                                    LastModifiedDate,
								                                    CreatedDate
							                                FROM CompetencyReview__c
							                                WHERE PerformanceReview__c =: p.id                                      
				                                            and (Reviewer__c <>: p.SecondManager__c)
							                                AND CompetencyGroupMember__c IN: c
							                               and Locked__c = true
							                               ORDER BY CreatedDate ASC]) {
		 		                         	competenciesReviewComments.add(cr);
					              }              
				    		}
			    		}else{
							// status mngr assmnt retrieve all except the Manager and 2nd Manager comments
					    		for(CompetencyReview__c cr: [SELECT Id, Name,
								                                    Comment__c,
								                                    Reviewer__c,
								                                    Reviewer__r.Name,
								                                    Rating__c,
								                                    CompetencyGroupMember__c,                   
								                                    PerformanceReview__c,
								                                    CreatedBy.Name,
								                                    LastModifiedDate,
								                                    CreatedDate
							                                FROM CompetencyReview__c
							                                WHERE PerformanceReview__c =: p.id                                      
				                                            and (Reviewer__c <>: p.Manager__c 
										                    and Reviewer__c <>: p.SecondManager__c)
							                                AND CompetencyGroupMember__c IN: c
							                               and Locked__c = true
							                               ORDER BY CreatedDate ASC]) {
		 		                         	competenciesReviewComments.add(cr);
				              }              
		    			}
	               }              
				return competenciesReviewComments;
            }           

       
        
		/*
		* END FUNCTIONS WITHOUT SHARING **************
		*/

    	// returns the values for the adjusted rating combo box
        public List<SelectOption> getRatingSelectOptions() {
            return PAMUtil.getRatingSelectOptions();
        }
        // Set competencies list
        public void setCompetencies(List<Competency> value){
        	this.competencies = value;
        }
		
		public String getCurrentUserProfile(){
			Profile pro = [select Id, Name from Profile where Id =: userInfo.getProfileId()];
			
			return pro.Name;
		}
        // Returns the PerformanceReview
        public PerformanceReview__c getPerformanceReview(){
                return performanceReview;
        }
        
        // Sets the Id of the PerformanceReview
        public void setPerformanceReviewParam(String Id){
            performanceRevId = Id;
        }
        
    	// sets the Id of the current user
        public String getCurrentUserId(){
            return currentUserId;   
        }

    	// gets the Id of the current user
        public void setCurrentUserId(String id){
            currentUserId = id; 
        }

    	// gets the profile of the current user
	     public String getUserProfile(){
	         return currentUserProfile;    
	     }

		// gets the label of the button for previous competency
       public String getLabelPreviousCompetency(){
            return '< ' +Label.Previous_Competency_btn;
       }

		// gets the label of the button for next competency
       public String getLabelNextCompetency(){
            return Label.Next_Competency_label + ' >';
       }      
		/*
		* BEGIN FUNCTIONS FOR COMPETENCIES **************
		*/
        
        public List<Competency> getCompetencies(){
            return competencies;
        }
        
    	// gets the weight of the competency section from the performance review template
        public String getCompetencyWeight() {
            ReviewFormTemplate__c rft = [Select CompetencyWeight__c 
                                         From ReviewFormTemplate__c r
                                         Where Id = :performanceReview.ReviewFormTemplate__c];
             return rft.CompetencyWeight__c + '';
        }

		/*
		* END FUNCTIONS FOR COMPETENCIES **************
		*/
		
		/*
		 * BEGIN SAVE FUNCTIONS *********************
		*/
		//all save functions are removed
		/*
		 * END SAVE FUNCTIONS *********************
		*/
		
		/*
		* BEGIN FUNCTIONS TO SHOW VALUES - ACCESS DESIGN **************
		*/

    // checks if it is assessment of methods. This is used in the JavaScripts
 	// similar to function getIsEmplMngr2ndMngrOr3PtInAssmnt
     public boolean getShowReviewEdit() {
		return accessUtil.getShowReviewEdit();
     } 

     // Return true if the logged user is the manager of performance review or a SysAdmin
     // in the manager assessment status (can edit elements)
     public boolean getIsManager() {
		return accessUtil.getIsMngr();
     }

     // Return true if the logged user is the employee of performance review no matter the status
     public boolean getIsEmployee() {
		return accessUtil.getIsEmployee();
     }

    //-----------------  USER PROFILES ----------------------------------------------------------------

    // Return true if the logged user is of System Administrator profile
    public boolean getIsSysAdminProfile(){
		return accessUtil.getIsSysAdminProfile();
    }

    //--------------------- USER ACCESS FUNCTIONS -------------------------------------------------

     // Return true if the logged user is the manager of performance review no matter the status
     public boolean getIsMngr() {
         return performanceReview.Manager__c == currentUserId;
     }
         
    // Manager in Assessment - Write permission
     public boolean getIsMngrInAssmnt() {
		return accessUtil.getIsMngrInAssmnt();
     }   

    // Employee, Manager, 2nd Manager or 3rd Party in Assessment - Write permission
     public boolean getIsEmplMngr2ndMngrOr3PtInAssmnt() {
		return (accessUtil.getIsEmplMngr2ndMngrOr3PtInAssmnt() && 
		!(accessUtil.getIsSysAdminProfile() && accessUtil.getStatusRO3()));
     } 

	/*
	* END FUNCTIONS TO SHOW VALUES - ACCESS DESIGN **************
	*/

	public class CompetencyReviewDate{
		String createdDate;
		CompetencyReview__c competencyReview;
		String lastModifiedDate;
		String reviewerName;
		
		public CompetencyReviewDate(CompetencyReview__c c){
			createdDate = c.CreatedDate.format();
			competencyReview = c;
			reviewerName = c.Reviewer__r.Name;
			lastModifiedDate = c.LastModifiedDate.format();
		}
		
		public CompetencyReview__c getCompetencyReview(){
			return competencyReview;
		}
		
		public void setCompetencyReview(CompetencyReview__c c){
			competencyReview = c;
		}
		
		public String getCreatedDate(){
			return createdDate;
		}
		public String getReviewerName(){
			return reviewerName;
		}
		
		public void setCreatedDate(String s){
		}
		
		public String getLastModifiedDate(){
			return lastModifiedDate;
		}
		
	}

     /*
      * Inner class
      * keeps the data of the competencies
      */
        public class Competency {
                
                String currentUserId = userInfo.getUserId();
                CompetencyGroupMember__c competency;

                double rating;
         		String ratingReview; 
                double weight;
				
				String ratingShow;
				
                CompetencyReview__c review;
                List<CompetencyReview__c> history;
                PerformanceReview__c performance;
         		String userProfile;

                public Competency(CompetencyGroupMember__c c, PerformanceReview__c p){
                        competency = c;
                        performance = p;
                }

			     public void setUserProfile(String profile){
			         userProfile = profile;    
			     }

                public CompetencyGroupMember__c getCompetency(){
                        return competency;
                }

                public void setCompetency(CompetencyGroupMember__c c){
                        competency = c;
                }

               public String getRatingReview(){
               		if(((performance.PreviousStatus__c == 'Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
						||((performance.PreviousStatus__c == '2nd Level Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
						||((performance.Status__c == '3rd Party Assessment') && (performance.PCOMM__c == userInfo.getUserId()))){
							return '-';
					}
		             if (rating != null) return String.valueOf(rating);
		             if (review == null)  return '-';
		             if (review.Rating__c == null) return '-';
		
					 if (review.Rating__c.intValue() == 0)
					 {
					 	return '-';
					 }
		             return String.valueOf(review.Rating__c.intValue());
		         }
		
		         public void setRating(double r){
		             if(review != null){
		                 if(r != null){
		                     review.Rating__c = r;
		                 }
		             }                    
		         }
		
		         public Integer getRating(){
		             if(review == null) return 0;
		             if(review.Rating__c == null) return 0;
	
		             return review.Rating__c.intValue();
		         }


                public double getWeight(){
                        return weight;
                }

                public void setWeight(double w){
                        weight = w;
                }

                public CompetencyReview__c getReview() {
                    return review;
                }

                public void setReview(CompetencyReview__c m) {
                    review = m;
                }

                public List<CompetencyReviewDate> getHistoryFormatted() {
                	
                	List<CompetencyReviewDate> result = new List<CompetencyReviewDate>();
                	
                	for (CompetencyReview__c c : history) {
                		result.add(new CompetencyReviewDate(c));
                	}
                	
                    return result;
                }

                public List<CompetencyReview__c> getHistory() {
                    return history;
                }

                public void setHistory(List<CompetencyReview__c> h) {

                    history = new List<CompetencyReview__c>();

                    // process history
                    for(CompetencyReview__c c: h) {

                        if(c.Reviewer__c == performance.Manager__c) {
		                 	if (!(UserInfo.getUserId().equals(performance.Employee__c) 
		                 	&& !(performance.Status__c.equals('Complete') 
		                 	|| performance.Status__c.equals('Employee Approval')))) {
		                            rating = c.Rating__c;
		                 	}
                        }
						
						//Do not show all the comments in 3rd party assessment
		                 if(((performance.PreviousStatus__c == 'Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
							||((performance.PreviousStatus__c == '2nd Level Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
							||((performance.Status__c == '3rd Party Assessment') && (performance.PCOMM__c == userInfo.getUserId()))){
								if(c.Reviewer__c == performance.Employee__c){
									history.add(c);
								}
						 }
						 else{
	                        // Do not show any comments in teh comment list that are empty
	                        if(c.Comment__c != null &&
	                            c.Comment__c != '')
	                            history.add(c);
						 }
                    }
                }
                
                public boolean getShowHistory(){
                    return (history.size() > 0);    
                }
                
                public String getCurrentUserId(){
                    return currentUserId;
                }
                
                public void setCurrentUserId(String id){
                    currentUserId = id;
                }
                
                public boolean getIsComplete() {
                    if(currentUserId.equals(performance.Employee__c) && performance.Status__c.equals('Employee Self Assessment'))
                    {
                       	
				     	 if (review != null && ((review.Comment__c == '') || (review.Comment__c == null)))
				     	 	return false;
				     	 else
                         	return true;
		     	 	}

                    if((currentUserId.equals(performance.Manager__c) || (userProfile == Label.System_Administrator_label)) &&
                       performance.Status__c.equals('Manager Assessment') &&
                       review.Rating__c != null){
                       	
				     	 if (currentUserId.equals(performance.Manager__c) && review != null && ((review.Comment__c == '') || (review.Comment__c == null) || review.Rating__c == 0 ))
				     	 {
				     	 	return false;
				     	 }
				     	 else
				     	 {
				     	 	if (((review.Comment__c == '') || (review.Comment__c == null) || review.Rating__c == 0 ))
				     	 	{
                         		return false;
				     	 	}
				     	 	else
				     	 	{
				     	 		return true;
				     	 	}
				     	 }
		     	 	}

                    if (currentUserId.equals(performance.SecondManager__c) &&
                        performance.Status__c.equals('2nd Level Manager Assessment')){
				     	 if (review != null && ((review.Comment__c == '') || (review.Comment__c == null)))
				     	 	return false;
				     	 else
                         	return true;
		     	 	}

		            if (performance.ThirdPartyReviewer__c != null){
	                    if (currentUserId.equals(performance.ThirdPartyReviewer__c) &&
	                        performance.Status__c.equals('3rd Party Assessment')){
					     	 if (review != null && ((review.Comment__c == '') || (review.Comment__c == null)))
					     	 	return false;
					     	 else
	                         	return true;
			     	 	}
		            }

                    return false;
                }
        	}

	/*
	 * Inner class: utility class to obtain data with sharing rules
     */
        public with sharing class CompetencyUtil {

        	// returns the performance review if the logged user is allowed to access it
            public PerformanceReview__c getPerformanceReviewWithSharing(Id id) {

                List<PerformanceReview__c> performanceReview = [Select  Id,
                                                                        Name,
                                                                        Employee__c,
                                                                        Manager__c,
                                                                        SecondManager__c,
                                                                        PCOMM__c,
                                                                        ThirdPartyReviewer__c,
                                                                        CompetencyGroup__r.Name,
                                                                        PerformanceReviewPeriod__r.name,
                                                                        V2MOM__c,
                                                                        V2MOM__r.Vision__c,
                                                                        PreviousStatus__c,
                                                                        Status__c,
                                                                        ReviewFormTemplate__c 
                                                                From PerformanceReview__c
                                                                Where Id=:id];

                    if(performanceReview.size() == 0) return null;

                    return performanceReview.get(0);
            }
            
            
        	// returns the data of the competencies if the logged user is allowed to access it
            public Map<Id, CompetencyReview__c> getCompetencyReviewWithSharingMap(PerformanceReview__c p, List<CompetencyGroupMember__c> c) {
            
                Map<Id, CompetencyReview__c> tempmap = new Map<Id, CompetencyReview__c>();
                   
                   for(CompetencyReview__c cr: [SELECT Rating__c,
                                                       Comment__c,
                                                       LastModifiedDate,
                                                       CompetencyGroupMember__r.Competency__c,
                                                       CompetencyGroupMember__c,
                                                       Reviewer__r.Name, Reviewer__c
                                            FROM CompetencyReview__c
                                            WHERE PerformanceReview__c =: p.id
                                            AND Reviewer__c =: UserInfo.getUserId()
                                            AND CompetencyGroupMember__c IN: c]) {
                            
                              tempmap.put(cr.CompetencyGroupMember__r.Competency__c, cr);
                   }
                   
                   return tempmap;
            }
            
        	// returns the data of the competency comments if the logged user is allowed to access it
            public List<CompetencyReview__c> getCompetencyReviewListWithSharing(PerformanceReview__c p, List<CompetencyGroupMember__c> c) {
				
				 if ((p.Status__c ==  '3rd Party Assessment' && p.Manager__c == Userinfo.getUserId())
				 	|| p.Status__c ==  '3rd Party Assessment' && p.SecondManager__c == Userinfo.getUserId() )
				 {
				 	  return [Select Id, Name,
                                    Comment__c,
                                    Reviewer__c,
                                    Reviewer__r.Name,
                                    Rating__c,
                                    CompetencyGroupMember__c,                   
                                    PerformanceReview__c,
                                    CreatedBy.Name,
                                    LastModifiedDate,
                                    CreatedDate
                               From CompetencyReview__c
                               Where PerformanceReview__c =: p.Id
                               AND CompetencyGroupMember__c IN: c
                               ORDER BY CreatedDate ASC];	
				 }
                 else
                 {
	                 return [Select Id, Name,
	                                    Comment__c,
	                                    Reviewer__c,
	                                    Reviewer__r.Name,
	                                    Rating__c,
	                                    CompetencyGroupMember__c,                   
	                                    PerformanceReview__c,
	                                    CreatedBy.Name,
	                                    LastModifiedDate,
	                                    CreatedDate
	                               From CompetencyReview__c
	                               Where PerformanceReview__c =: p.Id
	                               AND CompetencyGroupMember__c IN: c
	                               and Locked__c = true
	                               ORDER BY CreatedDate ASC];
                 }
            }           
       }
       
}