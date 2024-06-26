@isTest
private class Test_BatchableRoleHierarchyLinker {
    
    public static testMethod void Test_BatchableRoleHierarchyLinker() {
        
        //Get users for the test
        List<User> theUsers = [Select Id, FirstName, LastName, EmployeeNumber, Manager__c, UserRoleId From User Where UserType != 'Guest' Limit 10];
        
        String query = 'Select Id, FirstName, LastName, EmployeeNumber, Manager__c, UserRoleId From User Where UserType != \'Guest\' Limit 10';
        
        Test.startTest();
        
            BatchableRoleHierarchyLinker batch = new BatchableRoleHierarchyLinker(query);
            
            //Execute the query
            database.executeBatch(batch);
        
        Test.stopTest();
        
        //Verify if test worked
        
        /* Get the roles of the users */
        Set<Id>roleIds = new Set<Id>();
        Set<Id>managerIds = new Set<Id>();
        
        for (User usr : theUsers) {
            roleIds.add(usr.UserRoleId);
            managerIds.add(usr.Manager__c);
        }
        
        /* Get the managers of the users */
        List<User>managers = [select id, UserRoleId from User where Id in :managerIds];
        
        //meto en el map el id del manager, el id del role del manager
        Map<Id, Id>managerMap = new Map<Id, Id>();
        
        for (User cur : managers) {
            managerMap.put(cur.Id, cur.UserRoleId);
        }
        
        /* Get all the roles in a list to check if were linked */ //chapa los roles de los usuarios
        List<UserRole> rolesToCheck = [Select Id, Name, ParentRoleId From UserRole Where id IN: roleIds];
        
        Map<Id, UserRole>roleMap = new Map<Id, UserRole>();
        for (UserRole usrRole : rolesToCheck) {
            //mete el id del usuario, y el role
            roleMap.put(usrRole.Id, usrRole);
        }
        
        /* Go through users again and and check if their roles were linked to the manager's role. */
        for(User u : theUsers){
            if (managerMap.containsKey(u.Manager__c)) {
                if (roleMap.containsKey(u.UserRoleId)) {
                    UserRole temp = roleMap.get(u.UserRoleId);
                    System.assertEquals(temp.ParentRoleId,managerMap.get(u.Manager__c));     
                }
            }
        }
    }   
}