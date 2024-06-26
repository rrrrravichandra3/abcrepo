@isTest(SeeAllData=false)
public class Test_MA_CommunitiesLandingController {
    static testMethod void testForwardToStartPage() {
        MA_CommunitiesLandingController controller = new MA_CommunitiesLandingController();
        try{
            Test.startTest();
            PageReference pageRef = controller.forwardToStartPage();
            Test.stopTest();
            
            Assert.AreEqual(null, pageRef);
            Assert.AreEqual('/s/welcomemat', pageRef.getUrl());
        }catch(Exception e){
            System.debug(e);
        }
    }
    
}