public class V2MOM_Details_Controller {
	
	 V2MOM__c v2mom = new V2MOM__c();
	// String v2momId = System.currentPageReference().getParameters().get('id');
	List<V2MOM__c> v2moms = [select Id from V2MOM__c limit 10];
	String v2momId = v2moms[0].Id;
	 public V2MOM_Details_Controller(){
	 		
	 		v2mom = [select v.Vision__c, v.V2MOM_Type__c, v.Status__c, v.Share_With__c, 
	 						v.OwnerId, v.LastModifiedById, v.IsLocked, v.Id, v.Effective_Date__c,
	 						v.Date_Submitted__c, v.Date_Approved__c, v.CreatedById 
 					 from V2MOM__c v
 					 where Id =: v2momId];
	 }
	 
	 public V2MOM__c getV2MOM(){
	 	return v2mom;	
	 }
}