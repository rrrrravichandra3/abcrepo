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

public with sharing class ScorecardAdminConsultingUTController {
     
    Scorecard__c scorecard;
    List <IndividualTarget> individualTargetEmployees = new List <IndividualTarget>();
    List <IndividualActual> individualActualEmployees = new List<IndividualActual>();
    List <IndividualTarget> individualTargetManagers = new List <IndividualTarget>();
    List <IndividualActual> individualActualManagers = new List<IndividualActual>();
    List <IndividualActual> individualActual = new List<IndividualActual>();
    Long rating;
    Double weight;
    String effectiveDate;
    Boolean noMatches;
    Boolean noMatchesManager;
    list<UserSelect> users; // list of user for overlay
    Total total;
    
    public ScorecardAdminConsultingUTController()
    {
    	createObjects();
    }
    
    private void createObjects()
    {
        Id ed = System.currentPageReference().getParameters().get('id');
        
        if (ed == null)
        {
            //Look up all scorecard with type Utilization target
            List<Scorecard__c> effectivesDate = [select Id, 
                                                       EffectiveDate__c
                                                from Scorecard__c
                                                where Cost_Center__c =: Label.Consulting_label
                                                and Type__c =: Label.Utilization_Target_label];
                                                //where Department__c =: Label.Consulting_label
            
            if (effectivesDate.size() > 0 )
                scorecard = effectivesDate[0];
        }
        else
        {
            list<Scorecard__c> scorecards = [select Id,
					                                EffectiveDate__c
					                        from Scorecard__c
					                        where EffectiveDate__c = :ed 
					                        and Cost_Center__c =: Label.Consulting_label
					                        and Type__c =: Label.Utilization_Target_label ];
					                        //and Department__c =: Label.Consulting_label
			if (scorecards.size() > 0)
				scorecard = scorecards[0];
        }   
   
        if (scorecard != null)
        {
        	scorecard = [select s.EffectiveDate__c, 
                                s.Id, s.Rating__c, 
                                s.Weight__c, 
                                (select Q1__c, Q2__c, Q3__c, Q4__c, 
                                        RatingQ1Q2__c, RatingQ3Q4__c,
                                        WeightQ1Q2__c, WeightQ3Q4__c, 
                                        Employee__c,
                                        Employee__r.EmployeeNumber, Employee__r.Name, 
                                        Employee__r.FirstName, Employee__r.LastName, 
                                        Employee__r.CompetencyGroupCode__c,
                                        Employee__r.Profile.Name 
                                 from IndividualTargetScorecards__r 
                                 order by Employee__r.LastName  ),
                                (select Q1__c, Q2__c, Q3__c, Q4__c,
                                        RatingQ1Q2__c, RatingQ3Q4__c,
                                        WeightQ1Q2__c, WeightQ3Q4__c, Team__c  
                                from IndividualActualScorecards__r 
                                order by Team__c ) 
                        from Scorecard__c s 
                        where Id =: scorecard.Id];
                        
            Scorecard__c scorecardTwo = [select s.EffectiveDate__c, s.Id, s.Rating__c, s.Weight__c, 
        										(select Q1__c, Q2__c, Q3__c, Q4__c, RatingQ1Q2__c, RatingQ3Q4__c,
        												WeightQ1Q2__c, WeightQ3Q4__c, Employee__r.EmployeeNumber, Employee__r.Name,
        												Employee__r.CompetencyGroupCode__c 
												 from IndividualTargetScorecards__r 
												 order by Employee__r.CompetencyGroupCode__c ),
                    							(select Q1__c, Q2__c, Q3__c, Q4__c,RatingQ1Q2__c, RatingQ3Q4__c,
                    									WeightQ1Q2__c, WeightQ3Q4__c, Team__c  
            									 from IndividualActualScorecards__r 
            									 order by Team__c ) 
    									 from Scorecard__c s 
    									 where Id =: scorecard.Id ];
            
            IndividualTarget indiTar;
            IndividualActual indiAct;
            
            for (IndividualTargetScorecard__c currentIndTar : scorecard.IndividualTargetScorecards__r)
            {
                indiTar = new IndividualTarget(currentIndTar, scorecard.IndividualTargetScorecards__r, scorecard.IndividualActualScorecards__r );
                if (currentIndTar.Employee__r.Profile != null)
                {  
                    if (currentIndTar.Employee__r.Profile.Name.equals(Label.Consulting_Employee_label))                  
                        individualTargetEmployees.add(indiTar);
                    else if (currentIndTar.Employee__r.Profile.Name.equals(Label.Consulting_Manager_label))                 
                        individualTargetManagers.add(indiTar);
                }
            }
            
            for (IndividualActualScorecard__c currentIndAct : scorecard.IndividualActualScorecards__r)
            {
                indiAct = new IndividualActual(currentIndAct, scorecardTwo.IndividualTargetScorecards__r, scorecard.IndividualActualScorecards__r);
                individualActual.add(indiAct);
            }  

            totalItemsNumber = individualTargetEmployees.size();
            
            if (totalItemsNumber == 0 ) {
                noMatches = true;
                cntPagination = 0;  
                firstRow = 0;
                currentPagination = 1;
                jumpPage = 1;
            }
            else {
                noMatches = false;
                firstRow = 0;
                currentPagination = 1;
                jumpPage = 1;
                genCntPagination(); 
            }
        
            totalItemsNumberManager = individualTargetManagers.size();

            if (totalItemsNumberManager == 0 ) {
                noMatchesManager = true;
                cntPaginationManager = 0;   
                firstRowManager = 0;
                currentPaginationManager = 1;
                jumpPageManager = 1;
            }
            else {
                noMatchesManager = false;
                firstRowManager = 0;
                currentPaginationManager = 1;
                jumpPageManager = 1;
                genCntPaginationManager();  
            }            
        
            effectiveDate = ed;
            
            /* Users for Overlay */
            users = new list<UserSelect>();
            for(User user : [select Id,
                                    EmployeeNumber,
                                    Name,
                                    LastName,
                                    FirstName,
                                    CompetencyGroupCode__c                         
                            from User
                            where Profile.Name =: 'Consulting Manager'
                            and EmployeeNumber != null
                            order by EmployeeNumber, Name]) 
            {
            	if(!isInList(user.id)){	
	            	UserSelect u = new UserSelect(user, false);
	            	users.add(u);
            	}            	
            } 
            total = new Total(individualActual);    
        }        
        else {
        	scorecard = new Scorecard__c();
        }
    }
    
    public Boolean getHasNetBookings()
    {
    	Id ed = System.currentPageReference().getParameters().get('id');
    	List <Scorecard__c> netBookings;
    	
    	if (ed == null) 
    	{
    		//netBookings = [select Id, EffectiveDate__c from Scorecard__c where Department__c = :Label.Consulting_label AND Type__c = :Label.Net_Bookings_label];
    		netBookings = [select Id, EffectiveDate__c from Scorecard__c where Cost_Center__c = :Label.Consulting_label AND Type__c = :Label.Net_Bookings_label];
    	}
    	else
    	{
    		//netBookings = [select Id, EffectiveDate__c from Scorecard__c where EffectiveDate__c = :ed AND Department__c = :Label.Consulting_label AND Type__c = :Label.Net_Bookings_label];
    		netBookings = [select Id, EffectiveDate__c from Scorecard__c where EffectiveDate__c = :ed AND Cost_Center__c = :Label.Consulting_label AND Type__c = :Label.Net_Bookings_label];
    	}
    	
        if (netBookings.size() > 0) {
        	List <DeptScorecard__c> deptScorecards = [select Name, Id from DeptScorecard__c where Scorecard__c = :netBookings[0].Id];
        	if (deptScorecards.size() == 2)
        		return true;
        }
        
        return false;
    }
    
    public Boolean getHasBilling()
    {
    	Id ed = System.currentPageReference().getParameters().get('id');
    	List <Scorecard__c> billing;
    	
    	if (ed == null) 
    	{
    		//billing = [select Id, EffectiveDate__c from Scorecard__c where Department__c = :Label.Consulting_label AND Type__c = :Label.Billings_label];
    		billing = [select Id, EffectiveDate__c from Scorecard__c where Cost_Center__c = :Label.Consulting_label AND Type__c = :Label.Billings_label];
    	}
    	else
    	{
    		//billing = [select Id, EffectiveDate__c from Scorecard__c where EffectiveDate__c = :ed AND Department__c = :Label.Consulting_label AND Type__c = :Label.Billings_label];
    		billing = [select Id, EffectiveDate__c from Scorecard__c where EffectiveDate__c = :ed AND Cost_Center__c = :Label.Consulting_label AND Type__c = :Label.Billings_label];
    	}
    	
        if (billing.size() > 0) {
        	List <DeptScorecard__c> deptScorecards = [select Name, Id from DeptScorecard__c where Scorecard__c = :billing[0].Id];
        	if (deptScorecards.size() == 2)
        		return true;
        }
        
        return false;
    }
    
    public Boolean getHasMarginTarget()
    {
    	Id ed = System.currentPageReference().getParameters().get('id');
    	List <Scorecard__c> margin;
    	
    	if (ed == null) 
    	{
    		//margin = [select Id, EffectiveDate__c from Scorecard__c where Department__c = :Label.Consulting_label AND Type__c = :Label.Margin_Target_label];
    		margin = [select Id, EffectiveDate__c from Scorecard__c where Cost_Center__c = :Label.Consulting_label AND Type__c = :Label.Margin_Target_label];
    	}
    	else
    	{
    		//margin = [select Id, EffectiveDate__c from Scorecard__c where EffectiveDate__c = :ed AND Department__c = :Label.Consulting_label AND Type__c = :Label.Margin_Target_label];
    		margin = [select Id, EffectiveDate__c from Scorecard__c where EffectiveDate__c = :ed AND Cost_Center__c = :Label.Consulting_label AND Type__c = :Label.Margin_Target_label];
    	}
    	
        if (margin.size() > 0) {
        	List <DeptScorecard__c> deptScorecards = [select Name, Id from DeptScorecard__c where Scorecard__c = :margin[0].Id];
        	if (deptScorecards.size() == 2)
        		return true;
        }
        
        return false;
    }    
        
    public List<IndividualTarget> getIndividualTargetEmployees()
    {
        return individualTargetEmployees;
    }
    
    public List<IndividualActual> getIndividualActualEmployees()
    {
        return individualActualEmployees;   
    }
    
    public List<IndividualTarget> getIndividualTargetManagers()
    {
        return individualTargetManagers;
    }
    
    public List<IndividualActual> getIndividualActualManagers()
    {
        return individualActualManagers;   
    }
    
    public List<IndividualActual> getIndividualActual()
    {
        return individualActual;   
    }
    
    public List<SelectOption> getRatingSelectOptions() 
    {
        return PAMUtil.getRatingSelectOptions();
    }
    
    public Scorecard__c getScorecard()
    {
        return scorecard;
    }
    
    public Long getRating()
    {
    	if (scorecard.rating__c == null)
    		return 0;
        return Math.roundToLong(scorecard.rating__c);   
    }
    
    public void setRating(Long r)
    {
        rating = r; 
    }
    
    public Double getWeight()
    {
        return scorecard.Weight__c; 
    }
    
	//USER PROFILES 
    public String getUserProfile(){
    	String profileName;
    	User user = [Select u.Profile.Name, u.ProfileId From User u where Id =: UserInfo.getUserId()];	
    	if(user != null){
    		profileName = user.Profile.Name;
    	}
    	
    	return profileName;
    }
    
    public boolean getIsEducationProfile(){
    	if(getUserProfile() == 'Education Employee' || getUserProfile() == 'Education Manager'){
    		return true;
    	}
    	return false;
    }
    
    public boolean getIsSupportProfile(){
    	if(getUserProfile() == 'Support Employee' || getUserProfile() == 'Support Manager'){
    		return true;
    	}
    	return false;
    }
    
    public boolean getIsConsultingProfile(){
    	if(getUserProfile() == 'Consulting Employee' || getUserProfile() == 'Consulting Manager'){
    		return true;
    	}
    	return false;
    }
    
    public boolean getIsCSMProfile(){
    	if(getUserProfile() == 'CSM Employee' || getUserProfile() == 'CSM Manager'){
    		return true;
    	}
    	return false;
    }
    
    public boolean getHaveProfile(){
    	if(getIsEducationProfile()== false && getIsSupportProfile() == false && getIsConsultingProfile()== false && getIsCSMProfile() == false){
    		return false;
    	}
    	return true;
    }
    
 	//END OF USER PROFILES 
    public void newChangesReload(){
    	scorecard = null;
	    individualTargetEmployees = new List <IndividualTarget>();
	    individualActualEmployees = new List<IndividualActual>();
	    individualTargetManagers = new List <IndividualTarget>();
	    individualActualManagers = new List<IndividualActual>();
	    individualActual = new List<IndividualActual>();
	    
    	createObjects();
    }
    
    public boolean isInList(String id){
    	 for(IndividualTarget i : IndividualTargetManagers){
    	 	if(i.getEmployeeId() == id){
    	 		return true;
    	 	}	
    	 }
    	 return false;
    }
    
    public Integer getListSize(){
    	return individualTargetManagers.size();
    }
    
    public Total getTotal(){
    	return total;
    }
    	
	/**
    * Inner class, calculate totals
    */      
	public class Total
    {
		//INDIVIDUAL ACTUAL ATT      	
      	Double Q1IA = 0;
      	Double Q2IA = 0;
      	Double Q3IA = 0;
      	Double Q4IA = 0;
      	Double AVGQ1Q2IA = 0;
      	Double AVGQ3Q4IA = 0;
      	Long ratingQ1Q2IA = 0;
      	Long ratingQ3Q4IA = 0;
      	Double weightQ1Q2GIA = 0;
      	Double weightQ3Q4GIA = 0;
		//INDIVIDUAL TARGET ATT	
      	Double Q1IT = 0;
      	Double Q2IT = 0;
      	Double Q3IT = 0;
      	Double Q4IT = 0;
      	Double AVGQ1Q2IT = 0;
      	Double AVGQ3Q4IT = 0;
      	Long ratingQ1Q2IT = 0;
      	Long ratingQ3Q4IT = 0;
      	Double weightQ1Q2GIT = 0;
      	Double weightQ3Q4GIT = 0;
      	
      	List <IndividualActual> individualActuals = new List<IndividualActual>();
      	
      	public Total(List <IndividualActual> individualActualsTot){			
      		individualActuals = individualActualsTot;
      	}

		// INDIVIDUAL ACTUAL GETTERS       	
      	public Double getQ1IA()
        {        	
        	for(IndividualActual i:individualActuals){
        		Q1IA += i.getQ1Group();
        	}
			Decimal shortDouble = Q1IA;	
            return shortDouble.divide(individualActuals.size(),1,System.RoundingMode.HALF_UP);
        }
        
        public Double getQ2IA()
        {
        	for(IndividualActual i:individualActuals){
        		Q2IA += i.getQ2Group();
        	}
            Decimal shortDouble = Q2IA;	
            return shortDouble.divide(individualActuals.size(),1,System.RoundingMode.HALF_UP);
        }
        
        public Double getQ3IA()
        {
        	for(IndividualActual i:individualActuals){
        		Q3IA += i.getQ3Group();
        	}
            Decimal shortDouble = Q3IA;	
            return shortDouble.divide(individualActuals.size(),1,System.RoundingMode.HALF_UP);
        }
        
        public Double getQ4IA()
        {
        	for(IndividualActual i:individualActuals){
        		Q4IA += i.getQ4Group();
        	}
            Decimal shortDouble = Q4IA;	
            return shortDouble.divide(individualActuals.size(),1,System.RoundingMode.HALF_UP);
        }
        
        public Double getAVGQ1Q2IA()
        {
        	for(IndividualActual i:individualActuals){
        		AVGQ1Q2IA += i.getAVGQ1Q2Group();
        	}
            Decimal shortDouble = AVGQ1Q2IA;	
            return shortDouble.divide(individualActuals.size(),1,System.RoundingMode.HALF_UP);
        }
        
        public Double getAVGQ3Q4IA()
        {
        	for(IndividualActual i:individualActuals){
        		AVGQ3Q4IA += i.getAVGQ3Q4Group();
        	}
            Decimal shortDouble = AVGQ3Q4IA;	
            return shortDouble.divide(individualActuals.size(),1,System.RoundingMode.HALF_UP);
        }
        
        public Long getRatingQ1Q2IA()
        {
        	for(IndividualActual i:individualActuals){
        		ratingQ1Q2IA += i.getRatingQ1Q2Group();
        	}
            return Math.roundToLong(ratingQ1Q2IA / individualActuals.size());
        }
        
        public Long getRatingQ3Q4IA()
        {
        	for(IndividualActual i:individualActuals){
        		ratingQ3Q4IA += i.getRatingQ3Q4Group();
        	}
             return Math.roundToLong(ratingQ3Q4IA / individualActuals.size());
        }
        
        public Double getWeightQ1Q2IA()
        {
        	for(IndividualActual i:individualActuals){
        		weightQ1Q2GIA += i.getWeightQ1Q2Group();
        	}
            Decimal shortDouble = weightQ1Q2GIA;	
            return shortDouble.divide(individualActuals.size(),1,System.RoundingMode.HALF_UP);
        }
        
        public Double getWeightQ3Q4IA()
        {
        	for(IndividualActual i:individualActuals){
        		weightQ3Q4GIA += i.getWeightQ3Q4Group();
        	}
            Decimal shortDouble = weightQ3Q4GIA;	
            return shortDouble.divide(individualActuals.size(),1,System.RoundingMode.HALF_UP);
        }
                
		// INDIVIDUAL TARGET GETTERS       	
      	public Double getQ1IT()
        {
        	for(IndividualActual i:individualActuals){
        		Q1IT += i.individualActual.Q1__c;
        	}
        	
            Decimal shortDouble = Q1IT;	
            return shortDouble.divide(individualActuals.size(),1,System.RoundingMode.HALF_UP);
        }
        
        public Double getQ2IT()
        {
        	for(IndividualActual i:individualActuals){
        		Q2IT += i.individualActual.Q2__c;
        	}
            Decimal shortDouble = Q2IT;	
            return shortDouble.divide(individualActuals.size(),1,System.RoundingMode.HALF_UP);
        }
        
        public Double getQ3IT()
        {
        	for(IndividualActual i:individualActuals){
        		Q3IT += i.individualActual.Q3__c;
        	}
            Decimal shortDouble = Q3IT;	
            return shortDouble.divide(individualActuals.size(),1,System.RoundingMode.HALF_UP);
        }
        
        public Double getQ4IT()
        {
        	for(IndividualActual i:individualActuals){
        		Q4IT += i.individualActual.Q4__c;
        	}
            Decimal shortDouble = Q4IT;	
            return shortDouble.divide(individualActuals.size(),1,System.RoundingMode.HALF_UP);
        }
        
        public Double getAVGQ1Q2IT()
        {
        	for(IndividualActual i:individualActuals){
        		AVGQ1Q2IT += i.getAVGQ1Q2();
        	}
            Decimal shortDouble = AVGQ1Q2IT;	
            return shortDouble.divide(individualActuals.size(),1,System.RoundingMode.HALF_UP);
        }
        
        public Double getAVGQ3Q4IT()
        {
        	for(IndividualActual i:individualActuals){
        		AVGQ3Q4IT += i.getAVGQ3Q4();
        	}
            Decimal shortDouble = AVGQ3Q4IT;	
            return shortDouble.divide(individualActuals.size(),1,System.RoundingMode.HALF_UP);
        }
        
        public Long getRatingQ1Q2IT()
        {
        	for(IndividualActual i:individualActuals){
        		ratingQ1Q2IT += i.getRatingQ1Q2();
        	}
            return Math.roundToLong(ratingQ1Q2IT / individualActuals.size());
        }
        
        public Long getRatingQ3Q4IT()
        {
        	for(IndividualActual i:individualActuals){
        		ratingQ3Q4IT += i.getRatingQ3Q4();
        	}
             return Math.roundToLong(ratingQ3Q4IT / individualActuals.size());
        }
        
        public Double getWeightQ1Q2IT()
        {
        	for(IndividualActual i:individualActuals){
        		weightQ1Q2GIT += i.getWeightQ1Q2();
        	}
            Decimal shortDouble = weightQ1Q2GIT;	
            return shortDouble.divide(individualActuals.size(),1,System.RoundingMode.HALF_UP);
        }
        
        public Double getWeightQ3Q4IT()
        {
        	for(IndividualActual i:individualActuals){
        		weightQ3Q4GIT += i.getWeightQ3Q4();
        	}
            Decimal shortDouble = weightQ3Q4GIT;	
            return shortDouble.divide(individualActuals.size(),1,System.RoundingMode.HALF_UP);
        }	
	}
      
    /**
    * Inner class, AVG column must be calculated.
    */      
    public class IndividualActual
	{
        IndividualActualScorecard__c individualActual;
        List<IndividualTargetScorecard__c> individualTList;
        List <IndividualActualScorecard__c> individualTarget;
        IndividualActualScorecard__c targetByTeam;
        
        Double Q1Group = 0;
        Double Q2Group = 0;
        Double Q3Group = 0;
        Double Q4Group = 0;
        Double AVGQ1Q2Group = 0;
        Double AVGQ3Q4Group = 0;
        Long ratingQ1Q2Group = 0;
        Long ratingQ3Q4Group = 0;
        Double weightQ1Q2Group = 0;
        Double weightQ3Q4Group = 0;        
        
        public IndividualActual(IndividualActualScorecard__c iA, List<IndividualTargetScorecard__c> iT,List<IndividualActualScorecard__c> iAList )
        {
            individualActual = iA;
            individualTList = iT;
            individualTarget = iAList;
                        
            GroupValues();        
        }
        
        public IndividualActual(){
        	
        }
        
        public IndividualActualScorecard__c getIndividualActual()
        {
            return individualActual;
        }
      
        //No other way to do it more simple.
        public String getQ1()
        {
            if (string.valueOf(individualActual.Q1__c) == '-1')
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(individualActual.Q1__c);
            }
        }
        
        public String getQ2()
        {
            if (string.valueOf(individualActual.Q2__c) == '-1')
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(individualActual.Q2__c);
            }
        }
        
        public String getQ3()
        {
            if (string.valueOf(individualActual.Q3__c) == '-1')
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(individualActual.Q3__c);
            }
        }
        
        public String getQ4()
        {
            if (string.valueOf(individualActual.Q4__c) == '-1')
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(individualActual.Q4__c);
            }
        }
        
        public Long getRatingQ1Q2()
        {
            //Not sure why should be this, for now return actual group value
            return Math.roundToLong(ratingQ1Q2Group);
        }
        
        public Long getRatingQ3Q4()
        {
            //Not sure why should be this, for now return actual group value
            return Math.roundToLong(ratingQ3Q4Group);
        }
        
        public Double getAVGQ1Q2()
        {
            //Return for AVG Q1Q2 Column
            Double doubleNumber = (individualActual.Q1__c + individualActual.Q2__c) / 2;
            return  doubleNumber;
        }
        
        public Double getAVGQ3Q4()
        {
            //Return for AVG Q3Q4 Column
            Double doubleNumber = (individualActual.Q3__c + individualActual.Q4__c) / 2;
            return  doubleNumber;
        }
        
        public Double getWeightQ1Q2()
        {
            return individualActual.WeightQ1Q2__c;
        }
         
        public Double getWeightQ3Q4()
        {
            return individualActual.weightQ3Q4__c;
        }       
        
        //Here start getters to calculated values from individual
        public Double getQ1Group()
        {
            String shortDouble = string.valueOf(Q1Group);
            
            if (shortDouble.length() >= 4)
            {
                shortDouble = shortDouble.subString(0,4);
                
                Double returnDouble = double.valueOf(shortDouble);
                return  returnDouble;
            }
            else
            {
                return Q1Group;
            }
        }
        
        public Double getQ2Group()
        {
            String shortDouble = string.valueOf(Q2Group);
            
            if (shortDouble.length() >= 4)
            {
                shortDouble = shortDouble.subString(0,4);
                
                Double returnDouble = double.valueOf(shortDouble);
                return  returnDouble;
            }
            else
            {
                return  Q2Group;
            }
        }
        
        public Double getQ3Group()
        {
            String shortDouble = string.valueOf(Q3Group);
            
            if (shortDouble.length() >= 4)
            {
                shortDouble = shortDouble.subString(0,4);
                
                Double returnDouble = double.valueOf(shortDouble);
                return  returnDouble;
            }
            else
            {
                return Q3Group;
            }
        }
        
        public Double getQ4Group()
        {
            String shortDouble = string.valueOf(Q4Group);
            if (shortDouble.length() >= 4)
            {
                shortDouble = shortDouble.subString(0,4);
                
                Double returnDouble = double.valueOf(shortDouble);
                return  returnDouble;
            }
            else
            {
                return Q4Group; 
            }
        }
        
        public Long getRatingQ1Q2Group()
        { 
           return Math.roundToLong(ratingQ1Q2Group);
        }
        
        public Long getRatingQ3Q4Group()
        {            
            return Math.roundToLong(ratingQ3Q4Group);
        }
        
        public Double getAVGQ1Q2Group()
        {
            Decimal shortDouble = AVGQ1Q2Group;
            return shortDouble.divide(1,1,System.RoundingMode.HALF_UP);
        }
        
        public Double getAVGQ3Q4Group()
        {
            Decimal shortDouble = AVGQ3Q4Group;
            return shortDouble.divide(1,1,System.RoundingMode.HALF_UP);
        }
        
        public Double getWeightQ1Q2Group()
        {
            String shortDouble = string.valueOf(weightQ1Q2Group);
            if (shortDouble.length() >= 4)
            {
                shortDouble = shortDouble.subString(0,4);
                
                Double returnDouble = double.valueOf(shortDouble);
                return  returnDouble;
            }
            else
            {
                return weightQ1Q2Group; 
            }
        }
        
        public Double getWeightQ3Q4Group()
        {
            String shortDouble = string.valueOf(weightQ3Q4Group);
            if (shortDouble.length() >= 4)
            {
                shortDouble = shortDouble.subString(0,4);
                
                Double returnDouble = double.valueOf(shortDouble);
                return  returnDouble;
            }
            else
            {
                return weightQ3Q4Group; 
            }
        }       
        
        //Calculates all group values by team
        public void GroupValues()
        { 
            Integer teamMembers = 0;
            List <IndividualTargetScorecard__c> inSameTeam = new List<IndividualTargetScorecard__c>();            
    
            for (IndividualTargetScorecard__c currentIndividual : individualTList)
            {
                //Check if current employee is in current team
                if (currentIndividual.Employee__r.CompetencyGroupCode__c == individualActual.Team__c)
                {
                    //Check for all if none n/a value had been entered. If this is the case, ignore this
                    //and move on.                    
                    if (currentIndividual.Q1__c != -1)
                    {
                        Q1Group =   Math.roundToLong(currentIndividual.Q1__c) + Q1Group;
                    }
                    if (currentIndividual.Q2__c != -1)
                    {
                        Q2Group =   Math.roundToLong(currentIndividual.Q2__c) + Q2Group;
                    }
                    
                    if (currentIndividual.Q3__c != -1)
                    {
                        Q3Group =   Math.roundToLong(currentIndividual.Q3__c) + Q3Group;
                    }
                    if (currentIndividual.Q4__c != -1)
                    {
                        Q4Group =   Math.roundToLong(currentIndividual.Q4__c) + Q4Group; 
                    }
                    
                    //Not sure if this is the correct logic to apply in these cases
                    //When is -1 means it shows n/a value.
                    if (currentIndividual.Q1__c != -1 && currentIndividual.Q2__c != - 1)
                    {
                        AVGQ1Q2Group = ((currentIndividual.Q1__c + currentIndividual.Q2__c) / 2)  + AVGQ1Q2Group;
                    }
                    else
                    {
                        if (currentIndividual.Q1__c == -1)
                        {
                            AVGQ1Q2Group = currentIndividual.Q2__c;
                        }
                        if (currentIndividual.Q2__c == -1)
                        {
                            AVGQ1Q2Group = currentIndividual.Q1__c;
                        }
                    } 
                    
                    //Not sure if this is the correct logic to apply in these cases
                    //When is -1 means it shows n/a value.
                    if ((currentIndividual.Q3__c != -1) && (currentIndividual.Q4__c != -1))
                    {
                        AVGQ3Q4Group = ((currentIndividual.Q3__c + currentIndividual.Q4__c) / 2)  + AVGQ3Q4Group;                       
                    }
                    else
                    {
                        if (currentIndividual.Q3__c == -1)
                        {
                            AVGQ3Q4Group = currentIndividual.Q4__c; 
                        }
                        if (currentIndividual.Q4__c == -1)
                        {
                            AVGQ3Q4Group = currentIndividual.Q3__c; 
                        } 
                    }
                    
                    //Rating value is calculated            
                    Double target;
                    Double actual;
                    Long calculatedRating = 0;
                    targetByTeam = IndividualByTeamName(currentIndividual.Employee__r.CompetencyGroupCode__c);                    
                    
                    if (targetByTeam != null)
                    {   
                        //Not sure if this is the right business logic
                        if ((currentIndividual.Q3__c != -1) && (currentIndividual.Q4__c != -1))
                        {
                            actual = (currentIndividual.Q3__c + currentIndividual.Q4__c) / 2;
                        }
                        else
                        {
                            if (currentIndividual.Q3__c == -1)
                            {
                                actual = currentIndividual.Q4__c;
                            }
                            if (currentIndividual.Q4__c == -1)
                            {
                                actual = currentIndividual.Q3__c;
                            }
                        }                      
                        
                        calculatedRating = PAMUtil.getRatingFromActualTarget(actual);
                        
                        ratingQ3Q4Group = ratingQ3Q4Group + calculatedRating;
                        
                        if (currentIndividual.Q1__c != -1 && currentIndividual.Q2__c != -1)
                        {
                            actual = (currentIndividual.Q1__c + currentIndividual.Q2__c) / 2;
                        }
                        else
                        {
                            if (currentIndividual.Q1__c == -1)
                            {
                                actual = currentIndividual.Q2__c;
                            }
                            if (currentIndividual.Q2__c == -1)
                            {
                                actual = currentIndividual.Q1__c;
                            }
                        }                        
                      
                        calculatedRating = PAMUtil.getRatingFromActualTarget(actual);
                        
                        ratingQ1Q2Group = ratingQ1Q2Group + calculatedRating;
                    }                    
                    
                    //Check if it has null values, this field had been added later than other.                    
                    if (currentIndividual.weightQ1Q2__c != null)
                    {
                        weightQ1Q2Group = currentIndividual.weightQ1Q2__c + weightQ1Q2Group;    
                    }                
                    
                    if (currentIndividual.weightQ3Q4__c != null)
                    {
                        weightQ3Q4Group = currentIndividual.weightQ3Q4__c + weightQ3Q4Group;
                    }
                    
                    //Increment team member of current group
                    teamMembers++;                    
                }
            }
            
            //Check invalid Data in database, this could fail div operation.
            if (teamMembers != 0)
            {
                //Do average    
                Q1Group = Q1Group / teamMembers;
                Q2Group = Q2Group / teamMembers;
                Q3Group = Q3Group / teamMembers;
                Q4Group = Q4Group / teamMembers;
                AVGQ1Q2Group = AVGQ1Q2Group / teamMembers;
                AVGQ3Q4Group = AVGQ3Q4Group / teamMembers;
                ratingQ1Q2Group = ratingQ1Q2Group / teamMembers;
                ratingQ3Q4Group = ratingQ3Q4Group / teamMembers;
                weightQ1Q2Group = weightQ1Q2Group / teamMembers;
                weightQ3Q4Group = weightQ3Q4Group / teamMembers;
            }
        }
        
        public IndividualActualScorecard__c IndividualByTeamName(String teamName)
        {            
            //Found target values by team.            
            IndividualActualScorecard__c targetByTeam;
            
            for (IndividualActualScorecard__c currentIndividual : individualTarget)
            {
                if (currentIndividual.Team__c == teamName)
                {
                    targetByTeam = currentIndividual;
                }   
            }
            
            return targetByTeam;
        }
    }    
     
	/**
    * Inner class, AVG column must be calculated.
    */      
    public class IndividualTarget
    {
        IndividualTargetScorecard__c individualTargetScorecard;
        List <IndividualActualScorecard__c> individualByTeam;
        IndividualActualScorecard__c targetByTeam;
        
        //Hold group values from same team   
        List<IndividualTargetScorecard__c> individualTList;
        
        public IndividualTarget(IndividualTargetScorecard__c uT,List<IndividualTargetScorecard__c> iL, List<IndividualActualScorecard__c> iT )
        {
            individualTargetScorecard = uT;
            individualTList = iL;
            individualByTeam = iT;
            targetByTeam = IndividualByTeamName(individualTargetScorecard.Employee__r.CompetencyGroupCode__c);
        }
        
        public IndividualTargetScorecard__c getIndividualTargetScorecard()
        {
            return individualTargetScorecard;
        }
        
        public String getLastFirstName()
        {
            return  individualTargetScorecard.Employee__r.LastName + ', ' + individualTargetScorecard.Employee__r.FirstName;
        }
        
        public String getEmployeeId()
        {
            return  individualTargetScorecard.Employee__c;
        }
        
        public Double getAVGQ1Q2()
        {
            //Return for AVG Q1Q2 Column            
            if (individualTargetScorecard.Q1__c == -1)
            {
                return  individualTargetScorecard.Q2__c;
            }
            
            if (individualTargetScorecard.Q2__c == -1)
            {
                return  individualTargetScorecard.Q1__c;
            }
            
            Double doubleNumber = (individualTargetScorecard.Q1__c + individualTargetScorecard.Q2__c) / 2;
            
            Decimal shortValue = doubleNumber;
            
            return shortValue.divide(1,1,System.RoundingMode.HALF_UP);
        }
        
        public Double getAVGQ3Q4()
        {
            //Return for AVG Q3Q4 Column            
            if (individualTargetScorecard.Q3__c == -1)
            {
                return  individualTargetScorecard.Q4__c;
            }
            
            if (individualTargetScorecard.Q4__c == -1)
            {
                return  individualTargetScorecard.Q3__c;
            }
            
            Decimal doubleNumber = (individualTargetScorecard.Q3__c + individualTargetScorecard.Q4__c) / 2;
               Decimal shortValue = doubleNumber;
            
            return shortValue.divide(1,1,System.RoundingMode.HALF_UP);
        }
        
        //No other way to do it more simple.
        public String getQ1()
        {
            if (string.valueOf(individualTargetScorecard.Q1__c) == '-1')
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(individualTargetScorecard.Q1__c);
            }            
        }
        
        public String getQ2()
        {
            if (string.valueOf(individualTargetScorecard.Q2__c) == '-1')
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(individualTargetScorecard.Q2__c);
            }
        }
        
        public String getQ3()
        {
            if (string.valueOf(individualTargetScorecard.Q3__c) == '-1')
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(individualTargetScorecard.Q3__c);
            }
        }
        
        public String getQ4()
        {
            if (string.valueOf(individualTargetScorecard.Q4__c) == '-1')
            {
                return 'n/a';
            }
            else
            {
                return string.valueOf(individualTargetScorecard.Q4__c);
            }
        }
        
        public Long getRatingQ1Q2()
        {
            //Rating value is calculated
			//Not sure if this is the right business logic         
            Long calculatedRating = 0;
            Double total;
            
            if ((individualTargetScorecard.Q1__c != -1) && (individualTargetScorecard.Q2__c != -1))  
            {
                total = (individualTargetScorecard.Q1__c + individualTargetScorecard.Q2__c) / 2;
            }
            else
            {
                if (individualTargetScorecard.Q1__c == -1)
                {
                    total = individualTargetScorecard.Q2__c;
                }
                if (individualTargetScorecard.Q2__c == -1)
                {
                    total = individualTargetScorecard.Q1__c;
                }
            }
            
            calculatedRating = PAMUtil.getRatingFromActualTarget(total);
            
            return calculatedRating;
        }
        
        public Long getRatingQ3Q4()
        {               
            Long calculatedRating = 0;
            Double total;
            
            if ((individualTargetScorecard.Q3__c != -1) && (individualTargetScorecard.Q4__c != -1))  
            {
                total = (individualTargetScorecard.Q3__c + individualTargetScorecard.Q4__c) / 2;
            }
            else
            {
                if (individualTargetScorecard.Q3__c == -1)
                {
                    total = individualTargetScorecard.Q4__c;
                }
                if (individualTargetScorecard.Q4__c == -1)
                {
                    total = individualTargetScorecard.Q3__c;
                }
            }
            
            calculatedRating = PAMUtil.getRatingFromActualTarget(total);
            
            return calculatedRating;
        }
        
        public Double getWeightQ1Q2()
        {
            if (individualTargetScorecard.weightQ1Q2__c != null)
            {
                return  individualTargetScorecard.WeightQ1Q2__c;
            }
            else
            {
                return 0;   
            }
        }
    
        public Double getWeightQ3Q4()
        {
            if (individualTargetScorecard.weightQ3Q4__c != null)
            {
                return  individualTargetScorecard.WeightQ3Q4__c;
            }
            else
            {
                return 0;   
            }
        }
                
        public IndividualActualScorecard__c IndividualByTeamName(String teamName)
        {            
            //Found target values by team.            
            IndividualActualScorecard__c targetByTeam;
            
            for (IndividualActualScorecard__c currentIndividual : individualByTeam)
            {
                if (currentIndividual.Team__c == teamName)
                {
                    targetByTeam = currentIndividual;
                }   
            }
            
            return targetByTeam;
        }        
    }
    
    // Effective Date 
    // Only one scorecard for Effective Date, Department and Type
    public List<SelectOption> getEffectiveDateSelectOptions() 
    {
        list<SelectOption> options = new List<SelectOption>();
        list<Scorecard__c> effectivesDate = [Select Id, 
                                                    EffectiveDate__c
                                            From Scorecard__c ORDER BY  EffectiveDate__c ];
        Integer index = 0;
        
        for (Scorecard__c ed : effectivesDate)
        {
            if (index > 0)
            {
                if (effectivesDate[index - 1].EffectiveDate__c != ed.EffectiveDate__c)
                {
                     options.add(new SelectOption(ed.EffectiveDate__c, ed.EffectiveDate__c));   
                }
            }
            else
            {
                 options.add(new SelectOption(ed.EffectiveDate__c, ed.EffectiveDate__c));   
            }
            
            index++;
        }
        
        return options;
    }
    
    public String getEffectiveDate()
    {
        return effectiveDate;
    }
    
    public void setEffectiveDate(String ed)
    {
        effectiveDate = ed;
    }

    // Overlay    
    public list<UserSelect> getUsers() {
        return users;
    }
    
    public class UserSelect {
        User user;  
        boolean selected;
        
        public UserSelect(User u, boolean s) {
            user = u;
            selected = s;
        }
        
        public User getUser() {
            return user;    
        }
        
        public boolean getSelected() {
            return selected;    
        }
        
        public void setSelected(boolean s) {
            selected = s;   
        }
        
        public String getLastFirstName() {
            return user.LastName + ', ' + user.FirstName;
        }
    }
    
    /**
    *       Pagination        
    */    
    /**
    * Set of Integers to control pagination
    */
    public Integer numberOfItemsToShow = 20;
    public Integer cntPagination;
    public Integer currentPagination = 1;
    public Integer firstRow = 0;
    
    public Integer totalItemsNumber= 0;
    
    public Integer getTotalItemsNumber () {
        return totalItemsNumber;
    }

    /**
    * Set of Booleans to show or not prev / next links
    */
    public boolean prevPageLinkShow = false;
    public boolean prevPageShow  = false;
    public boolean nextPageLinkShow  = false;
    public boolean nextPageShow  = false;
        
    public void genCntPagination () {
        
        cntPagination = (totalItemsNumber - (Math.mod(totalItemsNumber, numberOfItemsToShow)))/ numberOfItemsToShow;    
        if (Math.mod(totalItemsNumber, numberOfItemsToShow) != 0 ) {
            cntPagination++;
        }   
    }
    
    public void nextPage () {
        currentPagination++;
        jumpPage = currentPagination;
        firstRow = firstRow + numberOfItemsToShow;          
    }
    
    public void prevPage () {
        currentPagination--;
        jumpPage = currentPagination;
        firstRow = firstRow - numberOfItemsToShow;  
    }

    /* Last Page */
    public void lastPage () {
        currentPagination = cntPagination;
        jumpPage = cntPagination;
        firstRow = (jumpPage - 1)* numberOfItemsToShow;     
    }
    
    /* First Page */
    public void firstPage () {
        currentPagination = 1;
        jumpPage = 1;
        firstRow = (jumpPage - 1)* numberOfItemsToShow; 
    }

    /**
    * Pagination Integer Getters
    */
    public Integer getFirstItem () {
        return (firstRow + 1);
    }
    
    public Integer getLastItem () {
        Integer lastItem;
        if ((currentPagination == cntPagination) || (currentPagination == 1 && (totalItemsNumber < numberOfItemsToShow))) {
            lastItem = firstRow + Math.mod(totalItemsNumber, numberOfItemsToShow);
        }
        else {
            lastItem = firstRow + numberOfItemsToShow;
        }
        return lastItem;
    }
    
    public Integer getCurrentPagination () {
        return currentPagination;
    }
    
    public Integer getCntPagination () {
        return cntPagination;
    }
    
    public Integer getNumberOfItemsToShow () {
        return numberOfItemsToShow;
    }
    
    public Integer getFirstRow () {
        return firstRow;
    }
    
    /**
    * Pagination Boolean Getters
    */    
    public boolean getPrevPageLinkShow () {
        
        if (currentPagination == 1){ 
        	prevPageLinkShow = false;       
        } 
        else {
        	prevPageLinkShow = true;
        }
        
        return prevPageLinkShow;
    }
    
    public boolean getPrevPageShow () {
        
        if (currentPagination == 1){ 
        	prevPageShow = true; 
        } 
        else {
        	prevPageShow = false;
        }
        
        return prevPageShow;
    }
    
    public boolean getNextPageLinkShow () {
        
        if (currentPagination == cntPagination || cntPagination == 0){   
        	nextPageLinkShow = false; 
        } 
        else { 
        	nextPageLinkShow = true;
        }          
        
        return nextPageLinkShow;
    }
    
    public boolean getNextPageShow () {
        
        if(currentPagination == cntPagination || cntPagination == 0) { 
        	nextPageShow = true; 
        } 
        else { 
        	nextPageShow = false;
        } 
        
        return nextPageShow;
    }   
    
    /**
    *        Jump to Page      
    */    
    public Integer jumpPage = 1;
    
    public Integer getJumpPage () {
        return jumpPage;
    }
    
    public void setJumpPage (Integer jumpPage) {
        this.jumpPage = jumpPage;
    }
    
    public void JumpToPage () {
        if (jumpPage > cntPagination) {
            currentPagination = cntPagination;
            jumpPage = cntPagination;
        }
        else {
            if (jumpPage < 1) {
                currentPagination = 1;
                jumpPage = 1;
            }
            else {  
                currentPagination = jumpPage;
            }
        }
        firstRow = (jumpPage - 1)* numberOfItemsToShow;
    }

    /**
    *  Pagination    2   
    */
    /**
    * Set of Integers to control pagination
    */
    public Integer numberOfItemsToShowManager = 10;
    public Integer cntPaginationManager;
    public Integer currentPaginationManager = 1;
    public Integer firstRowManager = 0;
    
    public Integer totalItemsNumberManager= 0;
    
    public Integer getTotalItemsNumberManager () {
        return totalItemsNumberManager;
    }

    /**
    * Set of Booleans to show or not prev / next links
    */
    public boolean prevPageLinkShowManager = false;
    public boolean prevPageShowManager  = false;
    public boolean nextPageLinkShowManager  = false;
    public boolean nextPageShowManager  = false;
        
    public void genCntPaginationManager () {        
        cntPaginationManager = (totalItemsNumberManager - (Math.mod(totalItemsNumberManager, numberOfItemsToShowManager)))/ numberOfItemsToShowManager; 
        if (Math.mod(totalItemsNumberManager, numberOfItemsToShowManager) != 0 ) {
            cntPaginationManager++;
        }           
    }
    
    public void nextPageManager () {
        currentPaginationManager++;
        jumpPageManager = currentPaginationManager;
        firstRowManager = firstRowManager + numberOfItemsToShowManager;         
    }
    
    public void prevPageManager () {
        currentPaginationManager--;
        jumpPageManager = currentPaginationManager;
        firstRowManager = firstRowManager - numberOfItemsToShowManager; 
    }

    /* Last Page */
    public void lastPageManager () {
        currentPaginationManager = cntPaginationManager;
        jumpPageManager = cntPaginationManager;
        firstRowManager = (jumpPageManager - 1)* numberOfItemsToShowManager;        
    }
    
    /* First Page */
    public void firstPageManager () {
        currentPaginationManager = 1;
        jumpPageManager = 1;
        firstRow = (jumpPageManager - 1)* numberOfItemsToShowManager;   
    }

    /**
    * Pagination Integer Getters
    */
    public Integer getFirstItemManager () {
        return (firstRowManager + 1);
    }
    
    public Integer getLastItemManager () {
        Integer lastItemManager;
        if (currentPaginationManager == cntPaginationManager || (currentPaginationManager == 1 && totalItemsNumberManager < numberOfItemsToShowManager)) {
            lastItemManager = firstRowManager + Math.mod(totalItemsNumberManager, numberOfItemsToShowManager);
        }
        else {
            lastItemManager = firstRowManager + numberOfItemsToShowManager;
        }
        return lastItemManager;
    }
    
    public Integer getCurrentPaginationManager () {
        return currentPaginationManager;
    }
    
    public Integer getCntPaginationManager () {
        return cntPaginationManager;
    }
    
    public Integer getNumberOfItemsToShowManager () {
        return numberOfItemsToShowManager;
    }
    
    public Integer getFirstRowManager () {
        return firstRowManager;
    }
    
    /**
    * Pagination Boolean Getters
    */    
    public boolean getPrevPageLinkShowManager () {        
        if (currentPaginationManager == 1){ 
        	prevPageLinkShowManager = false;     
        } 
        else {
        	prevPageLinkShowManager = true;
        }
        
        return prevPageLinkShowManager;
    }
    
    public boolean getPrevPageShowManager () {        
        if(currentPaginationManager == 1){  
        	prevPageShowManager = true; 
        } 
        else {
        	prevPageShowManager = false;
        }
        
        return prevPageShowManager;
    }
    
    public boolean getNextPageLinkShowManager () {        
        if(currentPaginationManager == cntPaginationManager || cntPaginationManager == 0){  
        	nextPageLinkShowManager = false; 
        } 
        else { 
        	nextPageLinkShowManager = true;
        }           
        
        return nextPageLinkShowManager;
    }
    
    public boolean getNextPageShowManager () {        
        if (currentPaginationManager == cntPaginationManager || cntPaginationManager == 0){ 
        	nextPageShowManager = true; 
        } 
        else { 
        	nextPageShowManager = false;
        } 
        
        return nextPageShowManager;
    }   
    
    /**
    /*    Jump to Page      
    */    
    public Integer jumpPageManager = 1;
    
    public Integer getJumpPageManager () {
        return jumpPageManager;
    }
    
    public void setJumpPageManager (Integer jumpPageManager) {
        this.jumpPageManager = jumpPageManager;
    }
    
    public void JumpToPageManager () {
        if (jumpPageManager > cntPaginationManager) {
            currentPaginationManager = cntPaginationManager;
            jumpPageManager = cntPaginationManager;
        }
        else {
            if (jumpPageManager < 1) {
                currentPaginationManager = 1;
                jumpPageManager = 1;
            }
            else {  
                currentPaginationManager = jumpPageManager;
            }
        }
        firstRowManager = (jumpPageManager - 1)* numberOfItemsToShowManager;
    }
        
}