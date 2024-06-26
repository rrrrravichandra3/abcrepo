/**
* #DreamJobCentral
* @date:        4/30/2013 
* @description: Controller for ESDJC_ChatButton. Show chat button all pages according to division and business hours for logged in user.
**/
public with sharing class ESDJC_LiveAgentChatController {
        public String liveChatBtnId{get; set;}
        public String liveChatDepId{get; set;}
        public String liveAgentUserEmail{get; set;}
        public String liveAgentUserName{get; set;}
        public String liveAgentUserId{get; set;}
        public id userId{get;set;}
        public boolean isLiveAgentAvailable{get;set;}
        public boolean displayLiveAgent{get;set;}
        public String dayOfWeek;
        
        public ESDJC_LiveAgentChatController(){
            ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
        	dayOfWeek = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).format('EEEE');
            determineLiveAgentAvailability(dayOfWeek);
            LiveChatButton ICBId =[Select Id from LiveChatButton where DeveloperName='ES_DJC_EMEA' LIMIT 1];
            Datetime tempDate = datetime.newInstance(0000, 00, 0, 00, 00, 0);
            String latestId;
            // Get id of chat button to be showed for the user. 
            List<LiveChatDeployment> IDIds = [SELECT Id, CreatedDate from LiveChatDeployment where DeveloperName='ES_DJC'];
                for (LiveChatDeployment d :IDIds){
                if (d.CreatedDate > tempDate){
                    latestId = d.id;
                }
            }
            liveChatBtnId = String.valueOf(ICBId.Id);
            liveChatDepId = latestId;
            // below 2 statments are the only once we are using at Novo as it met the requirement 
            //liveAgentUserName = UserINfo.getName();
            //liveAgentUserEmail = UserINFO.getUserEmail();
            System.debug('++++UserINfo.getName()='+UserINfo.getName());
            System.debug('++++UserINFO.getUserEmail()='+UserINFO.getUserEmail());
           List<User> users = [SELECT email, name, ContactId from User WHERE email=:UserINFO.getUserEmail() and ProfileId=:settings.Portal_User_Profile_Id__c and ContactId != null and IsActive = true];
           if(users.size() > 0){
           User user = users.get(0);
            liveAgentUserName = user.Name;
            liveAgentUserEmail = user.Email;
            liveAgentUserId = user.ContactId;
           } else {
            liveAgentUserName = UserINfo.getName();
            liveAgentUserEmail = UserINFO.getUserEmail();
           }
        }
  
    /*
     * Method to determine whether the user is accessing the page
     * during business hours.  If they are not the agent button will
     * be disabled.
     */ 
    public void determineLiveAgentAvailability(string dayOfWeek) {
        
        isLiveAgentAvailable = false;
        displayLiveAgent = false;
        //Get users region and from that determine business hours
        User user = [SELECT Division FROM User WHERE Id = :UserInfo.getUserId()];
        String region = ESDJC_Util.getRegionFromDivision(user.Division);
        if(region == 'EMEA'){
            displayLiveAgent = true;    
        }
        BusinessHours hours = [SELECT Id, Name, SundayStartTime, SundayEndTime, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime FROM BusinessHours WHERE Name = :region AND isActive = true];
                                
        //get day of week and use that to determine business start and end times.
        
               
        Time startTime = null;
        Time endTime = null;
                
        if (dayOfWeek == 'Monday') {
            startTime = hours.MondayStartTime;
            endTime = hours.MondayEndTime;
        } else if (dayOfWeek == 'Tuesday') {
            startTime = hours.TuesdayStartTime;
            endTime = hours.TuesdayEndTime;
        } else if (dayOfWeek == 'Wednesday') {
            startTime = hours.WednesdayStartTime;
            endTime = hours.WednesdayEndTime;
        } else if (dayOfWeek == 'Thursday') {
            startTime = hours.ThursdayStartTime;
            endTime = hours.ThursdayEndTime;
        } else if (dayOfWeek == 'Friday') {
            startTime = hours.FridayStartTime;
            endTime = hours.FridayEndTime;
        } else if (dayOfWeek == 'Saturday') {
            startTime = hours.SaturdayStartTime;
            endTime = hours.SaturdayEndTime;
        } else if (dayOfWeek == 'Sunday') {
            startTime = hours.SundayStartTime;
            endTime = hours.SundayEndTime;
        }               
    
        System.debug('DAY OF WEEK - ' + dayOfWeek);
        System.debug('START TIME  - ' + startTime);
        System.debug('END TIME    - ' + endTime);
        System.debug('TIME NOW    - ' + DateTime.now().timeGMT());

        if (startTime != null) //could be sat or sun in some regions
        {
            if (DateTime.now().timeGMT() > startTime && (DateTime.now().timeGMT() < endTime ||  endTime.hour() == 00)) {
                isLiveAgentAvailable = true;
                System.debug('LIVE AGENT IS TRUE');
            } else {
                System.debug('LIVE AGENT IS FALSE');
            }
        }
      
    }
    
}