/*
 * RelEng Perforce/RCS Header - Do not remove!
 * $Author:  $
 * $Change:  $
 * $DateTime:  $
 * $File:  $
 * $Id:  $
 * $Revision:  $
/*
 * this class will take an account and assign it to a user.
 * @author Fabritzio Calvetti
*/

public with sharing class PerformanceSOQLController {
	User currentUser;
	
	public PerformanceSOQLController(){
		
	}
	
	/*
    * Inner Class OverallUtil
    * 
    */
	public void setCurrentUser(User u){
       		currentUser = u;
    }  
    
 	// returns the performance review if the logged user is allowed to access it
    public PerformanceReview__c getPerformanceReviewWithSharing(Id id) {

        List<PerformanceReview__c> performanceReview = [Select  id,name,Employee__c,Employee__r.Name, Manager__c, Manager__r.Name, SecondManager__c, SecondManager__r.Name,  PCOMM__c, PCOMM__r.Name, ThirdPartyReviewer__c,CompetencyGroup__c,CompetencyGroup__r.Name, PerformanceReviewPeriod__c,  PerformanceReviewPeriod__r.name, PerformanceReviewPeriod__r.Effective_Date__c, ReviewFormTemplate__c, ReviewFormTemplate__r.MethodWeight__c, ReviewFormTemplate__r.CompetencyWeight__c,  V2MOM__c, V2MOM__r.V2MOM_Type__c, V2MOM__r.Vision__c, OwnerId, Status__c, PreviousStatus__c, EmailComment__c, ReviewRating__c, ReviewRating__r.OverallRating__c, PremierUser__c   From PerformanceReview__c
                                                        Where Id=:id];  
        if(performanceReview.size() == 0) return null;  
        return performanceReview.get(0);
    }
    
    // returns the comments of the scorecards if the logged user is allowed to access it
    public list<ScorecardSupportComment__c> getScorecardCommentWithSharing(PerformanceReview__c p){
         if ((p.Status__c ==  '3rd Party Assessment' && p.Manager__c == Userinfo.getUserId())
			 	|| p.Status__c ==  '3rd Party Assessment' && p.SecondManager__c == Userinfo.getUserId() )
			 	{
            		return [select  s.Reviewer__r.Name, s.Reviewer__c, s.CommentCS__c, s.CommentRenewals__c, s.CommentSupportInitiatives__c, s.CommentWMCases__c, s.CommentWMSMES__c,  s.CommentWMPA__c, s.CommentWMHC__c, s.CommentSalesImpact__c, s.CommentForecastAccuracy__c,s.CommentTimeOnPlatform__c, s.CommentRenewalExcellence__c, s.CommentOperationalExcellence__c, s.CommentStrategicInitiatives__c, s.CommentCSMSalesImpact__c, s.CreatedDate, s.CommentWMCCP__c, s.CommentWMCAA__c   from ScorecardSupportComment__c s  where  PerformanceReview__c  =: p.Id	order by CreatedDate ASC]; 
			 	}
			 	else
			 	{
			 		return [select  s.Reviewer__r.Name, s.Reviewer__c, s.CommentCS__c, s.CommentRenewals__c, s.CommentSupportInitiatives__c, s.CommentWMCases__c, s.CommentWMSMES__c,  s.CommentWMPA__c, s.CommentWMHC__c, s.CommentSalesImpact__c, s.CommentForecastAccuracy__c,s.CommentTimeOnPlatform__c, s.CommentRenewalExcellence__c,  s.CommentOperationalExcellence__c, s.CommentStrategicInitiatives__c, s.CommentCSMSalesImpact__c, s.CreatedDate, s.CommentWMCCP__c, s.CommentWMCAA__c   from ScorecardSupportComment__c s 
                    where  PerformanceReview__c  =: p.Id
					AND ((Locked__c = true) or (
					((Reviewer__c =: currentUser.Id) and (Reviewer__c =: p.Employee__c) and (PerformanceReview__r.Status__c = 'Employee Self Assessment')) or
					((Reviewer__c =: currentUser.Id) and (Reviewer__c =: p.Manager__c) and (PerformanceReview__r.Status__c = 'Manager Assessment')) or
					((Reviewer__c =: currentUser.Id) and (Reviewer__c =: p.SecondManager__c) and (PerformanceReview__r.Status__c = '2nd Level Manager Assessment')) or
					((Reviewer__c =: currentUser.Id) and (Reviewer__c =: p.ThirdPartyReviewer__c) and (PerformanceReview__r.Status__c = '3rd Party Assessment'))
                    ))
                    order by CreatedDate ASC];	
			 	}         
    }  
          
    // returns the data of the methods if the logged user is allowed to access it
       public Map<Id, MethodReview__c> getMethodReviewsWithSharing(PerformanceReview__c p, List<Method__c> m) {
           Map<Id, MethodReview__c> tempmap = new Map<Id, MethodReview__c>();               
           for(MethodReview__c mr: [SELECT Rating__c, Status__c, Weight__c, LastModifiedDate, Reviewer__c, Reviewer__r.Name, Method__c
                                    FROM MethodReview__c  WHERE PerformanceReview__c =: p.id AND Reviewer__c =: p.Manager__c AND Method__c IN: m order by CreatedDate ASC]) {                       
                 tempmap.put(mr.Method__c, mr);
           }            
           return tempmap;
       }   
                 
        // returns the competencies if the logged user is allowed to access it
       public Map<Id, CompetencyGroup__c> getCompetencyReviewManagerDataWithSharing(PerformanceReview__c p, List<CompetencyGroup__c> m){                              
            Map<Id, CompetencyGroup__c> tempmap = new Map<Id, CompetencyGroup__c>();              
            return tempmap;
       }  
                             
     // returns the comments of the competencies if the logged user is allowed to access it
       public Map<Id, CompetencyReview__c> getCompetencyReviewWithSharingMap(PerformanceReview__c p, List<CompetencyGroupMember__c> c) {               
            Map<Id, CompetencyReview__c> tempmap = new Map<Id, CompetencyReview__c>();               
            for(CompetencyReview__c cr: [SELECT Rating__c, Comment__c, Reviewer__c, Reviewer__r.Name, LastModifiedDate, CompetencyGroupMember__r.Competency__c, CompetencyGroupMember__c    FROM CompetencyReview__c    WHERE PerformanceReview__c =: p.id    AND Reviewer__c =: p.Manager__c   AND CompetencyGroupMember__c IN: c order by CreatedDate ASC]) {
                      tempmap.put(cr.CompetencyGroupMember__r.Competency__c, cr);
            }
               
            return tempmap;
       }    
    
     // returns the comments of the competencies if the logged user is allowed to access it
       public List<CompetencyReview__c> getCompetencyReviewListWithSharing(PerformanceReview__c p, List<CompetencyGroupMember__c> c) {               
           List<CompetencyReview__c> tempmap = new List<CompetencyReview__c>();                  
           	 if ((p.Status__c ==  '3rd Party Assessment' && p.Manager__c == Userinfo.getUserId())
			 	|| p.Status__c ==  '3rd Party Assessment' && p.SecondManager__c == Userinfo.getUserId() )
			 	{
			 		for(CompetencyReview__c cr: [SELECT Rating__c, Comment__c,CompetencyGroupMember__r.Competency__c, CreatedBy.Name, CreatedDate, LastModifiedDate, Reviewer__c, Reviewer__r.Name, CompetencyGroupMember__c FROM CompetencyReview__c WHERE PerformanceReview__c =: p.id AND CompetencyGroupMember__c IN: c   
                                        order by CreatedDate ASC]) {                 
                      tempmap.add(cr);	
			 	}
			}
            else
            {
            	for(CompetencyReview__c cr: [SELECT Rating__c, Comment__c,CompetencyGroupMember__r.Competency__c, CreatedBy.Name, CreatedDate, LastModifiedDate, Reviewer__c, Reviewer__r.Name, CompetencyGroupMember__c  FROM CompetencyReview__c WHERE PerformanceReview__c =: p.id AND CompetencyGroupMember__c IN: c AND ((Locked__c = true) or (
										((Reviewer__c =: currentUser.Id) and (Reviewer__c =: p.Employee__c) and (PerformanceReview__r.Status__c = 'Employee Self Assessment')) or
										((Reviewer__c =: currentUser.Id) and (Reviewer__c =: p.Manager__c) and (PerformanceReview__r.Status__c = 'Manager Assessment')) or
										((Reviewer__c =: currentUser.Id) and (Reviewer__c =: p.SecondManager__c) and (PerformanceReview__r.Status__c = '2nd Level Manager Assessment')) or
										((Reviewer__c =: currentUser.Id) and (Reviewer__c =: p.ThirdPartyReviewer__c) and (PerformanceReview__r.Status__c = '3rd Party Assessment'))
					                    ))
                                        order by CreatedDate ASC]) {                    
                      tempmap.add(cr);		
                   }
            }        
           return tempmap;  
       }        
        
    	// returns the comments of the summary if the logged user is allowed to access it
       public List<AdditionalComment__c> getCommentsHistoryWithSharing(PerformanceReview__c p) { 
       	if (p != null) {
       		if ((p.Status__c ==  '3rd Party Assessment' && p.Manager__c == Userinfo.getUserId())
			 	|| p.Status__c ==  '3rd Party Assessment' && p.SecondManager__c == Userinfo.getUserId() )
			 	{  
                   return [Select id,Comment__c,Reviewer__c,PerformanceReview__c, CreatedBy.Name,CreatedDate,Locked__c,UpdateMethods__c, SuggestionMethods__c, CommentCompetencies__c,SuggestionsCompetencies__c, LastModifiedDate
                           From AdditionalComment__c Where PerformanceReview__c =: p.id ORDER BY CreatedDate ASC];
			 	}
			 	else
			 	{
			 		 return [Select id,Comment__c,Reviewer__c,PerformanceReview__c, CreatedBy.Name,CreatedDate,Locked__c,UpdateMethods__c, SuggestionMethods__c, CommentCompetencies__c,SuggestionsCompetencies__c, LastModifiedDate
                           From AdditionalComment__c
                           Where PerformanceReview__c =: p.id
						   AND ((Locked__c = true) or (
							((Reviewer__c =: currentUser.Id) and (Reviewer__c =: p.Employee__c) and (PerformanceReview__r.Status__c = 'Employee Self Assessment')) or
							((Reviewer__c =: currentUser.Id) and (Reviewer__c =: p.Manager__c) and (PerformanceReview__r.Status__c = 'Manager Assessment')) or
							((Reviewer__c =: currentUser.Id) and (Reviewer__c =: p.SecondManager__c) and (PerformanceReview__r.Status__c = '2nd Level Manager Assessment')) or
							((Reviewer__c =: currentUser.Id) and (Reviewer__c =: p.ThirdPartyReviewer__c) and (PerformanceReview__r.Status__c = '3rd Party Assessment'))
		                    ))
                           ORDER BY CreatedDate ASC];
			 	}
       	}
       	return new List<AdditionalComment__c>();          	
       			
       }
       
       /*
	   * COMPETENCY UTIL METHODS
	   * to retrieve data of competencies with sharing
	   */
       // returns the competency comments with sharing
        public List<CompetencyReview__c> getCompetencyHistoryWithSharing(Id c, PerformanceReview__c p ) {           	            	
                return [Select Id,Name,Comment__c,Reviewer__c, Reviewer__r.Name, Rating__c,PerformanceReview__c,CreatedBy.Name, LastModifiedDate,CreatedDate
                        From CompetencyReview__c Where PerformanceReview__c =: p.id and CompetencyGroupMember__r.Competency__c =: c ORDER BY CreatedDate ASC];
        }
        
        // returns the data of the competencies if the logged user is allowed to access it
        // gets the competency review data with sharing
        public List<CompetencyReview__c> getCompetencyReviewWithSharing(PerformanceReview__c p, CompetencyGroupMember__c c) {
                return [SELECT Rating__c FROM CompetencyReview__c WHERE CompetencyGroupMember__c =:c.Id AND Reviewer__c =: p.Manager__c AND PerformanceReview__c =: p.Id order by CreatedDate ASC];
        }
       /*
	   * Method UTIL METHODS
	   * to retrieve data of methods with sharing
	   */
		
		// gets the method data with sharing
       List<User> profiles = new List<User>();  
       public List<MethodReview__c> getMethodHistoryWithSharing(PerformanceReview__c p, Method__c m ) {
           	 if ((p.Status__c ==  '3rd Party Assessment' && p.Manager__c == Userinfo.getUserId())
			 	|| p.Status__c ==  '3rd Party Assessment' && p.SecondManager__c == Userinfo.getUserId() )
			 	{
	               return [Select Name,CreatedBy.Name,CreatedDate, LastModifiedDate, Method__c,Comment__c,Rating__c,Reviewer__c, Reviewer__r.Name, Status__c,Weight__c
	                       From MethodReview__c Where PerformanceReview__c =: p.id ORDER BY CreatedDate ASC]; 
			 	}
			 	else
			 	{
			 		return [Select Name,CreatedBy.Name,CreatedDate,Method__c, LastModifiedDate, Comment__c,Rating__c,Reviewer__c, Reviewer__r.Name, Status__c,Weight__c
	                       From MethodReview__c Where PerformanceReview__c =: p.id and Method__c =: m.Id
						   AND ((Locked__c = true) or (
							((Reviewer__c =: currentUser.Id) and (Reviewer__c =: p.Employee__c) and (PerformanceReview__r.Status__c = 'Employee Self Assessment')) or
							((Reviewer__c =: currentUser.Id) and (Reviewer__c =: p.Manager__c) and (PerformanceReview__r.Status__c = 'Manager Assessment')) or
							((Reviewer__c =: currentUser.Id) and (Reviewer__c =: p.SecondManager__c) and (PerformanceReview__r.Status__c = '2nd Level Manager Assessment')) or
							((Reviewer__c =: currentUser.Id) and (Reviewer__c =: p.ThirdPartyReviewer__c) and (PerformanceReview__r.Status__c = '3rd Party Assessment'))
		                    ))
	                       ORDER BY CreatedDate ASC]; 
			 	}
       }
	   
	   // gets the method rating with sharing
       public List<MethodReview__c> getMethodReviewRating(PerformanceReview__c p, Method__c m) {
           return [SELECT Rating__c,Weight__c, Reviewer__c, Reviewer__r.Name, Status__c, LastModifiedDate
                   FROM MethodReview__c WHERE PerformanceReview__c =: p.id
                   AND Reviewer__c =: p.Manager__c AND Method__c =: m.id
                   order by CreatedDate ASC];
       }          
       
       // gets the method statuses with sharing
       public List<MethodReview__c> getMethodReviewStatus(PerformanceReview__c p, Method__c m) {
           return [SELECT Status__c,Comment__c, LastModifiedDate, Reviewer__c, Reviewer__r.Name
                   FROM MethodReview__c WHERE PerformanceReview__c =: p.id
                   AND Reviewer__c =: p.Employee__c AND Method__c =: m.id
                   order by CreatedDate ASC];
       }       
      
      // returns the method review data from the employee with sharing
      public Map<Id, MethodReview__c> getPerformanceReviewEmployeeWithSharing(PerformanceReview__c p, List<Method__c> m){
            Map<Id, MethodReview__c> tempmap = new Map<Id, MethodReview__c>();               
             for(MethodReview__c mr: [Select r.Name, r.Method__c, r.CreatedDate, r.CreatedBy.Name, r.LastModifiedDate, r.Reviewer__c, r.Reviewer__r.Name, r.Status__c, r.Rating__c
                                     From MethodReview__c r Where PerformanceReview__c =: p.Id AND r.Reviewer__c =: p.Employee__c
                                     and Method__c IN : m order by CreatedDate ASC]) {                       
                      tempmap.put(mr.Method__c, mr);
           }               
           return tempmap;
       }                    
       
       // returns the method review comments with sharing
       public List<MethodReview__c> getPerformanceReviewCommentWithSharing(PerformanceReview__c p, List<Method__c> m){
            List<MethodReview__c> tempmap = new List<MethodReview__c>();            
            	if ((p.Status__c ==  '3rd Party Assessment' && p.Manager__c == Userinfo.getUserId())
			 	|| p.Status__c ==  '3rd Party Assessment' && p.SecondManager__c == Userinfo.getUserId() )
			 	{
			 		 for(MethodReview__c mr: [Select r.Comment__c, r.CreatedById, r.CreatedBy.Name,r.LastModifiedDate, r.CreatedDate, r.Reviewer__c, r.Reviewer__r.Name, r.Method__c, r.Status__c
                                     		  From MethodReview__c r Where PerformanceReview__c =: p.Id and Method__c IN : m order by CreatedDate ASC]) {                       
                     	tempmap.add(mr);
                     }
			 	}
            	else
            	{
            		 for(MethodReview__c mr: [Select r.Comment__c, r.CreatedById, r.CreatedBy.Name, r.CreatedDate, r.LastModifiedDate, r.Reviewer__c, r.Reviewer__r.Name, r.Method__c, r.Status__c
                                     From MethodReview__c r Where PerformanceReview__c =: p.Id 
                                     and Method__c IN : m
					   				AND ((Locked__c = true) or (
									((Reviewer__c =: currentUser.Id) and (Reviewer__c =: p.Employee__c) and (PerformanceReview__r.Status__c = 'Employee Self Assessment')) or
									((Reviewer__c =: currentUser.Id) and (Reviewer__c =: p.Manager__c) and (PerformanceReview__r.Status__c = 'Manager Assessment')) or
									((Reviewer__c =: currentUser.Id) and (Reviewer__c =: p.SecondManager__c) and (PerformanceReview__r.Status__c = '2nd Level Manager Assessment')) or
									((Reviewer__c =: currentUser.Id) and (Reviewer__c =: p.ThirdPartyReviewer__c) and (PerformanceReview__r.Status__c = '3rd Party Assessment'))
				                    ))
                                     order by CreatedDate ASC]) {
                    
                      tempmap.add(mr);	
            	}
           }            
           return tempmap;
       }                     
       
       // returns the method data with sharing
       public Map<Id, MethodReview__c> getPerformanceReviewDataWithSharing(PerformanceReview__c p, List<Method__c> m){
            Map<Id, MethodReview__c> tempmap = new Map<Id, MethodReview__c>();               
             for(MethodReview__c mr: [Select r.Name, r.Method__c, r.CreatedDate, r.CreatedBy.Name, r.LastModifiedDate, r.Reviewer__c, r.Reviewer__r.Name, r.Weight__c, r.Rating__c, r.Status__c 
                                     From MethodReview__c r Where PerformanceReview__c =: p.Id AND r.Reviewer__c =: p.Manager__c and Method__c IN : m order by CreatedDate ASC]) {                      
                      tempmap.put(mr.Method__c, mr);
           }           
           return tempmap;
       }
}