public with sharing class PerformanceReviewYearEnd {
    
    public Id prId {get{return apexPages.currentPage().getParameters().get('id');}set;}
    
    public User currentUser;
    
    public PerformanceReview__c performanceReview;
    public PerformanceReviewYearEnd__c currentYearEnd {get;set;}
    public PerformanceReview__c currentReviewHolder {get;set;}
    
    public PerformanceAccessV2MOMMethods v2momMethod;
    public List<PerformanceAccessV2MOMMethods.Method> methods;
    
    public Boolean isSaving {get;set;} //Used to display a message when users save changes.
	public Boolean isSubmitting {get;set;} //Used to display a message when users submmit the sales scorecard.
	
    String currentUserId = userInfo.getUserId();
    
    //Constructor
    public PerformanceReviewYearEnd(){
        System.debug('******** PerformanceReviewYearEnd Constructor **********');
        
        currentUser = [Select Id, Profile.Name From User u where id = :currentUserId];
        performanceReview = getCurrentReview();
    }
    
    //Returns the current Performance Review Year End
    public PerformanceReviewYearEnd__c getYearEnd(){
        if(currentYearEnd == null){
            if(getCurrentReview().performanceReviewYearEnd__r.size() > 0){
                currentYearEnd = getCurrentReview().performanceReviewYearEnd__r[0];
            }
        }
        return currentYearEnd;
    }
    
    //Returns the current Performance Review with the Performance Year End
    public PerformanceReview__c getCurrentReview(){
        if (currentReviewHolder == null) {
            
            currentReviewHolder = [Select Id, Name,
                                          Employee__c,
                                          Employee__r.Name,
                                          Employee__r.Title,
                                          Employee__r.Department, 
                                          Manager__r.Name,
                                          Manager__r.Title,
                                          Manager__r.Department,
                                          EmailComment__c,
                                          SecondManager__r.Name,
                                          SecondManager__r.Title,
                                          SecondManager__r.Department,
                                          PCOMM__r.Name,
                                          PCOMM__r.Title,
                                          PCOMM__r.Department,
                                          ThirdPartyReviewer__r.Name,
                                          CompetencyGroup__c,
                                          PreviousStatus__c,
                                          Rating__c, Status__c,
                                          V2momRating__c,
                                          OwnerId,
                                          CompetencyRating__c,
                                          ReviewRating__r.CalculatedRating__c,
                                          PerformanceReviewPeriod__r.name,
                                          PerformanceReviewPeriod__r.V2MOM_Type__c,
                                          V2MOM__c,
                                          V2MOM__r.V2MOM_Type__c,
                                          V2MOM__r.Name,
                                          V2MOM__r.Locked__c,
                                          V2MOM__r.Effective_Date__c,
                                          (Select y.Id,
                                                  y.Name,
                                                  y.EmpKeyAccComment1__c,
                                                  y.EmpKeyAccComment2__c,
                                                  y.EmpKeyAccComment3__c,
                                                  y.MngrKeyAccComment1__c,
                                                  y.MngrKeyAccComment2__c,
                                                  y.MngrKeyAccComment3__c,
                                                  y.MngrSAAComment__c,
                                                  y.EmpSAAComment__c,
                                                  y.KeyStrengthsEmp1__c,
                                                  y.KeyStrengthsEmp2__c,
                                                  y.KeyStrengthsEmp3__c,
                                                  y.KeyStrengthsMngr1__c,
                                                  y.KeyStrengthsMngr2__c,
                                                  y.KeyStrengthsMngr3__c,
                                                  y.EmpBehaviorComment1__c,
                                                  y.EmpBehaviorComment2__c,
                                                  y.EmpBehaviorComment3__c,
                                                  y.MngrBehaviorComment1__c,
                                                  y.MngrBehaviorComment2__c,
                                                  y.MngrBehaviorComment3__c,
                                                  y.EmpImplementBehaviorCmnt__c,
                                                  y.MngrImplementBehaviorCmnt__c,
                                                  y.KeyBehaviorPerformanceRating__c,
                                                  y.Employee_Additional_Comment__c,
                                                  y.Manager_Additional_Comment__c,
                                                  y.High_Potential__c,
                                                  y.Retention_Risk__c,
                                                  y.Key_Role_Incumbent__c,
                                                  y.performanceReview__c
                                            From PerformanceReviewYearEnd__r y limit 1)
                                    From PerformanceReview__c where id =: prId];
        }
        return currentReviewHolder;
    }
    
    public PageReference setMethodsReviews(){
    	System.debug('******** Set methods reviews **********');
    	
    	//Get the V2MOM Methods
        methods = getV2MOMMethods();
        
    	return null;
    }
    
    //Returns a list of Methods associated to the V2mom of the Performance Review
    public List<PerformanceAccessV2MOMMethods.Method> getV2MOMMethods(){
        v2momMethod = new PerformanceAccessV2MOMMethods(performanceReview, currentUserId);
        
        List<PerformanceAccessV2MOMMethods.Method> tempMethodList = v2momMethod.getMethods();
        
        return tempMethodList;
    }
    
    
    // ************************** Methods that change the Performance Review Status ************************
    
    
    //Updates the performance review to the previous status
    public void setPrevStatus(PerformanceReview__c tempReview){
        tempReview.status__c = tempReview.PreviousStatus__c;
        try{
            update tempReview;
        }catch(DmlException e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Error Submitting Performance Review \n\nDescription\n'+e.getMessage());
            ApexPages.addMessage(msg);          
        }
    }
    
    //Updates the performance review to the next status
    public void setNextStatus(PerformanceReview__c tempReview,String nextStatus){
        tempReview.status__c = nextStatus;
        try{
            update tempReview;
        }catch(DmlException e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Error Submitting Performance Review \n\nDescription\n'+e.getMessage());
            ApexPages.addMessage(msg);          
        }
    }
    
    //************************************** /\ *************************************************\\
	
	//List of ratings used to associate the MethodReview rating value with a description 
    public list<ratingOption> getProgressPickList(){
        list<ratingOption> optionList = new list<ratingOption>();
        optionList.add(new ratingOption(null,'--Select Progress--'));
        optionList.add(new ratingOption(double.valueOf('1'),'Above Target'));
        optionList.add(new ratingOption(double.valueOf('2'),'On Target'));
        optionList.add(new ratingOption(double.valueOf('3'),'Under Target'));
        optionList.add(new ratingOption(double.valueOf('4'),'N/A'));
        
        return optionList;
    }
    
    //Inner class for methods ratings
    public class ratingOption{
        public double value {get;set;}
        public string label {get;set;}
        
        public ratingOption(Double val,String des){
            value = val;
            label = des;
        }
    }
    
    
    public List<PerformanceAccessV2MOMMethods.Method> getMethods(){
        return methods;
    }
    
    public PageReference setSharingReviews(){
    	shareMethodReviewWithManager();
    	return null;
    }
    
    public void shareMethodReviewWithManager(){
		
		System.debug('********* shareMethodReviewWithManager ***********');
		
		List<MethodReview__Share> methodsShare = new List<MethodReview__Share>();
		if(methods != null && methods.size() > 0 ){
			
			for (PerformanceAccessV2MOMMethods.Method m : methods){
	   			MethodReview__Share mShare = new MethodReview__Share();
	   			mShare.ParentId = m.getManagerReview().Id;
	   			mShare.AccessLevel = 'Edit';
	   			mShare.UserOrGroupId = m.performance.Manager__c;
		    	
	   			methodsShare.add(mShare);
	   		}
		}
   		if (methodsShare.size() > 0){
   			try{
	   			upsert methodsShare;
	   			System.debug('********** shareMethodReviewWithManager upserted ***********');
			}catch(Exception e){
				ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'A Problem Ocurred while triyng to upsert MethodReivew__Share '+e.getMessage());
	            ApexPages.addMessage(msg);
	        }
   		}
	}   

     //****************************VISIBILITY METHODS ****************************************\\
    
     private Map<string,Id> getPerformanceEditability(){
         Map<string,Id> tempMap = new Map<string,Id>();
         tempMap.put('Employee Self Assessment',performanceReview.Employee__c);
         tempMap.put('Manager Assessment',performanceReview.Manager__c);
         return tempMap;
    }
    public Boolean getRenderEditControls(){
        Map<string,Id> statusIdMap = getPerformanceEditability();
        return (statusIdMap.get(getCurrentReview().status__c) == UserInfo.getUserId());
    }
    
    public Boolean getRenderVisibilityEmpComp(){
        Map<String,List<Id>> statusIdMap = getVisibilityForEmployeeComponents();
        
        List<Id>theList = statusIdMap.get(performanceReview.status__c);
        if(theList != null){
            for(Id theId: theList){
                if(theId == UserInfo.getUserId()){
                    System.debug(getYearEnd());
                    return true;
                }
            }
        }
        return false;
    }
    
    public Boolean getRenderVisibilityMngrComp(){
        Map<String,List<Id>> statusIdMap = getVisibilityForManagerComponents();
        
        List<Id>theList = statusIdMap.get(performanceReview.status__c);
        if(theList != null){
            for(Id theId: theList){
                if(theId == UserInfo.getUserId()){
                    return true;
                }
            }
        }
        return false;
    }
    
    private Map<String, List<Id>> getVisibilityForEmployeeComponents(){
        Map<String, List<Id>> tempMap = new Map<String,List<Id>>();
        
        List<Id> tempListEmpSelfAssess = new List<Id>();
        List<Id> tempListMngrAssess = new List<Id>();
        
        tempListEmpSelfAssess.add(performanceReview.Employee__c);
        
        tempListMngrAssess.add(performanceReview.Employee__c);
        tempListMngrAssess.add(performanceReview.Manager__c);
        tempListMngrAssess.add(performanceReview.SecondManager__c);
        tempListMngrAssess.add(performanceReview.PCOMM__c);
        
        tempMap.put('Employee Self Assessment', tempListEmpSelfAssess);
        tempMap.put('Manager Assessment', tempListMngrAssess);
        
        //The others status uses the same visibility of MngrAssess
        tempMap.put('Calibration', tempListMngrAssess);
        tempMap.put('Manager Approval', tempListMngrAssess);
        tempMap.put('Employee Approval', tempListMngrAssess);
        tempMap.put('Complete', tempListMngrAssess);
        
        //These status are not used in the new workflow for the year end.
        //2nd Level Manager Assessment, Pending Employee Services, PCOMM Review
        
        return tempMap;
    }
    
    private Map<String, List<Id>> getVisibilityForManagerComponents(){
        Map<String, List<Id>> tempMap = new Map<String,List<Id>>();
        
        List<Id> tempListEmpSelfAssess = new List<Id>();
        List<Id> tempListMngrAssess = new List<Id>();
        List<Id> tempListAllActors = new List<Id>();
        
        tempListEmpSelfAssess.add(performanceReview.Manager__c);
        tempListEmpSelfAssess.add(performanceReview.SecondManager__c);
        tempListEmpSelfAssess.add(performanceReview.PCOMM__c);
        if(getIsAdminOrEmpSuccess()){
        	tempListEmpSelfAssess.add(currentUserId);
        	tempListAllActors.add(currentUserId);
        }
        
        //Only the Manager can view the fields when status is Manager Assessment
        //tempListMngrAssess.add(performanceReview.Manager__c);
        tempListMngrAssess.add(null);
        
        
        tempMap.put('Employee Self Assessment', tempListEmpSelfAssess);
        tempMap.put('Manager Assessment', tempListMngrAssess);
        
        //The others status uses the same visibility of Employee Self Assessment
        tempMap.put('Calibration', tempListEmpSelfAssess);
        tempMap.put('Manager Approval', tempListEmpSelfAssess);
        
        //All users can see all values
        tempListAllActors.add(performanceReview.Employee__c);
        tempListAllActors.add(performanceReview.Manager__c);
        tempListAllActors.add(performanceReview.SecondManager__c);
        tempListAllActors.add(performanceReview.PCOMM__c);
        
        //On these two, all users can see all fields
        tempMap.put('Employee Approval', tempListAllActors);
        tempMap.put('Complete', tempListAllActors);
        
        //These 3 are not used in the new workflow for the year end.
        //tempMap.put('2nd Level Manager Assessment', tempListEmpSelfAssess);
        //tempMap.put('Pending Employee Services', tempListEmpSelfAssess); 
        //tempMap.put('PCOMM Review', tempListEmpSelfAssess);
        
        return tempMap;
    }
    
    // Gets the profile of the current user
    public String getUserProfile(){
        return currentUser.Profile.Name;    
    }
    
    // Function to show the Change to incomplete button; only Sys admin can see it
    public boolean getShowIncomplete(){
		return !getIsIncompleteStatus() && getIsOnlySysAdminProfile();
    }
    
    public boolean getIsOnlySysAdminProfile(){
		return (getUserProfile() == 'System Administrator'|| getUserProfile()=='systemadministrator');
    }
    
    public boolean getIsIncompleteStatus(){
        return performanceReview.Status__c == 'Incomplete';
    }
    
    /*
    Returns true if the logged user is the employee of the performance review.
    */
    public Boolean getIsEmployee(){
        return (UserInfo.getUserId()== performanceReview.Employee__c);
    }
    
    /*
    Returns true if the logged user is the manager of the performance review.
    */
    public Boolean getIsManager(){
        return (UserInfo.getUserId()==performanceReview.Manager__c);
    }
    
    /*
    Returns true if the logged user is the 2nd Manager of the performance review.
    */
    public Boolean getIsSecondManager(){
        return (UserInfo.getUserId()== performanceReview.SecondManager__c);
    }
    
    /*
    Returns true if the logged user is the PCOMM of the performance review.
    */
    public Boolean getIsPCOMM(){
        return (UserInfo.getUserId()== performanceReview.PCOMM__c);
    }
    
    public Boolean getIsAdmin(){
        Profile p = [Select id,name From Profile Where Name=:Label.System_Administrator_label]; 
        Profile systemAdmin = [Select id,name From Profile Where Name=:'systemadministrator'];
        return (UserInfo.getProfileId()==p.id || UserInfo.getProfileId()==systemAdmin.id); 
    }
    
    /*
    Returns true if the profile of the logged user is Employee Success - Standard w/Cases.
    */
    public Boolean getIsEmployeeSuccessSC() {
        Profile p = [Select id,name From Profile Where Name=:'Employee Success - Standard w/ Cases'];
        return (UserInfo.getProfileId()==p.id); 
    }
    
    /*
    Returns true if the profile of the logged user is Employee Success/Business Partner.
    */
    public Boolean getIsESBP(){
        Profile p = [Select id,name From Profile Where Name=:'Employee Success/Business Partner'];
        return (UserInfo.getProfileId()==p.id); 
    }
    
    /*
    Returns true if the profile of the logged user is a SysAdmin, Employee Success standard or Business Partner.
    */
    public Boolean getIsAdminOrEmpSuccess(){
        if(UserInfo.getUserId() == performanceReview.Employee__c || UserInfo.getUserId() == performanceReview.Manager__c){
        	return false;
        }else{
	        return (getIsAdmin() || getIsEmployeeSuccessSC() || getIsESBP());
        }
    }
    
   	/**
    Return true if the current status is Created
    */
    public Boolean getIsStatusCreated() {   
        if(getCurrentReview().status__c != 'Created'){
            return false;
        }
        return true;
    }
   
    /*
    Return true if the current status is Employee Self Assessment
    */
    public Boolean getIsStatusEmpSelfAssess() {
        if(getCurrentReview().status__c != 'Employee Self Assessment'){
            return false;
        }
        return true;
    }
    
    /*
    Return true if the current status is Manager Assessment
    */
    public Boolean getIsStatusManagerAssess() {
        if(getCurrentReview().status__c != 'Manager Assessment'){
            return false;
        }
        return true;
    }
    
    /*
    Return true if the current status is Calibration
    */
    public Boolean getIsStatusCalibration() {
        if(getCurrentReview().status__c != 'Calibration'){
            return false;
        }
        return true;
    }
    
    /*
        Return true if the current status is Manager Approval
    */
    public Boolean getIsStatusManagerApp() {
        if(getCurrentReview().status__c != 'Manager Approval'){
            return false;
        }
        return true;
    }
    
    /*
        Return true if the current status is Employee Approval
    */
    public Boolean getIsStatusEmpApp() {
        if(getCurrentReview().status__c != 'Employee Approval'){
            return false;
        }
        return true;
    }
    
    /**
    Return true if the current status is Complete
    */
    public Boolean getIsStatusComplete() {  
        if(getCurrentReview().status__c != 'Complete'){
            return false;
        }
        return true;
    }
    
}