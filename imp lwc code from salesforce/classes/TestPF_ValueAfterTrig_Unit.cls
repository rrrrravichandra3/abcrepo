@isTest
private class TestPF_ValueAfterTrig_Unit {

	public static testMethod void execute_ValueAfterTrigOne() {  
		 
		GenerateEnvironmentTest.genAfterTrig(); 
		   
		//delete GenerateEnvironmentTest.v2momIndividual;
		
		User user = GenerateEnvironmentTest.managerSupport;
		 
    	System.runAs(user){
			Test.startTest();   
			try {
	        	V2MOM__c v2mom2 = new V2MOM__c (Vision__c = 'This Vision', 
												V2MOM_Type__c = 'Individual Q3/Q4',
												Name = 'V2MOM', 
												Effective_Date__c = 'FY07',
												Share_With__c = 'My Manager');
				insert v2mom2;
			} catch (Exception e) {
	            System.debug(' ****************** execute_ValueAfterTrigOne * ');
	            System.debug(e.getMessage());
			}
			
	        Test.stopTest();
    	}
        
	}

	public static testMethod void execute_ValueAfterTrigTwo() {  
		
		GenerateEnvironmentTest.genAfterTrig(); 
		
		Test.startTest();   
	
		try {
			V2MOM__c v2mom = GenerateEnvironmentTest.v2momIndividual;
			
			Value__c value = new Value__c (	V2MOM__c = v2mom.Id, 
											Priority__c = 1, 
											Name = 'Value');
			insert value;
			
			Value__c value2 = new Value__c (V2MOM__c = v2mom.Id, 
											Priority__c = 2, 
											Name = 'Value 2');
			insert value2;
			
			Value__c value3 = new Value__c (V2MOM__c = v2mom.Id, 
											Priority__c = 2, 
											Name = 'Value 3');
			insert value3;
			
			Method__c method = new Method__c(V2MOM__c = v2mom.Id, 
											Value__c = value.Id,
											Priority__c = 1, 
											Name = 'Method',
											Description__c = 'Description');
			insert method;
			
			
			value.Priority__c = 1;
			update value;
			
			Obstacle__c obstacle = new Obstacle__c(	Value__c = value.Id, 
													V2MOM__c = v2mom.Id, 
													Method__c = method.Id, 
													Priority__c = 1, 
													Description__c = 'Description');											
			insert obstacle;
			
			Obstacle__c obstacle1 = new Obstacle__c(Value__c = value.Id, 
													V2MOM__c = v2mom.Id, 
													Method__c = method.Id, 
													Priority__c = 2, 
													Description__c = 'Description');											
			insert obstacle1;
		} catch (Exception e) {
            System.debug(' ****************** execute_ValueAfterTrigTwo * ');
            System.debug(e.getMessage());
		}
					        
        Test.stopTest();
        
	}


	public static testMethod void execute_ValueAfterTrigTwo2() {  
		
		GenerateEnvironmentTest.genAfterTrig(); 
		
		Test.startTest();   
	
		try {
			
			V2MOM__c v2mom = GenerateEnvironmentTest.v2momIndividual;
			
			Value__c value = new Value__c (	V2MOM__c = v2mom.Id, 
											Priority__c = 1, 
											Name = 'Value');
			insert value;
			
			Value__c value2 = new Value__c (V2MOM__c = v2mom.Id, 
											Priority__c = 2, 
											Name = 'Value 2');
			insert value2;
			
			Value__c value3 = new Value__c (V2MOM__c = v2mom.Id, 
											Priority__c = 2, 
											Name = 'Value 3');
			insert value3;
			
			Method__c method = new Method__c(V2MOM__c = v2mom.Id, 
											Value__c = value.Id,
											Priority__c = 1, 
											Name = 'Method',
											Description__c = 'Description');
			insert method;
			
			
			value.Priority__c = 1;
			update value;
					
			Measure__c measure1 = new Measure__c(Value__c = value.Id, 
												V2MOM__c = v2mom.Id, 
												Method__c = method.Id, 
												Start_Date__c = Date.today(), 
												End_Date__c = Date.today().addYears(1), 
												Priority__c = 2, 
												Description__c = 'Description');											
			insert measure1;
			
			Measure__c measure2 = new Measure__c(Value__c = value.Id, 
												V2MOM__c = v2mom.Id, 
												Method__c = method.Id, 
												Start_Date__c = Date.today(), 
												End_Date__c = Date.today().addYears(1), 
												Priority__c = 2, 
												Description__c = 'Description');											
			insert measure2;
		} catch (Exception e) {
            System.debug(' ****************** execute_ValueAfterTrigTwo2 * ');
            System.debug(e.getMessage());
		}
			        
        Test.stopTest();
        
	}
	
	
	public static testMethod void execute_ValueAfterTrigThree() {  
		
		GenerateEnvironmentTest.genAfterTrig(); 
		
		Test.startTest();   
		try {
			delete GenerateEnvironmentTest.measure1;
			delete GenerateEnvironmentTest.obstacle1;
			delete GenerateEnvironmentTest.method1;
			delete GenerateEnvironmentTest.value1;
		} catch (Exception e) {
            System.debug(' ****************** execute_ValueAfterTrigThree * ');
            System.debug(e.getMessage());
		}
		        
        Test.stopTest();
        
	}
	
	
	public static testMethod void execute_ValueAfterTrigFour() {  
		
		GenerateEnvironmentTest.genV2MOMLocked(); 
		
		Test.startTest();   
	
		V2MOM__c v2mom = GenerateEnvironmentTest.v2momIndividual;

		try{		
			Value__c value = new Value__c (	V2MOM__c = v2mom.Id, 
											Priority__c = 1, 
											Name = 'Value');
			insert value;
				
		}catch (Exception e){
			System.debug(' Error the v2mom is locked');
		}		       
		 
        Test.stopTest();
        
	}

	
	public static testMethod void execute_ValueAfterTrigFive() {  
		
		GenerateEnvironmentTest.genV2MOMLocked(); 
		
		Test.startTest();   
	
		V2MOM__c v2mom = GenerateEnvironmentTest.v2momIndividual;
		Value__c value = GenerateEnvironmentTest.value1;

		try{
			Method__c method = new Method__c(V2MOM__c = v2mom.Id, 
											Value__c = value.Id,
											Priority__c = 1, 
											Name = 'Method',
											Description__c = 'Description');
			insert method;			
		}catch (Exception e){
			System.debug(' Error the v2mom is locked');
		}		        
		
        Test.stopTest();
        
	}

	
	public static testMethod void execute_ValueAfterTrigSix() {  
		
		GenerateEnvironmentTest.genV2MOMLocked(); 
		
		Test.startTest();   
	
		V2MOM__c v2mom = GenerateEnvironmentTest.v2momIndividual;
		Value__c value = GenerateEnvironmentTest.value1;
		Method__c method = GenerateEnvironmentTest.method1;

		try{
			Obstacle__c obstacle = new Obstacle__c(	Value__c = value.Id, 
													V2MOM__c = v2mom.Id, 
													Method__c = method.Id, 
													Priority__c = 1, 
													Description__c = 'Description');											
			insert obstacle;
		}catch (Exception e){
			System.debug(' Error the v2mom is locked');
		}		        
		
        Test.stopTest();
        
	}

	
	public static testMethod void execute_ValueAfterTrigSix2() {  
		
		GenerateEnvironmentTest.genV2MOMLocked(); 
		
		Test.startTest();   
	
		V2MOM__c v2mom = GenerateEnvironmentTest.v2momIndividual;
		Value__c value = GenerateEnvironmentTest.value1;
		Method__c method = GenerateEnvironmentTest.method1;

		try{
			Measure__c measure1 = new Measure__c(Value__c = value.Id, 
												V2MOM__c = v2mom.Id, 
												Method__c = method.Id, 
												Start_Date__c = Date.today(), 
												End_Date__c = Date.today().addYears(1), 
												Priority__c = 2, 
												Description__c = 'Description');											
			insert measure1;
		}catch (Exception e){
			System.debug(' Error the v2mom is locked');
		}		        
		
        Test.stopTest();
        
	}

	
	public static testMethod void execute_ValueAfterTrigSeven() {  
		
		GenerateEnvironmentTest.genV2MOMLocked(); 
		
		Test.startTest();   
	
		V2MOM__c v2mom = GenerateEnvironmentTest.v2momIndividual;

		try{		
			delete GenerateEnvironmentTest.value1;
		}catch (Exception e){
			System.debug(' Error the v2mom is locked');
		}		       
		 
        Test.stopTest();
        
	}

	
	public static testMethod void execute_ValueAfterTrigEight() {  
		
		GenerateEnvironmentTest.genV2MOMLocked(); 
		
		Test.startTest();   
	
		V2MOM__c v2mom = GenerateEnvironmentTest.v2momIndividual;

		try{
			delete GenerateEnvironmentTest.method1;
		}catch (Exception e){
			System.debug(' Error the v2mom is locked');
		}		        
		
        Test.stopTest();
        
	}

	
	public static testMethod void execute_ValueAfterTrigNine() {  
		
		GenerateEnvironmentTest.genV2MOMLocked(); 
		
		Test.startTest();   
	
		V2MOM__c v2mom = GenerateEnvironmentTest.v2momIndividual;

		try{
			delete GenerateEnvironmentTest.obstacle1;
		}catch (Exception e){
			System.debug(' Error the v2mom is locked');
		}		        
		
        Test.stopTest();
        
	}

	
	public static testMethod void execute_ValueAfterTrigTen() {  
		
		GenerateEnvironmentTest.genV2MOMLocked(); 
		
		Test.startTest();   
	
		V2MOM__c v2mom = GenerateEnvironmentTest.v2momIndividual;

		try{
			delete GenerateEnvironmentTest.measure1;
		}catch (Exception e){
			System.debug(' Error the v2mom is locked');
		}		        
		
        Test.stopTest();
        
	}
	
	
	public static testMethod void execute_ValueAfterTrigEleven() {  
		
		GenerateEnvironmentTest.genAfterTrig(); 
		
		Test.startTest();   
	
		try {
			V2MOM__c v2mom = GenerateEnvironmentTest.v2momIndividual;
		
			v2mom.Status__c = 'Pending Approval';
			update v2mom;
			
			v2mom.Status__c = 'Approved';
			update v2mom;
			
			v2mom.Status__c = 'Rejected';
			update v2mom;
		} catch (Exception e) {
            System.debug(' ****************** execute_ValueAfterTrigEleven * ');
            System.debug(e.getMessage());
		}
			        
        Test.stopTest();
        
	}

	public static testMethod void execute_ValueAfterTrigTwelve() {  
		
		GenerateEnvironmentTest.genAfterTrig(); 
		
		Test.startTest();   
		try {
			GenerateEnvironmentTest.value1.Priority__c = 2;
			update GenerateEnvironmentTest.value1;
				
			GenerateEnvironmentTest.value1.Priority__c = -2;
			update GenerateEnvironmentTest.value1;
		} catch (Exception e) {
            System.debug(' ****************** execute_ValueAfterTrigTwelve * ');
            System.debug(e.getMessage());
		}
			        
        Test.stopTest();
        
	}
	
	public static testMethod void execute_ValueAfterTrigThirteen() {  
		
		GenerateEnvironmentTest.genAfterTrig(); 
		
		Test.startTest();   
		try {
			GenerateEnvironmentTest.method1.Priority__c = 1;
			update GenerateEnvironmentTest.method1;
				
			GenerateEnvironmentTest.method1.Priority__c = -2;
			update GenerateEnvironmentTest.method1;
		} catch (Exception e) {
            System.debug(' ****************** execute_ValueAfterTrigThirteen * ');
            System.debug(e.getMessage());
		}
			        
        Test.stopTest();
        
	}

	
	public static testMethod void execute_ValueAfterTrigFourteen() {  
		
		GenerateEnvironmentTest.genAfterTrig(); 
		
		Test.startTest();  
		 
		try {
			
			GenerateEnvironmentTest.measure1.Priority__c = 2;
			GenerateEnvironmentTest.measure1.Method__c = GenerateEnvironmentTest.method2.Id;
			update GenerateEnvironmentTest.measure1;
	
			GenerateEnvironmentTest.measure1.Value__c = GenerateEnvironmentTest.value2.Id;
			update GenerateEnvironmentTest.measure1;
				
			GenerateEnvironmentTest.measure1.Priority__c = -2;
			update GenerateEnvironmentTest.measure1;
		} catch (Exception e) {
            System.debug(' ****************** execute_ValueAfterTrigFourteen * ');
            System.debug(e.getMessage());
		}
			        
        Test.stopTest();
        
	}
	
	public static testMethod void execute_ValueAfterTrigFifteen() {  
		
		GenerateEnvironmentTest.genAfterTrig(); 
		
		Test.startTest();   
		try {
			GenerateEnvironmentTest.obstacle1.Priority__c = 2;
			GenerateEnvironmentTest.obstacle1.Method__c = GenerateEnvironmentTest.method2.Id;
			update GenerateEnvironmentTest.obstacle1;
	
			GenerateEnvironmentTest.obstacle1.Value__c = GenerateEnvironmentTest.value2.Id;
			update GenerateEnvironmentTest.obstacle1;
				
			GenerateEnvironmentTest.obstacle1.Priority__c = -2;
			update GenerateEnvironmentTest.obstacle1;
		} catch (Exception e) {
            System.debug(' ****************** execute_ValueAfterTrigFifteen * ');
            System.debug(e.getMessage());
		}
			        
        Test.stopTest();
        
	}
	
	
	public static testMethod void execute_ValueAfterTrigSixteen() {  
		
		GenerateEnvironmentTest.genV2MOMLocked(); 
		
		Test.startTest();  
		 
		try{
			V2MOM__c v2mom = GenerateEnvironmentTest.v2momIndividual;
		
			v2mom.Status__c = 'Pending Approval';
			update v2mom;
		}catch (Exception e){
			System.debug(' Error the v2mom is locked');
		}		        
		try{
			V2MOM__c v2mom = GenerateEnvironmentTest.v2momIndividual;
			
			v2mom.Status__c = 'Approved';
			update v2mom;
		}catch (Exception e){
			System.debug(' Error the v2mom is locked');
		}		        
		try{
			V2MOM__c v2mom = GenerateEnvironmentTest.v2momIndividual;
			
			v2mom.Status__c = 'Rejected';
			update v2mom;
		}catch (Exception e){
			System.debug(' Error the v2mom is locked');
		}		        
			        
        Test.stopTest();
        
	}

	public static testMethod void execute_ValueAfterTrigSeventeen() {  
		
		GenerateEnvironmentTest.genV2MOMLocked(); 
		
		Test.startTest();  
		 
		try{				
			GenerateEnvironmentTest.value1.Priority__c = 2;
			update GenerateEnvironmentTest.value1;
		}catch (Exception e){
			System.debug(' Error the v2mom is locked');
		}		        
			        
		try{
			GenerateEnvironmentTest.value1.Priority__c = -2;
			update GenerateEnvironmentTest.value1;
		}catch (Exception e){
			System.debug(' Error the v2mom is locked');
		}		        
			        
        Test.stopTest();
        
	}
	
	public static testMethod void execute_ValueAfterTrigEighteen() {  
		
		GenerateEnvironmentTest.genV2MOMLocked(); 
		
		Test.startTest();   
		
		try{
			GenerateEnvironmentTest.method1.Priority__c = 2;
			update GenerateEnvironmentTest.method1;
		}catch (Exception e){
			System.debug(' Error the v2mom is locked');
		}	
			        
		try{
			GenerateEnvironmentTest.method1.Priority__c = -2;
			update GenerateEnvironmentTest.method1;
		}catch (Exception e){
			System.debug(' Error the v2mom is locked');
		}		        
			        
        Test.stopTest();
        
	}

	
	public static testMethod void execute_ValueAfterTrigNineteen() {  
		
		GenerateEnvironmentTest.genV2MOMLocked(); 
		
		Test.startTest();  
		 
		try{
			GenerateEnvironmentTest.measure1.Priority__c = 2;
			update GenerateEnvironmentTest.measure1;
		}catch (Exception e){
			System.debug(' Error the v2mom is locked');
		}		   
		     
		try{
			GenerateEnvironmentTest.measure1.Priority__c = -2;
			update GenerateEnvironmentTest.measure1;
		}catch (Exception e){
			System.debug(' Error the v2mom is locked');
		}		        
			        
        Test.stopTest();
        
	}
	
	public static testMethod void execute_ValueAfterTrigTwenty() {  
		
		GenerateEnvironmentTest.genV2MOMLocked(); 
		
		Test.startTest();   
			
		try{
			GenerateEnvironmentTest.obstacle1.Priority__c = 2;
			update GenerateEnvironmentTest.obstacle1;
		}catch (Exception e){
			System.debug(' Error the v2mom is locked');
		}		        
			
		try{
			GenerateEnvironmentTest.obstacle1.Priority__c = -2;
			update GenerateEnvironmentTest.obstacle1;
		}catch (Exception e){
			System.debug(' Error the v2mom is locked');
		}		        
			        
        Test.stopTest();
        
	}
	
	public static testMethod void execute_ValueAfterTrigTwentyOne() {  
		
		GenerateEnvironmentTest.genV2MOMLocked(); 
		
		Test.startTest();   
			
		try{
			delete GenerateEnvironmentTest.v2momIndividual;
		}catch (Exception e){
			System.debug(' Error the v2mom is locked');
		}		        
			        
        Test.stopTest();
        
	}
	
	
	public static testMethod void execute_ValueAfterTrigTwentyTwo() {  
		
		GenerateEnvironmentTest.genAfterTrig(); 
		
		Test.startTest();   
		try {
			V2MOM__c v2mom = GenerateEnvironmentTest.v2momIndividual;
			
			v2mom.Status__c = 'Approved';
			update v2mom;
	
			Method__c method = new Method__c(V2MOM__c = v2mom.Id, 
											Value__c = GenerateEnvironmentTest.value1.Id,
											Priority__c = 2, 
											Name = 'Method',
											Description__c = 'Description');
			insert method;
		} catch (Exception e) {
            System.debug(' ****************** execute_ValueAfterTrigTwentyTwo * ');
            System.debug(e.getMessage());
		}
			        
        Test.stopTest();
        
	}
	
	
	public static testMethod void execute_ValueAfterTrigTwentyThree() {  
		
		GenerateEnvironmentTest.genAfterTrig(); 
		
		Test.startTest();   
		try {
			GenerateEnvironmentTest.method1.Value__c = GenerateEnvironmentTest.value2.Id;
			update GenerateEnvironmentTest.method1;
		} catch (Exception e) {
            System.debug(' ****************** execute_ValueAfterTrigTwentyThree * ');
            System.debug(e.getMessage());
		}

        Test.stopTest();
        
	}
		
	public static testMethod void execute_ValueAfterTrigTwentyFour() {  
		
		GenerateEnvironmentTest.genAfterTrig(); 
		
		Test.startTest();   
		try {
			GenerateEnvironmentTest.measure1.Value__c = GenerateEnvironmentTest.value2.Id;
			update GenerateEnvironmentTest.measure1;
				
			GenerateEnvironmentTest.obstacle1.Value__c = GenerateEnvironmentTest.value2.Id;
			update GenerateEnvironmentTest.obstacle1;
		} catch (Exception e) {
            System.debug(' ****************** execute_ValueAfterTrigTwentyFour * ');
            System.debug(e.getMessage());
		}
			        
        Test.stopTest();
        
	}
	
	public static testMethod void execute_ValueAfterTrigTwentyFive() {  
		
		Test.startTest(); 
		  
		try{
	    	V2MOM__c v2mom2 = new V2MOM__c (Vision__c = 'This Vision', 
											V2MOM_Type__c = 'Individual Q3/Q4',
											Name = 'V2MOM', 
											Effective_Date__c = 'FY07',
											Share_With__c = 'Other');
			insert v2mom2;
		}catch (Exception e){
			System.debug(' Share invalid');
		}		        
		
        Test.stopTest();
        
	}
	
	public static testMethod void execute_ValueAfterTrigTwentySix() {  
		
		Test.startTest();  
		 
		try{
			V2MOM__c v2mom = GenerateEnvironmentTest.v2momIndividual;
			
			v2mom.Status__c = 'Pending Approval';
			v2mom.Share_With__c = '';
			update v2mom;
		}catch (Exception e){
			System.debug(' Share invalid');
		}		        
		
        Test.stopTest();
        
	}
	
}