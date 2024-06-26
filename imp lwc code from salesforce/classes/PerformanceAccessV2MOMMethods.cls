public with sharing class PerformanceAccessV2MOMMethods {
	
	public List<Method> methods;
	public PerformanceReview__c performanceReview;
	public PerformanceAccessUtil accessUtil;
	public Boolean isPCOMMLikeViewProfile;

	User currentUser;
    User scorecardTypeProfile;

	PerformanceSOQLController  util = new PerformanceSOQLController();
        
	public PerformanceAccessV2MOMMethods(PerformanceReview__c pr, Id currentUserId){
		this.performanceReview = pr;
		// gets the user
		currentUser = [Select Id, Profile.Name From User u where id =: currentUserId];           
		util.setCurrentUser(currentUser);
		
		// gets the profile of the employee to see what kind of scorecard it might have
        scorecardTypeProfile = [Select Id, Profile.Name From User u where id = :performanceReview.Employee__c];
            
		// access class for permissions
        accessUtil = new PerformanceAccessUtil(performanceReview, currentUser, scorecardTypeProfile);
		accessUtil.setUserInf(currentUserId);
		
		isPCOMMLikeViewProfile = accessUtil.getPCOMMLikeViewProfile();
	}
	
	
	public List<Method> getMethods(){
        methods = new List<Method>();
            
        list<Value__c> tempValues = [SELECT Name,
                                           (SELECT Id
                                            FROM Methods__r)
                                     FROM Value__c
                                     WHERE V2MOM__c = :performanceReview.V2MOM__c
                                     ORDER BY Priority__c];
        System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$Temp VALUES: ' + tempValues);
        
        list<Method__c> methodsc = new List<Method__c>();
        if(tempValues != null && tempValues.size()>0){                  
        	methodsc = [Select m.id, 
                               m.name, 
                               m.Value__c, 
                               m.Value__r.Name, 
                               m.Description__c, 
                              (Select name, description__c From Obstacles__r ORDER BY Priority__c),  
                              (Select name, description__c From Measures__r ORDER BY Priority__c)
                        From Method__c m
                        Where V2MOM__c=:performanceReview.V2MOM__c
                        and Value__c IN :tempValues
                        ORDER BY Priority__c];
	        System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$methodsc: ' + methodsc);
        }
        
        list<Method__c> methodsc_withoutvalue = [Select m.id,
        												m.name,
        												m.Value__c,
        												m.Value__r.Name,
        												m.Description__c, 
                                                       (Select name, description__c From Obstacles__r),  
                                                       (Select name, description__c From Measures__r)
                                                From Method__c m
                                                Where V2MOM__c=:performanceReview.V2MOM__c
                                              	and Value__c NOT IN :tempValues
                                                ORDER BY Priority__c];
        
        System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$methodsc_withoutvalue: ' + methodsc_withoutvalue);
        
        Map<Id, MethodReview__c> methodReviewsManager;
        Map<Id, MethodReview__c> methodReviewsEmployee;
        //List<MethodReview__c> methodReviewsComments;
		List<MethodReview__c> methodReviewsToInsert = new List<MethodReview__c>();
		
        if(methodsc.size() > 0 ){
	        if (isPCOMMLikeViewProfile) {
	            // retrieve data without sharing
	            System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$methodsc size: ' + methodsc.size());
	            System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$Calling getPerformanceReviewDAtaWithoutSharing');
	            methodReviewsManager = getPerformanceReviewDataWithoutSharing(performanceReview, methodsc);
	            
	            System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$Calling getPerformanceReviewEmployeeWithoutSharing');
	            methodReviewsEmployee = getPerformanceReviewEmployeeWithoutSharing(performanceReview, methodsc);
	        }
	        else {
	        	//aca entra logueado como manager, status empSelfAssess
	        	System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$Calling util.getPerformanceReviewDAtaWithSharing');
	            methodReviewsManager = util.getPerformanceReviewDataWithSharing(performanceReview, methodsc);
	            System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$Calling util.getPerformanceReviewEmployeeWithSharing');
	            methodReviewsEmployee = util.getPerformanceReviewEmployeeWithSharing(performanceReview, methodsc);
	            //methodReviewsComments = util.getPerformanceReviewCommentWithSharing(performanceReview, methodsc);
	        }
	        for(Method__c methodc: methodsc){
	        	
	            List<MethodReview__c> temp = new List<MethodReview__c>();
	            Method method = new Method(methodc,  performanceReview);
	            MethodReview__c managerReview = methodReviewsManager.get(methodc.Id);
	            MethodReview__c reviewEmployee = methodReviewsEmployee.get(methodc.Id);
	        	//Para cada metodo busca su methodReview y se lo agrega, si no existe un method review lo crea.
	        	System.debug('#########################################################Map methodsReviewsManager 1: ' + methodReviewsManager);
	            if (managerReview != null) {
	            	System.debug('##############################################################managerReview: ' + managerReview);
	                method.setManagerReview(managerReview);
	            }else{
	        		if(performanceReview.Status__c == 'Manager Assessment' && currentUser.Id != performanceReview.Employee__c ){
		        		System.debug('##############################################################managerReview 1 not founded on the map, doing new methodReview ');
		            	MethodReview__c mngrReview = new MethodReview__c();
		            	mngrReview.Method__c = methodc.Id;
		            	mngrReview.Reviewer__c = performanceReview.Manager__c;
		            	mngrReview.Rating__c = null;
		            	mngrReview.PerformanceReview__c = performanceReview.Id;
		            	
		            	methodReviewsToInsert.add(mngrReview);
		            	
		            	method.setManagerReview(mngrReview);
	        		}
	            }
	            
	            System.debug('#########################################################Map methodsReviewsEmployee 1: ' + methodReviewsEmployee);
	            if (reviewEmployee != null) {
	                System.debug('##############################################################reviewEmployee: ' + reviewEmployee);
	                method.setEmployeeReview(reviewEmployee);
	            }else{
	            	if(performanceReview.Status__c == 'Employee Self Assessment' && (currentUser.Id == performanceReview.Employee__c || isPCOMMLikeViewProfile)){
		            	System.debug('##############################################################reviewEmployee 1 not founded on the map, doing new methodReview ');
		            	MethodReview__c empReview = new MethodReview__c();
		            	empReview.Method__c = methodc.Id;
		            	empReview.Reviewer__c = performanceReview.Employee__c;
		            	empReview.Rating__c = null;
		            	empReview.PerformanceReview__c = performanceReview.Id;
		            	
		            	methodReviewsToInsert.add(empReview);
	            	
	            		method.setEmployeeReview(empReview);
	            	}
	            }
	            
	            methods.add(method);
	        }
        }
		if(methodsc_withoutvalue.size() > 0 ){
	        if (isPCOMMLikeViewProfile) {
	            // retrieve data without sharing
	            System.debug('***********************************************************PERFORMANCE ACCESS V2MOM METHODS --> isPCOMMLikeViewProfile so get the Data WITHOUT SHARING');       
	            methodReviewsManager = getPerformanceReviewDataWithoutSharing(performanceReview, methodsc_withoutvalue);
	            System.debug('************************************methodReviewsManager: ' + methodReviewsManager);
	            methodReviewsEmployee = getPerformanceReviewEmployeeWithoutSharing(performanceReview, methodsc_withoutvalue);
	            System.debug('************************************methodReviewsEmployee: ' + methodReviewsEmployee);
	        }
	        else {
	    	 	System.debug('***********************************************************PERFORMANCE ACCESS V2MOM METHODS --> NOT isPCOMMLikeViewProfile so get the Data With Sharing');
	            methodReviewsManager = util.getPerformanceReviewDataWithSharing(performanceReview, methodsc_withoutvalue);
	            System.debug('************************************methodReviewsManager after util.getPerformanceReviewDataWithSharing: ' + methodReviewsManager);
	            methodReviewsEmployee = util.getPerformanceReviewEmployeeWithSharing(performanceReview, methodsc_withoutvalue);
	        	System.debug('************************************methodReviewsEmployee: ' + methodReviewsEmployee);
	        }
	          
	        for(Method__c methodc: methodsc_withoutvalue){               
	            List<MethodReview__c> temp = new List<MethodReview__c>();
	            Method method = new Method(methodc,  performanceReview);    
	            MethodReview__c review = methodReviewsManager.get(methodc.Id);
	            MethodReview__c reviewEmployee = methodReviewsEmployee.get(methodc.Id);
	    		
	    		System.debug('#########################################################Map methodReviewsManager 2: ' + methodReviewsManager);
	            System.debug('########################################################review: ' + review);
	            if (review != null) {
	                System.debug('##############################################################ManagerReview: ' + review);
	                method.setManagerReview(review);
	                System.debug('************#############*********************############PERFORMANCE ACCESS V2MOM METHODS --> ManagerReview: ' + review);
	            }else{
	            	if(performanceReview.Status__c == 'Manager Assessment' && currentUser.Id != performanceReview.Employee__c ){
		            	System.debug('************#############*********************############NEW ManagerReview cause not founded on methodReviewsManager');
		            	//New MethodReview for the manager
		            	MethodReview__c mngrReview = new MethodReview__c();
		            	mngrReview.Method__c = methodc.Id;
		            	mngrReview.Reviewer__c = performanceReview.Manager__c;
		            	mngrReview.Rating__c = null;
		            	mngrReview.PerformanceReview__c = performanceReview.Id;
		            	
		            	methodReviewsToInsert.add(mngrReview);
		            	method.setManagerReview(mngrReview);
	            	}
	            }
	            
	            System.debug('#########################################################Map methodReviewsEmployee 2: ' + methodReviewsEmployee);
	            System.debug('#########################################################reviewEmployee: '+reviewEmployee);
	            if (reviewEmployee != null) {
	                System.debug('##############################################################EmployeeReview: ' + reviewEmployee);
	                method.setEmployeeReview(reviewEmployee);
	                System.debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&PERFORMANCE ACCESS V2MOM METHODS --> EmployeeReview: ' + reviewEmployee);
	            }else{
	            	if(performanceReview.Status__c == 'Employee Self Assessment' && (currentUser.Id == performanceReview.Employee__c || isPCOMMLikeViewProfile)){
		            	//New MethodReview for the employee
		            	System.debug('*********###############*********###########********########**reviewEmployee not founded on the map, doing new methodReview ');
		            	MethodReview__c empReview = new MethodReview__c();
		            	empReview.Method__c = methodc.Id;
		            	empReview.Reviewer__c = performanceReview.Employee__c;
		            	empReview.Rating__c = null;
		            	empReview.PerformanceReview__c = performanceReview.Id;
		            	
		            	methodReviewsToInsert.add(empReview);
		            	method.setEmployeeReview(empReview);
	            	}
	            }
	            
	            methods.add(method);
	        }
		}
		
        return methods;
    }
	
    // gets the method review data without sharing
    public Map<Id, MethodReview__c> getPerformanceReviewDataWithoutSharing(PerformanceReview__c p, List<Method__c> m){
        Map<Id, MethodReview__c> tempmap = new Map<Id, MethodReview__c>();
        
        for(MethodReview__c mr: [Select r.Name, 
                                        r.Method__c, 
                                        r.CreatedDate, 
                                        r.CreatedBy.Name, 
                                        r.Reviewer__c, 
                                        r.Weight__c, 
                                        r.Rating__c 
                                 From MethodReview__c r
                                 Where PerformanceReview__c =: p.Id 
                                 AND r.Reviewer__c =: p.Manager__c
                                 and Method__c IN : m]) {
                
                  tempmap.put(mr.Method__c, mr);
        }
		System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$getPerformanceReviewDataWithoutSharing TEMPMAP: ' + tempmap);
        return tempmap;
    }
    
    // gets the method review data from the employee without sharing
    public Map<Id, MethodReview__c> getPerformanceReviewEmployeeWithoutSharing(PerformanceReview__c p, List<Method__c> m){
        Map<Id, MethodReview__c> tempmap = new Map<Id, MethodReview__c>();
            
         for(MethodReview__c mr: [Select r.Name, 
                                         r.Method__c, 
                                         r.CreatedDate, 
                                         r.CreatedBy.Name, 
                                         r.Reviewer__c, 
                                         r.Status__c,
                                         r.Rating__c
                                 From MethodReview__c r 
                                 Where PerformanceReview__c =: p.Id 
                                 AND r.Reviewer__c =: p.Employee__c
                                 and Method__c IN : m]) {
                
                  tempmap.put(mr.Method__c, mr);
       }
           
       return tempmap;
   }           

	/*
	* Inner Class Method
	*/
	public class Method {
		public Method__c method;
		public MethodReview__c managerReview;
		public MethodReview__c employeeReview;
		List<Obstacle__c> obstacles;
		List<Measure__c> metrics;
		public PerformanceReview__c performance;

		public Method(Method__c m, PerformanceReview__c p){
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

        public MethodReview__c getManagerReview() {
            return managerReview;
        }

        public void setManagerReview(MethodReview__c m) {
            managerReview = m;
        }
        
        public MethodReview__c getEmployeeReview() {
            return EmployeeReview;
        }

        public void setEmployeeReview(MethodReview__c m) {
            employeeReview = m;
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
	}
}