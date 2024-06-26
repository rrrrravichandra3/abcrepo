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

public with sharing class ScorecardAdminConsultBillingController {
    Scorecard__c scorecard = null;
    List<DepartmentBillingEast> listEast = new List<DepartmentBillingEast>();
    List<DepartmentBillingWest> listWest = new List<DepartmentBillingWest>();
      
    public ScorecardAdminConsultBillingController()
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
                                                and Type__c =: Label.Billings_label];
                                            //Where Department__c =: Label.Consulting_label
            
            
            if (effectivesDate.size() > 0 )
            {
                scorecard = effectivesDate[0];
            }    
                       
        }
        else
        {
               	System.debug('IsNotNull');
                List <Scorecard__c> scorecardList = [select Id,
                                EffectiveDate__c
                        from Scorecard__c
                        where EffectiveDate__c = :ed AND Cost_Center__c =: Label.Consulting_label
                                                    AND Type__c =: Label.Billings_label ];
                                                    //where EffectiveDate__c = :ed AND Cost_Center__c =: Label.Consulting_label
                                                    
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
                DepartmentBillingEast depToAddEast = new DepartmentBillingEast(currentDepEast);
                listEast.add(depToAddEast);
            }
            
            
            for (DeptScorecard__c currentDepWest : departmentWest)
            {
                DepartmentBillingWest depToAddWest = new DepartmentBillingWest(currentDepWest);
                listWest.add(depToAddWest);
            }
            
        }
    }
    
    public void newBillingChangesReload(){
    	String ed = System.currentPageReference().getParameters().get('id');
        
        if (ed == null)
        {
           //Look up all scorecard with type Utilization target
           List<Scorecard__c> effectivesDate = [Select Id, 
                                                    EffectiveDate__c, Rating__c, Weight__c
                                            From Scorecard__c
                                            Where Cost_Center__c =: Label.Consulting_label
                                                and Type__c =:Label.Billings_label];
                                            //Where Department__c =: Label.Consulting_label
            
            if (effectivesDate.size() > 0 )
            {
                scorecard = effectivesDate[0];
            }    
                       
        }
        else
        {
                List <Scorecard__c> scorecardList = [select Id, EffectiveDate__c
                        							 from Scorecard__c
                        							 where EffectiveDate__c = :ed AND Cost_Center__c =: Label.Consulting_label
                                                     AND Type__c =: Label.Billings_label ];
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
                DepartmentBillingEast depToAddEast = new DepartmentBillingEast(currentDepEast);
                listEast.add(depToAddEast);
            }
            
            
            for (DeptScorecard__c currentDepWest : departmentWest)
            {
                DepartmentBillingWest depToAddWest = new DepartmentBillingWest(currentDepWest);
                listWest.add(depToAddWest);
            }
            
        }
    	
    }
    
    public DepartmentBillingEast getBillingDeptEast()
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
     
    public DepartmentBillingWest getBillingDeptWest()
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
    public class DepartmentBillingEast
    {
        DeptScorecard__c departmentBillingScorecard;
        
    
        public DepartmentBillingEast(DeptScorecard__c departmentScorecard)
        {
            departmentBillingScorecard = departmentScorecard;
        }
        
    
        
        //Getters for all int values, no way to do it clean.
        
        public String getActualQ1()
        {
            if (departmentBillingScorecard.Q1Actual__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentBillingScorecard.Q1Actual__c));    
            }
               
        }
        
        public String getActualQ2()
        {
            if (departmentBillingScorecard.Q2Actual__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentBillingScorecard.Q2Actual__c));    
            }
               
        }
        
        public String getActualQ3()
        {
            if (departmentBillingScorecard.Q3Actual__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentBillingScorecard.Q3Actual__c));    
            }
               
        }
        
        public String getActualQ4()
        {
            if (departmentBillingScorecard.Q4Actual__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentBillingScorecard.Q4Actual__c));    
            }
               
        }
        
        
        
        
        
        public String getTargetQ1()
        {
            if(departmentBillingScorecard.Q1Target__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentBillingScorecard.Q1Target__c));    
            }
            
        }
        
        public String getTargetQ2()
        {
            if(departmentBillingScorecard.Q2Target__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentBillingScorecard.Q2Target__c));    
            }
            
        }
        
       public String getTargetQ3()
        {
            if(departmentBillingScorecard.Q3Target__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentBillingScorecard.Q3Target__c));    
            }
            
        }
        
        public String getTargetQ4()
        {
            if(departmentBillingScorecard.Q4Target__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentBillingScorecard.Q4Target__c));    
            }
            
        }
        
        public Long getRatingQ1()
        {
             
            //return Math.roundToLong(departmentBillingScorecard.Q1Rating__c);
            
            return PAMUtil.getRatingFromActualTarget(getAttainabilityQ1()); 
        }
        
        public Long getRatingQ2()
        {
            //return Math.roundToLong(departmentBillingScorecard.Q2Rating__c);
            return PAMUtil.getRatingFromActualTarget(getAttainabilityQ2());     
        }
        
        public Long getRatingQ3()
        {
            //return Math.roundToLong(departmentBillingScorecard.Q3Rating__c);  
            return PAMUtil.getRatingFromActualTarget(getAttainabilityQ3()); 
        }
        
        public Long getRatingQ4()
        {
            //return Math.roundToLong(departmentBillingScorecard.Q4Rating__c);
            return PAMUtil.getRatingFromActualTarget(getAttainabilityQ4());     
        }
        
        
        public Long getAvgRatingQ1Q2()
        {
            /*
            Double total;
            
            if ((departmentBillingScorecard.Q1Rating__c != -1) && (departmentBillingScorecard.Q2Rating__c != -1))
            {
                total = departmentBillingScorecard.Q1Rating__c + departmentBillingScorecard.Q2Rating__c; 
            }
            else
            {
                if (departmentBillingScorecard.Q1Rating__c == -1)
                {
                    total = departmentBillingScorecard.Q2Rating__c;
                }
                 
                if (departmentBillingScorecard.Q2Rating__c == -1)
                {
                    total = departmentBillingScorecard.Q1Rating__c;
                }
            } 
            
            total = total /2;
            return total;
          

            Double Q1 = getRatingQ1();
            Double Q2 = getRatingQ2();
            
            Double ret = (Q1 + Q2) / 2 ;
  
            return ret;
            
              */
              
           return PAMUtil.getRatingFromActualTarget(getAttainalibityAvgQ1Q2());
        }
        
        public Long getAvgRatingQ3Q4()
        {
            /*
            Double total;
            
            if ((departmentBillingScorecard.Q1Rating__c != -1) && (departmentBillingScorecard.Q2Rating__c != -1))
            {
                total = departmentBillingScorecard.Q1Rating__c + departmentBillingScorecard.Q2Rating__c; 
            }
            else
            {
                if (departmentBillingScorecard.Q3Rating__c == -1)
                {
                    total = departmentBillingScorecard.Q4Rating__c;
                }
                
                if (departmentBillingScorecard.Q4Rating__c == -1)
                {
                    total = departmentBillingScorecard.Q3Rating__c;
                }
            } 
            
            total = total /2;
            return total;
            
            */
            
             System.debug('Testtt ' + getAttainalibityAvgQ3Q4() );
             
             return PAMUtil.getRatingFromActualTarget(getAttainalibityAvgQ3Q4());
            
  
        }
        
        
        public Double getAttainabilityQ1()
        {
            Decimal attainability = 0;
            if ((departmentBillingScorecard.Q1Actual__c != -1) && (departmentBillingScorecard.Q1Target__c != -1 ))
            {
                if (departmentBillingScorecard.Q1Target__c != 0)
                {
                     attainability = (departmentBillingScorecard.Q1Actual__c / departmentBillingScorecard.Q1Target__c) * 100;
                }
                            
            }
            
            attainability = attainability.divide(1, 1);
            
            return attainability; 
        }
        
        public Double getAttainabilityQ2()
        {
            Decimal attainability = 0;
            if ((departmentBillingScorecard.Q2Actual__c != -1) && (departmentBillingScorecard.Q2Target__c != -1 ))
            {
                if (departmentBillingScorecard.Q2Target__c != 0)
                {
                    attainability = (departmentBillingScorecard.Q2Actual__c / departmentBillingScorecard.Q2Target__c) * 100;
                }
                    
            }
            
            attainability = attainability.divide(1, 1);
            
            return attainability; 
        }
        
        public Double getAttainabilityQ3()
        {
            Decimal attainability = 0;
            
            if ((departmentBillingScorecard.Q3Actual__c != -1) && (departmentBillingScorecard.Q3Target__c != -1 ))
            {
                if (departmentBillingScorecard.Q3Target__c != 0)
                {
                     attainability = (departmentBillingScorecard.Q3Actual__c / departmentBillingScorecard.Q3Target__c) * 100;
                }            
            }
            
            attainability = attainability.divide(1, 1);
            
            return attainability; 
        }
        
        public Double getAttainabilityQ4()
        {
            Decimal attainability = 0;
            if ((departmentBillingScorecard.Q4Actual__c != -1) && (departmentBillingScorecard.Q4Target__c != -1 ))
            {
                if (departmentBillingScorecard.Q4Target__c != 0)
                {
                    attainability = (departmentBillingScorecard.Q4Actual__c / departmentBillingScorecard.Q4Target__c) * 100;
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
    public class DepartmentBillingWest
    {
        DeptScorecard__c departmentBillingScorecard;
        
    
        public DepartmentBillingWest(DeptScorecard__c departmentScorecard)
        {
            departmentBillingScorecard = departmentScorecard;
        }
        
    
        
        //Getters for all int values, no way to do it clean.
        
       public String getActualQ1()
        {
            if (departmentBillingScorecard.Q1Actual__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentBillingScorecard.Q1Actual__c));    
            }
               
        }
        
        public String getActualQ2()
        {
            if (departmentBillingScorecard.Q2Actual__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentBillingScorecard.Q2Actual__c));    
            }
               
        }
        
        public String getActualQ3()
        {
            if (departmentBillingScorecard.Q3Actual__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentBillingScorecard.Q3Actual__c));    
            }
               
        }
        
        public String getActualQ4()
        {
            if (departmentBillingScorecard.Q4Actual__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentBillingScorecard.Q4Actual__c));    
            }
               
        }
        
        
        
        
        
        public String getTargetQ1()
        {
            if(departmentBillingScorecard.Q1Target__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentBillingScorecard.Q1Target__c));    
            }
            
        }
        
        public String getTargetQ2()
        {
            if(departmentBillingScorecard.Q2Target__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentBillingScorecard.Q2Target__c));    
            }
            
        }
        
       public String getTargetQ3()
        {
            if(departmentBillingScorecard.Q3Target__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentBillingScorecard.Q3Target__c));    
            }
            
        }
        
        public String getTargetQ4()
        {
            if(departmentBillingScorecard.Q4Target__c == -1)
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(Math.roundToLong(departmentBillingScorecard.Q4Target__c));    
            }
            
        }
        
        
        public Long getRatingQ1()
        {
            //return Math.roundToLong(departmentBillingScorecard.Q1Rating__c);
            return PAMUtil.getRatingFromActualTarget(getAttainabilityQ1());     
        }
        
        public Long getRatingQ2()
        {
            //return Math.roundToLong(departmentBillingScorecard.Q2Rating__c);
            return PAMUtil.getRatingFromActualTarget(getAttainabilityQ2());     
        }
        
        public Long getRatingQ3()
        {
            //return Math.roundToLong(departmentBillingScorecard.Q3Rating__c);
            return PAMUtil.getRatingFromActualTarget(getAttainabilityQ3());     
        }
        
        public Long getRatingQ4()
        {
            //return Math.roundToLong(departmentBillingScorecard.Q4Rating__c);
            return PAMUtil.getRatingFromActualTarget(getAttainabilityQ4());     
        }
        
        public Long getAvgRatingQ1Q2()
        {
            /*
            Double total;
            
            if ((departmentBillingScorecard.Q1Rating__c != -1) && (departmentBillingScorecard.Q2Rating__c != -1))
            {
                total = departmentBillingScorecard.Q1Rating__c + departmentBillingScorecard.Q2Rating__c; 
            }
            else
            {
                if (departmentBillingScorecard.Q1Rating__c == -1)
                {
                    total = departmentBillingScorecard.Q2Rating__c;
                }
                
                if (departmentBillingScorecard.Q2Rating__c == -1)
                {
                    total = departmentBillingScorecard.Q1Rating__c;
                }
            } 
            
            total = total /2;
            return total;
            
            */
            
             return PAMUtil.getRatingFromActualTarget(getAttainalibityAvgQ1Q2());
        }
        
        public Long getAvgRatingQ3Q4()
        {
            /*
            Double total;
            
            if ((departmentBillingScorecard.Q1Rating__c != -1) && (departmentBillingScorecard.Q2Rating__c != -1))
            {
                total = departmentBillingScorecard.Q1Rating__c + departmentBillingScorecard.Q2Rating__c; 
            }
            else
            {
                if (departmentBillingScorecard.Q3Rating__c == -1)
                {
                    total = departmentBillingScorecard.Q4Rating__c;
                }
                
                if (departmentBillingScorecard.Q4Rating__c == -1)
                {
                    total = departmentBillingScorecard.Q3Rating__c;
                }
            } 
            
            total = total /2;
            return total;
            
            */
            
             return PAMUtil.getRatingFromActualTarget(getAttainalibityAvgQ3Q4());
             
        }
        
        
           public Double getAttainabilityQ1()
        {
            Decimal attainability = 0;
            if ((departmentBillingScorecard.Q1Actual__c != -1) && (departmentBillingScorecard.Q1Target__c != -1 ))
            {
                if (departmentBillingScorecard.Q1Target__c != 0)
                {
                     attainability = (departmentBillingScorecard.Q1Actual__c / departmentBillingScorecard.Q1Target__c) * 100;
                }
                            
            }
            
            attainability = attainability.divide(1, 1);
            
            return attainability; 
        }
        
        public Double getAttainabilityQ2()
        {
            Decimal attainability = 0;
            if ((departmentBillingScorecard.Q2Actual__c != -1) && (departmentBillingScorecard.Q2Target__c != -1 ))
            {
                if (departmentBillingScorecard.Q2Target__c != 0)
                {
                    attainability = (departmentBillingScorecard.Q2Actual__c / departmentBillingScorecard.Q2Target__c) * 100;
                }
                    
            }
            
            attainability = attainability.divide(1, 1);
            
            return attainability; 
        }
        
        public Double getAttainabilityQ3()
        {
            Decimal attainability = 0;
            
            if ((departmentBillingScorecard.Q3Actual__c != -1) && (departmentBillingScorecard.Q3Target__c != -1 ))
            {
                if (departmentBillingScorecard.Q3Target__c != 0)
                {
                     attainability = (departmentBillingScorecard.Q3Actual__c / departmentBillingScorecard.Q3Target__c) * 100;
                }            
            }
            
            attainability = attainability.divide(1, 1);
            
            return attainability; 
        }
        
        public Double getAttainabilityQ4()
        {
            Decimal attainability = 0;
            if ((departmentBillingScorecard.Q4Actual__c != -1) && (departmentBillingScorecard.Q4Target__c != -1 ))
            {
                if (departmentBillingScorecard.Q4Target__c != 0)
                {
                    attainability = (departmentBillingScorecard.Q4Actual__c / departmentBillingScorecard.Q4Target__c) * 100;
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