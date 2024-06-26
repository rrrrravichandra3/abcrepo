@istest
public class NHW_MockCampaignResponseGenerator implements HttpCalloutMock{
    
    public  boolean generateCustomCampaigns = false;
    public map<string,set<Date>> mCampaignTypetoStartDateList = new map<string,set<date>>();
    
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
              
        // Create a fake response
        HttpResponse res = new HttpResponse(); 
        res.setHeader('Content-Type', 'application/json');
        String CampaignResponseJSON = '';
        if(generateCustomCampaigns){ 
        	if(mCampaignTypetoStartDateList.size()>0 ){
          		 CampaignResponseJSON = NHW_TestFactory.getCustomMockCampaignsJSON(mCampaignTypetoStartDateList);      		
        	}
        	else{
        		throw new NHWException('Please populate mCampaignTypetoStartDateList to use custom campaign response generation ');
        	}  
        }
        else{
     	 CampaignResponseJSON = NHW_TestFactory.getMockCampaignsJSON();
        }
        res.setBody(CampaignResponseJSON);
        res.setStatusCode(200);
        return res;
    }
    public void setmCampaignTypetoStartDateList(map<string,set<date>> mCampaignTypetoStartDateList){
    	this.mCampaignTypetoStartDateList = mCampaignTypetoStartDateList;
    }
    public void setCampaignDatesForCampaignType(String CampaignType,set<Date> SDs){
    	if(mCampaignTypetoStartDateList.containsKey(CampaignType)){
    	  mCampaignTypetoStartDateList.get(CampaignType).addAll(SDs);
    	}else{
    	  mCampaignTypetoStartDateList.put(CampaignType,SDs);
    	}
    }
    public void setGenerateCustomCampaigns(Boolean setGenerate){
    	this.GenerateCustomCampaigns = setGenerate;
    }
}