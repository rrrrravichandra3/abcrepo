@isTest
private class TaskReassignment_ControllerTest {

    @testSetup static void setup(){
        List<sObject> lstInsert = new List<sObject>();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        //Creation of User Data
        User u1 = new User(Alias = 'newUser', Email='newuser@example.com', EmailEncodingKey='UTF-8', LastName='newTestUser1', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='newuserTask@example.com');
        User u2 = new User(Alias = 'newUser2', Email='newuser2@example.com', EmailEncodingKey='UTF-8', LastName='newTestUser2', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='newuserTask2@example.com');
        
        lstInsert.add(u1);
        lstInsert.add(u2);
        
        insert lstInsert;
        
        //Creation of Task 
        Task tsk = new Task(Subject='Interview', Priority='Normal', Status='Not Started', OwnerId=u1.Id);
        insert tsk;
    }
    
    @isTest static void TaskReassignment_ControllerMethod(){
        
        Task tsk = [Select id, ownerId from Task limit 1];
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(tsk);
        TaskReassignment_Controller taskReAssign = new TaskReassignment_Controller(stdCon);
        
        Test.startTest();
        
        // Passing empty "strUserToSearch" search string to UserSearch method
        String searchCriteria = 'Minimum of 3 characters needed to search.';
        taskReAssign.strUserToSearch = '';
        taskReAssign.SearchUsers();
        boolean msgFoundsearchCriteria = false; 
        for(Apexpages.Message msg : ApexPages.getMessages())
        { 
              if (msg.getDetail() == searchCriteria) msgFoundsearchCriteria = true; 
        } 
        system.assert(msgFoundsearchCriteria);
        
        // Passing less then 3 characters of "strUserToSearch" search string to UserSearch method
        taskReAssign.strUserToSearch = 'ne';
        taskReAssign.SearchUsers();
        boolean msgFoundsearchCriteria1 = false; 
        for(Apexpages.Message msg : ApexPages.getMessages())
        { 
              if (msg.getDetail() == searchCriteria) msgFoundsearchCriteria1 = true; 
        } 
        system.assert(msgFoundsearchCriteria1);
        
        // Passing string which will not bring any results to UserSearch method
        taskReAssign.strUserToSearch = 'zzzzzz';
        taskReAssign.SearchUsers();
        System.assertEquals(0,taskReAssign.lstUser.size());

        
        // Passing string which will bring results to UserSearch method
        taskReAssign.strUserToSearch = 'newTestUser2';
        taskReAssign.SearchUsers();
        System.assertEquals(1,taskReAssign.lstUser.size());
        taskReAssign.Cancel();
        
        // Calling UpdateOwner method without selecting new Owner
        taskReAssign.UpdateOwner();
        
        // Calling UpdateOwner method after selecting new Owner
        User usr2 = [Select id, name from User where username='newuserTask2@example.com' limit 1];
        taskReAssign.strSelectedUserId = String.ValueOf(usr2.Id);
        taskReAssign.strSelectedUserName = usr2.Name;
        taskReAssign.UpdateOwner();
        System.assertEquals(usr2.Id,tsk.OwnerId);
        
        Test.StopTest();
    }

}