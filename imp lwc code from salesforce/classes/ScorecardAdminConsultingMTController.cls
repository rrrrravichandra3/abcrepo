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

public with sharing class ScorecardAdminConsultingMTController {
    Scorecard__c scorecard = null;
    List<DepartmentMarginTargetEast> listEast = new List<DepartmentMarginTargetEast>(); 
    List<DepartmentMarginTargetWest> listWest = new List<DepartmentMarginTargetWest>();
      
    public ScorecardAdminConsultingMTController()
    {
        
        String ed = System.currentPageReference().getParameters().get('id');
      
        
        if (ed == null)
        {
         	System.debug('IsNulll');
           //Look up all scorecard with type Utilization target
           List<Scorecard__c> effectivesDate = [Select Id, 
                                                    EffectiveDate__c, Rating__c, Weight__c
                                            From Scorecard__c
                                            Where Cost_Center__c =: Label.Consulting_label
                                                and Type__c =: Label.Margin_Target_label];
                                            //Where Department__c =: Label.Consulting_label
            
            System.debug('Cost_Center__c ' + Label.Consulting_label );
            System.debug('Type__c ' + Label.Margin_Target_label );
            
            if (effectivesDate.size() > 0 )
            {
            	System.debug('FoundScorecard');
                scorecard = effectivesDate[0];
            }    
                       
        }
        else
        {
                System.debug('ISNotNull');
                List <Scorecard__c> scorecardList = [select Id,
                                EffectiveDate__c
                        from Scorecard__c
                        where EffectiveDate__c = :ed AND Cost_Center__c =: Label.Consulting_label
                                                    AND Type__c =: Label.Margin_Target_label ];
                        //where EffectiveDate__c = :ed AND Department__c =: Label.Consulting_label
                                                    
                if (scorecardList.size() == 1)
                {
                    scorecard = scorecardList[0];
                }
                else
                {
                    scorecard = new Scorecard__c();
                }
        }
            
        if (scorecard != null)
        {
            System.debug('Scorecard is not null');
            System.debug(Label.East_label);
            System.debug(Label.West_label);
            
            List<DeptScorecard__c> departmentEast = [Select Id, Q1Actual__c, Q1Target__c, Q2Actual__c, Q2Rating__c, Q2Target__c, Q3Actual__c,
                     Q3Rating__c, Q3Target__c, Q4Actual__c, Q4Rating__c, Q4Target__c, Q1Rating__c 
                        From DeptScorecard__c WHERE Zone__c =: Label.East_label AND Scorecard__c =: scorecard.Id];  
                        
            List<DeptScorecard__c> departmentWest = [Select Id, Q1Actual__c, Q1Target__c, Q2Actual__c, Q2Rating__c, Q2Target__c, Q3Actual__c,
                     Q3Rating__c, Q3Target__c, Q4Actual__c, Q4Rating__c, Q4Target__c, Q1Rating__c 
                        From DeptScorecard__c WHERE Zone__c =: Label.West_label AND Scorecard__c =: scorecard.Id];  
                        
            for (DeptScorecard__c currentDepEast : departmentEast)
            {
            	System.debug('FoundEast');
                DepartmentMarginTargetEast depToAddEast = new DepartmentMarginTargetEast(currentDepEast);
                listEast.add(depToAddEast);
            }
            
            
            for (DeptScorecard__c currentDepWest : departmentWest)
            {
            	System.debug('FoundWest');
                DepartmentMarginTargetWest depToAddWest = new DepartmentMarginTargetWest(currentDepWest);
                listWest.add(depToAddWest);
            }
            
        }
    }
    
    public void newMarginTargetChangesReload(){
    	String ed = System.currentPageReference().getParameters().get('id');
        
        if (ed == null)
        {
           //Look up all scorecard with type Utilization target
           List<Scorecard__c> effectivesDate = [Select Id, 
                                                    EffectiveDate__c, Rating__c, Weight__c
                                            From Scorecard__c
                                            Where Cost_Center__c =: Label.Consulting_label
                                                and Type__c =:Label.Margin_Target_label];
                                            //Where Department__c =: Label.Consulting_label
            
            if (effectivesDate.size() > 0 )
            {
                scorecard = effectivesDate[0];
            }    
                       
        }
        else
        {
                List <Scorecard__c> scorecardList = [select Id,
                                EffectiveDate__c
                        from Scorecard__c
                        where EffectiveDate__c = :ed AND Cost_Center__c =: Label.Consulting_label
                                                    AND Type__c =: Label.Margin_Target_label ];
                        //where EffectiveDate__c = :ed AND Department__c =: Label.Consulting_label
                                                    
                if (scorecardList.size() == 1)
                {
                    scorecard = scorecardList[0];
                }
                else
                {
                    scorecard = new Scorecard__c();
                }
        }
            
        if (scorecard != null)
        {
            List<DeptScorecard__c> departmentEast = [Select Id, Q1Actual__c, Q1Target__c, Q2Actual__c, Q2Rating__c, Q2Target__c, Q3Actual__c,
                     Q3Rating__c, Q3Target__c, Q4Actual__c, Q4Rating__c, Q4Target__c, Q1Rating__c 
                        From DeptScorecard__c WHERE Zone__c =: Label.East_label AND Scorecard__c =: scorecard.Id];  
                        
            List<DeptScorecard__c> departmentWest = [Select Id, Q1Actual__c, Q1Target__c, Q2Actual__c, Q2Rating__c, Q2Target__c, Q3Actual__c,
                     Q3Rating__c, Q3Target__c, Q4Actual__c, Q4Rating__c, Q4Target__c, Q1Rating__c 
                        From DeptScorecard__c WHERE Zone__c =: Label.West_label AND Scorecard__c =: scorecard.Id];  
                        
            for (DeptScorecard__c currentDepEast : departmentEast)
            {
                DepartmentMarginTargetEast depToAddEast = new DepartmentMarginTargetEast(currentDepEast);
                listEast.add(depToAddEast);
            }
            
            
            for (DeptScorecard__c currentDepWest : departmentWest)
            {
                DepartmentMarginTargetWest depToAddWest = new DepartmentMarginTargetWest(currentDepWest);
                listWest.add(depToAddWest);
            }
            
        }
    	
    }
    
    public DepartmentMarginTargetEast getMarginTargetDeptEast()
    {
        if (listEast.size() > 0)
        {
            return listEast[0];
        }
        else
        {
            return null;    
        }
    }
    
    public Scorecard__c getScorecard()
    {
        return scorecard;   
    }
     
    public DepartmentMarginTargetWest getMarginTargetDeptWest()
    {
        if (listWest.size() > 0)
        {
            return listWest[0];
        }
        else
        {
            return null;    
        }
    }
    
    public List<SelectOption> getRatingSelectOptions() 
    {
        return PAMUtil.getRatingSelectOptions();
    }
    
      /**
      * Inner class.Hold DeptScorecard object
      * 
      */
    public class DepartmentMarginTargetEast
    {
        DeptScorecard__c departmentMarginTargetScorecard;
        
    
        public DepartmentMarginTargetEast(DeptScorecard__c departmentScorecard)
        {
            departmentMarginTargetScorecard = departmentScorecard;
        }
        
    
        
        //Getters for all int values, no way to do it clean.
        
        public String getActualQ1()
        {
            if (departmentMarginTargetScorecard.Q1Actual__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentMarginTargetScorecard.Q1Actual__c));    
            }
               
        }
        
        public String getActualQ2()
        {
            if (departmentMarginTargetScorecard.Q2Actual__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentMarginTargetScorecard.Q2Actual__c));    
            }
               
        }
        
        public String getActualQ3()
        {
            if (departmentMarginTargetScorecard.Q3Actual__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentMarginTargetScorecard.Q3Actual__c));    
            }
               
        }
        
        public String getActualQ4()
        {
            if (departmentMarginTargetScorecard.Q4Actual__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentMarginTargetScorecard.Q4Actual__c));    
            }
               
        }
        
        
        
        
        
        public String getTargetQ1()
        {
            if(departmentMarginTargetScorecard.Q1Target__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentMarginTargetScorecard.Q1Target__c));    
            }
            
        }
        
        public String getTargetQ2()
        {
            if(departmentMarginTargetScorecard.Q2Target__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentMarginTargetScorecard.Q2Target__c));    
            }
            
        }
        
       public String getTargetQ3()
        {
            if(departmentMarginTargetScorecard.Q3Target__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentMarginTargetScorecard.Q3Target__c));    
            }
            
        }
        
        public String getTargetQ4()
        {
            if(departmentMarginTargetScorecard.Q4Target__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentMarginTargetScorecard.Q4Target__c));    
            }
            
        }
        
        public Long getRatingQ1()
        {
             
            //return Math.roundToLong(departmentMarginTargetScorecard.Q1Rating__c);
            
            return PAMUtil.getRatingFromActualTarget(getAttainabilityQ1()); 
        }
        
        public Long getRatingQ2()
        {
            //return Math.roundToLong(departmentMarginTargetScorecard.Q2Rating__c);
            return PAMUtil.getRatingFromActualTarget(getAttainabilityQ2());     
        }
        
        public Long getRatingQ3()
        {
            //return Math.roundToLong(departmentMarginTargetScorecard.Q3Rating__c);  
            return PAMUtil.getRatingFromActualTarget(getAttainabilityQ3()); 
        }
        
        public Long getRatingQ4()
        {
            //return Math.roundToLong(departmentMarginTargetScorecard.Q4Rating__c);
            return PAMUtil.getRatingFromActualTarget(getAttainabilityQ4());     
        }
        
        
        public Long getAvgRatingQ1Q2()
        {
              
           return PAMUtil.getRatingFromActualTarget(getAttainalibityAvgQ1Q2());
        }
        
        public Long getAvgRatingQ3Q4()
        {
            
             
             return PAMUtil.getRatingFromActualTarget(getAttainalibityAvgQ3Q4());
            
  
        }
        
        
        public Double getAttainabilityQ1()
        {
            Decimal attainability = 0;
            if ((departmentMarginTargetScorecard.Q1Actual__c != -1) && (departmentMarginTargetScorecard.Q1Target__c != -1 ))
            {
                if (departmentMarginTargetScorecard.Q1Target__c != 0)
                {
                     attainability = (departmentMarginTargetScorecard.Q1Actual__c / departmentMarginTargetScorecard.Q1Target__c) * 100;
                }
                            
            }
            
            attainability = attainability.divide(1, 1);
            
            return attainability; 
        }
        
        public Double getAttainabilityQ2()
        {
            Decimal attainability = 0;
            if ((departmentMarginTargetScorecard.Q2Actual__c != -1) && (departmentMarginTargetScorecard.Q2Target__c != -1 ))
            {
                if (departmentMarginTargetScorecard.Q2Target__c != 0)
                {
                    attainability = (departmentMarginTargetScorecard.Q2Actual__c / departmentMarginTargetScorecard.Q2Target__c) * 100;
                }
                    
            }
            
            attainability = attainability.divide(1, 1);
            
            return attainability; 
        }
        
        public Double getAttainabilityQ3()
        {
            Decimal attainability = 0;
            
            if ((departmentMarginTargetScorecard.Q3Actual__c != -1) && (departmentMarginTargetScorecard.Q3Target__c != -1 ))
            {
                if (departmentMarginTargetScorecard.Q3Target__c != 0)
                {
                     attainability = (departmentMarginTargetScorecard.Q3Actual__c / departmentMarginTargetScorecard.Q3Target__c) * 100;
                }            
            }
            
            attainability = attainability.divide(1, 1);
            
            return attainability; 
        }
        
        public Double getAttainabilityQ4()
        {
            Decimal attainability = 0;
            if ((departmentMarginTargetScorecard.Q4Actual__c != -1) && (departmentMarginTargetScorecard.Q4Target__c != -1 ))
            {
                if (departmentMarginTargetScorecard.Q4Target__c != 0)
                {
                    attainability = (departmentMarginTargetScorecard.Q4Actual__c / departmentMarginTargetScorecard.Q4Target__c) * 100;
                }            
            }
            
            attainability = attainability.divide(1, 1);
            
            return attainability;  
        } 
        
        public Double getAttainalibityAvgQ1Q2()
        {
            Decimal result = (getAttainabilityQ1() + getAttainabilityQ2());
            
            result = result.divide(2,1,System.RoundingMode.HALF_UP);
         
         
            return result;
        }
        
        public Double getAttainalibityAvgQ3Q4()
        {
           Decimal result = (getAttainabilityQ3() + getAttainabilityQ4());
            
            result = result.divide(2,1,System.RoundingMode.HALF_UP);
         
         
            return result;
        }
    }
    
     
    
     /**
      * Inner class.Hold DeptScorecard object
      * 
      */
    public class DepartmentMarginTargetWest
    {
        DeptScorecard__c departmentMarginTargetScorecard;
        
    
        public DepartmentMarginTargetWest(DeptScorecard__c departmentScorecard)
        {
            departmentMarginTargetScorecard = departmentScorecard;
        }
        
    
        
        //Getters for all int values, no way to do it clean.
        
       public String getActualQ1()
        {
            if (departmentMarginTargetScorecard.Q1Actual__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentMarginTargetScorecard.Q1Actual__c));    
            }
               
        }
        
        public String getActualQ2()
        {
            if (departmentMarginTargetScorecard.Q2Actual__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentMarginTargetScorecard.Q2Actual__c));    
            }
               
        }
        
        public String getActualQ3()
        {
            if (departmentMarginTargetScorecard.Q3Actual__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentMarginTargetScorecard.Q3Actual__c));    
            }
               
        }
        
        public String getActualQ4()
        {
            if (departmentMarginTargetScorecard.Q4Actual__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentMarginTargetScorecard.Q4Actual__c));    
            }
               
        }
        
        
        
        
        
        public String getTargetQ1()
        {
            if(departmentMarginTargetScorecard.Q1Target__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentMarginTargetScorecard.Q1Target__c));    
            }
            
        }
        
        public String getTargetQ2()
        {
            if(departmentMarginTargetScorecard.Q2Target__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentMarginTargetScorecard.Q2Target__c));    
            }
            
        }
        
       public String getTargetQ3()
        {
            if(departmentMarginTargetScorecard.Q3Target__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentMarginTargetScorecard.Q3Target__c));    
            }
            
        }
        
        public String getTargetQ4()
        {
            if(departmentMarginTargetScorecard.Q4Target__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentMarginTargetScorecard.Q4Target__c));    
            }
            
        }
        
        
        public Long getRatingQ1()
        {
            //return Math.roundToLong(departmentMarginTargetScorecard.Q1Rating__c);
            return PAMUtil.getRatingFromActualTarget(getAttainabilityQ1());     
        }
        
        public Long getRatingQ2()
        {
            //return Math.roundToLong(departmentMarginTargetScorecard.Q2Rating__c);
            return PAMUtil.getRatingFromActualTarget(getAttainabilityQ2());     
        }
        
        public Long getRatingQ3()
        {
            //return Math.roundToLong(departmentMarginTargetScorecard.Q3Rating__c);
            return PAMUtil.getRatingFromActualTarget(getAttainabilityQ3());     
        }
        
        public Long getRatingQ4()
        {
            //return Math.roundToLong(departmentMarginTargetScorecard.Q4Rating__c);
            return PAMUtil.getRatingFromActualTarget(getAttainabilityQ4());     
        }
        
        public Long getAvgRatingQ1Q2()
        {
          
             return PAMUtil.getRatingFromActualTarget(getAttainalibityAvgQ1Q2());
        }
        
        public Long getAvgRatingQ3Q4()
        {
            
            
             return PAMUtil.getRatingFromActualTarget(getAttainalibityAvgQ3Q4());
             
        }
        
        
           public Double getAttainabilityQ1()
        {
            Decimal attainability = 0;
            if ((departmentMarginTargetScorecard.Q1Actual__c != -1) && (departmentMarginTargetScorecard.Q1Target__c != -1 ))
            {
                if (departmentMarginTargetScorecard.Q1Target__c != 0)
                {
                     attainability = (departmentMarginTargetScorecard.Q1Actual__c / departmentMarginTargetScorecard.Q1Target__c) * 100;
                }
                            
            }
            
            attainability = attainability.divide(1, 1);
            
            return attainability; 
        }
        
        public Double getAttainabilityQ2()
        {
            Decimal attainability = 0;
            if ((departmentMarginTargetScorecard.Q2Actual__c != -1) && (departmentMarginTargetScorecard.Q2Target__c != -1 ))
            {
                if (departmentMarginTargetScorecard.Q2Target__c != 0)
                {
                    attainability = (departmentMarginTargetScorecard.Q2Actual__c / departmentMarginTargetScorecard.Q2Target__c) * 100;
                }
                    
            }
            
            attainability = attainability.divide(1, 1);
            
            return attainability; 
        }
        
        public Double getAttainabilityQ3()
        {
            Decimal attainability = 0;
            
            if ((departmentMarginTargetScorecard.Q3Actual__c != -1) && (departmentMarginTargetScorecard.Q3Target__c != -1 ))
            {
                if (departmentMarginTargetScorecard.Q3Target__c != 0)
                {
                     attainability = (departmentMarginTargetScorecard.Q3Actual__c / departmentMarginTargetScorecard.Q3Target__c) * 100;
                }            
            }
            
            attainability = attainability.divide(1, 1);
            
            return attainability; 
        }
        
        public Double getAttainabilityQ4()
        {
            Decimal attainability = 0;
            if ((departmentMarginTargetScorecard.Q4Actual__c != -1) && (departmentMarginTargetScorecard.Q4Target__c != -1 ))
            {
                if (departmentMarginTargetScorecard.Q4Target__c != 0)
                {
                    attainability = (departmentMarginTargetScorecard.Q4Actual__c / departmentMarginTargetScorecard.Q4Target__c) * 100;
                }            
            }
            
            attainability = attainability.divide(1, 1);
            
            return attainability;  
        } 
        
        public Double getAttainalibityAvgQ1Q2()
        {
            Decimal result = (getAttainabilityQ1() + getAttainabilityQ2());
            
            result = result.divide(2,1,System.RoundingMode.HALF_UP);
         
         
            return result;
        }
        
        public Double getAttainalibityAvgQ3Q4()
        {
             Decimal result = (getAttainabilityQ3() + getAttainabilityQ4());
            
            result = result.divide(2,1,System.RoundingMode.HALF_UP);
         
         
            return result;
        }
    }
}