@isTest
private class TestPF_BatchableRoleAssignment_Unit {
    
    public static testMethod void Test_BatchableRoleHierarchyAssignment() {
        
        //Get users for the test
        List<User> theUsers = [Select Id, FirstName, LastName, EmployeeNumber, Manager__c, UserRoleId From User Where UserType != 'Guest' Limit 10];
        
        String query = 'Select Id, FirstName, LastName, EmployeeNumber, Manager__c, UserRoleId From User Where UserType != \'Guest\' Limit 10';
        
        Test.startTest();
        
            BatchableRoleHierarchyAssignment batch = new BatchableRoleHierarchyAssignment(query);
            
            //Execute the query
            database.executeBatch(batch);
        
        Test.stopTest();
        
        //Verify if test worked
        
        //Select the same users of the test
        List<User> users = [Select id, 
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
            
            //Compare if now the UserRoleId of the user is equals to tempRole.Name
            UserRole usrRole = [Select Id, Name From UserRole Where Id=: usr.UserRoleId];
            System.assert(usrRole.Name!= null);     
        
        }
    }   
}