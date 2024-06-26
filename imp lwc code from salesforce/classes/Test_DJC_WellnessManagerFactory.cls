@isTest
public class Test_DJC_WellnessManagerFactory {

    public static testMethod void testManagerFactoryInstances(){
        
        List<Reimbursement_Category_Policy_Assoc__mdt> associations = [SELECT Category_Id__c, Policy_Id__c FROM Reimbursement_Category_Policy_Assoc__mdt];

        for(Reimbursement_Category_Policy_Assoc__mdt association : associations){
	        
            Reimbursement_Policy__mdt policy = [SELECT Country__c, Currency__c, Id__c, Organization__c FROM Reimbursement_Policy__mdt WHERE Id__c = :association.Policy_Id__c];
            Reimbursement_Category__mdt category = [SELECT Group__c, Id__c FROM Reimbursement_Category__mdt WHERE Id__c = :association.Category_Id__c];
			
			DJC_WellnessManagerFactory managerFactory = DJC_WellnessManagerFactory.getInstance(null, policy, category, null);
            
            if(policy.Organization__c.equalsIgnoreCase('Salesforce')){
                if(category.Group__c.equalsIgnoreCase(DJC_Wellness_Type.WELLNESS.name())){
                    System.assert(managerFactory instanceof DJC_QuarterWellnessManagerFactory, 'Wrong wellness manager factory returned');
                }else if(category.Group__c.equalsIgnoreCase(DJC_Wellness_Type.HEALTH.name())){
                    System.assert(managerFactory instanceof DJC_YearWellnessManagerFactory, 'Wrong wellness manager factory returned');
                }else if(category.Group__c.equalsIgnoreCase(DJC_Wellness_Type.EDUCATION.name())){
                    System.assert(managerFactory instanceof DJC_YearEducationManagerFactory, 'Wrong wellness manager factory returned');
                }
            }else if(policy.Organization__c.equalsIgnoreCase('Foundation')){
                if(category.Group__c.equalsIgnoreCase(DJC_Wellness_Type.WELLNESS.name())){
					System.assert(managerFactory instanceof DJC_WellnessManagerFactory_Fndt, 'Wrong wellness manager factory returned');
                }else if(category.Group__c.equalsIgnoreCase(DJC_Wellness_Type.HEALTH.name())){
					System.assert(managerFactory == null, 'Wrong wellness manager factory returned');
                }else if(category.Group__c.equalsIgnoreCase(DJC_Wellness_Type.EDUCATION.name())){
					System.assert(managerFactory instanceof DJC_YearEducationManagerFactory_Fndt, 'Wrong wellness manager factory returned');
                }
            }
        }
    }
}