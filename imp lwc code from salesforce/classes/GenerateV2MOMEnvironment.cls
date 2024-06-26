public with sharing class GenerateV2MOMEnvironment {
   
    public static List<Method__c> methodList = new List<Method__c>();
	public static List<Measure__c> metricList = new List<Measure__c>();
	public static List<Obstacle__c> obstacleList = new List<Obstacle__c>();
	
	
	/*
	* Create V2MOM
	*/
	public static V2MOM__c createV2MOM(String name, String t, String effectiveDate, String vision, String share, String status, boolean locked){
		V2MOM__c v = new V2MOM__c();
		v.Name = name;
		v.V2MOM_Type__c = t;
		v.Effective_Date__c = effectiveDate;
		v.Vision__c = vision;
		v.Share_With__c = share;
		v.Status__c = status;
		v.Locked__c = locked;
		upsert(v);
		return v;
	}
	
    /*
	* Create Value
	*/
	public static Value__c createValue(String name, String tagLine, Integer priority, Id id){
		Value__c v = new Value__c();
		v.Name = name;
		v.Tag_Line__c = tagLine;
		v.Priority__c = priority;
		v.V2MOM__c = id;
		upsert(v);
		return v;
	}
	
	/*
	* Lock V2MOM
	*/
	public static V2MOM__c lockV2MOM (V2MOM__c v2moms){
		v2moms.Locked__c = true;
		update v2moms;
		return v2moms;
	}
	
    /*
	* Create Method
	*/
	public static Method__c createMethod(String name, String description, Integer priority, Id v2momId, Id valueId){
		Method__c m = new Method__c();
		m.Name = name;
		m.Description__c = description;
		m.Priority__c = priority;
		if (valueId != null)
			m.Value__c = valueId;
		m.V2MOM__c = v2momId;
		upsert m;
		return m;
	}
	
	/*
	* Create Metric
	*/
	public static Measure__c createMetric(String description, Integer priority, Id v2momId, Id valueId, Id methodId){
		Measure__c m = new Measure__c();
		m.Description__c = description;
		m.Start_Date__c = System.today();
		m.End_Date__c = System.today().addYears(1);
		m.Priority__c = priority;
		if (valueId != null)
			m.Value__c = valueId;
		if (methodId != null)
			m.Method__c = methodId;
		m.V2MOM__c = v2momId;
		upsert m;
		return m;
	}
	
	/*
	* Create Obstacle
	*/
	public static Obstacle__c createObstacle(String description, Integer priority, Id v2momId, Id valueId, Id methodId){
		Obstacle__c obs = new Obstacle__c();
		obs.Description__c = description;
		obs.Priority__c = priority;
		if (valueId != null)
			obs.Value__c = valueId;
		if (methodId != null)
			obs.Method__c = methodId;
		obs.V2MOM__c = v2momId;
		upsert obs;
		return obs;
	}
	@isTest
	static void test1(){
		V2mom__c v2mom = GenerateV2MOMEnvironment.createV2MOM('name', 'Year End','12/12/2012', 'vision', 'My Management Hierarchy', 'Approved', False);
		Value__c value= GenerateV2MOMEnvironment.createValue('name', 'tagLine', 2, v2mom.id);
		Method__c method =GenerateV2MOMEnvironment.createMethod('name', 'description', 1, v2mom.id, value.id);
		Measure__c measure = GenerateV2MOMEnvironment.createMetric('description', 1, v2mom.id, value.Id, method.Id);
		Obstacle__c obstacle = GenerateV2MOMEnvironment.createObstacle('description', 1, v2mom.Id, value.Id, method.Id);
		GenerateV2MOMEnvironment.lockV2MOM(v2mom);
		
	}	
}