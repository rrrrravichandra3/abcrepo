@istest
public class Test_PF_NHW_ProvisioningTypeTestFactory {
    @istest
    public static void createNHWProvisionings() {
        List<sObject> nhwprovisionings = Test.loadData(NHW_Provisioning__c.sObjectType, 'testNHWProvisioningData');
    }
    
    @istest
    public static void createNHWLightningComponents() {
        List<sObject> nhwlc = Test.loadData(NHW_Lightning_Component__c.sObjectType, 'testNHWLightningComponentData');
    }

    
    public static Case getMockProvisioningCase() {
            TF2_Department__c cc = new TF2_Department__c(Department_Number__c='7419',Name='IT Apps');
            Business_Unit__c BU = new Business_Unit__c(BU_Code__c='2301',Name = 'Shared Services');
            TF2_Company__c Comp = new TF2_Company__c(Company_Code__c='100',Name='100-United States of America');
            TF2_PCC__c pcc = new TF2_PCC__c(name = '100-United States of America' );
            TF2_Business_Site__c buSite = new TF2_Business_Site__c(name='Remote -California - San Francisco',City__c = 'California',
                                       Country__c='Unites States',Street_Address__c='350 Mission St',State_Province__c = 'San Francisco',
                                       Type__c='City');
        	Contact con = new Contact(FirstName = 'Test', LastName = '39387', Email='test@salesforce.com',EmployeeNumber__c ='9009',
                                      RecordTypeId = NHW_Util.getEmployeeContactRecordTypeId(), Status__c = 'Deactive');
			insert BU;
        	insert Comp;
        	insert pcc;
        	insert cc;
        	insert buSite;
        	insert con;
        
            Case provisioningCase = new Case();
            provisioningCase.Offer_Type__c = 'External (normal) hire';
            provisioningCase.Resource_Type__c = 'Perm/FTE';
            provisioningCase.First_Name__c = 'Test';
            provisioningCase.Last_Name__c = 'New Hire 1';
            provisioningCase.Company__c = Comp.id;
            provisioningCase.Primary_Coverage_Country__c = pcc.Id;
            provisioningCase.Business_Title__c = 'AMTS';
            provisioningCase.Business_Unit_NHW__c = '2301-Shared Services';
            provisioningCase.Cost_Center_NHW__c =  '7419-IT Apps';
            provisioningCase.NHW_Business_Unit__c = BU.id;
            provisioningCase.NHW_Cost_Center__c =  cc.id;
            provisioningCase.NHW_Start_Date__c = Date.today().addDays(16);
            provisioningCase.NH_Personal_Email__c = 'test123@email.com';  
            provisioningCase.description='';
            provisioningCase.NH_Business_Site__c = buSite.id;
            provisioningCase.Office_Address__c = '350 Mission St';
            provisioningCase.Office_City__c ='California';
            provisioningCase.Office_State_Province__c = 'San Francisco';
            provisioningCase.Office_Zip_Postal_Code__c = '94002';
            provisioningCase.Office_Country__c = 'United States';
            provisioningCase.Manager_s_Email__c = UserInfo.getUserEmail();
            provisioningCase.Email_Address__c = 'test@email.com';
            provisioningCase.NHW_Employee_Type__c = 'regular employee';
            provisioningCase.Division__c = 'AMER';
            provisioningCase.RecordTypeId = NHW_Util.getnhwCaseRecordTypeId();
            provisioningCase.NHW_Send_Reminder__c = false;
            provisioningCase.origin = 'NHW';
            provisioningCase.status = 'New';
            provisioningCase.Subject = 'New Hire Provisioning Request for ' + provisioningCase.First_Name__c + ' ' + provisioningCase.Last_Name__c;
        	provisioningCase.NHW_Employee__c = con.id;
            return provisioningCase;
            
    }
}