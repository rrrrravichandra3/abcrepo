@SuppressWarnings(
    'PMD.CognitiveComplexity'
)
public class NHW_Org62Service {

  private static Onboarding_Setting__c onBoardingSetting = Onboarding_Setting__c.getInstance(); 
  public static String accessToken {
    set;
    get{
      if(accessToken == null){
        accessToken = NHW_Util.getAccessToken(onBoardingSetting.Org62_Token_Endpoint__c,onBoardingSetting.JWT_Aud_Endpoint__c,onBoardingSetting.PF_Certificate__c,onBoardingSetting.JWT_User_Name__c,onBoardingSetting.Org62_Consumer_Key__c);
      }
      return accessToken; 
    }

  }

  public class Org62Data {
    public list<CampaignResult> campaignList;
    public String contactId;
    public list<CampaignMemberResult> campaignMemberList;
  }

  public class CampaignResult { 
    public String campaignId;
    public String campaignName;
    public String campaignType;
    public String campaignItemId;
    public Date campaignStartDate;
    public String numberOfContacts;
    public String MaxAttendees;
    public String EnrollmentMaximum;
    public String Location;
  }

  public class CampaignMemberResult {
    public String campaignId;
    public String contactId;
    public String status;
    public Date campaignStartDate;
    public String campaignLocation;
  }

  public class Org62PostParameters{
    public String requestType; 
    public List<List<String>> incomingRequests;   }

  public class NHW_SST_MgmtH{
    public List<User> users; 
    public String errorOrWarningMessage;
    public  boolean isErrorOrWarning;
  }
  public class SSTParams{
    public String employeeNumber;
    public String email;
    public String searchString;
  }


  public static Org62Data getCampaignResults(String conEmail, String NH_Name){
    Org62Data org62Results = new Org62Data();
    org62Results.campaignList = new List<CampaignResult>();
    org62Results.campaignMemberList = new List<CampaignMemberResult>();
    HTTPResponse res;
    try{
      res = NHW_Util.performCallOut(onBoardingSetting.Org62_Service_Endpoint__c+'/'+conEmail, accessToken, 'GET', null);
    } catch(Exception e){
     PF_Logger.log('NHW','ERROR', e.getMessage(),e.getTypeName(), e.getLineNumber()+ 'Error while fetching campaign records in getCampaignResults method for conEmail = ' + conEmail, 'NHW_Org62Service', NH_Name);
    }
    if(res!=null && res.getStatusCode() == 200){
      //log returned results.. 
      org62Results = (Org62Data) JSON.deserialize(res.getBody(),Org62Data.class);
    } else{
      String errorLogDescription ='Fetch campaign records getCampaignResults method for conEmail= '+conEmail+' resBody: ';
      if(res == null){
        errorLogDescription = errorLogDescription + 'No response Received';
      }else{
        errorLogDescription = errorLogDescription + res.getBody();
      }
      
      //Fix below - causes nullpointer as errormessage in null
      PF_Logger.log('NHW','WARNING', 'Invalid Response','Invalid Response',errorLogDescription , 'NHW_Org62Service', NH_Name);
}
    NHW_Util.insertNHWLogs();
    return org62Results; 

  }

  public static List<Contact> org62Contacts(String email){
    String endpoint = onBoardingSetting.Org62_URL__c;
    String query =onBoardingSetting.Org62_Contact_Query__c.replace('<<email>>', email);
    query = EncodingUtil.urlEncode(query, 'UTF-8');

    endpoint += '/services/data/v26.0/query?q='+ query;
    HTTPResponse response = NHW_Util.queryOrg(endpoint, accessToken);
    if(response.getStatusCode() == 200){
      String responseBody = response.getBody();
      Map<String, Object> contactQueryResponse = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
      String contactsString = JSON.serialize(contactQueryResponse.get('records'));
      List<Contact> contacts = (List<Contact>)JSON.deserialize(contactsString, List<Contact>.class);
      return contacts;
    }
    return null;
  }


  public static List<User> getSSTUsers(String empNumber, String email, String searchString){

    if(empNumber == null || email ==null) {
      return null;
    }
    NHW_SST_MgmtH sstList = new NHW_SST_MgmtH();
    sstList.users = new List<User>();
    SSTParams param = new SSTParams();
    param.employeeNumber = empNumber;
    param.email = email;
    param.searchString = searchString;
    try{
      //Org62_SST_Endpoint__c
      HTTPResponse res = NHW_Util.performCallOut(onBoardingSetting.Org62_SST_Endpoint__c, accessToken, 'POST', Json.serialize(param));
      if(res!=null && res.getStatusCode() == 200){
        System.debug('success -->' + res.getBody());
        sstList = (NHW_SST_MgmtH) JSON.deserialize(res.getBody(),NHW_SST_MgmtH.class);
        //check if SST_Service is returning any warnings or errors
        if(sstList.isErrorOrWarning){
         PF_Logger.log('NHW','ERROR', NULL,null, 'Received error or warning while fetching SST Users in getSSTUsers method for email= ' + email + ' with response = ' + res.getBody(), 'Org62SSTService');
        } else {
          return sstList.users;
        }
      } else{
        PF_Logger.log('NHW','ERROR', NULL,null, 'Received response with code other than 200 in getSSTUsers method for email= ' + email + ' and response = ' + res.getBody(), 'Org62SSTService');
      }
    } catch(Exception e){
      PF_Logger.log('NHW','ERROR',e.getMessage(),e.getTypeName(), e.getLineNumber()+ 'Error while calling out Org62 SST for email= ' + email, 'NHW_Org62Service');
    }
    NHW_Util.insertNHWLogs();

    return null;

  }

  /*
      Following method peforms followings operations : 
      1) Create campaign member in org62 
      2) Update Org62 contact with updated business unit/ startdate/ email/hiring manager 
   */

  @future(callout = true)
  public static void org62CallOut(String function, List<String> campaignIds,String contactInfo,String NH_Name){
    String paramsJson;
    String descrptn = (campaignIds!=null && contactInfo!=null)? ('Org62 Callout: Create Campaign member successful ') : ('Org62 Callout: Update to Org62 contact successful '); 
    Org62PostParameters params = new Org62PostParameters(); 
    if(function == 'createCampaignMember' && (contactInfo == null || campaignIds ==null)) {
      if(function == 'createCampaignMember' && contactInfo == null){
        PF_Logger.log('NHW','ERROR','Received null contactInfo when function was equal to createCampaignMember',null, 'Null contactInfo passed to org62CallOut method', 'NHW_Org62Service',NH_Name);
      }
      else if(function == 'createCampaignMember' && campaignIds ==null){
       PF_Logger.log('NHW','ERROR','Received null campaignIds when function was equal to createCampaignMember',null, 'Null campaignIds passed to org62CallOut method', 'NHW_Org62Service',NH_Name);  
      }
      NHW_Util.insertNHWLogs();
      return;
    } // for updatecontactinfo, we pass null for  campaignId.
    else if(function == 'UpdateContactInfo' && (contactInfo == null || campaignIds!=null)){
      if(function == 'UpdateContactInfo' && contactInfo == null){
        PF_Logger.log('NHW','ERROR','Received null contactInfo when function was equal to UpdateContactInfo',null, 'Null contactInfo passed to org62CallOut method', 'NHW_Org62Service',NH_Name);
      }
      else if (function == 'UpdateContactInfo' && campaignIds != null){
       PF_Logger.log('NHW','ERROR','Received non null campaignIds when function was equal to UpdateContactInfo',null, 'Non-Null campaignIds passed to org62CallOut method', 'NHW_Org62Service',NH_Name);
      }  
      NHW_Util.insertNHWLogs();
      return; 
    }else if(function == 'UpdateTrailGuideContactInfo' && (contactInfo == null || NH_Name == null)){
        PF_Logger.log('NHW','ERROR','Received null NH Email OR Trailguide Email',null,'Null email passed to org62CallOut method', 'NHW_Org62Service',NH_Name);
        NHW_Util.insertNHWLogs();
        return; 
    }else if(function == 'rescheduleTraining' && (contactInfo == null) && (campaignIds==null || campaignIds.isEmpty())){
       PF_Logger.log('NHW','ERROR','Received null NH Email',null,'Null email passed to org62CallOut method', 'NHW_Org62Service',NH_Name);
        NHW_Util.insertNHWLogs();
        return; 
    }

    params.requestType = function;
    params.incomingRequests = new List<List<String>>();
    if(campaignIds!=null){
      params.incomingRequests.add(campaignIds);

    }
    if(contactInfo!=null && function != 'UpdateTrailGuideContactInfo'){
      params.incomingRequests.add(new List<String>{contactInfo});
    }
    if((function == 'UpdateTrailGuideContactInfo')&&(contactInfo!=null && NH_Name!=null)){
       params.incomingRequests.add(new List<String>{contactInfo,NH_Name});

    }   

    try{
      //convert params to Json.. 
      paramsJson = Json.serialize(params); 
      String calloutString = onBoardingSetting.Org62_Service_Endpoint__c + ';;' + accessToken + ';;' + 'POST' + ';;' + paramsJson;
      HTTPResponse res = NHW_Util.performCallOut(onBoardingSetting.Org62_Service_Endpoint__c, accessToken, 'POST', paramsJson);
      if(res!=null && res.getStatusCode() == 200){
       // PF_Logger.log('NHW','INFO', 'Received non-null response while performing org62CallOut with StatusCode = 200',null, descrptn+res.getBody(), 'NHW_Org62Service',NH_Name,calloutString);
        System.debug('NHW INFO - RReceived non-null response while performing org62CallOut with StatusCode = 200 '+ descrptn+res.getBody() + ' for NHW_Org62Service '+ NH_Name + ' - ' + calloutString);
      } 
      else{
          if(res == null){
            PF_Logger.log('NHW','WARNING','Received null response while performing org62CallOut',null, descrptn, 'NHW_Org62Service',NH_Name,calloutString);  
          }
          else if(res != null && res.getStatusCode() != 200){
            PF_Logger.log('NHW','WARNING','Received response while performing org62CallOut with StatusCode = ' + res.getStatusCode() ,null, descrptn+res.getBody(), 'NHW_Org62Service',NH_Name,calloutString);
          }
      }
    }  catch(Exception e){
      PF_Logger.log('NHW','ERROR',e.getMessage(),e.getTypeName(), e.getLineNumber()+ 'Error while calling out Org62 from org62CallOut method', 'NHW_Org62Service', NH_Name);
    }

    NHW_Util.insertNHWLogs();

  }

  @future(callout = true)
  public static void org62CampaingMemberDeleteCallOut(String function, List<String> contactList,String NH_Name){
    String paramsJson;
    String descrptn = (function!=null && contactList!=null && contactList.size() > 0)? ('CampaignMemberDelete Callout: Deletion of Campaign member successful ') : ('CampaignMemberDelete Callout: Received null params'); 
    Org62PostParameters params = new Org62PostParameters(); 
    if(function == 'deleteCampaignMember' && (contactList == null || contactList.size() <= 0)) {
      PF_Logger.log('NHW','ERROR','Received null or empty contactList when function was equal to deleteCampaignMember',null, 'Null or empty contactList passed to org62CampaingMemberDeleteCallOut method', 'NHW_Org62Service',NH_Name);
      NHW_Util.insertNHWLogs();
      return;
    } // for updatecontactinfo, we pass null for  campaignId.
    else if(function != 'deleteCampaignMember'){
     PF_Logger.log('NHW','ERROR','Received wrong function: ' + function,null, 'Wrong Function passed to org62CampaingMemberDeleteCallOut method', 'NHW_Org62Service',NH_Name);
      NHW_Util.insertNHWLogs();
      return;  
    }
    params.requestType = function;
    params.incomingRequests = new List<List<String>>();
    if(contactList!=null){
      params.incomingRequests.add(contactList);
    }
    try{
      //convert params to Json.. 
      paramsJson = Json.serialize(params); 
      String calloutString = onBoardingSetting.Org62_Service_Endpoint__c + ';;' + accessToken + ';;' + 'POST' + ';;' + paramsJson;
      HTTPResponse res = NHW_Util.performCallOut(onBoardingSetting.Org62_Service_Endpoint__c, accessToken, 'POST', paramsJson);
      if(res!=null && res.getStatusCode() == 200){
        //PF_Logger.log('NHW','INFO', 'Received non-null response while performing org62CampaingMemberDeleteCallOut with StatusCode = 200',null, descrptn+res.getBody(), 'NHW_Org62Service',NH_Name,calloutString);
        System.debug('NHW INFO - Received non-null response while performing org62CampaingMemberDeleteCallOut with StatusCode = 200 ' + descrptn+res.getBody() +  'for NHW_Org62Service' + NH_Name + ' - ' + calloutString);
      } 
      else{
          if(res == null){
           PF_Logger.log('NHW','WARNING','Received null response while performing org62CampaingMemberDeleteCallOut',null, descrptn+res.getBody(), 'NHW_Org62Service',NH_Name,calloutString);  
          }
          else if(res != null && res.getStatusCode() != 200){
           PF_Logger.log('NHW','WARNING','Received response while performing org62CampaingMemberDeleteCallOut with StatusCode = ' + res.getStatusCode() ,null, descrptn+res.getBody(), 'NHW_Org62Service',NH_Name,calloutString);
          }
      }
    }  catch(Exception e){
      PF_Logger.log('NHW','ERROR',e.getMessage(),e.getTypeName(), e.getLineNumber()+ 'Error while calling out Org62 from CampaignMemberDelete method', 'NHW_Org62Service',NH_Name);
    }
 
    NHW_Util.insertNHWLogs();
    
  }  



}