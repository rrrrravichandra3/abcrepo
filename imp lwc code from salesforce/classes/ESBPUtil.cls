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

public class ESBPUtil {
    

	public static list<PerformanceReview__c> getPerformanceReviewsPrevOrderByNameAux(Integer max, Boolean isNext, Boolean descByName, String pcommFilter, String prpFilter, String effectiveDate, String status){
		if (! descByName){
			if (pcommFilter.equals('0') && prpFilter.equals('0') &&  effectiveDate.equals('All') && status.equals('All') ) {			  	
				
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.Employee__r.EmployeeNumber,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
						         pr.Status__c
				         From PerformanceReview__c pr
				         Where  (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('firstName')
				        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
				        				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('firstName')))
						ORDER BY pr.Employee__r.Name DESC, Id DESC 
						LIMIT :max];
			}

			if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! effectiveDate.equals('All') && ! status.equals('All')) {			  	
				
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
						         pr.Employee__r.Department,
						         pr.Employee__r.EmployeeNumber,
						         pr.Employee__r.Division,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
						         pr.Status__c
				         From PerformanceReview__c pr Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND Status__c =: status AND
				           (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('firstName')
				        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
				        				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('firstName')))
						ORDER BY pr.Employee__r.Name DESC, Id DESC 
						LIMIT :max];
			}
			
			if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! effectiveDate.equals('All')) {			  	
				
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.Employee__r.EmployeeNumber,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
						         pr.Status__c
				         From PerformanceReview__c pr Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND
				           (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('firstName')
				        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
				        				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('firstName')))
						ORDER BY pr.Employee__r.Name DESC, Id DESC 
						LIMIT :max];
			}
			
			if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! status.equals('All')) {			  	
				
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.Employee__r.EmployeeNumber,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
						         pr.Status__c
				         From PerformanceReview__c pr Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND Status__c =: status AND
				           (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('firstName')
				        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
				        				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('firstName')))
						ORDER BY pr.Employee__r.Name DESC, Id DESC 
						LIMIT :max];
			}
			
			if (! effectiveDate.equals('All') && ! prpFilter.equals('0') && ! status.equals('All')) {			  	
			
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
						         pr.Employee__r.Department,
						         pr.Employee__r.EmployeeNumber,
						         pr.Employee__r.Division,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
						         pr.Status__c
				         From PerformanceReview__c pr Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PerformanceReviewPeriod__c =: prpFilter
				             AND Status__c =: status AND
				           (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('firstName')
				        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
				        				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('firstName')))
						ORDER BY pr.Employee__r.Name DESC, Id DESC 
						LIMIT :max];
			}
			
			if (! effectiveDate.equals('All') && ! pcommFilter.equals('0') && ! status.equals('All')) {			  	
				  
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
						         pr.Employee__r.Department,
						         pr.Employee__r.Division,
						         pr.Employee__r.EmployeeNumber,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
						         pr.Status__c
				         From PerformanceReview__c pr Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PCOMM__c =: pcommFilter 
				             AND Status__c =: status AND
				           (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('firstName')
				        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
				        				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('firstName')))
						ORDER BY pr.Employee__r.Name DESC, Id DESC 
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
						         pr.Employee__r.EmployeeNumber,
						         pr.Employee__r.Division,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
						         pr.Status__c
				         From PerformanceReview__c pr
				         Where PerformanceReviewPeriod__c =: prpFilter AND PCOMM__c =: pcommFilter AND
				         (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('firstName')
				        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
				        				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('firstName')))
						ORDER BY pr.Employee__r.Name DESC, Id DESC 
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
						         pr.Employee__r.EmployeeNumber,
						         pr.Employee__r.Division,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
						         pr.Status__c
				         From PerformanceReview__c pr
				         Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND PCOMM__c =: pcommFilter AND
				         (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('firstName')
				        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
				        				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('firstName')))
						ORDER BY pr.Employee__r.Name DESC, Id DESC 
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
						         pr.Employee__r.EmployeeNumber,
						         pr.Employee__r.Division,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
						         pr.Status__c
				         From PerformanceReview__c pr
				         Where Status__c =: status AND PCOMM__c =: pcommFilter AND
				         (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('firstName')
				        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
				        				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('firstName')))
						ORDER BY pr.Employee__r.Name DESC, Id DESC 
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
						         pr.Employee__r.EmployeeNumber,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
						         pr.Status__c
				         From PerformanceReview__c pr
				         Where PerformanceReviewPeriod__c =: prpFilter AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND
				         (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('firstName')
				        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
				        				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('firstName')))
						ORDER BY pr.Employee__r.Name DESC, Id DESC 
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
						         pr.Employee__r.EmployeeNumber,
						         pr.Employee__r.Division,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
						         pr.Status__c
				         From PerformanceReview__c pr
				         Where PerformanceReviewPeriod__c =: prpFilter AND Status__c =: status AND
				         (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('firstName')
				        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
				        				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('firstName')))
						ORDER BY pr.Employee__r.Name DESC, Id DESC 
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
						         pr.Employee__r.EmployeeNumber,
						         pr.Employee__r.Division,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
						         pr.Status__c
				         From PerformanceReview__c pr
				         Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND Status__c =: status AND
				         (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('firstName')
				        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
				        				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('firstName')))
						ORDER BY pr.Employee__r.Name DESC, Id DESC 
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
						         pr.Employee__r.EmployeeNumber,
						         pr.Employee__r.Division,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
						         pr.Status__c
				         From PerformanceReview__c pr
				         Where PCOMM__c =: pcommFilter AND (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('firstName')
				        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
				        				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('firstName')))
						ORDER BY pr.Employee__r.Name DESC, Id DESC 
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
						         pr.Employee__r.EmployeeNumber,
						         pr.Employee__r.Division,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
						         pr.Status__c
				         From PerformanceReview__c pr
				         Where PerformanceReviewPeriod__c =: prpFilter AND (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('firstName')
				        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
				        				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('firstName')))
						ORDER BY pr.Employee__r.Name DESC, Id DESC 
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
						         pr.Employee__r.EmployeeNumber,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
						         pr.Status__c
				         From PerformanceReview__c pr
				         Where pr.V2MOM__r.Effective_Date__c =: effectiveDate AND (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('firstName')
				        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
				        				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('firstName')))
						ORDER BY pr.Employee__r.Name DESC, Id DESC 
						LIMIT :max];	
			}
			
			if (! status.equals('All')){
				System.debug('FilterOnlyByStatus');
				return  [Select  pr.id,
						         pr.Name,
						         pr.Employee__c,
						         pr.Employee__r.Name,
						         pr.Employee__r.Title,
						         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
						         pr.Employee__r.Department,
						         pr.Employee__r.EmployeeNumber,
						         pr.Employee__r.Division,
						         pr.manager__c,
						         pr.SecondManager__c,
						         pr.V2MOM__c,
				         		 pr.V2MOM__r.V2MOM_Type__c,
						         pr.ReviewRating__r.CalculatedRating__c,
						         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
						         pr.Status__c
				         From PerformanceReview__c pr
				         Where Status__c =: status AND (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('firstName')
				        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
				        				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('firstName')))
						ORDER BY pr.Employee__r.Name DESC, Id DESC 
						LIMIT :max];	
			}
			
		}
		else{
			System.debug('Enterelseee');
			if (System.currentPageReference().getParameters().get('firstName') == ''){
				if (pcommFilter.equals('0') && prpFilter.equals('0') && effectiveDate.equals('All') && status.equals('All'))	{				
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.EmployeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where  (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('firstName')
					        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('firstName')))
							ORDER BY pr.Employee__r.Name , Id  
							LIMIT :max];
				}
				
				if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! effectiveDate.equals('All') && ! status.equals('All'))	{				
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.EmployeeNumber,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							         pr.Status__c
					         From PerformanceReview__c pr Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND Status__c =: status AND
					           (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('firstName')
					        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('firstName')))
							ORDER BY pr.Employee__r.Name , Id  
							LIMIT :max];
				}
				
				if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! effectiveDate.equals('All'))	{				
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.EmployeeNumber,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							         pr.Status__c
					         From PerformanceReview__c pr Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND
					           (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('firstName')
					        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('firstName')))
							ORDER BY pr.Employee__r.Name , Id  
							LIMIT :max];
				}

				if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! status.equals('All'))	{				
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.EmployeeNumber,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							         pr.Status__c
					         From PerformanceReview__c pr Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND Status__c =: status AND
					           (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('firstName')
					        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('firstName')))
							ORDER BY pr.Employee__r.Name , Id  
							LIMIT :max];
				}
				
				if (! effectiveDate.equals('All') && ! pcommFilter.equals('0') && ! status.equals('All'))	{				
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.EmployeeNumber,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							         pr.Status__c
					         From PerformanceReview__c pr Where PCOMM__c =: pcommFilter AND PCOMM__c =: pcommFilter
				             AND Status__c =: status AND
					           (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('firstName')
					        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('firstName')))
							ORDER BY pr.Employee__r.Name , Id  
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
							         pr.Employee__r.EmployeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         		 	 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where  PerformanceReviewPeriod__c =: prpFilter AND PCOMM__c =: pcommFilter AND  (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('firstName')
					        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('firstName')))
							ORDER BY pr.Employee__r.Name , Id  
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
							         pr.Employee__r.EmployeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where  pr.V2MOM__r.Effective_Date__c =: prpFilter AND PCOMM__c =: pcommFilter AND  (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('firstName')
					        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('firstName')))
							ORDER BY pr.Employee__r.Name , Id  
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
							         pr.Employee__r.EmployeeNumber,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where  Status__c =: status AND PCOMM__c =: pcommFilter AND  (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('firstName')
					        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('firstName')))
							ORDER BY pr.Employee__r.Name , Id  
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
							         pr.Employee__r.EmployeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where  PerformanceReviewPeriod__c =: prpFilter AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND  (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('firstName')
					        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('firstName')))
							ORDER BY pr.Employee__r.Name , Id  
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
							         pr.Employee__r.EmployeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where  PerformanceReviewPeriod__c =: prpFilter AND Status__c =: status AND  (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('firstName')
					        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('firstName')))
							ORDER BY pr.Employee__r.Name , Id  
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
							         pr.Employee__r.EmployeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where  pr.V2MOM__r.Effective_Date__c =: effectiveDate AND Status__c =: status AND  (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('firstName')
					        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('firstName')))
							ORDER BY pr.Employee__r.Name , Id  
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
							         pr.Employee__r.EmployeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where  PCOMM__c =: pcommFilter AND (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('firstName')
					        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('firstName')))
							ORDER BY pr.Employee__r.Name , Id  
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
							         pr.Employee__r.EmployeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where  PerformanceReviewPeriod__c =: prpFilter AND (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('firstName')
					        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('firstName')))
							ORDER BY pr.Employee__r.Name , Id  
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
							         pr.Employee__r.EmployeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where  pr.V2MOM__r.Effective_Date__c =: effectiveDate AND (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('firstName')
					        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('firstName')))
							ORDER BY pr.Employee__r.Name , Id  
							LIMIT :max];	
				}		
				
				if (! status.equals('All')) {
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.EmployeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where  Status__c =: status AND (pr.Employee__r.Name < : System.currentPageReference().getParameters().get('firstName')
					        		 OR (Id <: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Employee__r.Name <= : System.currentPageReference().getParameters().get('firstName')))
							ORDER BY pr.Employee__r.Name , Id  
							LIMIT :max];	
				}		
			}
			else{
				if (pcommFilter.equals('0') && prpFilter.equals('0') && effectiveDate.equals('All') && status.equals('All') ) {
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.EmployeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where (pr.Employee__r.Name >: System.currentPageReference().getParameters().get('firstName')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('firstName')))
							ORDER BY pr.Employee__r.Name , Id  
							LIMIT :max];
				}

				if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! effectiveDate.equals('All') && ! status.equals('All')  ) {
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.EmployeeNumber,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							         pr.Status__c
					         From PerformanceReview__c pr Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND Status__c =: status AND
				              (pr.Employee__r.Name >: System.currentPageReference().getParameters().get('firstName')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('firstName')))
							ORDER BY pr.Employee__r.Name , Id  
							LIMIT :max];
				}
				
				if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! effectiveDate.equals('All')  ) {
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.EmployeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							         pr.Status__c
					         From PerformanceReview__c pr Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND
				              (pr.Employee__r.Name >: System.currentPageReference().getParameters().get('firstName')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('firstName')))
							ORDER BY pr.Employee__r.Name , Id  
							LIMIT :max];
				}
				
				if (! pcommFilter.equals('0') && ! prpFilter.equals('0') && ! status.equals('All')  ) {
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.EmployeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							         pr.Status__c
					         From PerformanceReview__c pr Where PCOMM__c =: pcommFilter AND PerformanceReviewPeriod__c =: prpFilter
				             AND Status__c =: status AND
				              (pr.Employee__r.Name >: System.currentPageReference().getParameters().get('firstName')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('firstName')))
							ORDER BY pr.Employee__r.Name , Id  
							LIMIT :max];
				}
				
				if (! status.equals('All') && ! prpFilter.equals('0') && ! effectiveDate.equals('All')  ) {
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.EmployeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							         pr.Status__c
					         From PerformanceReview__c pr Where Status__c =: status AND PerformanceReviewPeriod__c =: prpFilter
				             AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND
				              (pr.Employee__r.Name >: System.currentPageReference().getParameters().get('firstName')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('firstName')))
							ORDER BY pr.Employee__r.Name , Id  
							LIMIT :max];
				}
				
				if (! status.equals('All') && ! pcommFilter.equals('0') && ! effectiveDate.equals('All')  ) {
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.EmployeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							         pr.Status__c
					         From PerformanceReview__c pr Where Status__c =: status AND PCOMM__c =: pcommFilter
				             AND pr.V2MOM__r.Effective_Date__c =: effectiveDate AND
				              (pr.Employee__r.Name >: System.currentPageReference().getParameters().get('firstName')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('firstName')))
							ORDER BY pr.Employee__r.Name , Id  
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
							         pr.Employee__r.EmployeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where PerformanceReviewPeriod__c =:prpFilter AND PCOMM__c =:pcommFilter AND (pr.Employee__r.Name >: System.currentPageReference().getParameters().get('firstName')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('firstName')))
							ORDER BY pr.Employee__r.Name , Id  
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
							         pr.manager__c,
							         pr.Employee__r.EmployeeNumber,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where pr.V2MOM__r.Effective_Date__c =:effectiveDate AND PCOMM__c =:pcommFilter AND (pr.Employee__r.Name >: System.currentPageReference().getParameters().get('firstName')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('firstName')))
							ORDER BY pr.Employee__r.Name , Id  
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
							         pr.Employee__r.EmployeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where Status__c =: status AND PCOMM__c =:pcommFilter AND (pr.Employee__r.Name >: System.currentPageReference().getParameters().get('firstName')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('firstName')))
							ORDER BY pr.Employee__r.Name , Id  
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
							         pr.Employee__r.EmployeeNumber,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where PerformanceReviewPeriod__c =:prpFilter AND pr.V2MOM__r.Effective_Date__c =:effectiveDate AND (pr.Employee__r.Name >: System.currentPageReference().getParameters().get('firstName')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('firstName')))
							ORDER BY pr.Employee__r.Name , Id  
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
							         pr.Employee__r.EmployeeNumber,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where PerformanceReviewPeriod__c =:prpFilter AND Status__c =: status AND (pr.Employee__r.Name >: System.currentPageReference().getParameters().get('firstName')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('firstName')))
							ORDER BY pr.Employee__r.Name , Id  
							LIMIT :max];
				}
				
				if ((!effectiveDate.equals('All')) && (!status.equals('All'))){
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.EmployeeNumber,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where Status__c =: status AND pr.V2MOM__r.Effective_Date__c =:effectiveDate AND (pr.Employee__r.Name >: System.currentPageReference().getParameters().get('firstName')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('firstName')))
							ORDER BY pr.Employee__r.Name , Id  
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
							         pr.Employee__r.EmployeeNumber,
							         pr.Employee__r.Division,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where PCOMM__c =:pcommFilter AND (pr.Employee__r.Name >: System.currentPageReference().getParameters().get('firstName')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('firstName')))
							ORDER BY pr.Employee__r.Name , Id  
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
							         pr.Employee__r.EmployeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where PerformanceReviewPeriod__c =:prpFilter AND (pr.Employee__r.Name >: System.currentPageReference().getParameters().get('firstName')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('firstName')))
							ORDER BY pr.Employee__r.Name , Id  
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
							         pr.Employee__r.EmployeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where pr.V2MOM__r.Effective_Date__c =:effectiveDate AND (pr.Employee__r.Name >: System.currentPageReference().getParameters().get('firstName')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('firstName')))
							ORDER BY pr.Employee__r.Name , Id  
							LIMIT :max];
				}
				
				if (! status.equals('All')) {
				
					return  [Select  pr.id,
							         pr.Name,
							         pr.Employee__c,
							         pr.Employee__r.Name,
							         pr.Employee__r.Title,
							         pr.Employee__r.Manager__r.Name, pr.Employee__r.ReviewManager__r.Name,
							         pr.Employee__r.Department,
							         pr.Employee__r.Division,
							         pr.Employee__r.EmployeeNumber,
							         pr.manager__c,
							         pr.SecondManager__c,
							         pr.V2MOM__c,
				         			 pr.V2MOM__r.V2MOM_Type__c,
							         pr.ReviewRating__r.CalculatedRating__c,
							         pr.ReviewRating__r.OverAllRating__c,pr.PerformanceReviewPeriod__r.Effective_Date__c, pr.V2MOM__r.Effective_Date__c, 
							         pr.Status__c
					         From PerformanceReview__c pr
					         Where Status__c =: status AND (pr.Employee__r.Name >: System.currentPageReference().getParameters().get('firstName')
					        		 OR (Id >: System.currentPageReference().getParameters().get('prevId') 
					        				 AND pr.Employee__r.Name >= : System.currentPageReference().getParameters().get('firstName')))
							ORDER BY pr.Employee__r.Name , Id  
							LIMIT :max];
				}
			}			
		}

		return null;
	}
	
	
	
	
		
}