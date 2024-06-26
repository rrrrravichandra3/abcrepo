@isTest
private class TestPF_BatchableRoleCreator_Unit {
    
    public static testMethod void Test_BatchableRoleHierarchyCreator() {
        
        //Get users for the test
        List<User> theUsers = [Select Id, FirstName, LastName, EmployeeNumber, Manager__c, UserRoleId From User Where UserType != 'Guest' and EmployeeNumber != null   Limit 50];
        
        
        String query = 'Select Id, FirstName, LastName, EmployeeNumber, Manager__c, UserRoleId From User Where UserType != \'Guest\' and EmployeeNumber != null   Limit 50';
        
        Test.startTest();
        
            BatchableRoleHierarchyCreator batch = new BatchableRoleHierarchyCreator(query);
            
            //Execute the query
            database.executeBatch(batch);
        
        Test.stopTest();
        
        //Verify if test worked
        List<User> users = new List<User>();
        
        //Select the same users of the test
        users = [Select id, 
                        FirstName, 
                        LastName, 
                        EmployeeNumber, 
                        Manager__c, 
                        UserRoleId 
                 From User Where id IN: theUsers];
        
        for(User usr: users){
            
            UserRole tempRole = new UserRole();
            
            //Create the Role Name 
            String nameString = usr.FirstName + usr.LastName;
            if (nameString.length() > 34) {
                nameString = nameString.substring(0,34);
            }
            
            tempRole.Name = nameString + usr.EmployeeNumber;
            
            //Get the UserRole of the user
            UserRole role = [Select Id, Name From UserRole Where Id =: usr.UserRoleId];
            
            //Compare if the UserRole.Name of the user is now the same of tempRole
            System.assert(role.Name != null);    
        
        }
    }   
}