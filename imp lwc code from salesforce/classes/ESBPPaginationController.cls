public class ESBPPaginationController {
	
	public static Long getNumberOfPages(Integer max, Boolean isNext, Boolean descByName, String pcommFilter, String prpFilter, String effectiveDate, String status){
	
		Integer allPrByFilters;
		
		if (! descByName){
			if (pcommFilter.equals('0') && prpFilter.equals('0') && effectiveDate.equals('All') && status.equals('All') ) {
				
			
					allPrByFilters =  [Select Count() From PerformanceReview__c pr
				             Where  (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName'))) 
						 ];
						
					return allPrByFilters;
			}

			if (!pcommFilter.equals('0') &&  ! prpFilter.equals('0') &&  ! effectiveDate.equals('All')   && ! status.equals('All') ) {
				
				allPrByFilters =  [Select Count() From PerformanceReview__c pr 
					 Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND Status__c =: status and
				               (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName'))) 
						 ];
						
						return allPrByFilters;
			}
			
			if ((!pcommFilter.equals('0')) && (!prpFilter.equals('0')) && ! effectiveDate.equals('All')) {

				allPrByFilters =  [Select Count() From PerformanceReview__c pr 
				             Where PerformanceReviewPeriod__c =: prpFilter AND  PCOMM__c =: pcommFilter AND
				              pr.V2MOM__r.Effective_Date__c =: effectiveDate AND 
				             (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
							 ];
				
				return allPrByFilters; 
			}
			
			if ((!pcommFilter.equals('0')) && (!prpFilter.equals('0')) && ! status.equals('All')) {

				allPrByFilters =  [Select Count() From PerformanceReview__c pr 
				             Where PerformanceReviewPeriod__c =: prpFilter AND  PCOMM__c =: pcommFilter AND
				              Status__c =: status AND 
				             (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
							 ];
							
				return allPrByFilters;
			}
			
			if ( !prpFilter.equals('0') && ! effectiveDate.equals('All') && ! status.equals('All')) 
			{
				allPrByFilters =  [Select Count() From PerformanceReview__c pr 
				             Where PerformanceReviewPeriod__c =: prpFilter AND  pr.V2MOM__r.Effective_Date__c =: effectiveDate AND
				              Status__c =: status AND 
				             (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
							 ];
							
				return allPrByFilters;
			}
			
			if ( !pcommFilter.equals('0') && ! effectiveDate.equals('All') && ! status.equals('All')) 
			{
				allPrByFilters =  [Select Count() From PerformanceReview__c pr 
				             Where PCOMM__c =: pcommFilter AND  pr.V2MOM__r.Effective_Date__c =: effectiveDate AND
				              Status__c =: status AND 
				             (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName'))) 
							 ];
				
				return allPrByFilters;
			}
			
			if ((!pcommFilter.equals('0')) && (!prpFilter.equals('0'))) {

				allPrByFilters =  [Select Count() From PerformanceReview__c pr 
				             Where PerformanceReviewPeriod__c =: prpFilter AND  PCOMM__c =: pcommFilter AND
				             (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
							
							 ];
				
				return allPrByFilters;
			}

			if ((!pcommFilter.equals('0')) && (!effectiveDate.equals('All'))) {

				allPrByFilters =  [Select Count() From PerformanceReview__c pr 
				             Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND  PCOMM__c =: pcommFilter AND
				             (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
							
							 ];
							
				return allPrByFilters;
			}
			
			if ((!pcommFilter.equals('0')) && (!status.equals('All'))) {

				allPrByFilters =  [Select Count() From PerformanceReview__c pr 
				             Where Status__c =: status AND  PCOMM__c =: pcommFilter AND
				             (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
							
							 ];
							
				return allPrByFilters;
			}
			if ((!effectiveDate.equals('All')) && (!prpFilter.equals('0'))) {

				allPrByFilters =  [Select Count() From PerformanceReview__c pr 
				             Where PerformanceReviewPeriod__c =: prpFilter AND  pr.V2MOM__r.Effective_Date__c =: effectiveDate AND
				             (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
							
							 ];
							
				return allPrByFilters;
			}
			
			if ((!status.equals('All')) && (!prpFilter.equals('0'))) {

				allPrByFilters =  [Select Count() From PerformanceReview__c pr 
				             Where PerformanceReviewPeriod__c =: prpFilter AND  Status__c =: status AND
				             (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
							
							 ];
							
				return allPrByFilters;
			}
			
			
			if ((!status.equals('All')) && (!effectiveDate.equals('All'))) {

				allPrByFilters =  [Select Count() From PerformanceReview__c pr 
				             Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND  Status__c =: status AND
				             (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
							
							 ];
							
				return allPrByFilters;
			}
			
			if (! pcommFilter.equals('0')) {
				allPrByFilters =  [Select Count() From PerformanceReview__c pr 
				             Where PCOMM__c =: pcommFilter AND (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
							
							 ];
							
				return allPrByFilters;
			}

			if (! prpFilter.equals('0')) {
				allPrByFilters =  [Select Count() From PerformanceReview__c pr 
				             Where PerformanceReviewPeriod__c =: prpFilter AND (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
							
							 ];
							
				return allPrByFilters;
			}
			
			if (! effectiveDate.equals('All')) {
				allPrByFilters =  [Select Count() From PerformanceReview__c pr 
				             Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
							
							 ];
							
				return allPrByFilters;
			}
			
			if (! status.equals('All')) {
				allPrByFilters =  [Select Count() From PerformanceReview__c pr 
				             Where Status__c =: status AND (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
				            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
				            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
							
							 ];
							
				return allPrByFilters;
			}
		}
		else{
			
			System.debug('TTTTT ' + System.currentPageReference().getParameters().get('lastName') == '' );
			if (System.currentPageReference().getParameters().get('lastName') == ''){
				if (pcommFilter.equals('0') && prpFilter.equals('0')  && effectiveDate.equals('All') && status.equals('All') ) {
					allPrByFilters =  [Select Count() From PerformanceReview__c pr 
					             Where (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								 
								 ];
					return allPrByFilters;
				}
				
				if (! pcommFilter.equals('0') &&  ! prpFilter.equals('0')  && ! effectiveDate.equals('All') && ! status.equals('All') ) {
					allPrByFilters =  [Select Count() From PerformanceReview__c pr 
						 Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND Status__c =: status AND
					              (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								
								 ];
					return allPrByFilters;
				}
				
				if ((!pcommFilter.equals('0')) && (!prpFilter.equals('0')) && ! effectiveDate.equals('All'))  {					   		
					allPrByFilters =  [Select Count() From PerformanceReview__c pr 
					             Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter AND
					             pr.V2MOM__r.Effective_Date__c =: effectiveDate 
					             AND   (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								
								 ];
								
						return allPrByFilters;
				}
				
				if ((!pcommFilter.equals('0')) && (!prpFilter.equals('0')) && ! status.equals('All'))  {					   		
					allPrByFilters =  [Select Count() From PerformanceReview__c pr 
					             Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter AND
					             Status__c =: status 
					             AND   (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								 
								 ];
								
						return allPrByFilters;
				}
				
				if ((!effectiveDate.equals('All')) && (!prpFilter.equals('0')) && ! status.equals('All'))  {					   		
					allPrByFilters =  [Select Count() From PerformanceReview__c pr 
					             Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PerformanceReviewPeriod__c =: prpFilter AND
					             Status__c =: status 
					             AND   (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								 
								 ];
								
						return allPrByFilters;
				}
				
				if ((!effectiveDate.equals('All')) && (!pcommFilter.equals('0')) && ! status.equals('All'))  {					   		
					allPrByFilters =  [Select Count() From PerformanceReview__c pr 
					             Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PCOMM__c =: pcommFilter AND
					             Status__c =: status 
					             AND   (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								
								 ];
								
					return allPrByFilters;
				}
				
				if ((!pcommFilter.equals('0')) && (!prpFilter.equals('0')))  {					   		
					allPrByFilters =  [Select Count() From PerformanceReview__c pr 
					             Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
					             AND   (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								 
								 ];
								
					return allPrByFilters;
				}

				if ((!pcommFilter.equals('0')) && (!effectiveDate.equals('All')))  {					   		
					allPrByFilters =  [Select Count() From PerformanceReview__c pr 
					             Where PCOMM__c =: pcommFilter AND pr.V2MOM__r.Effective_Date__c =: effectiveDate
					             AND   (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								 
								 ];
								
					return allPrByFilters;
				}
				
				if ((!pcommFilter.equals('0')) && (!status.equals('All')))  {					   		
					allPrByFilters =  [Select Count() From PerformanceReview__c pr 
					             Where PCOMM__c =: pcommFilter AND Status__c =: status
					             AND   (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								
								 ];
								
					return allPrByFilters;
				}
				
				if ((!effectiveDate.equals('All')) && (!prpFilter.equals('0')))  {					   		
					allPrByFilters =  [Select Count() From PerformanceReview__c pr 
					             Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PerformanceReviewPeriod__c =: prpFilter
					             AND   (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								 
								 ];
								
						return allPrByFilters;
				}
				
				if ((!status.equals('All')) && (!prpFilter.equals('0')))  {					   		
					allPrByFilters =  [Select Count() From PerformanceReview__c pr 
					             Where Status__c =: status AND PerformanceReviewPeriod__c =: prpFilter
					             AND   (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								 ];
								
						return allPrByFilters;
				}
				
				if ((!effectiveDate.equals('All')) && (!status.equals('All')))  {					   		
					allPrByFilters =  [Select Count() From PerformanceReview__c pr 
					             Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND Status__c =: status
					             AND   (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								 ];
								
						return allPrByFilters;
				}
				
				if (! pcommFilter.equals('0')) {
					allPrByFilters =  [Select Count() From PerformanceReview__c pr 
					             Where PCOMM__c =: pcommFilter AND  (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								 ];
					
					return allPrByFilters;
				}

				if (! prpFilter.equals('0')) {
					allPrByFilters =  [Select Count() From PerformanceReview__c pr 
					             Where PerformanceReviewPeriod__c =: prpFilter AND  (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								 ];
					return allPrByFilters;
				}
				
				if (! effectiveDate.equals('All')) {
					allPrByFilters =  [Select Count() From PerformanceReview__c pr 
					             Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND  (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								 ];
					return allPrByFilters;
				}
				
				if (! status.equals('All')) {
					allPrByFilters =  [Select Count() From PerformanceReview__c pr 
					             Where Status__c =: status AND  (pr.Employee__r.Name > : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id >: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('lastName')))
								 ];
					return allPrByFilters;
				}
			}
			else{
				if (pcommFilter.equals('0') && prpFilter.equals('0') && effectiveDate.equals('All') && status.equals('All') ){					
					allPrByFilters =  [Select Count() From PerformanceReview__c pr 
					             Where  (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName'))) 
								 ];
								
								System.debug('Goooo to return');
					return allPrByFilters;
				}
				
				if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! effectiveDate.equals('All') && ! status.equals('All')  ){					
					allPrByFilters =  [Select Count() From PerformanceReview__c pr 
						 Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND Status__c =: status AND
					              (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName')))
								 ];
								
								System.debug('Goooo to return');
					return allPrByFilters;
				}
				
				if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! effectiveDate.equals('All') ){					
					allPrByFilters =  [Select Count() From PerformanceReview__c pr  
						 Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND
					              (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName')))
								
								 ];
								
								System.debug('Goooo to return');
					return allPrByFilters;
				}

				if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! status.equals('All') ){					
					allPrByFilters =  [Select Count() From PerformanceReview__c pr  
						 Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND Status__c =: status AND
					              (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName')))
								 ];
								
								System.debug('Goooo to return');
					return allPrByFilters;
				}
				
				if (! effectiveDate.equals('All') && ! prpFilter.equals('0') && ! status.equals('All') ){					
					allPrByFilters =  [Select Count() From PerformanceReview__c pr  
						 Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PerformanceReviewPeriod__c =: prpFilter
				             AND Status__c =: status AND
					              (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName')))
								 ];
								
								System.debug('Goooo to return');
					return allPrByFilters;
				}
				
				if (! effectiveDate.equals('All') && ! pcommFilter.equals('0') && ! status.equals('All') ){					
					allPrByFilters =  [Select Count() From PerformanceReview__c pr  
							 Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PCOMM__c =: pcommFilter
				             AND Status__c =: status AND
					              (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName')))
								 ];
								
								System.debug('Goooo to return');
					return allPrByFilters;
				}
				if ((!pcommFilter.equals('0')) && (!prpFilter.equals('0')))	{
					allPrByFilters =  [Select Count() From PerformanceReview__c pr 
					             Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter AND
					             (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName')))
								
								 ];
								
					 return allPrByFilters;
				}


				if ((!pcommFilter.equals('0')) && (!effectiveDate.equals('All')))	{
					allPrByFilters =  [Select Count() From PerformanceReview__c pr 
					             Where PCOMM__c =: pcommFilter AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND
					             (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName')))
						
								 ];
								
					 return allPrByFilters;
				}
				
				if ((!pcommFilter.equals('0')) && (!status.equals('All')))	{
					allPrByFilters =  [Select Count() From PerformanceReview__c pr 
					             Where PCOMM__c =: pcommFilter AND Status__c =: status AND
					             (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName')))
								
								 ];
								
					 return allPrByFilters;
				}
				if ((!effectiveDate.equals('All')) && (!prpFilter.equals('0')))	{
					allPrByFilters =  [Select Count() From PerformanceReview__c pr 
					             Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PerformanceReviewPeriod__c =: prpFilter AND
					             (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName')))
								
								 ];
								
					 return allPrByFilters;
				}
				
				if ((!status.equals('All')) && (!prpFilter.equals('0')))	{
					allPrByFilters =  [Select Count() From PerformanceReview__c pr 
					             Where Status__c =: status AND PerformanceReviewPeriod__c =: prpFilter AND
					             (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName')))
								
								 ];
								
					 return allPrByFilters;
				}
				
				if ((!effectiveDate.equals('All')) && (!status.equals('All')))	{
					allPrByFilters =  [Select Count() From PerformanceReview__c pr 
					             Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND Status__c =: status AND
					             (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName')))
								
								 ];
								
					 return allPrByFilters;
				}
				if (! pcommFilter.equals('0')) {
					allPrByFilters =  [Select Count() From PerformanceReview__c pr 
					             Where PCOMM__c =: pcommFilter AND (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName')))
								
								 ];
								
						return allPrByFilters;
				}

				if (! prpFilter.equals('0')) {
					allPrByFilters =  [Select Count() From PerformanceReview__c pr 
					             Where PerformanceReviewPeriod__c =: prpFilter AND
					             (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName')))
								 
								 ];
								
					return allPrByFilters;
				}			
				
				if (! effectiveDate.equals('All')) {
					allPrByFilters =  [Select Count() From PerformanceReview__c pr 
					             Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND
					             (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName')))
								
								 ];
								
					return allPrByFilters;
				}			
				
				if (! status.equals('All')) {
					allPrByFilters =  [Select Count() From PerformanceReview__c pr 
					             Where Status__c =: status AND
					             (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('lastName')
					            		 OR (Id <: System.currentPageReference().getParameters().get('lastId') 
					            				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('lastName')))
								
								 ];
								
					return allPrByFilters;
				}				 	 	 	   
			}
		}

		return allPrByFilters;
		
    }
}