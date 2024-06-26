public with sharing class PerformanceReviewHistoryController {
	
	public String perfId 
	{ 
		get; 
		set
		{
			perfId = value;
			performanceReviewsHistory = new List<PerformanceReviewHistoryDate>();
			for(PerformanceReview__History ph : [Select p.ParentId, Parent.Name, Parent.CreatedDate, p.OldValue, p.NewValue, p.Field, p.CreatedDate, p.CreatedById, p.CreatedBy.Name From PerformanceReview__History p where ParentId =: perfId and p.Field <> 'EmailComment__c' order by createdDate  ])
			{
				PerformanceReviewHistoryDate prhd = new PerformanceReviewHistoryDate(ph);
				performanceReviewsHistory.add(prhd);
			}
		}
	}
	
	public List<PerformanceReviewHistoryDate> performanceReviewsHistory {get;set;}
	
	
	public PerformanceReviewHistoryController(){
		
	}
	
	
	public class PerformanceReviewHistoryDate{
		PerformanceReview__History performanceReviewHistory;
		String CreatedDate;	
		String status = '';		
		public PerformanceReviewHistoryDate(PerformanceReview__History ph){
			performanceReviewHistory = ph;
			CreatedDate = ph.CreatedDate.format();
		}			
		public PerformanceReview__History getPerformanceReviewHistory(){
			return performanceReviewHistory;
		}			
		
		public String getStatus(){
			if(performanceReviewHistory != null && (performanceReviewHistory.Field == 'Status__c' || performanceReviewHistory.Field == 'Created')){
				String field = performanceReviewHistory.Field;
				if(field == 'Status__c'){
					status = 'Changed Status from ' + performanceReviewHistory.OldValue + ' to ' + performanceReviewHistory.NewValue;
				}
				else{
					status = 'Created';
				}
			}
			return status;
		}
					
		public String getCreatedDate(){
			return createdDate;
		}					
	}
	
}