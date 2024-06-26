@isTest
private class Test_V2MOMUtil {
    
    public static testMethod void execute_methods_V2MOMUtil() {
        V2MOM_Util.isTest = true;

        //Create a new V2MOM
        User employeeStandard  = [select id, username, name, Profile.Name from User where username=:GenerateEnvironmentTestUsers.ccstndmngr];
        V2MOM__c v2momIndividual = GenerateEnvironmentTest3.createV2MOM(employeeStandard.Id, 'Vision', 'Individual', 'Test V2MOM Individual', 'FY08', 'My Management Hierarchy');
        V2MOM__c v2momIndividual2 = GenerateEnvironmentTest3.createV2MOM(employeeStandard.Id, 'Vision', 'Individual', 'Test V2MOM Individual2', 'FY11', 'My Management Hierarchy');
        v2momIndividual.Status__c = 'Rejected';
        update v2momIndividual;
        Set<Id> v2moms = new Set<Id>();
        v2moms.add(v2momIndividual.Id);
        String effectiveDate = V2MOM_Util.getDefaultEffectiveDate();
        system.assert(effectiveDate != null);      
        V2MOM_Util.sumVisits();
        //Verify the requires reapproval method
        V2MOM_Util.set_v2mom_status_to_requires_reapproval(v2moms);
        
        //Verify setAlready executed check for locked
        V2MOM_Util.setAlready_executed_check_for_locked(true);
        V2MOM_Util.already_executed_check_for_locked=true;
        
        
        //Verify check for locked v2moms
        Map<Id, Set<Integer>> v2mom_with_changing_measures = new Map<Id, Set<Integer>>();
        list<Measure__c> old_children = new list<Measure__c>(); 
		list<Measure__c> new_children = new list<Measure__c>();         
        V2MOM_Util.check_for_locked_v2moms(v2mom_with_changing_measures, true, false, '', old_children, new_children); 
        
        //Verify add child index to map
        V2MOM_Util.add_child_index_to_map(v2momIndividual.Id, 2, v2mom_with_changing_measures);
        
        //Verify that the v2mom would require reapproval    
        V2MOM_Util.v2mom_change_that_would_require_reapproval(v2momIndividual, v2momIndividual2);
        
        //Verify that value change that would require reapproval
        Value__c value1 = GenerateEnvironmentTest1.createValue('test value', 'test value tag line 1', 1, v2momIndividual.Id);
		Value__c value2 = GenerateEnvironmentTest1.createValue('test value', 'test value tag line 2', 1, v2momIndividual2.Id);
        V2MOM_Util.value_change_that_would_require_reapproval(value1, value2);
        
        //Verify that method change that would require_reapproval
        Method__c method1 = GenerateEnvironmentTest3.createMethod(v2momIndividual.Id, null, 1, 'Method 1', 'Description method 1');
        Method__c method2 = GenerateEnvironmentTest3.createMethod(v2momIndividual2.Id, null, 1, 'Method 1', 'Description method 1');
        V2MOM_Util.method_change_that_would_require_reapproval(method1, method2);  
    }
    
    public static testMethod void test_check_for_locked_v2moms() {
            V2MOM_Util.isTest = true;

        //Create a new V2MOM
        User employeeStandard  = [select id, username, name, Profile.Name from User where username=:GenerateEnvironmentTestUsers.ccstndmngr];
        V2MOM__c v2momIndividual = GenerateEnvironmentTest3.createV2MOM(employeeStandard.Id, 'Vision', 'Individual', 'Test V2MOM Individual', 'FY08', 'My Management Hierarchy');
        V2MOM__c v2momIndividual2 = GenerateEnvironmentTest3.createV2MOM(employeeStandard.Id, 'Vision', 'Individual', 'Test V2MOM Individual2', 'FY11', 'My Management Hierarchy');
        v2momIndividual.Status__c = 'Rejected';
        update v2momIndividual;
        Set<Id> v2moms = new Set<Id>();
        v2moms.add(v2momIndividual.Id);
        
        //Verify the requires reapproval method
        V2MOM_Util.set_v2mom_status_to_requires_reapproval(v2moms);
        
        //Verify setAlready executed check for locked
        V2MOM_Util.setAlready_executed_check_for_locked(true);
        V2MOM_Util.already_executed_check_for_locked=true;
        
        
        //Verify check for locked v2moms
        Map<Id, Set<Integer>> v2mom_with_changing_measures = new Map<Id, Set<Integer>>();
        list<Measure__c> old_children = new list<Measure__c>(); 
		list<Measure__c> new_children = new list<Measure__c>();
		V2MOM__c v;
		try{
			v = [select id,name,owner.id,owner.name from v2mom__c where owner.Id =: employeeStandard.Id and V2MOM_Type__c='Individual' and Effective_Date__c='FY08'];

		}catch(Exception e){
			v = GenerateEnvironmentTest3.createV2MOM(employeeStandard.Id, 'Vision', 'Individual', 'Test V2MOM Individual', 'FY08', 'My Management Hierarchy');  
		}
		
		v.Locked__c = true;
		update v;
		v2mom_with_changing_measures.put(v.Id, new Set<Integer>());
		V2MOM_Util.setAlready_executed_check_for_locked(false);       
		System.assert(!V2MOM_Util.already_executed_check_for_locked);
        V2MOM_Util.check_for_locked_v2moms(v2mom_with_changing_measures, true, false, '', old_children, new_children); 
        
    }
    
    
    public static testMethod void test_changeObstaclesAndMeasures() {
        V2MOM_Util.isTest = true;

        //Create a new V2MOM
        User employeeStandard  = [select id, username, name, Profile.Name from User where username=:GenerateEnvironmentTestUsers.ccstndmngr];
        V2MOM__c v2momIndividual = GenerateEnvironmentTest3.createV2MOM(employeeStandard.Id, 'Vision', 'Individual', 'Test V2MOM Individual', 'FY08', 'My Management Hierarchy');
        V2MOM__c v2momIndividual2 = GenerateEnvironmentTest3.createV2MOM(employeeStandard.Id, 'Vision', 'Individual', 'Test V2MOM Individual2', 'FY11', 'My Management Hierarchy');
        v2momIndividual.Status__c = 'Rejected';
        update v2momIndividual;
        Set<Id> v2moms = new Set<Id>();
        v2moms.add(v2momIndividual.Id);
        Obstacle__c ob1 = new Obstacle__c();
        Obstacle__c ob2 = new Obstacle__c();
        //Verify the requires reapproval method
        System.assert(!V2MOM_Util.obstacle_change_that_would_require_reapproval(ob1, ob2));
    
        Measure__c m1 = new Measure__c();
        Measure__c m2 = new Measure__c();
        System.assert(!V2MOM_Util.measure_change_that_would_require_reapproval(m1, m2));
    }
    
    
      public static testMethod void test_getMaxMeasurePriorityFromMethod() {
        V2MOM_Util.isTest = true;

        //Create a new V2MOM
        User employeeStandard  = [select id, username, name, Profile.Name from User where username=:GenerateEnvironmentTestUsers.ccstndmngr];
        V2MOM__c v2momIndividual = GenerateEnvironmentTest3.createV2MOM(employeeStandard.Id, 'Vision', 'Individual', 'Test V2MOM Individual', 'FY08', 'My Management Hierarchy');
        Set<Id> v2moms = new Set<Id>();
        v2moms.add(v2momIndividual.Id);
        Method__c mt1 = createMethod( v2momIndividual.Id , 2, 'method 1', 'desc method 1');
        Method__c mt2 = createMethod( v2momIndividual.Id , 1, 'method 2', 'desc method 2');
        
        Measure__c m1 = insertMeasure('measure 1', v2momIndividual.Id, mt1.Id,1);
      	Measure__c m2 = insertMeasure('measure 2', v2momIndividual.Id, null,2);
      	Measure__c m3 = insertMeasure('measure 3', v2momIndividual.Id, mt2.Id,2);
      	
      	Double d = V2MOM_Util.getMaxMeasurePriorityFromMethod(m1);
      	Double expectedMax = 3.0;
      	system.assertEquals(expectedMax, d);  
      }
      
      
       public static testMethod void test_getMinMaxMeasurePriorityInMethod() {
        V2MOM_Util.isTest = true;

        //Create a new V2MOM
        User employeeStandard  = [select id, username, name, Profile.Name from User where username=:GenerateEnvironmentTestUsers.ccstndmngr];
        V2MOM__c v2momIndividual = GenerateEnvironmentTest3.createV2MOM(employeeStandard.Id, 'Vision', 'Individual', 'Test V2MOM Individual', 'FY08', 'My Management Hierarchy');
        Set<Id> v2moms = new Set<Id>();
        v2moms.add(v2momIndividual.Id);
        Method__c mt1 = createMethod( v2momIndividual.Id , 2, 'method 1', 'desc method 1');
        Method__c mt2 = createMethod( v2momIndividual.Id , 1, 'method 2', 'desc method 2');
        
        Measure__c m1 = insertMeasure('measure 1', v2momIndividual.Id, mt1.Id,1);
      	Measure__c m2 = insertMeasure('measure 2', v2momIndividual.Id, null,2);
      	Measure__c m3 = insertMeasure('measure 3', v2momIndividual.Id, mt2.Id,2);
      	
      	Double d = V2MOM_Util.getMaxMeasurePriorityInMethod(m1);
      	Double expectedMax = 1;
      	system.assertEquals(expectedMax, d);
      	V2MOM_Util.getMaxMeasurePriorityInMethod(m2);
      	V2MOM_Util.getMinMeasurePriorityInMethod(m1);
      	V2MOM_Util.getMinMeasurePriorityInMethod(m2);
      	  
      }
      
      
       public static testMethod void test_getMaxObstaclePriorityFromMethod() {
        V2MOM_Util.isTest = true;

        //Create a new V2MOM
        User employeeStandard  = [select id, username, name, Profile.Name from User where username=:GenerateEnvironmentTestUsers.ccstndmngr];
        V2MOM__c v2momIndividual = GenerateEnvironmentTest3.createV2MOM(employeeStandard.Id, 'Vision', 'Individual', 'Test V2MOM Individual', 'FY08', 'My Management Hierarchy');
        Set<Id> v2moms = new Set<Id>();
        v2moms.add(v2momIndividual.Id);
        Method__c mt1 = createMethod( v2momIndividual.Id , 2, 'method 1', 'desc method 1');
        Method__c mt2 = createMethod( v2momIndividual.Id , 1, 'method 2', 'desc method 2');
        
        Obstacle__c m1 = insertObstacle('Obstacle 1', v2momIndividual.Id, mt1.Id,1);
      	Obstacle__c m2 = insertObstacle('Obstacle 2', v2momIndividual.Id, null,2);
      	Obstacle__c m3 = insertObstacle('Obstacle 3', v2momIndividual.Id, mt2.Id,2);
      	
      	Double d = V2MOM_Util.getMaxObstaclePriorityFromMethod(m1);
      	Double expectedMax = 3;
      	system.assertEquals(expectedMax, d);
        
      }
      
      
       public static testMethod void test_check_for_locked_v2moms2() {
        V2MOM_Util.isTest = true;

        //Create a new V2MOM
        User employeeStandard  = [select id, username, name, Profile.Name from User where username=:GenerateEnvironmentTestUsers.ccstndmngr];
        V2MOM__c v2momIndividual = GenerateEnvironmentTest3.createV2MOM(employeeStandard.Id, 'Vision', 'Individual', 'Test V2MOM Individual', 'FY08', 'My Management Hierarchy');
        Set<Id> v2moms = new Set<Id>();
        v2moms.add(v2momIndividual.Id);
        v2momIndividual.Locked__c = true;
        update v2momIndividual;
       
        Method__c m1 = createMethod( v2momIndividual.Id , 1, 'method1','desc 1');
        SObject[] old_children = new Method__c[1];
        old_children[0] = m1;
       
        Method__c m2 = createMethod( v2momIndividual.Id , 2, 'method2','desc 2');
        SObject[] new_children = new Method__c[1];
        new_children[0] = m2;
       
        Map<Id, Set<Integer>> v2momMap = new Map<Id, Set<Integer>>();
        v2momMap.put( v2momIndividual.Id , new Set<Integer>());
       
        V2MOM_Util.check_for_locked_v2moms(v2momMap, true, false, '', old_children, new_children); 
        System.assert( V2MOM_Util.already_executed_check_for_locked ); 
      	  
      }
      
    
      public static testMethod void test_getMinMaxMethodPriorityPreviousValue() {
        V2MOM_Util.isTest = true;

        //Create a new V2MOM
        User employeeStandard  = [select id, username, name, Profile.Name from User where username=:GenerateEnvironmentTestUsers.ccstndmngr];
        V2MOM__c v2momIndividual = GenerateEnvironmentTest3.createV2MOM(employeeStandard.Id, 'Vision', 'Individual', 'Test V2MOM Individual', 'FY08', 'My Management Hierarchy');
        Set<Id> v2moms = new Set<Id>();
        v2moms.add(v2momIndividual.Id);
        Value__c v1 = createValue( v2momIndividual.Id , 2, 'value 1', 'tag value 1');
        Value__c v2 = createValue( v2momIndividual.Id , 1, 'value 2', 'tag value 2');
        Method__c mt1 = createMethod( v2momIndividual.Id , 3, 'method 1', 'desc method 1',v1.Id);
        Method__c mt2 = createMethod( v2momIndividual.Id , 2, 'method 2', 'desc method 2');
      	Method__c mt3 = createMethod( v2momIndividual.Id , 1, 'method 3', 'desc method 3',v2.Id);
      	
      	V2MOM_Util.getMaxMethodPriorityPreviousValue(mt1);
      	V2MOM_Util.getMinMethodPriorityFromValue(mt1); 
      	
      
      	Double d = V2MOM_Util.getMinMethodPriorityFromValue(mt2);
      	Double expectedMin = 1;
      	system.assertEquals(expectedMin,d); 
      }
      
      public static testMethod void test_getMaxMethodPriorityFromValue() {
        V2MOM_Util.isTest = true;

        //Create a new V2MOM
        User employeeStandard  = [select id, username, name, Profile.Name from User where username=:GenerateEnvironmentTestUsers.ccstndmngr];
        V2MOM__c v2momIndividual = GenerateEnvironmentTest3.createV2MOM(employeeStandard.Id, 'Vision', 'Individual', 'Test V2MOM Individual', 'FY08', 'My Management Hierarchy');
        Set<Id> v2moms = new Set<Id>();
        v2moms.add(v2momIndividual.Id);
        Value__c v1 = createValue( v2momIndividual.Id , 2, 'value 1', 'tag value 1');
        Value__c v2 = createValue( v2momIndividual.Id , 1, 'value 2', 'tag value 2');
        Method__c mt1 = createMethod( v2momIndividual.Id , 3, 'method 1', 'desc method 1',v1.Id);
        Method__c mt2 = createMethod( v2momIndividual.Id , 2, 'method 2', 'desc method 2');
      	Method__c mt3 = createMethod( v2momIndividual.Id , 1, 'method 3', 'desc method 3',v1.Id);
      	
      	Double d = V2MOM_Util.getMaxMethodPriorityFromValue(mt1);
        Double expectedMin = 2.0;
        system.assertEquals(expectedMin, d);
      }
      
      public static testMethod void test_getRatingDescription() {

 		String s0 = '-';
 		String s1 = '1';
 		String s2 = '2';
 		String s3 = '3';
 		String s4 = '4';
 		String s5 = '5';
 		String s_1 = 'N/A';
 		
      	String r0 = V2MOM_Util.getRatingDescription(0);
      	String r1 = V2MOM_Util.getRatingDescription(1);
      	String r2 = V2MOM_Util.getRatingDescription(2);
      	String r3 = V2MOM_Util.getRatingDescription(3);
      	String r4 = V2MOM_Util.getRatingDescription(4);
      	String r5 = V2MOM_Util.getRatingDescription(5);
      	String r_1 = V2MOM_Util.getRatingDescription(-1);
      	String r_2 = V2MOM_Util.getRatingDescription(-2);
      	
      	system.assertEquals(s0, r0);
      	system.assertEquals(s1, r1);
      	system.assertEquals(s2, r2);
      	system.assertEquals(s3, r3);
      	system.assertEquals(s4, r4);
      	system.assertEquals(s5, r5);
      	system.assertEquals(s_1, r_1);
      	system.assertEquals(s0, r_2);  
      }
      
      
 	 public static testMethod void test_getSalesImpact() {
        V2MOM_Util.getSalesImpactRating(null, null, null, null);

       //create scorecard support reviews
       ScorecardSupportReview__c Q1 = new ScorecardSupportReview__c (name = 'Q1SSR', FiscalQuarter__c = 'Q1', SalesImpactRating__c = 1, SalesImpactWeight__c = 1); 
       ScorecardSupportReview__c Q2 = new ScorecardSupportReview__c (name = 'Q2SSR', FiscalQuarter__c = 'Q2', SalesImpactRating__c = 1, SalesImpactWeight__c = 1);
       ScorecardSupportReview__c Q3 = new ScorecardSupportReview__c (name = 'Q3SSR', FiscalQuarter__c = 'Q3', SalesImpactRating__c = 1, SalesImpactWeight__c = 1);
       ScorecardSupportReview__c Q4 = new ScorecardSupportReview__c (name = 'Q4SSR', FiscalQuarter__c = 'Q4', SalesImpactRating__c = 1, SalesImpactWeight__c = 1);	  

       V2MOM_Util.getSalesImpactRating(null, null, null, null);
       V2MOM_Util.getSalesImpactRating(null, null, null, Q4);
 	   V2MOM_Util.getSalesImpactRating(null, null, Q3, null);
 	   V2MOM_Util.getSalesImpactRating(null, Q2, null, null);
 	   V2MOM_Util.getSalesImpactRating(Q1, null, null, null);

       V2MOM_Util.getSalesImpactWeight(null, null, null, null);
       V2MOM_Util.getSalesImpactWeight(null, null, null, Q4);
 	   V2MOM_Util.getSalesImpactWeight(null, null, Q3, null);
 	   V2MOM_Util.getSalesImpactWeight(null, Q2, null, null);
 	   String result = V2MOM_Util.getSalesImpactWeight(Q1, null, null, null);
       String expectedValue = '1.0';
       System.assertEquals(expectedValue, result);
     }
       
     public static testMethod void test_getTimeOnPlatform() {
        V2MOM_Util.getSalesImpactRating(null, null, null, null);

       //create scorecard support reviews
       ScorecardSupportReview__c Q1 = new ScorecardSupportReview__c (name = 'Q1SSR', FiscalQuarter__c = 'Q1', TimeOnPlatformRating__c = 1, TimeOnPlatformWeight__c = 1); 
       ScorecardSupportReview__c Q2 = new ScorecardSupportReview__c (name = 'Q2SSR', FiscalQuarter__c = 'Q2', TimeOnPlatformRating__c = 1, TimeOnPlatformWeight__c = 1);
       ScorecardSupportReview__c Q3 = new ScorecardSupportReview__c (name = 'Q3SSR', FiscalQuarter__c = 'Q3', TimeOnPlatformRating__c = 1, TimeOnPlatformWeight__c = 1);
       ScorecardSupportReview__c Q4 = new ScorecardSupportReview__c (name = 'Q4SSR', FiscalQuarter__c = 'Q4', TimeOnPlatformRating__c = 1, TimeOnPlatformWeight__c = 1);	  

       V2MOM_Util.getTimeOnPlatformRating(null, null, null, null);
       V2MOM_Util.getTimeOnPlatformRating(null, null, null, Q4);
 	   V2MOM_Util.getTimeOnPlatformRating(null, null, Q3, null);
 	   V2MOM_Util.getTimeOnPlatformRating(null, Q2, null, null);
 	   V2MOM_Util.getTimeOnPlatformRating(Q1, null, null, null);

       V2MOM_Util.getTimeOnPlatformWeight(null, null, null, null);
       V2MOM_Util.getTimeOnPlatformWeight(null, null, null, Q4);
 	   V2MOM_Util.getTimeOnPlatformWeight(null, null, Q3, null);
 	   V2MOM_Util.getTimeOnPlatformWeight(null, Q2, null, null);
 	   V2MOM_Util.getTimeOnPlatformWeight(Q1, null, null, null);
     }  
       
        
     public static testMethod void test_getForecastAccuracy() {
        V2MOM_Util.getSalesImpactRating(null, null, null, null);

       //create scorecard support reviews
       ScorecardSupportReview__c Q1 = new ScorecardSupportReview__c (name = 'Q1SSR', FiscalQuarter__c = 'Q1', ForecastAccuracyRating__c = 1, ForecastAccuracyWeight__c = 1); 
       ScorecardSupportReview__c Q2 = new ScorecardSupportReview__c (name = 'Q2SSR', FiscalQuarter__c = 'Q2', ForecastAccuracyRating__c = 1, ForecastAccuracyWeight__c = 1);
       ScorecardSupportReview__c Q3 = new ScorecardSupportReview__c (name = 'Q3SSR', FiscalQuarter__c = 'Q3', ForecastAccuracyRating__c = 1, ForecastAccuracyWeight__c = 1);
       ScorecardSupportReview__c Q4 = new ScorecardSupportReview__c (name = 'Q4SSR', FiscalQuarter__c = 'Q4', ForecastAccuracyRating__c = 1, ForecastAccuracyWeight__c = 1);	  

       V2MOM_Util.getForecastAccuracyRating(null, null, null, null);
       V2MOM_Util.getForecastAccuracyRating(null, null, null, Q4);
 	   V2MOM_Util.getForecastAccuracyRating(null, null, Q3, null);
 	   V2MOM_Util.getForecastAccuracyRating(null, Q2, null, null);
 	   V2MOM_Util.getForecastAccuracyRating(Q1, null, null, null);
 	   
 	   
       V2MOM_Util.getForecastAccuracyWeight(null, null, null, null);
       V2MOM_Util.getForecastAccuracyWeight(null, null, null, Q4);
 	   V2MOM_Util.getForecastAccuracyWeight(null, null, Q3, null);
 	   V2MOM_Util.getForecastAccuracyWeight(null, Q2, null, null);
 	   V2MOM_Util.getForecastAccuracyWeight(Q1, null, null, null);
 	   
     }    
       
 public static testMethod void test_getRenewalExcellence() {
        V2MOM_Util.getSalesImpactRating(null, null, null, null);

       //create scorecard support reviews
       ScorecardSupportReview__c Q1 = new ScorecardSupportReview__c (name = 'Q1SSR', FiscalQuarter__c = 'Q1', RenewalExcellenceRating__c = 1, RenewalExcellenceWeight__c = 1); 
       ScorecardSupportReview__c Q2 = new ScorecardSupportReview__c (name = 'Q2SSR', FiscalQuarter__c = 'Q2', RenewalExcellenceRating__c = 1, RenewalExcellenceWeight__c = 1);
       ScorecardSupportReview__c Q3 = new ScorecardSupportReview__c (name = 'Q3SSR', FiscalQuarter__c = 'Q3', RenewalExcellenceRating__c = 1, RenewalExcellenceWeight__c = 1);
       ScorecardSupportReview__c Q4 = new ScorecardSupportReview__c (name = 'Q4SSR', FiscalQuarter__c = 'Q4', RenewalExcellenceRating__c = 1, RenewalExcellenceWeight__c = 1);	  

       V2MOM_Util.getRenewalExcellenceRating(null, null, null, null);
       V2MOM_Util.getRenewalExcellenceRating(null, null, null, Q4);
 	   V2MOM_Util.getRenewalExcellenceRating(null, null, Q3, null);
 	   V2MOM_Util.getRenewalExcellenceRating(null, Q2, null, null);
 	   V2MOM_Util.getRenewalExcellenceRating(Q1, null, null, null);
 	   
 	   
       V2MOM_Util.getRenewalExcellenceWeight(null, null, null, null);
       V2MOM_Util.getRenewalExcellenceWeight(null, null, null, Q4);
 	   V2MOM_Util.getRenewalExcellenceWeight(null, null, Q3, null);
 	   V2MOM_Util.getRenewalExcellenceWeight(null, Q2, null, null);
 	   V2MOM_Util.getRenewalExcellenceWeight(Q1, null, null, null);
 	   
     }     
   
   public static testMethod void test_getOperationalExcellence() {
        V2MOM_Util.getSalesImpactRating(null, null, null, null);

       //create scorecard support reviews
       ScorecardSupportReview__c Q1 = new ScorecardSupportReview__c (name = 'Q1SSR', FiscalQuarter__c = 'Q1', OperationalExcellenceRating__c = 1, OperationalExcellenceWeight__c = 1); 
       ScorecardSupportReview__c Q2 = new ScorecardSupportReview__c (name = 'Q2SSR', FiscalQuarter__c = 'Q2', OperationalExcellenceRating__c = 1, OperationalExcellenceWeight__c = 1);
       ScorecardSupportReview__c Q3 = new ScorecardSupportReview__c (name = 'Q3SSR', FiscalQuarter__c = 'Q3', OperationalExcellenceRating__c = 1, OperationalExcellenceWeight__c = 1);
       ScorecardSupportReview__c Q4 = new ScorecardSupportReview__c (name = 'Q4SSR', FiscalQuarter__c = 'Q4', OperationalExcellenceRating__c = 1, OperationalExcellenceWeight__c = 1);	  

       V2MOM_Util.getOperationalExcellenceRating(null, null, null, null);
       V2MOM_Util.getOperationalExcellenceRating(null, null, null, Q4);
 	   V2MOM_Util.getOperationalExcellenceRating(null, null, Q3, null);
 	   V2MOM_Util.getOperationalExcellenceRating(null, Q2, null, null);
 	   V2MOM_Util.getOperationalExcellenceRating(Q1, null, null, null);
 	   
 	   
       V2MOM_Util.getOperationalExcellenceWeight(null, null, null, null);
       V2MOM_Util.getOperationalExcellenceWeight(null, null, null, Q4);
 	   V2MOM_Util.getOperationalExcellenceWeight(null, null, Q3, null);
 	   V2MOM_Util.getOperationalExcellenceWeight(null, Q2, null, null);
 	   V2MOM_Util.getOperationalExcellenceWeight(Q1, null, null, null);
 	   
     }     
      
	 public static testMethod void test_getStrategicInitiatives() {
        V2MOM_Util.getSalesImpactRating(null, null, null, null);

       //create scorecard support reviews
       ScorecardSupportReview__c Q1 = new ScorecardSupportReview__c (name = 'Q1SSR', FiscalQuarter__c = 'Q1', StrategicInitiativesRating__c = 1, StrategicInitiativesWeight__c = 1); 
       ScorecardSupportReview__c Q2 = new ScorecardSupportReview__c (name = 'Q2SSR', FiscalQuarter__c = 'Q2', StrategicInitiativesRating__c = 1, StrategicInitiativesWeight__c = 1);
       ScorecardSupportReview__c Q3 = new ScorecardSupportReview__c (name = 'Q3SSR', FiscalQuarter__c = 'Q3', StrategicInitiativesRating__c = 1, StrategicInitiativesWeight__c = 1);
       ScorecardSupportReview__c Q4 = new ScorecardSupportReview__c (name = 'Q4SSR', FiscalQuarter__c = 'Q4', StrategicInitiativesRating__c = 1, StrategicInitiativesWeight__c = 1);	  

       V2MOM_Util.getStrategicInitiativesRating(null, null, null, null);
       V2MOM_Util.getStrategicInitiativesRating(null, null, null, Q4);
 	   V2MOM_Util.getStrategicInitiativesRating(null, null, Q3, null);
 	   V2MOM_Util.getStrategicInitiativesRating(null, Q2, null, null);
 	   V2MOM_Util.getStrategicInitiativesRating(Q1, null, null, null);
 	   
 	   
       V2MOM_Util.getStrategicInitiativesWeight(null, null, null, null);
       V2MOM_Util.getStrategicInitiativesWeight(null, null, null, Q4);
 	   V2MOM_Util.getStrategicInitiativesWeight(null, null, Q3, null);
 	   V2MOM_Util.getStrategicInitiativesWeight(null, Q2, null, null);
 	   V2MOM_Util.getStrategicInitiativesWeight(Q1, null, null, null);
 	   
     }     
      
      public static testMethod void test_getCSMSalesImpact() {
        V2MOM_Util.getSalesImpactRating(null, null, null, null);

       //create scorecard support reviews
       ScorecardSupportReview__c Q1 = new ScorecardSupportReview__c (name = 'Q1SSR', FiscalQuarter__c = 'Q1', CSMSalesImpactRating__c = 1, CSMSalesImpactWeight__c = 1); 
       ScorecardSupportReview__c Q2 = new ScorecardSupportReview__c (name = 'Q2SSR', FiscalQuarter__c = 'Q2', CSMSalesImpactRating__c = 1, CSMSalesImpactWeight__c = 1);
       ScorecardSupportReview__c Q3 = new ScorecardSupportReview__c (name = 'Q3SSR', FiscalQuarter__c = 'Q3', CSMSalesImpactRating__c = 1, CSMSalesImpactWeight__c = 1);
       ScorecardSupportReview__c Q4 = new ScorecardSupportReview__c (name = 'Q4SSR', FiscalQuarter__c = 'Q4', CSMSalesImpactRating__c = 1, CSMSalesImpactWeight__c = 1);	  

       V2MOM_Util.getCSMSalesImpactRating(null, null, null, null);
       V2MOM_Util.getCSMSalesImpactRating(null, null, null, Q4);
 	   V2MOM_Util.getCSMSalesImpactRating(null, null, Q3, null);
 	   V2MOM_Util.getCSMSalesImpactRating(null, Q2, null, null);
 	   V2MOM_Util.getCSMSalesImpactRating(Q1, null, null, null);
 	   
 	   
       V2MOM_Util.getCSMSalesImpactWeight(null, null, null, null);
       V2MOM_Util.getCSMSalesImpactWeight(null, null, null, Q4);
 	   V2MOM_Util.getCSMSalesImpactWeight(null, null, Q3, null);
 	   V2MOM_Util.getCSMSalesImpactWeight(null, Q2, null, null);
 	   V2MOM_Util.getCSMSalesImpactWeight(Q1, null, null, null);
 	   
     }     
       
      public static testMethod void test_getCustomerSatisfaction() {
        V2MOM_Util.getSalesImpactRating(null, null, null, null);

       //create scorecard support reviews
       ScorecardSupportReview__c Q1 = new ScorecardSupportReview__c (name = 'Q1SSR', FiscalQuarter__c = 'Q1', RatingCustomerSatisfaction__c = 1, WeightCustomerSatisfaction__c = 1); 
       ScorecardSupportReview__c Q2 = new ScorecardSupportReview__c (name = 'Q2SSR', FiscalQuarter__c = 'Q2', RatingCustomerSatisfaction__c = 1, WeightCustomerSatisfaction__c = 1);
       ScorecardSupportReview__c Q3 = new ScorecardSupportReview__c (name = 'Q3SSR', FiscalQuarter__c = 'Q3', RatingCustomerSatisfaction__c = 1, WeightCustomerSatisfaction__c = 1);
       ScorecardSupportReview__c Q4 = new ScorecardSupportReview__c (name = 'Q4SSR', FiscalQuarter__c = 'Q4', RatingCustomerSatisfaction__c = 1, WeightCustomerSatisfaction__c = 1);	  

       V2MOM_Util.getCustomerSatisfactionRating(null, null, null, null);
       V2MOM_Util.getCustomerSatisfactionRating(null, null, null, Q4);
 	   V2MOM_Util.getCustomerSatisfactionRating(null, null, Q3, null);
 	   V2MOM_Util.getCustomerSatisfactionRating(null, Q2, null, null);
 	   V2MOM_Util.getCustomerSatisfactionRating(Q1, null, null, null);
 	   
 	   
       V2MOM_Util.getCustomerSatisfactionWeight(null, null, null, null);
       V2MOM_Util.getCustomerSatisfactionWeight(null, null, null, Q4);
 	   V2MOM_Util.getCustomerSatisfactionWeight(null, null, Q3, null);
 	   V2MOM_Util.getCustomerSatisfactionWeight(null, Q2, null, null);
 	   V2MOM_Util.getCustomerSatisfactionWeight(Q1, null, null, null);
 	   
     }     
       
   public static testMethod void test_getWMCCP() {
        V2MOM_Util.getSalesImpactRating(null, null, null, null);

       //create scorecard support reviews
       ScorecardSupportReview__c Q1 = new ScorecardSupportReview__c (name = 'Q1SSR', FiscalQuarter__c = 'Q1', WMCCPRating__c = 1, WMCCPWeight__c = 1); 
       ScorecardSupportReview__c Q2 = new ScorecardSupportReview__c (name = 'Q2SSR', FiscalQuarter__c = 'Q2', WMCCPRating__c = 1, WMCCPWeight__c = 1);
       ScorecardSupportReview__c Q3 = new ScorecardSupportReview__c (name = 'Q3SSR', FiscalQuarter__c = 'Q3', WMCCPRating__c = 1, WMCCPWeight__c = 1);
       ScorecardSupportReview__c Q4 = new ScorecardSupportReview__c (name = 'Q4SSR', FiscalQuarter__c = 'Q4', WMCCPRating__c = 1, WMCCPWeight__c = 1);	  

       V2MOM_Util.getWMCCPRating(null, null, null, null);
       V2MOM_Util.getWMCCPRating(null, null, null, Q4);
 	   V2MOM_Util.getWMCCPRating(null, null, Q3, null);
 	   V2MOM_Util.getWMCCPRating(null, Q2, null, null);
 	   V2MOM_Util.getWMCCPRating(Q1, null, null, null);
 	   
 	   
       V2MOM_Util.getWMCCPWeight(null, null, null, null);
       V2MOM_Util.getWMCCPWeight(null, null, null, Q4);
 	   V2MOM_Util.getWMCCPWeight(null, null, Q3, null);
 	   V2MOM_Util.getWMCCPWeight(null, Q2, null, null);
 	   V2MOM_Util.getWMCCPWeight(Q1, null, null, null);
 	   
     }     
      public static testMethod void test_getWMCAA() {
        V2MOM_Util.getSalesImpactRating(null, null, null, null);

       //create scorecard support reviews
       ScorecardSupportReview__c Q1 = new ScorecardSupportReview__c (name = 'Q1SSR', FiscalQuarter__c = 'Q1', WMCAARating__c = 1, WMCAAWeight__c = 1); 
       ScorecardSupportReview__c Q2 = new ScorecardSupportReview__c (name = 'Q2SSR', FiscalQuarter__c = 'Q2', WMCAARating__c = 1, WMCAAWeight__c = 1);
       ScorecardSupportReview__c Q3 = new ScorecardSupportReview__c (name = 'Q3SSR', FiscalQuarter__c = 'Q3', WMCAARating__c = 1, WMCAAWeight__c = 1);
       ScorecardSupportReview__c Q4 = new ScorecardSupportReview__c (name = 'Q4SSR', FiscalQuarter__c = 'Q4', WMCAARating__c = 1, WMCAAWeight__c = 1);	  

       V2MOM_Util.getWMCAARating(null, null, null, null);
       V2MOM_Util.getWMCAARating(null, null, null, Q4);
 	   V2MOM_Util.getWMCAARating(null, null, Q3, null);
 	   V2MOM_Util.getWMCAARating(null, Q2, null, null);
 	   V2MOM_Util.getWMCAARating(Q1, null, null, null);
 	   
 	   
       V2MOM_Util.getWMCAAWeight(null, null, null, null);
       V2MOM_Util.getWMCAAWeight(null, null, null, Q4);
 	   V2MOM_Util.getWMCAAWeight(null, null, Q3, null);
 	   V2MOM_Util.getWMCAAWeight(null, Q2, null, null);
 	   V2MOM_Util.getWMCAAWeight(Q1, null, null, null);
 	   
     }     
     
      public static Measure__c insertMeasure(String description, Id v2momId, Id methodId, Integer priority){
      	Measure__c m1 = new Measure__c( description__c = description, V2MOM__c = v2momId, Method__c = methodId, priority__c = priority);
      	insert m1;
      	return m1;
      	
      }
      
      public static Obstacle__c insertObstacle(String description, Id v2momId, Id methodId, Integer priority){
      	Obstacle__c m1 = new Obstacle__c( description__c = description, V2MOM__c = v2momId, Method__c = methodId, priority__c = priority);
      	
      	insert m1;
      	return m1;
      	
      }
      
      public static Method__c createMethod(Id v2mom,  Integer priority, String name, String d){
		Method__c method = new Method__c(V2MOM__c = v2mom, 
										
										Priority__c = priority, 
										Name = name,
										Description__c = d);
		
		insert method;
		
		return method;
	}
	
	      public static Method__c createMethod(Id v2mom,  Integer priority, String name, String d,Id idValue){
		Method__c method = new Method__c(V2MOM__c = v2mom, 
										
										Priority__c = priority, 
										Name = name,
										Description__c = d,
										Value__c = idValue);
		
		insert method;
		
		return method;
	}
	
	 public static Value__c createValue(Id v2mom,  Integer priority, String name, String tagLine){
		Value__c v = new Value__c (V2MOM__c = v2mom,										
										Priority__c = priority, 
										Name = name,
										Tag_Line__c = tagLine);
		
		insert v;
		
		return v;
	}
	
	
	
}