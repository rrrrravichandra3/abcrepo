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


public without sharing class V2MOM_Util{
    
    
    public static Boolean currently_executing_trigger = false;
    public static Boolean currently_executing_trigger_scorecardSupportReviewAfterInsert = false;
    public static Boolean currently_deleting_value = false;
    public static Boolean currently_deleting_method = false;
    public static Boolean cancelUpdateInHandBook = true;
    public static Boolean already_executed_check_for_locked = false;

    public static Boolean error_deleting_method = false;
    public static Boolean error_deleting_obstacle = false;
    public static Boolean error_deleting_measure = false;
    
    public static Boolean isTest = false;
    public static String test = 'test';
    public static Boolean disable_all_sharing_triggers = false;
    public static Boolean cancel_locked_v2mom = false; 
    
    public static void setAlready_executed_check_for_locked (Boolean a) {
        already_executed_check_for_locked = a;
    }
    
    public static void check_for_locked_v2moms( Map<Id, Set<Integer>> v2mom_with_changing_children, Boolean isInsert, Boolean isDelete, String object_name, SObject[] old_children, SObject[] new_children) {       
        if (!already_executed_check_for_locked) {
            already_executed_check_for_locked = true;
            
            
            User currentUser = [select Id, Profile.Name from User Where id =: userInfo.getUserId()];
            
            Set<Id> locked_v2moms = new Set<Id>();        
            
            if (!v2mom_with_changing_children.keySet().isEmpty()) {       
                for (V2MOM__c v2mom : [select Id from V2MOM__c where (Id in :v2mom_with_changing_children.keySet()) and (Locked__c = true)]) {
                    locked_v2moms.add(v2mom.Id);
                }
            }
            
            for (Id v2mom : locked_v2moms) {
                System.assert(v2mom_with_changing_children.keySet().contains(v2mom));
                Set<Integer> values_for_v2mom = v2mom_with_changing_children.get(v2mom);
                for (Integer i : values_for_v2mom) {
                	
                	if (currentUser.Profile.id != PerformanceAccessUtil.getSystem_Administrator_Id())
                    if (isDelete) {
                        if (old_children.size() > i)
                            old_children[i].addError(Label.You_cannot_delete_this_label + ' ' + object_name + ' ' + Label.cannot_be_deleted_because_its_V2MOM_is_locked_label);
                    } else if (isInsert) {
                        if (new_children.size() > i)
                            new_children[i].addError(Label.You_cannot_create_a_new_label + ' ' + object_name + ' ' + Label.cannot_be_deleted_because_its_V2MOM_is_locked_label);
                    } else {
                        if (new_children.size() > i)
                            new_children[i].addError(Label.You_cannot_edit_this_label + ' ' + object_name + ' ' + Label.cannot_be_deleted_because_its_V2MOM_is_locked_label);
                    }
                }
            }
        }
    }
    
    public static void add_child_index_to_map(Id v2mom, Integer child_index, Map<Id, Set<Integer>> v2mom_with_changing_children) {
        if (v2mom != null) {
            Set<Integer> children_for_v2mom = v2mom_with_changing_children.get(v2mom);
            if (children_for_v2mom == null) {
                children_for_v2mom = new Set<Integer>();
                v2mom_with_changing_children.put(v2mom, children_for_v2mom);
            }
            children_for_v2mom.add(child_index);
        }
    }
    
    public static Boolean v2mom_change_that_would_require_reapproval(V2MOM__c old_val, V2MOM__c new_val) {
        return ((old_val.Effective_Date__c != new_val.Effective_Date__c) || (old_val.OwnerId != new_val.OwnerId) || (old_val.Name != new_val.Name) || (old_val.Vision__c != new_val.Vision__c));
    }
    
    public static Boolean value_change_that_would_require_reapproval(Value__c old_val, Value__c new_val) {
        return ((old_val.Priority__c != new_val.Priority__c) || (old_val.Name != new_val.Name) || (old_val.Tag_Line__c != new_val.Tag_Line__c));
    }
    
    public static Boolean method_change_that_would_require_reapproval(Method__c old_val, Method__c new_val) {
        return ((old_val.Value__c != new_val.Value__c) || (old_val.Priority__c != new_val.Priority__c) || (old_val.Name != new_val.Name) || (old_val.Description__c != new_val.Description__c) || (old_val.Accountable_Person__c != new_val.Accountable_Person__c));
    }

    public static Boolean obstacle_change_that_would_require_reapproval(Obstacle__c old_val, Obstacle__c new_val) {
        return ((old_val.Value__c != new_val.Value__c) || (old_val.Method__c != new_val.Method__c) || (old_val.Priority__c != new_val.Priority__c) || (old_val.Description__c != new_val.Description__c));
    }
    
    public static Boolean measure_change_that_would_require_reapproval(Measure__c old_val, Measure__c new_val) {
        return ((old_val.Value__c != new_val.Value__c) || (old_val.Method__c != new_val.Method__c) || (old_val.Priority__c != new_val.Priority__c) || (old_val.Description__c != new_val.Description__c) || (old_val.Start_Date__c != new_val.Start_Date__c) || (old_val.End_Date__c != new_val.End_Date__c));
    }    
    
    public static Double getMaxMeasurePriorityFromMethod (Measure__c insertMeasure) {
        Method__c currentMeasureValue = [Select Id, Priority__c FROM Method__c WHERE Id =: insertMeasure.Method__c ];
        List <Method__c> methodsWithLessPriority = [SELECT v.Id, v.Name, v.Priority__c, (SELECT Id, Name, Priority__c FROM Measures__r ORDER BY Priority__c DESC) FROM Method__c v WHERE V2MOM__c =: insertMeasure.V2MOM__c AND Priority__c <: currentMeasureValue.Priority__c ORDER BY Priority__c DESC];
        List <Measure__c> measuresWitoutMethod = [SELECT Id, Priority__c FROM Measure__c WHERE V2MOM__c =: insertMeasure.V2MOM__c AND Method__c = null ORDER BY Priority__c ASC ];
        Double maxPriority = 0;
        Boolean found = false;
        
        for (Method__c  currentMethod : methodsWithLessPriority ) {
            if ((currentMethod.Measures__r.size() > 0) && (found == false) ) {
                maxPriority = currentMethod.Measures__r[0].Priority__c;
                found = true;
            }
        }
        
        //Check if obstacle without method has same priority
        
        for (Measure__c measure : measuresWitoutMethod) {
            if (maxPriority + 1 == measure.Priority__c) {
                //if some method has the same priority
            
                maxPriority = measure.Priority__c;
            }   
        }   
        
        return maxPriority;
    }
    
    public static Double getMaxObstaclePriorityFromMethod (Obstacle__c insertObstacle) {
        
        Method__c currentObstacleValue = [Select Id, Priority__c FROM Method__c WHERE Id =: insertObstacle.Method__c ];
        List <Method__c> methodsWithLessPriority = [SELECT v.Id, v.Name, v.Priority__c, (SELECT Id, Name, Priority__c FROM Obstacles__r ORDER BY Priority__c DESC) FROM Method__c v WHERE V2MOM__c =: insertObstacle.V2MOM__c AND Priority__c <: currentObstacleValue.Priority__c ORDER BY Priority__c DESC];
        List <Obstacle__c> obstaclesWitoutMethod = [SELECT Id, Priority__c FROM Obstacle__c WHERE V2MOM__c =: insertObstacle.V2MOM__c AND Method__c = null ORDER BY Priority__c ASC ];
        Double maxPriority = 0;
        Boolean found = false;
        
        for (Method__c  currentMethod : methodsWithLessPriority ) {
            if ((currentMethod.Obstacles__r.size() > 0) && (found == false) ) {
                maxPriority = currentMethod.Obstacles__r[0].Priority__c;
                found = true;
            }
        }
        
        //Check if obstacle without method has same priority
        
        for (Obstacle__c obstacle : obstaclesWitoutMethod) {
            if (maxPriority + 1 == obstacle.Priority__c) {
                //if some method has the same priority            
                maxPriority = obstacle.Priority__c;
            }   
        }   
        
        return maxPriority;    
    }
    
    public static Double getMaxMethodPriorityPreviousValue(Method__c insertMethod) {
        Value__c currentMethodValue = [Select Id, Priority__c FROM Value__c WHERE Id =: insertMethod.Value__c ];
        List <Value__c> valueWithLessPriority = [SELECT v.Id, v.Name, v.Priority__c, (SELECT Id, Name, Priority__c FROM Methods__r ORDER BY Priority__c DESC) FROM Value__c v WHERE V2MOM__c =: insertMethod.V2MOM__c AND Priority__c <: currentMethodValue.Priority__c ORDER BY Priority__c DESC];
        List <Method__c> methodsWitoutValues = [SELECT Id, Priority__c FROM Method__c WHERE V2MOM__c =: insertMethod.V2MOM__c AND Value__c = null ORDER BY Priority__c ASC ];
        Double maxPriority = 0;
        Boolean found = false;
        
        for (Value__c currenValue : valueWithLessPriority) {
            if ((currenValue.Methods__r.size() > 0) && (found == false) ) {
                maxPriority = currenValue.Methods__r[0].Priority__c;
                found = true;
            }
        }
        
        //Check if method without same value has same priority
        for (Method__c method : methodsWitoutValues) {
            if (maxPriority + 1 == method.Priority__c) {
                //if some method has the same priority
                maxPriority = method.Priority__c;
            }   
        }
        
        return maxPriority;        
    }
    
    public static Double getMaxMethodPriorityFromValue(Method__c insertMethod) {
        List <Method__c> allMethodsInValue = new List<Method__c>();
        if (!isTest) {
            allMethodsInValue = [SELECT Priority__c FROM Method__c WHERE Value__c =: insertMethod.Value__c ORDER BY Priority__c DESC];
        }
        else {
            allMethodsInValue = [SELECT Priority__c FROM Method__c WHERE Value__c =: insertMethod.Value__c ORDER BY Priority__c DESC limit 10];
        }
        
        Double maxValue;
        
        if (allMethodsInValue.size() > 0 ) {
            maxValue = allMethodsInValue[0].Priority__c;
        }
        else {
            maxValue = 1;   
        }
        
        return maxValue;
    }
    
    public static Double getMaxValuePreviousPriorityFromV2MOM(Value__c insertValue) {
        List<Value__c> allValues = [SELECT Priority__c FROM Value__c WHERE V2MOM__c =: insertValue.V2MOM__c];
        
        return allValues.size();
    }
    
    public static Double getMaxMethodPreviousPriorityFromV2MOM(Method__c insertMethod) {
        List <Method__c> allMethods = [SELECT Priority__c FROM Method__c WHERE V2MOM__c =: insertMethod.V2MOM__c];
        
        return allMethods.size();
    }
    
    public static Double getMaxObstaclePreviousPriorityFromV2MOM(Obstacle__c insertObstacle) {
        List <Obstacle__c> allObstacles = [SELECT Priority__c FROM Obstacle__c WHERE V2MOM__c =: insertObstacle.V2MOM__c];
        
        return allObstacles.size();
    }
    
    public static Double getMaxMeasurePreviousPriorityFromV2MOM(Measure__c insertMeasure) {
        List <Measure__c> allMeasures = [SELECT Priority__c FROM Measure__c WHERE V2MOM__c =: insertMeasure.V2MOM__c];
        
        return allMeasures.size();
    }
    
    public static Double getMaxMeasurePriorityInMethod(Measure__c measure) {
        List <Measure__c> allMeasuresInValue = [SELECT Priority__c FROM Measure__c WHERE Method__c =: measure.Method__c ORDER BY Priority__c DESC];
        Double maxValue;
        
        if (allMeasuresInValue.size() > 0 ) {
            maxValue = allMeasuresInValue[0].Priority__c;
        }
        else {
            maxValue = 1;   
        }
        
        return maxValue;
    }
    
    public static Double getMinMeasurePriorityInMethod(Measure__c measure) {
        List <Measure__c> allMeasuresInValue = [SELECT Priority__c FROM Measure__c WHERE Method__c =: measure.Method__c ORDER BY Priority__c ASC];
        Double maxValue;
        
        if (allMeasuresInValue.size() > 0 ) {
            maxValue = allMeasuresInValue[0].Priority__c;
        }
        else {
            maxValue = 1;   
        }
        
        return maxValue;
    }
    
    public static Double getMinMethodPriorityFromValue(Method__c insertMethod) {
        List <Method__c> allMethodsInValue = new List<Method__c>();
        if (!isTest) {
            allMethodsInValue = [SELECT Priority__c FROM Method__c WHERE Value__c =: insertMethod.Value__c ORDER BY Priority__c ASC];
        }
        else {
            allMethodsInValue = [SELECT Priority__c FROM Method__c WHERE Value__c =: insertMethod.Value__c ORDER BY Priority__c ASC limit 10];
        }
        
        Double minValue;
        
        if (allMethodsInValue.size() > 0 ) {
            minValue = allMethodsInValue[0].Priority__c;
        }
        else {
            minValue = 1;   
        }
        
        return minValue;
    }
    
    public static void updateValuePriority(Value__c insertValue, Double priority) {
        Value__c theValue = [SELECT Id, Priority__c FROM Value__c Where Id =: insertValue.Id ];
        
        if (theValue != null) {
            theValue.Priority__c = priority;
            update theValue;
        }
    }
    
    public static void updateMethodPriority(Method__c insertMethod, Double priority) {
        Method__c theMethod = [SELECT Id, Priority__c FROM Method__c Where Id =: insertMethod.Id ];
        
        if (theMethod != null) {
            theMethod.Priority__c = priority;
            update theMethod;
        }
    }
    
    public static void updateMeasurePriority(Measure__c insertMeasure,Double priority) {
        Measure__c measure = [SELECT Id, Priority__c FROM Measure__c Where Id =: insertMeasure.Id ];
        
        if (measure != null) { 
            measure.Priority__c = priority;
            update measure;
        }
    }
    
    public static void updateObstaclePriority(Obstacle__c insertObstacle,Double priority) {
        Obstacle__c obstacle = [SELECT Id, Priority__c FROM Obstacle__c Where Id =: insertObstacle.Id ];
        
        if (obstacle != null) { 
            obstacle.Priority__c = priority;
            update obstacle;
        }
    }
    
    
    //HERE SCORECARD FUNCTIONS
    public static String getSalesImpactRating(ScorecardSupportReview__c scorecardQ1, ScorecardSupportReview__c scorecardQ2, ScorecardSupportReview__c scorecardQ3, ScorecardSupportReview__c scorecardQ4) {
     
         if (scorecardQ1 != null && scorecardQ1.SalesImpactRating__c != null) {
            return  getRatingDescription(scorecardQ1.SalesImpactRating__c.intValue());
         }
         
         if (scorecardQ2 != null && scorecardQ2.SalesImpactRating__c != null) {
            return  getRatingDescription(scorecardQ2.SalesImpactRating__c.intValue());
         }
         
         if (scorecardQ3 != null && scorecardQ3.SalesImpactRating__c != null) {
            return  getRatingDescription(scorecardQ3.SalesImpactRating__c.intValue());
         }
         
         if (scorecardQ4 != null && scorecardQ4.SalesImpactRating__c != null) {
            return  getRatingDescription(scorecardQ4.SalesImpactRating__c.intValue());
         }
         
         return '-';
    }
            
    public static String getSalesImpactWeight(ScorecardSupportReview__c scorecardQ1, ScorecardSupportReview__c scorecardQ2, ScorecardSupportReview__c scorecardQ3, ScorecardSupportReview__c scorecardQ4) {    
         if (scorecardQ1 != null && scorecardQ1.SalesImpactWeight__c != null) {
            return  String.valueOf(scorecardQ1.SalesImpactWeight__c);
         }
         
         if (scorecardQ2 != null && scorecardQ2.SalesImpactWeight__c != null) {
            return  String.valueOf(scorecardQ2.SalesImpactWeight__c);
         }
         
         if (scorecardQ3 != null && scorecardQ3.SalesImpactWeight__c != null) {
            return  String.valueOf(scorecardQ3.SalesImpactWeight__c);
         }
         
         if (scorecardQ4 != null && scorecardQ4.SalesImpactWeight__c != null) {
            return  String.valueOf(scorecardQ4.SalesImpactWeight__c);
         }
         
        return '-';
    }
        
    public static  String getTimeOnPlatformRating(ScorecardSupportReview__c scorecardQ1, ScorecardSupportReview__c scorecardQ2, ScorecardSupportReview__c scorecardQ3, ScorecardSupportReview__c scorecardQ4) {
         if (scorecardQ1 != null && scorecardQ1.TimeOnPlatformRating__c != null) {
            return  getRatingDescription(scorecardQ1.TimeOnPlatformRating__c.intValue());
         }
         
         if (scorecardQ2 != null && scorecardQ2.TimeOnPlatformRating__c != null) {
            return  getRatingDescription(scorecardQ2.TimeOnPlatformRating__c.intValue());
         }
         
         if (scorecardQ3 != null && scorecardQ3.TimeOnPlatformRating__c != null) {
            return  getRatingDescription(scorecardQ3.TimeOnPlatformRating__c.intValue());
         }
         
         if (scorecardQ4 != null && scorecardQ4.TimeOnPlatformRating__c != null) {
            return  getRatingDescription(scorecardQ4.TimeOnPlatformRating__c.intValue());
         }
         
         return '-';
    }
        
       
        
    public static String getTimeOnPlatformWeight(ScorecardSupportReview__c scorecardQ1, ScorecardSupportReview__c scorecardQ2, ScorecardSupportReview__c scorecardQ3, ScorecardSupportReview__c scorecardQ4) {    
         if (scorecardQ1 != null && scorecardQ1.TimeOnPlatformWeight__c != null) {
            return  String.valueOf(scorecardQ1.TimeOnPlatformWeight__c);
         }
         
         if (scorecardQ2 != null && scorecardQ2.TimeOnPlatformWeight__c != null) {
            return  String.valueOf(scorecardQ2.TimeOnPlatformWeight__c);
         }
         
         if (scorecardQ3 != null && scorecardQ3.TimeOnPlatformWeight__c != null) {
            return  String.valueOf(scorecardQ3.TimeOnPlatformWeight__c);
         }
         
         if (scorecardQ4 != null && scorecardQ4.TimeOnPlatformWeight__c != null) {
            return  String.valueOf(scorecardQ4.TimeOnPlatformWeight__c);
         }
         
        return '-';
    }
        
    public static String getForecastAccuracyRating(ScorecardSupportReview__c scorecardQ1, ScorecardSupportReview__c scorecardQ2, ScorecardSupportReview__c scorecardQ3, ScorecardSupportReview__c scorecardQ4) {
         if (scorecardQ1 != null && scorecardQ1.ForecastAccuracyRating__c != null) {
            return  getRatingDescription(scorecardQ1.ForecastAccuracyRating__c.intValue());
         }
         
         if (scorecardQ2 != null && scorecardQ2.ForecastAccuracyRating__c != null) {
            return  getRatingDescription(scorecardQ2.ForecastAccuracyRating__c.intValue());
         }
         
         if (scorecardQ3 != null && scorecardQ3.ForecastAccuracyRating__c != null) {
            return  getRatingDescription(scorecardQ3.ForecastAccuracyRating__c.intValue());
         }
         
         if (scorecardQ4 != null && scorecardQ4.ForecastAccuracyRating__c != null) {
            return  getRatingDescription(scorecardQ4.ForecastAccuracyRating__c.intValue());
         }
         
         return '-';
    }
      
    public static String getForecastAccuracyWeight(ScorecardSupportReview__c scorecardQ1, ScorecardSupportReview__c scorecardQ2, ScorecardSupportReview__c scorecardQ3, ScorecardSupportReview__c scorecardQ4) {    
         if (scorecardQ1 != null && scorecardQ1.ForecastAccuracyWeight__c != null) {
            return  String.valueOf(scorecardQ1.ForecastAccuracyWeight__c);
         }
         
         if (scorecardQ2 != null && scorecardQ2.ForecastAccuracyWeight__c != null) {
            return  String.valueOf(scorecardQ2.ForecastAccuracyWeight__c);
         }
         
         if (scorecardQ3 != null && scorecardQ3.ForecastAccuracyWeight__c != null) {
            return  String.valueOf(scorecardQ3.ForecastAccuracyWeight__c);
         }
         
         if (scorecardQ4 != null && scorecardQ4.ForecastAccuracyWeight__c != null) {
            return  String.valueOf(scorecardQ4.ForecastAccuracyWeight__c);
         }
         
        return '-';
    }
    
    
    // To CSM Scorecards
    
    public static String getRenewalExcellenceRating(ScorecardSupportReview__c scorecardQ1, ScorecardSupportReview__c scorecardQ2, ScorecardSupportReview__c scorecardQ3, ScorecardSupportReview__c scorecardQ4) {
         if (scorecardQ1 != null && scorecardQ1.RenewalExcellenceRating__c != null) {
            return  getRatingDescription(scorecardQ1.RenewalExcellenceRating__c.intValue());
         }
         
         if (scorecardQ2 != null && scorecardQ2.RenewalExcellenceRating__c != null) {
            return  getRatingDescription(scorecardQ2.RenewalExcellenceRating__c.intValue());
         }
         
         if (scorecardQ3 != null && scorecardQ3.RenewalExcellenceRating__c != null) {
            return  getRatingDescription(scorecardQ3.RenewalExcellenceRating__c.intValue());
         }
         
         if (scorecardQ4 != null && scorecardQ4.RenewalExcellenceRating__c != null) {
            return  getRatingDescription(scorecardQ4.RenewalExcellenceRating__c.intValue());
         }
         
         return '-';
    }
      
    public static String getRenewalExcellenceWeight(ScorecardSupportReview__c scorecardQ1, ScorecardSupportReview__c scorecardQ2, ScorecardSupportReview__c scorecardQ3, ScorecardSupportReview__c scorecardQ4) {    
         if (scorecardQ1 != null && scorecardQ1.RenewalExcellenceWeight__c != null) {
            return  String.valueOf(scorecardQ1.RenewalExcellenceWeight__c);
         }
         
         if (scorecardQ2 != null && scorecardQ2.RenewalExcellenceWeight__c != null) {
            return  String.valueOf(scorecardQ2.RenewalExcellenceWeight__c);
         }
         
         if (scorecardQ3 != null && scorecardQ3.RenewalExcellenceWeight__c != null) {
            return  String.valueOf(scorecardQ3.RenewalExcellenceWeight__c);
         }
         
         if (scorecardQ4 != null && scorecardQ4.RenewalExcellenceWeight__c != null) {
            return  String.valueOf(scorecardQ4.RenewalExcellenceWeight__c);
         }
         
        return '-';
    }
    
    
    public static String getOperationalExcellenceRating(ScorecardSupportReview__c scorecardQ1, ScorecardSupportReview__c scorecardQ2, ScorecardSupportReview__c scorecardQ3, ScorecardSupportReview__c scorecardQ4) {
         if (scorecardQ1 != null && scorecardQ1.OperationalExcellenceRating__c != null) {
            return  getRatingDescription(scorecardQ1.OperationalExcellenceRating__c.intValue());
         }
         
         if (scorecardQ2 != null && scorecardQ2.OperationalExcellenceRating__c != null) {
            return  getRatingDescription(scorecardQ2.OperationalExcellenceRating__c.intValue());
         }
         
         if (scorecardQ3 != null && scorecardQ3.OperationalExcellenceRating__c != null) {
            return  getRatingDescription(scorecardQ3.OperationalExcellenceRating__c.intValue());
         }
         
         if (scorecardQ4 != null && scorecardQ4.OperationalExcellenceRating__c != null) {
            return  getRatingDescription(scorecardQ4.OperationalExcellenceRating__c.intValue());
         }
         
         return '-';
    }
      
    public static String getOperationalExcellenceWeight(ScorecardSupportReview__c scorecardQ1, ScorecardSupportReview__c scorecardQ2, ScorecardSupportReview__c scorecardQ3, ScorecardSupportReview__c scorecardQ4) {    
         if (scorecardQ1 != null && scorecardQ1.OperationalExcellenceWeight__c != null) {
            return  String.valueOf(scorecardQ1.OperationalExcellenceWeight__c);
         }
         
         if (scorecardQ2 != null && scorecardQ2.OperationalExcellenceWeight__c != null) {
            return  String.valueOf(scorecardQ2.OperationalExcellenceWeight__c);
         }
         
         if (scorecardQ3 != null && scorecardQ3.OperationalExcellenceWeight__c != null) {
            return  String.valueOf(scorecardQ3.OperationalExcellenceWeight__c);
         }
         
         if (scorecardQ4 != null && scorecardQ4.OperationalExcellenceWeight__c != null) {
            return  String.valueOf(scorecardQ4.OperationalExcellenceWeight__c);
         }
         
        return '-';
    }
    
    public static String getStrategicInitiativesRating(ScorecardSupportReview__c scorecardQ1, ScorecardSupportReview__c scorecardQ2, ScorecardSupportReview__c scorecardQ3, ScorecardSupportReview__c scorecardQ4) {
         if (scorecardQ1 != null && scorecardQ1.StrategicInitiativesRating__c != null) {
            return  getRatingDescription(scorecardQ1.StrategicInitiativesRating__c.intValue());
         }
         
         if (scorecardQ2 != null && scorecardQ2.StrategicInitiativesRating__c != null) {
            return  getRatingDescription(scorecardQ2.StrategicInitiativesRating__c.intValue());
         }
         
         if (scorecardQ3 != null && scorecardQ3.StrategicInitiativesRating__c != null) {
            return  getRatingDescription(scorecardQ3.StrategicInitiativesRating__c.intValue());
         }
         
         if (scorecardQ4 != null && scorecardQ4.StrategicInitiativesRating__c != null) {
            return  getRatingDescription(scorecardQ4.StrategicInitiativesRating__c.intValue());
         }
         
         return '-';
    }
      
    public static String getStrategicInitiativesWeight(ScorecardSupportReview__c scorecardQ1, ScorecardSupportReview__c scorecardQ2, ScorecardSupportReview__c scorecardQ3, ScorecardSupportReview__c scorecardQ4) {    
         if (scorecardQ1 != null && scorecardQ1.StrategicInitiativesWeight__c != null) {
            return  String.valueOf(scorecardQ1.StrategicInitiativesWeight__c); 
         }
         
         if (scorecardQ2 != null && scorecardQ2.StrategicInitiativesWeight__c != null) {
            return  String.valueOf(scorecardQ2.StrategicInitiativesWeight__c);
         }
         
         if (scorecardQ3 != null && scorecardQ3.StrategicInitiativesWeight__c != null) {
            return  String.valueOf(scorecardQ3.StrategicInitiativesWeight__c);
         }
         
         if (scorecardQ4 != null && scorecardQ4.StrategicInitiativesWeight__c != null) {
            return  String.valueOf(scorecardQ4.StrategicInitiativesWeight__c);
         }
         
        return '-';
    }
    
    public static String getCSMSalesImpactRating(ScorecardSupportReview__c scorecardQ1, ScorecardSupportReview__c scorecardQ2, ScorecardSupportReview__c scorecardQ3, ScorecardSupportReview__c scorecardQ4) {
     
         if (scorecardQ1 != null && scorecardQ1.CSMSalesImpactRating__c != null) {
            return  getRatingDescription(scorecardQ1.CSMSalesImpactRating__c.intValue());
         }
         
         if (scorecardQ2 != null && scorecardQ2.CSMSalesImpactRating__c != null) {
            return  getRatingDescription(scorecardQ2.CSMSalesImpactRating__c.intValue());
         }
         
         if (scorecardQ3 != null && scorecardQ3.CSMSalesImpactRating__c != null) {
            return  getRatingDescription(scorecardQ3.CSMSalesImpactRating__c.intValue());
         }
         
         if (scorecardQ4 != null && scorecardQ4.CSMSalesImpactRating__c != null) {
            return  getRatingDescription(scorecardQ4.CSMSalesImpactRating__c.intValue());
         }
         
         return '-';
    }
            
    public static String getCSMSalesImpactWeight(ScorecardSupportReview__c scorecardQ1, ScorecardSupportReview__c scorecardQ2, ScorecardSupportReview__c scorecardQ3, ScorecardSupportReview__c scorecardQ4) {    
         if (scorecardQ1 != null && scorecardQ1.CSMSalesImpactWeight__c != null) {
            return  String.valueOf(scorecardQ1.CSMSalesImpactWeight__c);
         }
         
         if (scorecardQ2 != null && scorecardQ2.CSMSalesImpactWeight__c != null) {
            return  String.valueOf(scorecardQ2.CSMSalesImpactWeight__c);
         }
         
         if (scorecardQ3 != null && scorecardQ3.CSMSalesImpactWeight__c != null) {
            return  String.valueOf(scorecardQ3.CSMSalesImpactWeight__c);
         }
         
         if (scorecardQ4 != null && scorecardQ4.CSMSalesImpactWeight__c != null) {
            return  String.valueOf(scorecardQ4.CSMSalesImpactWeight__c);
         }
         
        return '-';
    }
    
    
    // Customer Satisfaction  Table
    
    public static String getCustomerSatisfactionRating(ScorecardSupportReview__c scorecardQ1, ScorecardSupportReview__c scorecardQ2, ScorecardSupportReview__c scorecardQ3, ScorecardSupportReview__c scorecardQ4) {
     
         if (scorecardQ1 != null && scorecardQ1.RatingCustomerSatisfaction__c != null) {
            return  getRatingDescription(scorecardQ1.RatingCustomerSatisfaction__c.intValue());
         }
         
         if (scorecardQ2 != null && scorecardQ2.RatingCustomerSatisfaction__c != null) {
            return  getRatingDescription(scorecardQ2.RatingCustomerSatisfaction__c.intValue());
         }
         
         if (scorecardQ3 != null && scorecardQ3.RatingCustomerSatisfaction__c != null) {
            return  getRatingDescription(scorecardQ3.RatingCustomerSatisfaction__c.intValue());
         }
         
         if (scorecardQ4 != null && scorecardQ4.RatingCustomerSatisfaction__c != null) {
            return  getRatingDescription(scorecardQ4.RatingCustomerSatisfaction__c.intValue());
         }
         
         return '-';
    }
            
    public static String getCustomerSatisfactionWeight(ScorecardSupportReview__c scorecardQ1, ScorecardSupportReview__c scorecardQ2, ScorecardSupportReview__c scorecardQ3, ScorecardSupportReview__c scorecardQ4) {    
         if (scorecardQ1 != null && scorecardQ1.WeightCustomerSatisfaction__c != null) {
            return  String.valueOf(scorecardQ1.WeightCustomerSatisfaction__c);
         }
         
         if (scorecardQ2 != null && scorecardQ2.WeightCustomerSatisfaction__c != null) {
            return  String.valueOf(scorecardQ2.WeightCustomerSatisfaction__c);
         }
         
         if (scorecardQ3 != null && scorecardQ3.WeightCustomerSatisfaction__c != null) {
            return  String.valueOf(scorecardQ3.WeightCustomerSatisfaction__c);
         }
         
         if (scorecardQ4 != null && scorecardQ4.WeightCustomerSatisfaction__c != null) {
            return  String.valueOf(scorecardQ4.WeightCustomerSatisfaction__c);
         }
         
        return '-';
    }
    
    // end
    
    
    // WM CCP  Table
    
    public static String getWMCCPRating(ScorecardSupportReview__c scorecardQ1, ScorecardSupportReview__c scorecardQ2, ScorecardSupportReview__c scorecardQ3, ScorecardSupportReview__c scorecardQ4) {
     
         if (scorecardQ1 != null && scorecardQ1.WMCCPRating__c != null) {
            return  getRatingDescription(scorecardQ1.WMCCPRating__c.intValue());
         }
         
         if (scorecardQ2 != null && scorecardQ2.WMCCPRating__c != null) {
            return  getRatingDescription(scorecardQ2.WMCCPRating__c.intValue());
         }
         
         if (scorecardQ3 != null && scorecardQ3.WMCCPRating__c != null) {
            return  getRatingDescription(scorecardQ3.WMCCPRating__c.intValue());
         }
         
         if (scorecardQ4 != null && scorecardQ4.WMCCPRating__c != null) {
            return  getRatingDescription(scorecardQ4.WMCCPRating__c.intValue());
         }
         
         return '-';
    }
            
    public static String getWMCCPWeight(ScorecardSupportReview__c scorecardQ1, ScorecardSupportReview__c scorecardQ2, ScorecardSupportReview__c scorecardQ3, ScorecardSupportReview__c scorecardQ4) {    
         if (scorecardQ1 != null && scorecardQ1.WMCCPWeight__c != null) {
            return  String.valueOf(scorecardQ1.WMCCPWeight__c);
         }
         
         if (scorecardQ2 != null && scorecardQ2.WMCCPWeight__c != null) {
            return  String.valueOf(scorecardQ2.WMCCPWeight__c);
         }
         
         if (scorecardQ3 != null && scorecardQ3.WMCCPWeight__c != null) {
            return  String.valueOf(scorecardQ3.WMCCPWeight__c);
         }
         
         if (scorecardQ4 != null && scorecardQ4.WMCCPWeight__c != null) {
            return  String.valueOf(scorecardQ4.WMCCPWeight__c);
         }
         
        return '-';
    }
    
    // end
    
    // WM CAA  Table
    
    public static String getWMCAARating(ScorecardSupportReview__c scorecardQ1, ScorecardSupportReview__c scorecardQ2, ScorecardSupportReview__c scorecardQ3, ScorecardSupportReview__c scorecardQ4) {
     
         if (scorecardQ1 != null && scorecardQ1.WMCAARating__c != null) {
            return  getRatingDescription(scorecardQ1.WMCAARating__c.intValue());
         }
         
         if (scorecardQ2 != null && scorecardQ2.WMCAARating__c != null) {
            return  getRatingDescription(scorecardQ2.WMCAARating__c.intValue());
         }
         
         if (scorecardQ3 != null && scorecardQ3.WMCAARating__c != null) {
            return  getRatingDescription(scorecardQ3.WMCAARating__c.intValue());
         }
         
         if (scorecardQ4 != null && scorecardQ4.WMCAARating__c != null) {
            return  getRatingDescription(scorecardQ4.WMCAARating__c.intValue());
         }
         
         return '-';
    }
            
    public static String getWMCAAWeight(ScorecardSupportReview__c scorecardQ1, ScorecardSupportReview__c scorecardQ2, ScorecardSupportReview__c scorecardQ3, ScorecardSupportReview__c scorecardQ4) {    
         if (scorecardQ1 != null && scorecardQ1.WMCAAWeight__c != null) {
            return  String.valueOf(scorecardQ1.WMCAAWeight__c);
         }
         
         if (scorecardQ2 != null && scorecardQ2.WMCAAWeight__c != null) {
            return  String.valueOf(scorecardQ2.WMCAAWeight__c);
         }
         
         if (scorecardQ3 != null && scorecardQ3.WMCAAWeight__c != null) {
            return  String.valueOf(scorecardQ3.WMCAAWeight__c);
         }
         
         if (scorecardQ4 != null && scorecardQ4.WMCAAWeight__c != null) {
            return  String.valueOf(scorecardQ4.WMCAAWeight__c);
         }
         
        return '-';
    }
    
    // end
    
    public static String getRatingDescription(Integer value) {
        if (value == 0) {
            return '-';
        }
        if (value == 1) {
            return '1';
        }
        if (value == 2) {
            return '2';
        }
        if (value == 3) {
            return '3';
        }
        if (value == 4) {
            return '4';
        }
        if (value == 5) {
            return '5';
        }
        if (value == -1) {
            return 'N/A';
        }
            
        return '-';
    }

    public static Boolean IsAlreadyAdded(V2MOM__c v2mom)
    {
        System.debug('TheV2MOM is ' + v2mom );
        
        List<String> v2momShare;
        
        if (v2mom.Share_With__c != null)
        {
            v2momShare = v2mom.Share_With__c.split(';');
            
            for (String share : v2momShare) 
            {
                if (share == V2MOM_Constants.MgmgHierarchyPicklistValue)
                {
                    //Maneger allready added
                    return true;
                }
            }
        }
        else
        {
            return false;   
        }
        
        return false;
    }

    /**
    * Return default effective Date
    */
	public static String getDefaultEffectiveDate()
	{
		Schema.DescribeFieldResult fieldResult = V2MOM__c.Effective_Date__c.getDescribe();

		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		
	  	for( Schema.PicklistEntry f : ple)
	   	{
	     	if (f.isDefaultValue())
	     	{
	      		return f.getLabel();
	     	}  
	   }   
	   
	   return '';
	}
	
	
}