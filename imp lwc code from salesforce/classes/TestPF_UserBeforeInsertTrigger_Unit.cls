/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestPF_UserBeforeInsertTrigger_Unit {



    /**
    * Test 1
    */
    static testMethod void newUserWithoutManagerAndReviewManagerNoOverride() {
        // Create a new user, leave both the manager and review manager fields empty
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User u =  new User(username='test__changeManager_test1@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmngr1',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id);
   
        insert u;   
  
        //verify that the user's manager and review manager are still empty
        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.assert(u.manager__c == null);
        System.assert(u.reviewManager__c == null);
        
    }

    /**
    *  Test 2
    */
    static testMethod void newUserWithoutManagerWithReviewManagerNoOverride() {
        // Create a new user, leave the manager empty, fill in the review manager
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User manager = GenerateEnvironmentTest.getManager();
        User u =  new User(username='test__changeManager_test2@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmngr2',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    reviewManager__c = manager.Id);

        insert u;   
  
        //verify that the user's manager remains blank and review manager is the one provided in the insert data
        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.assert(u.manager__c == null);
        System.assert(u.reviewManager__c == manager.Id);
    }
    
    
   /**
   * Test 3
   */ 
   static testMethod void newUserWithManagerWithoutReviewManagerNoOverride() {
        // Create a new user, provide a manager but leave the review manager empty
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User manager = GenerateEnvironmentTest.getManager();
        User u =  new User(username='test__changeManager_test3@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmngr3',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    Manager__c = manager.Id);
                insert u;   
         
  
        //verify that the user's manager is the one provided in the insert data
        //and that the review manager has been updated and is equal to the manager field
        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.assert(u.manager__c == manager.Id);
        System.assert(u.reviewManager__c == manager.Id);
        
    }
    
      
   /**
   * Test 4
   */   
   static testMethod void newUserWithManagerAndRevManagerNoOverride() {
        // Create a new user, provide a manager and a review manager (different users), leave the Override Manager option unchecked (default)
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User manager = GenerateEnvironmentTest.getManager();
        User reviewManager = GenerateEnvironmentTest.getSecondManager();
        User u =  new User(username='test__changeManager_test4@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmngr4',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    Manager__c = manager.Id,
                                    ReviewManager__c = reviewManager.Id);
                                    
        insert u;   
  
        //verify that the user's manager is the one provided in the insert data
        //and that the review manager has been updated and is equal to the manager field
        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.assert(u.manager__c == manager.Id);
        System.assert(u.reviewManager__c == manager.Id);
    }
    
      /**
      * Test 5
      */
      static testMethod void newUserWithManagerAndRevManagerOverride() {
        // Create a new user, provide a manager and a review manager (different users), leave the Override Manager option checked 
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User manager = GenerateEnvironmentTest.getManager();
        User reviewManager = GenerateEnvironmentTest.getSecondManager();
        User u =  new User(username='test__changeManager_test5@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmngr5',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    Manager__c = manager.Id,
                                    reviewManager__c = reviewManager.Id,
                                    overrideManager__c = true);
    
                insert u;    
  
        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.assert(u.manager__c == manager.Id);
        System.assert(u.reviewManager__c == reviewManager.Id);
        
    }
    
     /**
     *
     *  Test 6
     */
     static testMethod void newUserWithManagerAndWithoutRevManagerOverride() {
        // Create a new user, provide a manager, leave the  review manager empty, leave the Override Manager option checked 
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User manager = GenerateEnvironmentTest.getManager();
        User reviewManager = GenerateEnvironmentTest.getSecondManager();
        User u =  new User(username='test__changeManager_test6@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmngr6',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    Manager__c = manager.Id,
                                    overrideManager__c = true);
      
        insert u;   

        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.assert(u.manager__c == manager.Id);
        System.assert(u.reviewManager__c == null);
        
    }
    
     /**
     *
     * Test 7
     */
     static testMethod void newUserWithoutManagerWithReviewManagerOverride() {
        // Create a new user, leave the manager empty, fill in the review manager
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User reviewManager = GenerateEnvironmentTest.getSecondManager();
        User u =  new User(username='test__changeManager_test7@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmngr7',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    reviewManager__c = reviewManager.Id,
                                    overrideManager__c = true);

       insert u;   
          
  
        //verify that the user's manager remains blank and review manager is the one provided in the insert data
        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.assert(u.manager__c == null);
        System.assert(u.reviewManager__c == reviewManager.Id);
    }
    
    
    /**
    *  Test 8
    */
    static testMethod void newUserWithoutManagerAndReviewManagerOverride() {
        // Create a new user, leave both the manager and review manager fields empty
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User u =  new User(username='test__changeManager_test8@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmngr8',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    overrideManager__c = true);
   
        insert u;   
        
        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.assert(u.manager__c == null);
        System.assert(u.reviewManager__c == null);
        
    }
    
    /**
    *
    *  Test 9
    */
    static testMethod void updateUserManagerWithNullNoOverride() {
      
        User manager = GenerateEnvironmentTest.getManager();
        User reviewManager = GenerateEnvironmentTest.getSecondManager();
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User u =  new User(username='test__changeManager_test9@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmngr9',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    Manager__c = manager.Id,
                                    reviewManager__c = reviewManager.Id);
        insert u;   
        
                         
        u.Manager__c = null;
        
        update u;
        //verify that the user's manager is empty
        //and that the review manager was not updated and is not null
        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.assert(u.manager__c == null);
        System.assert(u.ReviewManager__c == reviewManager.Id); 
      }
    
    
    /**
    *
    * Test 10
    */
    static testMethod void updateUserManagerWithNewManagerNoOverride() {
       
        User manager = GenerateEnvironmentTest.getManager();
        User reviewManager = GenerateEnvironmentTest.getSecondManager();
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User u =  new User(username='test__changeManager_test10@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmng10',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    Manager__c = manager.Id,
                                    reviewManager__c = reviewManager.Id);
        insert u; 
       
       
        User newManager = getNewManager();
        u.Manager__c = newManager.Id;
        
      
        update u;
        
        //verify that the user's manager is still the same
        //and that the review manager has been updated and is equal to the manager field
        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.assert(u.manager__c == newManager.Id);
        System.assert(u.reviewManager__c == newManager.Id);
      
    }
    
        /** 
        *  Test 11
        *
        */
        static testMethod void updateUserReviewManagerWithNewReviewManagerNoOverride() {
       
        User manager = GenerateEnvironmentTest.getManager();
        User reviewManager = GenerateEnvironmentTest.getSecondManager();
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User u =  new User(username='test__changeManager_test11@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmng11',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    Manager__c = manager.Id,
                                    reviewManager__c = reviewManager.Id);
        insert u; 
       
       
        User newManager = getNewManager();
        u.reviewManager__c = newManager.Id;
        
        update u;
        
        //verify that the user's manager is still the same
        //and that the review manager has been updated and is equal to the manager field
        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.assert(u.manager__c != newManager.Id);
        System.assert(u.reviewManager__c == newManager.Id);
      
    }
    
        /**
        *
        *  Test 12
        */
       static testMethod void updateUserWithoutReviewManagerWithNullManagerNoOverride() {
       
        User manager = GenerateEnvironmentTest.getManager();
        User reviewManager = GenerateEnvironmentTest.getSecondManager();
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User u =  new User(username='test__changeManager_test12@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmng12',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    reviewManager__c = null,
                                    Manager__c = manager.Id);
        insert u; 
       
       
       
        u.Manager__c = null;
        
        update u;
        
        //verify that the user's manager is still the same
        //and that the review manager has been updated and is equal to the manager field
        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.debug(u.reviewManager__c);
        System.assert(u.manager__c == null);
        System.assert(u.reviewManager__c == null);
    
    }
    
  

     /**
     *
     * Test 13
     *
     */
     static testMethod void updateUserWithoutReviewManagerWithNewManagerNoOverride() {
       
        User manager = GenerateEnvironmentTest.getManager();
        User reviewManager = GenerateEnvironmentTest.getSecondManager();
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User u =  new User(username='test__changeManager_test13@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmng13',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    Manager__c = Manager.Id,
                                    reviewManager__c = null);
                        
        insert u; 
      
        User newManager = getNewManager();
        u.Manager__c = newManager.Id;
        
        update u;
        
        //verify that the user's manager is still the same
        //and that the review manager has been updated and is equal to the manager field
        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.assert(u.Manager__c == newManager.Id);
        System.assert(u.reviewManager__c == newManager.Id);
    }
    
    
        /**
        *  
        *
        *  Test 14
        */
        static testMethod void updateUserWithoutReviewManagerWithNewReviewManagerNoOverride() {
       
        User manager = GenerateEnvironmentTest.getManager();
        User reviewManager = GenerateEnvironmentTest.getSecondManager();
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User u =  new User(username='test__changeManager_test14@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmng14',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    Manager__c = Manager.Id,
                                    reviewManager__c = null);
                        
        insert u; 
      
        User newManager = getNewManager();
        u.ReviewManager__c = newManager.Id;
        
        update u;
        
        //verify that the user's manager is still the same
        //and that the review manager has been updated and is equal to the manager field
        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.assert(u.Manager__c == manager.Id);
        System.assert(u.reviewManager__c == newManager.Id);
    }
    
     /**
     *
     *  Test 15
     */
     static testMethod void updateUserWithoutManagerWithReviewManagerNullNoOverride() {
       
        User manager = GenerateEnvironmentTest.getManager();
        User reviewManager = GenerateEnvironmentTest.getSecondManager();
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User u =  new User(username='test__changeManager_test15@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmng15',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    Manager__c = null,
                                    reviewManager__c = reviewManager.Id);
                        
        insert u; 
       
      
        u.reviewManager__c = null;
        
        update u;
        
        //verify that the user's manager is still the same
        //and that the review manager has been updated and is equal to the manager field
        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.assert(u.manager__c == null);
        System.assert(u.reviewManager__c == null);
    }


     /**
     *
     *  Test 16
     */
     static testMethod void updateUserWithoutManagerWithNewReviewManagerNoOverride() {
       
        User manager = GenerateEnvironmentTest.getManager();
        User reviewManager = GenerateEnvironmentTest.getSecondManager();
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User u =  new User(username='test__changeManager_test16@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmng16',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    Manager__c = null,
                                    reviewManager__c = reviewManager.Id);
                        
        insert u; 
       
      
        User newManager = getNewManager();
        u.ReviewManager__c = newManager.Id;        
        
        update u;
        
        //verify that the user's manager is still the same
        //and that the review manager has been updated and is equal to the manager field
        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.assert(u.manager__c == null);
        System.assert(u.reviewManager__c == newManager.Id);
    
    }
    
    
    
     /**
     *  Test 17
     */
     static testMethod void updateUserWithoutManagerWithNewManagerNoOverride() {
       
        User manager = GenerateEnvironmentTest.getManager();
        User reviewManager = GenerateEnvironmentTest.getSecondManager();
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User u =  new User(username='test__changeManager_test17@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmng17',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    Manager__c = null,
                                    reviewManager__c = reviewManager.Id);
                        
        insert u; 
      
        User newManager = getNewManager();
        u.Manager__c = newManager.Id;        
        
        update u;
        
        //verify that the user's manager is still the same
        //and that the review manager has been updated and is equal to the manager field
        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.assert(u.manager__c == newManager.Id);
        System.assert(u.reviewManager__c == newManager.Id);
    
    }
    
    
     /**
     *  Test 18
     */
     static testMethod void updateUserWithReviewManagerWithNullManagerNoOverride() {
       
        User manager = GenerateEnvironmentTest.getManager();
        User reviewManager = GenerateEnvironmentTest.getSecondManager();
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User u =  new User(username='test__changeManager_test18@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmng18',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    Manager__c = null,
                                    reviewManager__c = reviewManager.Id);
                        
        insert u; 
      

        u.Manager__c = null;        
        
        update u;
        
        //verify that the user's manager is still the same
        //and that the review manager has been updated and is equal to the manager field
        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.assert(u.manager__c == null);
        System.assert(u.reviewManager__c == reviewManager.Id);
    
    }
    
       
     /**
     *  Test 19
     */
     static testMethod void updateUserWithoutManagerAndReviewManagerWithManagerNoOverride() {
       
        User manager = GenerateEnvironmentTest.getManager();
        User reviewManager = GenerateEnvironmentTest.getSecondManager();
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User u =  new User(username='test__changeManager_test19@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmng19',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    Manager__c = null,
                                    reviewManager__c = null);
                        
        insert u; 
      
        User newManager = getNewManager();
        u.Manager__c = newManager.Id;        
        
        update u;
        
        //verify that the user's manager is still the same
        //and that the review manager has been updated and is equal to the manager field
        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.assert(u.manager__c == newManager.Id);
        System.assert(u.reviewManager__c == newManager.Id);
    }
    
    
     /**
     *  Test 20
     */
     static testMethod void updateUserWithoutManagerAndReviewManagerWithNewReviewManagerNoOverride() {
       
        User manager = GenerateEnvironmentTest.getManager();
        User reviewManager = GenerateEnvironmentTest.getSecondManager();
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User u =  new User(username='test__changeManager_test20@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmng20',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    Manager__c = null,
                                    reviewManager__c = null);
                        
        insert u; 
      
        User newManager = getNewManager();
        u.reviewManager__c = newManager.Id;        
        
        update u;
        
        //verify that the user's manager is still the same
        //and that the review manager has been updated and is equal to the manager field
        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.assert(u.manager__c == null);
        System.assert(u.reviewManager__c == newManager.Id);
    
    }
    
     /**
    *
    *  Test 21
    */
    static testMethod void updateUserManagerWithNullOverride() {
      
        User manager = GenerateEnvironmentTest.getManager();
        User reviewManager = GenerateEnvironmentTest.getSecondManager();
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User u =  new User(username='test__changeManager_test21@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmng21',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    Manager__c = manager.Id,
                                    reviewManager__c = reviewManager.Id,
                                    overrideManager__c = true);
        insert u;   
        
                         
        u.Manager__c = null;
        
        update u;
        //verify that the user's manager is empty
        //and that the review manager was not updated and is not null
        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.assert(u.manager__c == null);
        System.assert(u.ReviewManager__c == reviewManager.Id); 
      }
    
    
    /**
    *
    * Test 22
    */
    static testMethod void updateUserManagerWithNewManagerOverride() {
       
        User manager = GenerateEnvironmentTest.getManager();
        User reviewManager = GenerateEnvironmentTest.getSecondManager();
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User u =  new User(username='test__changeManager_test22@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmng22',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    Manager__c = manager.Id,
                                    reviewManager__c = reviewManager.Id,
                                    overrideManager__c = true);
        insert u; 
       
       
        User newManager = getNewManager();
        u.Manager__c = newManager.Id;
        
      
        update u;
        
        //verify that the user's manager is still the same
        //and that the review manager has been updated and is equal to the manager field
        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.assert(u.manager__c == newManager.Id);
        System.assert(u.reviewManager__c == reviewManager.Id);
      
    }
    
        /** 
        *  Test 23
        *
        */
        static testMethod void updateUserReviewManagerWithNewReviewManagerOverride() {
       
        User manager = GenerateEnvironmentTest.getManager();
        User reviewManager = GenerateEnvironmentTest.getSecondManager();
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User u =  new User(username='test__changeManager_test23@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmng23',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    Manager__c = manager.Id,
                                    reviewManager__c = reviewManager.Id,
                                    overrideManager__c = true);
        insert u; 
       
       
        User newManager = getNewManager();
        u.reviewManager__c = newManager.Id;
        
        update u;
        
        //verify that the user's manager is still the same
        //and that the review manager has been updated and is equal to the manager field
        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.assert(u.manager__c != newManager.Id);
        System.assert(u.reviewManager__c == newManager.Id);
      
    }
    
        /**
        *
        *  Test 24
        */
       static testMethod void updateUserWithoutReviewManagerWithNullManagerOverride() {
       
        User manager = GenerateEnvironmentTest.getManager();
        User reviewManager = GenerateEnvironmentTest.getSecondManager();
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User u =  new User(username='test__changeManager_test24@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmng24',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    reviewManager__c = null,
                                    Manager__c = manager.Id,
                                    overrideManager__c = true);
        insert u; 
       
       
       
        u.Manager__c = null;
        
        update u;
        
        //verify that the user's manager is still the same
        //and that the review manager has been updated and is equal to the manager field
        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.debug(u.reviewManager__c);
        System.assert(u.manager__c == null);
        System.assert(u.reviewManager__c == null);
    
    }
    
  

     /**
     *
     * Test 25
     *
     */
     static testMethod void updateUserWithoutReviewManagerWithNewManagerOverride() {
       
        User manager = GenerateEnvironmentTest.getManager();
        User reviewManager = GenerateEnvironmentTest.getSecondManager();
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User u =  new User(username='test__changeManager_test25@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmng25',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    Manager__c = Manager.Id,
                                    reviewManager__c = null,
                                    overrideManager__c = true);
                        
        insert u; 
      
        User newManager = getNewManager();
        u.Manager__c = newManager.Id;
        
        update u;
        
        //verify that the user's manager is still the same
        //and that the review manager has been updated and is equal to the manager field
        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.assert(u.Manager__c == newManager.Id);
        System.assert(u.reviewManager__c == null);
    }
    
    
        /**
        *  
        *
        *  Test 26
        */
        static testMethod void updateUserWithoutReviewManagerWithNewReviewManagerOverride() {
       
        User manager = GenerateEnvironmentTest.getManager();
        User reviewManager = GenerateEnvironmentTest.getSecondManager();
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User u =  new User(username='test__changeManager_test26@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmng26',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    Manager__c = Manager.Id,
                                    reviewManager__c = null,
                                    overrideManager__c = true);
                        
        insert u; 
      
        User newManager = getNewManager();
        u.ReviewManager__c = newManager.Id;
        
        update u;
        
        //verify that the user's manager is still the same
        //and that the review manager has been updated and is equal to the manager field
        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.assert(u.Manager__c == manager.Id);
        System.assert(u.reviewManager__c == newManager.Id);
    }
    
     /**
     *
     *  Test 27
     */
     static testMethod void updateUserWithoutManagerWithReviewManagerOverride() {
       
        User manager = GenerateEnvironmentTest.getManager();
        User reviewManager = GenerateEnvironmentTest.getSecondManager();
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User u =  new User(username='test__changeManager_test27@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmng27',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    Manager__c = null,
                                    reviewManager__c = reviewManager.Id,
                                    overrideManager__c = true);
                        
        insert u; 
       
      
        u.reviewManager__c = null;
        
        update u;
        
        //verify that the user's manager is still the same
        //and that the review manager has been updated and is equal to the manager field
        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.assert(u.manager__c == null);
        System.assert(u.reviewManager__c == null);
    }


     /**
     *
     *  Test 28
     */
     static testMethod void updateUserWithoutManagerWithNewReviewManagerOverride() {
       
        User manager = GenerateEnvironmentTest.getManager();
        User reviewManager = GenerateEnvironmentTest.getSecondManager();
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User u =  new User(username='test__changeManager_test28@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmng28',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    Manager__c = null,
                                    reviewManager__c = reviewManager.Id,
                                    overrideManager__c = true);
                        
        insert u; 
       
      
        User newManager = getNewManager();
        u.ReviewManager__c = newManager.Id;        
        
        update u;
        
        //verify that the user's manager is still the same
        //and that the review manager has been updated and is equal to the manager field
        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.assert(u.manager__c == null);
        System.assert(u.reviewManager__c == newManager.Id);
    
    }
    
    
    
     /**
     *  Test 29
     */
     static testMethod void updateUserWithoutManagerWithNewManagerOverride() {
       
        User manager = GenerateEnvironmentTest.getManager();
        User reviewManager = GenerateEnvironmentTest.getSecondManager();
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User u =  new User(username='test__changeManager_test29@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmng29',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    Manager__c = null,
                                    reviewManager__c = reviewManager.Id,
                                    overrideManager__c = true);
                        
        insert u; 
      
        User newManager = getNewManager();
        u.Manager__c = newManager.Id;        
        
        update u;
        
        //verify that the user's manager is still the same
        //and that the review manager has been updated and is equal to the manager field
        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.assert(u.manager__c == newManager.Id);
        System.assert(u.reviewManager__c == reviewManager.Id);
    
    }
    
    
     /**
     *  Test 30
     */
     static testMethod void updateUserWithReviewManagerWithNullManagerOverride() {
       
        User manager = GenerateEnvironmentTest.getManager();
        User reviewManager = GenerateEnvironmentTest.getSecondManager();
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User u =  new User(username='test__changeManager_test30@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmng30',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    Manager__c = null,
                                    reviewManager__c = reviewManager.Id,
                                    overrideManager__c = true);
                        
        insert u; 
      

        u.Manager__c = null;        
        
        update u;
        
        //verify that the user's manager is still the same
        //and that the review manager has been updated and is equal to the manager field
        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.assert(u.manager__c == null);
        System.assert(u.reviewManager__c == reviewManager.Id);
    
    }
    
       
     /**
     *  Test 31
     */
     static testMethod void updateUserWithoutManagerAndReviewManagerWithManagerOverride() {
       
        User manager = GenerateEnvironmentTest.getManager();
        User reviewManager = GenerateEnvironmentTest.getSecondManager();
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User u =  new User(username='test__changeManager_test31@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmng31',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    Manager__c = null,
                                    reviewManager__c = null,
                                    overrideManager__c = true);
                        
        insert u; 
      
        User newManager = getNewManager();
        u.Manager__c = newManager.Id;        
        
        update u;
        
        //verify that the user's manager is still the same
        //and that the review manager has been updated and is equal to the manager field
        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.assert(u.manager__c == newManager.Id);
        System.assert(u.reviewManager__c == null);
    }
    
    
     /**
     *  Test 32
     */
     static testMethod void updateUserWithoutManagerAndReviewManagerWithNewReviewManagerOverride() {
       
        User manager = GenerateEnvironmentTest.getManager();
        User reviewManager = GenerateEnvironmentTest.getSecondManager();
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User u =  new User(username='test__changeManager_test32@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmng32',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    Manager__c = null,
                                    reviewManager__c = null,
                                    overrideManager__c = true);
                        
        insert u; 
      
        User newManager = getNewManager();
        u.reviewManager__c = newManager.Id;        
        
        update u;
        
        //verify that the user's manager is still the same
        //and that the review manager has been updated and is equal to the manager field
        u = [select manager__c, reviewManager__c from user where id=:u.Id limit 1];
        System.assert(u.manager__c == null);
        System.assert(u.reviewManager__c == newManager.Id);
    
    }
    
    
    
    private static User getUser(){
        User manager = GenerateEnvironmentTest.getManager();
        User reviewManager = GenerateEnvironmentTest.getSecondManager();
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User u =  new User(username='test__changeManager@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testChangeManager@salesforce.com.qa',
                                    alias='tchmngr',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    Manager__c = manager.Id,
                                    reviewManager__c = reviewManager.Id);
                                    
                                  
        insert u;   
        
        return u;                   
    }
    
    private static User getNewManager(){
        Profile p = [Select Id From Profile where Name =: 'Manager'];
        User u =  new User(username='test__newManager@peopleforce.com.qa',
                                    lastName='testChangeManager',
                                    email='testNewManager@salesforce.com.qa',
                                    alias='tnmngr',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id);
                                    
        insert u;   
        
        return u;                   
    }
    
    
    
}