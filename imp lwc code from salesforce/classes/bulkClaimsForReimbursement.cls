public class bulkClaimsForReimbursement   {
    
    public static void createBulkWellnessCases(Contact c,Integer caseRec,Integer claimRec){
        Reimbursement_Policy__mdt Policy = [SELECT Id__c, Currency__c 
                                            FROM Reimbursement_Policy__mdt 
                                            WHERE Country__c = :c.ES_DJC_Contact_Country__c 
                                            AND Active__c = true
                                            and MasterLabel Like '%Wellness%'];
        Reimbursement_Category__mdt category = [SELECT MasterLabel,Id__c FROM Reimbursement_Category__mdt 
                                                WHERE Group__c = 'Wellness'];
        list<case> wellnessCasesToInsert = new list<case>();
        list<DJC_Wellness_Reimbursement_Claim__c> claimsToInsert = new list<DJC_Wellness_Reimbursement_Claim__c>();
        
        for(integer i =0;i<caseRec;i++){
            Case wellnessCase = new case();
            wellnessCase.Contactid = c.id;
            wellnessCase.subject = 'Test reimbursemnt integartion for wellness'+i;
            wellnessCase.Description = 'Test reimbursemnt integartion for wellness';
            wellnessCase.recordtypeid=Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Expense Cases').getRecordTypeId();
            wellnessCase.Type = 'Wellness Reimbursement Request';
            wellnessCase.Reimbursement_Policy_Id__c = Policy.Id__c;
            wellnessCase.Reimbursement_Category_Id__c = category.Id__c;
            wellnessCase.ES_DJC_Topic__c = category.MasterLabel;
            wellnessCase.Division__c = c.Division__c;
            wellnessCase.Origin = 'Employee Success - Web';
            wellnessCase.status  = 'Approved';
            wellnessCase.CurrencyIsoCode = Policy.Currency__c; 
            wellnessCasesToInsert.add(wellnessCase);    
        }
        
        
        insert wellnessCasesToInsert;
        
        DJC_Wellness_Provider__c Provider = new DJC_Wellness_Provider__c();
        Provider.DJC_Contact__c = c.id;
        Provider.Name = '24x7 Fitness';
        insert Provider;    
        for(Case wellnessCase : wellnessCasesToInsert){
        for(integer j=0;j<caseRec;j++){
            DJC_Wellness_Reimbursement_Claim__c claim = new DJC_Wellness_Reimbursement_Claim__c();       
            claim.DJC_Wellness_Case__c = wellnessCasesToInsert[0].id;
            claim.DJC_Wellness_Provider__c = Provider.id;
            claim.DJC_Wellness_Start_Date_of_Activity__c = System.today();
            claim.DJC_Wellness_Request_Status__c = 'Approved';
            claim.DJC_Wellness_Activity__c ='Badminton';
            claim.CurrencyIsoCode = wellnessCasesToInsert[0].CurrencyIsoCode;
            claim.DJC_Wellness_Amount_Requested__c=1;  
            claimsToInsert.add(claim);   
        }   
    }
        insert claimsToInsert;   
        
    }
    
}