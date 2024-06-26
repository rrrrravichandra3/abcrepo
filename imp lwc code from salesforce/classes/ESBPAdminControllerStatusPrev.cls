public class ESBPAdminControllerStatusPrev {


public static list<PerformanceReview__c> getPerformanceReviewsOrderByStatus(Integer max, Boolean isNext, Boolean desccByStatus, String pcommFilter, String prpFilter, String effectiveDate, String status){

		String ordered = '';
 
		if (! desccByStatus) {
			if (pcommFilter.equals('0') && prpFilter.equals('0') && effectiveDate.equals('All') && status.equals('All')){
				System.debug('Enter lklkl');
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.Employee__r.employeeNumber,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
						         pr.Status__c
				         From PerformanceReview__c pr
				         Where  (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
				        		 OR (Id >: System.currentPageReference().getParameters().get('lastId')
				        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
						ORDER BY pr.Status__c , Id 
						LIMIT :max];
			}

			if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! effectiveDate.equals('All') && ! status.equals('All')){
				System.debug('Enter lklkl');
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.Employee__r.employeeNumber,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
						         pr.Status__c From
				         PerformanceReview__c pr Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND Status__c =: status AND
				               (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
				        		 OR (Id >: System.currentPageReference().getParameters().get('lastId')
				        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
						ORDER BY pr.Status__c , Id 
						LIMIT :max];
			}
			
			if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! effectiveDate.equals('All')){
				System.debug('Enter lklkl');
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.Employee__r.employeeNumber,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
						         pr.Status__c From
				         PerformanceReview__c pr Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND
				               (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
				        		 OR (Id >: System.currentPageReference().getParameters().get('lastId')
				        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
						ORDER BY pr.Status__c , Id 
						LIMIT :max];
			}
			
			if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! status.equals('All')){
				System.debug('Enter lklkl');
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.Employee__r.employeeNumber,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
						         pr.Status__c From
				         PerformanceReview__c pr Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND Status__c =: status AND
				               (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
				        		 OR (Id >: System.currentPageReference().getParameters().get('lastId')
				        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
						ORDER BY pr.Status__c , Id 
						LIMIT :max];
			}
			
			if (! effectiveDate.equals('All') && ! prpFilter.equals('0') && ! status.equals('All')){
				System.debug('Enter lklkl');
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.Employee__r.employeeNumber,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
						         pr.Status__c From
				         PerformanceReview__c pr Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PerformanceReviewPeriod__c =: prpFilter
				             AND Status__c =: status AND
				               (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
				        		 OR (Id >: System.currentPageReference().getParameters().get('lastId')
				        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
						ORDER BY pr.Status__c , Id 
						LIMIT :max];
			}
			
			if (! effectiveDate.equals('All') && ! pcommFilter.equals('0') && ! status.equals('All')){
				System.debug('Enter lklkl');
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.Employee__r.employeeNumber,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
						         pr.Status__c From
				         PerformanceReview__c pr Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PCOMM__c =: pcommFilter
				             AND Status__c =: status AND
				               (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
				        		 OR (Id >: System.currentPageReference().getParameters().get('lastId')
				        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
						ORDER BY pr.Status__c , Id 
						LIMIT :max];
			}
			
			if ((!pcommFilter.equals('0')) && (!prpFilter.equals('0'))){				
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name, 
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.Employee__r.employeeNumber,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
						         pr.Status__c
				         From PerformanceReview__c pr
				         Where PerformanceReviewPeriod__c =: prpFilter AND PCOMM__c =: pcommFilter AND
				         (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
				        		 OR (Id >: System.currentPageReference().getParameters().get('lastId')
				        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
						ORDER BY pr.Status__c , Id 
						LIMIT :max];				
			}

			if ((!pcommFilter.equals('0')) && (!effectiveDate.equals('All'))){				
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name, 
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.Employee__r.employeeNumber,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
						         pr.Status__c
				         From PerformanceReview__c pr
				         Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PCOMM__c =: pcommFilter AND
				         (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
				        		 OR (Id >: System.currentPageReference().getParameters().get('lastId')
				        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
						ORDER BY pr.Status__c , Id 
						LIMIT :max];				
			}
			
			if ((!pcommFilter.equals('0')) && (!status.equals('All'))){				
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name, 
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.Employee__r.employeeNumber,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
						         pr.Status__c
				         From PerformanceReview__c pr
				         Where Status__c =: status AND PCOMM__c =: pcommFilter AND
				         (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
				        		 OR (Id >: System.currentPageReference().getParameters().get('lastId')
				        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
						ORDER BY pr.Status__c , Id 
						LIMIT :max];				
			}
			
			if ((!effectiveDate.equals('All')) && (!prpFilter.equals('0'))){				
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name, 
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.Employee__r.employeeNumber,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
						         pr.Status__c
				         From PerformanceReview__c pr
				         Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PerformanceReviewPeriod__c =: prpFilter AND
				         (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
				        		 OR (Id >: System.currentPageReference().getParameters().get('lastId')
				        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
						ORDER BY pr.Status__c , Id 
						LIMIT :max];				
			}
			
			if ((!status.equals('All')) && (!prpFilter.equals('0'))){				
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name, 
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.Employee__r.employeeNumber,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
						         pr.Status__c
				         From PerformanceReview__c pr
				         Where Status__c =: status AND PerformanceReviewPeriod__c =: prpFilter AND
				         (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
				        		 OR (Id >: System.currentPageReference().getParameters().get('lastId')
				        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
						ORDER BY pr.Status__c , Id 
						LIMIT :max];				
			}
			
			if ((!status.equals('All')) && (!effectiveDate.equals('All'))){				
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name, 
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.Employee__r.employeeNumber,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
						         pr.Status__c
				         From PerformanceReview__c pr
				         Where Status__c =: status AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND
				         (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
				        		 OR (Id >: System.currentPageReference().getParameters().get('lastId')
				        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
						ORDER BY pr.Status__c , Id 
						LIMIT :max];				
			}
			
			if (! pcommFilter.equals('0')) {
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.Employee__r.employeeNumber,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
						         pr.Status__c
				         From PerformanceReview__c pr
				         Where  PCOMM__c =: pcommFilter AND
				         (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
				        		 OR (Id >: System.currentPageReference().getParameters().get('lastId')
				        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
						ORDER BY pr.Status__c , Id 
						LIMIT :max];	
			}

			if (! prpFilter.equals('0')){			
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.Employee__r.employeeNumber,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
						         pr.Status__c
				         From PerformanceReview__c pr
				         Where PerformanceReviewPeriod__c =: prpFilter  AND
				         (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
				        		 OR (Id >: System.currentPageReference().getParameters().get('lastId')
				        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
						ORDER BY pr.Status__c , Id 
						LIMIT :max];
			}
			
			if (! effectiveDate.equals('All')){			
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.Employee__r.employeeNumber,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
						         pr.Status__c
				         From PerformanceReview__c pr
				         Where pr.V2MOM__r.Effective_Date__c =: effectiveDate  AND
				         (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
				        		 OR (Id >: System.currentPageReference().getParameters().get('lastId')
				        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
						ORDER BY pr.Status__c , Id 
						LIMIT :max];
			}
			
			if (! status.equals('All')){			
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.Employee__r.employeeNumber,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
						         pr.Status__c
				         From PerformanceReview__c pr
				         Where Status__c =: status  AND
				         (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
				        		 OR (Id >: System.currentPageReference().getParameters().get('lastId')
				        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
						ORDER BY pr.Status__c , Id 
						LIMIT :max];
			}
		}
		else{			
			if (System.currentPageReference().getParameters().get('lastStatus') == ''){
				System.debug('22222');
				if (pcommFilter.equals('0') && prpFilter.equals('0') && effectiveDate.equals('All') && status.equals('All') ){	
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.employeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where  (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id > : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];
				}

				if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! effectiveDate.equals('All') && ! status.equals('All') ){	
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.employeeNumber,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c From
					         PerformanceReview__c pr Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND Status__c =: status AND
				               (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id > : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];
				}
				
				if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! effectiveDate.equals('All') ){	
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.employeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c From
					         PerformanceReview__c pr Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND
				               (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id > : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];
				}
				
				if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! status.equals('All') ){	
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.employeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c From
					         PerformanceReview__c pr Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND Status__c =: status AND
				               (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id > : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];
				}
				
				if (! effectiveDate.equals('All') && ! prpFilter.equals('0') && ! status.equals('All') ){	
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.employeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c From
					         PerformanceReview__c pr Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PerformanceReviewPeriod__c =: prpFilter
				             AND Status__c =: status AND
				               (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id > : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];
				}
				
				if (! effectiveDate.equals('All') && ! prpFilter.equals('0') && ! status.equals('All') ){	
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.employeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c From
					         PerformanceReview__c pr Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PerformanceReviewPeriod__c =: prpFilter
				             AND Status__c =: status AND
				               (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id > : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];
				}
				
				
				if (! effectiveDate.equals('All') && ! pcommFilter.equals('0') && ! status.equals('All') ){	
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.employeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c From
					         PerformanceReview__c pr Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PCOMM__c =: pcommFilter
				             AND Status__c =: status AND
				               (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id > : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];
				}
				if ((!pcommFilter.equals('0')) && (!prpFilter.equals('0'))){
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.employeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where PerformanceReviewPeriod__c =: prpFilter AND PCOMM__c =: pcommFilter AND
					         (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id > : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];					
				}

				if ((!pcommFilter.equals('0')) && (!effectiveDate.equals('All'))){
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.employeeNumber,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PCOMM__c =: pcommFilter AND
					         (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id > : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];					
				}
				
				
				if ((!pcommFilter.equals('0')) && (!status.equals('All'))){
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.employeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where Status__c =: status AND PCOMM__c =: pcommFilter AND
					         (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id > : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];					
				}
				
				if ((!effectiveDate.equals('All')) && (!prpFilter.equals('0'))){
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.employeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where PerformanceReviewPeriod__c =: prpFilter AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND
					         (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id > : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];					
				}
				
				if ((!status.equals('All')) && (!prpFilter.equals('0'))){
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.employeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where PerformanceReviewPeriod__c =: prpFilter AND Status__c =: status AND
					         (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id > : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];					
				}
				
				if ((!status.equals('All')) && (!effectiveDate.equals('All'))){
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.employeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND Status__c =: status AND
					         (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id > : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];					
				}
				if (! pcommFilter.equals('0')) {
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.employeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where  PCOMM__c =: pcommFilter AND
					         (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id > : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];
				}

				if (! prpFilter.equals('0')) {
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.employeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where PerformanceReviewPeriod__c =: prpFilter  AND
					         (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id > : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];
				}
				
				if (! effectiveDate.equals('All')) {
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.employeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where pr.V2MOM__r.Effective_Date__c =: effectiveDate  AND
					         (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id > : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];
				}
				
				if (! status.equals('All')) {
					
					System.debug('Gotttoooooo');
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.employeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where Status__c =: status  AND
					         (pr.Status__c > :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id > : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c >= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];
				}
			}
			else {
				
				System.debug('111');
				if (pcommFilter.equals('0') && prpFilter.equals('0') && effectiveDate.equals('All') && status.equals('All') ){
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.employeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where  (pr.Status__c < :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id < : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];
				}

				if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! effectiveDate.equals('All') && ! status.equals('All') ){
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.employeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c From
					        PerformanceReview__c pr Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND Status__c =: status AND
				               (pr.Status__c < :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id < : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];
				}
				
				if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! effectiveDate.equals('All') ){
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.employeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c From
					        PerformanceReview__c pr Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND
				               (pr.Status__c < :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id < : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];
				}
				
				if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! status.equals('All') ){
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.employeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c From
					        PerformanceReview__c pr Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND Status__c =: status AND
				               (pr.Status__c < :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id < : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];
				}
				
				if (! effectiveDate.equals('All') && ! prpFilter.equals('0') && ! status.equals('All') ){
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.employeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c From
					        PerformanceReview__c pr Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PerformanceReviewPeriod__c =: prpFilter
				             AND Status__c =: status AND
				               (pr.Status__c < :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id < : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];
				}
				
				if (! effectiveDate.equals('All') && ! pcommFilter.equals('0') && ! status.equals('All') ){
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.employeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c From
					        PerformanceReview__c pr Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PCOMM__c =: pcommFilter
				             AND Status__c =: status AND
				               (pr.Status__c < :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id < : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];
				}
				
				if ((!pcommFilter.equals('0')) && (!prpFilter.equals('0')))	{
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.employeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where PerformanceReviewPeriod__c =: prpFilter AND PCOMM__c =: pcommFilter AND
					         (pr.Status__c < :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id < : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];
				}
				
				if ((!pcommFilter.equals('0')) && (!effectiveDate.equals('All')))	{
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.employeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PCOMM__c =: pcommFilter AND
					         (pr.Status__c < :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id < : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];
				}

				if ((!pcommFilter.equals('0')) && (!status.equals('All')))	{
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.employeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where Status__c =: status AND PCOMM__c =: pcommFilter AND
					         (pr.Status__c < :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id < : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];
				}
				
				if ((!effectiveDate.equals('All')) && (!prpFilter.equals('0')))	{
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.employeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where PerformanceReviewPeriod__c =: prpFilter AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND
					         (pr.Status__c < :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id < : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];
				}
				
				if ((!status.equals('All')) && (!prpFilter.equals('0')))	{
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.employeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where PerformanceReviewPeriod__c =: prpFilter AND Status__c =: status AND
					         (pr.Status__c < :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id < : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];
				}
				
				if ((!status.equals('All')) && (!effectiveDate.equals('All')))	{
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.employeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND Status__c =: status AND
					         (pr.Status__c < :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id < : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];
				}
				
				if (! pcommFilter.equals('0'))	{
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.employeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where  PCOMM__c =: pcommFilter AND
					         (pr.Status__c < :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id < : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];
				}

				if (! prpFilter.equals('0')){
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.employeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where PerformanceReviewPeriod__c =: prpFilter AND
					         (pr.Status__c < :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id < : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];
				}
				
				if (! effectiveDate.equals('All')){
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.employeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND
					         (pr.Status__c < :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id < : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];
				}
				
				if (! status.equals('All')){
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.employeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c , 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where Status__c =: status AND
					         (pr.Status__c < :  System.currentPageReference().getParameters().get('lastStatus')
					        		 OR (Id < : System.currentPageReference().getParameters().get('lastId')
					        				 AND pr.Status__c <= : System.currentPageReference().getParameters().get('lastStatus') ))
							ORDER BY pr.Status__c DESC , Id DESC
							LIMIT :max];
				}
			}
		}

		return null;
	}
	 

}