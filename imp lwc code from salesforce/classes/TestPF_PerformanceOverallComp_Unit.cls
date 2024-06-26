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
private class TestPF_PerformanceOverallComp_Unit {

    static testMethod void PerformanceOverallCompetencyCont() 
    {
       GenerateEnvironmentTest3.genScorecardMetricEducation();
       
       test.startTest();
       PerformanceCompetencyController competencyController = new PerformanceCompetencyController(GenerateEnvironmentTest3.competencyGroupMember1, GenerateEnvironmentTest3.PRIndividualQ1Q2Edu);
       
       competencyController.getCompetency();
       try{
       	competencyController.getRating();
       	competencyController.getRatingShow();	
       }catch(Exception e){
       	
       }
       
       competencyController.setHistory(new List<CompetencyReview__c>());
       competencyController.getHistory();
       competencyController.getHistoryFormatted();
       competencyController.setWeight(0);
       competencyController.getWeigthShow();
       competencyController.getWeight();
       competencyController.setWeight(null);
       competencyController.getWeigthShow();
       competencyController.getWeight();
       competencyController.setRating(0); 
       competencyController.setCompetency(GenerateEnvironmentTest3.competencyGroupMember1);
       
       CompetencyReview__c compRev = new CompetencyReview__c();
       compRev.CreatedDate = date.newInstance(2010,1,1);
       compRev.LastModifiedDate = date.newInstance(2010,1,1);
       
       
       PerformanceCompetencyController.CompetencyReviewDate testCompetencyReview = new PerformanceCompetencyCOntroller.CompetencyReviewDate(compRev);
       
       testCompetencyReview.getCompetencyReview();
       testCompetencyReview.getReviewerName();
       testCompetencyReview.getLastModifiedDate();
       testCompetencyReview.getCreatedDate();
       testCompetencyREview.setCreatedDate('2010-17-12');
       testCompetencyREview.getCompetencyReview();
       test.stopTest();
    }
}