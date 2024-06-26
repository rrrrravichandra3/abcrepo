public class EXBPAdminControllerUtilName {

	
	public static List<PerformanceReview__c> getPerformanceReviewsPrevOrderByStatus(Integer max, Boolean isNext, Boolean descByName, String pcommFilter,String prpFilter, String effectiveDate, Boolean desccByStatus, String status) 
	{
		if (! desccByStatus){
			System.debug('Enter byyy');
			if (pcommFilter.equals('0') && prpFilter.equals('0') && effectiveDate.equals('All') && status.equals('All')) {
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name,
						         pr.Employee__r.ReviewManager__r.Name,
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
						         pr.Status__c
				         From PerformanceReview__c pr
				         Where  (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
				        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
				        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
				ORDER BY pr.Status__c DESC, Id DESC 
				LIMIT :max];
			}

			if (! pcommFilter.equals('0') && prpFilter.equals('0') && ! effectiveDate.equals('All') && ! status.equals('All')) {
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name,
						         pr.Employee__r.ReviewManager__r.Name,
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
						         pr.Status__c
				         From PerformanceReview__c pr
				         Where  (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
				        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
				        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
				ORDER BY pr.Status__c DESC, Id DESC 
				LIMIT :max];
			}
			
				if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! effectiveDate.equals('All')) {
		 		return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name,
						         pr.Employee__r.ReviewManager__r.Name,
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
						         pr.Status__c
				         From PerformanceReview__c pr Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND
				               (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
				        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
				        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
				ORDER BY pr.Status__c DESC, Id DESC 
				LIMIT :max];
			}
			
			if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! status.equals('All')) {
		 		return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name,
						         pr.Employee__r.ReviewManager__r.Name,
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
						         pr.Status__c
				         From PerformanceReview__c pr Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND Status__c =: status AND
				               (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
				        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
				        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
				ORDER BY pr.Status__c DESC, Id DESC 
				LIMIT :max];
			}
			
			if (! effectiveDate.equals('All') && ! prpFilter.equals('0') && ! status.equals('All')) {
		 		return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name,
						         pr.Employee__r.ReviewManager__r.Name,
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
						         pr.Status__c
				         From PerformanceReview__c pr Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PerformanceReviewPeriod__c =: prpFilter	AND Status__c =: status AND
				               (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
				        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
				        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
				ORDER BY pr.Status__c DESC, Id DESC 
				LIMIT :max];
			}
			
			if (! effectiveDate.equals('All') && ! pcommFilter.equals('0') && ! status.equals('All')) {
		 		return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name,
						         pr.Employee__r.ReviewManager__r.Name,
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
						         pr.Status__c
				         From PerformanceReview__c pr Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PCOMM__c =: pcommFilter AND Status__c =: status AND
				               (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
				        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
				        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
				ORDER BY pr.Status__c DESC, Id DESC 
				LIMIT :max];
			}
			
			if ((!pcommFilter.equals('0')) && (!prpFilter.equals('0'))) {
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name,
						         pr.Employee__r.ReviewManager__r.Name,
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
						         pr.Status__c
				         From PerformanceReview__c pr
				         Where PerformanceReviewPeriod__c =: prpFilter AND PCOMM__c =: pcommFilter  AND
				         (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
				        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
				        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
				ORDER BY pr.Status__c DESC, Id DESC 
				LIMIT :max];
			}
			
			if ((!pcommFilter.equals('0')) && (!effectiveDate.equals('All'))) {
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name,
						         pr.Employee__r.ReviewManager__r.Name,
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
						         pr.Status__c
				         From PerformanceReview__c pr
				         Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PCOMM__c =: pcommFilter  AND
				         (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
				        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
				        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
				ORDER BY pr.Status__c DESC, Id DESC 
				LIMIT :max];
			}
			
			if ((!pcommFilter.equals('0')) && (!status.equals('All'))) {
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name,
						         pr.Employee__r.ReviewManager__r.Name,
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
						         pr.Status__c
				         From PerformanceReview__c pr
				         Where Status__c =: status AND PCOMM__c =: pcommFilter  AND
				         (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
				        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
				        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
				ORDER BY pr.Status__c DESC, Id DESC 
				LIMIT :max];
			}
			
			if ((!effectiveDate.equals('All')) && (!prpFilter.equals('0'))) {
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name,
						         pr.Employee__r.ReviewManager__r.Name,
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
						         pr.Status__c
				         From PerformanceReview__c pr
				         Where PerformanceReviewPeriod__c =: prpFilter AND pr.V2MOM__r.Effective_Date__c =: effectiveDate  AND
				         (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
				        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
				        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
				ORDER BY pr.Status__c DESC, Id DESC 
				LIMIT :max];
			}
			
			if ((!status.equals('All')) && (!prpFilter.equals('0'))) {
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name,
						         pr.Employee__r.ReviewManager__r.Name,
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
						         pr.Status__c
				         From PerformanceReview__c pr
				         Where Status__c =: status AND PerformanceReviewPeriod__c =: prpFilter  AND
				         (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
				        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
				        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
				ORDER BY pr.Status__c DESC, Id DESC 
				LIMIT :max];
			}
			
			if ((!status.equals('All')) && (!effectiveDate.equals('All'))) {
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name,
						         pr.Employee__r.ReviewManager__r.Name,
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
						         pr.Status__c
				         From PerformanceReview__c pr
				         Where Status__c =: status AND pr.V2MOM__r.Effective_Date__c =: effectiveDate  AND
				         (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
				        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
				        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
				ORDER BY pr.Status__c DESC, Id DESC 
				LIMIT :max];
			}

			if (! pcommFilter.equals('0')){
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name,
						         pr.Employee__r.ReviewManager__r.Name,
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
						         pr.Status__c
				         From PerformanceReview__c pr
				         Where  PCOMM__c =: pcommFilter  AND
				         (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
				        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
				        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
						ORDER BY pr.Status__c DESC, Id DESC 
						LIMIT :max];
			}

			if (! prpFilter.equals('0')){
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name,
							         pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where PerformanceReviewPeriod__c =: prpFilter AND
					         PerformanceReviewPeriod__c =: prpFilter  AND
					         (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
					        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c DESC, Id DESC 
							LIMIT :max];	
			}
			
			if (! effectiveDate.equals('All')){
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name,
							         pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND
					         (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
					        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c DESC, Id DESC 
							LIMIT :max];	
			}
			
			if (! status.equals('All')){
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name,
							         pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where Status__c =: status AND
					         (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
					        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c DESC, Id DESC 
							LIMIT :max];	
			}
			
		
		}
		else{
			System.debug('Enterrlpos');
			if (System.currentPageReference().getParameters().get('firstStatus') == '')	{
				if (pcommFilter.equals('0') && prpFilter.equals('0') && effectiveDate.equals('All') && status.equals('All') ){

					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name,
							         pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
					        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];
				}

				if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! effectiveDate.equals('All') && ! status.equals('All') ){

					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name,
							         pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department, 
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					           Where PerformanceReviewPeriod__c =: prpFilter AND PCOMM__c =: pcommFilter  AND
					             pr.V2MOM__r.Effective_Date__c =: effectiveDate AND Status__c =: Status AND
					            (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
					        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];
				}
				
					if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! effectiveDate.equals('All') ){

					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name,
							         pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND
				              (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
					        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];
				}
				
				if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! status.equals('All') ){

					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name,
							         pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND Status__c =: status AND
				              (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
					        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];
				}
				
				if (! effectiveDate.equals('All') && ! prpFilter.equals('0') && ! status.equals('All') ){

					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name,
							         pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PerformanceReviewPeriod__c =: prpFilter
				             AND Status__c =: status AND
				              (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
					        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];
				}
				
				if (! effectiveDate.equals('All') && ! pcommFilter.equals('0') && ! status.equals('All') ){

					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name,
							         pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PCOMM__c =: pcommFilter
				             AND Status__c =: status AND
				              (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
					        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];
				} 
				
				if ((!pcommFilter.equals('0')) && (!prpFilter.equals('0')))	{
					return [Select  pr.id,
							        pr.Name,
							        pr.Employee__c,
							        pr.Employee__r.Name,
							        pr.Employee__r.Title,
							        pr.Employee__r.Manager__r.Name,
							        pr.Employee__r.ReviewManager__r.Name,
							        pr.Employee__r.Department,
							        pr.Employee__r.Division,
							        pr.manager__c,
							        pr.SecondManager__c,
							        pr.ReviewRating__r.CalculatedRating__c,
							        pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							        pr.Status__c
					        From PerformanceReview__c pr
					        Where PerformanceReviewPeriod__c =: prpFilter AND PCOMM__c =: pcommFilter  AND
					        (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
					        		OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];

				}

				if ((!pcommFilter.equals('0')) && (!effectiveDate.equals('All')))	{
					return [Select  pr.id,
							        pr.Name,
							        pr.Employee__c,
							        pr.Employee__r.Name,
							        pr.Employee__r.Title,
							        pr.Employee__r.Manager__r.Name,
							        pr.Employee__r.ReviewManager__r.Name,
							        pr.Employee__r.Department,
							        pr.Employee__r.Division,
							        pr.manager__c,
							        pr.SecondManager__c,
							        pr.ReviewRating__r.CalculatedRating__c,
							        pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							        pr.Status__c
					        From PerformanceReview__c pr
					        Where pr.V2MOM__r.Effective_Date__c =: prpFilter AND PCOMM__c =: pcommFilter  AND
					        (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
					        		OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];

				}
				
				if ((!pcommFilter.equals('0')) && (!status.equals('All')))	{
					return [Select  pr.id,
							        pr.Name,
							        pr.Employee__c,
							        pr.Employee__r.Name,
							        pr.Employee__r.Title,
							        pr.Employee__r.Manager__r.Name,
							        pr.Employee__r.ReviewManager__r.Name,
							        pr.Employee__r.Department,
							        pr.Employee__r.Division,
							        pr.manager__c,
							        pr.SecondManager__c,
							        pr.ReviewRating__r.CalculatedRating__c,
							        pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							        pr.Status__c
					        From PerformanceReview__c pr
					        Where Status__c =: status AND PCOMM__c =: pcommFilter  AND
					        (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
					        		OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];

				}
				if ((!effectiveDate.equals('All')) && (!prpFilter.equals('0')))	{
					return [Select  pr.id,
							        pr.Name,
							        pr.Employee__c,
							        pr.Employee__r.Name,
							        pr.Employee__r.Title,
							        pr.Employee__r.Manager__r.Name,
							        pr.Employee__r.ReviewManager__r.Name,
							        pr.Employee__r.Department,
							        pr.Employee__r.Division,
							        pr.manager__c,
							        pr.SecondManager__c,
							        pr.ReviewRating__r.CalculatedRating__c,
							        pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							        pr.Status__c
					        From PerformanceReview__c pr
					        Where PerformanceReviewPeriod__c =: prpFilter AND pr.V2MOM__r.Effective_Date__c =: effectiveDate  AND
					        (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
					        		OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];

				}
				
				if ((!status.equals('All')) && (!prpFilter.equals('0')))	{
					return [Select  pr.id,
							        pr.Name,
							        pr.Employee__c,
							        pr.Employee__r.Name,
							        pr.Employee__r.Title,
							        pr.Employee__r.Manager__r.Name,
							        pr.Employee__r.ReviewManager__r.Name,
							        pr.Employee__r.Department,
							        pr.Employee__r.Division,
							        pr.manager__c,
							        pr.SecondManager__c,
							        pr.ReviewRating__r.CalculatedRating__c,
							        pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							        pr.Status__c
					        From PerformanceReview__c pr
					        Where PerformanceReviewPeriod__c =: prpFilter AND Status__c =: status  AND
					        (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
					        		OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];

				}
				
				if ((!status.equals('All')) && (!effectiveDate.equals('All')))	{
					return [Select  pr.id,
							        pr.Name,
							        pr.Employee__c,
							        pr.Employee__r.Name,
							        pr.Employee__r.Title,
							        pr.Employee__r.Manager__r.Name,
							        pr.Employee__r.ReviewManager__r.Name,
							        pr.Employee__r.Department,
							        pr.Employee__r.Division,
							        pr.manager__c,
							        pr.SecondManager__c,
							        pr.ReviewRating__r.CalculatedRating__c,
							        pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							        pr.Status__c
					        From PerformanceReview__c pr
					        Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND Status__c =: status  AND
					        (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
					        		OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];

				}
				if (! pcommFilter.equals('0')) {
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name,
							         pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where PCOMM__c =: pcommFilter  AND
					         (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
					        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];
				}

				if (! prpFilter.equals('0')){
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name,
							         pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where PerformanceReviewPeriod__c =: prpFilter  AND
					         (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
					        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];						
				}
				
				if (! effectiveDate.equals('All')){
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name,
							         pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where pr.V2MOM__r.Effective_Date__c =: effectiveDate  AND
					         (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
					        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];						
				}
				
				if (! status.equals('All')){
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name,
							         pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where Status__c =: status  AND
					         (pr.Status__c < : System.currentPageReference().getParameters().get('firstStatus')
					        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];						
				}
				
			
			}
			else{
				System.debug('121412');
				if (pcommFilter.equals('0') && prpFilter.equals('0') && effectiveDate.equals('All') && status.equals('All') ) {				
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name,
							         pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where  (pr.Status__c > : System.currentPageReference().getParameters().get('firstStatus')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];
				}

				if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! effectiveDate.equals('All') && ! status.equals('All') ) {				
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name,
							         pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					          Where PerformanceReviewPeriod__c =: prpFilter AND PCOMM__c =: pcommFilter  AND 
					          pr.V2MOM__r.Effective_Date__c =: effectiveDate AND Status__c =: status AND
					            (pr.Status__c > : System.currentPageReference().getParameters().get('firstStatus')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];
				}
				
				if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! effectiveDate.equals('All') ) {				
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name,
							         pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND
				               (pr.Status__c > : System.currentPageReference().getParameters().get('firstStatus')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];
				}
				
				if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! status.equals('All') ) {				
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name,
							         pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND Status__c =: status AND
				               (pr.Status__c > : System.currentPageReference().getParameters().get('firstStatus')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];
				}
				
				if (! effectiveDate.equals('All') && ! prpFilter.equals('0') && ! status.equals('All') ) {				
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name,
							         pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PerformanceReviewPeriod__c =: prpFilter
				             AND Status__c =: status AND
				               (pr.Status__c > : System.currentPageReference().getParameters().get('firstStatus')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];
				}
				
				if (! effectiveDate.equals('All') && ! pcommFilter.equals('All') && ! status.equals('All') ) {				
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name,
							         pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PCOMM__c =: pcommFilter
				             AND Status__c =: status AND
				               (pr.Status__c > : System.currentPageReference().getParameters().get('firstStatus')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];
				}
				
				if ((!pcommFilter.equals('0')) && (!prpFilter.equals('0'))) {
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name,
							         pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where PerformanceReviewPeriod__c =: prpFilter AND PCOMM__c =: pcommFilter  AND
					         (pr.Status__c > : System.currentPageReference().getParameters().get('firstStatus')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];
				}
		
				if ((!pcommFilter.equals('0')) && (!effectiveDate.equals('All'))) {
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name,
							         pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PCOMM__c =: pcommFilter  AND
					         (pr.Status__c > : System.currentPageReference().getParameters().get('firstStatus')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];
				}
				
				if ((!pcommFilter.equals('0')) && (!status.equals('All'))) {
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name,
							         pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where Status__c =: status AND PCOMM__c =: pcommFilter  AND
					         (pr.Status__c > : System.currentPageReference().getParameters().get('firstStatus')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];
				}
				if ((!effectiveDate.equals('All')) && (!prpFilter.equals('0'))) {
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name,
							         pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where PerformanceReviewPeriod__c =: prpFilter AND pr.V2MOM__r.Effective_Date__c =: effectiveDate  AND
					         (pr.Status__c > : System.currentPageReference().getParameters().get('firstStatus')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];
				}
				
				if ((!status.equals('All')) && (!prpFilter.equals('0'))) {
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name,
							         pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where PerformanceReviewPeriod__c =: prpFilter AND Status__c =: status  AND
					         (pr.Status__c > : System.currentPageReference().getParameters().get('firstStatus')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];
				}
				
				if ((!status.equals('All')) && (!effectiveDate.equals('All'))) {
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name,
							         pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND Status__c =: status  AND
					         (pr.Status__c > : System.currentPageReference().getParameters().get('firstStatus')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];
				}
				
				if (! pcommFilter.equals('0')){
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name,
							         pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where PCOMM__c =: pcommFilter  AND
					         (pr.Status__c > : System.currentPageReference().getParameters().get('firstStatus')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];
				}

				if (! prpFilter.equals('0')) {				  	
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name,
							         pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where PerformanceReviewPeriod__c =: prpFilter  AND
					         (pr.Status__c > : System.currentPageReference().getParameters().get('firstStatus')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];
				}
				
				if (! effectiveDate.equals('All')){
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name,
							         pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where pr.V2MOM__r.Effective_Date__c =: effectiveDate  AND
					         (pr.Status__c > : System.currentPageReference().getParameters().get('firstStatus')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];
				}
				
				if (! status.equals('All')){
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name,
							         pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where Status__c =: status  AND
					         (pr.Status__c > : System.currentPageReference().getParameters().get('firstStatus')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('firstStatus')))
							ORDER BY pr.Status__c , Id  
							LIMIT :max];
				}
				
				
			}
		}

		return null;
	
	}
	
}