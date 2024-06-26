public class ESBPAdminControllerStatusFilter {

	
public static List<PerformanceReview__c> getPerformanceReviewsOrderByName(String lastId, String lastName, Boolean isNext, String pcommFilter, String prpFilter, String effectiveDate, String status, Integer max, Boolean descByName)
{	
	List<PerformanceReview__c> listTest;
		System.debug('Enter KKKK ' + descByName);
		
		if (! descByName){
			if (pcommFilter.equals('0') && prpFilter.equals('0') && effectiveDate.equals('All') && status.equals('All') ) {
				
				System.debug('OOOO');
				listTest = [Select   pr.id,
						             pr.Name,
						             pr.Employee__c,
						             pr.Employee__r.Name,
						             pr.Employee__r.Title,
						             pr.Employee__r.Manager__r.Name,
						             pr.Employee__r.ReviewManager__r.Name,
						             pr.Employee__r.Department,
						             pr.Employee__r.Division,
						             pr.Employee__r.employeeNumber,
						             pr.manager__c,
						             pr.SecondManager__c,
						             pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
						             pr.ReviewRating__r.CalculatedRating__c,
						             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
						             pr.Status__c
				             From PerformanceReview__c pr
				             Where  (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
						ORDER BY pr.Employee__r.Name, Id 
						LIMIT :max];
						
						return listTest;
			}

			if (!pcommFilter.equals('0') &&  ! prpFilter.equals('0') &&  ! effectiveDate.equals('All')   && ! status.equals('All') ) {
				
				listTest = [Select   pr.id,
						             pr.Name,
						             pr.Employee__c,
						             pr.Employee__r.Name,
						             pr.Employee__r.Title,
						             pr.Employee__r.Manager__r.Name,
						             pr.Employee__r.ReviewManager__r.Name,
						             pr.Employee__r.Department,
						             pr.Employee__r.Division,
						             pr.Employee__r.employeeNumber,
						             pr.manager__c,
						             pr.SecondManager__c,
						             pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
						             pr.ReviewRating__r.CalculatedRating__c,
						             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
						             pr.Status__c
				             From PerformanceReview__c pr Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND Status__c =: status and
				               (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
						ORDER BY pr.Employee__r.Name, Id 
						LIMIT :max];
						
						return listTest;
			}
			
			if ((!pcommFilter.equals('0')) && (!prpFilter.equals('0')) && ! effectiveDate.equals('All')) {

				listTest =  [Select  pr.id,
						             pr.Name,
						             pr.Employee__c,
						             pr.Employee__r.Name,
						             pr.Employee__r.Title,
						             pr.Employee__r.Manager__r.Name,
						             pr.Employee__r.ReviewManager__r.Name,
						             pr.Employee__r.Department,
						             pr.Employee__r.Division,
						             pr.Employee__r.employeeNumber,
						             pr.manager__c,
						             pr.SecondManager__c,
						             pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
						             pr.ReviewRating__r.CalculatedRating__c,
						             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
						             pr.Status__c
				             From PerformanceReview__c pr
				             Where PerformanceReviewPeriod__c =: prpFilter AND  PCOMM__c =: pcommFilter AND
				              pr.V2MOM__r.Effective_Date__c =: effectiveDate AND 
				             (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
							ORDER BY pr.Employee__r.Name, Id 
							LIMIT :max];
							
				
				
				
				return listTest;
			}
			
			if ((!pcommFilter.equals('0')) && (!prpFilter.equals('0')) && ! status.equals('All')) {

				listTest =  [Select  pr.id,
						             pr.Name,
						             pr.Employee__c,
						             pr.Employee__r.Name,
						             pr.Employee__r.Title,
						             pr.Employee__r.Manager__r.Name,
						             pr.Employee__r.ReviewManager__r.Name,
						             pr.Employee__r.Department,
						             pr.Employee__r.Division,
						             pr.Employee__r.employeeNumber,
						             pr.manager__c,
						             pr.SecondManager__c,
						             pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
						             pr.ReviewRating__r.CalculatedRating__c,
						             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
						             pr.Status__c
				             From PerformanceReview__c pr
				             Where PerformanceReviewPeriod__c =: prpFilter AND  PCOMM__c =: pcommFilter AND
				              Status__c =: status AND 
				             (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
							ORDER BY pr.Employee__r.Name, Id 
							LIMIT :max];
							
				
				
				
				return listTest;
			}
			
			if ( !prpFilter.equals('0') && ! effectiveDate.equals('All') && ! status.equals('All')) 
			{
				listTest =  [Select  pr.id,
						             pr.Name,
						             pr.Employee__c,
						             pr.Employee__r.Name,
						             pr.Employee__r.Title,
						             pr.Employee__r.Manager__r.Name,
						             pr.Employee__r.ReviewManager__r.Name,
						             pr.Employee__r.Department,
						             pr.Employee__r.Division,
						             pr.Employee__r.employeeNumber,
						             pr.manager__c,
						             pr.SecondManager__c,
						             pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
						             pr.ReviewRating__r.CalculatedRating__c,
						             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
						             pr.Status__c
				             From PerformanceReview__c pr
				             Where PerformanceReviewPeriod__c =: prpFilter AND  pr.V2MOM__r.Effective_Date__c =: effectiveDate AND
				              Status__c =: status AND 
				             (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
							ORDER BY pr.Employee__r.Name, Id 
							LIMIT :max];
							
				
				
				
				return listTest;
			}
			
			if ( !pcommFilter.equals('0') && ! effectiveDate.equals('All') && ! status.equals('All')) 
			{
				listTest =  [Select  pr.id,
						             pr.Name,
						             pr.Employee__c,
						             pr.Employee__r.Name,
						             pr.Employee__r.Title,
						             pr.Employee__r.Manager__r.Name,
						             pr.Employee__r.ReviewManager__r.Name,
						             pr.Employee__r.Department,
						             pr.Employee__r.Division,
						             pr.Employee__r.employeeNumber,
						             pr.manager__c,
						             pr.SecondManager__c,
						             pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
						             pr.ReviewRating__r.CalculatedRating__c,
						             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
						             pr.Status__c
				             From PerformanceReview__c pr
				             Where PCOMM__c =: pcommFilter AND  pr.V2MOM__r.Effective_Date__c =: effectiveDate AND
				              Status__c =: status AND 
				             (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
							ORDER BY pr.Employee__r.Name, Id 
							LIMIT :max];
							
				
				
				
				return listTest;
			}
			
			if ((!pcommFilter.equals('0')) && (!prpFilter.equals('0'))) {

				listTest =  [Select  pr.id,
						             pr.Name,
						             pr.Employee__c,
						             pr.Employee__r.Name,
						             pr.Employee__r.Title,
						             pr.Employee__r.Manager__r.Name,
						             pr.Employee__r.ReviewManager__r.Name,
						             pr.Employee__r.Department,
						             pr.Employee__r.Division,
						             pr.Employee__r.employeeNumber,
						             pr.manager__c,
						             pr.SecondManager__c,
						             pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
						             pr.ReviewRating__r.CalculatedRating__c,
						             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
						             pr.Status__c
				             From PerformanceReview__c pr
				             Where PerformanceReviewPeriod__c =: prpFilter AND  PCOMM__c =: pcommFilter AND
				             (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
							ORDER BY pr.Employee__r.Name, Id 
							LIMIT :max];
							
				
				
				
				return listTest;
			}

			if ((!pcommFilter.equals('0')) && (!effectiveDate.equals('All'))) {

				listTest =  [Select  pr.id,
						             pr.Name,
						             pr.Employee__c,
						             pr.Employee__r.Name,
						             pr.Employee__r.Title,
						             pr.Employee__r.Manager__r.Name,
						             pr.Employee__r.ReviewManager__r.Name,
						             pr.Employee__r.Department,
						             pr.Employee__r.Division,
						             pr.Employee__r.employeeNumber,
						             pr.manager__c,
						             pr.SecondManager__c,
						             pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
						             pr.ReviewRating__r.CalculatedRating__c,
						             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
						             pr.Status__c
				             From PerformanceReview__c pr
				             Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND  PCOMM__c =: pcommFilter AND
				             (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
							ORDER BY pr.Employee__r.Name, Id 
							LIMIT :max];
							
				
				
				
				return listTest;
			}
			
			if ((!pcommFilter.equals('0')) && (!status.equals('All'))) {

				listTest =  [Select  pr.id,
						             pr.Name,
						             pr.Employee__c,
						             pr.Employee__r.Name,
						             pr.Employee__r.Title,
						             pr.Employee__r.Manager__r.Name,
						             pr.Employee__r.ReviewManager__r.Name,
						             pr.Employee__r.Department,
						             pr.Employee__r.Division,
						             pr.Employee__r.employeeNumber,
						             pr.manager__c,
						             pr.SecondManager__c,
						             pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
						             pr.ReviewRating__r.CalculatedRating__c,
						             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
						             pr.Status__c
				             From PerformanceReview__c pr
				             Where Status__c =: status AND  PCOMM__c =: pcommFilter AND
				             (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
							ORDER BY pr.Employee__r.Name, Id 
							LIMIT :max];
							
				
				
				
				return listTest;
			}
			if ((!effectiveDate.equals('All')) && (!prpFilter.equals('0'))) {

				listTest =  [Select  pr.id,
						             pr.Name,
						             pr.Employee__c,
						             pr.Employee__r.Name,
						             pr.Employee__r.Title,
						             pr.Employee__r.Manager__r.Name,
						             pr.Employee__r.ReviewManager__r.Name,
						             pr.Employee__r.Department,
						             pr.Employee__r.Division,
						             pr.Employee__r.employeeNumber,
						             pr.manager__c,
						             pr.SecondManager__c,
						             pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
						             pr.ReviewRating__r.CalculatedRating__c,
						             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
						             pr.Status__c
				             From PerformanceReview__c pr
				             Where PerformanceReviewPeriod__c =: prpFilter AND  pr.V2MOM__r.Effective_Date__c =: effectiveDate AND
				             (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
							ORDER BY pr.Employee__r.Name, Id 
							LIMIT :max];
							
				
				
				
				return listTest;
			}
			
			if ((!status.equals('All')) && (!prpFilter.equals('0'))) {

				listTest =  [Select  pr.id,
						             pr.Name,
						             pr.Employee__c,
						             pr.Employee__r.Name,
						             pr.Employee__r.Title,
						             pr.Employee__r.Manager__r.Name,
						             pr.Employee__r.ReviewManager__r.Name,
						             pr.Employee__r.Department,
						             pr.Employee__r.Division,
						             pr.Employee__r.employeeNumber,
						             pr.manager__c,
						             pr.SecondManager__c,
						             pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
						             pr.ReviewRating__r.CalculatedRating__c,
						             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
						             pr.Status__c
				             From PerformanceReview__c pr
				             Where PerformanceReviewPeriod__c =: prpFilter AND  Status__c =: status AND
				             (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
							ORDER BY pr.Employee__r.Name, Id 
							LIMIT :max];
							
				
				
				
				return listTest;
			}
			
			
			if ((!status.equals('All')) && (!effectiveDate.equals('All'))) {

				listTest =  [Select  pr.id,
						             pr.Name,
						             pr.Employee__c,
						             pr.Employee__r.Name,
						             pr.Employee__r.Title,
						             pr.Employee__r.Manager__r.Name,
						             pr.Employee__r.ReviewManager__r.Name,
						             pr.Employee__r.Department,
						             pr.Employee__r.Division,
						             pr.Employee__r.employeeNumber,
						             pr.manager__c,
						             pr.SecondManager__c,
						             pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
						             pr.ReviewRating__r.CalculatedRating__c,
						             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
						             pr.Status__c
				             From PerformanceReview__c pr
				             Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND  Status__c =: status AND
				             (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
							ORDER BY pr.Employee__r.Name, Id 
							LIMIT :max];
							
				
				
				
				return listTest;
			}
			
			if (! pcommFilter.equals('0')) {
				listTest =  [Select  pr.id,
						             pr.Name,
						             pr.Employee__c,
						             pr.Employee__r.Name,
						             pr.Employee__r.Title,
						             pr.Employee__r.Manager__r.Name,
						             pr.Employee__r.ReviewManager__r.Name,
						             pr.Employee__r.Department,
						             pr.Employee__r.Division,
						             pr.Employee__r.employeeNumber,
						             pr.manager__c,
						             pr.SecondManager__c,
						             pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
						             pr.ReviewRating__r.CalculatedRating__c,
						             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
						             pr.Status__c
				             From PerformanceReview__c pr
				             Where PCOMM__c =: pcommFilter AND (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
							ORDER BY pr.Employee__r.Name, Id 
							LIMIT :max];
							
					return listTest;
			}

			if (! prpFilter.equals('0')) {
				listTest =  [Select  pr.id,
						             pr.Name,
						             pr.Employee__c,
						             pr.Employee__r.Name,
						             pr.Employee__r.Title,
						             pr.Employee__r.Manager__r.Name,
						             pr.Employee__r.ReviewManager__r.Name,
						             pr.Employee__r.Department,
						             pr.Employee__r.Division,
						             pr.Employee__r.employeeNumber,
						             pr.manager__c,
						             pr.SecondManager__c,
						             pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
						             pr.ReviewRating__r.CalculatedRating__c,
						             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
						             pr.Status__c
				             From PerformanceReview__c pr
				             Where PerformanceReviewPeriod__c =: prpFilter AND (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
							ORDER BY pr.Employee__r.Name, Id 
							LIMIT :max];
							
				return listTest;
			}
			
			if (! effectiveDate.equals('All')) {
				listTest =  [Select  pr.id,
						             pr.Name,
						             pr.Employee__c,
						             pr.Employee__r.Name,
						             pr.Employee__r.Title,
						             pr.Employee__r.Manager__r.Name,
						             pr.Employee__r.ReviewManager__r.Name,
						             pr.Employee__r.Department,
						             pr.Employee__r.Division,
						             pr.Employee__r.employeeNumber,
						             pr.manager__c,
						             pr.SecondManager__c,
						             pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
						             pr.ReviewRating__r.CalculatedRating__c,
						             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
						             pr.Status__c
				             From PerformanceReview__c pr
				             Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
							ORDER BY pr.Employee__r.Name, Id 
							LIMIT :max];
							
				return listTest;
			}
			
			if (! status.equals('All')) {
				listTest =  [Select  pr.id,
						             pr.Name,
						             pr.Employee__c,
						             pr.Employee__r.Name,
						             pr.Employee__r.Title,
						             pr.Employee__r.Manager__r.Name,
						             pr.Employee__r.ReviewManager__r.Name,
						             pr.Employee__r.Department,
						             pr.Employee__r.Division,
						             pr.Employee__r.employeeNumber,
						             pr.manager__c,
						             pr.SecondManager__c,
						             pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
						             pr.ReviewRating__r.CalculatedRating__c,
						             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
						             pr.Status__c
				             From PerformanceReview__c pr
				             Where Status__c =: status AND (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
							ORDER BY pr.Employee__r.Name, Id 
							LIMIT :max];
							
				return listTest;
			}
		}
		else{
			
			System.debug('TTTTT ' + System.currentPageReference().getParameters().get('lastName') == '' );
			if (System.currentPageReference().getParameters().get('lastName') == ''){
				if (pcommFilter.equals('0') && prpFilter.equals('0')  && effectiveDate.equals('All') && status.equals('All') ) {
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.Division,
							             pr.Employee__r.employeeNumber,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			 	 pr.V2MOM__r.V2MOM_Type__c,
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
							             pr.Status__c
					             From PerformanceReview__c pr
					             Where (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
					return listTest;
				}
				
				if (! pcommFilter.equals('0') &&  ! prpFilter.equals('0')  && ! effectiveDate.equals('All') && ! status.equals('All') ) {
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.Division,
							             pr.Employee__r.employeeNumber,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			 	 pr.V2MOM__r.V2MOM_Type__c,
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
							             pr.Status__c
					             From PerformanceReview__c pr Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND Status__c =: status AND
					              (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
					return listTest;
				}
				
				if ((!pcommFilter.equals('0')) && (!prpFilter.equals('0')) && ! effectiveDate.equals('All'))  {					   		
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.Division,
							             pr.Employee__r.employeeNumber,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			 	 pr.V2MOM__r.V2MOM_Type__c,
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
							             pr.Status__c
					             From PerformanceReview__c pr
					             Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter AND
					             pr.V2MOM__r.Effective_Date__c =: effectiveDate 
					             AND   (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
								
						return listTest;
				}
				
				if ((!pcommFilter.equals('0')) && (!prpFilter.equals('0')) && ! status.equals('All'))  {					   		
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.Division,
							             pr.Employee__r.employeeNumber,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			 	 pr.V2MOM__r.V2MOM_Type__c,
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
							             pr.Status__c
					             From PerformanceReview__c pr
					             Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter AND
					             Status__c =: status 
					             AND   (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
								
						return listTest;
				}
				
				if ((!effectiveDate.equals('All')) && (!prpFilter.equals('0')) && ! status.equals('All'))  {					   		
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.Division,
							             pr.Employee__r.employeeNumber,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			 	 pr.V2MOM__r.V2MOM_Type__c,
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
							             pr.Status__c
					             From PerformanceReview__c pr
					             Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PerformanceReviewPeriod__c =: prpFilter AND
					             Status__c =: status 
					             AND   (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
								
						return listTest;
				}
				
				if ((!effectiveDate.equals('All')) && (!pcommFilter.equals('0')) && ! status.equals('All'))  {					   		
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.Division,
							             pr.Employee__r.employeeNumber,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			 	 pr.V2MOM__r.V2MOM_Type__c,
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
							             pr.Status__c
					             From PerformanceReview__c pr
					             Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PCOMM__c =: pcommFilter AND
					             Status__c =: status 
					             AND   (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
								
						return listTest;
				}
				
				if ((!pcommFilter.equals('0')) && (!prpFilter.equals('0')))  {					   		
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.Division,
							             pr.Employee__r.employeeNumber,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			 	 pr.V2MOM__r.V2MOM_Type__c,
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
							             pr.Status__c
					             From PerformanceReview__c pr
					             Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
					             AND   (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
								
						return listTest;
				}

				if ((!pcommFilter.equals('0')) && (!effectiveDate.equals('All')))  {					   		
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.Division,
							             pr.Employee__r.employeeNumber,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			 	 pr.V2MOM__r.V2MOM_Type__c,
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
							             pr.Status__c
					             From PerformanceReview__c pr
					             Where PCOMM__c =: pcommFilter AND pr.V2MOM__r.Effective_Date__c =: effectiveDate
					             AND   (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
								
						return listTest;
				}
				
				if ((!pcommFilter.equals('0')) && (!status.equals('All')))  {					   		
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.Division,
							             pr.Employee__r.employeeNumber,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			 	 pr.V2MOM__r.V2MOM_Type__c,
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
							             pr.Status__c
					             From PerformanceReview__c pr
					             Where PCOMM__c =: pcommFilter AND Status__c =: status
					             AND   (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
								
						return listTest;
				}
				
				if ((!effectiveDate.equals('All')) && (!prpFilter.equals('0')))  {					   		
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.Division,
							             pr.Employee__r.employeeNumber,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			 	 pr.V2MOM__r.V2MOM_Type__c,
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
							             pr.Status__c
					             From PerformanceReview__c pr
					             Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PerformanceReviewPeriod__c =: prpFilter
					             AND   (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
								
						return listTest;
				}
				
				if ((!status.equals('All')) && (!prpFilter.equals('0')))  {					   		
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.Division,
							             pr.Employee__r.employeeNumber,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			 	 pr.V2MOM__r.V2MOM_Type__c,
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
							             pr.Status__c
					             From PerformanceReview__c pr
					             Where Status__c =: status AND PerformanceReviewPeriod__c =: prpFilter
					             AND   (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
								
						return listTest;
				}
				
				if ((!effectiveDate.equals('All')) && (!status.equals('All')))  {					   		
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.employeeNumber,
							             pr.Employee__r.Division,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			 	 pr.V2MOM__r.V2MOM_Type__c,	
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
							             pr.Status__c
					             From PerformanceReview__c pr
					             Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND Status__c =: status
					             AND   (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
								
						return listTest;
				}
				
				if (! pcommFilter.equals('0')) {
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.Division,
							             pr.Employee__r.employeeNumber,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			 	 pr.V2MOM__r.V2MOM_Type__c,
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
							             pr.Status__c
					             From PerformanceReview__c pr
					             Where PCOMM__c =: pcommFilter AND  (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
					
					return listTest;
				}

				if (! prpFilter.equals('0')) {
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.Division,
							             pr.Employee__r.employeeNumber,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			 	 pr.V2MOM__r.V2MOM_Type__c,
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
							             pr.Status__c
					             From PerformanceReview__c pr
					             Where PerformanceReviewPeriod__c =: prpFilter AND  (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
					return listTest;
				}
				
				if (! effectiveDate.equals('All')) {
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.Division,
							             pr.Employee__r.employeeNumber,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			 	 pr.V2MOM__r.V2MOM_Type__c,
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
							             pr.Status__c
					             From PerformanceReview__c pr
					             Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND  (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
					return listTest;
				}
				
				if (! status.equals('All')) {
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.Division,
							             pr.Employee__r.employeeNumber,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			 	 pr.V2MOM__r.V2MOM_Type__c,
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
							             pr.Status__c
					             From PerformanceReview__c pr
					             Where Status__c =: status AND  (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
					return listTest;
				}
			}
			else{
				
				System.debug('Enter CVCV');
				if (pcommFilter.equals('0') && prpFilter.equals('0') && effectiveDate.equals('All') && status.equals('All') ){					
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.Division,
							             pr.Employee__r.employeeNumber,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			 	 pr.V2MOM__r.V2MOM_Type__c,
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
							             pr.Status__c
					             From PerformanceReview__c pr
					             Where  (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
								
								System.debug('Goooo to return');
					return listTest;
				}
				
				if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! effectiveDate.equals('All') && ! status.equals('All')  ){					
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.Division,
							             pr.Employee__r.employeeNumber,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			 	 pr.V2MOM__r.V2MOM_Type__c,
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
							             pr.Status__c
					             From PerformanceReview__c pr Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND Status__c =: status AND
					              (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
								
								System.debug('Goooo to return');
					return listTest;
				}
				
				if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! effectiveDate.equals('All') ){					
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.Division,
							             pr.Employee__r.employeeNumber,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			 	 pr.V2MOM__r.V2MOM_Type__c,
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
							             pr.Status__c
					             From PerformanceReview__c pr Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND
					              (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
								
								System.debug('Goooo to return');
					return listTest;
				}

				if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! status.equals('All') ){					
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.Division,
							             pr.Employee__r.employeeNumber,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			 	 pr.V2MOM__r.V2MOM_Type__c,
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
							             pr.Status__c
					             From PerformanceReview__c pr Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND Status__c =: status AND
					              (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
								
								System.debug('Goooo to return');
					return listTest;
				}
				
				if (! effectiveDate.equals('All') && ! prpFilter.equals('0') && ! status.equals('All') ){					
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.Division,
							             pr.Employee__r.employeeNumber,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			 	 pr.V2MOM__r.V2MOM_Type__c,
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
							             pr.Status__c
					             From PerformanceReview__c pr Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PerformanceReviewPeriod__c =: prpFilter
				             AND Status__c =: status AND
					              (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
								
								System.debug('Goooo to return');
					return listTest;
				}
				
				if (! effectiveDate.equals('All') && ! pcommFilter.equals('0') && ! status.equals('All') ){					
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.Division,
							             pr.Employee__r.employeeNumber,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			 	 pr.V2MOM__r.V2MOM_Type__c,
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
							             pr.Status__c
					             From PerformanceReview__c pr Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PCOMM__c =: pcommFilter
				             AND Status__c =: status AND
					              (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
								
								System.debug('Goooo to return');
					return listTest;
				}
				if ((!pcommFilter.equals('0')) && (!prpFilter.equals('0')))	{
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.Division,
							             pr.Employee__r.employeeNumber,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			 	 pr.V2MOM__r.V2MOM_Type__c,
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
							             pr.Status__c
					             From PerformanceReview__c pr
					             Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter AND
					             (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
								
					 return listTest;
				}


				if ((!pcommFilter.equals('0')) && (!effectiveDate.equals('All')))	{
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.Division,
							             pr.Employee__r.employeeNumber,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			 	 pr.V2MOM__r.V2MOM_Type__c,
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							             pr.Status__c
					             From PerformanceReview__c pr
					             Where PCOMM__c =: pcommFilter AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND
					             (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
								
					 return listTest;
				}
				
				if ((!pcommFilter.equals('0')) && (!status.equals('All')))	{
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.Division,
							             pr.Employee__r.employeeNumber,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			 	 pr.V2MOM__r.V2MOM_Type__c,
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
							             pr.Status__c
					             From PerformanceReview__c pr
					             Where PCOMM__c =: pcommFilter AND Status__c =: status AND
					             (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
								
					 return listTest;
				}
				if ((!effectiveDate.equals('All')) && (!prpFilter.equals('0')))	{
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.Division,
							             pr.Employee__r.employeeNumber,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			 	 pr.V2MOM__r.V2MOM_Type__c,
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							             pr.Status__c
					             From PerformanceReview__c pr
					             Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PerformanceReviewPeriod__c =: prpFilter AND
					             (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
								
					 return listTest;
				}
				
				if ((!status.equals('All')) && (!prpFilter.equals('0')))	{
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.Division,
							             pr.Employee__r.employeeNumber,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			 	 pr.V2MOM__r.V2MOM_Type__c,
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c,
							             pr.Status__c
					             From PerformanceReview__c pr
					             Where Status__c =: status AND PerformanceReviewPeriod__c =: prpFilter AND
					             (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
								
					 return listTest;
				}
				
				if ((!effectiveDate.equals('All')) && (!status.equals('All')))	{
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.Division,
							             pr.Employee__r.employeeNumber,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			 	 pr.V2MOM__r.V2MOM_Type__c,
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							             pr.Status__c
					             From PerformanceReview__c pr
					             Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND Status__c =: status AND
					             (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
								
					 return listTest;
				}
				if (! pcommFilter.equals('0')) {
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.Division,
							             pr.Employee__r.employeeNumber,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			 	 pr.V2MOM__r.V2MOM_Type__c,
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							             pr.Status__c
					             From PerformanceReview__c pr
					             Where PCOMM__c =: pcommFilter AND (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
								
						return listTest;
				}

				if (! prpFilter.equals('0')) {
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.Division,
							             pr.Employee__r.employeeNumber,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			 	 pr.V2MOM__r.V2MOM_Type__c,
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							             pr.Status__c
					             From PerformanceReview__c pr
					             Where PerformanceReviewPeriod__c =: prpFilter AND
					             (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
								
					return listTest;
				}			
				
				if (! effectiveDate.equals('All')) {
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.Division,
							             pr.Employee__r.employeeNumber,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			     pr.V2MOM__r.V2MOM_Type__c,
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							             pr.Status__c
					             From PerformanceReview__c pr
					             Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND
					             (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
								
					return listTest;
				}			
				
				if (! status.equals('All')) {
					listTest =  [Select  pr.id,
							             pr.Name,
							             pr.Employee__c,
							             pr.Employee__r.Name,
							             pr.Employee__r.Title,
							             pr.Employee__r.Manager__r.Name,
							             pr.Employee__r.ReviewManager__r.Name,
							             pr.Employee__r.Department,
							             pr.Employee__r.Division,
							             pr.Employee__r.employeeNumber,
							             pr.manager__c,
							             pr.SecondManager__c,
							             pr.V2MOM__c,
				         			 	 pr.V2MOM__r.V2MOM_Type__c,
							             pr.ReviewRating__r.CalculatedRating__c,
							             pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							             pr.Status__c
					             From PerformanceReview__c pr
					             Where Status__c =: status AND
					             (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName')))
								ORDER BY pr.Employee__r.Name DESC, Id DESC 
								LIMIT :max];
								
					return listTest;
				}				 	 	 	   
			}
		}

		return listTest;
		
    }
}