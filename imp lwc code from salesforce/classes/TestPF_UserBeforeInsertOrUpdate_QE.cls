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
private class TestPF_UserBeforeInsertOrUpdate_QE {



    /**
    * Test 1
    */
    static testMethod void newUserWithoutManagerAndReviewManagerNoOverride() {
        // Create a new user, leave both the manager and review manager fields empty
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User u =  new User(username='test__changeManager@peopleforce1.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager2@peopleforce.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager3@peopleforce.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager4@peopleforce.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager5@peopleforce.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager6@peopleforce.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager7@peopleforce.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager8@peopleforce.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager9@peopleforce.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager10@peopleforce.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager11@peopleforce.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager12@peopleforce.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager13@peopleforce.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager14@peopleforce.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager15@peopleforce.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager16@peopleforce.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager17@peopleforce.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager18@peopleforce.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager19@peopleforce.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager20@peopleforce.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager21@peopleforce.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager22@peopleforce.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager23@peopleforce.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager24@peopleforce.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager25@peopleforce.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager26@peopleforce.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager27@peopleforce.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager28@peopleforce.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager29@peopleforce.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager30@peopleforce.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager31@peopleforce.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager32@peopleforce.com.qa',
                                    lastName='testChangeManager2',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
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
        User u =  new User(username='test__changeManager11@peopleforce.com.qa',
                                    lastName='testChangeManager22',
                                    email='testChangeManager2@salesforce.com.qa',
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
                                    lastName='testChangeManager244',
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