/**
 * @description       : Test class for MA_AcquisitionStore
 * @author            : Srikanth Chennojui
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   27-11-2023   Srikanth Chennoju   Initial Version
**/
@isTest(SeeAllData=false)
public class Test_MA_AcquisitionStore {

     private Static String maESName = 'acqStore';
    @testSetup 
    static void setupCompanyData() {
        
        UserRole role = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_ESROLE_NAME);
        profile userProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_EMPLOYEE_PROFILE);
        List<User> maUser = MA_TestUtil.createESUser(1, userProfile.Id, role.Id, true, maESName);
        
        PermissionSet maESPS = [SELECT Id FROM PermissionSet WHERE Name = :MA_TestUtilityValues.MA_ES_PERMSET LIMIT 1];
        MA_TestUtil.createPermissionsetAssignment(maESPS.Id, maUser[0].Id, true);
    }
    
       @isTest static void test_ElevatedContext() {
        User maESUser = [Select id,email from user where Email = :maESName + MA_TestUtilityValues.MA_ES_USER_EMAIL limit 1];
      
        System.runAs(maESUser){
            MA_AcquisitionStore.getAcquisitionContactByEmail(maESUser.email);
            

        }
           
       }
}