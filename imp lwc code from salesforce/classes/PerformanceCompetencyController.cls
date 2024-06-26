/*
 * RelEng Perforce/RCS Header - Do not remove!
 * $Author:  $
 * $Change:  $
 * $DateTime:  $
 * $File:  $
 * $Id:   $
 * $Revision:  $
/*
 * this class will take an account and assign it to a user.
 * @author Fabritzio Calvetti
*/
public class PerformanceCompetencyController {
	public CompetencyGroupMember__c competency;
    public double rating;
    public double weight;
    public CompetencyReview__c reviewCom;
    public List<CompetencyReview__c> history;
    public PerformanceReview__c performance;
    
    public PerformanceCompetencyController(CompetencyGroupMember__c c, PerformanceReview__c perf ){
            competency = c;
            performance = perf;
    }
    
    public CompetencyGroupMember__c getCompetency(){
            return competency;
    }
    
    public void setCompetency(CompetencyGroupMember__c c){
            competency = c;
    }
    
    public String getRating(){
    	if(((performance.PreviousStatus__c == 'Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
			||((performance.PreviousStatus__c == '2nd Level Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
			|| ((performance.Status__c == '3rd Party Assessment') && (performance.PCOMM__c == userInfo.getUserId()))){
				return '-';
		}
        if(rating == null) return '-';

        return PAMUtil.getRatingLabel(rating.intValue());
    }	
    	
	public String getRatingShow()
	{
		if(((performance.PreviousStatus__c == 'Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
			||((performance.PreviousStatus__c == '2nd Level Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
			|| ((performance.Status__c == '3rd Party Assessment') && (performance.PCOMM__c == userInfo.getUserId()))){
				return '-';
		}
		if(rating == null) return '-';

		String value = PAMUtil.getRatingLabel(rating.intValue());
		
		if (value == '--None--')
		{
			return '-';
		}
					
        return value ;	
	}			
	
    public void setRating(double r){
            rating = r;
    }
                
    public String getWeight(){
        if (weight == null) return '';

        return (''+weight+'');
    }
                
	public String getWeigthShow(){
	    if (weight == null) return '-';

        return ('' + weight+ '%');
    }    
                            
    public void setWeight(double w){                        
            weight = w;
    }
                
	public List<CompetencyReview__c> getHistory() {
	    return history;
	}
                
    public List<CompetencyReviewDate> getHistoryFormatted() {               	
    	List<CompetencyReviewDate> result = new List<CompetencyReviewDate>();              	
    	for (CompetencyReview__c c : history) {
    		
    		if(((performance.PreviousStatus__c == 'Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
				||((performance.PreviousStatus__c == '2nd Level Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
				|| ((performance.Status__c == '3rd Party Assessment') && (performance.PCOMM__c == userInfo.getUserId()))){
					if(c.Reviewer__c == performance.Employee__c){
						result.add(new CompetencyReviewDate(c));
					}
			 }
			 else{
			 	 // Do not show any comments in the comment list that are empty
                 if(c.Comment__c != null && c.Comment__c != '')
                     result.add(new CompetencyReviewDate(c));
			 }	
    	}          	
        return result;
    }
                
    public void setHistory(List<CompetencyReview__c> l) {
            this.history = l;
    }
     
    
    
    public class CompetencyReviewDate{
		String createdDate;
		String lastModifiedDate;
		String reviewerName;
		CompetencyReview__c competencyReview;	
				
		public CompetencyReviewDate(CompetencyReview__c c){
			createdDate = c.CreatedDate.format();
			lastModifiedDate = c.LastModifiedDate.format();
			reviewerName = c.Reviewer__r.Name;
			competencyReview = c;
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
		
		public String getLastModifiedDate(){
			return lastModifiedDate;
		}		
		public void setCreatedDate(String s){
		}			
	}
}