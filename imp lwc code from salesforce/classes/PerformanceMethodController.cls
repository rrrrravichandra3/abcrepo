/*
 * RelEng Perforce/RCS Header - Do not remove!
 * $Change:  $
 * $DateTime:  $
 * $File:  $
 * $Id:   $
 * $Revision:  $
/*
 * this class will take an account and assign it to a user.
 * @author Fabritzio Calvetti
*/
public class PerformanceMethodController {
	
	public Method__c method;
    public double rating;
    public double weight;
    public MethodReview__c review;
    public List<MethodReview__c> history;
    public List<Obstacle__c> obstacles;
    public List<Measure__c> metrics;
    public PerformanceReview__c performance;
	
	public PerformanceMethodController(Method__c m, PerformanceReview__c p){
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
    
    public String getRating(){
        
        if(((performance.PreviousStatus__c == 'Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
			||((performance.PreviousStatus__c == '2nd Level Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
			|| ((performance.Status__c == '3rd Party Assessment') && (performance.PCOMM__c == userInfo.getUserId()))){
				return '-';
		}
        if(rating == null) return '-';
        
        if(rating.intValue() == -1)
            	return 'N/A';
            	
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
		
		if(rating.intValue() == -1)
            	return 'N/A';
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
    
    public String getStatus(){
        if (review != null)
        {
              if(review.Status__c == null)
              {
                 return '';        
              }
              else
              {
                 return review.Status__c;           
              } 
        }
        else
        {
            return '';
        }
    }
    
    public void setStatus(String s){
            review.Status__c = s;   
    }
    
    public String getWeight(){
        if(((performance.PreviousStatus__c == 'Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
			||((performance.PreviousStatus__c == '2nd Level Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
			|| ((performance.Status__c == '3rd Party Assessment') && (performance.PCOMM__c == userInfo.getUserId()))){
				return '-';
		}
        if (weight == null) return '-';
        return (''+weight+'');
    }	
    			
	 public String getWeightShow(){
        if(((performance.PreviousStatus__c == 'Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
			||((performance.PreviousStatus__c == '2nd Level Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
			|| ((performance.Status__c == '3rd Party Assessment') && (performance.PCOMM__c == userInfo.getUserId()))){
				return '-';
		}
        if (weight == null) return '-';
        return (''+weight+'%');
    }   
                
    public void setWeight(double w){                        
            weight = w;
    }
    
    public MethodReview__c getReview() {
        return review;
    }
    
    public void setReview(MethodReview__c m) {
        review = m;
    }
    
    public List<MethodReview__c> getHistory() {
        return history;
    }
    		
    public List<MethodReviewDate> getHistoryFormatted() {		        	
    	List<MethodReviewDate> result = new List<MethodReviewDate>();		        	
    	if ((history != null) && (history.size() > 0)){
        	for (MethodReview__c c : history) {
        		//Do not show all the comments in 3rd party assessment
                 if(((performance.PreviousStatus__c == 'Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
					||((performance.PreviousStatus__c == '2nd Level Manager Assessment') && (performance.Status__c == '3rd Party Assessment') && (performance.SecondManager__c == userInfo.getUserId()))
					|| ((performance.Status__c == '3rd Party Assessment') && (performance.PCOMM__c == userInfo.getUserId()))){
						if(c.Reviewer__c == performance.Employee__c){
							result.add(new MethodReviewDate(c));
						}
				 }
				 else{
				 	 // Do not show any comments in the comment list that are empty
	                 if(c.Comment__c != null && c.Comment__c != '')
	                     result.add(new MethodReviewDate(c));
				 }	
        	}
    	} 	
        return result;
    }
    
    public void setHistory(List<MethodReview__c> h) {
        history = h;
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
    
    public class MethodReviewDate{
		String createdDate;
		MethodReview__c methodReview;	
		String lastModifiedDate;
		String reviewerName;
			
		public MethodReviewDate(MethodReview__c c){
			createdDate = c.CreatedDate.format();
			lastModifiedDate = c.LastModifiedDate.format();
			reviewerName = c.Reviewer__r.Name;
			methodReview = c;
		}	
		
		public MethodReview__c getMethodReview(){
			return methodReview;
		}	
			
		public void setMethodReview(MethodReview__c c){
			methodReview = c;
		}	
		
		public String getReviewerName(){
			return reviewerName;
		}
			
		public String getCreatedDate(){
			return createdDate;
		}	
		
		public String getLastModifiedDate(){
			return lastModifiedDate;
		}
			
		public void setCreatedDate(String s){
		}	
	}
}