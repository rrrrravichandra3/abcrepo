public class ReimbursementPDFController {

    public ReimbursementPDFController controller{
        get{
            return this;
        }
        set;
    }
    
    public String reimbursementCaseId{get;set;}
    
    public Case reimbursementCase{
        get{
            if(reimbursementCase == null){
                reimbursementCase = [SELECT Subject, CaseNumber, Contact.Name, Type, ES_DJC_Topic__c, Status, CreatedDate, LastModifiedDate FROM Case WHERE Id = :reimbursementCaseId];
            }
            return reimbursementCase;
        }
        set;
    }

    public List<DJC_Wellness_Reimbursement_Claim__c> claims{
        get{
            if(claims == null){
                claims = [select DJC_Wellness_Amount_Requested__c,
                                DJC_Wellness_Request_Comments__c,
                                DJC_Wellness_End_Date_of_Activity__c,
                                DJC_Wellness_Start_Date_of_Activity__c,
                                DJC_Wellness_Request_Status__c,
                                DJC_Wellness_Activity__c,
                                DJC_Wellness_Provider__r.name,
                                DJC_Education_Policy__c,
                                DJC_Education_Date_Completed__c,
                                DJC_Reimbursement_Claim_Detail__c,
                                DJC_Education_Institution__r.name,
                                CurrencyISOCode,
                                Name,
                                DJC_Wellness_Claim_Fiscal_Year_Start__c,
                                DJC_Wellness_Claim_Quarter__c
                        from DJC_Wellness_Reimbursement_Claim__c WHERE DJC_Wellness_Case__c = :reimbursementCase.Id order by name];
            }
            return claims;
        }
        set;
    }

    public String categoryGroup{
        get{
            if(categoryGroup == null){                
                for(Case c : [SELECT Id, Reimbursement_Category_Id__c FROM Case WHERE Id = :reimbursementCase.Id]){
                    Integer categoryId = c.Reimbursement_Category_Id__c.intValue();
                    categoryGroup = [SELECT Group__c FROM Reimbursement_Category__mdt WHERE Id__c = :categoryId].Group__c;
                }
            }
            return categoryGroup;
        }
       set;
    }

    public String fileName{
        get{
            if(fileName == null){
                fileName = reimbursementCase.Subject + '-' + Datetime.now().format('MM-dd-yyyy KK-mm a') + '.pdf';
            }
            return fileName;
        }
        set;
    }

}