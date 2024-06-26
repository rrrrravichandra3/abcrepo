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
 
public without sharing class PerformanceAccessUtil {
  	public static Id SystemAdministratorProfileId;
    public PerformanceReview__c    performanceReview;
    public String userInf = UserInfo.getUserId();
    User scorecardTypeProfile;
    User currentUser;
	boolean isManagerProfile = false;
	
    /* 
     * Constructor
     * cu - current user
     * scProfile - profile of the employee of the performance review
     */
    public PerformanceAccessUtil (PerformanceReview__c p, User cu, User scProfile){
        performanceReview = p; 
        currentUser = cu;
        scorecardTypeProfile = scProfile;
        
    	if  ((!getIsEmplMngr2ndMngrPCOMMOr3Pt()) && (getUserProfile() == 'Manager')){
	    	if (scorecardTypeProfile.Profile.Name.equals('Support Employee') || scorecardTypeProfile.Profile.Name.equals('Support Manager'))
	    		isManagerProfile = getIsMngrSupportProfile();
	    	if (scorecardTypeProfile.Profile.Name.equals('Education Employee') || scorecardTypeProfile.Profile.Name.equals('Education Manager'))
	    		isManagerProfile = getIsMngrEducationProfile();
	    	if (scorecardTypeProfile.Profile.Name.equals('Consulting Employee') || scorecardTypeProfile.Profile.Name.equals('Consulting Manager'))
	    		isManagerProfile = getIsMngrConsultingProfile();
	    	if (scorecardTypeProfile.Profile.Name.equals('CSM Employee') || scorecardTypeProfile.Profile.Name.equals('CSM Manager'))
	    		isManagerProfile = getIsMngrCSMProfile();
    	}
    }
 
 	public void setUserInf(String userId)
 	{
 		userInf = userId;
 	}
     // gets the profile of the current user
     public String getUserProfile(){
         return currentUser.Profile.Name;    
     }
     public String getUserProfileID(){
     	return currentUser.ProfileId;
     	}
 
 	// checks if it is assessment of metrics. This is used in the JavaScripts
 	// similar to function getIsMngr2ndMngrOr3PtInAssmnt
    public boolean getShowReviewScorecard()
    {
        if (userInf.equals(performanceReview.Manager__c)
                && performanceReview.Status__c.equals('Manager Assessment'))
            return true;

        if (userInf.equals(performanceReview.SecondManager__c)
                && performanceReview.Status__c.equals('2nd Level Manager Assessment'))
            return true;

        if (performanceReview.ThirdPartyReviewer__c != null)
        {
            if (userInf.equals(performanceReview.ThirdPartyReviewer__c)
                    && performanceReview.Status__c.equals('3rd Party Assessment'))
                return true;
        }
        
        if((getUserProfile() == Label.System_Administrator_label)
        && (performanceReview.Status__c.equals('Manager Assessment'))){
            return true;
        }

        return false;
    }
    
    // checks if it is assessment of methods. This is used in the JavaScripts
 	// similar to function getIsEmplMngr2ndMngrOr3PtInAssmnt
     public boolean getShowReviewEdit() {
         if(userInf.equals(performanceReview.Employee__c)
                 && performanceReview.Status__c.equals('Employee Self Assessment'))
             return true;

         if (userInf.equals(performanceReview.Manager__c)
                 && performanceReview.Status__c.equals('Manager Assessment'))
             return true;

         if (userInf.equals(performanceReview.SecondManager__c)
                 && performanceReview.Status__c.equals('2nd Level Manager Assessment'))
             return true;

         if (performanceReview.ThirdPartyReviewer__c != null)
         {
             if (userInf.equals(performanceReview.ThirdPartyReviewer__c)
                     && performanceReview.Status__c.equals('3rd Party Assessment'))
                 return true;
         }
         
        if((getUserProfile() == Label.System_Administrator_label || getUserProfile().equals('systemadministrator'))
        && ((performanceReview.Status__c.equals('Employee Self Assessment'))
        || (performanceReview.Status__c.equals('Manager Assessment')))){
            return true;
        }

         return false;
     } 

		// returns true if it's the SysAdmin in the Manager Assessment status
		// Used to filter this condition for the gray background in metrics 
		public boolean getIsSysAdminInMngrAssmnt(){
	        return ((getUserProfile() == Label.System_Administrator_label)
	        && (performanceReview.Status__c.equals('Manager Assessment')));
		}

     // Return true if the logged user is the manager of performance review or a SysAdmin
     // in the manager assessment status (can edit elements)
     public boolean getIsManager() {
         if (userInf.equals(performanceReview.Manager__c)
                 && performanceReview.Status__c.equals('Manager Assessment'))
                 return true;
                 
        if(getUserProfile() == Label.System_Administrator_label && (performanceReview.Status__c.equals('Manager Assessment'))){
            return true;
        }
         return false;
     }

     // Return true if the logged user is the employee of performance review no matter the status
     public boolean getIsEmployee() {
         return performanceReview.Employee__c == userInf;
     }
     
     // checks the logged user is the manager of the performance review or a SysAdmin no matter the status
    public boolean getIsManagerOrSecondManager()
    {
        if (performanceReview.Manager__c == userInf)
        {
            return true;    
        }
        
        if(getUserProfile() == Label.System_Administrator_label){
            return true;
        }

        return false;
    }

	// gets the second manager of the performance review
    public User getSecondManager()
    {
        User secondManager;
		if(performanceReview.SecondManager__c != null){
        	secondManager = [SELECT Manager__c FROM User Where Id =: performanceReview.SecondManager__c];
		}
        return secondManager; 
    }

	public boolean getIsOnlySysAdminProfile()
    {
    	//return (getUserProfileID() == PerformanceAccessUtil.getSystem_Administrator_Id() || getUserProfile()=='systemadministrator');
    	return (getUserProfile() ==Label.System_Administrator_Label|| getUserProfile()=='systemadministrator');
    }
    
    public boolean getIsIncompleteStatus(){
    	return performanceReview.Status__c == 'Incomplete';
    }
    
    public boolean getIsOnlyJuniorSysAdminProfile()
    {
    	return (getUserProfile() == 'Junior Admin');
    }
    
     // checks the logged user is the manager, 2nd manager or 3rd party
     // of the performance review or a SysAdmin no matter the status
    public boolean getIsManagerOrSecondManager3P()
    {
        if (performanceReview.Manager__c ==  userInf)
        {
            return true;
        }
        if (getSecondManager() != null){
	        if (getSecondManager().Id == userInf)
	        {
	            return true;    
	        }
        }
        if (performanceReview.ThirdPartyReviewer__c != null)
        {
            if (performanceReview.ThirdPartyReviewer__c == userInf)
            {
                return true;
            }
        }
        
        if(getUserProfile() == Label.System_Administrator_label){
            return true;
        }
        
        return false;
    }
	
	
	//Not show rating & weight in 3rd party assessment status
	
	public boolean showRatingAndWeightIn3rdPartyAssmnt(){
		if(((performanceReview.PreviousStatus__c == 'Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
			||((performanceReview.PreviousStatus__c == '2nd Level Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.SecondManager__c == userInfo.getUserId()))
			||((performanceReview.PreviousStatus__c == 'Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.Employee__c == userInfo.getUserId()))
			||((performanceReview.PreviousStatus__c == '2nd Level Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.Employee__c == userInfo.getUserId()))
			||((performanceReview.PreviousStatus__c == 'Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.PCOMM__c == userInfo.getUserId()))
			||((performanceReview.PreviousStatus__c == '2nd Level Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (performanceReview.PCOMM__c == userInfo.getUserId()))){
				return false;
		}
		return true;
	}
    //-------------------------------------------------------------------------------------------------

    //-----------------  USER PROFILES ----------------------------------------------------------------
    

    public boolean getIsEducationProfile(){
        
    	if (!scorecardTypeProfile.Profile.Name.equals('Education Employee')
    	&& !scorecardTypeProfile.Profile.Name.equals('Education Manager'))
    		return false;

        if (getIsEmplMngr2ndMngrOrPCOMM()){
            return true;
        }
        
        if(getIsESAdminProfile() || getIsSysAdminProfile() 
        || getIsEmplSucProfile() || getIsCEOProfile() || getIsMngrEducationProfile() || getIs3rdManager()){
            return true;
        }

        return false;
    }
      
     public boolean getIsEmplInAssmntOnly()
     {
     	return true;
     }  
    public boolean getIsSupportProfile(){
        
    	if (!scorecardTypeProfile.Profile.Name.equals('Support Employee')
    	&& !scorecardTypeProfile.Profile.Name.equals('Support Manager'))
    		return false;

        if (getIsEmplMngr2ndMngrOrPCOMM()){
            return true;
        }
        
        if(getIsESAdminProfile() || getIsSysAdminProfile() 
        || getIsEmplSucProfile() || getIsCEOProfile() || getIsMngrSupportProfile() || getIs3rdManager()){
            return true;
        }
    
        return false;
    }
    
    public boolean getIsConsultingProfile(){
        
    	if (!scorecardTypeProfile.Profile.Name.equals('Consulting Employee')
    	&& !scorecardTypeProfile.Profile.Name.equals('Consulting Manager'))
    		return false;

        if (getIsEmplMngr2ndMngrPCOMMOr3Pt()){
            return true;
        }
        
        if(getIsESAdminProfile() || getIsSysAdminProfile() 
        || getIsEmplSucProfile() || getIsCEOProfile() || getIsMngrConsultingProfile()){
            return true;
        }
    
        return false;
    }
    
    public boolean getIsCSMProfile(){
        
    	if (!scorecardTypeProfile.Profile.Name.equals('CSM Employee')
    	&& !scorecardTypeProfile.Profile.Name.equals('CSM Manager'))
    		return false;

        if (getIsEmplMngr2ndMngrPCOMMOr3Pt()){
            return true;
        }
        
        if(getIsESAdminProfile() || getIsSysAdminProfile() 
        || getIsEmplSucProfile() || getIsCEOProfile() || getIsMngrCSMProfile()){
            return true;
        }
    
        return false;
    }
    
    public boolean getIsScorecardProfile(){
        
    	if (scorecardTypeProfile.Profile.Name.equals('CSM Employee')
    		|| scorecardTypeProfile.Profile.Name.equals('CSM Manager')
    		|| scorecardTypeProfile.Profile.Name.equals('Support Employee')
	    	|| scorecardTypeProfile.Profile.Name.equals('Support Manager')
	    	|| scorecardTypeProfile.Profile.Name.equals('Consulting Employee')
	    	|| scorecardTypeProfile.Profile.Name.equals('Consulting Manager')
			|| scorecardTypeProfile.Profile.Name.equals('Education Employee')
	    	|| scorecardTypeProfile.Profile.Name.equals('Education Manager')){
    	
    		return true;
    	}
        return false;
    }

    // Return true if the logged user is of PCOMM profile
	// It could be the PCOMM of the performance review, so it needs to be considered
    public boolean getIsPCOMMProfile(){
         if(getUserProfile() == 'PCOMM'){
             return true;
         }
         return false;
    }

	// If the user has Manager profile and it is the manager of somebody with support profile
	// then the user can see the scorecards    
    public boolean getIsMngrProfile(){
        return isManagerProfile;
    }

	// If the user has Manager profile and it is the manager of somebody with Support profile
	// then the user can see the scorecards    
    public boolean getIsMngrSupportProfile(){
    	List<User> suppProf = [Select u.Id 
    							From User u 
    							where ((u.Profile.Name =: 'Support Employee') or
    									(u.Profile.Name =:'Support Manager')) and
    									 u.ReviewManager__c = :userInf];
    	
        if((suppProf.size()>0) && (getUserProfile() == 'Manager')){
            return true;
        }
        return false;
    }

	// If the user has Manager profile and it is the manager of somebody with Education profile
	// then the user can see the scorecards    
    public boolean getIsMngrEducationProfile(){
    	List<User> educationProf = [Select u.Id 
    								From User u 
    								where ((u.Profile.Name =:'Education Employee') or
    										(u.Profile.Name =:'Education Manager')) and
    										 u.ReviewManager__c = :userInf];
    
        if((educationProf.size()>0) && (getUserProfile() == 'Manager')){
            return true;
        }
        return false;
    }

	// If the user has Manager profile and it is the manager of somebody with Consulting profile
	// then the user can see the scorecards    
    public boolean getIsMngrConsultingProfile(){
    	List<User> consultingProf = [Select u.Id 
    								 From User u 
    								 where ((u.Profile.Name =:'Consulting Employee') or
    										(u.Profile.Name =:'Consulting Manager')) and
    									 	 u.ReviewManager__c = :userInf];
    									 
        if((consultingProf.size()>0) && (getUserProfile() == 'Manager')){
            return true;
        }
        return false;
    }

	// If the user has Manager profile and it is the manager of somebody with CSM profile
	// then the user can see the scorecards    
    public boolean getIsMngrCSMProfile(){
    	List<User> csmProf = [Select u.Id 
    							From User u 
    							where ((u.Profile.Name =:'CSM Employee') or
    									(u.Profile.Name =:'CSM Manager')) and
    									 u.ReviewManager__c = :userInf];
    
        if((csmProf.size()>0) && (getUserProfile() == 'Manager')){
            return true;
        }
        return false;
    }
    
      // Return true if the logged user is of ES Admin profile
    public boolean getIsESAdminProfile(){
        if((getUserProfile() == 'ES Admin') && (!getIsEmplMngr2ndMngrPCOMMOr3Pt())){
            return true;
        }
        return false;
    }
    
      // Return true if the logged user is of System Administrator profile
    public boolean getIsSysAdminProfile(){
        if((getUserProfileID() == PerformanceAccessUtil.getSystem_Administrator_Id() || getUserProfile() == 'systemadministrator') && (!getIsEmplMngr2ndMngrPCOMMOr3Pt())){
            return true;
        }
        return false;
    }
    
      // Return true if the logged user is of Employee Success/Business Partner profile
    public boolean getIsEmplSucProfile(){
        if((getUserProfile() == 'Employee Success/Business Partner') && (!getIsEmplMngr2ndMngrPCOMMOr3Pt())){
            return true;
        }
        return false;
    }
    
      // Return true if the logged user is of CEO profile
    public boolean getIsCEOProfile(){
        if((getUserProfile() == 'CEO') && (!getIsEmplMngr2ndMngrPCOMMOr3Pt())){
            return true;
        }
        return false;
    }

    // for those profiles not considered by the sharing rules that have same visibility as the PCOMM
    public boolean getPCOMMLikeViewProfile(){
        if((!getIsEmplMngr2ndMngrPCOMMOr3Pt())
        && (getIsESAdminProfile() || getIsSysAdminProfile() 
        || getIsEmplSucProfile() || getIsCEOProfile() || getIsMngrProfile())){
            return true;
        }
        if(getIsPCOMM()){
        	return true;
        }
        if(performanceReview.Employee__c == userInf && performanceReview.Status__c == 'Employee Approval'){
        	return true;
        }
        return false;    	
    }
    
    // checks all the profiles that can view the scorecards if there are scorecards
    public boolean getScorecardViewProfile(){
    
        if(getIsEducationProfile() || getIsSupportProfile() || getIsConsultingProfile() || getIsCSMProfile() 
        	|| getIsESAdminProfile() || getIsSysAdminProfile() || getIsEmplSucProfile() 
        	|| getIsCEOProfile() || getIsMngrProfile()){
            return true;
        }
        return false;
    }

    // returns true if it is not a profile that should see scorecards
    public boolean getHaveProfile(){
        if(!getIsEducationProfile() && !getIsSupportProfile() && !getIsConsultingProfile() && !getIsCSMProfile()){
            return false;
        }
        return true;
    }
    
    //--------------------- END OF USER PROFILES --------------------------------------------------

    //---------------------------------------------------------------------------------------------

    //--------------------- USER ACCESS FUNCTIONS -------------------------------------------------

     // Return true if the logged user is the employee of performance review no matter the status
     public boolean getIsEmpl() {
         return performanceReview.Employee__c == userInf;
     }

     // Return true if the logged user is the manager of performance review no matter the status
     public boolean getIsMngr() {
         return performanceReview.Manager__c == userInf;
     }

     // Return true if the logged user is the 2nd manager of performance review no matter the status
     public boolean getIs2ndMngr() {
         return performanceReview.SecondManager__c == userInf;
     }

     // Return true if the logged user is the 3rd party reviewer of performance review no matter the status
     public boolean getIs3rdParty() {
         return performanceReview.ThirdPartyReviewer__c == userInf;
     }

     // Return true if the logged user is the PCOMM reviewer of performance review no matter the status
     public boolean getIsPCOMM() {
         return performanceReview.PCOMM__c == userInf;
     }
    
    // Return true if the logged user is the Manager, 2nd Manager or PCOMM reviewer of performance review no matter the status
    public boolean getIsMngr2ndMngrOrPCOMM()
    {
        return (getIsMngr() || getIs2ndMngr() || getIsPCOMM());
    }

    // Return true if the logged user is the Manager, 2nd Manager, PCOMM reviewer 
    // or 3rd Party of performance review no matter the status
    public boolean getIsMngr2ndMngrPCOMMOr3Pt()
    {
        return (getIsMngr2ndMngrOrPCOMM() || getIs3rdParty());
    }
    
    // Return true if the logged user is the Employee, Manager, 2nd Manager or PCOMM reviewer of performance review no matter the status
    public boolean getIsEmplMngr2ndMngrOrPCOMM()
    {
        return (getIsEmpl() || getIsMngr2ndMngrOrPCOMM());
    }
    
    // Return true if the logged user is the Employee, Manager, 2nd Manager, PCOMM reviewer 
    // or 3rd Party of performance review no matter the status
    public boolean getIsEmplMngr2ndMngrPCOMMOr3Pt()
    {
        return (getIsEmplMngr2ndMngrOrPCOMM() || getIs3rdParty());
    }
    
    // Statuses after Manager Assessment and before employee approval or completed
    // - Read only Permission, just show
    // Rule applied to show metric adjusted ratings and calculated difference
    public boolean getStatusRO1(){
    	return(
    	performanceReview.Status__c.equals('2nd Level Manager Assessment')
    	|| performanceReview.Status__c.equals('Pending Employee Services')
    	|| performanceReview.Status__c.equals('PCOMM Review')
    	|| performanceReview.Status__c.equals('2nd Level Manager Approval')
    	|| performanceReview.Status__c.equals('Manager Approval')
    	);
    }

    // Statuses after Manager Assessment that do not include getStatusRO1
    // - Read only Permission, just show
    // Rule applied to show metric adjusted ratings and calculated difference
    public boolean getStatusRO2(){
    	return(
    	performanceReview.Status__c.equals('Complete')
    	|| performanceReview.Status__c.equals('Employee Approval')
    	|| performanceReview.Status__c.equals('3rd Party Assessment')
    	);
    	
    }

     // Statuses that only includes created and the employee assessment
     // Read only Permission, just show
    public boolean getStatusRO3(){
    	return(
    	performanceReview.Status__c.equals('Created') ||
    	performanceReview.Status__c.equals('Employee Self Assessment')
    	);
    }
   
    // Employee in Assessment - Write permission
     public boolean getIsEmplInAssmnt() {
     	
     	Boolean firstCondition = userInf.equals(performanceReview.Employee__c) && performanceReview.Status__c.equals('Employee Self Assessment');
     	Boolean secondCondition =  (getUserProfileID() == PerformanceAccessUtil.getSystem_Administrator_Id() || getUserProfile() == 'systemadministrator') && performanceReview.Status__c.equals('Employee Self Assessment');
     	
     	if	(firstCondition || secondCondition)
     	{
     		return true;
     	} 
         return false;
     }   
     
    // Employee in 3rd Party Assessment - Read permission for exceptions in this case
     public boolean getIsEmplIn3PtAssmnt() {
         if (userInf.equals(performanceReview.Employee__c)
                 && performanceReview.Status__c.equals('3rd Party Assessment'))
             return true;
         return false;
     }   
     
    // Manager in Assessment - Write permission
     public boolean getIsMngrInAssmnt() {
         if ((userInf.equals(performanceReview.Manager__c) || getIsSysAdminProfile())
                 && performanceReview.Status__c.equals('Manager Assessment'))
             return true;
         return false;
     }   

    // 2nd Manager in Assessment - Write permission
     public boolean getIs2ndMngrInAssmnt() {
         if (userInf.equals(performanceReview.SecondManager__c)
                 && performanceReview.Status__c.equals('2nd Level Manager Assessment'))
             return true;
         return false;
     }   

    // 3rd Party in Assessment - Write permission
     public boolean getIs3PtInAssmnt() {
         if (userInf.equals(performanceReview.ThirdPartyReviewer__c)
                 && performanceReview.Status__c.equals('3rd Party Assessment'))
             return true;
         return false;
     }   
      
     public boolean getOnlyEmployeeInAssmnt(){
     	 if ((userInf.equals(performanceReview.Employee__c) && (performanceReview.Status__c.equals('Employee Self Assessment')))){
     	 	return true;
     	 }
     	 return false;
     }
      // Employee, Manager, 2nd Manager - Write permission
     public boolean getIsEmplMngr2ndMngr(){
         return (getOnlyEmployeeInAssmnt() || getIsMngrInAssmnt() || getIs2ndMngrInAssmnt());
     } 
    // Employee, Manager, 2nd Manager or 3rd Party in Assessment - Write permission
     public boolean getIsEmplMngr2ndMngrOr3PtInAssmnt() {
         return (getIsEmplInAssmnt() || getIsMngrInAssmnt() || getIs2ndMngrInAssmnt() || getIs3PtInAssmnt());
     } 
     
      // Manager, 2nd Manager or 3rd Party in Assessment - Write permission in scorecard object
     public boolean getIsMngr2ndMngrOr3PtInAssmnt() {
         return (getIsMngrInAssmnt() || getIs2ndMngrInAssmnt() || getIs3PtInAssmnt());
     } 
     
     public boolean getIs3rdManager(){
     	if(performanceReview.SecondManager__c != null){
		 	User thirdManager = [Select Id, u.ReviewManager__c, u.Manager__c From User u where Id =:  performanceReview.SecondManager__c];
		 	
		 	if(thirdManager != null){
		 		if(userInf.equals(thirdManager.ReviewManager__c)){
		 			return true;
		 		}	
		 	}
		 	else{
		 		return true;	
		 	}
     	}	
	 	return false;
	 }

// -------------------- Functions for Step 1 --------------------------------------

     // shows save buttons for users that are in assessment status and have NO scorecards
     public boolean getIsSaveMode(){
     	return ((getIsEmplMngr2ndMngrOr3PtInAssmnt() && 
				!(getIsEducationProfile() || getIsSupportProfile() 
				|| getIsConsultingProfile() || getIsCSMProfile()
     			|| getIsSysAdminProfile()))
     			&& !getIs3PtInAssmnt()
        );
     }
     
     // shows save buttons for users that are in assessment status and have scorecards
     public boolean getIsSaveScorecardMode(){
     	return ((getIsMngr2ndMngrOr3PtInAssmnt() && 
				(getIsEducationProfile() || getIsSupportProfile() 
				|| getIsConsultingProfile() || getIsCSMProfile()
     			|| getIsSysAdminProfile()))
     			|| getIs3PtInAssmnt()
        );
     }

// -------------------- Functions for Support Metrics --------------------------------------

	// determines the users and statuses in which the difference can be shown
	public boolean getDifferenceView(){
		return (((getIsMngr2ndMngrOrPCOMM() || getPCOMMLikeViewProfile()) 
		&& (getStatusRO1() || getStatusRO2()))
			|| getIsMngrInAssmnt() || getIs3PtInAssmnt());
	}
	
	// determines the users and statuses in which the adjusted rating can be shown
	public boolean getAdjustedRatingView(){
		return (((getIsMngr2ndMngrOrPCOMM() || getPCOMMLikeViewProfile()) && getStatusRO1()) 
			|| ((getIsEmplMngr2ndMngrPCOMMOr3Pt() || getPCOMMLikeViewProfile()) && getStatusRO2() && !getIsEmplIn3PtAssmnt())
			|| getIsMngrInAssmnt());
	}

// -------------------- Functions for Step 3 --------------------------------------

	// determines the users and statuses in which the overall calculated method rating can be shown
	public boolean getOverallCalcMethodRatingView(){
		if(((performanceReview.PreviousStatus__c == 'Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (this.getIsSysAdminProfile())) 
			||((performanceReview.PreviousStatus__c == '2nd Level Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (this.getIsSysAdminProfile()))
			||((performanceReview.PreviousStatus__c == '2nd Level Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (this.getIsMngr()))
			||((performanceReview.PreviousStatus__c == 'Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (this.getIsMngr()))){
				return true;
		}
		if ((performanceReview.PreviousStatus__c == 'Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment'))
			return false; 
		return (((getIsMngr2ndMngrOrPCOMM() || getPCOMMLikeViewProfile()) && getStatusRO1()) 
			|| ((getIsEmplMngr2ndMngrPCOMMOr3Pt() || getPCOMMLikeViewProfile()) && getStatusRO2() && !getIs3PtInAssmnt() && !getIsEmplIn3PtAssmnt())
			|| getIsMngrInAssmnt() || getIs3rdManager());
	}

	// determines the users and statuses in which the overall calculated metric rating can be shown
	public boolean getOverallCalcMetricRatingView(){
		if(((performanceReview.PreviousStatus__c == 'Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (this.getIsSysAdminProfile())) 
			||((performanceReview.PreviousStatus__c == '2nd Level Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (this.getIsSysAdminProfile()))
			||((performanceReview.PreviousStatus__c == '2nd Level Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (this.getIsMngr()))
			||((performanceReview.PreviousStatus__c == 'Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (this.getIsMngr()))){
				return true;
		}
		if ((performanceReview.PreviousStatus__c == 'Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment'))
			return false; 
		return (((getIsMngr2ndMngrOrPCOMM() || getPCOMMLikeViewProfile()) && getStatusRO1()) 
			|| ((getIsEmplMngr2ndMngrPCOMMOr3Pt() || getPCOMMLikeViewProfile()) && getStatusRO2() && !getIsEmplIn3PtAssmnt())
			|| getIsMngrInAssmnt() || getIs3rdManager());
	}

	// determines the users and statuses in which the overall calculated competency rating can be shown
	public boolean getOverallCalcCompRatingView(){
		if(((performanceReview.PreviousStatus__c == 'Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (this.getIsSysAdminProfile())) 
			||((performanceReview.PreviousStatus__c == '2nd Level Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (this.getIsSysAdminProfile()))
			||((performanceReview.PreviousStatus__c == '2nd Level Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (this.getIsMngr()))
			||((performanceReview.PreviousStatus__c == 'Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (this.getIsMngr()))){
				return true;
		}
		if ((performanceReview.PreviousStatus__c == 'Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment'))
			return false; 
		return (((getIsMngr2ndMngrOrPCOMM() || getPCOMMLikeViewProfile()) && getStatusRO1()) 
			|| ((getIsEmplMngr2ndMngrPCOMMOr3Pt() || getPCOMMLikeViewProfile()) && getStatusRO2() && !getIs3PtInAssmnt() && !getIsEmplIn3PtAssmnt())
			|| getIsMngrInAssmnt() || getIs3rdManager());
	}

	// determines the users and statuses in which the overall calculated rating can be shown
	public boolean getOverallRatingView(){
		if(((performanceReview.PreviousStatus__c == 'Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (this.getIsSysAdminProfile())) 
			||((performanceReview.PreviousStatus__c == '2nd Level Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (this.getIsSysAdminProfile()))
			||((performanceReview.PreviousStatus__c == '2nd Level Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (this.getIsMngr()))
			||((performanceReview.PreviousStatus__c == 'Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment') && (this.getIsMngr()))){
				return true;
		}
		if ((performanceReview.PreviousStatus__c == 'Manager Assessment') && (performanceReview.Status__c == '3rd Party Assessment'))
			return false; 
		return (((getIsMngr2ndMngrOrPCOMM() || getPCOMMLikeViewProfile()) && getStatusRO1()) 
			|| ((getIsEmplMngr2ndMngrPCOMMOr3Pt() || getPCOMMLikeViewProfile()) && getStatusRO2() && !getIs3PtInAssmnt() && !getIsEmplIn3PtAssmnt())
			|| getIsMngrInAssmnt() || getIs3rdManager());
	}
	
	public static Id getSystem_Administrator_Id(){
		if (SystemAdministratorProfileId == null){
			SystemAdministratorProfileId = [Select Id From Profile Where Name =: Label.System_Administrator_label].Id;
		}
		
		return SystemAdministratorProfileId;
	}

}