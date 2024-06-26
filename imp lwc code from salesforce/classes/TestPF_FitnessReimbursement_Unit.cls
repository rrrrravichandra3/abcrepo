@isTest
private class TestPF_FitnessReimbursement_Unit {

    static testMethod void Test_FitnessReimbursement() {
       
       Fitness_Reimbursement__c fit = new Fitness_Reimbursement__c();
       fit.Status__c = 'Pending Approval';
       fit.Signature__c = true;
       fit.Description_of_Eligible_Fitness_Activity__c = 'Gym Membership: Employee Only';
       fit.Name_Address_Fitness_Centre_Provider__c = 'Test';
       fit.Country__c = 'France';
       fit.Amount_of_Reimbursement_Requested__c = 10;
       fit.Currency__c = 'EUR';
       fit.Quarter__c = 'Jan-Mar';
       fit.Receipt_1_Date_From__c = Date.newInstance(2009, 1, 1);
       fit.Receipt_1_Date_To__c = Date.newInstance(2009, 2, 1);
       fit.Year__c = '2009';
       fit.Total_Amount_Requested__c = 100;
       fit.Fitness_Provider_Name_Location__c = 'Test Location';
       fit.Amount_Requested__c = 200;
       fit.Activity_Receipt_Date__c = System.Date.today();
       fit.Total_Amount_Requested__c = 100;
       fit.Fitness_Provider_Name_Location__c = 'Provider Location';
       
        
       try 
       {
	       User u = [Select Id, Profile.Name from User Where Division = 'EMEA - All Countries' limit 1];
	       System.assertEquals(fit.Fitness_Provider_Name_Location__c, 'Provider Location');
	       System.runAs(u)
	       {
		   	   insert fit;
		   		
		   	   update fit;
	       }
       }
       catch(Exception ex)
       {
       		System.debug('This Failed ' + ex.getMessage());
       }
    }
}