public without sharing class PF_NHW_AdditionalInfoService extends PF_NHW_PageService{
    
    protected override List<PF_NHW_LightningComponentConfiguration> getComponentsConfig(){
        return PF_NHW_LightningComponentsService.getComponentsConfigForCaseAndPage(provisioningCase, PF_NHW_Page.TRAININGS);
    }
    
    public override String processPageInformation(){
        return provisioningCase.Id;
    }
    
    
    public override List<ReviewItem> getReviewList(Case provisioningCase, PF_NHW_Process process){
        List<ReviewItem> reviewList = new List<ReviewItem>();
        reviewList.add(new ReviewItem('Comments',provisioningcase.Description));                             
        return reviewList;
    }
}