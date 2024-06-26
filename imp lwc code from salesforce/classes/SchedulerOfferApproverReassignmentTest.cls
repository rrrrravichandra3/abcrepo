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
@isTest(seeAllData=true)
public with sharing class SchedulerOfferApproverReassignmentTest {
   
  public  testmethod static void testReassignmentOfApprovers(){
     
    String cron_exp = '0 0 0 3 9 ? 2022'; 
    Test.startTest();
    SchedulerOfferApproverReassignment scheduler = new SchedulerOfferApproverReassignment();
      String jobId = System.schedule('testBasicScheduledApex',cron_exp,scheduler);
    Test.stopTest();
    CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger where id=:SchedulerOfferApproverReassignment.selfScheduleJobId ];
    // Verify the job has not run 
    System.assertEquals(0, ct.TimesTriggered);
    
    String thisyear = String.valueOf(Date.today().year());
    
    System.assert(ct.CronExpression.contains(thisyear));
    
    }
}