public class bulkClaimsForEducationalReimbursement {
    public static void createBulkEducationCases(Contact c,Integer caseRecs,Integer claimrecs){
        Reimbursement_Policy__mdt Policy = [SELECT Id__c, Currency__c 
                                            FROM Reimbursement_Policy__mdt 
                                            WHERE Country__c = :c.ES_DJC_Contact_Country__c 
                                            AND Active__c = true
                                            and MasterLabel Like '%Education%'];
        Reimbursement_Category__mdt category = [SELECT MasterLabel,Id__c FROM Reimbursement_Category__mdt 
                                                WHERE Group__c = 'Education'];
        list<case> wellnessCasesToInsert = new list<case>();
        list<DJC_Wellness_Reimbursement_Claim__c> claimsToInsert = new list<DJC_Wellness_Reimbursement_Claim__c>();
        for(integer i =0;i<caseRecs;i++){
            Case wellnessCase = new case();
            wellnessCase.Contactid = c.id;
            wellnessCase.subject = 'Educational Reimbursement For Integration'+i;
            wellnessCase.Description = 'Bulk Testing For the Education'+i;
            wellnessCase.recordtypeid=Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Expense Cases').getRecordTypeId();
            wellnessCase.Type = 'Education Reimbursement Request';
            wellnessCase.Reimbursement_Policy_Id__c = Policy.Id__c;
            wellnessCase.Reimbursement_Category_Id__c = category.Id__c;
            wellnessCase.ES_DJC_Topic__c = category.MasterLabel;
            wellnessCase.Division__c = c.Division__c;
            wellnessCase.status = 'Approved';
            wellnessCase.Origin = 'Employee Success - Web';
            wellnessCase.CurrencyIsoCode = Policy.Currency__c; 
            wellnessCasesToInsert.add(wellnessCase);    
        }
        insert wellnessCasesToInsert;
        
        DJC_Wellness_Provider__c Provider = new DJC_Wellness_Provider__c();
        Provider.DJC_Contact__c = c.id;
        Provider.Name = 'University Of Texas';
        insert Provider;    
        for(case claimForCase : wellnessCasesToInsert){
        for(integer j=0;j<claimrecs;j++){
            DJC_Wellness_Reimbursement_Claim__c claim = new DJC_Wellness_Reimbursement_Claim__c();       
            claim.DJC_Wellness_Case__c = claimForCase.id;
            claim.RecordTypeId = Schema.SObjectType.DJC_Wellness_Reimbursement_Claim__c.getRecordTypeInfosByName().get('Education Claim').getRecordTypeId();
            claim.DJC_Wellness_Provider__c = Provider.id;
            claim.DJC_Education_Date_Completed__c = System.today();
            claim.DJC_Wellness_Request_Status__c = 'Approved';
            claim.DJC_Education_Policy__c ='Diploma';
            claim.DJC_Reimbursement_Claim_Detail__c ='Machine Learning';
            claim.CurrencyIsoCode = claimForCase.CurrencyIsoCode;
            claim.DJC_Wellness_Amount_Requested__c=1;  
            claimsToInsert.add(claim);   
        } 
        }
        insert claimsToInsert;
    }
}