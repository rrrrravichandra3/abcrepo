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
 * @author Mike Fullmore - 4/2/2009
*/

public with sharing class ViewReviewPeriodController {
 
    private PerformanceReviewPeriod__c          period;
    Id                                      currentUserId;

   // The extension constructor initializes the private member
    // variable by using the getSubject method on the standard
    // controller.
    public ViewReviewPeriodController (ApexPages.StandardController stdController) {
        period = (PerformanceReviewPeriod__c)stdController.getSubject();
        
        period = [Select Id,
                         Name,
                         Status__c,
                         OwnerId, 
                         StartDate__c,
                         EndDate__c,
                         Effective_Date__c,
                         V2MOM_Type__c
                  From PerformanceReviewPeriod__c
                  Where Id =:period.Id];
                  
        currentUserId = userInfo.getUserId();

    }

    public boolean getShowAdminOptions() {

        /**
        * Employee Service Admin
        */
        List<GroupMember> groupMember= [SELECT Id
                                        FROM GroupMember
                                        WHERE GroupId =: PAMUtil.getESAdminQueue()
                                        AND UserOrGroupId =: currentUserId];

        if (groupMember.size() != 0) return true;

        // Employee Services
        List<GroupMember> esgroupMember= [SELECT Id
                                          FROM GroupMember
                                          WHERE GroupId =: PAMUtil.getEmployeeServicesQueue()
                                          AND UserOrGroupId =: currentUserId];

        if (esgroupMember.size() != 0) return true;

        return false;

    }

    public Boolean getShowSingleDepartment() {
        return (period.V2MOM_Type__c != null && period.V2MOM_Type__c.equals('Ad Hoc')); 
    }    
    
    public List<ReviewPeriodDepartment__c> getDepartments() {
        List<ReviewPeriodDepartment__c> revDepts = new List<ReviewPeriodDepartment__c>();
        List<ReviewPeriodDepartment__c> depts = new List<ReviewPeriodDepartment__c>();
        //revDepts = [SELECT Department__r.Name, Department__r.Id FROM ReviewPeriodDepartment__c WHERE PerformanceReviewPeriod__c =: period.Id order by Department__r.Id];
        revDepts = [SELECT Cost_Center__r.Name, Cost_Center__r.Id FROM ReviewPeriodDepartment__c WHERE PerformanceReviewPeriod__c =: period.Id order by Cost_Center__r.Id];
        
        for(Integer i = 0; i < revDepts.size(); i++){
        	ReviewPeriodDepartment__c dep = revDepts[i];
        	if(i == 0){
        		depts.add(dep);
        	}
        	else{
        		//if(revDepts[i - 1].Department__c != dep.Department__c){
        		if(revDepts[i - 1].Cost_Center__c != dep.Cost_Center__c){
        			depts.add(dep);
        		}
        	}	        	
        }         
        return  depts;
    }    

    public PerformanceReviewPeriod__c getPeriod() {
        return period;
    }    
}